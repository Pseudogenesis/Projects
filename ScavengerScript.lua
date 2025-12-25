-- Spirit Panel for MJ & iakona's Spirit Island Mod --
-- With Scavenge Token functionality --
useProgression = false
useAspect = 2

local SCAVENGE_TAGS = {"Beasts", "Badlands", "Wilds", "Disease"}
local scavengerPanel = nil  -- Reference to this panel

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
local function addScavengeMenu(obj)
    if not isScavengeTarget(obj) then return end

    obj.addContextMenuItem("Scavenge Token", function(playerColor)
        if scavengerPanel then
            -- Convert local position to world position
            -- Upper left area of the panel (in local coords)
            local targetPos = scavengerPanel.positionToWorld({-0.8, 0.3, 0.7})
            obj.setPositionSmooth(targetPos, false, false)
        end
    end, false)  -- false = don't keep menu open after clicking
end

-- Add context menu to all existing valid tokens
local function setupScavengeMenus()
    for _, obj in ipairs(getAllObjects()) do
        addScavengeMenu(obj)
    end
end

-----------------------------------------
-- TTS Event Handlers
-----------------------------------------

function onLoad(saved_data)
    Color.Add("SoftBlue", Color.new(0.53,0.92,1))
    Color.Add("SoftYellow", Color.new(1,0.8,0.5))
    getObjectFromGUID("SourceSpirit").call("load", {obj = self, saved_data = saved_data})

    scavengerPanel = self

    -- Setup menus after a short delay to ensure all objects are loaded
    Wait.frames(setupScavengeMenus, 60)
end

-----------------------------------------
-- Setup function (called by mod framework when spirit is picked)
-----------------------------------------

function doSetup(params)
    -- Re-run menu setup after spirit is picked, in case tokens spawned during setup
    Wait.frames(setupScavengeMenus, 30)
    return true
end

-----------------------------------------
-- Handle newly spawned objects (Global event)
-----------------------------------------

function onObjectSpawn(obj)
    -- Small delay to ensure object is fully initialized
    Wait.frames(function()
        addScavengeMenu(obj)
    end, 10)
end
