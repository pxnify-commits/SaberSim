-- ========================================================
-- 🏰 DUNGEON AUTOFARM (COMPLETE VERSION - DYNAMIC HEIGHT)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10
_G.Hub.Config.SelectedDifficulty = _G.Hub.Config.SelectedDifficulty or "Easy"
_G.Hub.Config.SelectedMap = _G.Hub.Config.SelectedMap or "Castle"

local selUpgrade = "DungeonHealth"
local debugTimer = 0
local currentTarget = nil
local rotationSet = false

-- ========================================================
-- UI ELEMENTS - LOBBY MANAGEMENT
-- ========================================================

Tab:CreateSection("🏛️ Lobby Management")

Tab:CreateDropdown({
    Name = "Select Difficulty",
    Options = {"Easy", "Medium", "Hard", "Nightmare"},
    CurrentOption = _G.Hub.Config.SelectedDifficulty,
    Callback = function(v)
        _G.Hub.Config.SelectedDifficulty = v
        print("⚙️ Schwierigkeit: " .. v)
    end
})

Tab:CreateDropdown({
    Name = "Select Map",
    Options = {"Castle", "Desert", "Winter", "Volcano"},
    CurrentOption = _G.Hub.Config.SelectedMap,
    Callback = function(v)
        _G.Hub.Config.SelectedMap = v
        print("🗺️ Map: " .. v)
    end
})

Tab:CreateButton({
    Name = "Create Lobby",
    Callback = function()
        pcall(function()
            print("🚪 Erstelle Lobby: " .. _G.Hub.Config.SelectedMap .. " (" .. _G.Hub.Config.SelectedDifficulty .. ")")
            RS.Events.CreateDungeonLobby:FireServer(
                _G.Hub.Config.SelectedMap,
                _G.Hub.Config.SelectedDifficulty
            )
        end)
    end
})

Tab:CreateButton({
    Name = "Start Dungeon",
    Callback = function()
        pcall(function()
            print("▶️ Starte Dungeon...")
            RS.Events.StartDungeon:FireServer()
        end)
    end
})

Tab:CreateButton({
    Name = "Leave Dungeon/Lobby",
    Callback = function()
        pcall(function()
            print("🚪 Verlasse Dungeon/Lobby...")
            RS.Events.LeaveDungeon:FireServer()
        end)
    end
})

Tab:CreateToggle({
    Name = "Auto Create & Start",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoCreateStart = v
        print("🔄 Auto Create & Start: " .. tostring(v))
    end
})

-- ========================================================
-- UI ELEMENTS - DUNGEON FARMING
-- ========================================================

Tab:CreateSection("⚔️ Dungeon Farming")

Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        currentTarget = nil
        rotationSet = false
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
-- UI ELEMENTS - DUNGEON UPGRADES
-- ========================================================

Tab:CreateSection("⬆️ Dungeon Upgrades")

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

-- ========================================================
-- UI ELEMENTS - DUNGEON REWARDS
-- ========================================================

Tab:CreateSection("🎁 Dungeon Rewards")

Tab:CreateToggle({
    Name = "Auto Collect Chests",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoCollectChests = v
        print("💎 Auto Collect Chests: " .. tostring(v))
    end
})

Tab:CreateToggle({
    Name = "Auto Claim Incubate Eggs",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoClaimEggs = v
        print("🥚 Auto Claim Incubate Eggs: " .. tostring(v))
    end
})

Tab:CreateToggle({
    Name = "Auto Best Dungeon Egg",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoBestEgg = v
        print("✨ Auto Best Dungeon Egg: " .. tostring(v))
    end
})

Tab:CreateButton({
    Name = "Collect All Chests Now",
    Callback = function()
        pcall(function()
            local dId = Player:GetAttribute("DungeonId")
            if not dId then 
                warn("❌ Nicht im Dungeon!")
                return 
            end
            
            local ds = WS:FindFirstChild("DungeonStorage")
            if not ds then return end
            
            local dFolder = ds:FindFirstChild(tostring(dId))
            if not dFolder then return end
            
            local important = dFolder:FindFirstChild("Important")
            if not important then return end
            
            local rewardChests = important:FindFirstChild("RewardChests")
            if not rewardChests then 
                warn("⚠️ Keine RewardChests gefunden!")
                return 
            end
            
            local count = 0
            for _, chest in pairs(rewardChests:GetChildren()) do
                if chest:IsA("Model") or chest:IsA("Part") then
                    RS.Events.CollectChest:FireServer(chest)
                    count = count + 1
                    task.wait(0.1)
                end
            end
            print("✅ " .. count .. " Chests gesammelt!")
        end)
    end
})

-- ========================================================
-- AUTO CREATE & START LOOP
-- ========================================================

task.spawn(function()
    while task.wait(2) do
        if _G.Hub.Toggles.AutoCreateStart then
            pcall(function()
                local dId = Player:GetAttribute("DungeonId")
                local inLobby = Player:GetAttribute("InDungeonLobby")
                
                if not dId and not inLobby then
                    print("🔄 Erstelle automatisch Lobby...")
                    RS.Events.CreateDungeonLobby:FireServer(
                        _G.Hub.Config.SelectedMap,
                        _G.Hub.Config.SelectedDifficulty
                    )
                    task.wait(1)
                end
                
                if inLobby and not dId then
                    print("▶️ Starte Dungeon automatisch...")
                    RS.Events.StartDungeon:FireServer()
                    task.wait(1)
                end
            end)
        end
    end
end)

-- ========================================================
-- RENDERSTEPPED LOOP FÜR POSITION (DYNAMISCHE HÖHE)
-- ========================================================

RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm and currentTarget then
        local char = Player.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        
        if myHRP and currentTarget.Parent then
            -- Prüfe ob Ziel noch lebt
            local hp = currentTarget.Parent:GetAttribute("Health")
            if not hp or hp <= 0 then
                currentTarget = nil
                rotationSet = false
                return
            end
            
            -- DYNAMISCHE Position basierend auf AKTUELLER Höhe
            local targetPosition = currentTarget.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)
            
            -- Rotation NUR einmal setzen beim neuen Ziel
            if not rotationSet then
                myHRP.CFrame = CFrame.new(targetPosition) * CFrame.Angles(math.rad(90), 0, 0)
                rotationSet = true
                print("🔄 Rotation auf 90° gesetzt")
            else
                -- Danach nur Position halten (Rotation bleibt)
                local currentRotation = myHRP.CFrame - myHRP.CFrame.Position
                myHRP.CFrame = CFrame.new(targetPosition) * currentRotation
            end
            
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ========================================================
-- MAIN AUTOFARM LOOP
-- ========================================================

task.spawn(function()
    print("🚀 Diagnose-System gestartet. Warte auf Toggle...")
    
    while true do
        task.wait(0.5)
        
        if _G.Hub.Toggles.AutoFarm then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            local dId = Player:GetAttribute("DungeonId")
            
            if tick() - debugTimer > 3 then
                print("--- [DIAGNOSE START] ---")
                
                if not char then warn("❌ Fehler: Charakter nicht gefunden!") 
                elseif not myHRP then warn("❌ Fehler: HumanoidRootPart fehlt!")
                else print("✅ Charakter-Check: OK") end
                
                if not dId then 
                    warn("❌ Fehler: Keine DungeonId am Player gefunden! (Bist du im Dungeon?)")
                else 
                    print("✅ DungeonId gefunden: " .. tostring(dId)) 
                end

                local ds = WS:FindFirstChild("DungeonStorage")
                if not ds then 
                    warn("❌ Fehler: Workspace.DungeonStorage existiert nicht!")
                else
                    print("✅ DungeonStorage gefunden.")
                    local dFolder = ds:FindFirstChild(tostring(dId))
                    if not dFolder then
                        warn("❌ Fehler: Ordner mit Name '" .. tostring(dId) .. "' nicht in DungeonStorage!")
                        print("ℹ️ Vorhandene Ordner in DS:")
                        for _, child in pairs(ds:GetChildren()) do print("   -> " .. child.Name) end
                    else
                        print("✅ Dungeon-Ordner gefunden.")
                        
                        local important = dFolder:FindFirstChild("Important")
                        if not important then
                            warn("❌ Fehler: Ordner 'Important' fehlt im Dungeon-Ordner!")
                        else
                            local targetPart = nil
                            local enemyFound = false
                            local spawners = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}
                            
                            for _, sName in pairs(spawners) do
                                local sFolder = important:FindFirstChild(sName)
                                if sFolder then
                                    for _, bot in pairs(sFolder:GetChildren()) do
                                        local hp = bot:GetAttribute("Health") or 0
                                        if bot:IsA("Model") and hp > 0 then
                                            targetPart = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                                            if targetPart then 
                                                print("🎯 Gegner gefunden: " .. bot.Name .. " (HP: " .. hp .. ")")
                                                enemyFound = true
                                                break 
                                            end
                                        end
                                    end
                                end
                                if targetPart then break end
                            end
                            
                            if not enemyFound then
                                warn("⚠️ Info: Keine lebenden Gegner in den Spawnern gefunden.")
                                currentTarget = nil
                                rotationSet = false
                            end
                        end
                    end
                end
                print("--- [DIAGNOSE ENDE] ---")
                debugTimer = tick()
            end
            
            -- TARGET FINDING
            pcall(function()
                if not (dId and myHRP) then return end
                
                -- Prüfe ob aktuelles Ziel noch lebt
                local targetStillAlive = false
                if currentTarget then
                    local hp = currentTarget.Parent:GetAttribute("Health")
                    if hp and hp > 0 then
                        targetStillAlive = true
                    end
                end
                
                -- Wenn Ziel tot oder keins vorhanden -> Suche neues
                if not targetStillAlive then
                    currentTarget = nil
                    rotationSet = false
                    
                    local ds = WS:FindFirstChild("DungeonStorage")
                    if not ds then return end
                    
                    local dFolder = ds:FindFirstChild(tostring(dId))
                    if not dFolder then return end
                    
                    local important = dFolder:FindFirstChild("Important")
                    if not important then return end
                    
                    local spawners = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}
                    
                    for _, sName in pairs(spawners) do
                        local sFolder = important:FindFirstChild(sName)
                        if sFolder then
                            for _, bot in pairs(sFolder:GetChildren()) do
                                local hp = bot:GetAttribute("Health")
                                if bot:IsA("Model") and hp and hp > 0 then
                                    local targetPart = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                                    if targetPart then
                                        currentTarget = targetPart
                                        print("🎯 Neues Ziel erfasst: " .. bot.Name)
                                        break
                                    end
                                end
                            end
                        end
                        if currentTarget then break end
                    end
                end
            end)
        else
            currentTarget = nil
            rotationSet = false
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

-- ========================================================
-- AUTO COLLECT CHESTS LOOP
-- ========================================================

task.spawn(function()
    while task.wait(1) do
        if _G.Hub.Toggles.AutoCollectChests then
            pcall(function()
                local dId = Player:GetAttribute("DungeonId")
                if not dId then return end
                
                local ds = WS:FindFirstChild("DungeonStorage")
                if not ds then return end
                
                local dFolder = ds:FindFirstChild(tostring(dId))
                if not dFolder then return end
                
                local important = dFolder:FindFirstChild("Important")
                if not important then return end
                
                local rewardChests = important:FindFirstChild("RewardChests")
                if not rewardChests then return end
                
                for _, chest in pairs(rewardChests:GetChildren()) do
                    if chest:IsA("Model") or chest:IsA("Part") then
                        RS.Events.CollectChest:FireServer(chest)
                    end
                end
            end)
        end
    end
end)

-- ========================================================
-- AUTO CLAIM INCUBATE EGGS LOOP
-- ========================================================

task.spawn(function()
    while task.wait(2) do
        if _G.Hub.Toggles.AutoClaimEggs then
            pcall(function()
                RS.Events.ClaimIncubateEgg:FireServer()
            end)
        end
    end
end)

-- ========================================================
-- AUTO BEST DUNGEON EGG LOOP
-- ========================================================

task.spawn(function()
    while task.wait(1) do
        if _G.Hub.Toggles.AutoBestEgg then
            pcall(function()
                RS.Events.BuyBestDungeonEgg:FireServer()
            end)
        end
    end
end)

print("✅ Dungeon Autofarm Script VOLLSTÄNDIG geladen!")
print("📦 Features: Lobby, Farming, Upgrades, Rewards (Chests, Eggs)")
