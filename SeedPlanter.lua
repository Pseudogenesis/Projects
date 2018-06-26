--[[ This is Seed Planter, a seed log generator for The Binding of Isaac: Afterbirth+
	 This is pretty much my 3rd real programming project ever, so any bug reports, pull requests and constructive feedback are always appreciated. 
	 Feel free to message my reddit account /u/Pseudogenesis at any time, or to submit an issue or pull request to Github: https://github.com/Pseudogenesis
	 I'm honestly not super motivated to return to this project, but if you have a major bug to report or a relatively simple feature to request, I might give it a shot. 
	 I'd still like constructive criticism though, even if I might not carry it out. 
	 Special thanks to Taiga, budj and Andre Segura for their indispensible help in figuring out how to put this monstrosity together. ]]--

--[[ As it stands, this doesn't support record items that have been rerolled or actives that have been replaced. Each item list is created anew whenever a boss is killed. 
	 I spent half a day trying to fix it, but due to the way the program is structured it was much more difficult for me than I thought. I might fix it eventually but it'd likely require a major refactoring that I'm not motivated to work on ]]--

-- STATIC VARIABLES
local seedMod = RegisterMod("Seed Planter 1.5", 1)

--[[ Notable items the run might've had. Based on the top 30 items on IsaacRanks.com (as of 5/27/18), game-designated special items, and any other items I thought were run-defining, powerful, notable or memorable
	 Some items, like Guppy's Collar, Rotten Baby and Gnawed Leaf, don't necessarily fit these criteria but are included for the sake of identifying possible transformations or interesting synergies (Guppy, fly synergy, etc) 
	 If you want to add items to this list yourself, it's fairly simple. The format is [item ID] = "Item Name", with each entry separated by a comma.
	 The Item ID can be found on PlatinumGod.co.uk or the Isaac wiki, that goes in brackets. I'm not entirely sure how one might add items that have been modded in, but it's probably possible. ]]-- 
local NotableItemsDict = {[12] = "Magic Mushroom", [245] = "20/20",[182] = "Sacred Heart",[313] = "Holy Mantle",[395] = "Tech X",[118] = "Brimstone",[153] = "Mutant Spider",[399] = "Maw of the Void", [11] = "1up!",
				[331] = "Godhead",[105] = "D6",[237] = "Death's Touch",[4] = "Cricket's Head",[169] = "Polyphemus",[80] = "The Pact",[108] = "The Wafer",[360] = "Incubus",[230] = "Abaddon",[261] = "Proptosis",
				[494] = "Jacob's Ladder",[114] = "Mom's Knife",[415] = "Crown of Light",[223] = "Pyromaniac",[307] = "Capricorn",[224] = "Cricket's Body",[345] = "Synthoil",[101] = "The Halo",[168] = "Epic Fetus",
				[51] = "Pentagram",[189] = "SMB Super Fan",[216] = "Ceremonial Robes",[7] = "Blood of the Martyr",[330] = "Soy Milk",[5] = "My Reflection",[223] = "Tiny Planet",[529] = "Pop!",[152] = "Tech 2",
				[6] = "Number One",[524] = "Tech Zero",[69] = "Chocolate Milk",[402] = "Chaos",[2] = "The Inner Eye",[149] = "Ipecac",[414] = "More Options",[215] = "Goat Head",[424] = "Sack Head", [499] = "Eucharist", 
				[229] = "Monstro's Lung",[52] = "Dr. Fetus",[268] = "Dark Bum",[3] = "Spoon Bender",[104] = "The Parasite",[329] = "Ludovico Technique",[335] = "The Soul", [284] = "D4", [225] = "Gimpy", 
				[81] = "Dead Cat", [98] = "The Relic", [83] = "The Nail", [121] = "Odd Mushroom (Thick)", [120] = "Odd Mushroom (Thin)", [132] = "Lump of Coal", [68] = "Technology", [224] = "Tech.5", [407] = "Purity",
				[64] = "Steam Sale", [134] = "Guppy's Tail", [145] = "Guppy's Head", [212] = "Guppy's Collar", [187] = "Guppy's Hairball", [133] = "Guppy's Paw", [144] = "Bum Friend", [385] = "Bumbo", 
				[109] = "Money = Power", [78] = "Book of Revelations", [292] = "Satanic Bible", [173] = "Mitre", [151] = "The Mulligan", [179] = "Fate", [184] = "Holy Grail", [20] = "Transcendence", [477] = "Void", 
				[82] = "Lord of the Pit", [159] = "Spirit of the Night", [185] = "Dead Dove", [248] = "Hive Mind", [314] = "Thunder Thighs", [417] = "Succubus", [528] = "Angelic Prism", [534] = "Schoolbag", 
				[170] = "Daddy Longlegs", [203] = "Humbleing Bundle", [210] = "Gnawed Leaf", [241] = "Contract from Below", [286] = "Blank Card", [217] = "Mom's Wig", [227] = "Piggy Bank", [549] = "Brittle Bones", 
				[258] = "Missing No.", [268] = "Rotten Baby", [247] = "BFFs", [249] = "There's Options", [305] = "Scorpio", [316] = "Cursed Eye", [347] = "Diplopia", [356] = "Car Battery", [545] = "Book of the Dead", 
				[359] = "8 Inch Nails", [369] = "Continuum", [353] = "Bomber Boy", [106] = "Mr. Mega", [190] = "Pyro", [17] = "Skeleton Key", [191] = "3 Dollar Bill", [18] = "A Dollar", [544] = "Pointy Rib", 
				[501] = "Greed's Gullet", [358] = "The Wiz", [373] = "Dead Eye", [400] = "Spear of Destiny", [412] = "Cambion Conception", [413] = "Immaculate Conception", [394] = "Marked", [546] = "Dad's Ring", 
				[388] = "Key Bum", [393] = "Serpent's Kiss", [398] = "God's Flesh", [397] = "Tractor Beam", [424] = "Sack Head", [429] = "Head of the Keeper", [425] = "Analog Stick", [441] = "Mega Blast", 
				[443] = "Apple!", [462] = "Eye of Belial", [489] = "D Infinity", [485] = "Crooked Penny", [495] = "Ghost Pepper", [464] = "Glyph of Balance", [498] = "Duality", [482] = "Clicker", [9] = "Skatole", 
				[496] = "Euthanasia", [506] = "Backstabber", [522] = "Telekinesis", [523] = "Moving Box", [526] = "7 Seals", [530] = "Death's List", [532] = "Lachryphagy", [531] = "Haemolacria", [533] = "Trisagion"}
				

local json = require("json") --[[AB+ includes JSON4Lua, a JSON encoding utility. This mod uses it to store and retrieve info from the save file as tables. 
								 Before I realized AB+ supported JSON, I tried to work with just string manipulations. It was a nightmare, do not recommend ]]--

local difficultyTable = {[0] = "Normal", [1] = "Hard", [2] = "Greed", [3] = "Greedier"}


-- DYNAMIC VARIABLES

local trackingItems = 1 -- Sort of a legacy variable, probably dumb but I'm keeping it in to prevent loops from screwing things up in some unforeseen way
local seedData = {}
local currentRunDataExists = false
local firstTimeUser
local gameStartCheckDone = false
local currentItems = ""


-- FUNCTIONS

function seedMod:GameStartCheck(fromSaveGame)
	gameStartCheckDone = true
	if fromSaveGame and (Game():GetVictoryLap() == 0) then -- If the game is being started from a save file
		currentRunDataExists = true -- Tells the mod to edit the current continued run's data instead of creating a whole new seed entry
		trackingItems = 1
		seedMod:UpdateItemsList()
	elseif (not fromSaveGame) and (Game():GetVictoryLap() == 0) then -- If the run is brand new
		currentRunDataExists = false 
		trackingItems = 1
		seedMod:UpdateItemsList() 
	else
		trackingItems = 0 -- This condition should only occur during Victory Laps. Victory lap runs have their own seeds, but won't be recorded (because the seeds don't really matter if you've already gone through the game once)
	end
end

function seedMod:CustomEncode(tbl) -- Bundles json.encode() with our own pretty printing functions
	local encodedSeed = json.encode(tbl)
	encodedSeed = seedMod:make_pretty(encodedSeed) -- Pretty printer ensures the seed data is easily readable by ordinary users
	encodedSeed = seedMod:ExtraPretty(encodedSeed) -- Even more pretty	
	return encodedSeed
end

function seedMod:CustomDecode(str) -- Same as above but for decoding
	local decodedSeed = seedMod:ReverseExtraPretty(str)
	decodedSeed = json.decode(decodedSeed)
	return decodedSeed
end



function seedMod:IsolateSeeds(data) -- Takes the log data, extracts the most recent seed info, and separates it all into distinct parts. masterTable contains everything, lastSeedTable is just lastSeed after JSON4Lua is through with it. 
	local masterTable = {}
	local lastSeedTable = {}
	local lastSeed = ""
	table.insert(lastSeedTable, string.match(data, "{.*}"))
	lastSeed = table.concat(lastSeedTable)
	Isaac.ConsoleOutput(lastSeed)
	lastSeedTable = seedMod:CustomDecode(lastSeed)
	table.insert(masterTable, lastSeed)
	table.insert(masterTable, string.match(data, "}(.*)"))
	return lastSeed, lastSeedTable, masterTable
end

function seedMod:SaveInfo() -- The main logical structure of the program. If there was ever something I was going to refactor, it'd be this. Although it's *much* cleaner now that I moved several major code blocks into their own functions. 
	if Game():GetVictoryLap() == 0 then
		local lastSeed = ""
		local lastSeedTable, masterTable = {}
		
		trackingItems = 1
		seedData = ""
		local seedDataTableBuffer = {}
		
		local player = Isaac.GetPlayer(0)
		local seed = Game():GetSeeds():GetStartSeedString() 
		local name = player:GetName()
		local mode = difficultyTable[Game().Difficulty]
		-- local datetime = os.date("%x %X") -- Disabled due to the os library being inaccessible through the API under normal circumstances. No way around this, unfortunately. I plan to replace Date with a measure of run length. 
		local datetime = "Disabled - impossible to access with API"
		local transforms = seedMod:RecordTransformations()
		local isChallenge = Game().Challenge -- All challenges are Normal difficulty but do not support starting from seed. I'm supporting challenges anyway, just in case somebody really likes the run the seed generated. 
		if isChallenge > 0 then
			mode = "Challenge (Normal)"
		end
		
		if currentItems == "" then
			currentItems = "No notable items"
		end
		
		local currentSeedInfo = {Date = datetime, Items = currentItems, Seed = seed, Name = name, Mode = mode, Transformations = transforms}
		-- datetime = string.gsub(datetime, "/", "-") -- "/"s gets turned into "\/" after being parsed by JSON4Lua, which looks really weird. "-"s circumvent this
		seedData = Isaac.LoadModData(seedMod)
		
		if string.len(seedData) == 0 then -- If the save file is completely empty, i.e. somebody just installed the mod
			firstTimeUser = true
			currentSeedInfo = seedMod:CustomEncode(currentSeedInfo)
			seedData = currentSeedInfo
			Isaac.SaveModData(seedMod, seedData)
			currentRunDataExists = true
		else
			lastSeed, lastSeedTable, masterTable = seedMod:IsolateSeeds(seedData)
		end
		if (not currentRunDataExists) and (not firstTimeUser) then -- If it's a new run, append a new table with the current run's data to the master table
			table.insert(masterTable, 1, currentSeedInfo)
			masterTable[1] = seedMod:CustomEncode(masterTable[1])
			currentRunDataExists = true
		elseif currentRunDataExists and (not firstTimeUser) then -- If it's a continued run, then just edit the existing items list.
			masterTable[1] = lastSeedTable
			if string.len(masterTable[1].Items) < string.len(currentItems) then -- Comparing lengths prevents things like complete item rerolls from deleting the existing item data. Old will be overwritten if the new notable items list exceeds it in length
				masterTable[1] = currentSeedInfo
			elseif masterTable[1].Items == "No notable items" and currentItems ~= "No notable items" then -- Ensures that short currentItems lists, like "20-20, Tech 2" would overwrite the "No notable items" string. 
				masterTable[1] = currentSeedInfo
			else
				masterTable[1].Transformations = transforms
				-- Run length will also be set here, when I implement it
			end
			masterTable[1] = seedMod:CustomEncode(masterTable[1])
		end
		
		if (not firstTimeUser) then -- We only save the data if they're not a first time user. If they are (ie have just installed the mod) then their data has already been saved at this point.
			table.insert(masterTable, 1, "SEEDS ARE IN CHRONOLOGICAL ORDER. The top seed is the newest, the bottom seed is the oldest. Enjoy!\n") -- This message stays at the top every time because of the way IsolateSeeds() handles reading the log. 
			seedData = table.concat(masterTable)
			Isaac.SaveModData(seedMod, seedData)
		else
			firstTimeUser = false
		end
		
	else
		trackingItems = 0 -- VICTORY LAPS MUST DIE
	end
end


function seedMod:UpdateItemsList(fromBossKill) -- Cycles through our list of notable items and adds them to a currentItems list for later. Calls SaveInfo() at the end. 
	if gameStartCheckDone == true then
		local player = Isaac.GetPlayer(0)
		local numberOfItems = 0
		itemTableBuffer = {}
		currentItems = ""
		local seedData = Isaac.LoadModData(seedMod)
		for ItemID,ItemName in pairs(NotableItemsDict) do
			if (player:HasCollectible(ItemID)) then
				numberOfItems = numberOfItems + 1
				if numberOfItems > 1 then -- Only add a comma if there's more than 1 item in the list
					table.insert(itemTableBuffer, ", ") -- Lua has built-in string concatenation with "..", but it is extremely inefficient. 
					table.insert(itemTableBuffer, ItemName) -- Using tables as a buffer and concatenating those with table.concat() solves this issue with very little extra complexity. 
				else
					table.insert(itemTableBuffer, ItemName)
				end
			end
		end
		currentItems = table.concat(itemTableBuffer)
		currentItems = string.gsub(currentItems, "/", "-") -- Same deal as with date, the item "20/20" is renamed to "20-20" for formatting reasons
		if not fromBossKill then
			seedMod:SaveInfo(currentItems)
		end
	end
end

function seedMod:RecordTransformations() -- Checks for transformations the player has, and returns a list of their names
	local transformationCount = 0
	local player = Isaac.GetPlayer(0)
	local currentTransformations = {}
	local possibleTransformations = {[0] = "Guppy", [1] = "Lord of the Flies", [2] = "Fun Guy", [3] = "Seraphim", [4] = "Bob", [5] = "Spun", [6] = "Yes Mother", [7] = "Conjoined", [8] = "Leviathan", [9] = "Oh Crap", [10] = "Bookworm", [11] = "Adult", [12] = "Spider Baby"}
	for transformationID, transformationName in pairs(possibleTransformations) do 
		if player:HasPlayerForm(transformationID) then
			transformationCount = transformationCount + 1
			if transformationCount > 1 then
				table.insert(currentTransformations, ", ")
				table.insert(currentTransformations, transformationName)
			else
				table.insert(currentTransformations, transformationName)
			end
		end
	end
	if transformationCount == 0 then
		currentTransformations = "None" 
		return currentTransformations
	else
		currentTransformations = table.concat(currentTransformations)
		return currentTransformations
	end
end
			
function seedMod:CheckDeadNPC(DeadNPC) -- CheckDeadNPC calls UpdateItemsList() whenever a boss is killed
	if DeadNPC:IsBoss() then
		if ((Game():GetVictoryLap() == 0) and (trackingItems == 1)) then
			if DeadNPC.Type == EntityType.ENTITY_THE_LAMB and Game():GetLevel():GetName() == "Dark Room" then -- CheckDeadNPC only saves info after killing The Lamb, in case the player does a Victory Lap, which doesn't trigger the PRE_GAME_EXIT callback. 
				seedMod:UpdateItemsList(false)
			else
				seedMod:UpdateItemsList(true) -- true means UpdateItemsList() will not call SaveInfo() at the end, so that killing multiple bosses at once doesn't cause performance issues (this was easily visible when killing segmented bosses like Pin)
			end
		else
			trackingItems = 0
		end
	end
end


function seedMod:make_pretty(uglystr) -- Pretty printer written by the legendary Andre Segura - https://github.com/andrensegura/ . I have no clue how this voodoo magic works, so comments will be limited to the things I changed. 
    -- Takes an ugly string, returns a prettier one.
    -- Change spaces to your desired indentation width.
	local tableBuffer = {}
    local spaces = 2
    local prettystr = ""
    local count = 0
	local formattingCommaIncoming -- This flag is tripped if the next character might be a formatting comma. Without this, the commas separating the player's collected items would be screwed with.
    for c in uglystr:gmatch"." do
        if c == '[' or c == '{' then
            table.insert(tableBuffer, c)
			table.insert(tableBuffer, '\r\n') -- The \r has to be included, or Notepad will not recognize the linebreak
            count = count + 1
            for i=1,count*spaces do
                table.insert(tableBuffer, " ")
            end
			formattingCommaIncoming = true -- Formatting commas only occur after curly braces (}) and quotation marks (")
        elseif c == ']' or c == '}' then
            table.insert(tableBuffer, '\r\n')
            count = count - 1
            for i=1,count*spaces do
                table.insert(tableBuffer, " ")
            end
            table.insert(tableBuffer, c)
			formattingCommaIncoming = true
        elseif c == ',' then
            if formattingCommaIncoming then
				table.insert(tableBuffer, c)
				table.insert(tableBuffer, '\r\n')
				for i=1,count*spaces do
					table.insert(tableBuffer, " ")
				end
			else
				table.insert(tableBuffer, c)
			end
			formattingCommaIncoming = false
		elseif c == '"' then
			table.insert(tableBuffer, c)
			formattingCommaIncoming = true
        else
            table.insert(tableBuffer, c)
			formattingCommaIncoming = false
        end
    end
	prettystr = table.concat(tableBuffer) -- If we used .. notation instead of this method for concatenating, this mod would be grossly inefficient. https://www.lua.org/pil/11.6.html
    return prettystr
end

function seedMod:ExtraPretty(outboundSaveData) -- Because you can never have too much pretty. Reformats the output so it looks like Seed: "2G4M 8OA3" instead of "Seed": "2G4M 8OA3". Reversed with the next function.
	outboundSaveData = string.gsub(outboundSaveData, '"Mode":', 'Mode: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Name":', 'Name: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Items":', 'Items: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Seed":', 'Seed: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Date":', 'Date: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Transformations":', 'Transformations: ')
	return outboundSaveData
end

function seedMod:ReverseExtraPretty(inboundSaveData) -- Reverses the work done by ExtraPretty() so that JSON4Lua can parse the data properly again. Because apparently you can have too much pretty.
	inboundSaveData = string.gsub(inboundSaveData, 'Mode: ', '"Mode":')
	inboundSaveData = string.gsub(inboundSaveData, 'Name: ', '"Name":')
	inboundSaveData = string.gsub(inboundSaveData, 'Items: ', '"Items":')
	inboundSaveData = string.gsub(inboundSaveData, 'Seed: ', '"Seed":')
	inboundSaveData = string.gsub(inboundSaveData, 'Date: ', '"Date":')
	inboundSaveData = string.gsub(inboundSaveData, 'Transformations: ', '"Transformations":')
	return inboundSaveData
end

function seedMod:OnMenuExit() -- So that gameStartCheckDone doesn't remain tripped if we quit and then continue a run. 
	seedMod:UpdateItemsList() -- Updating one last time on menu exit
	gameStartCheckDone = false
end

-- CALLBACKS



seedMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, seedMod.GameStartCheck) -- Triggers GameStartCheck upon entering/re-entering a run
seedMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, seedMod.CheckDeadNPC) -- Triggers CheckDeadNPC whenever an NPC is killed
seedMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, seedMod.OnMenuExit) -- Triggers OnMenuExit when, you guessed it, the player exits to the main menu

-- DEBUG STUFF

-- function seedMod:TestTable(location)  -- Deprecated for now
	-- Isaac.ConsoleOutput(location .. ": ")
	-- for k,v in ipairs(masterTable) do
	-- Isaac.ConsoleOutput(count)
	-- count = count + 1
	-- Isaac.ConsoleOutput(tostring(v))
	-- Isaac.ConsoleOutput("\n")
	-- end
-- end

-- Isaac.ConsoleOutput("After master table made: ") - Block for testing contents of the masterTable. 
-- local count = 1
-- for k,v in ipairs(masterTable) do
	-- Isaac.ConsoleOutput(count)
	-- count = count + 1
	-- Isaac.ConsoleOutput(tostring(v))
	-- Isaac.ConsoleOutput("\n")
-- end

-- function seedMod:Trim(str) -- Removes whitespace. Debug, deprecated for now
  -- return (str:gsub("^%s*(.-)%s*$", "%1"))
-- end
