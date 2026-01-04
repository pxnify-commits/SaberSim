-- ========================================================
-- 🏰 DUNGEON ULTIMATE - AUTO-NEXT TARGET & 90° ROTATION
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local currentTarget = nil
local selUpgrade = "DungeonHealth"
local selDungeon, selDiff = "Space", "Easy"

local diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Nightmare"] = 4}
local upgradeMap = {
    ["Health"] = "DungeonHealth", ["Damage"] = "DungeonDamage",
    ["Crit Chance"] = "DungeonCritChance", ["Incubator Slots"] = "DungeonEggSlots",
    ["Coins Boost"] = "DungeonCoins"
}

-- ========================================================
-- UI SECTION
-- ========================================================
Tab:CreateSection("🏛️ Lobby Management")
Tab:CreateDropdown({Name = "Select Dungeon", Options = {"Space", "Castle", "Forest", "Desert"}, CurrentOption = "Space", Callback = function(v) selDungeon = v end})
Tab:CreateDropdown({Name = "Select Difficulty", Options = {"Easy", "Medium", "Hard", "Nightmare"}, CurrentOption = "Easy", Callback = function(v) selDiff = v end})
Tab:CreateButton({Name = "🔨 Create Lobby", Callback = function() RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", "Public", selDungeon, diffMap[selDiff] or 1) end})
Tab:CreateButton({Name = "▶️ Start Dungeon", Callback = function() RS.Events.UIAction:FireServer("DungeonGroupAction", "Start") end})

Tab:CreateSection("⚔️ Dungeon Farming")
Tab:CreateToggle({Name = "Enable Autofarm", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoFarm = v currentTarget = nil end})
Tab:CreateToggle({Name = "Auto Swing", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoSwing = v end})
Tab:CreateSlider({Name = "Farm Height", Min = 5, Max = 30, CurrentValue = 10, Callback = function(v) _G.Hub.Config.FarmHeight = v end})

Tab:CreateSection("🆙 Upgrades")
Tab:CreateDropdown({Name = "Select Upgrade", Options = {"Health", "Damage", "Crit Chance", "Incubator Slots", "Coins Boost"}, CurrentOption = "Health", Callback = function(v) selUpgrade = upgradeMap[v] end})
Tab:CreateToggle({Name = "Auto Buy Upgrade", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoDungeonUpgrade = v end})

-- ========================================================
-- LOGIC: SMOOTH 90° FOLLOW (RENDERSTEPPED)
-- ========================================================
RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm and currentTarget and currentTarget.Parent then
        local char = Player.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        
        if myHRP then
            -- Live Check: Wenn HP 0, Ziel sofort verwerfen
            local hp = currentTarget.Parent:GetAttribute("Health") or 0
            if hp <= 0 then
                currentTarget = nil
                return
            end
            
            local targetPosition = currentTarget.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)
            myHRP.CFrame = CFrame.new(targetPosition) * CFrame.Angles(math.rad(-90), 0, 0)
            myHRP.Velocity = Vector3.new(0, 0, 0)
        end
    else
        currentTarget = nil -- Sicherheitshalber zurücksetzen, wenn Toggle aus
    end
end)

-- ========================================================
-- LOGIC: AGGRESSIVE TARGET SCANNER
-- ========================================================
task.spawn(function()
    while true do
        task.wait(0.1) -- Schneller Scan für flüssiges Farmen
        
        if _G.Hub.Toggles.AutoFarm then
            -- Nur suchen, wenn wir kein aktives Ziel haben oder das Ziel tot ist
            local needsTarget = false
            if not currentTarget or not currentTarget.Parent or (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
                needsTarget = true
            end

            if needsTarget then
                pcall(function()
                    local dId = Player:GetAttribute("DungeonId")
                    if dId then
                        local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
                        if dFolder and dFolder:FindFirstChild("Important") then
                            local spawners = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}
                            local newTarget = nil
                            
                            for _, sName in pairs(spawners) do
                                local folder = dFolder.Important:FindFirstChild(sName)
                                if folder then
                                    for _, bot in pairs(folder:GetChildren()) do
                                        local hp = bot:GetAttribute("Health") or 0
                                        if hp > 0 then
                                            newTarget = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                                            if newTarget then break end
                                        end
                                    end
                                end
                                if newTarget then break end
                            end
                            currentTarget = newTarget
                        end
                    end
                end)
            end
        end
    end
end)

-- ========================================================
-- LOOPS: SWING & UPGRADES
-- ========================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if _G.Hub.Toggles.AutoDungeonUpgrade and selUpgrade then
            RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade)
        end
    end
end)

print("✅ Dungeon Script geladen - Sucht jetzt automatisch neue Ziele!")
