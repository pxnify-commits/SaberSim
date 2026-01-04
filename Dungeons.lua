-- ========================================================
-- 🏰 DUNGEON DEBUG MASTER (DIAGNOSTIC VERSION)
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

-- UI (Gekürzt für den Fokus auf die Logik)
Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        print("----------------------------------")
        print("🔘 Autofarm Toggle wurde geklickt: " .. tostring(v))
    end
})

-- HAUPT-LOGIK MIT SCHRITT-FÜR-SCHRITT FEEDBACK
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
