 .model small
 .stack 100h
 .data

 imsg1 db " Enter Input1 ( PlainText ): $"
 imsg2 db " Enter Input2 (RSA encrypted String ): $"
 imsg3 db " Enter Input3 : $"

 omsg1 db " Output1 for RSA ( Encryption ): $"
 omsg3 db " Output3 for RSA ( Decryption ): $"

 nextLine db 0ah ,0dh ,’$’

 input1 db 256 dup ('$')
 input2 db 256 dup ('$')
 input3 db 256 dup ('$')

 output1 dw 256 dup ('$')
 output2 dw 256 dup ('$')
 output3 dw 256 dup ('$')
 output4 dw 256 dup ('$')

 x dw 13d ;x must be a prime
 y dw 3d ;y must be a prime x!=y

 n dw 0
 t dw 0
 i dw 0
 flag dw 0
 dollar dw '$'

 e dw 0
 d dw 0
 j dw 0
 k dw 0
 pt dw 0
 ct dw 0


 num dw 0


 .code




 ; Display Part

 ; End Disp Procedure


 main proc




 mov ax , @data
 mov ds ,ax

 mov ax ,0
 mov ax ,x
 mov bx ,y
 mul bl

 mov n,ax

 ;n = x * y calculated above

 mov ax ,0
 mov ax ,x
 mov bx ,y
 dec al
 dec bl
 mul bl
 mov t,ax

 ; t = (x -1) * (y - 1) calculated



 call getInput1
 call time

 lea dx , nextLine
 mov ah ,09
 int 21h

 call encryptionKeys

 call encryptRSA


 mov ah ,09
 lea dx , omsg1
 int 21h


 lea si , output1

 call printoutput
 call time

 lea dx , nextLine

 mov ah ,09
 int 21h

 call getInput2
 call time

 lea dx , nextLine
 mov ah ,09
 int 21h


 call decryptRSA


 mov ah ,09
 lea dx , omsg3
 int 21h

 lea si , output3
 call printoutput
 call time
 lea dx , nextLine
 mov ah ,09
 int 21h

 exit :
 mov ah ,4ch
 int 21h

 main endp




 proc getInput1

 lea dx , imsg1
 mov ah ,09
 int 21h

 lea si , input1
 input11 : mov ah ,1
 int 21h
 cmp al ,0dh
 je end11
 mov [si],al
 inc si
 jmp input11
 end11 :
 ret


 proc getInput2

 lea dx , imsg2
 mov ah ,09
 int 21h
 lea si , input2
 input22 : mov ah ,1
 int 21h
 cmp al ,0dh
 je end22
 mov [si],al
 inc si
 jmp input22
 end22 :
 ret


 proc getInput3

 lea dx , imsg3
 mov ah ,09
 int 21h
 lea si , input3
 input33 : mov ah ,1
 int 21h
 cmp al ,0dh
 je end33

 mov [si],al
 inc si
 jmp input33
 end33 :
 ret




 proc isPrime

 mov flag ,1
 mov ax , num
 cmp ax ,0
 je F1
 cmp ax ,1
 je F1
 mov dx ,0

 mov bx ,2

 ploop : cmp bx , num
 je pdone
 div bx
 cmp dx ,0
 je F1
 mov ax , num
 inc bx
 mov dx ,0
 jmp ploop

 F1:mov flag ,0
 pdone :
 ret

 proc encryptionKeys

 mov i ,2


 enckey : mov ax ,t
 cmp i,ax
 jge encEnd

 mov ax ,t
 mov dx ,0
 div i
 cmp dx ,0
 je encNext

 mov ax ,i
 mov num ,ax
 call isPrime
 cmp flag ,0
 je encNext
 mov ax ,i
 cmp ax ,x
 je encNext
 cmp ax ,y
 je encNext
 mov ax ,i
 mov e,ax
 mov num ,ax

 call calculateD

 cmp flag ,0
 jle encNext
 mov ax , flag
 mov d,ax
 jmp encEnd

 encNext :
 inc i
 jmp enckey

 encEnd :

 ret




 proc calculateD
 mov k ,1

 cdLoop : mov ax ,t
 add k,ax

 mov dx ,0
 mov ax ,k
 div num
 cmp dx ,0
 jne cdLoop
 mov flag ,ax

 ret


 proc encryptRSA


 lea si , input1
 lea di , output1


 encLoopRSA :
 mov ax ,0
 mov al ,[ si]
 mov pt ,ax
 mov bx , dollar
 cmp pt ,bx
 je endeRSA
 sub pt ,96d
 mov k ,1
 mov j ,0
 kloop : mov ax ,e
 cmp j,ax
 jge nextRSA


 mov ax ,0
 mov dx ,0
 mov ax ,k
 mul pt
 mov dx ,0
 div n
 mov k,dx
 inc j
 jmp kloop

 nextRSA :
 add k ,96d
 mov ax ,k
 mov [di],al
 inc di
 inc di
 inc si
 jmp encLoopRSA
 endeRSA :

 ret

 proc decryptRSA

 lea si , input2
 lea di , output3


 decLoopRSA :
 mov ax ,0
 mov al ,[ si]
 mov ct ,ax
 mov bx , dollar
 cmp ct ,bx
 je enddRSA
 sub ct ,96d
 mov k ,1
 mov j ,0

 kdloop : mov ax ,d
 cmp j,ax
 jge nextRSAd

 mov ax ,0
 mov dx ,0
 mov ax ,k
 mul ct
 mov dx ,0
 div n
 mov k,dx
 inc j
 jmp kdloop

 nextRSAd :
 add k ,96d
 mov ax ,k
 mov [di],al
 inc di
 inc di
 inc si
 jmp decLoopRSA
 enddRSA :



 ret



 proc printoutput


 oloop : mov ax ,0
 mov al ,[ si]
 cmp ax , dollar
 je oend
 mov dx ,ax
 mov ah ,02

 int 21h
 inc si
 inc si

 jmp oloop

 oend :
 ret

 proc time
 MOV AX , @DATA
 MOV DS ,AX

 mov dx ,13
 mov ah ,2
 int 21h
 mov dx , 10
 mov ah ,2
 int 21h
 ; Hour Part
 HOUR :
 MOV AH ,2CH ; To get System Time
 INT 21H
 MOV AL ,CH ; Hour is in CH
 AAM
 MOV BX ,AX
 MOV DL ,BH ; Since the values are in BX , BH Part
 ADD DL ,30H ; ASCII Adjustment
 MOV AH ,02H ; To Print in DOS
 INT 21H
 MOV DL ,BL ; BL Part
 ADD DL ,30H ; ASCII Adjustment
 MOV AH ,02H ; To Print in DOS
 INT 21H

 MOV DL ,':'
 MOV AH ,02H ; To Print : in DOS
 INT 21H


 ; Minutes Part
 MINUTES :
 MOV AH ,2CH ; To get System Time
 INT 21H
 MOV AL ,CL ; Minutes is in CL
 AAM
 MOV BX ,AX
 MOV DL ,BH ; Since the values are in BX , BH Part
 ADD DL ,30H ; ASCII Adjustment
 MOV AH ,02H ; To Print in DOS
 INT 21H
 MOV DL ,BL ; BL Part
 ADD DL ,30H ; ASCII Adjustment
 MOV AH ,02H ; To Print in DOS
 INT 21H

 MOV DL ,':' ; To Print : in DOS
 MOV AH ,02H
 INT 21H

 ; Seconds Part
 Seconds :
 MOV AH ,2CH ; To get System Time
 INT 21H
 MOV AL ,DH ; Seconds is in DH
 AAM
 MOV BX ,AX
 MOV DL ,BH ; Since the values are in BX , BH Part
 ADD DL ,30H ; ASCII Adjustment
 MOV AH ,02H ; To Print in DOS
 INT 21H
 MOV DL ,BL ; BL Part
 ADD DL ,30H ; ASCII Adjustment
 MOV AH ,02H ; To Print in DOS
 INT 21H
 mov dx ,13
 mov ah ,2
 int 21h
 mov dx , 10

 mov ah ,2
 int 21h
 ret

 end main
