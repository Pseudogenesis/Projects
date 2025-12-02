--[[ Seed Planter 2.0 - A seed log generator for The Binding of Isaac: Repentance+

	 FEATURES:
	 - Automatic seed logging with detailed run information
	 - Tainted character support
	 - Dual item tracking: Notable items + Quality-based filtering
	 - Transformation tracking (all 15 transformations including Stompy & Super Bum)
	 - Floor progression tracking
	 - In-game UI for viewing seed history (Press TAB to toggle)
	 - Challenge mode support
	 - Victory lap handling

	 USAGE:
	 - The mod works automatically - just play!
	 - Press TAB in-game to view your seed history
	 - Or check the save file in your Isaac mods folder
	 - Console command: lua seedMod:ToggleUI()

	 CREDITS:
	 - Original mod by /u/Pseudogenesis - https://github.com/Pseudogenesis
	 - Pretty printer by Andre Segura
	 - Testing help from Taiga and budj
	 - Repentance+ update by Claude AI

	 NOTE: Item rerolls and active item replacements may not be tracked perfectly.
	 The mod creates a new item snapshot after each boss kill. ]]--

-- STATIC VARIABLES
local seedMod = RegisterMod("Seed Planter 2.0", 1)

-- All Repentance transformations
local possibleTransformations = {
	[0] = "Guppy",
	[1] = "Lord of the Flies",
	[2] = "Fun Guy",
	[3] = "Seraphim",
	[4] = "Bob",
	[5] = "Spun",
	[6] = "Yes Mother",
	[7] = "Conjoined",
	[8] = "Leviathan",
	[9] = "Oh Crap",
	[10] = "Bookworm",
	[11] = "Adult",
	[12] = "Spider Baby",
	[13] = "Stompy",
	[14] = "Super Bum"
}

--[[ Notable items - includes powerful, run-defining, and memorable items from all DLCs
	 Based on IsaacRanks.com rankings, special items, transformation items, and community favorites
	 Updated for Repentance with new items
	 Format: [item ID] = "Item Name" - IDs can be found on PlatinumGod.co.uk or the Isaac wiki ]]--
local NotableItemsDict = {
	-- Afterbirth+ items (original list)
	[12] = "Magic Mushroom", [245] = "20/20", [182] = "Sacred Heart", [313] = "Holy Mantle", [395] = "Tech X", [118] = "Brimstone", [153] = "Mutant Spider", [399] = "Maw of the Void", [11] = "1up!",
	[331] = "Godhead", [105] = "D6", [237] = "Death's Touch", [4] = "Cricket's Head", [169] = "Polyphemus", [80] = "The Pact", [108] = "The Wafer", [360] = "Incubus", [230] = "Abaddon", [261] = "Proptosis",
	[494] = "Jacob's Ladder", [114] = "Mom's Knife", [415] = "Crown of Light", [223] = "Pyromaniac", [307] = "Capricorn", [224] = "Cricket's Body", [345] = "Synthoil", [101] = "The Halo", [168] = "Epic Fetus",
	[51] = "Pentagram", [189] = "SMB Super Fan", [216] = "Ceremonial Robes", [7] = "Blood of the Martyr", [330] = "Soy Milk", [5] = "My Reflection", [529] = "Pop!", [152] = "Tech 2",
	[6] = "Number One", [524] = "Tech Zero", [69] = "Chocolate Milk", [402] = "Chaos", [2] = "The Inner Eye", [149] = "Ipecac", [414] = "More Options", [215] = "Goat Head", [424] = "Sack Head", [499] = "Eucharist",
	[229] = "Monstro's Lung", [52] = "Dr. Fetus", [268] = "Dark Bum", [3] = "Spoon Bender", [104] = "The Parasite", [329] = "Ludovico Technique", [335] = "The Soul", [284] = "D4", [225] = "Gimpy",
	[81] = "Dead Cat", [98] = "The Relic", [83] = "The Nail", [121] = "Odd Mushroom (Thick)", [120] = "Odd Mushroom (Thin)", [132] = "Lump of Coal", [68] = "Technology", [407] = "Purity",
	[64] = "Steam Sale", [134] = "Guppy's Tail", [145] = "Guppy's Head", [212] = "Guppy's Collar", [187] = "Guppy's Hairball", [133] = "Guppy's Paw", [144] = "Bum Friend", [385] = "Bumbo",
	[109] = "Money = Power", [78] = "Book of Revelations", [292] = "Satanic Bible", [173] = "Mitre", [151] = "The Mulligan", [179] = "Fate", [184] = "Holy Grail", [20] = "Transcendence", [477] = "Void",
	[82] = "Lord of the Pit", [159] = "Spirit of the Night", [185] = "Dead Dove", [248] = "Hive Mind", [314] = "Thunder Thighs", [417] = "Succubus", [528] = "Angelic Prism", [534] = "Schoolbag",
	[170] = "Daddy Longlegs", [203] = "Humbling Bundle", [210] = "Gnawed Leaf", [241] = "Contract from Below", [286] = "Blank Card", [217] = "Mom's Wig", [227] = "Piggy Bank", [549] = "Brittle Bones",
	[258] = "Missing No.", [247] = "BFFs", [249] = "There's Options", [305] = "Scorpio", [316] = "Cursed Eye", [347] = "Diplopia", [356] = "Car Battery", [545] = "Book of the Dead",
	[359] = "8 Inch Nails", [369] = "Continuum", [353] = "Bomber Boy", [106] = "Mr. Mega", [190] = "Pyro", [17] = "Skeleton Key", [191] = "3 Dollar Bill", [18] = "A Dollar", [544] = "Pointy Rib",
	[501] = "Greed's Gullet", [358] = "The Wiz", [373] = "Dead Eye", [400] = "Spear of Destiny", [412] = "Cambion Conception", [413] = "Immaculate Conception", [394] = "Marked", [546] = "Dad's Ring",
	[388] = "Key Bum", [393] = "Serpent's Kiss", [398] = "God's Flesh", [397] = "Tractor Beam", [429] = "Head of the Keeper", [425] = "Analog Stick", [441] = "Mega Blast",
	[443] = "Apple!", [462] = "Eye of Belial", [489] = "D Infinity", [485] = "Crooked Penny", [495] = "Ghost Pepper", [464] = "Glyph of Balance", [498] = "Duality", [482] = "Clicker", [9] = "Skatole",
	[496] = "Euthanasia", [506] = "Backstabber", [522] = "Telekinesis", [523] = "Moving Box", [526] = "7 Seals", [530] = "Death's List", [532] = "Lachryphagy", [531] = "Haemolacria", [533] = "Trisagion",

	-- Repentance items (new additions)
	[562] = "Rock Bottom", [579] = "Spirit Sword", [580] = "Red Key", [588] = "Sol", [589] = "Luna", [591] = "Venus", [592] = "Terra", [593] = "Mars", [594] = "Jupiter", [595] = "Saturn",
	[596] = "Uranus", [597] = "Pluto", [601] = "120 Volt", [609] = "Eternal D6", [611] = "Larynx", [619] = "Lost Soul", [622] = "Genesis", [623] = "Sharp Key", [624] = "Booster Pack",
	[625] = "Mega Mush", [626] = "Sacred Orb", [627] = "Recall", [628] = "Death Certificate", [631] = "Meat Cleaver", [632] = "Evil Charm", [635] = "Akeldama", [636] = "R Key",
	[637] = "Knockout Drops", [638] = "Eraser", [639] = "Yuck Heart", [640] = "Urn of Souls", [641] = "Alabaster Box", [642] = "Magic Skin", [643] = "Revelation", [644] = "Consolation Prize",
	[645] = "Tinytoma", [649] = "Fruity Plum", [652] = "Portals", [655] = "Spin to Win", [656] = "Damocles", [657] = "Vasculitis", [665] = "Ocular Rift", [667] = "Strawman",
	[668] = "Dad's Note", [669] = "Sausage", [670] = "Options?", [671] = "Candy Heart", [675] = "Binge Eater", [676] = "Guppy's Eye", [678] = "C Section", [679] = "Lemegeton",
	[680] = "Sumptorium", [681] = "Recall", [685] = "Jar of Wisps", [687] = "Friend Finder", [689] = "Glitched Crown", [691] = "Tooth and Nail", [692] = "Immaculate Heart",
	[694] = "Heartbreak", [696] = "Salvation", [697] = "Vanishing Twin", [698] = "Twisted Pair", [699] = "Azazel's Rage", [700] = "Echo Chamber", [701] = "Isaac's Tomb",
	[703] = "Vengeful Spirit", [704] = "Esau Jr", [705] = "Berserk!", [706] = "Dark Arts", [707] = "Abyss", [708] = "Suplex!", [709] = "Bag of Crafting", [710] = "Flip",
	[711] = "Lemegeton", [712] = "Stitches", [713] = "R Key", [714] = "Spindown Dice", [715] = "Hypercoagulation", [719] = "The Swarm", [720] = "Heartbreak", [721] = "Tooth and Nail",
	[722] = "Hypercoagulation", [723] = "Ghost Bombs", [728] = "Gello"
}
				

local json = require("json") --[[AB+ includes JSON4Lua, a JSON encoding utility. This mod uses it to store and retrieve info from the save file as tables. 
								 Before I realized AB+ supported JSON, I tried to work with just string manipulations. It was a nightmare, do not recommend ]]--

local difficultyTable = {[0] = "Normal", [1] = "Hard", [2] = "Greed", [3] = "Greedier"}

-- Item Quality levels (0-4, where 4 is the highest quality like Sacred Heart, Godhead, etc.)
local QUALITY_THRESHOLD = 2 -- Only log items of this quality or higher (2 = good items and above)
local LOG_ALL_QUALITIES = false -- Set to true to log all items regardless of quality

-- DYNAMIC VARIABLES

local trackingItems = 1
local seedData = {}
local currentRunDataExists = false
local firstTimeUser
local gameStartCheckDone = false
local currentItems = ""
local currentQualityItems = "" -- Items filtered by quality
local showingUI = false -- Whether the in-game UI is currently displayed



-- FUNCTIONS

-- Get proper character name including tainted variant detection
function seedMod:GetCharacterName(player)
	local playerType = player:GetPlayerType()
	local name = player:GetName()

	-- Tainted characters have PlayerType >= 21 and <= 38 in Repentance
	-- The game should return the proper name with "Tainted" prefix, but we verify it
	if playerType >= 21 and playerType <= 38 then
		-- If the name doesn't already include "Tainted", add it
		if not string.find(name, "Tainted") then
			name = "Tainted " .. name
		end
	end

	return name
end

-- Helper function to check if we should log an item based on quality
function seedMod:ShouldLogItem(itemID)
	if LOG_ALL_QUALITIES then
		return true
	end

	local itemConfig = Isaac.GetItemConfig():GetCollectible(itemID)
	if itemConfig then
		local quality = itemConfig.Quality
		return quality >= QUALITY_THRESHOLD
	end

	return false
end

-- Get floor name for run statistics
function seedMod:GetFloorName()
	local level = Game():GetLevel()
	local stage = level:GetStage()
	local stageType = level:GetStageType()
	local curses = level:GetCurses()

	local floorNames = {
		[1] = "Basement",
		[2] = "Caves",
		[3] = "Depths",
		[4] = "Womb",
		[5] = "???",
		[6] = "Sheol/Cathedral",
		[7] = "Dark Room/Chest",
		[8] = "The Void",
		[9] = "Downpour/Dross",
		[10] = "Mines/Ashpit",
		[11] = "Mausoleum/Gehenna",
		[12] = "Corpse",
		[13] = "Home"
	}

	local name = floorNames[stage] or "Unknown"

	-- Add XL suffix if applicable
	if level:GetName():find("XL") then
		name = name .. " XL"
	end

	return name
end

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

function seedMod:CustomDecode(str) -- Decodes pretty-printed JSON back to table
	local decodedSeed = seedMod:ReverseExtraPretty(str)
	-- Remove all whitespace formatting (newlines, carriage returns, extra spaces)
	decodedSeed = string.gsub(decodedSeed, "\r\n", "")
	decodedSeed = string.gsub(decodedSeed, "\n", "")
	decodedSeed = string.gsub(decodedSeed, "\r", "")
	-- Remove indentation spaces (but keep spaces within quoted strings)
	decodedSeed = string.gsub(decodedSeed, "%s+", " ")
	decodedSeed = string.gsub(decodedSeed, " :", ":")
	decodedSeed = string.gsub(decodedSeed, ": ", ":")
	decodedSeed = string.gsub(decodedSeed, " ,", ",")
	decodedSeed = string.gsub(decodedSeed, ", ", ",")
	decodedSeed = string.gsub(decodedSeed, "{ ", "{")
	decodedSeed = string.gsub(decodedSeed, " }", "}")
	decodedSeed = json.decode(decodedSeed)
	return decodedSeed
end



function seedMod:IsolateSeeds(data) -- Takes the log data, extracts the most recent seed info, and separates it into two parts: The last seed data, and the rest of the file.  
	local master = {}			-- This is to make it easier for us to 
	local lastSeed = ""
	lastSeed = string.match(data, "{.-}")
	lastTable = seedMod:CustomDecode(lastSeed)
	table.insert(master, lastSeed)
	table.insert(master, string.match(data, "}(.*)"))
	return master, lastTable
end

function seedMod:GetRunData()
	-- Returns a table containing current run data: Seed, character, items, mode/difficulty, transformations, and floor
	local playerOne = Isaac.GetPlayer(0)
	local dataTable = {
		Seed = Game():GetSeeds():GetStartSeedString(),
		Name = seedMod:GetCharacterName(playerOne), -- Now properly detects tainted characters
		Floor = seedMod:GetFloorName(), -- Track which floor the run reached
		Transformations = seedMod:RecordTransformations(),
		Items = currentItems,
		QualityItems = currentQualityItems, -- Quality-filtered items
		Mode = difficultyTable[Game().Difficulty]
	}

	-- Override mode for challenges
	if Game().Challenge > 0 then
		dataTable.Mode = "Challenge (Normal)"
	end

	return dataTable
end
	
	
function seedMod:SaveInfo() -- The main logical structure of the program. If there was ever something I was going to refactor, it'd be this. Although it's *much* cleaner now that I moved several major code blocks into their own functions. 
	if Game():GetVictoryLap() == 0 then
		local masterTable = {}
		local lastSeedTable = {}
		local runData = seedMod:GetRunData()
		seedData = ""
		trackingItems = 1
		-- datetime = string.gsub(datetime, "/", "-") -- "/"s gets turned into "\/" after being parsed by JSON4Lua, which looks really weird. "-"s circumvent this
		seedData = Isaac.LoadModData(seedMod)
		
		if string.len(seedData) == 0 then -- If the save file is completely empty, i.e. somebody just installed the mod
			firstTimeUser = true
			runData = seedMod:CustomEncode(runData)
			seedData = runData
			Isaac.SaveModData(seedMod, seedData)
			currentRunDataExists = true
		else
			masterTable, lastSeedTable = seedMod:IsolateSeeds(seedData)
		end
		if (not currentRunDataExists) and (not firstTimeUser) then -- If it's a new run, append a new table with the current run's data to the master table
			table.insert(masterTable, 1, runData)
			masterTable[1] = seedMod:CustomEncode(masterTable[1])
			currentRunDataExists = true
		elseif currentRunDataExists and (not firstTimeUser) then -- If it's a continued run, then just edit the existing items list.
			masterTable[1] = lastSeedTable
			if string.len(masterTable[1].Items) < string.len(currentItems) then -- Comparing lengths prevents things like complete item rerolls from deleting the existing item data. Old will be overwritten if the new notable items list exceeds it in length
				masterTable[1] = runData
			elseif masterTable[1].Items == "No notable items" and currentItems ~= "No notable items" then -- Ensures that short currentItems lists, like "20-20, Tech 2" would overwrite the "No notable items" string. 
				masterTable[1] = runData
			else
				masterTable[1].Transformations = runData.Transformations
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


function seedMod:UpdateItemsList(fromBossKill)
	-- Cycles through notable items and quality items, updating both lists
	if gameStartCheckDone == true then
		local player = Isaac.GetPlayer(0)
		local numberOfItems = 0
		local numberOfQualityItems = 0
		local itemTableBuffer = {}
		local qualityItemBuffer = {}
		currentItems = ""
		currentQualityItems = ""

		-- First, build the notable items list (manual curated list)
		for ItemID, ItemName in pairs(NotableItemsDict) do
			if player:HasCollectible(ItemID) then
				numberOfItems = numberOfItems + 1
				if numberOfItems > 1 then
					table.insert(itemTableBuffer, ", ")
					table.insert(itemTableBuffer, ItemName)
				else
					table.insert(itemTableBuffer, ItemName)
				end
			end
		end

		-- Second, build quality-based items list (all items meeting quality threshold)
		local itemConfig = Isaac.GetItemConfig()
		local maxItemID = 730 -- Approximate max collectible ID in Repentance+
		for itemID = 1, maxItemID do
			if player:HasCollectible(itemID) then
				local item = itemConfig:GetCollectible(itemID)
				if item and seedMod:ShouldLogItem(itemID) then
					numberOfQualityItems = numberOfQualityItems + 1
					local itemName = item.Name
					if numberOfQualityItems > 1 then
						table.insert(qualityItemBuffer, ", ")
						table.insert(qualityItemBuffer, itemName)
					else
						table.insert(qualityItemBuffer, itemName)
					end
				end
			end
		end

		-- Finalize notable items list
		currentItems = table.concat(itemTableBuffer)
		currentItems = string.gsub(currentItems, "/", "-") -- "20/20" becomes "20-20" for formatting
		if currentItems == "" then
			currentItems = "No notable items"
		end

		-- Finalize quality items list
		currentQualityItems = table.concat(qualityItemBuffer)
		currentQualityItems = string.gsub(currentQualityItems, "/", "-")
		if currentQualityItems == "" then
			currentQualityItems = "No quality items"
		end

		if not fromBossKill then
			seedMod:SaveInfo(currentItems)
		end
	end
end

function seedMod:RecordTransformations() -- Checks for transformations the player has, and returns a list of their names
	local transformationCount = 0
	local player = Isaac.GetPlayer(0)
	local currentTransformations = {}
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

function seedMod:ExtraPretty(outboundSaveData)
	-- Reformats JSON output for better readability
	outboundSaveData = string.gsub(outboundSaveData, '"Mode":', 'Mode: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Name":', 'Name: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Items":', 'Items: ')
	outboundSaveData = string.gsub(outboundSaveData, '"QualityItems":', 'Quality Items: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Seed":', 'Seed: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Floor":', 'Floor: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Transformations":', 'Transformations: ')
	return outboundSaveData
end

function seedMod:ReverseExtraPretty(inboundSaveData)
	-- Reverses ExtraPretty() formatting so JSON can be parsed again
	-- Handle both new and old format (old format had "Date" instead of "Floor")
	inboundSaveData = string.gsub(inboundSaveData, 'Mode: ', '"Mode":')
	inboundSaveData = string.gsub(inboundSaveData, 'Name: ', '"Name":')
	inboundSaveData = string.gsub(inboundSaveData, 'Items: ', '"Items":')
	inboundSaveData = string.gsub(inboundSaveData, 'Quality Items: ', '"QualityItems":')
	inboundSaveData = string.gsub(inboundSaveData, 'Seed: ', '"Seed":')
	inboundSaveData = string.gsub(inboundSaveData, 'Floor: ', '"Floor":')
	inboundSaveData = string.gsub(inboundSaveData, 'Date: ', '"Date":') -- Old format compatibility
	inboundSaveData = string.gsub(inboundSaveData, 'Transformations: ', '"Transformations":')
	return inboundSaveData
end

function seedMod:OnMenuExit()
	-- Reset state when exiting to menu
	seedMod:UpdateItemsList()
	gameStartCheckDone = false
	showingUI = false
end

-- IN-GAME UI FUNCTIONS

local uiScrollOffset = 0
local MAX_VISIBLE_SEEDS = 8

function seedMod:ToggleUI()
	-- Toggle the seed history UI on/off
	showingUI = not showingUI
	if showingUI then
		uiScrollOffset = 0
	end
end

function seedMod:ParseSeedHistory()
	-- Parse saved seed data and return a table of seed entries
	local savedData = Isaac.LoadModData(seedMod)
	if string.len(savedData) == 0 then
		return {}
	end

	local seeds = {}
	-- Split the data by seed entries (each starts with "{" and ends with "}")
	for seedEntry in string.gmatch(savedData, "{.-}") do
		local decodedSeed = seedMod:CustomDecode(seedEntry)
		table.insert(seeds, decodedSeed)
	end

	return seeds
end

function seedMod:RenderUI()
	-- Render the in-game seed history UI
	if not showingUI then
		return
	end

	local seeds = seedMod:ParseSeedHistory()
	if #seeds == 0 then
		-- Display "no seeds" message
		local font = Font()
		font:Load("font/upheaval.fnt")
		local screenWidth = Isaac.GetScreenWidth()
		local screenHeight = Isaac.GetScreenHeight()

		local title = "SEED PLANTER - No Seeds Recorded"
		local titleWidth = font:GetStringWidth(title)
		font:DrawString(title, screenWidth/2 - titleWidth/2, 50, KColor(1,1,1,1), 0, true)

		local hint = "Press TAB to close"
		local hintWidth = font:GetStringWidth(hint)
		font:DrawString(hint, screenWidth/2 - hintWidth/2, screenHeight - 30, KColor(0.7,0.7,0.7,1), 0, true)
		return
	end

	-- Render seed history
	local font = Font()
	font:Load("font/upheaval.fnt")
	local screenWidth = Isaac.GetScreenWidth()
	local screenHeight = Isaac.GetScreenHeight()
	local yPos = 40

	-- Title
	local title = "SEED PLANTER - Recent Seeds"
	local titleWidth = font:GetStringWidth(title)
	font:DrawString(title, screenWidth/2 - titleWidth/2, yPos, KColor(1,1,0.5,1), 0, true)
	yPos = yPos + 25

	-- Draw visible seeds
	local startIdx = uiScrollOffset + 1
	local endIdx = math.min(startIdx + MAX_VISIBLE_SEEDS - 1, #seeds)

	for i = startIdx, endIdx do
		local seed = seeds[i]
		local lineColor = KColor(1,1,1,1)

		-- Seed info
		local seedLine = string.format("%d. %s - %s (%s)", i, seed.Seed or "???", seed.Name or "Unknown", seed.Mode or "Unknown")
		font:DrawString(seedLine, 50, yPos, lineColor, 0, true)
		yPos = yPos + 15

		-- Floor reached
		if seed.Floor then
			local floorLine = "   Floor: " .. seed.Floor
			font:DrawString(floorLine, 50, yPos, KColor(0.8,0.8,1,1), 0, true)
			yPos = yPos + 12
		end

		-- Transformations
		if seed.Transformations and seed.Transformations ~= "None" then
			local transLine = "   Transformations: " .. seed.Transformations
			font:DrawString(transLine, 50, yPos, KColor(1,0.8,1,1), 0, true)
			yPos = yPos + 12
		end

		-- Items (truncate if too long)
		if seed.Items and seed.Items ~= "No notable items" then
			local itemsText = seed.Items
			if string.len(itemsText) > 80 then
				itemsText = string.sub(itemsText, 1, 77) .. "..."
			end
			local itemLine = "   Items: " .. itemsText
			font:DrawString(itemLine, 50, yPos, KColor(0.8,1,0.8,1), 0, true)
			yPos = yPos + 12
		end

		yPos = yPos + 8 -- Spacing between entries
	end

	-- Footer with controls
	local footer = "Press TAB to close | " .. string.format("Showing %d-%d of %d seeds", startIdx, endIdx, #seeds)
	local footerWidth = font:GetStringWidth(footer)
	font:DrawString(footer, screenWidth/2 - footerWidth/2, screenHeight - 30, KColor(0.7,0.7,0.7,1), 0, true)
end

function seedMod:OnUpdate()
	-- Check for TAB key press to toggle UI
	-- Using MC_POST_UPDATE to check keyboard input each frame
	if Input.IsButtonTriggered(Keyboard.KEY_TAB, 0) then
		seedMod:ToggleUI()
	end
end

-- CALLBACKS

seedMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, seedMod.GameStartCheck)
seedMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, seedMod.CheckDeadNPC)
seedMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, seedMod.OnMenuExit)
seedMod:AddCallback(ModCallbacks.MC_POST_RENDER, seedMod.RenderUI)
seedMod:AddCallback(ModCallbacks.MC_POST_UPDATE, seedMod.OnUpdate)

-- Console command: Players can open console with tilde (~) and type: lua seedMod:ToggleUI()