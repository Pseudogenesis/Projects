--[[ Seed Planter 2.0 - A seed log generator for The Binding of Isaac: Repentance+

	 FEATURES:
	 - Automatic seed logging with detailed run information
	 - Tainted character support
	 - Dual item tracking: Notable items + Quality-based filtering
	 - Transformation tracking (all 15 transformations including Stompy & Super Bum)
	 - Floor progression tracking
	 - In-game UI for viewing seed history (Press F2 to toggle)
	 - Challenge mode support
	 - Victory lap handling

	 USAGE:
	 - The mod works automatically - just play!
	 - Press F2 in-game to view your seed history
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

	-- Repentance items (verified notable items only)
	-- For additional items, find IDs at platinumgod.co.uk and add them below
	[562] = "Rock Bottom", [579] = "Spirit Sword", [625] = "Mega Mush", [628] = "Death Certificate",
	[636] = "R Key", [642] = "Magic Skin", [643] = "Revelation", [656] = "Damocles",
	[678] = "C Section", [689] = "Glitched Crown", [714] = "Spindown Dice"
}

-- Item priority rankings (1-5, where 5 = most important)
-- This ensures the best items appear first in the list
local ItemPriority = {
	-- Tier 5: Game-breaking, run-winning items
	[182] = 5, -- Sacred Heart
	[331] = 5, -- Godhead
	[628] = 5, -- Death Certificate
	[636] = 5, -- R Key
	[562] = 5, -- Rock Bottom
	[689] = 5, -- Glitched Crown

	-- Tier 4: Extremely powerful items
	[118] = 4, -- Brimstone
	[114] = 4, -- Mom's Knife
	[169] = 4, -- Polyphemus
	[168] = 4, -- Epic Fetus
	[395] = 4, -- Tech X
	[313] = 4, -- Holy Mantle
	[399] = 4, -- Maw of the Void
	[12] = 4,  -- Magic Mushroom
	[678] = 4, -- C Section
	[625] = 4, -- Mega Mush
	[656] = 4, -- Damocles

	-- Tier 3: Very strong items
	[4] = 3,   -- Cricket's Head
	[237] = 3, -- Death's Touch
	[261] = 3, -- Proptosis
	[245] = 3, -- 20/20
	[153] = 3, -- Mutant Spider
	[360] = 3, -- Incubus
	[230] = 3, -- Abaddon
	[105] = 3, -- D6
	[52] = 3,  -- Dr. Fetus
	[229] = 3, -- Monstro's Lung
	[643] = 3, -- Revelation
	[579] = 3, -- Spirit Sword
	[714] = 3, -- Spindown Dice

	-- Tier 2: Strong items
	[415] = 2, -- Crown of Light
	[223] = 2, -- Pyromaniac
	[215] = 2, -- Goat Head
	[477] = 2, -- Void
	[407] = 2, -- Purity
	[149] = 2, -- Ipecac
	[329] = 2, -- Ludovico Technique
	[69] = 2,  -- Chocolate Milk
	[494] = 2, -- Jacob's Ladder
	[642] = 2, -- Magic Skin

	-- Everything else defaults to Tier 1 (still notable, but less critical)
}

-- Get priority for an item (default to 1 if not specified)
local function GetItemPriority(itemID)
	return ItemPriority[itemID] or 1
end
				

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
	currentRunVictory = nil -- Reset victory tracking for new game
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
	-- First, try to reverse the pretty formatting
	local decodedSeed = seedMod:ReverseExtraPretty(str)

	-- Remove all whitespace formatting (newlines, carriage returns, extra spaces)
	decodedSeed = string.gsub(decodedSeed, "\r\n", "")
	decodedSeed = string.gsub(decodedSeed, "\n", "")
	decodedSeed = string.gsub(decodedSeed, "\r", "")

	-- Remove indentation spaces carefully (preserve spaces in quoted strings)
	decodedSeed = string.gsub(decodedSeed, "%s+", " ")
	decodedSeed = string.gsub(decodedSeed, " :", ":")
	decodedSeed = string.gsub(decodedSeed, ": ", ":")
	decodedSeed = string.gsub(decodedSeed, " ,", ",")
	decodedSeed = string.gsub(decodedSeed, ", ", ",")
	decodedSeed = string.gsub(decodedSeed, "{ ", "{")
	decodedSeed = string.gsub(decodedSeed, " }", "}")
	decodedSeed = string.gsub(decodedSeed, " %[", "[")
	decodedSeed = string.gsub(decodedSeed, "%[ ", "[")

	-- Try to decode with error handling
	local success, result = pcall(json.decode, decodedSeed)
	if success then
		return result
	else
		-- If decode fails, log error and return nil
		if Isaac.ConsoleOutput then
			Isaac.ConsoleOutput("Seed Planter: Failed to decode seed data - " .. tostring(result) .. "\n")
		end
		return nil
	end
end



function seedMod:IsolateSeeds(data) -- Takes the log data, extracts the most recent seed info, and separates it into two parts: The last seed data, and the rest of the file.
	local master = {}
	local lastSeed = ""
	lastSeed = string.match(data, "{.-}")

	if not lastSeed then
		-- No valid seed data found
		return {}, {}
	end

	lastTable = seedMod:CustomDecode(lastSeed)

	-- If decode failed, return empty table to prevent crashes
	if not lastTable then
		lastTable = {}
	end

	table.insert(master, lastSeed)
	local remainder = string.match(data, "}(.*)")
	table.insert(master, remainder or "")
	return master, lastTable
end

function seedMod:GetRunData()
	-- Returns a table containing current run data: Seed, character, items, mode/difficulty, transformations, floor, and victory
	local playerOne = Isaac.GetPlayer(0)
	local dataTable = {
		Seed = Game():GetSeeds():GetStartSeedString(),
		Name = seedMod:GetCharacterName(playerOne), -- Now properly detects tainted characters
		Floor = seedMod:GetFloorName(), -- Track which floor the run reached
		Transformations = seedMod:RecordTransformations(),
		Items = currentItems,
		QualityItems = currentQualityItems, -- Quality-filtered items
		Mode = difficultyTable[Game().Difficulty],
		Victory = currentRunVictory -- Track if final boss was defeated
	}

	-- Override mode for challenges
	if Game().Challenge > 0 then
		dataTable.Mode = "Challenge (Normal)"
	end

	return dataTable
end
	
	
function seedMod:SaveInfo()
	-- Main save logic with safeguards to prevent data loss
	if Game():GetVictoryLap() == 0 then
		local masterTable = {}
		local lastSeedTable = {}
		local runData = seedMod:GetRunData()
		seedData = ""
		trackingItems = 1
		seedData = Isaac.LoadModData(seedMod)

		if string.len(seedData) == 0 then
			-- Empty save file - first time user
			firstTimeUser = true
			runData = seedMod:CustomEncode(runData)
			seedData = runData
			Isaac.SaveModData(seedMod, seedData)
			currentRunDataExists = true

			-- Mark cache as needing refresh since we just saved new data
			cacheNeedsRefresh = true
		else
			-- Try to parse existing save data
			masterTable, lastSeedTable = seedMod:IsolateSeeds(seedData)

			-- CRITICAL: Check if parsing failed
			if #masterTable == 0 or not lastSeedTable then
				-- Parsing failed! Do NOT overwrite the save file
				-- Just append our new data to the end and hope for the best
				if Isaac.ConsoleOutput then
					Isaac.ConsoleOutput("Seed Planter: Warning - Could not parse existing save data. Appending new seed without modifying old data.\n")
				end

				-- Encode the new run data
				local encodedNewRun = seedMod:CustomEncode(runData)

				-- Append to existing data instead of replacing
				seedData = seedData .. "\n" .. encodedNewRun
				Isaac.SaveModData(seedMod, seedData)
				currentRunDataExists = true

				-- Mark cache as needing refresh since we just saved new data
				cacheNeedsRefresh = true

				return -- Exit early to prevent further processing
			end
		end

		-- Normal processing if parsing succeeded
		if (not currentRunDataExists) and (not firstTimeUser) then
			-- New run - add to master table
			table.insert(masterTable, 1, runData)
			masterTable[1] = seedMod:CustomEncode(masterTable[1])
			currentRunDataExists = true
		elseif currentRunDataExists and (not firstTimeUser) then
			-- Continued run - update existing entry
			-- Safety check: ensure lastSeedTable has required fields
			if type(lastSeedTable) == "table" and lastSeedTable.Items then
				masterTable[1] = lastSeedTable
				if string.len(lastSeedTable.Items or "") < string.len(currentItems) then
					masterTable[1] = runData
				elseif lastSeedTable.Items == "No notable items" and currentItems ~= "No notable items" then
					masterTable[1] = runData
				else
					masterTable[1].Transformations = runData.Transformations
					masterTable[1].Floor = runData.Floor -- Update floor progress
					masterTable[1].QualityItems = runData.QualityItems -- Update quality items
				end
				masterTable[1] = seedMod:CustomEncode(masterTable[1])
			else
				-- lastSeedTable is invalid, create new entry
				table.insert(masterTable, 1, seedMod:CustomEncode(runData))
				currentRunDataExists = true
			end
		end

		if (not firstTimeUser) then
			-- Save the updated data
			table.insert(masterTable, 1, "SEEDS ARE IN CHRONOLOGICAL ORDER. The top seed is the newest, the bottom seed is the oldest. Enjoy!\n")
			seedData = table.concat(masterTable)
			Isaac.SaveModData(seedMod, seedData)
		else
			firstTimeUser = false
		end

		-- Mark cache as needing refresh since we just saved new data
		cacheNeedsRefresh = true

	else
		trackingItems = 0 -- Victory laps not tracked
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
		-- Collect items with their priorities for sorting
		local itemsWithPriority = {}
		for ItemID, ItemName in pairs(NotableItemsDict) do
			if player:HasCollectible(ItemID) then
				table.insert(itemsWithPriority, {
					id = ItemID,
					name = ItemName,
					priority = GetItemPriority(ItemID)
				})
			end
		end

		-- Sort by priority (highest first), then alphabetically by name
		table.sort(itemsWithPriority, function(a, b)
			if a.priority == b.priority then
				return a.name < b.name  -- Alphabetical if same priority
			end
			return a.priority > b.priority  -- Higher priority first
		end)

		-- Build the comma-separated string from sorted items
		for i, item in ipairs(itemsWithPriority) do
			numberOfItems = numberOfItems + 1
			if i > 1 then
				table.insert(itemTableBuffer, ", ")
			end
			table.insert(itemTableBuffer, item.name)
		end

		-- Second, build quality-based items list (all items meeting quality threshold)
		local itemConfig = Isaac.GetItemConfig()
		local maxItemID = 730 -- Approximate max collectible ID in Repentance+
		for itemID = 1, maxItemID do
			if player:HasCollectible(itemID) then
				local item = itemConfig:GetCollectible(itemID)
				if item and seedMod:ShouldLogItem(itemID) then
					-- Use the item's name - in Repentance this should be localized
					local itemName = item.Name
					-- Check if it's a constant (starts with #) and skip it
					if string.sub(itemName, 1, 1) ~= "#" then
						numberOfQualityItems = numberOfQualityItems + 1
						if numberOfQualityItems > 1 then
							table.insert(qualityItemBuffer, ", ")
							table.insert(qualityItemBuffer, itemName)
						else
							table.insert(qualityItemBuffer, itemName)
						end
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
			
-- Track if victory has been achieved this run
local currentRunVictory = nil

function seedMod:CheckDeadNPC(DeadNPC)
	-- Updates and saves item list whenever a boss is killed
	if DeadNPC:IsBoss() then
		if ((Game():GetVictoryLap() == 0) and (trackingItems == 1)) then
			-- Check if this is a final boss for victory tracking
			local bossType = DeadNPC.Type
			local bossName = nil

			-- Final boss entity IDs
			if bossType == 78 then
				bossName = "Mom's Heart/It Lives"
			elseif bossType == 84 then
				bossName = "Satan"
			elseif bossType == 102 then
				bossName = "Isaac/Blue Baby"
			elseif bossType == 273 then
				bossName = "The Lamb"
			elseif bossType == 274 then
				bossName = "Mega Satan"
			elseif bossType == 412 then
				bossName = "Delirium"
			elseif bossType == 912 then
				bossName = "Mother"
			elseif bossType == 951 then
				bossName = "The Beast"
			elseif bossType == 406 or bossType == 407 then
				bossName = "Ultra Greed"
			end

			-- If we defeated a final boss, mark victory
			if bossName then
				currentRunVictory = bossName
			end

			-- Save after every boss kill now
			-- This ensures the log updates throughout the run
			seedMod:UpdateItemsList(false)
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
	outboundSaveData = string.gsub(outboundSaveData, '"Victory":', 'Victory: ')
	outboundSaveData = string.gsub(outboundSaveData, '"Favorite":', 'Favorite: ')
	return outboundSaveData
end

function seedMod:ReverseExtraPretty(inboundSaveData)
	-- Reverses ExtraPretty() formatting so JSON can be parsed again
	-- Handle all possible fields from various versions, with and without spaces after colons
	-- IMPORTANT: Process longer patterns first to avoid partial matches

	-- Process with spaces first (preferred format) - longer patterns first
	inboundSaveData = string.gsub(inboundSaveData, 'Quality Items: ', '"QualityItems":')
	inboundSaveData = string.gsub(inboundSaveData, 'Transformations: ', '"Transformations":')
	inboundSaveData = string.gsub(inboundSaveData, 'Victory: ', '"Victory":')
	inboundSaveData = string.gsub(inboundSaveData, 'Favorite: ', '"Favorite":')
	inboundSaveData = string.gsub(inboundSaveData, 'Items: ', '"Items":')
	inboundSaveData = string.gsub(inboundSaveData, 'Mode: ', '"Mode":')
	inboundSaveData = string.gsub(inboundSaveData, 'Name: ', '"Name":')
	inboundSaveData = string.gsub(inboundSaveData, 'Seed: ', '"Seed":')
	inboundSaveData = string.gsub(inboundSaveData, 'Floor: ', '"Floor":')
	inboundSaveData = string.gsub(inboundSaveData, 'Date: ', '"Date":')
	inboundSaveData = string.gsub(inboundSaveData, 'Length: ', '"Length":')

	-- Process without spaces (legacy/corrupted format) - longer patterns first
	inboundSaveData = string.gsub(inboundSaveData, 'Quality Items:', '"QualityItems":')
	inboundSaveData = string.gsub(inboundSaveData, 'Transformations:', '"Transformations":')
	inboundSaveData = string.gsub(inboundSaveData, 'Victory:', '"Victory":')
	inboundSaveData = string.gsub(inboundSaveData, 'Favorite:', '"Favorite":')
	inboundSaveData = string.gsub(inboundSaveData, 'Items:', '"Items":')
	inboundSaveData = string.gsub(inboundSaveData, 'Mode:', '"Mode":')
	inboundSaveData = string.gsub(inboundSaveData, 'Name:', '"Name":')
	inboundSaveData = string.gsub(inboundSaveData, 'Seed:', '"Seed":')
	inboundSaveData = string.gsub(inboundSaveData, 'Floor:', '"Floor":')
	inboundSaveData = string.gsub(inboundSaveData, 'Date:', '"Date":')
	inboundSaveData = string.gsub(inboundSaveData, 'Length:', '"Length":')

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
local MAX_VISIBLE_SEEDS = 5  -- Starting point for dynamic display (actual count varies)

-- Performance optimization: Cache parsed seed data to avoid re-parsing every frame
local cachedSeeds = nil
local cacheNeedsRefresh = true

-- Track last rendered seed index for scroll calculations
local lastRenderedEndIdx = 0

function seedMod:ToggleUI()
	-- Toggle the seed history UI on/off
	showingUI = not showingUI
	if showingUI then
		uiScrollOffset = 0
		cacheNeedsRefresh = true  -- Refresh cache when opening UI
	end
end

function seedMod:ParseSeedHistory()
	-- Parse saved seed data and return a table of seed entries
	-- Uses caching to avoid expensive re-parsing every frame (critical for large log files)

	-- Return cached data if available and valid
	if cachedSeeds and not cacheNeedsRefresh then
		return cachedSeeds
	end

	-- Need to parse/re-parse the data
	local savedData = Isaac.LoadModData(seedMod)
	if string.len(savedData) == 0 then
		cachedSeeds = {}
		cacheNeedsRefresh = false
		return {}
	end

	local seeds = {}
	-- Split the data by seed entries (each starts with "{" and ends with "}")
	for seedEntry in string.gmatch(savedData, "{.-}") do
		local decodedSeed = seedMod:CustomDecode(seedEntry)
		-- Only add successfully decoded seeds
		if decodedSeed and type(decodedSeed) == "table" then
			table.insert(seeds, decodedSeed)
		end
	end

	-- Cache the results for subsequent frames
	cachedSeeds = seeds
	cacheNeedsRefresh = false

	return seeds
end

function seedMod:RenderUI()
	-- Render the in-game seed history UI with proper pixel-width-based text wrapping
	if not showingUI then
		return
	end

	local seeds = seedMod:ParseSeedHistory()
	if #seeds == 0 then
		-- Display "no seeds" message with proportional positioning
		local font = Font()
		font:Load("font/upheaval.fnt")
		local screenWidth = Isaac.GetScreenWidth()
		local screenHeight = Isaac.GetScreenHeight()

		local topMargin = math.floor(screenHeight * 0.1)  -- 10% from top
		local bottomMargin = math.floor(screenHeight * 0.05)  -- 5% from bottom

		local title = "SEED PLANTER - No Seeds Recorded"
		local titleWidth = font:GetStringWidth(title)
		font:DrawString(title, screenWidth/2 - titleWidth/2, topMargin, KColor(1,1,1,1), 0, true)

		local hint = "Press F2 to close"
		local hintWidth = font:GetStringWidth(hint)
		font:DrawString(hint, screenWidth/2 - hintWidth/2, screenHeight - bottomMargin, KColor(0.7,0.7,0.7,1), 0, true)
		return
	end

	-- Render seed history
	local font = Font()
	font:Load("font/upheaval.fnt")
	local screenWidth = Isaac.GetScreenWidth()
	local screenHeight = Isaac.GetScreenHeight()

	-- Proportional scaling for consistent look across all screen sizes
	-- Increased left margin to avoid overlapping Isaac's native HUD (stats, items, etc.)
	local leftMargin = math.floor(screenWidth * 0.12)  -- 12% of screen width for HUD clearance
	local rightMargin = math.floor(screenWidth * 0.03)  -- 3% on right (less UI there)
	local topMargin = math.floor(screenHeight * 0.05)  -- 5% of screen height
	local footerReserve = math.floor(screenHeight * 0.12)  -- 12% reserved for footer
	local minSeedHeight = math.floor(screenHeight * 0.13)  -- 13% minimum per seed (very conservative)

	local maxWidth = screenWidth - leftMargin - rightMargin -- Account for asymmetric margins
	local yPos = topMargin

	-- Title
	local title = "SEED PLANTER - Recent Seeds"
	local titleWidth = font:GetStringWidth(title)
	font:DrawString(title, screenWidth/2 - titleWidth/2, yPos, KColor(1,1,0.5,1), 0, true)
	yPos = yPos + 20

	-- Calculate available vertical space (78% of screen max, rest for title/footer)
	-- Very conservative to prevent any overflow into footer area
	local maxY = math.floor(screenHeight * 0.78)
	local visibleCount = 0
	local startIdx = uiScrollOffset + 1
	local endIdx = startIdx

	-- Dynamically render seeds until we run out of vertical space
	for i = startIdx, #seeds do
		-- Check if we have space for another seed BEFORE rendering it
		-- Uses proportional minimum height check (scales with screen)
		if visibleCount > 0 and yPos + minSeedHeight > maxY then
			-- No more vertical space - stop here
			break
		end

		local seed = seeds[i]

		-- Determine seed quality for highlighting
		local quality = GetSeedQuality(seed.Items)
		local lineColor = KColor(1,1,1,1) -- Default white

		if quality == 3 then
			lineColor = KColor(1,0.84,0,1) -- Gold - Has tier 5 items
		elseif quality == 2 then
			lineColor = KColor(0.8,0.5,1,1) -- Purple - 3+ tier 4 items
		elseif quality == 1 then
			lineColor = KColor(0.5,1,0.5,1) -- Green - Good run
		end

		-- Add favorite marker if this seed is favorited
		local favoriteMarker = ""
		if seed.Favorite then
			favoriteMarker = "★ "
			lineColor = KColor(1,1,0,1) -- Yellow for favorites (overrides quality color)
		end

		-- Seed info (compact format)
		local seedLine = string.format("%s%d. %s - %s (%s)", favoriteMarker, i, seed.Seed or "???", seed.Name or "Unknown", seed.Mode or "Unknown")
		font:DrawString(seedLine, leftMargin, yPos, lineColor, 0, true)
		yPos = yPos + 13

		-- Floor reached and victory status
		if seed.Floor then
			local floorLine = "Floor: " .. seed.Floor
			if seed.Victory then
				floorLine = floorLine .. " | Victory: " .. seed.Victory
				font:DrawString(floorLine, leftMargin + 10, yPos, KColor(0.5,1,0.5,1), 0, true) -- Green for victory
			else
				font:DrawString(floorLine, leftMargin + 10, yPos, KColor(0.8,0.8,1,1), 0, true)
			end
			yPos = yPos + 11
		end

		-- Transformations (with text wrapping)
		if seed.Transformations and seed.Transformations ~= "None" then
			local transText = seed.Transformations
			local prefix = "Trans: "
			local indent = "       "
			local prefixWidth = font:GetStringWidth(prefix)
			local indentWidth = font:GetStringWidth(indent)

			-- Split transformations by comma
			local transformations = {}
			for trans in string.gmatch(transText, "[^,]+") do
				table.insert(transformations, trans)
			end

			local currentLine = prefix
			local currentWidth = prefixWidth
			local transLineCount = 0

			for idx, trans in ipairs(transformations) do
				local transText = trans
				if idx < #transformations then
					transText = transText .. ","
				end

				local transWidth = font:GetStringWidth(transText)

				-- Check if adding this transformation would exceed width
				if currentWidth + transWidth > maxWidth and currentLine ~= prefix then
					-- Print current line and start new one
					font:DrawString(currentLine, leftMargin + 10, yPos, KColor(1,0.8,1,1), 0, true)
					yPos = yPos + 11
					transLineCount = transLineCount + 1

					-- Start new line with indentation
					currentLine = indent .. transText
					currentWidth = indentWidth + transWidth
				else
					-- Add to current line
					currentLine = currentLine .. transText
					currentWidth = currentWidth + transWidth
				end
			end

			-- Print final line
			font:DrawString(currentLine, leftMargin + 10, yPos, KColor(1,0.8,1,1), 0, true)
			yPos = yPos + 11
		end

		-- Items (word-wrap using actual pixel width)
		if seed.Items and seed.Items ~= "No notable items" then
			local itemsText = seed.Items
			local prefix = "Items: "
			local indent = "       "
			local prefixWidth = font:GetStringWidth(prefix)
			local indentWidth = font:GetStringWidth(indent)
			local ellipsisWidth = font:GetStringWidth("...")

			-- Split items by comma
			local items = {}
			for item in string.gmatch(itemsText, "[^,]+") do
				table.insert(items, item)
			end

			local currentLine = prefix
			local currentWidth = prefixWidth
			local lineCount = 0
			local maxLines = 2 -- Limit to 2 lines per seed
			local truncated = false

			for idx, item in ipairs(items) do
				-- Add comma if not first item
				local itemText = item
				if idx < #items then
					itemText = itemText .. ","
				end

				local itemWidth = font:GetStringWidth(itemText)

				-- Check if adding this item would exceed width
				if currentWidth + itemWidth > maxWidth and currentLine ~= prefix then
					-- Print current line and start new one
					font:DrawString(currentLine, leftMargin + 10, yPos, KColor(0.8,1,0.8,1), 0, true)
					yPos = yPos + 11
					lineCount = lineCount + 1

					-- Check if we've hit max lines
					if lineCount >= maxLines then
						-- Try to append "..." to current line if it fits
						if currentWidth + ellipsisWidth <= maxWidth then
							currentLine = currentLine .. "..."
							font:DrawString(currentLine, leftMargin + 10, yPos - 11, KColor(0.8,1,0.8,1), 0, true)
						else
							-- Print "..." on new line only if necessary
							local truncLine = indent .. "..."
							font:DrawString(truncLine, leftMargin + 10, yPos, KColor(0.8,1,0.8,1), 0, true)
							yPos = yPos + 11
						end
						truncated = true
						break
					end

					-- Start new line with indentation
					currentLine = indent .. itemText
					currentWidth = indentWidth + itemWidth
				else
					-- Add to current line
					currentLine = currentLine .. itemText
					currentWidth = currentWidth + itemWidth
				end
			end

			-- Print final line if not truncated
			if not truncated then
				font:DrawString(currentLine, leftMargin + 10, yPos, KColor(0.8,1,0.8,1), 0, true)
				yPos = yPos + 11
			end
		end

		yPos = yPos + 6 -- Compact spacing between entries

		-- This seed was successfully rendered, include it in the count
		endIdx = i
		visibleCount = visibleCount + 1
	end

	-- Footer with controls (clean, compact format)
	local footer = "F2: Close | F: Favorite | "

	-- Show scroll hints based on position
	-- Calculate max offset based on total seeds and how many we can show
	local hasMoreSeeds = endIdx < #seeds
	local canScrollUp = uiScrollOffset > 0

	if hasMoreSeeds or canScrollUp then
		if uiScrollOffset == 0 then
			-- At top - can only scroll down
			footer = footer .. "Down: More | "
		elseif not hasMoreSeeds then
			-- At bottom - can only scroll up
			footer = footer .. "Up: More | "
		else
			-- In middle - can scroll both ways
			footer = footer .. "Arrows: Scroll | "
		end
	end

	-- Use compact format: "X-Y/Z" instead of "X-Y of Z" to prevent overflow
	footer = footer .. string.format("%d-%d/%d", startIdx, endIdx, #seeds)

	-- Footer positioned higher to clear item names at bottom (positioned at 85%)
	local footerWidth = font:GetStringWidth(footer)
	local footerY = math.floor(screenHeight * 0.85)  -- Raised to 85% to vertically clear bottom HUD

	-- Calculate footer X position with margins to avoid HUD overlap
	local footerMargin = math.floor(screenWidth * 0.12)  -- 12% margin on each side
	local footerMaxWidth = screenWidth - (footerMargin * 2)

	-- Center footer within safe area (between footerMargins)
	local footerX = footerMargin + (footerMaxWidth / 2) - (footerWidth / 2)

	-- If footer is too wide, try to center it as best we can
	if footerWidth > footerMaxWidth then
		-- Adjust X to keep footer visible even if slightly wider
		footerX = math.max(footerMargin, (screenWidth / 2) - (footerWidth / 2))
	end

	font:DrawString(footer, footerX, footerY, KColor(0.7,0.7,0.7,1), 0, true)

	-- Store endIdx for scroll calculations
	lastRenderedEndIdx = endIdx
end

-- Track previous key states to prevent multiple triggers
local lastKeyState = false
local lastUpKeyState = false
local lastDownKeyState = false
local lastFavoriteKeyState = false

-- Helper function to evaluate seed quality for highlighting
local function GetSeedQuality(itemsString)
	if not itemsString or itemsString == "No notable items" then
		return 0 -- No special quality
	end

	local tier5Count = 0
	local tier4Count = 0
	local tier3Count = 0

	-- Check each item in the string against priority tiers
	for itemName in string.gmatch(itemsString, "[^,]+") do
		itemName = itemName:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace

		-- Find this item in our dictionary and check its priority
		for itemID, name in pairs(NotableItemsDict) do
			if name == itemName then
				local priority = GetItemPriority(itemID)
				if priority == 5 then
					tier5Count = tier5Count + 1
				elseif priority == 4 then
					tier4Count = tier4Count + 1
				elseif priority == 3 then
					tier3Count = tier3Count + 1
				end
				break
			end
		end
	end

	-- Return quality level based on item tiers
	if tier5Count >= 1 then
		return 3 -- Gold - Has tier 5 items
	elseif tier4Count >= 3 then
		return 2 -- Purple - 3+ tier 4 items
	elseif tier4Count >= 2 or tier3Count >= 3 then
		return 1 -- Green - Good run
	end

	return 0 -- Default white
end

function seedMod:ToggleFavorite(seedIndex)
	-- Toggle favorite status for a specific seed
	local seeds = seedMod:ParseSeedHistory()
	if seedIndex < 1 or seedIndex > #seeds then
		return -- Invalid index
	end

	-- Load the raw save data
	local savedData = Isaac.LoadModData(seedMod)
	if string.len(savedData) == 0 then
		return
	end

	-- Parse all seeds
	local seedEntries = {}
	for seedEntry in string.gmatch(savedData, "{.-}") do
		table.insert(seedEntries, seedEntry)
	end

	-- Decode the target seed
	local targetSeed = seedMod:CustomDecode(seedEntries[seedIndex])
	if not targetSeed then
		return
	end

	-- Toggle favorite status
	targetSeed.Favorite = not targetSeed.Favorite

	-- Re-encode the seed
	seedEntries[seedIndex] = seedMod:CustomEncode(targetSeed)

	-- Rebuild the save file
	local header = "SEEDS ARE IN CHRONOLOGICAL ORDER. The top seed is the newest, the bottom seed is the oldest. Enjoy!\n"
	local newSaveData = header .. table.concat(seedEntries)

	-- Save
	Isaac.SaveModData(seedMod, newSaveData)
	cacheNeedsRefresh = true
end

function seedMod:OnUpdate()
	-- Check for F2 key press to toggle UI
	-- Using MC_POST_UPDATE to check keyboard input each frame
	-- F2 chosen to avoid conflicts with game's Tab key (map toggle)
	local keyPressed = Input.IsButtonPressed(Keyboard.KEY_F2, 0)

	-- Only toggle when key transitions from not pressed to pressed
	if keyPressed and not lastKeyState then
		seedMod:ToggleUI()
	end

	lastKeyState = keyPressed

	-- Handle arrow key scrolling when UI is visible
	if showingUI then
		local upPressed = Input.IsButtonPressed(Keyboard.KEY_UP, 0)
		local downPressed = Input.IsButtonPressed(Keyboard.KEY_DOWN, 0)

		-- Scroll up (show earlier seeds)
		if upPressed and not lastUpKeyState then
			if uiScrollOffset > 0 then
				uiScrollOffset = uiScrollOffset - 1
			end
		end

		-- Scroll down (show later seeds)
		if downPressed and not lastDownKeyState then
			local seeds = seedMod:ParseSeedHistory()
			-- Allow scrolling if the last rendered seed isn't the final seed
			if lastRenderedEndIdx < #seeds then
				uiScrollOffset = uiScrollOffset + 1
			end
		end

		lastUpKeyState = upPressed
		lastDownKeyState = downPressed

		-- Check for F key press to toggle favorite for the top visible seed
		local fPressed = Input.IsButtonPressed(Keyboard.KEY_F, 0)

		if fPressed and not lastFavoriteKeyState then
			-- Toggle favorite for the top visible seed (the one at scroll offset)
			seedMod:ToggleFavorite(uiScrollOffset + 1)
		end

		lastFavoriteKeyState = fPressed
	end
end

-- CALLBACKS

seedMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, seedMod.GameStartCheck)
seedMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, seedMod.CheckDeadNPC)
seedMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, seedMod.OnMenuExit)
seedMod:AddCallback(ModCallbacks.MC_POST_RENDER, seedMod.RenderUI)
seedMod:AddCallback(ModCallbacks.MC_POST_UPDATE, seedMod.OnUpdate)

-- Console command: Players can open console with tilde (~) and type: lua seedMod:ToggleUI()