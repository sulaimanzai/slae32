global _start

section .text

_start:	
	
	jmp short name	
	
callback:

	pop esi			; has the address of 'hacke'
	xor eax,eax		; zero out eax
	mov [esi+0x6],al	; add a null byte at the # so it becomes 'hacked\0'
	mov al,0x27			
	lea ebx,[esi]		; loads the address of the string in ebx
	mov cx,0x1ed		; sets mode at 755
	int 0x80		

	mov al,0x1		; exit call
	xor ebx,ebx
	int 0x80

name:
	call callback
	push dword 0x656b6361	; 'hacke' the 'pushd dword' is hex 68 or 'h'
	fs			; 'd'
	db 0x23			; '#'
