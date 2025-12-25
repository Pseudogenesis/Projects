spiritName = "Tempers of the Ever-Changing Skies"

local impendTable = {}
local pos
local EMOTIONS = {"Sorrow", "Ire", "Joy", "Calm"}
local seasonWheel = nil
local activated = false


function doSetup(params)
    local color = params.color
    local panel = params.spiritPanel
    self.locked = true
    local position = panel.getPosition() + Vector(-8.2,-0.22,6.8)
    pos = position
    self.setPosition(position)

    -- Find the Season Wheel object by searching for it on the table
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

    local hand = Player[color].getHandObjects(1)
    Wait.frames(function()
        if hand ~= {} then
            for _,card in pairs(hand) do
                if card.hasTag("Innate") then
                    card.deal(1, color, 3)
                end
            end
        end
    end, 1)

    createPanelButtons(panel)

    return true
end

-----------------------------------------
-- buttons and functions for spirit panel
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

local function getEmotionIndex(card)
    for i, tag in ipairs(EMOTIONS) do
        if card.hasTag(tag) then return i end
    end
    return 1 -- default to Sorrow if none
end

local function getNextEmotionTag(card, reverse)
    local i = getEmotionIndex(card)
    if reverse then
        -- Go backwards: 1->4, 2->1, 3->2, 4->3
        return EMOTIONS[((i - 2) % #EMOTIONS) + 1]
    else
        -- Go forwards: 1->2, 2->3, 3->4, 4->1
        return EMOTIONS[(i % #EMOTIONS) + 1]
    end
end

local function cycleSeasonWheel(reverse)
    if not seasonWheel then return end

    local currentState = seasonWheel.getStateId()
    if currentState == -1 then return end -- No states

    -- getStates() returns all states EXCEPT the current one, so total = #getStates + 1
    local states = seasonWheel.getStates()
    if not states then return end
    local numStates = #states + 1

    local nextState
    if reverse then
        -- Go backwards: 1->4, 2->1, 3->2, 4->3
        nextState = ((currentState - 2) % numStates) + 1
    else
        -- Go forwards: 1->2, 2->3, 3->4, 4->1
        nextState = (currentState % numStates) + 1
    end

    -- setState returns new object reference; update our reference
    if nextState ~= currentState then
        seasonWheel = seasonWheel.setState(nextState)
    end
end

local function findInnateWithTagInHand(color, handIndex, tagName)
    local hand = Player[color].getHandObjects(handIndex)
    for _, obj in ipairs(hand) do
        if obj.hasTag("Innate") and obj.hasTag(tagName) then
            return obj
        end
    end
    return nil
end

function changeSeason(obj, player_color, alt_click)
    -- Hide this script object after first activation
    if not activated then
        activated = true
        self.setInvisibleTo(Player.getColors())
    end

    local color = Global.call("getSpiritColor", {name = spiritName})
    local reverse = alt_click -- true for right-click (go backwards)

    local hits = Physics.cast({
        origin = obj.getPosition() + Vector(5,0,-5),
        direction = Vector(0,1,0),
        type = 3,
        size = {6,1,6.5},
        max_distance = 1,
        -- debug = true
    })

    for _, hit in pairs(hits) do
        local card = hit.hit_object
        if card and card.hasTag("Innate") then
            local targetPos = card.getPosition()
            local targetRot = card.getRotation()

            local wantTag = getNextEmotionTag(card, reverse)

            -- Move the current one to hand 3
            card.deal(1, color, 3)

            -- After it lands in hand 3, pull the next emotion from hand 3 back to the panel
            local replacement = findInnateWithTagInHand(color, 3, wantTag)
            if replacement then
                replacement.setPosition(targetPos, false)
                replacement.setRotation(targetRot, false)
            end

            -- Cycle the Season Wheel to match
            cycleSeasonWheel(reverse)

            break -- only process one innate card
        else
            local replacement = findInnateWithTagInHand(color, 3, "Sorrow")
            if replacement then
                replacement.setPosition(pos + Vector(13,0.5,-10), false)
            end
        end
    end
end

function timePasses()
    local color = Global.call("getSpiritColor", {name = spiritName})
    local hits = Physics.cast({
        origin = obj.getPosition() + Vector(5,0,-5),
        direction = Vector(0,1,0),
        type = 3,
        size = {6,1,6.5},
        max_distance = 1,
        -- debug = true
    })

    for _, hit in pairs(hits) do
        local card = hit.hit_object
        if card and card.hasTag("Innate") then
            local targetPos = card.getPosition()
            local targetRot = card.getRotation()

            local wantTag = getNextEmotionTag(card, false)

            -- Move the current one to hand 3
            card.deal(1, color, 3)

            -- After it lands in hand 3, pull the next emotion from hand 3 back to the panel
            local replacement = findInnateWithTagInHand(color, 3, wantTag)
            if replacement then
                replacement.setPosition(targetPos, false)
                replacement.setRotation(targetRot, false)
            end

            -- Cycle the Season Wheel to match
            cycleSeasonWheel(false)

            break -- only process one innate card
        else
            local replacement = findInnateWithTagInHand(color, 3, "Sorrow")
            if replacement then
                replacement.setPosition(pos + Vector(13,0.5,-10), false)
            end
        end
    end
end

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
