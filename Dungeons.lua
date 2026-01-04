-- ========================================================
-- 🏰 MENYANETY HUB | ULTIMATE DUNGEON MODULE
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

local upgradeMap = {
    ["Health"] = "DungeonHealth", ["Damage"] = "DungeonDamage",
    ["Crit Chance"] = "DungeonCritChance", ["Incubator Slots"] = "DungeonEggSlots",
    ["Incubator Speed"] = "IncubatorSpeed", ["Coins Boost"] = "DungeonCoins",
    ["Crowns Boost"] = "DungeonCrowns"
}

-- 2. DYNAMISCHE DATEN LADEN (Dungeon Info)
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

-- 3. UI SEKTION: MAIN (Autofarm & Kampf)
Tab:CreateSection("Main")

Tab:CreateToggle({
    Name = "Auto Farm 💀 Dungeon 💀",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoFarm = v end
})

Tab:CreateToggle({
    Name = "Auto 🗡️ Swing 🗡️",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoSwing = v end
})

Tab:CreateToggle({
    Name = "Auto Collect Chest",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoCollectChest = v end
})

Tab:CreateSlider({
    Name = "Farm Height (Höhe)",
    Min = 5, Max = 50, CurrentValue = 10,
    Callback = function(v) _G.Hub.Config.FarmHeight = v end
})

-- 4. UI SEKTION: LOBBY MANAGEMENT
Tab:CreateSection("🏰 Dungeon Management")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonNames,
    CurrentOption = "Space",
    Callback = function(opt) selDungeon = (type(opt) == "table" and opt[1]) or tostring(opt) end
})

Tab:CreateDropdown({
    Name = "Difficulty",
    Options = diffNames,
    CurrentOption = "Easy",
    Callback = function(opt) selDiff = (type(opt) == "table" and opt[1]) or tostring(opt) end
})

Tab:CreateButton({
    Name = "🔨 Create Lobby",
    Callback = function()
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", "Public", tostring(selDungeon), tonumber(diffMap[selDiff]) or 1)
    end
})

Tab:CreateButton({
    Name = "▶️ Start Dungeon",
    Callback = function()
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Start")
    end
})

-- 5. UI SEKTION: UPGRADES & INCUBATOR
Tab:CreateSection("🆙 Upgrades & Incubator")

Tab:CreateDropdown({
    Name = "Select Upgrade",
    Options = {"Health", "Damage", "Crit Chance", "Incubator Slots", "Incubator Speed", "Coins Boost", "Crowns Boost"},
    CurrentOption = "Health",
    Callback = function(opt)
        local val = (type(opt) == "table" and opt[1]) or tostring(opt)
        selUpgrade = upgradeMap[val] or "DungeonHealth"
    end
})

Tab:CreateToggle({
    Name = "Auto Buy Upgrade",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoDungeonUpgrade = v end
})

Tab:CreateToggle({
    Name = "Auto Claim Incubator",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoIncubator = v end
})

-- 6. HAUPT-LOGIK LOOP (SCANNER & POSITIONIERUNG)
task.spawn(function()
    while true do
        task.wait(0.05)
        
        -- A. PRÄZISIONS-AUTOFARM LOGIK (Shuffelt durch Spawner)
        if _G.Hub.Toggles.AutoFarm then
            pcall(function()
                local storage = WS:FindFirstChild("DungeonStorage")
                if storage then
                    local currentDungeon = storage:FindFirstChildOfClass("Folder") or storage:GetChildren()[1]
                    if currentDungeon and currentDungeon:FindFirstChild("Important") then
                        local important = currentDungeon.Important
                        local spawnerTypes = {"Green", "Blue", "Purple", "Red", "PurpleBoss"}
                        local targetBot = nil

                        -- Scannt alle Spawner nach einem Bot mit Health > 0
                        for _, color in pairs(spawnerTypes) do
                            if targetBot then break end
                            local sName = color .. "EnemySpawner"
                            for _, obj in pairs(important:GetChildren()) do
                                if obj.Name == sName then
                                    for _, bot in pairs(obj:GetChildren()) do
                                        if bot:GetAttribute("Health") and bot:GetAttribute("Health") > 0 and bot:FindFirstChild("HumanoidRootPart") then
                                            targetBot = bot
                                            break
                                        end
                                    end
                                end
                                if targetBot then break end
                            end
                        end

                        -- Teleportiert 90° über den gefundenen Bot
                        if targetBot and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = targetBot.HumanoidRootPart
                            local rotation = CFrame.Angles(math.rad(-90), 0, 0)
                            
                            -- Klebt am Bot bis er stirbt
                            repeat 
                                task.wait() 
                                if hrp and _G.Hub.Toggles.AutoFarm then
                                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)) * rotation
                                end
                            until not targetBot.Parent or targetBot:GetAttribute("Health") <= 0 or not _G.Hub.Toggles.AutoFarm
                        end
                    end
                end
            end)
        end

        -- B. AUTO SWING LOGIK
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing") 
        end

        -- C. UPGRADES & INCUBATOR (Jede Sekunde)
        if tick() % 1 <= 0.1 then
            if _G.Hub.Toggles.AutoDungeonUpgrade and selUpgrade then
                for i = 1, 10 do RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade, i) end
            end
            if _G.Hub.Toggles.AutoIncubator then
                RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
            end
        end
    end
end)
