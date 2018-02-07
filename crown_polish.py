import re # Importing Regular Expressions package
import os # Importing operating system package, to clear console from text and automatically size terminal window

os.system('mode con: cols=140 lines=55')

class tformat: # Ansi escape characters which allow for colors & formatting
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[33m'
    INTENSEYELLOW = '\033[93m'
    CYAN = '\033[36m'
    INTENSECYAN = '\033[96m'
    UNDERLINE = '\033[4m'
    INTENSEWHITE = '\033[97m'
    PURPLE = '\033[95m'
    NORMAL = '\033[0m'
    

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
                                                                   # array position. Every word in the save file is now stored individually in this array.
    except FileNotFoundError: # If the program can't find the save file.
        print("=============================================================================================================================")
        input("nuclearthrone.sav not found. Make sure this program is in the same directory as the save file, then press Enter to try again. \n")
        checkNuclearThroneSav()
        
    os.system("cls") # Clears all text from console, Windows only
    print("Opening nuclearthrone.sav")
    print("=============================================================================================================================")
    
    for i in saveDataArray: # Iterating through the words in the save file, looking for character data
        if i in charNames: # If character data is found
            postloopCrownsUnlocked = [] # We create new arrays to store locked and unlocked crowns, or delete old contents we no longer need.
            preloopCrownsUnlocked = []
            postloopCrownsLocked = []
            preloopCrownsLocked = []
            print(tformat.UNDERLINE + tformat.INTENSEWHITE + charNames[i] + tformat.NORMAL) # This is the character whose unlocks we're currently looking at.
            currentPlace = (saveDataArray.index(i) + 18) # When formatted using re.sub("[^\w]", " ",  saveDataRaw).split(), the
                                                         # first crown is 18 array places after the character data.
                                                         # We use this variable to keep track of where we are in the file.
            for x in crownIDs:
                if saveDataArray[currentPlace] == "1": # If the crown is unlocked
                    if x in [1, 5, 6, 8, 9, 12]:
                        postloopCrownsUnlocked.append(crownIDs[x]) # Adds crown to unlocked crowns array
                    else:
                        preloopCrownsUnlocked.append(crownIDs[x])
                    currentPlace += 2 # With the formatting I used, each crown is two array places ahead of the last
                else:
                    if x in [1, 5, 6, 8, 9, 12]:
                        postloopCrownsLocked.append(crownIDs[x]) # Otherwise, the crown is considered locked and we move on.
                    else:
                        preloopCrownsLocked.append(crownIDs[x])
                    currentPlace += 2
            if not postloopCrownsUnlocked:
                postloopCrownsUnlocked.append("NONE")
            if not preloopCrownsUnlocked:
                preloopCrownsUnlocked.append("NONE")
            if not postloopCrownsLocked:
                postloopCrownsLocked.append("NONE")
            if not preloopCrownsLocked:
                preloopCrownsLocked.append("NONE")
            print()
            print(tformat.RED + "Locked:  " + tformat.NORMAL, tformat.INTENSEYELLOW + tformat.UNDERLINE + "Preloop: " + ", ".join(preloopCrownsLocked) + tformat.NORMAL + tformat.PURPLE + " || " + tformat.NORMAL + tformat.INTENSECYAN + tformat.UNDERLINE + "Postloop: " + ", ".join(postloopCrownsLocked) + tformat.NORMAL)
            print("=============================================================================================================================")
    input("To toggle " + tformat.PURPLE + "showing" + tformat.NORMAL + " unlocked crowns, press Enter.")
    os.system("cls")
    checkNuclearThroneSavShown() # Triggers if the input() is accepted, ie if Enter is pressed

def checkNuclearThroneSavShown(): # Exact same thing, but with unlocked crowns displaying.
    try:
        with open('nuclearthrone.sav', 'r') as saveFile: 
            saveDataRaw = saveFile.read() 
            saveDataArray = re.sub("[^\w]", " ",  saveDataRaw).split() 
                                                                   
    except FileNotFoundError: 
        print("=============================================================================================================================")
        input("nuclearthrone.sav not found. Make sure this program is in the same directory as the save file, then press Enter to try again. \n")
        checkNuclearThroneSav()
        
    os.system("cls")
    print("Opening nuclearthrone.sav")
    print("=============================================================================================================================")
    
    for i in saveDataArray: 
        if i in charNames: 
            postloopCrownsUnlocked = [] 
            preloopCrownsUnlocked = []
            postloopCrownsLocked = []
            preloopCrownsLocked = []
            print(tformat.UNDERLINE + tformat.INTENSEWHITE + charNames[i] + tformat.NORMAL) 
            currentPlace = (saveDataArray.index(i) + 18) 
                                                         
                                                         
            for x in crownIDs:
                if saveDataArray[currentPlace] == "1": 
                    if x in [1, 5, 6, 8, 9, 12]:
                        postloopCrownsUnlocked.append(crownIDs[x]) 
                    else:
                        preloopCrownsUnlocked.append(crownIDs[x])
                    currentPlace += 2 
                else:
                    if x in [1, 5, 6, 8, 9, 12]:
                        postloopCrownsLocked.append(crownIDs[x]) 
                    else:
                        preloopCrownsLocked.append(crownIDs[x])
                    currentPlace += 2
            if not postloopCrownsUnlocked:
                postloopCrownsUnlocked.append("NONE")
            if not preloopCrownsUnlocked:
                preloopCrownsUnlocked.append("NONE")
            if not postloopCrownsLocked:
                postloopCrownsLocked.append("NONE")
            if not preloopCrownsLocked:
                preloopCrownsLocked.append("NONE")
            print(tformat.GREEN + "Unlocked:" + tformat.NORMAL + tformat.YELLOW + " Preloop: " + ", ".join(preloopCrownsUnlocked) + tformat.NORMAL + tformat.PURPLE + " || " + tformat.NORMAL + tformat.CYAN + "Postloop: " + ", ".join(postloopCrownsUnlocked) + tformat.NORMAL)
            print(tformat.RED + "Locked:  " + tformat.NORMAL, tformat.INTENSEYELLOW + tformat.UNDERLINE + "Preloop: " + ", ".join(preloopCrownsLocked) + tformat.NORMAL + tformat.PURPLE + " || " + tformat.NORMAL + tformat.INTENSECYAN + tformat.UNDERLINE + "Postloop: " + ", ".join(postloopCrownsLocked) + tformat.NORMAL)
            print("=============================================================================================================================")
    input("To toggle " + tformat.PURPLE + "hiding" + tformat.NORMAL + " unlocked crowns, press Enter.")
    os.system("cls")
    checkNuclearThroneSav()

checkNuclearThroneSav() # It begins
