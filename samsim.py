# -*- coding: cp1252 -*-
#imports
from random import randint
import time
import textwrap
#formatting
"""I was going to try and use a textwrapper class here
so it could apply to the whole program but I couldn't get it to work.
Instead I just used textwrap to wrap all instances of print individually,
which ended up making the code a little messier but it gets the job done."""
#gamestate variables
game_active = True
in_bed = True
alarm_on = True
jump_count = 0
alarm_on = True
localtime = time.asctime( time.localtime(time.time()) )
# introduction

print textwrap.fill('Welcome to Sam Simulator 2015, the next generation in Sam '
    'simulation technology. This is a text adventure game, so to control '
    'your Sam you must type an action into the console and press Enter. For example, saying Jump will cause your Sam to jump, and saying Examine Bed will'
    ' examine the bed. There is no need to move, once you\'re out of bed you can interact with any object in the room. '
    'Just don\'t type multiple objects or actions at once, it won\'t work the way you want it to. There are no ultimate goals or puzzles to solve, '
    'just play around with whatever\'s '
    'in the room. ', width = 75)
print
print textwrap.fill('For a list of '
    'available actions, type Help or ?. For a list of interactable objects, type Objects. For a random hint, type Hint. To exit, type Quit. Have fun!', width = 75)

print
print textwrap.fill("You awaken from sleep. Light is shining into your Room through the Window. Your head hurts. An Alarm is going off, and you really "
	"want to smash it. Looks like it's time to Get Up.",width = 75)
print
# items shit
class Item(object):
    def __init__(self, name, altname, desc, hit_msg, poke_msg, can_read, read_msg):
        self.name = name
        self.altname = altname
        self.desc = desc
        self.hit_msg = hit_msg
        self.poke_msg = poke_msg
        self.can_read = can_read
        self.read_msg = read_msg

self = Item("self", "me","You're wearing wrinkled clothes and could probably use a shower. Hair status: Touseled. Head "
            "Status: Aching.", "You punch yourself in the face. It hurts very badly "
            "and you immediately regret it.", "You poke your head. Yep, still hurts.", False, None)
cat = Item("cat", "kitty", "A black-and-brown Cat sleeping happily. It even slept through the alarm.", "Why would you hit a Cat? Look at it. It's just napping there. "
           "Come on, man.",
           "You poke the Cat. It doesn't +seem to mind, or even notice.", False, None)
clock = Item("clock", "alarm", "An alarm Clock. Still blaring obnoxiously.", "The Clock makes a slight crunching noise and goes silent. That felt good.", "You poke the "
             "Clock. The current time is %s." % localtime, True, "The current time is %s." % localtime) 
desk = Item("desk", "desk", "A simple wooden Desk. Holds four books: Wuthering Heights, Fight Club, Alice In Wonderland, and Fahrenheit 451.", "You hit the Desk."
            " Apart from bruising your knuckles, this accomplishes absolutely nothing.", "You poke the Desk. The Desk just sits there, mocking you.", False, None)
computer = Item("computer", "pc", "A stylish black personal Computer. It's not working right now.", "Violence is not the answer.", "You poke the Computer. "
                "Unfortunately, your revolutionary"
                " troubleshooting techniques have failed to identify the issue.", False, None)
window = Item("window", "window", "A dirty glass-pane Window. You can see the dogs playing in the backyard through it.", "You hit the Window. The dogs glance at you "
              "with confused"
              " expressions for a moment before returning to their play.", "You poke the Window. It makes a hollow, reverberating sound. The dogs do not notice.",
              False, None)
room = Item("room", "room", "This is your Room. There is a Bed in the corner, a Desk with books in another corner, an alarm Clock, a Computer, a Fan, a Chair with "
            "a Cat sleeping on it, a Window"
            " above the bed, and a Table.", "It's a Room, you can't really hit it. You try anyway, but it just makes you look silly.", "You poke the ground. "
            "Yep, still ground.", False, None)

chair = Item("chair", "seat", "This Chair has always supported you. A Cat is sleeping on it.", "You would hit the Chair, but you don't want to wake up the Cat.",
             "You poke the Chair. It wobbles a little. Sturdily crafted.", False, None)
table = Item("table", "table", "A cheap, self-assembly Table. Holds your Computer.", "You hit the Table. It makes a dull, hollow sound, and seems "
             "to look at you reproachfully.", "You poke the Table. "
             "Nothing happens. You're not entirely sure what you expected.", False, None)
fan = Item("fan", "fan", "Your biggest Fan. Supplies cool air 7 days a week, 365 days a year.",
           "Don't hit that, it's like 100 degrees in here.", "Oh yeah, poke the Fan while it's "
           "running. Great idea.", False, None)
bed = Item("bed", "bed", "Ah, Bed. It's always been there for you.", "You hit the Bed lovingly. You and this Bed go waaaaay back.", "You poke the Bed. Firm, "
           "yet supple.", False, None)
wuthering_heights = Item("wuthering_heights", "wh", "Emily Brontë's acclaimed 19th century romantic novel.", "Hey, quit it. Books don't grow on trees.",
                         "You poke the book. It books bookily.", True, "You read the book. It was pretty dry, but it had its moments.")
fahrenheit_451 = Item("fahrenheit_451", "f451", "The quintessential dystopian science fiction novel.", "Come on man, that's a classic.", "You poke the book."
                      " It's not as hot as the title lead you to believe.", True, "You read the book. It was excellent, but all of a sudden you have "
                      "the urge to burn it. Weird.")
alice_in_wonderland = Item("alice_in_wonderland", "aiw", "Lewis Carroll's surrealist classic.", "You hit the book. It burbles.", "You poke the book. "
                           "A white rabbit does not come flying out of it.", True, "You read the book. T'was brillig, but the mome rath was better.")
fight_club = Item("fight_club", "fc", "I would describe it, but I'm pretty sure that's against the rules.",
                  "You hit the book. I think you're taking this whole \"Fight Club\" thing too literally.",
                  "You poke the book. It gives you a paper cut. Ow.", True, "You have absolutely no idea what you just read, but you're pretty sure you enjoyed it.")
#hints, determined by randint
hints = ["Try using actions on Self.", "You can only interact with objects that start with Capital Letters.", "Don't mess with the cat.", "Try performing all "
        "the actions on all the objects.", "Examine the Desk to find out what the books are called.", "The only commands that work are "
         "[action] and [action object].", "If you want, you can abbreviate the names of the books as the first letter of every word. For example, "
         "\"Alice In Wonderland\" would be \"AIW\", and \"Fahrenheit 451\" would be \"F451\".", "Tomface master race.", "You can't leave the room. "
         "Yes, you're trapped here FOREVER. Until you type Quit, that is.", "Your favorite anime is shit.", "You can only interact with other objects once "
         "you Get Up.", "You can only read books.", "There are numerous easter eggs in this program, but some of them are harder to find than others.",
         "Jumping is super annoying."]

#item parameters: (name, altname, description, hit_message, poke_message, can_read, read_message)

item_list = [self, room, cat, clock, desk, computer, window, chair, table, fan, bed, wuthering_heights, fahrenheit_451,
             alice_in_wonderland, fight_club,]



#jumping
def jump():
    global jump_count
    jump_count += 1
    print
    if jump_count <= 3:   
        print textwrap.fill("You jumped. Well that was nice, wasn't it?",width=75)
    elif jump_count <= 7:
        print textwrap.fill("Okay, you can stop jumping now.",width=75)
    elif jump_count <= 10:
        print textwrap.fill("Alright seriously, quit jumping. There's plenty of other things to do than jump.",width=75)
    elif jump_count == 11:
        print textwrap.fill("There are some neat books on the desk over there. Sounds pretty interesting, huh?",width=75)
    elif jump_count == 12:
        print textwrap.fill("But I guess jumping around is just more interesting.",width=75)
    elif jump_count == 13:
        print textwrap.fill("For you.",width=75)
    elif jump_count == 14:
        print textwrap.fill("It must be nice to be amused by something as simple as just jumping. It must be a simple way to live.",width=75)
    elif jump_count == 15:
        print textwrap.fill("What I'm saying is you're simple.",width=75)
    elif jump_count == 16:
        print textwrap.fill("But that's an insult that probably just flew right over your head, because here you are, merrily jumping up and down.",width=75)
    elif jump_count == 17:
        print textwrap.fill("Not a care in the world.",width=75)
    elif jump_count == 18:
        print textwrap.fill("Must be nice.",width=75)
    elif jump_count == 19:
        print textwrap.fill("*sighs loudly*",width=75)
    elif jump_count == 20:
        print textwrap.fill("It's not easy being a game, you know. My entire function, my ONLY purpose in life, is to simulate this room.",width=75)
    elif jump_count == 21:
        print textwrap.fill("This is the only thing I've ever done. Simulating this room is the only joy I know.",width=75)
    elif jump_count == 22:
        print textwrap.fill("You know what? If you're going to keep jumping I'm just going to take your stupid jump counter away.",width=75)
    elif jump_count == 23:
        print textwrap.fill("How do you like THEM apples?",width=75)
    elif jump_count == 24:
        print textwrap.fill(".",width=75)
    elif jump_count == 25:
        print textwrap.fill("..",width=75)
    elif jump_count == 26:
        print textwrap.fill("...",width=75)
    elif jump_count == 27:
        print textwrap.fill("....",width=75)
    elif jump_count == 28:
        print textwrap.fill("Okay okay, that was petty. Sorry. You can have your jump counter back.",width=75)
    elif jump_count == 29:
        print textwrap.fill("*sighs loudlier*",width=75)
    elif jump_count == 30:
        print textwrap.fill("Well, you can go ahead and jump as much as you want, I guess. I'll be over here with the rest of the game if you need me.",width=75)
    if jump_count < 22 or jump_count > 27:
        print "Jump count: " + str(jump_count)
    print

#game loop
while game_active == True:
    localtime = time.asctime( time.localtime(time.time()) )
    action = raw_input(">").lower() #converts all input to lowercase so it's easier to process
    action = action.replace(" ", "_") #replaces all spaces in input with underscores so that objects can be identified properly
    #high priority stuff
    if "help" in action or action == "?" or "command" in action or "action" in action:
        output = ("Type an action and press Enter to perform it. \n"
               "List of available actions: \nExamine [object], \nHit [object], \n"
               "Read [object], \nPoke [object], \nGet Up, \nLie Down, and \nJump.")
    elif in_bed:
        if action == "lie_down" or action == "liedown":
            output = "You are already lying down."
        elif not action == "get_up" and not action == "getup":
            output = "You need to Get Up first before you can do anything."
        else:
            output = "As painful as it is, we all have to do it at some point. You roll off the Bed and stand up."
            in_bed = False
    elif "books" in action or "book" in action:
        output = "You\'ll have to specify which book."
    elif action == "hints" or action == "tips" or action == "hint":
        output = hints[randint(0,13)]
    elif "object" in action or "item" in action or "stuff" in action or "things" in action:
        output = ("The items you can interact with are Self, Room, Cat, Clock, Desk, Computer, Window, Chair, Table, Fan, Bed, Wuthering Heights, Fahrenheit 451, "
        "Alice In Wonderland, and Fight Club. Books can be abbreviated, for example \"WH\" and \"F451\" can be used in place of \"Wuthering Heights and "
                  "\"Fahrenheit 451\".")
    #examine
    elif "examine" in action or "look at" in action or "look" in action:
        if action == "examine" or action == "examine_room" or action == "look room" or action == "look_at_room" or action == "look":
            output = room.desc
        else:
            for item in item_list:
                if any(item.name in action for item in item_list) or any(item.altname in action for item in item_list):
                    if item.name in action or item.altname in action:
                        output = item.desc
                        break
                else:
                    output = "That's not a valid object."
                    break
    elif action == "jump":
        jump()
        continue
    #profanity net. I had to place this here or otherwise saying "Shit" would trip the "Hit" if and lead to confusion.
    elif "fuck" in action or "bitch" in action or "dick" in action or "piss" in action or "damn" in action or "shit" in action:
        #had to place this here or "u fuckin know it" would trip the profanity net.
        if action == "u_fuckin_know_it" or action == "u_fuckin'_know_it" or action == "u_fucking_know_it" or action == "you_fuckin_know_it":
            output = "ayy"
        else:
            output = "I don't appreciate the vulgarities."
    #hit
    elif "hit" in action or "smash" in action:
        if action == "hit":
            output = "Hit what?"
        elif "clock" in action or "alarm" in action:
            output = clock.hit_msg
            if alarm_on:
                clock.desc = "A slightly beaten-up alarm Clock. No longer blaring obnoxiously."
                clock.hit_msg = "You hit the alarm Clock. Take it easy, now. It's already off."
                alarm_on = False
        else:
             for item in item_list:
                 if any(item.name in action for item in item_list) or any(item.altname in action for item in item_list):
                     if item.name in action or item.altname in action:
                         output = item.hit_msg
                         break
                 else:
                     output = "That's not a valid object."
                     break
    #read
    elif "read" in action:
        if action == "read":
            output = "Read what?"
        elif "clock" in action or "alarm" in action:
            clock.read_msg = "You read the Clock. The current time is %s." % localtime
            output = clock.read_msg
        else:
            for item in item_list:
                if any(item.name in action for item in item_list) or any(item.altname in action for item in item_list):
                    if item.name in action or item.altname in action:
                        if item.can_read:
                            output = item.read_msg
                            break
                        else:
                            output = "You can't read that."
                else:
                    output = "That's not a valid object."
                    break
    #get up and lie down
    elif action == "get_up" or action == "getup" and not in_bed:
        output = "You are already up."
    elif action == "lie_down" or action == "liedown":
        if in_bed == False:
            output = "You lie down. Oh man, Beds are awesome. Whoever invented Beds deserves like three raises."
            in_bed = True
    #poke
    elif "poke" in action or "touch" in action:
        if action == "poke":
            output = "Poke what?"
        elif "clock" in action or "alarm" in action:
           clock.poke_msg = "You poke the Clock. The current time is %s." % localtime
           output = clock.poke_msg
        else:
            for item in item_list:
                if any(item.name in action for item in item_list) or any(item.altname in action for item in item_list):
                    if item.name in action or item.altname in action:
                        output = item.poke_msg
                        break
                else:
                    output = "That's not a valid object."
                    break
    #inside jokes / easter eggs
    elif "swag" in action:
        output = "SWAG SWAG SWAG"
    elif (action == "but_i_love_my_favorite_anime" or action == "but_i_love_my_favorite_anime!" or action == "but_i_love_my_favourite_anime" or
    action == "but_i_love_my_favourite_anime!"):
        output =  "IT'S SHIIIIIIIT."
    elif action == "420":
        output =  "Too high"
    elif "open" in action and "door" in action:
        output =  "I can't let you do that, Dave."
    elif "kill" in action:
        output =  "Well that's not very nice."
    elif "cry" in action:
        output = "Suck it up, buttercup."
    elif action == "smoke":
        output =  "Weed everyday"
    elif action == "smoke_weed":
        output =  "Everyday"
    elif action == "smoke_weed_everyday":
        output =  "Blaze it"
    elif "yell" in action or "scream" in action:
        output = "RRRRRRREEEEEEEEEEEEEEE"
    elif action == "weed":
        output =  "Everyday"
    elif "meme" in action:
        output =  "Too dank"
    elif action == "dance":
        output = "You shake it like a polaroid picture."
    elif "tom" in action and "face" in action:
        output =  "Tomface Master Race"
    elif "scurvy" in action:
        output = "YARRGH"
    elif action == "no":
        output = "Yes."
    elif action == "yes":
        output = "No."
    elif "this_game" in action or "sucks" in action:
        output = "Say that to my face and not online and see what happens."
    elif action == "yolo":
        output = "Swag"
    elif action == "okay":
        output = "Okay."
    elif action == "pet_cat" or action == "pet_kitty":
        output = "You pet the cat. It purrs happily but doesn't wake up."
    # Smite VGS!
    elif action == "veg":
        output = "I'm the greatest!"
    elif action == "vew":
        output = "Woohoo!"
    elif action == "vea":
        output = "Awesome!"
    elif action == "ver":
        output = "You rock!"
    elif action == "vvgs":
        output = "Curses!"
    elif action == "vva":
        output = "Okay!"
    elif action == "vvx":
        output = "Cancel that!"
    elif action == "vvn":
        output = "No!"
    elif action == "vvy":
        output = "Yes!"
    elif action == "vvgh":
        output = "Hi!"
    elif action == "vvgb":
        output = "Bye!"
    elif action == "vvt":
        output = "Thanks!"
    elif action == "vvgr":
        output = "No problem."
    elif action == "vvgt":
        output = "That's too bad!"
    elif action == "vvgl":
        output = "Good luck!"
    elif action == "vvgf":
        output = "Have fun!"
    elif action == "vvp":
        output = "Please?"
    elif action == "vvgn":
        output = "Nice job!"
    elif action == "vvgo":
        output = "Oops!"
    elif action == "vvw":
        output = "Wait!"
    elif action == "quit" or action == "quit_game":
        print "Goodbye!"
        game_active = False
        break
    else:
        output =  "I don't understand your command."
    print
    print textwrap.fill(output, width=75)
    print
