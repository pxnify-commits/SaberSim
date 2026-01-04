-- ========================================================
-- 🏰 DUNGEON ULTIMATE HUB (FULL DEBUG & DYNAMIC FIXED)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer

-- 1. KONFIGURATIONEN & SPEICHER
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local selDungeon, selDiff, selPrivacy = "Space", "Easy", "Public"
local selUpgrade = "DungeonHealth"
local dungeonNames, diffNames, diffMap = {"Space"}, {"Easy"}, {["Easy"] = 1}
local debugTimer = 0

local upgradeMap = {
    ["Health"] = "DungeonHealth", ["Damage"] = "DungeonDamage",
    ["Crit Chance"] = "DungeonCritChance", ["Incubator Slots"] = "DungeonEggSlots",
    ["Incubator Speed"] = "IncubatorSpeed", ["Coins Boost"] = "DungeonCoins",
    ["Crowns Boost"] = "DungeonCrowns"
}

-- 2. DYNAMISCHE DATEN LADEN (Info vom Server)
local function RefreshData()
    local success, Info = pcall(function() return require(RS.Modules:WaitForChild("DungeonInfo", 5)) end)
    if success and Info and Info.Dungeons and Info.Difficulties then
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

-- 3. UI: LOBBY MANAGEMENT
Tab:CreateSection("🏰 Dungeon Management")
Tab:CreateDropdown({Name = "Select Dungeon", Options = dungeonNames, CurrentOption = "Space", Callback = function(opt) selDungeon = (type(opt) == "table" and opt[1]) or tostring(opt) end})
Tab:CreateDropdown({Name = "Difficulty", Options = diffNames, CurrentOption = "Easy", Callback = function(opt) selDiff = (type(opt) == "table" and opt[1]) or tostring(opt) end})
Tab:CreateDropdown({Name = "Privacy", Options = {"Public", "Friends"}, CurrentOption = "Public", Callback = function(opt) selPrivacy = (type(opt) == "table" and opt[1]) or tostring(opt) end})
Tab:CreateButton({Name = "🔨 Create Lobby", Callback = function() RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", tostring(selPrivacy), tostring(selDungeon), tonumber(diffMap[selDiff]) or 1) end})
Tab:CreateButton({Name = "▶️ Start Dungeon", Callback = function() RS.Events.UIAction:FireServer("DungeonGroupAction", "Start") end})

-- 4. UI: AUTOFARM
Tab:CreateSection("⚔️ Dungeon Autofarm")
Tab:CreateToggle({Name = "Enable Autofarm", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoFarm = v print("Autofarm Toggle:", v) end})
Tab:CreateToggle({Name = "Auto Swing", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoSwing = v end})
Tab:CreateSlider({Name = "Farm Height (Höhe)", Min = 5, Max = 50, CurrentValue = 10, Callback = function(v) _G.Hub.Config.FarmHeight = v end})

-- 5. UI: UPGRADES & INCUBATOR
Tab:CreateSection("🆙 Upgrades & Incubator")
Tab:CreateDropdown({Name = "Select Upgrade", Options = {"Health", "Damage", "Crit Chance", "Incubator Slots", "Incubator Speed", "Coins Boost", "Crowns Boost"}, CurrentOption = "Health", Callback = function(opt) selUpgrade = upgradeMap[(type(opt) == "table" and opt[1]) or tostring(opt)] end})
Tab:CreateToggle({Name = "Auto Buy Upgrade", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoDungeonUpgrade = v end})
Tab:CreateToggle({Name = "Auto Claim Incubator", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoIncubator = v end})

-- 6. HAUPT-LOGIK (DEBUG & TELEPORT)
task.spawn(function()
    print("🚀 Dungeon-System geladen. Warte auf Autofarm-Aktivierung...")
    
    while true do
        task.wait(0.01)
        
        if _G.Hub.Toggles.AutoFarm then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            if myHRP then
                pcall(function()
                    local ds = WS:FindFirstChild("DungeonStorage")
                    if not ds then 
                        if tick() - debugTimer > 5 then warn("❌ DEBUG: DungeonStorage nicht gefunden!") debugTimer = tick() end
                        return 
                    end

                    -- Findet den dynamischen Ordner (z.B. 56c6f689...)
                    local dungeonFolder = nil
                    for _, child in pairs(ds:GetChildren()) do
                        if child:IsA("Folder") and child:FindFirstChild("Important") then
                            dungeonFolder = child
                            break
                        end
                    end
                    
                    if dungeonFolder then
                        local important = dungeonFolder.Important
                        local targetPart = nil
                        local targetBotObj = nil
                        
                        local spawnerList = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}
                        
                        -- Suche Bots
                        for _, sName in pairs(spawnerList) do
                            if targetPart then break end
                            for _, obj in pairs(important:GetChildren()) do
                                if obj.Name == sName then
                                    for _, bot in pairs(obj:GetChildren()) do
                                        local hp = bot:GetAttribute("Health")
                                        if bot:IsA("Model") and hp and hp > 0 then
                                            targetPart = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                                            if targetPart then 
                                                targetBotObj = bot
                                                break 
                                            end
                                        end
                                    end
                                end
                                if targetPart then break end
                            end
                        end
                        
                        -- AUSGABE IN KONSOLE (Alle 2 Sek)
                        if tick() - debugTimer > 2 then
                            if targetBotObj and targetPart then
                                print("--- [DUNGEON DEBUG] ---")
                                print("👾 Bot gefunden: " .. tostring(targetBotObj.Name))
                                print("📍 Bot Position: " .. tostring(targetPart.Position))
                                print("🛤️ MoveTo Attribut: " .. tostring(targetBotObj:GetAttribute("MoveTo")))
                                print("❤️ Health: " .. tostring(targetBotObj:GetAttribute("Health")))
                            else
                                warn("🔍 Suche läuft... Dungeon gefunden, aber keine lebenden Bots sichtbar.")
                            end
                            debugTimer = tick()
                        end

                        -- Teleport Ausführung
                        if targetPart then
                            myHRP.Velocity = Vector3.new(0,0,0)
                            myHRP.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                        end
                    else
                        if tick() - debugTimer > 5 then warn("⚠️ DEBUG: DungeonStorage ist da, aber kein aktiver Dungeon-Ordner!") debugTimer = tick() end
                    end
                end)
            end
        end
        
        -- Auto Swing
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)

-- 7. UPGRADE & INCUBATOR LOOP (FIXED)
task.spawn(function()
    while true do
        task.wait(1)
        -- Upgrades (Index-Fehler gefixt)
        if _G.Hub.Toggles.AutoDungeonUpgrade and selUpgrade then
            pcall(function()
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade)
            end)
        end
        -- Incubator
        if _G.Hub.Toggles.AutoIncubator then
            pcall(function()
                RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
            end)
        end
    end
end)
