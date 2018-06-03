local seedMod = RegisterMod("SeedBackupGenerator", 1)

-- Notable items the run might've had. Based on the top 30 items on IsaacRanks.com as of 5/27/18, game-designated special items, and any other items I thought were run-defining
local NotableItemsDict = {[12] = "Magic Mushroom", [245] = "20/20",[182] = "Sacred Heart",[313] = "Holy Mantle",[395] = "",[395] = "Tech X",[118] = "",[118] = "Brimstone",[153] = "Mutant Spider",
				[331] = "Godhead",[105] = "D6",[237] = "Death's Touch",[4] = "Cricket's Head",[169] = "Polyphemus",[80] = "The Pact",[108] = "The Wafer",[360] = "Incubus",[230] = "Abaddon",[261] = "Proptosis",
				[494] = "Jacob's Ladder",[114] = "Mom's Knife",[415] = "Crown of Light",[223] = "Pyromaniac",[307] = "Capricorn",[224] = "Cricket's Body",[345] = "Synthoil",[101] = "The Halo",[168] = "Epic Fetus",
				[51] = "Pentagram",[189] = "SMB Super Fan",[216] = "Ceremonial Robes",[7] = "Blood of the Martyr",[330] = "Soy Milk",[5] = "My Reflection",[223] = "Tiny Planet",[529] = "Pop!",[152] = "Tech 2",
				[6] = "Number One",[524] = "Tech Zero",[69] = "Chocolate Milk",[402] = "Chaos",[2] = "The Inner Eye",[149] = "Ipecac",[414] = "More Options",[215] = "Goat Head",[424] = "Sack Head",
				[229] = "Monstro's Lung",[52] = "Dr. Fetus",[268] = "Dark Bum",[3] = "Spoon Bender",[104] = "The Parasite",[329] = "Ludovico Technique",[335] = "The Soul", [284] = "D4"}
				

local json = require("json") -- AB+ includes JSON4Lua, a JSON encoding utility. This mod uses it to store and retrieve info from the save file as tables. 
							 -- Before I realized AB+ supported JSON, I tried to work with just string manipulations. It was a nightmare.

local difficultyTable = {[0] = "Normal", [1] = "Hard", [2] = "Greed", [3] = "Greedier"}
local trackingItems = 1 -- Sort of a legacy variable, probably dumb but I'm keeping it in to prevent loops from screwing things up in some unforeseen way
local oldData = {}
local currentRunDataExists = false
local firstTimeUser
local gameStartCheckDone = false
local currentItems = ""


function seedMod:GameStartCheck(fromSaveGame)
	gameStartCheckDone = true
	if fromSaveGame and (Game():GetVictoryLap() == 0) then -- Victory lap runs have their own seeds, but should not be duplicated 
		currentRunDataExists = true 
		trackingItems = 1
		seedMod:UpdateItemsList()
	elseif (not fromSaveGame) and (Game():GetVictoryLap() == 0) then
		currentRunDataExists = false 
		trackingItems = 1
		seedMod:UpdateItemsList()
	else
		trackingItems = 0
	end
end



function seedMod:SaveInfo()
	if Game():GetVictoryLap() == 0 then
		trackingItems = 1
		oldData = ""
		local player = Isaac.GetPlayer(0)
		local seed = Game():GetSeeds():GetStartSeedString() 
		local name = player:GetName()
		local mode = difficultyTable[Game().Difficulty]
		local dateTime = os.date("%x %X")
		local isChallenge = Game().Challenge
		if isChallenge > 0 then
			mode = "Challenge (Normal)"
		end
		dateTime = string.gsub(dateTime, "/", "-")
		local numberOfItems = 0
		oldData = Isaac.LoadModData(seedMod)
		if string.len(oldData) == 0 then
			firstTimeUser = true
			oldData = {[1] = {DateTime = dateTime, Items = currentItems, Seed = seed, Name = name, Mode = mode}}
			oldData = json.encode(oldData)
			oldData = seedMod:make_pretty(oldData)
			Isaac.SaveModData(seedMod, oldData)
		else
			oldData = json.decode(oldData)
		end
		if (not currentRunDataExists) and (not firstTimeUser) then
			table.insert(oldData, 1, {Date = dateTime, Items = currentItems, Seed = seed, Name = name, Mode = mode})
			currentRunDataExists = true
		elseif currentRunDataExists and (not firstTimeUser) then
			if string.len(oldData[1].Items) < string.len(currentItems) then
				oldData[1].Items = currentItems
			end
		end
		if (not firstTimeUser) then 
			local originalData = oldData
			oldData = json.encode(oldData)
			oldData = seedMod:make_pretty(oldData)
			Isaac.SaveModData(seedMod, oldData)
		else
			firstTimeUser = false
		end
	else
		trackingItems = 0
	end
end


function seedMod:UpdateItemsList()
	if gameStartCheckDone == true then
		local player = Isaac.GetPlayer(0)
		local numberOfItems = 0
		itemTableBuffer = {}
		currentItems = ""
		for ItemID,ItemName in pairs(NotableItemsDict) do
			if (player:HasCollectible(ItemID)) then
				numberOfItems = numberOfItems + 1
				if numberOfItems > 1 then
					table.insert(itemTableBuffer, ", ")
					table.insert(itemTableBuffer, ItemName)
				else
					table.insert(itemTableBuffer, ItemName)
				end
			end
		end
		currentItems = table.concat(itemTableBuffer)
		currentItems = string.gsub(currentItems, "/", "-")
		seedMod:SaveInfo(currentItems)
	end
end
	

function seedMod:CheckDeadNPC(DeadNPC)
	if DeadNPC:IsBoss() then
		if ((Game():GetVictoryLap() == 0) and (trackingItems == 1)) then
			seedMod:UpdateItemsList()
		else
			trackingItems = 0
		end
	end
end


function seedMod:make_pretty(uglystr) -- Written by the legendary Andre Segura - https://github.com/andrensegura/
    -- Takes an ugly string, returns a prettier one.
    -- Change spaces to your desired indentation width.
	local tableBuffer = {}
    local spaces = 2
    local prettystr = ""
    local count = 0
	local formattingCommaIncoming
    for c in uglystr:gmatch"." do
        if c == '[' or c == '{' then
            table.insert(tableBuffer, c)
			table.insert(tableBuffer, '\n')
            count = count + 1
            for i=1,count*spaces do
                table.insert(tableBuffer, " ")
            end
			formattingCommaIncoming = true
        elseif c == ']' or c == '}' then
            table.insert(tableBuffer, '\n')
            count = count - 1
            for i=1,count*spaces do
                table.insert(tableBuffer, " ")
            end
            table.insert(tableBuffer, c)
			formattingCommaIncoming = true
        elseif c == ',' then
            if formattingCommaIncoming then
				table.insert(tableBuffer, c)
				table.insert(tableBuffer, '\n')
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
	prettystr = table.concat(tableBuffer)
    return prettystr
end

function seedMod:OnMenuExit()
	gameStartCheckDone = false
end


seedMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, seedMod.GameStartCheck)
seedMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, seedMod.CheckDeadNPC)
seedMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, seedMod.OnMenuExit)
