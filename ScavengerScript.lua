-- Spirit Panel for MJ & iakona's Spirit Island Mod --
-- With Scavenge Token functionality --
useProgression = false
useAspect = 2

local SCAVENGE_TAGS = {"Beasts", "Badlands", "Wilds", "Disease"}
local menuAddedTo = {}  -- Track GUIDs we've already added menus to

-----------------------------------------
-- Helper functions
-----------------------------------------

-- Check if an object is a valid scavenge target
local function isScavengeTarget(obj)
    if not obj then return false end
    for _, tag in ipairs(SCAVENGE_TAGS) do
        if obj.hasTag(tag) then
            return true
        end
    end
    return false
end

-- Add context menu to a token
local function addScavengeMenu(obj, panel)
    if not obj or not isScavengeTarget(obj) then return end

    -- Prevent duplicates by tracking GUIDs
    local guid = obj.getGUID()
    if menuAddedTo[guid] then return end
    menuAddedTo[guid] = true

    -- Capture panel reference in closure
    obj.addContextMenuItem("Scavenge Token", function(playerColor)
        if panel and panel.getPosition then
            -- Convert local position to world position
            -- Upper left area of the panel (in local coords)
            local targetPos = panel.positionToWorld({-0.8, 0.3, 0.7})
            obj.setPositionSmooth(targetPos, false, false)
        end
    end, false)  -- false = don't keep menu open after clicking
end

-- Add context menu to all existing valid tokens
local function setupScavengeMenus(panel)
    for _, obj in ipairs(getAllObjects()) do
        addScavengeMenu(obj, panel)
    end
end

-----------------------------------------
-- TTS Event Handlers
-----------------------------------------

function onLoad(saved_data)
    Color.Add("SoftBlue", Color.new(0.53,0.92,1))
    Color.Add("SoftYellow", Color.new(1,0.8,0.5))
    getObjectFromGUID("SourceSpirit").call("load", {obj = self, saved_data = saved_data})

    -- Setup menus after a delay, passing self as the panel reference
    local panel = self
    Wait.frames(function()
        setupScavengeMenus(panel)
    end, 60)
end

-----------------------------------------
-- Setup function (called by mod framework when spirit is picked)
-----------------------------------------

function doSetup(params)
    -- Re-run menu setup after spirit is picked
    local panel = self
    Wait.frames(function()
        setupScavengeMenus(panel)
    end, 30)
    return true
end

-----------------------------------------
-- Handle newly spawned objects
-----------------------------------------

function onObjectSpawn(obj)
    local panel = self
    Wait.frames(function()
        if obj then
            addScavengeMenu(obj, panel)
        end
    end, 10)
end
