-- ========================================================
-- 🏰 DUNGEON MODULE (ALL-IN-ONE: DYNAMIC, MGMT & AUTOFARM)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer

-- Initialisierung der Configs (falls nicht vorhanden)
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10
_G.Hub.Config.FarmAngle = _G.Hub.Config.FarmAngle or 90

-- Lokale Speicher für die Auswahl (Strings)
local selDungeon = "Space"
local selDiff = "Easy"
local selPrivacy = "Public"
local selUpgrade = "DungeonHealth"

local dungeonNames = {"Space"}
local diffNames = {"Easy", "Medium", "Hard", "Impossible"}
local diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Impossible"] = 4}

-- 1. DYNAMISCHE DATEN LADEN
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

-- 2. UI: DUNGEON MANAGEMENT (Lobby & Start)
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
        local pArg = tostring(selPrivacy)
        if pArg:find("table:") then pArg = "Public" end
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", pArg, tostring(selDungeon), tonumber(diffMap[selDiff]) or 1)
    end
})

Tab:CreateButton({
    Name = "▶️ Start Dungeon",
    Callback = function()
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Start")
    end
})

-- 3. UI: DUNGEON AUTOFARM (Extra Feature)
Tab:CreateSection("⚔️ Dungeon Autofarm")

Tab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoFarm = v end
})

Tab:CreateSlider({
    Name = "Farm Height (Höhe)",
    Min = 5,
    Max = 30,
    CurrentValue = 10,
    Callback = function(v) _G.Hub.Config.FarmHeight = v end
})

-- 4. UI: UPGRADES & INCUBATOR
Tab:CreateSection("🆙 Upgrades & Incubator")

local upgradeMap = {
    ["Health"] = "DungeonHealth", ["Damage"] = "DungeonDamage",
    ["Crit Chance"] = "DungeonCritChance", ["Incubator Slots"] = "DungeonEggSlots",
    ["Incubator Speed"] = "IncubatorSpeed", ["Coins Boost"] = "DungeonCoins",
    ["Crowns Boost"] = "DungeonCrowns"
}

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

-- 5. LOGIK LOOP (Autofarm, Upgrades & Incubator)
task.spawn(function()
    while true do
        task.wait(0.1)
        
        -- 5a. AUTOFARM LOGIK
        if _G.Hub.Toggles.AutoFarm then
            pcall(function()
                local dungeonStorage = WS:FindFirstChild("DungeonStorage")
                if dungeonStorage then
                    for _, dungeonInstance in pairs(dungeonStorage:GetChildren()) do
                        local important = dungeonInstance:FindFirstChild("Important")
                        if important then
                            local spawnerNames = {"GreenEnemySpawner", "BlueEnemySpawner", "PurpleEnemySpawner", "RedEnemySpawner", "PurpleBossEnemySpawner"}
                            
                            for _, sName in pairs(spawnerNames) do
                                local spawner = important:FindFirstChild(sName)
                                if spawner then
                                    for _, bot in pairs(spawner:GetChildren()) do
                                        local hp = bot:GetAttribute("Health")
                                        local hrp = bot:FindFirstChild("HumanoidRootPart")
                                        
                                        if hp and hp > 0 and hrp then
                                            local char = Player.Character
                                            if char and char:FindFirstChild("HumanoidRootPart") then
                                                -- Teleport über den Bot
                                                local targetPos = hrp.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)
                                                char.HumanoidRootPart.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-_G.Hub.Config.FarmAngle), 0, 0)
                                                
                                                -- Warte bis Bot tot
                                                repeat task.wait(0.1) until not bot.Parent or bot:GetAttribute("Health") <= 0 or not _G.Hub.Toggles.AutoFarm
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- 5b. UPGRADES & INCUBATOR (Jede Sekunde)
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
