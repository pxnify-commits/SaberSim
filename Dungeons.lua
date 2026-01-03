-- ========================================================
-- 🏰 DUNGEON MODULE (FINAL CLEAN VERSION)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")

-- Lokale Speicher für die Auswahl (verhindert Table-Adressen Fehler)
local selDungeon = "Space"
local selDiff = "Easy"
local selPrivacy = "Public"

local dungeonNames = {"Space"}
local diffNames = {"Easy", "Medium", "Hard", "Impossible"}
local diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Impossible"] = 4}

-- 1. DYNAMISCHE DATEN LADEN
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

-- 2. UI DROPDOWNS
Tab:CreateSection("🏰 Create Dungeon Group")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonNames,
    CurrentOption = "Space",
    Callback = function(opt) 
        -- Extrahiert Text, egal ob Rayfield eine Tabelle oder einen String liefert
        selDungeon = (type(opt) == "table" and opt[1]) or tostring(opt)
    end
})

Tab:CreateDropdown({
    Name = "Difficulty",
    Options = diffNames,
    CurrentOption = "Easy",
    Callback = function(opt) 
        selDiff = (type(opt) == "table" and opt[1]) or tostring(opt)
    end
})

Tab:CreateDropdown({
    Name = "Privacy",
    Options = {"Public", "Friends"},
    CurrentOption = "Public",
    Callback = function(opt) 
        selPrivacy = (type(opt) == "table" and opt[1]) or tostring(opt)
    end
})

Tab:CreateButton({
    Name = "🚀 Create Dungeon",
    Callback = function()
        -- Wir erzwingen hier die sauberen Werte
        local pArg = tostring(selPrivacy)
        local dArg = tostring(selDungeon)
        local dNum = tonumber(diffMap[selDiff]) or 1

        -- Letzter Check gegen "table: 0x..."
        if pArg:find("table:") then pArg = "Public" end
        if dArg:find("table:") then dArg = "Space" end

        -- Remote feuern (Exakt wie dein SimpleSpy Beispiel)
        local args = {
            [1] = "DungeonGroupAction",
            [2] = "Create",
            [3] = pArg,   -- String: "Public" oder "Friends"
            [4] = dArg,   -- String: z.B. "Space"
            [5] = dNum    -- Zahl: 1, 2, 3 oder 4
        }
        
        RS.Events.UIAction:FireServer(unpack(args))
        print("Dungeon Create fired!")
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
        local val = (type(opt) == "table" and opt[1]) or tostring(opt)
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

-- 4. LOOP (Upgrades & Incubator)
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
