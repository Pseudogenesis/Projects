import os
f = os.open( "p.txt", os.O_RDWR) #Create the file 
os.write(f, b"This is a test \n")  #Try to write 
os.close(f)
