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
-- 2. GEGNER-SUCHE (DEINE BEWÄHRTE 90° LOGIK)
-- ========================================================
local function GetNextTarget()
    local dId = Player:GetAttribute("DungeonId")
    if not dId then return nil end
    
    local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
    if not dFolder or not dFolder:FindFirstChild("Important") then return nil end
    
    local spawners = {
        "GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", 
        "PurpleEnemySpawner", "PurpleBossEnemySpawner"
    }
    
    for _, folder in pairs(dFolder.Important:GetChildren()) do
        for _, sName in pairs(spawners) do
            if folder.Name == sName then
                for _, bot in pairs(folder:GetChildren()) do
                    local hp = bot:GetAttribute("Health") or (bot:FindFirstChildOfClass("Humanoid") and bot:FindFirstChildOfClass("Humanoid").Health) or 0
                    if hp > 0 then
                        local hrp = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                        if hrp then return hrp end
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
-- 6. DIE STABILEN LOOPS
-- ========================================================

-- 90° ROTATION & POSITION
RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm then
        if not currentTarget or not currentTarget.Parent or (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
            currentTarget = GetNextTarget()
        end
        
        if currentTarget then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            if myHRP then
                local h = _G.Hub.Config.FarmHeight or 10
                local targetPos = currentTarget.Position + Vector3.new(0, h, 0)
                
                -- Die stabile 90 Grad Neigung
                myHRP.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
                myHRP.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- AUTO SWING & UPGRADE (Hintergrund-Loops)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AutoSwing and _G.Hub.Toggles.AutoFarm and currentTarget then
            pcall(function() RS.Events.UIAction:FireServer("Swing") end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1.5)
        if _G.Hub.Toggles.AutoUpgrade then
            pcall(function() RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade) end)
        end
    end
end)

print("✅ Dungeon Master SMART geladen! Alles bereit.")
