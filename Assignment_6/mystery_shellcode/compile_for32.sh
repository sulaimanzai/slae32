#!/bin/bash

echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o $1.o $1.nasm

echo '[+] Linking ...'
#ld -o $1 $1.o
ld -N -m elf_i386 -o $1 $1.o 

echo '[+] Done!'



