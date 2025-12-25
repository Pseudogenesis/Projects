-- Season Change Script for Tempers of the Ever-Changing Skies --
-- Runs from invisible attached child object --
-- Self-initializes via onLoad since mod doesn't call doSetup on child objects --

local spiritName = "Tempers of the Ever-Changing Skies"
local impendTable = {}
local pos
-- Wheel states: 1=Ire, 2=Joy, 3=Calm, 4=Sorrow
local EMOTIONS = {"Ire", "Joy", "Calm", "Sorrow"}
local seasonWheel = nil
local playerColor = nil
local busy = false  -- Prevents rapid clicking
local spiritPanel = nil  -- Reference to parent panel
local initialized = false  -- Prevent double initialization

-----------------------------------------
-- Forward declarations for local functions
-----------------------------------------
local getWheelEmotion
local setWheelToEmotion
local findInnateWithTagInHand
local findInnateWithTagInHandObjects
local getEmotionIndex
local getNextEmotionIndex

-----------------------------------------
-- Local function implementations
-----------------------------------------

getWheelEmotion = function()
    if not seasonWheel then return "Ire" end
    local stateId = seasonWheel.getStateId()
    if stateId == -1 then stateId = 1 end
    return EMOTIONS[stateId] or "Ire"
end

setWheelToEmotion = function(emotionTag)
    if not seasonWheel then return end

    local targetState = 1
    for i, emotion in ipairs(EMOTIONS) do
        if emotion == emotionTag then
            targetState = i
            break
        end
    end

    local currentState = seasonWheel.getStateId()
    if currentState == -1 then currentState = 1 end

    if targetState ~= currentState then
        seasonWheel = seasonWheel.setState(targetState)
    end
end

findInnateWithTagInHand = function(color, handIndex, tagName)
    local hand = Player[color].getHandObjects(handIndex)
    for _, obj in ipairs(hand) do
        if obj.hasTag("Innate") and obj.hasTag(tagName) then
            return obj
        end
    end
    return nil
end

findInnateWithTagInHandObjects = function(handObjects, tagName)
    for _, obj in ipairs(handObjects) do
        if obj.hasTag("Innate") and obj.hasTag(tagName) then
            return obj
        end
    end
    return nil
end

getEmotionIndex = function(card)
    for i, tag in ipairs(EMOTIONS) do
        if card.hasTag(tag) then return i end
    end
    return 1
end

getNextEmotionIndex = function(card, reverse)
    local i = getEmotionIndex(card)
    if reverse then
        return ((i - 2) % #EMOTIONS) + 1
    else
        return (i % #EMOTIONS) + 1
    end
end

-----------------------------------------
-- Initialization
-----------------------------------------

local function runSetup()
    if initialized then return end

    -- Get player color from Global
    local color = Global.call("getSpiritColor", {name = spiritName})
    if not color then return end  -- Spirit not set up yet

    initialized = true
    playerColor = color

    -- Get the parent spirit panel
    spiritPanel = self.getParent()
    if not spiritPanel then return end

    local position = spiritPanel.getPosition() + Vector(-8.2,-0.22,6.8)
    pos = position

    -- Find the Season Wheel
    for _, obj in ipairs(getAllObjects()) do
        if obj.getName():find("Season Wheel") then
            seasonWheel = obj
            break
        end
    end

    -- Spawn the new hand (hand index 3)
    local handPosition = Player[color].getHandTransform(2).position
    handPosition.z = handPosition.z - 5.5
    Global.call("SpawnHand", {color = color, position = handPosition})

    -- Determine starting emotion from wheel
    local startingEmotion = getWheelEmotion()

    -- Process Innate cards
    local hand = Player[color].getHandObjects(1)
    Wait.frames(function()
        if hand ~= {} then
            local startingCard = findInnateWithTagInHandObjects(hand, startingEmotion)

            for _,card in pairs(hand) do
                if card.hasTag("Innate") then
                    if card == startingCard then
                        local targetPos = pos + Vector(13, 0.5, -10)
                        card.setPosition(targetPos, false)
                    else
                        card.deal(1, color, 3)
                    end
                end
            end
        end
    end, 1)

    -- Create the button on the panel
    createPanelButtons(spiritPanel)
end

-- Poll for setup completion
local function waitForSetup()
    if initialized then return end

    -- Check if spirit is set up by trying to get the color
    local color = Global.call("getSpiritColor", {name = spiritName})
    if color then
        runSetup()
    else
        -- Keep polling every second
        Wait.time(waitForSetup, 1)
    end
end

function onLoad(saved_data)
    -- Start polling for when spirit is set up
    Wait.time(waitForSetup, 2)
end

-----------------------------------------
-- Panel button creation
-----------------------------------------

function createPanelButtons(panel)
    panel.createButton({
        click_function = "changeSeason",
        function_owner = self,
        label = "Change Season",
        position = {-0.93,0.5,0},
        scale = {x=0.08, y=0.08, z=0.08},
        width = 5000,
        height = 750,
        font_size = 750,
        color = {1,1,1},
        font_color = {0,0,0},
        tooltip = "Left-click: Next Season | Right-click: Previous Season",
    })
end

-----------------------------------------
-- Change Season (button click handler)
-----------------------------------------

function changeSeason(obj, player_color, alt_click)
    if busy then return end
    busy = true

    local color = Global.call("getSpiritColor", {name = spiritName})
    local reverse = alt_click

    local hits = Physics.cast({
        origin = obj.getPosition() + Vector(5,0,-5),
        direction = Vector(0,1,0),
        type = 3,
        size = {6,1,6.5},
        max_distance = 1,
    })

    local innateCard = nil
    for _, hit in pairs(hits) do
        local card = hit.hit_object
        if card and card.hasTag("Innate") then
            innateCard = card
            break
        end
    end

    if innateCard then
        local targetPos = innateCard.getPosition()
        local targetRot = innateCard.getRotation()

        local nextIndex = getNextEmotionIndex(innateCard, reverse)
        local wantTag = EMOTIONS[nextIndex]

        innateCard.deal(1, color, 3)

        local replacement = findInnateWithTagInHand(color, 3, wantTag)
        if replacement then
            replacement.setPosition(targetPos, false)
            replacement.setRotation(targetRot, false)
        end

        setWheelToEmotion(wantTag)
    else
        local replacement = findInnateWithTagInHand(color, 3, "Ire")
        if replacement then
            replacement.setPosition(pos + Vector(13,0.5,-10), false)
        end
    end

    Wait.frames(function()
        busy = false
    end, 20)
end

-----------------------------------------
-- Time Passes handler
-----------------------------------------

function timePasses()
    if not spiritPanel then return end

    local color = Global.call("getSpiritColor", {name = spiritName})
    local hits = Physics.cast({
        origin = spiritPanel.getPosition() + Vector(5,0,-5),
        direction = Vector(0,1,0),
        type = 3,
        size = {6,1,6.5},
        max_distance = 1,
    })

    local innateCard = nil
    for _, hit in pairs(hits) do
        local card = hit.hit_object
        if card and card.hasTag("Innate") then
            innateCard = card
            break
        end
    end

    if innateCard then
        local targetPos = innateCard.getPosition()
        local targetRot = innateCard.getRotation()

        local nextIndex = getNextEmotionIndex(innateCard, false)
        local wantTag = EMOTIONS[nextIndex]

        innateCard.deal(1, color, 3)

        local replacement = findInnateWithTagInHand(color, 3, wantTag)
        if replacement then
            replacement.setPosition(targetPos, false)
            replacement.setRotation(targetRot, false)
        end

        setWheelToEmotion(wantTag)
    else
        local replacement = findInnateWithTagInHand(color, 3, "Ire")
        if replacement then
            replacement.setPosition(pos + Vector(13,0.5,-10), false)
        end
    end
end

-----------------------------------------
-- Cost modification
-----------------------------------------

function modifyCost(params)
    local costs = params.costs
    if params.color == Global.call("getSpiritColor", {name = spiritName}) then
        for guid,_ in pairs(costs) do
            if impendTable[guid] then
                costs[guid] = 0
            end
        end
    end
    return costs
end
