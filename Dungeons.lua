-- ========================================================
-- 🏰 DUNGEON ULTIMATE HUB (FINAL SYNC VERSION)
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

-- 2. DYNAMISCHE DATEN LADEN
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

-- 3. UI ELEMENTE
Tab:CreateSection("🏰 Dungeon Management")
Tab:CreateDropdown({Name = "Select Dungeon", Options = dungeonNames, CurrentOption = "Space", Callback = function(opt) selDungeon = (type(opt) == "table" and opt[1]) or tostring(opt) end})
Tab:CreateDropdown({Name = "Difficulty", Options = diffNames, CurrentOption = "Easy", Callback = function(opt) selDiff = (type(opt) == "table" and opt[1]) or tostring(opt) end})
Tab:CreateDropdown({Name = "Privacy", Options = {"Public", "Friends"}, CurrentOption = "Public", Callback = function(opt) selPrivacy = (type(opt) == "table" and opt[1]) or tostring(opt) end})
Tab:CreateButton({Name = "🔨 Create Lobby", Callback = function() RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", tostring(selPrivacy), tostring(selDungeon), tonumber(diffMap[selDiff]) or 1) end})
Tab:CreateButton({Name = "▶️ Start Dungeon", Callback = function() RS.Events.UIAction:FireServer("DungeonGroupAction", "Start") end})

Tab:CreateSection("⚔️ Dungeon Autofarm")
Tab:CreateToggle({Name = "Enable Autofarm", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoFarm = v print("Autofarm Status: " .. tostring(v)) end})
Tab:CreateToggle({Name = "Auto Swing", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoSwing = v end})
Tab:CreateSlider({Name = "Farm Height", Min = 5, Max = 50, CurrentValue = 10, Callback = function(v) _G.Hub.Config.FarmHeight = v end})

Tab:CreateSection("🆙 Upgrades & Incubator")
Tab:CreateDropdown({Name = "Select Upgrade", Options = {"Health", "Damage", "Crit Chance", "Incubator Slots", "Incubator Speed", "Coins Boost", "Crowns Boost"}, CurrentOption = "Health", Callback = function(opt) selUpgrade = upgradeMap[(type(opt) == "table" and opt[1]) or tostring(opt)] end})
Tab:CreateToggle({Name = "Auto Buy Upgrade", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoDungeonUpgrade = v end})
Tab:CreateToggle({Name = "Auto Claim Incubator", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoIncubator = v end})

-- 4. HAUPT-LOGIK (TELEPORT & DEBUG)
task.spawn(function()
    print("🚀 Dungeon-Logik mit ID-Synchronisation gestartet!")
    
    while true do
        task.wait(0.01)
        
        if _G.Hub.Toggles.AutoFarm then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            -- Nutzt das DungeonId-Attribut vom Spieler für den Pfad
            local dungeonId = Player:GetAttribute("DungeonId")
            
            if myHRP and dungeonId then
                pcall(function()
                    local ds = WS:FindFirstChild("DungeonStorage")
                    local dungeonFolder = ds and ds:FindFirstChild(dungeonId)
                    
                    if dungeonFolder and dungeonFolder:FindFirstChild("Important") then
                        local important = dungeonFolder.Important
                        local targetPart = nil
                        local targetBot = nil
                        
                        -- Liste der Spawner aus dem Explorer
                        local spawners = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}
                        
                        for _, sName in pairs(spawners) do
                            local sFolder = important:FindFirstChild(sName)
                            if sFolder then
                                for _, bot in pairs(sFolder:GetChildren()) do
                                    -- Prüft Health-Attribut gemäß Properties
                                    local hp = bot:GetAttribute("Health") or 0
                                    if bot:IsA("Model") and hp > 0 then
                                        targetPart = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                                        if targetPart then targetBot = bot break end
                                    end
                                end
                            end
                            if targetPart then break end
                        end

                        -- DEBUG OUTPUT (Alle 2 Sekunden)
                        if tick() - debugTimer > 2 then
                            if targetBot then
                                print("--- [DUNGEON STATUS] ---")
                                print("👾 Ziel-Bot: " .. targetBot.Name)
                                print("📍 Bot Pos: " .. tostring(targetPart.Position))
                                print("🛤️ MoveTo Pos: " .. tostring(targetBot:GetAttribute("MoveTo"))) --
                                print("❤️ Health: " .. tostring(targetBot:GetAttribute("Health")))
                            else
                                warn("🔍 Suche... Dungeon-Ordner gefunden, aber keine lebenden Bots!")
                            end
                            debugTimer = tick()
                        end

                        -- Teleport Ausführung
                        if targetPart then
                            myHRP.Velocity = Vector3.new(0,0,0)
                            myHRP.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                        end
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

-- 5. UPGRADES & INCUBATOR (FIXED INDEX ERROR)
task.spawn(function()
    while true do
        task.wait(1)
        if _G.Hub.Toggles.AutoDungeonUpgrade and selUpgrade then
            pcall(function() 
                -- Entfernt den numerischen Index, um nil-Fehler zu vermeiden
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade) 
            end)
        end
        if _G.Hub.Toggles.AutoIncubator then
            pcall(function() 
                RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll") 
            end)
        end
    end
end)
