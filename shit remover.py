""" A simple script to remove all non-alphanumeric characters in text files with some readable text 
and LOTS of random characters. Works decently but doesn't catch everything. 
Encoding is set to latin-1 because otherwise IDLE throws a "UnicodeDecodeError". """

import re # Regular expressions package
origin = open(r"C:\Users\Sam\Desktop\Quarantine\origin.dat", "r+", encoding="latin-1")       # The "r" before the directory makes it
subtitles = open(r"C:\Users\Sam\Desktop\Quarantine\subtitles.dat", "r+", encoding="latin-1") # a raw string, elminating the need for escape chars. 
subtitles.write(re.sub('[^a-zA-Z0-9_\s:]', '',origin.read())) # I have no goddamn idea how that regex works, just took it from stackoverflow                              
origin.close()
subtitles.close()
