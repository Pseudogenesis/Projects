--[[
    Scavenger of Fates - Scavenging Automation Script

    This script lives in an invisible child object attached to the Scavenger of Fates spirit panel.
    It adds a "Scavenge Token" context menu option to Beasts, Badlands, Wilds, and Disease tokens,
    allowing any player to send them to the scavenging area on the spirit panel.

    Setup: This script should be placed in a small invisible object that is grouped/locked
    with the Scavenger of Fates spirit panel.
]]--

-- Configuration
local SCAVENGEABLE_TYPES = {"Beasts", "Badlands", "Wilds", "Disease"}
local SPIRIT_PANEL_NAME = "Scavenger of Fates"
local MENU_LABEL = "Scavenge Token"

-- The offset from the spirit panel's center to the upper-left scavenging area
-- These are in local coordinates relative to the panel
-- Adjust these values based on your panel's layout
local SCAVENGE_OFFSET = {
    x = -1.0,   -- Left side of panel (negative X in local space)
    y = 0.3,    -- Slightly above the panel surface
    z = -0.8    -- Upper portion of panel (negative Z in local space)
}

-- Track which objects have been given the context menu
local registeredObjects = {}

-- Reference to the spirit panel (parent object)
local spiritPanel = nil

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
    Find the Scavenger of Fates spirit panel
    First tries to find parent object, then searches all objects
]]--
function findSpiritPanel()
    -- Try to get the parent object (if this script is in a child object)
    local parent = self.getAttachments and self.getAttachments()[1]

    -- Search through all objects for the spirit panel
    for _, obj in ipairs(getObjects()) do
        if obj.getName() == SPIRIT_PANEL_NAME then
            return obj
        end
    end

    -- If we couldn't find it by name, check if our script object is attached to something
    -- In TTS, when objects are grouped, we can try to find the panel differently
    return nil
end

--[[
    Calculate the world position for the scavenging area
    Takes into account the panel's position, rotation, and scale
]]--
function getScavengePosition()
    if spiritPanel == nil then
        spiritPanel = findSpiritPanel()
    end

    if spiritPanel == nil then
        -- Fallback: just use the script object's position with an offset
        local selfPos = self.getPosition()
        return {
            x = selfPos.x + SCAVENGE_OFFSET.x,
            y = selfPos.y + SCAVENGE_OFFSET.y,
            z = selfPos.z + SCAVENGE_OFFSET.z
        }
    end

    local panelPos = spiritPanel.getPosition()
    local panelRot = spiritPanel.getRotation()
    local panelScale = spiritPanel.getScale()

    -- Convert rotation to radians for calculation
    local rotY = math.rad(panelRot.y)

    -- Calculate the offset in world space, accounting for panel rotation
    -- The panel is rotated, so we need to rotate our offset accordingly
    local worldOffsetX = (SCAVENGE_OFFSET.x * math.cos(rotY) - SCAVENGE_OFFSET.z * math.sin(rotY)) * panelScale.x
    local worldOffsetZ = (SCAVENGE_OFFSET.x * math.sin(rotY) + SCAVENGE_OFFSET.z * math.cos(rotY)) * panelScale.z

    return {
        x = panelPos.x + worldOffsetX,
        y = panelPos.y + SCAVENGE_OFFSET.y,
        z = panelPos.z + worldOffsetZ
    }
end

--[[
    Callback function when "Scavenge Token" is selected from context menu
    Moves the clicked object to the scavenging area on the spirit panel
]]--
function onScavengeToken(playerColor, position, clickedObject)
    if clickedObject == nil then
        printToColor("Error: No object to scavenge.", playerColor, {1, 0.5, 0})
        return
    end

    local targetPos = getScavengePosition()

    -- Add a small random offset to prevent tokens from stacking exactly on top of each other
    local randomOffset = {
        x = (math.random() - 0.5) * 0.5,
        z = (math.random() - 0.5) * 0.5
    }

    targetPos.x = targetPos.x + randomOffset.x
    targetPos.z = targetPos.z + randomOffset.z

    -- Move the token smoothly to the scavenging area
    clickedObject.setPositionSmooth(targetPos, false, true)

    -- Optional: Provide feedback to the player
    local tokenName = clickedObject.getName()
    broadcastToAll(playerColor .. " scavenged a " .. tokenName .. " token.", {0.8, 0.6, 1})
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
    -- Find the spirit panel
    spiritPanel = findSpiritPanel()

    if spiritPanel == nil then
        print("[Scavenger Script] Warning: Could not find Scavenger of Fates spirit panel.")
        print("[Scavenger Script] The script will still function, but positioning may be off.")
    else
        print("[Scavenger Script] Found spirit panel: " .. spiritPanel.getName())
    end

    -- Small delay to ensure all objects are loaded before scanning
    Wait.time(function()
        registerAllTokens()
        print("[Scavenger Script] Scavenging automation initialized.")
    end, 1)
end
