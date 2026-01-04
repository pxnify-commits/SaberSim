-- ========================================================
-- 🏰 DUNGEON MASTER ULTIMATE (SMART LOGIC INTEGRATION)
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
    -- Versuch, die echten Daten vom Spiel-Modul zu ziehen
    local success, Info = pcall(function() 
        return require(RS.Modules:WaitForChild("DungeonInfo", 2)) 
    end)
    
    if success and Info and Info.Dungeons then
        dungeonNames = {}
        for name, _ in pairs(Info.Dungeons) do table.insert(dungeonNames, name) end
        
        diffNames = {}
        diffMap = {}
        for index, data in ipairs(Info.Difficulties) do
            table.insert(diffNames, data.Name)
            diffMap[data.Name] = index
        end
        print("✅ Dungeon-Daten erfolgreich vom Spiel geladen.")
    else
        -- DEINE SMARTEN ERROR-BACKUPS
        warn("⚠️ Spiel-Daten nicht bereit. Nutze Backup-Listen.")
        dungeonNames = {"Error404", "Error405", "Error406", "Error407", "Error505"}
        diffNames = {"Error408", "Error409", "Error410", "Error411"}
        diffMap = {
            ["Error408"] = 1, ["Error409"] = 2, ["Error410"] = 3, ["Error411"] = 4
        }
    end
    selDungeon = dungeonNames[1]
    selDiff = diffNames[1]
end
RefreshDungeonData()

-- ========================================================
-- 2. VERBESSERTE GEGNER-SUCHE (PRIORISIERT SPAWNER-REIHENFOLGE)
-- ========================================================
local function GetNextTarget()
    local dId = Player:GetAttribute("DungeonId")
    if not dId then return nil end
    
    local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
    if not dFolder or not dFolder:FindFirstChild("Important") then return nil end
    
    -- Spawner-Priorität: Boss > Purple > Red > Blue > Green
    local spawners = {
        "PurpleBossEnemySpawner",
        "PurpleEnemySpawner", 
        "RedEnemySpawner", 
        "BlueEnemySpawner", 
        "GreenEnemySpawner"
    }
    
    -- Durchsuche alle Spawner in Prioritätsreihenfolge
    for _, sName in pairs(spawners) do
        for _, folder in pairs(dFolder.Important:GetChildren()) do
            if folder.Name == sName then
                for _, bot in pairs(folder:GetChildren()) do
                    -- Prüft Attribut "Health" oder Humanoid.Health
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

Tab:CreateDropdown({
    Name = "Select Dungeon", 
    Options = dungeonNames, 
    CurrentOption = selDungeon, 
    Callback = function(v) selDungeon = (type(v) == "table" and v[1]) or tostring(v) end
})

Tab:CreateDropdown({
    Name = "Select Difficulty", 
    Options = diffNames, 
    CurrentOption = selDiff, 
    Callback = function(v) selDiff = (type(v) == "table" and v[1]) or tostring(v) end
})

Tab:CreateButton({
    Name = "🔨 Create & Prepare Lobby", 
    Callback = function() 
        local dIndex = diffMap[selDiff] or 1
        print("🚀 Erstelle Lobby: " .. selDungeon .. " | Stufe: " .. tostring(dIndex))
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", "Public", selDungeon, dIndex) 
    end
})

Tab:CreateButton({
    Name = "▶️ Force Start Dungeon", 
    Callback = function() 
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Start") 
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

Tab:CreateSlider({
    Name = "Farm Height (Abstand)", 
    Min = 2, Max = 50, CurrentValue = _G.Hub.Config.FarmHeight, 
    Callback = function(v) _G.Hub.Config.FarmHeight = tonumber(v) end
})

Tab:CreateToggle({
    Name = "Auto Swing", 
    CurrentValue = false, 
    Callback = function(v) _G.Hub.Toggles.AutoSwing = v end
})

-- ========================================================
-- 5. UI SECTION: SMART UPGRADES
-- ========================================================
Tab:CreateSection("🆙 Smart Upgrades")

Tab:CreateDropdown({
    Name = "Target Upgrade",
    Options = {"Damage ⚔️", "Health ❤️", "Crit Chance 💥", "Coins 💰", "Egg Slots 🥚"},
    CurrentOption = "Damage ⚔️",
    Callback = function(v)
        local display = (type(v) == "table" and v[1]) or tostring(v)
        selUpgrade = upgradeMapping[display] or "DungeonDamage"
    end
})

Tab:CreateToggle({
    Name = "Auto Buy Upgrades",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoUpgrade = v end
})

-- ========================================================
-- 6. DEBUG SECTION (Optional für Troubleshooting)
-- ========================================================
Tab:CreateSection("🔍 Debug Info")

Tab:CreateButton({
    Name = "Show Current Target", 
    Callback = function()
        if currentTarget then
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
    if _G.Hub.Toggles.AutoFarm then
        -- Ziel-Validierung und Refresh
        if not currentTarget or 
           not currentTarget.Parent or 
           (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
            currentTarget = GetNextTarget()
        end
        
        if currentTarget then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            if myHRP then
                local h = _G.Hub.Config.FarmHeight or 10
                local targetPos = currentTarget.Position + Vector3.new(0, h, 0)
                
                -- 90° Neigung für optimale Treffergenauigkeit
                myHRP.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
                
                -- Verhindert Fallen/Driften
                myHRP.Velocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- ========================================================
-- 8. AUTO SWING LOOP (Hintergrund)
-- ========================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AutoSwing and _G.Hub.Toggles.AutoFarm and currentTarget then
            pcall(function() 
                RS.Events.UIAction:FireServer("Swing") 
            end)
        end
    end
end)

-- ========================================================
-- 9. AUTO UPGRADE LOOP (Hintergrund)
-- ========================================================
task.spawn(function()
    while true do
        task.wait(1.5)
        if _G.Hub.Toggles.AutoUpgrade then
            pcall(function() 
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade) 
            end)
        end
    end
end)

print("✅ Dungeon Master ULTIMATE geladen!")
print("📋 Features:")
print("   • Smart Lobby Creation")
print("   • 90° Auto-Target Farming")
print("   • Auto Swing System")
print("   • Auto Upgrade System")
print("   • Debug Tools")
