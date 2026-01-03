-- ========================================================
-- 🏰 DUNGEON MODULE (DYNAMIC SCANNER)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Tabellen für dynamische Daten
local dungeonNames = {}
local diffNames = {}
local diffMap = {} -- Speichert { ["Easy"] = 1, ["Medium"] = 2 ... }

-- 1. DYNAMISCHER SCANNER (Liest DungeonInfo Modul)
local function RefreshDungeonData()
    local success, Info = pcall(function() 
        return require(RS.Modules:WaitForChild("DungeonInfo", 10)) 
    end)
    
    if success and Info then
        -- Dungeons scannen
        dungeonNames = {}
        for name, _ in pairs(Info.Dungeons) do
            table.insert(dungeonNames, name)
        end
        
        -- Difficulties scannen (Wichtig für Dynamik!)
        diffNames = {}
        diffMap = {}
        for index, diffData in ipairs(Info.Difficulties) do
            local name = diffData.Name
            table.insert(diffNames, name)
            diffMap[name] = index -- Der Index (1, 2, 3...) ist der Wert für den Server
        end
    else
        -- Fallback falls Modul nicht lädt
        dungeonNames = {"Space"}
        diffNames = {"Easy", "Medium", "Hard", "Impossible"}
        diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Impossible"] = 4}
    end
end

RefreshDungeonData()

-- 2. UI: DUNGEON CREATION
Tab:CreateSection("🏰 Create Dungeon Group")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonNames,
    CurrentOption = dungeonNames[1] or "Space",
    Callback = function(opt) _G.Hub.Config.SelectedDungeon = opt end
})

Tab:CreateDropdown({
    Name = "Difficulty",
    Options = diffNames,
    CurrentOption = diffNames[1] or "Easy",
    Callback = function(opt) 
        -- Holt sich die Zahl automatisch aus dem Map-Index
        _G.Hub.Config.SelectedDiffValue = diffMap[opt] or 1
        print("Selected Difficulty Index:", _G.Hub.Config.SelectedDiffValue)
    end
})

Tab:CreateDropdown({
    Name = "Privacy",
    Options = {"Public", "Friends"},
    CurrentOption = "Public",
    Callback = function(opt) _G.Hub.Config.DungeonPrivacy = opt end
})

Tab:CreateButton({
    Name = "🚀 Create Dungeon",
    Callback = function()
        local privacyArg = {
            [1] = _G.Hub.Config.DungeonPrivacy or "Public"
        }
        
        local args = {
            [1] = "DungeonGroupAction",
            [2] = "Create",
            [3] = privacyArg,
            [4] = _G.Hub.Config.SelectedDungeon or "Space",
            [5] = _G.Hub.Config.SelectedDiffValue or 1
        }
        
        RS.Events.UIAction:FireServer(unpack(args))
    end
})

-- 3. UI: AUTO UPGRADES (Inklusive technischer Namen)
Tab:CreateSection("🆙 Dungeon Upgrades")

local upgradeTechnicalNames = {
    ["Health"] = "DungeonHealth",
    ["Damage"] = "DungeonDamage",
    ["Crit Chance"] = "DungeonCritChance",
    ["Incubator Slots"] = "DungeonEggSlots",
    ["Incubator Speed"] = "IncubatorSpeed",
    ["Coins Boost"] = "DungeonCoins",
    ["Crowns Boost"] = "DungeonCrowns"
}

Tab:CreateDropdown({
    Name = "Select Upgrade",
    Options = {"Health", "Damage", "Crit Chance", "Incubator Slots", "Incubator Speed", "Coins Boost", "Crowns Boost"},
    CurrentOption = "Health",
    Callback = function(opt)
        _G.Hub.Config.CurrentUpgradeTech = upgradeTechnicalNames[opt]
    end
})

Tab:CreateToggle({
    Name = "Auto Buy Upgrade",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoDungeonUpgrade = v end
})

-- 4. LOGIK LOOP
task.spawn(function()
    while true do
        task.wait(1)
        if _G.Hub.Toggles.AutoDungeonUpgrade and _G.Hub.Config.CurrentUpgradeTech then
            for i = 1, 10 do
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", _G.Hub.Config.CurrentUpgradeTech, i)
            end
        end
        if _G.Hub.Toggles.AutoIncubator then
            RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
        end
    end
end)
