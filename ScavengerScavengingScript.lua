--[[
    Scavenger of Fates - Scavenging Automation Script

    This script lives in an invisible child object attached to the Scavenger of Fates spirit panel.
    It adds a "Scavenge Token" context menu option to Beasts, Badlands, Wilds, and Disease tokens,
    allowing any player to send them to this script object's position on the spirit panel.

    Also registers a hotkey "Scavenge Token" that players can bind in Options > Game Keys.

    Setup: Position this object where you want scavenged tokens to land, then group/lock
    it with the Scavenger of Fates spirit panel.
]]--

-- Configuration
local SCAVENGEABLE_TYPES = {"Beasts", "Badlands", "Wilds", "Disease"}
local MENU_LABEL = "Scavenge Token"
local HOTKEY_LABEL = "Scavenge Token"

-- Transparency settings (0 = invisible, 1 = fully visible)
local LOCKED_ALPHA = 0.1    -- Nearly transparent when flipped or locked
local UNLOCKED_ALPHA = 1.0  -- Fully visible when unlocked (for positioning)

-- Track which objects have been given the context menu
local registeredObjects = {}

--[[
    Update the object's transparency based on locked/flipped state
    Makes it nearly invisible when flipped or locked for cleaner gameplay
]]--
function updateTransparency()
    local color = self.getColorTint()
    if self.is_face_down or self.locked then
        color.a = LOCKED_ALPHA
    else
        color.a = UNLOCKED_ALPHA
    end
    self.setColorTint(color)
end

--[[
    Check if an object is a scavengeable token type
    Uses both name and tag checking for reliability
]]--
function isScavengeable(obj)
    if obj == nil then return false end

    local objName = obj.getName()

    for _, tokenType in ipairs(SCAVENGEABLE_TYPES) do
        -- Check by name
        if objName == tokenType then
            return true
        end
        -- Check by tag as backup
        if obj.hasTag and obj.hasTag(tokenType) then
            return true
        end
    end

    return false
end

--[[
    Move a token to the scavenging area
]]--
function scavengeToken(playerColor, tokenObject)
    if tokenObject == nil then
        return false
    end

    -- Get this script object's position as the target
    local targetPos = self.getPosition()

    -- Add a small random offset to prevent tokens from stacking exactly on top of each other
    local randomOffset = {
        x = (math.random() - 0.5) * 0.5,
        z = (math.random() - 0.5) * 0.5
    }

    targetPos.x = targetPos.x + randomOffset.x
    targetPos.z = targetPos.z + randomOffset.z
    targetPos.y = targetPos.y + 0.5  -- Slightly above to drop onto surface

    -- Move the token smoothly to the scavenging area
    tokenObject.setPositionSmooth(targetPos, false, true)

    -- Provide feedback to the player
    local tokenName = tokenObject.getName()
    broadcastToAll(playerColor .. " scavenged a " .. tokenName .. " token.", {0.8, 0.6, 1})

    return true
end

--[[
    Callback function when "Scavenge Token" is selected from context menu
    Moves the clicked object to this script object's position
]]--
function onScavengeToken(playerColor, position, clickedObject)
    if clickedObject == nil then
        printToColor("Error: No object to scavenge.", playerColor, {1, 0.5, 0})
        return
    end

    scavengeToken(playerColor, clickedObject)
end

--[[
    Hotkey callback - scavenges the object the player is hovering over
]]--
function onScavengeHotkey(playerColor, hoveredObject, pointerPosition, isKeyUp)
    -- Only trigger on key down, not key up
    if isKeyUp then return end

    if hoveredObject == nil then
        printToColor("No object under cursor to scavenge.", playerColor, {1, 0.5, 0})
        return
    end

    if not isScavengeable(hoveredObject) then
        printToColor("This object cannot be scavenged.", playerColor, {1, 0.5, 0})
        return
    end

    scavengeToken(playerColor, hoveredObject)
end

--[[
    Add the scavenge context menu option to a single object
]]--
function addScavengeMenu(obj)
    if obj == nil then return end

    local guid = obj.getGUID()

    -- Skip if already registered
    if registeredObjects[guid] then
        return
    end

    -- Only add to scavengeable token types
    if not isScavengeable(obj) then
        return
    end

    -- Add the context menu item
    obj.addContextMenuItem(MENU_LABEL, onScavengeToken, false)
    registeredObjects[guid] = true
end

--[[
    Scan all objects and add context menus to scavengeable tokens
]]--
function registerAllTokens()
    for _, obj in ipairs(getObjects()) do
        addScavengeMenu(obj)
    end
end

--[[
    Event handler: Called when any object is spawned/created
]]--
function onObjectSpawn(obj)
    -- Small delay to ensure the object is fully initialized
    Wait.time(function()
        addScavengeMenu(obj)
    end, 0.5)
end

--[[
    Event handler: Called when an object is destroyed
    Cleans up our tracking table
]]--
function onObjectDestroy(obj)
    if obj ~= nil then
        local guid = obj.getGUID()
        if guid and registeredObjects[guid] then
            registeredObjects[guid] = nil
        end
    end
end

--[[
    Event handler: Called when this script object loads
]]--
function onLoad(savedData)
    -- Register the scavenge hotkey (players bind it in Options > Game Keys)
    addHotkey(HOTKEY_LABEL, onScavengeHotkey, true)

    -- Check if this is the first time the script has loaded
    local isFirstLoad = (savedData == nil or savedData == "")

    -- Set initial transparency
    updateTransparency()

    -- Periodically check for lock/flip state changes to update transparency
    -- TTS doesn't have onLock/onFlip events, so we poll at a fast interval
    Wait.time(function()
        Timer.create({
            identifier = self.getGUID() .. "_transparency",
            function_name = "updateTransparency",
            function_owner = self,
            delay = 0.1,  -- Fast polling for near-instant response
            repetitions = 0  -- Repeat forever
        })
    end, 0.1)

    -- Small delay to ensure all objects are loaded before scanning
    Wait.time(function()
        registerAllTokens()
        print("[Scavenger Script] Scavenging automation initialized.")
        if isFirstLoad then
            print("[Scavenger Script] Tip: Bind 'Scavenge Token' to Ctrl+Click in Options > Game Keys for quick scavenging.")
        end
    end, 1)
end

--[[
    Event handler: Called when the game is saved
    Saves state so we know the script has been initialized
]]--
function onSave()
    return "initialized"
end
