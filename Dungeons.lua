-- ========================================================
-- 🏰 DUNGEON MODULE (ORIGINAL UI + IMPROVED SCANNER)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer

-- Konfigurationen
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

-- Speicher für Auswahl
local selDungeon, selDiff, selPrivacy = "Space", "Easy", "Public"
local dungeonNames, diffNames, diffMap = {"Space"}, {"Easy"}, {["Easy"] = 1}
local selUpgrade = "DungeonHealth"

local upgradeMap = {
    ["Health"] = "DungeonHealth", ["Damage"] = "DungeonDamage",
    ["Crit Chance"] = "DungeonCritChance", ["Incubator Slots"] = "DungeonEggSlots",
    ["Incubator Speed"] = "IncubatorSpeed", ["Coins Boost"] = "DungeonCoins",
    ["Crowns Boost"] = "DungeonCrowns"
}

-- 1. DYNAMISCHE DATEN (Dungeon Info)
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

-- 2. UI: MANAGEMENT (Wie davor)
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

Tab:CreateDropdown({
    Name = "Privacy",
    Options = {"Public", "Friends"},
    CurrentOption = "Public",
    Callback = function(opt) selPrivacy = (type(opt) == "table" and opt[1]) or tostring(opt) end
})

Tab:CreateButton({
    Name = "🔨 Create Lobby",
    Callback = function()
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", tostring(selPrivacy), tostring(selDungeon), tonumber(diffMap[selDiff]) or 1)
    end
})

Tab:CreateButton({
    Name = "▶️ Start Dungeon",
    Callback = function()
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Start")
    end
})

-- 3. UI: AUTOFARM EINSTELLUNGEN
Tab:CreateSection("⚔️ Dungeon Autofarm")

Tab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoFarm = v end
})

Tab:CreateSlider({
    Name = "Farm Height",
    Min = 5,
    Max = 30,
    CurrentValue = 10,
    Callback = function(v) _G.Hub.Config.FarmHeight = v end
})

-- 4. UI: UPGRADES & INCUBATOR
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

-- 5. HAUPT-LOGIK LOOP
task.spawn(function()
    while true do
        task.wait(0.05)
        
        if _G.Hub.Toggles.AutoFarm then
            pcall(function()
                local storage = WS:FindFirstChild("DungeonStorage")
                if storage then
                    -- Findet den dynamischen Ordner
                    local currentDungeon = storage:FindFirstChildOfClass("Folder") or storage:GetChildren()[1]
                    if currentDungeon and currentDungeon:FindFirstChild("Important") then
                        local important = currentDungeon.Important
                        local spawnerTypes = {"Green", "Blue", "Purple", "Red", "PurpleBoss"}
                        local targetBot = nil

                        -- Scannt alle Spawner in der Reihenfolge
                        for _, color in pairs(spawnerTypes) do
                            if targetBot then break end
                            local sName = color .. "EnemySpawner"
                            for _, obj in pairs(important:GetChildren()) do
                                if obj.Name == sName then
                                    for _, bot in pairs(obj:GetChildren()) do
                                        -- Health-Check via Attribute
                                        if bot:GetAttribute("Health") and bot:GetAttribute("Health") > 0 and bot:FindFirstChild("HumanoidRootPart") then
                                            targetBot = bot
                                            break
                                        end
                                    end
                                end
                                if targetBot then break end
                            end
                        end

                        -- Teleport-Logik (90 Grad Winkel)
                        if targetBot and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = targetBot.HumanoidRootPart
                            local rotation = CFrame.Angles(math.rad(-90), 0, 0)
                            
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

        -- Upgrades & Incubator Check
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
