-- ========================================================
-- 🏰 DUNGEON MODULE (EXACT REMOTE LOGIC)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

local dungeonList = {"Space"} -- Standardwert
local difficultyMap = {
    ["Easy"] = 1,
    ["Medium"] = 2,
    ["Hard"] = 3,
    ["Impossible"] = 4
}

-- 1. DATEN DYNAMISCH LADEN (Dungeon Namen)
local function LoadDungeonNames()
    local success, Info = pcall(function() return require(RS.Modules.DungeonInfo) end)
    if success and Info and Info.Dungeons then
        dungeonList = {}
        for name, _ in pairs(Info.Dungeons) do
            table.insert(dungeonList, name)
        end
    end
end
LoadDungeonNames()

-- 2. UI ELEMENTE
Tab:CreateSection("🏰 Create Dungeon Group")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonList,
    CurrentOption = dungeonList[1],
    Callback = function(opt) _G.Hub.Config.SelectedDungeon = opt end
})

Tab:CreateDropdown({
    Name = "Select Difficulty",
    Options = {"Easy", "Medium", "Hard", "Impossible"},
    CurrentOption = "Easy",
    Callback = function(opt) 
        _G.Hub.Config.SelectedDiffValue = difficultyMap[opt] or 1
    end
})

Tab:CreateDropdown({
    Name = "Privacy Settings",
    Options = {"Public", "Friends"},
    CurrentOption = "Public",
    Callback = function(opt) _G.Hub.Config.DungeonPrivacy = opt end
})

Tab:CreateButton({
    Name = "🚀 Create Dungeon",
    Callback = function()
        -- Logik basierend auf deinen SimpleSpy Logs:
        -- Public muss eine Tabelle sein: {[1] = "Public"}
        -- Friends muss ein einfacher String sein: "Friends"
        
        local privacyArg
        if _G.Hub.Config.DungeonPrivacy == "Public" then
            privacyArg = {[1] = "Public"}
        else
            privacyArg = "Friends"
        end

        local args = {
            [1] = "DungeonGroupAction",
            [2] = "Create",
            [3] = privacyArg,
            [4] = _G.Hub.Config.SelectedDungeon or "Space",
            [5] = _G.Hub.Config.SelectedDiffValue or 1
        }
        
        RS.Events.UIAction:FireServer(unpack(args))
        print("Dungeon erstellt mit Diff:", args[5])
    end
})

-- 3. AUTO UPGRADES SECTION
Tab:CreateSection("🆙 Dungeon Upgrades")

local upgradeDisplayNames = {"Health", "Damage", "Crit Chance", "Incubator Slots", "Incubator Speed", "Coins Boost", "Crowns Boost"}
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
    Options = upgradeDisplayNames,
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
            -- Wir versuchen Tier 1 bis 10 zu kaufen (Server entscheidet, welches bezahlbar ist)
            for i = 1, 10 do
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", _G.Hub.Config.CurrentUpgradeTech, i)
            end
        end
    end
end)
