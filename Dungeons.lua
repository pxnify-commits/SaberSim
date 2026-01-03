-- ========================================================
-- 🏰 DUNGEON MODULE (ULTIMATE DYNAMIC FIX)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- 1. DYNAMISCHE DATEN HOLEN
local dungeonNames = {}
local diffNames = {}
local diffMap = {}

local function RefreshData()
    local success, Info = pcall(function() return require(RS.Modules:WaitForChild("DungeonInfo", 10)) end)
    if success and Info then
        -- Dungeons laden
        for name, _ in pairs(Info.Dungeons) do table.insert(dungeonNames, name) end
        -- Difficulties dynamisch mappen (Name -> Index)
        for index, data in ipairs(Info.Difficulties) do
            table.insert(diffNames, data.Name)
            diffMap[data.Name] = index
        end
    else
        -- Fallback
        dungeonNames = {"Space"}
        diffNames = {"Easy", "Medium", "Hard", "Impossible"}
        diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Impossible"] = 4}
    end
end
RefreshData()

-- 2. UI: DUNGEON ERSTELLEN
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
        -- Hier wird die Zahl (1, 2, 3...) dynamisch aus der Map geholt
        _G.Hub.Config.SelectedDiffValue = diffMap[opt] or 1
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
        -- DER FIX: Wir senden einen REINEN STRING für [3]
        -- Genau wie in deinem Log: [3] = "Public" oder "Friends"
        local privacyArg = tostring(_G.Hub.Config.DungeonPrivacy or "Public")
        
        local args = {
            [1] = "DungeonGroupAction",
            [2] = "Create",
            [3] = privacyArg, -- Reiner String!
            [4] = tostring(_G.Hub.Config.SelectedDungeon or "Space"),
            [5] = tonumber(_G.Hub.Config.SelectedDiffValue) or 1
        }
        
        RS.Events.UIAction:FireServer(unpack(args))
    end
})

-- 3. UI: AUTO UPGRADES & INCUBATOR
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

Tab:CreateSection("🥚 Incubator")
Tab:CreateToggle({
    Name = "Auto Claim Incubator",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoIncubator = v end
})

-- 4. LOGIK LOOP
task.spawn(function()
    while true do
        task.wait(1)
        -- Auto Upgrades
        if _G.Hub.Toggles.AutoDungeonUpgrade and _G.Hub.Config.CurrentUpgradeTech then
            for i = 1, 10 do
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", _G.Hub.Config.CurrentUpgradeTech, i)
            end
        end
        -- Auto Incubator
        if _G.Hub.Toggles.AutoIncubator then
            RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
        end
    end
end)
