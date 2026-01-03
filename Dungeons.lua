-- ========================================================
-- 🏰 DUNGEON MODULE (FORCED STRING LOGIC)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

local dungeonNames = {}
local diffNames = {}
local diffMap = {}

-- 1. DYNAMISCHE DATEN LADEN
local function RefreshData()
    local success, Info = pcall(function() return require(RS.Modules:WaitForChild("DungeonInfo", 10)) end)
    if success and Info then
        for name, _ in pairs(Info.Dungeons) do table.insert(dungeonNames, name) end
        for index, data in ipairs(Info.Difficulties) do
            table.insert(diffNames, data.Name)
            diffMap[data.Name] = index
        end
    else
        dungeonNames = {"Space"}
        diffNames = {"Easy", "Medium", "Hard", "Impossible"}
        diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Impossible"] = 4}
    end
end
RefreshData()

-- 2. UI ELEMENTE
Tab:CreateSection("🏰 Create Dungeon Group")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonNames,
    CurrentOption = dungeonNames[1] or "Space",
    Callback = function(opt) 
        -- Extraktion des Strings falls opt eine Tabelle ist
        local val = type(opt) == "table" and opt[1] or opt
        _G.Hub.Config.SelectedDungeon = tostring(val)
    end
})

Tab:CreateDropdown({
    Name = "Difficulty",
    Options = diffNames,
    CurrentOption = diffNames[1] or "Easy",
    Callback = function(opt) 
        local val = type(opt) == "table" and opt[1] or opt
        _G.Hub.Config.SelectedDiffValue = diffMap[tostring(val)] or 1
    end
})

Tab:CreateDropdown({
    Name = "Privacy",
    Options = {"Public", "Friends"},
    CurrentOption = "Public",
    Callback = function(opt) 
        -- WICHTIG: Hier speichern wir nur den reinen Text
        local val = type(opt) == "table" and opt[1] or opt
        _G.Hub.Config.DungeonPrivacy = tostring(val)
    end
})

Tab:CreateButton({
    Name = "🚀 Create Dungeon",
    Callback = function()
        -- RADIKALER FIX: Wir prüfen den Wert manuell vor dem Senden
        local finalPrivacy = "Public"
        if _G.Hub.Config.DungeonPrivacy == "Friends" or _G.Hub.Config.DungeonPrivacy == "table: " then
             finalPrivacy = "Friends"
        elseif _G.Hub.Config.DungeonPrivacy == "Public" then
             finalPrivacy = "Public"
        end
        
        -- Falls die Library immer noch Müll liefert, nehmen wir den Wert direkt aus der Auswahl
        -- Wir erzwingen hier die exakte Schreibweise
        local args = {
            [1] = "DungeonGroupAction",
            [2] = "Create",
            [3] = tostring(finalPrivacy), -- GARANTIERT EIN STRING
            [4] = tostring(_G.Hub.Config.SelectedDungeon or "Space"),
            [5] = tonumber(_G.Hub.Config.SelectedDiffValue) or 1
        }
        
        RS.Events.UIAction:FireServer(unpack(args))
        print("Fired Dungeon Action with Privacy: " .. args[3])
    end
})

-- 3. UPGRADES & INCUBATOR
Tab:CreateSection("🆙 Upgrades & Incubator")

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
        local val = type(opt) == "table" and opt[1] or opt
        _G.Hub.Config.CurrentUpgradeTech = upgradeMap[tostring(val)]
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
