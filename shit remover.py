""" A proof of concept showing how a certain person would choose to
access and write to files. I honestly still don't know how this works.
Written by https://github.com/andrensegura """ 

import os
f = os.open( "p.txt", os.O_RDWR) #Create the file 
os.write(f, b"This is a test \n")  #Try to write 
os.close(f)
