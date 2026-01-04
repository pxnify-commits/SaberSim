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
_G.Hub.Config.SelectedDifficulty = _G.Hub.Config.SelectedDifficulty or "Easy"
_G.Hub.Config.SelectedMap = _G.Hub.Config.SelectedMap or "Castle"

local selUpgrade = "DungeonHealth"
local debugTimer = 0

-- ========================================================
-- UI ELEMENTS - LOBBY SECTION
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
-- UI ELEMENTS - FARMING SECTION
-- ========================================================

Tab:CreateSection("⚔️ Dungeon Farming")

Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        print("----------------------------------")
        print("🔘 Autofarm Toggle wurde geklickt: " .. tostring(v))
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
-- UI ELEMENTS - REWARDS SECTION
-- ========================================================

Tab:CreateSection("🎁 Rewards")

Tab:CreateToggle({
    Name = "Auto Collect Chests",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoCollectChests = v
        print("💎 Auto Collect Chests: " .. tostring(v))
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
                
                -- Wenn nicht im Dungeon und nicht in Lobby -> Erstelle Lobby
                if not dId and not inLobby then
                    print("🔄 Erstelle automatisch Lobby...")
                    RS.Events.CreateDungeonLobby:FireServer(
                        _G.Hub.Config.SelectedMap,
                        _G.Hub.Config.SelectedDifficulty
                    )
                    task.wait(1)
                end
                
                -- Wenn in Lobby -> Starte Dungeon
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
-- MAIN AUTOFARM LOOP WITH DIAGNOSTICS (DEINE ORIGINAL LOGIK)
-- ========================================================

task.spawn(function()
    print("🚀 Diagnose-System gestartet. Warte auf Toggle...")
    
    while true do
        task.wait(0.1) -- Langsamerer Loop für saubere Console-Logs
        
        if _G.Hub.Toggles.AutoFarm then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            -- Schritt 1: DungeonId prüfen
            local dId = Player:GetAttribute("DungeonId")
            
            if tick() - debugTimer > 3 then -- Feedback alle 3 Sekunden
                print("--- [DIAGNOSE START] ---")
                
                if not char then warn("❌ Fehler: Charakter nicht gefunden!") 
                elseif not myHRP then warn("❌ Fehler: HumanoidRootPart fehlt!")
                else print("✅ Charakter-Check: OK") end
                
                if not dId then 
                    warn("❌ Fehler: Keine DungeonId am Player gefunden! (Bist du im Dungeon?)")
                else 
                    print("✅ DungeonId gefunden: " .. tostring(dId)) 
                end

                -- Schritt 2: DungeonStorage & Ordner prüfen
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
                        
                        -- Schritt 3: Gegner-Suche
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
                            else
                                -- Schritt 4: Teleport Versuch
                                print("⚡ Teleportiere zu Position: " .. tostring(targetPart.Position))
                                myHRP.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                            end
                        end
                    end
                end
                print("--- [DIAGNOSE ENDE] ---")
                debugTimer = tick()
            end
            
            -- Ausführung des Teleports (ohne Print-Verzögerung für flüssiges Farmen)
            pcall(function()
                if dId and myHRP then
                    local target = nil
                    for _, sName in pairs({"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}) do
                        local folder = WS.DungeonStorage[dId].Important:FindFirstChild(sName)
                        if folder then
                            for _, b in pairs(folder:GetChildren()) do
                                if b:GetAttribute("Health") and b:GetAttribute("Health") > 0 then
                                    target = b.PrimaryPart or b:FindFirstChild("HumanoidRootPart")
                                    if target then break end
                                end
                            end
                        end
                        if target then break end
                    end
                    if target then
                        myHRP.Velocity = Vector3.new(0,0,0)
                        myHRP.CFrame = CFrame.new(target.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                    end
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

print("✅ Dungeon Autofarm Script VOLLSTÄNDIG geladen!")
print("📦 Features: Lobby Creation, Autofarm (Original Logik), Auto Swing, Auto Upgrade, Auto Collect")
