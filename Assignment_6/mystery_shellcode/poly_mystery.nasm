global _start

section .text

_start:	
	
;	jmp short name	
	
;callback:

	;popi esi		; has the starting address of 'hacke'
	sub eax,eax		; zero out eax
	mul ecx
	;mov [esi+0x6],al	; add a null byte at the # so it becomes 'hacked\0'
	push eax		; push null bytes in the stack
	mov eax, 0x64656B62
	inc eax
	push eax
	sub eax, eax
	mov ax, 0x6167
	inc eax
	push ax

	xor eax, eax		; zero out eax	
	mov al,0x26
	inc eax			
	mov ebx, esp		; loads the address of the string in ebx
	mov cx,0x1ec		; sets mode at 754
	inc cx			; restore it to 755
	int 0x80		

	mov al,0x2		; exit call
	dec al
	sub ebx,ebx
	int 0x80

;name:
;	call callback
;	push dword 0x656b6361	; 'hacke' the 'pushd dword' is hex 68 or 'h'
;	fs			; 'd'
;	db 0x23			; '#'
