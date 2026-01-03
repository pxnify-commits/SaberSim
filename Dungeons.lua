-- ========================================================
-- 🏰 DUNGEON MODULE (FORCED UI-TEXT EXTRACTION)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

local dungeonNames = {"Space"}
local diffNames = {"Easy", "Medium", "Hard", "Impossible"}
local diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Impossible"] = 4}

-- 1. DYNAMISCHE DATEN (Falls Modul verfügbar)
local function RefreshData()
    local success, Info = pcall(function() return require(RS.Modules:WaitForChild("DungeonInfo", 5)) end)
    if success and Info then
        dungeonNames = {}
        for name, _ in pairs(Info.Dungeons) do table.insert(dungeonNames, name) end
        diffNames = {}
        diffMap = {}
        for index, data in ipairs(Info.Difficulties) do
            table.insert(diffNames, data.Name)
            diffMap[data.Name] = index
        end
    end
end
RefreshData()

-- 2. UI DROPDOWNS (Werte werden in lokalen Variablen gehalten um Config-Tables zu umgehen)
local selDungeon = "Space"
local selDiff = "Easy"
local selPrivacy = "Public"

Tab:CreateSection("🏰 Create Dungeon Group")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonNames,
    CurrentOption = "Space",
    Callback = function(opt) 
        selDungeon = type(opt) == "table" and opt[1] or tostring(opt)
    end
})

Tab:CreateDropdown({
    Name = "Difficulty",
    Options = diffNames,
    CurrentOption = "Easy",
    Callback = function(opt) 
        selDiff = type(opt) == "table" and opt[1] or tostring(opt)
    end
})

Tab:CreateDropdown({
    Name = "Privacy",
    Options = {"Public", "Friends"},
    CurrentOption = "Public",
    Callback = function(opt) 
        -- Wir speichern den Wert direkt in einer lokalen Variable statt in der Config-Table
        selPrivacy = type(opt) == "table" and opt[1] or tostring(opt)
    end
})

Tab:CreateButton({
    Name = "🚀 Create Dungeon",
    Callback = function()
        -- Wir säubern die Variablen vor dem Senden extrem gründlich
        local cleanPrivacy = tostring(selPrivacy)
        local cleanDungeon = tostring(selDungeon)
        local diffIndex = tonumber(diffMap[selDiff]) or 1

        -- Sicherheits-Check gegen Speicheradressen:
        -- Wenn der String "table:" enthält, setzen wir einen Default
        if cleanPrivacy:find("table:") then cleanPrivacy = "Public" end
        if cleanDungeon:find("table:") then cleanDungeon = "Space" end

        local args = {
            [1] = "DungeonGroupAction",
            [2] = "Create",
            [3] = cleanPrivacy, -- GARANTIERT STRING
            [4] = cleanDungeon, -- GARANTIERT STRING
            [5] = diffIndex    -- GARANTIERT ZAHL
        }
        
        RS.Events.UIAction:FireServer(unpack(args))
        
        -- Benachrichtigung zur Kontrolle
        Rayfield:Notify({
            Title = "Dungeon gestartet",
            Content = "Modus: " .. cleanPrivacy .. " | Diff: " .. tostring(diffIndex),
            Duration = 3
        })
    end
})

-- 3. UPGRADES & INCUBATOR
Tab:CreateSection("🆙 Upgrades & Incubator")

local selUpgrade = "DungeonHealth"
local upgradeMap = {
    ["Health"] = "DungeonHealth", ["Damage"] = "DungeonDamage",
    ["Crit Chance"] = "DungeonCritChance", ["Incubator Slots"] = "DungeonEggSlots",
    ["Incubator Speed"] = "IncubatorSpeed", ["Coins Boost"] = "DungeonCoins",
    ["Crowns Boost"] = "DungeonCrowns"
}

Tab:CreateDropdown({
    Name = "Select Upgrade",
    Options = {"Health", "Damage", "Crit Chance", "Incubator Slots", "Incubator Speed", "Coins Boost", "Crowns Boost"},
    CurrentOption = "Health",
    Callback = function(opt)
        local val = type(opt) == "table" and opt[1] or tostring(opt)
        selUpgrade = upgradeMap[val] or "DungeonHealth"
    end
})

Tab:CreateToggle({
    Name = "Auto Buy Upgrade",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoDungeonUpgrade = v end
})

Tab:CreateToggle({
    Name = "Auto Claim Incubator",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoIncubator = v end
})

-- 4. LOOP
task.spawn(function()
    while true do
        task.wait(1)
        if _G.Hub.Toggles.AutoDungeonUpgrade and selUpgrade then
            for i = 1, 10 do
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade, i)
            end
        end
        if _G.Hub.Toggles.AutoIncubator then
            RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
        end
    end
end)
