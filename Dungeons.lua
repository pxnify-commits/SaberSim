-- ========================================================
-- 🏰 DUNGEON DEBUG MASTER (FIXED VERSION)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local debugTimer = 0

-- UI Toggle
Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        print("----------------------------------")
        print("🔘 Autofarm Toggle: " .. tostring(v))
    end
})

-- HELPER FUNCTION: Find living enemies
local function findLivingEnemy(dungeonFolder)
    local important = dungeonFolder:FindFirstChild("Important")
    if not important then return nil end
    
    -- Search through ALL children of Important
    for _, child in pairs(important:GetChildren()) do
        -- Check if this is a spawner (contains "Spawner" in name)
        if string.match(child.Name, "EnemySpawner") and child:IsA("Model") then
            -- Look for enemy models inside this spawner
            for _, possibleEnemy in pairs(child:GetDescendants()) do
                if possibleEnemy:IsA("Model") and possibleEnemy.Name:match("Bot") then
                    local hp = possibleEnemy:GetAttribute("Health")
                    if hp and hp > 0 then
                        local targetPart = possibleEnemy.PrimaryPart or possibleEnemy:FindFirstChild("HumanoidRootPart")
                        if targetPart then
                            return targetPart, possibleEnemy.Name, hp
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- MAIN LOOP WITH DIAGNOSTICS
task.spawn(function()
    print("🚀 Diagnose-System gestartet. Warte auf Toggle...")
    
    while task.wait(0.1) do
        if _G.Hub.Toggles.AutoFarm then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            -- === DIAGNOSTIC OUTPUT (every 3 seconds) ===
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
                                print("ℹ️ Inhalt von Important:")
                                for _, child in pairs(important:GetChildren()) do
                                    print("   -> " .. child.Name .. " (" .. child.ClassName .. ")")
                                end
                                
                                -- Step 6: Enemy Search
                                local targetPart, enemyName, hp = findLivingEnemy(dFolder)
                                if not targetPart then
                                    warn("⚠️ Keine lebenden Gegner gefunden")
                                else
                                    print("🎯 Ziel gefunden: " .. enemyName .. " (HP: " .. hp .. ")")
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

-- === AUTO-SWING LOOP ===
task.spawn(function()
    while task.wait(0.3) do
        if _G.Hub.Toggles.AutoFarm then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

print("✅ Dungeon Autofarm Script geladen!")
