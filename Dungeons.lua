-- ========================================================
-- 🏰 DUNGEON AUTOFARM (COMPLETE VERSION)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local selUpgrade = "DungeonHealth"
local debugTimer = 0

-- ========================================================
-- UI ELEMENTS
-- ========================================================

Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        print("----------------------------------")
        print("🔘 Autofarm Toggle: " .. tostring(v))
    end
})

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoSwing = v
        print("🗡️ Auto Swing: " .. tostring(v))
    end
})

Tab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoUpgrade = v
        print("⬆️ Auto Upgrade: " .. tostring(v))
    end
})

Tab:CreateDropdown({
    Name = "Select Upgrade",
    Options = {"DungeonHealth", "DungeonDamage", "DungeonSpeed"},
    CurrentOption = selUpgrade,
    Callback = function(v)
        selUpgrade = v
        print("📋 Upgrade ausgewählt: " .. v)
    end
})

Tab:CreateSlider({
    Name = "Farm Height",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = _G.Hub.Config.FarmHeight,
    Callback = function(v)
        _G.Hub.Config.FarmHeight = v
        print("📏 Farm Height: " .. v)
    end
})

-- ========================================================
-- HELPER FUNCTION: Find Living Enemy
-- ========================================================

local function findLivingEnemy(dungeonFolder)
    local important = dungeonFolder:FindFirstChild("Important")
    if not important then return nil end
    
    -- Liste aller Spawner-Namen
    local spawnerNames = {
        "GreenEnemySpawner",
        "BlueEnemySpawner", 
        "RedEnemySpawner",
        "PurpleEnemySpawner",
        "PurpleBossEnemySpawner"
    }
    
    -- Durchsuche alle Spawner
    for _, spawnerName in pairs(spawnerNames) do
        -- Es können mehrere Spawner mit gleichem Namen existieren
        for _, child in pairs(important:GetChildren()) do
            if child.Name == spawnerName then
                -- Suche nach Bots in diesem Spawner
                for _, bot in pairs(child:GetChildren()) do
                    if bot:IsA("Model") then
                        local hp = bot:GetAttribute("Health")
                        if hp and hp > 0 then
                            local targetPart = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                            if targetPart then
                                return targetPart, bot.Name, hp, spawnerName
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- ========================================================
-- MAIN AUTOFARM LOOP WITH DIAGNOSTICS
-- ========================================================

task.spawn(function()
    print("🚀 Dungeon Autofarm System gestartet. Warte auf Toggle...")
    
    while task.wait(0.1) do
        if _G.Hub.Toggles.AutoFarm then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            -- === DIAGNOSTIC OUTPUT (alle 3 Sekunden) ===
            if tick() - debugTimer > 3 then
                print("--- [🔍 DIAGNOSE START] ---")
                
                -- Step 1: Character Check
                if not char then 
                    warn("❌ Fehler: Charakter nicht gefunden!") 
                elseif not myHRP then 
                    warn("❌ Fehler: HumanoidRootPart fehlt!")
                else 
                    print("✅ Charakter-Check: OK") 
                end
                
                -- Step 2: DungeonId Check
                local dId = Player:GetAttribute("DungeonId")
                if not dId then 
                    warn("❌ Fehler: Keine DungeonId! Bist du im Dungeon?")
                else 
                    print("✅ DungeonId: " .. tostring(dId)) 
                    
                    -- Step 3: DungeonStorage Check
                    local ds = WS:FindFirstChild("DungeonStorage")
                    if not ds then 
                        warn("❌ Fehler: Workspace.DungeonStorage existiert nicht!")
                    else
                        print("✅ DungeonStorage gefunden")
                        
                        -- Step 4: Dungeon Folder Check
                        local dFolder = ds:FindFirstChild(tostring(dId))
                        if not dFolder then
                            warn("❌ Fehler: Ordner '" .. tostring(dId) .. "' nicht gefunden!")
                            print("ℹ️ Verfügbare Ordner:")
                            for _, child in pairs(ds:GetChildren()) do 
                                print("   -> " .. child.Name) 
                            end
                        else
                            print("✅ Dungeon-Ordner gefunden")
                            
                            -- Step 5: Important Folder Check
                            local important = dFolder:FindFirstChild("Important")
                            if not important then
                                warn("❌ Fehler: 'Important' Ordner fehlt!")
                            else
                                print("✅ Important Ordner gefunden")
                                print("ℹ️ Spawner in Important:")
                                for _, child in pairs(important:GetChildren()) do
                                    if child.Name:match("EnemySpawner") then
                                        local botCount = 0
                                        for _, bot in pairs(child:GetChildren()) do
                                            if bot:IsA("Model") then
                                                botCount = botCount + 1
                                            end
                                        end
                                        print("   -> " .. child.Name .. " (" .. botCount .. " Bots)")
                                    end
                                end
                                
                                -- Step 6: Enemy Search
                                local targetPart, enemyName, hp, spawnerName = findLivingEnemy(dFolder)
                                if not targetPart then
                                    warn("⚠️ Keine lebenden Gegner gefunden")
                                else
                                    print("🎯 Ziel gefunden: " .. enemyName .. " in " .. spawnerName)
                                    print("💚 HP: " .. hp)
                                    print("📍 Position: " .. tostring(targetPart.Position))
                                end
                            end
                        end
                    end
                end
                
                print("--- [🔍 DIAGNOSE ENDE] ---\n")
                debugTimer = tick()
            end
            
            -- === ACTUAL FARMING LOGIC ===
            pcall(function()
                local dId = Player:GetAttribute("DungeonId")
                if not (dId and myHRP) then return end
                
                local ds = WS:FindFirstChild("DungeonStorage")
                if not ds then return end
                
                local dFolder = ds:FindFirstChild(tostring(dId))
                if not dFolder then return end
                
                local targetPart = findLivingEnemy(dFolder)
                if targetPart then
                    myHRP.Velocity = Vector3.new(0, 0, 0)
                    myHRP.CFrame = CFrame.new(
                        targetPart.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)
                    ) * CFrame.Angles(math.rad(-90), 0, 0)
                end
            end)
        end
    end
end)

-- ========================================================
-- AUTO-SWING LOOP
-- ========================================================

task.spawn(function()
    while task.wait(0.3) do
        if _G.Hub.Toggles.AutoSwing then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

-- ========================================================
-- AUTO-UPGRADE LOOP
-- ========================================================

task.spawn(function()
    while task.wait(0.5) do
        if _G.Hub.Toggles.AutoUpgrade then
            pcall(function()
                RS.Events.DungeonUpgrade:FireServer(selUpgrade)
            end)
        end
    end
end)

print("✅ Dungeon Autofarm Script vollständig geladen!")
print("📦 Features: Autofarm, Auto Swing, Auto Upgrade")
