import re # Importing Regular Expressions package
import os # Importing operating system package, to clear console of text later

charNames = {"charData_1":"Fish", "charData_2":"Crystal", "charData_3":"Eyes",
             "charData_4":"Melting", "charData_5":"Plant", "charData_6":"Y.V.",
             "charData_7":"Steroids", "charData_8":"Robot", "charData_9":"Chicken",
             "charData_10":"Rebel", "charData_11":"Horror", "charData_12":"Rogue", }
              
crownIDs = {1:"Death", 2:"Life", 3:"Haste", 4:"Guns",5:"Hatred",6:"Blood", 7:"Destiny", 8:"Love", 9:"Luck", 10:"Curses", 11:"Risk", 12:"Protection"}
              

def checkNuclearThroneSav():
    try:
        with open('nuclearthrone.sav', 'r') as saveFile: # Save file accessible but not yet in text form
            saveDataRaw = saveFile.read() # Lets us read the file as raw text
            saveDataArray = re.sub("[^\w]", " ",  saveDataRaw).split() # Regex, removes all non alphanumeric characters and splits each word into its own
                                                                   # array position. Every word in the save file is now stored individually in this
                                                                   # array.
    except FileNotFoundError: # If the program can't find the save file.
        print("==================================================")
        print("nuclearthrone.sav not found. Make sure this program is in the same directory as the save file, then press Enter to try again.")
        print()
        if re.sub("^[ \t]+|[ \t]+$", "", input("Alternatively, type \"other\" to try reading vanilla Nuclear Throne's save instead.\n")) == "other": # Clusterfuck
            checkNuclearThroneSav()
        else:
            checkNuclearThroneTogetherSav()
        
    os.system("cls")
    print("Opening nuclearthrone.sav")
    print("==================================================")
    
    for i in saveDataArray: # Iterating through the words in the save file, looking for character data
        if i in charNames: # If character data is found
            crownsUnlocked = [] # We create new arrays to store locked and unlocked crowns, or delete old contents we no longer need.
            crownsLocked = []
            print("\033[4m" + charNames[i] + "\033[0m") # This is the character whose unlocks we're currently looking at. Uses awesome ANSI escape characters for underline effect.
            currentPlace = (saveDataArray.index(i) + 18) # When formatted using re.sub("[^\w]", " ",  saveDataRaw).split(), the
                                                         # first crown is 18 array places after the character data.
                                                         # We use this variable to keep track of where we are in the file.
            for x in crownIDs:
                if saveDataArray[currentPlace] == "1": # If the crown is unlocked
                    crownsUnlocked.append(crownIDs[x]) # Adds crown to unlocked crowns array
                    currentPlace += 2 # With the formatting I used, each crown is two array places ahead of the last
                else:
                    crownsLocked.append(crownIDs[x]) # Otherwise, the crown is considered locked and we move on.
                    currentPlace += 2
            print("Crowns unlocked:", ", ".join(crownsUnlocked))
            print("Crowns locked:", ", ".join(crownsLocked))
            print("==================================================")
            
    input("If you would like to switch to reading NuclearThroneTogether's save file, press Enter now.")
    os.system("cls") 
    checkNuclearThroneTogetherSav()
    

def checkNuclearThroneTogetherSav(): # Same exact function as above, but for NuclearThroneTogether.sav.
    print("==================================================")
    print("Opening nuclearthronetogether.sav")
    print("==================================================")
    try:
        with open('nuclearthronetogether.sav', 'r') as saveFile:
            saveDataRaw = saveFile.read()
            saveDataArray = re.sub("[^\w]", " ",  saveDataRaw).split()
    except FileNotFoundError:
        print("nuclearthronetogether.sav not found. Make sure this program is in the same directory as the save file, then press Enter to try again.")
        print()
        if re.sub("^[ \t]+|[ \t]+$", "", input("Alternatively, type \"other\" to try reading vanilla Nuclear Throne's save instead.\n")) == "other":
            checkNuclearThroneSav()
        else:
            checkNuclearThroneTogetherSav()
            
    os.system("cls")
    
    for i in saveDataArray: 
        if i in charNames: 
            crownsUnlocked = [] 
            crownsLocked = []
            print("\033[4m" + charNames[i] + "\033[0m") 
            currentPlace = (saveDataArray.index(i) + 18)
                  
            for x in crownIDs:
                if saveDataArray[currentPlace] == "1": 
                    crownsUnlocked.append(crownIDs[x]) 
                    currentPlace += 2 
                else:
                    crownsLocked.append(crownIDs[x]) 
                    currentPlace += 2
            print("Crowns unlocked:", ", ".join(crownsUnlocked))
            print("Crowns locked:", ", ".join(crownsLocked))
            print("==================================================")
    input("If you would like to switch to reading NuclearThrone's save file, press Enter now.")
    placeholderVariable = os.system("cls") 
    checkNuclearThroneSav()
    
os.system("cls")
checkNuclearThroneSav()
        

