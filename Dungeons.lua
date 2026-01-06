-- ========================================================
-- 🏰 DUNGEON MASTER ULTIMATE (FIXED VERSION)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Globale Tabellen initialisieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local currentTarget = nil
local dungeonNames, diffNames, diffMap = {}, {}, {}
local selDungeon, selDiff = "", ""
local selUpgrade = "DungeonDamage"

local upgradeMapping = {
    ["Damage ⚔️"] = "DungeonDamage",
    ["Health ❤️"] = "DungeonHealth",
    ["Crit Chance 💥"] = "DungeonCritChance",
    ["Coins 💰"] = "DungeonCoins",
    ["Egg Slots 🥚"] = "DungeonEggSlots"
}

-- ========================================================
-- 1. SMARTE DATEN-LOGIK (LÄDT ECHTE DATEN ODER BACKUPS)
-- ========================================================
local function RefreshDungeonData()
    local success, Info = pcall(function() 
        return require(RS.Modules:WaitForChild("DungeonInfo", 2)) 
    end)
    
    if success and Info and Info.Dungeons then
        dungeonNames = {}
        for name, _ in pairs(Info.Dungeons) do 
            table.insert(dungeonNames, name) 
        end
        
        diffNames = {}
        diffMap = {}
        for index, data in ipairs(Info.Difficulties) do
            table.insert(diffNames, data.Name)
            diffMap[data.Name] = index
        end
        print("✅ Dungeon-Daten erfolgreich vom Spiel geladen.")
    else
        warn("⚠️ Spiel-Daten nicht bereit. Nutze Backup-Listen.")
        dungeonNames = {"Error404", "Error405", "Error406", "Error407", "Error505"}
        diffNames = {"Error408", "Error409", "Error410", "Error411"}
        diffMap = {
            ["Error408"] = 1, 
            ["Error409"] = 2, 
            ["Error410"] = 3, 
            ["Error411"] = 4
        }
    end
    
    -- WICHTIG: Stelle sicher, dass Listen nicht leer sind
    if #dungeonNames == 0 then
        dungeonNames = {"No Dungeons Available"}
    end
    if #diffNames == 0 then
        diffNames = {"No Difficulties Available"}
    end
    
    selDungeon = dungeonNames[1] or ""
    selDiff = diffNames[1] or ""
end
RefreshDungeonData()

-- ========================================================
-- 2. VERBESSERTE GEGNER-SUCHE
-- ========================================================
local function GetNextTarget()
    local dId = Player:GetAttribute("DungeonId")
    if not dId then return nil end
    
    local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
    if not dFolder or not dFolder:FindFirstChild("Important") then return nil end
    
    local spawners = {
        "PurpleBossEnemySpawner",
        "PurpleEnemySpawner", 
        "RedEnemySpawner", 
        "BlueEnemySpawner", 
        "GreenEnemySpawner"
    }
    
    for _, sName in pairs(spawners) do
        for _, folder in pairs(dFolder.Important:GetChildren()) do
            if folder.Name == sName then
                for _, bot in pairs(folder:GetChildren()) do
                    local hp = bot:GetAttribute("Health") or 
                              (bot:FindFirstChildOfClass("Humanoid") and 
                               bot:FindFirstChildOfClass("Humanoid").Health) or 0
                    
                    if hp > 0 then
                        local hrp = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                        if hrp then 
                            return hrp 
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- ========================================================
-- 3. UI SECTION: SMART LOBBY
-- ========================================================
Tab:CreateSection("🏛️ Smart Lobby Management")

-- FIX: Sichere Dropdown-Erstellung mit Validierung
pcall(function()
    Tab:CreateDropdown({
        Name = "Select Dungeon", 
        Options = dungeonNames, 
        CurrentOption = dungeonNames[1], 
        Callback = function(v) 
            if type(v) == "table" then
                selDungeon = v[1] or ""
            else
                selDungeon = tostring(v or "")
            end
        end
    })
end)

pcall(function()
    Tab:CreateDropdown({
        Name = "Select Difficulty", 
        Options = diffNames, 
        CurrentOption = diffNames[1], 
        Callback = function(v) 
            if type(v) == "table" then
                selDiff = v[1] or ""
            else
                selDiff = tostring(v or "")
            end
        end
    })
end)

Tab:CreateButton({
    Name = "🔨 Create & Prepare Lobby", 
    Callback = function() 
        local dIndex = diffMap[selDiff] or 1
        print("🚀 Erstelle Lobby: " .. selDungeon .. " | Stufe: " .. tostring(dIndex))
        pcall(function()
            RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", "Public", selDungeon, dIndex)
        end)
    end
})

Tab:CreateButton({
    Name = "▶️ Force Start Dungeon", 
    Callback = function() 
        pcall(function()
            RS.Events.UIAction:FireServer("DungeonGroupAction", "Start")
        end)
    end
})

-- ========================================================
-- 4. UI SECTION: SMART FARMING
-- ========================================================
Tab:CreateSection("⚔️ Dungeon Farming")

Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        currentTarget = nil
        if v then
            print("✅ Autofarm aktiviert - Suche Gegner...")
        else
            print("⏸️ Autofarm deaktiviert")
        end
    end
})

Tab:CreateToggle({
    Name = "Auto Swing", 
    CurrentValue = false, 
    Callback = function(v) _G.Hub.Toggles.AutoSwing = v end
})

-- FIX: Slider mit besserer Fehlerbehandlung - JETZT UNTER AUTO SWING
pcall(function()
    Tab:CreateSlider({
        Name = "Farm Height (Abstand)", 
        Range = {2, 50},
        Increment = 1,
        CurrentValue = _G.Hub.Config.FarmHeight or 10, 
        Callback = function(v) 
            _G.Hub.Config.FarmHeight = tonumber(v) or 10
        end
    })
end)

-- ========================================================
-- 5. UI SECTION: SMART UPGRADES
-- ========================================================
Tab:CreateSection("🆙 Smart Upgrades")

pcall(function()
    Tab:CreateDropdown({
        Name = "Target Upgrade",
        Options = {"Damage ⚔️", "Health ❤️", "Crit Chance 💥", "Coins 💰", "Egg Slots 🥚"},
        CurrentOption = "Damage ⚔️",
        Callback = function(v)
            local display
            if type(v) == "table" then
                display = v[1] or "Damage ⚔️"
            else
                display = tostring(v or "Damage ⚔️")
            end
            selUpgrade = upgradeMapping[display] or "DungeonDamage"
        end
    })
end)

Tab:CreateToggle({
    Name = "Auto Buy Upgrades",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoUpgrade = v end
})

-- ========================================================
-- 6. DEBUG SECTION
-- ========================================================
Tab:CreateSection("🔍 Debug Info")

Tab:CreateButton({
    Name = "Show Current Target", 
    Callback = function()
        if currentTarget and currentTarget.Parent then
            print("🎯 Aktuelles Ziel:", currentTarget.Parent.Name)
            print("   Position:", currentTarget.Position)
        else
            print("❌ Kein Ziel gefunden")
        end
    end
})

Tab:CreateButton({
    Name = "Force Target Refresh", 
    Callback = function()
        currentTarget = nil
        currentTarget = GetNextTarget()
        if currentTarget then
            print("✅ Neues Ziel:", currentTarget.Parent.Name)
        else
            print("⚠️ Keine Gegner verfügbar")
        end
    end
})

-- ========================================================
-- 7. HAUPT-FARMING LOOP (90° ROTATION & POSITION)
-- ========================================================
RunService.RenderStepped:Connect(function()
    if not _G.Hub.Toggles.AutoFarm then return end
    
    pcall(function()
        -- Ziel-Validierung
        if not currentTarget or 
           not currentTarget.Parent or 
           (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
            currentTarget = GetNextTarget()
        end
        
        if currentTarget then
            local char = Player.Character
            if not char then return end
            
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            
            local h = _G.Hub.Config.FarmHeight or 10
            local targetPos = currentTarget.Position + Vector3.new(0, h, 0)
            
            -- 90° Neigung
            myHRP.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end)
end)

-- ========================================================
-- 8. AUTO SWING LOOP
-- ========================================================
task.spawn(function()
    while task.wait(0.1) do
        if _G.Hub.Toggles.AutoSwing and _G.Hub.Toggles.AutoFarm and currentTarget then
            pcall(function() 
                RS.Events.UIAction:FireServer("Swing") 
            end)
        end
    end
end)

-- ========================================================
-- 9. AUTO UPGRADE LOOP
-- ========================================================
task.spawn(function()
    while task.wait(1.5) do
        if _G.Hub.Toggles.AutoUpgrade then
            pcall(function() 
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade) 
            end)
        end
    end
end)

print("✅ Dungeon Master ULTIMATE geladen!")
print("📋 Alle Systeme bereit")
