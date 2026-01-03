-- ========================================================
-- 🏰 DUNGEON & UPGRADE MODULE
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Daten-Listen
local dungeonList = {}
local difficultyNames = {}
local upgradeNames = {}
local upgradeMap = {} -- Verknüpft DisplayName mit technischem Namen

-- 1. DATEN DYNAMISCH LADEN
local function LoadDungeonData()
    local success, Info = pcall(function() return require(RS.Modules.DungeonInfo) end)
    if success and Info then
        -- Dungeons laden
        for name, data in pairs(Info.Dungeons) do
            table.insert(dungeonList, data.DisplayName or name)
        end
        -- Schwierigkeiten laden
        for i, diff in ipairs(Info.Difficulties) do
            table.insert(difficultyNames, diff.Name)
        end
    end

    local success2, UpgInfo = pcall(function() return require(RS.Modules.DungeonUpgradeShop) end)
    if success2 and UpgInfo then
        for _, techName in ipairs(UpgInfo.UpgradeTypes) do
            local data = UpgInfo[techName]
            if data then
                table.insert(upgradeNames, data.DisplayName)
                upgradeMap[data.DisplayName] = techName
            end
        end
    end
end

LoadDungeonData()

-- 2. UI: DUNGEON CREATION
Tab:CreateSection("🏰 Create Dungeon Group")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonList,
    CurrentOption = dungeonList[1] or "Space",
    Callback = function(opt) _G.Hub.Config.SelectedDungeon = opt end
})

Tab:CreateDropdown({
    Name = "Difficulty",
    Options = difficultyNames,
    CurrentOption = "Easy",
    Callback = function(opt) 
        -- Findet den Index (1 für Easy, 2 für Medium etc.)
        for i, v in ipairs(difficultyNames) do
            if v == opt then _G.Hub.Config.SelectedDiffIndex = i break end
        end
    end
})

Tab:CreateDropdown({
    Name = "Privacy",
    Options = {"Public", "Friends"},
    CurrentOption = "Public",
    Callback = function(opt) _G.Hub.Config.DungeonPrivacy = opt end
})

Tab:CreateButton({
    Name = "🚀 Create / Start Dungeon",
    Callback = function()
        local args = {
            [1] = "DungeonGroupAction",
            [2] = "Create",
            [3] = _G.Hub.Config.DungeonPrivacy or "Public",
            [4] = _G.Hub.Config.SelectedDungeon or "Space",
            [5] = _G.Hub.Config.SelectedDiffIndex or 1
        }
        RS.Events.UIAction:FireServer(unpack(args))
    end
})

-- 3. UI: AUTO UPGRADES
Tab:CreateSection("🆙 Auto Upgrades")

Tab:CreateDropdown({
    Name = "Select Upgrade to Buy",
    Options = upgradeNames,
    CurrentOption = upgradeNames[1],
    Callback = function(opt) _G.Hub.Config.SelectedUpgrade = upgradeMap[opt] end
})

Tab:CreateToggle({
    Name = "Auto Buy Upgrades",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoDungeonUpgrade = v end
})

-- 4. UI: INCUBATOR
Tab:CreateSection("🥚 Incubator")

Tab:CreateButton({
    Name = "Claim All Finished Eggs",
    Callback = function()
        RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
    end
})

Tab:CreateToggle({
    Name = "Auto Claim Eggs",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoIncubator = v end
})

-- 5. LOGIK LOOP
task.spawn(function()
    while true do
        task.wait(1)
        
        -- Auto Upgrade Logik
        if _G.Hub.Toggles.AutoDungeonUpgrade and _G.Hub.Config.SelectedUpgrade then
            pcall(function()
                -- Da wir nicht genau wissen, welches Level du bist, 
                -- versuchen wir nacheinander Upgrades zu kaufen (Server blockt wenn zu teuer)
                -- Wir senden einfach ein hohes Tier, das Spiel kauft meist das nächste verfügbare
                for i = 1, 10 do
                    RS.Events.UIAction:FireServer("BuyDungeonUpgrade", _G.Hub.Config.SelectedUpgrade, i)
                    task.wait(0.1)
                end
            end)
        end

        -- Auto Incubator Logik
        if _G.Hub.Toggles.AutoIncubator then
            pcall(function()
                RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
            end)
        end
    end
end)
