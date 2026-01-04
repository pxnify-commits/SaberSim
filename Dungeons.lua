-- ========================================================
-- 🏰 DUNGEON MODULE (COMPLETE & REPAIRED VERSION)
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

-- 2. DYNAMISCHE DATEN LADEN
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

-- 3. UI: MANAGEMENT (Lobby & Start)
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

-- 4. UI: AUTOFARM & SWING
Tab:CreateSection("⚔️ Dungeon Autofarm")

Tab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoFarm = v end
})

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoSwing = v end
})

Tab:CreateSlider({
    Name = "Farm Height (Höhe)",
    Min = 5, Max = 50, CurrentValue = 10,
    Callback = function(v) _G.Hub.Config.FarmHeight = v end
})

-- 5. UI: UPGRADES & INCUBATOR
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

-- 6. HAUPT-LOGIK (TELEPORT & SWING)
task.spawn(function()
    while true do
        task.wait(0.01)
        
        -- --- AUTOFARM LOGIK ---
        if _G.Hub.Toggles.AutoFarm then
            pcall(function()
                local ds = WS:FindFirstChild("DungeonStorage")
                local char = Player.Character
                if ds and char and char.PrimaryPart then
                    -- Findet den aktuellen Dungeon-Ordner
                    local dungeonFolder = nil
                    for _, f in pairs(ds:GetChildren()) do
                        if f:IsA("Folder") and f:FindFirstChild("Important") then
                            dungeonFolder = f
                            break
                        end
                    end
                    
                    if dungeonFolder then
                        local important = dungeonFolder.Important
                        local targetHRP = nil
                        local spawnerList = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}
                        
                        -- Scannt Spawner nach Bots (basierend auf deinen Properties-Bildern)
                        for _, sName in pairs(spawnerList) do
                            if targetHRP then break end
                            for _, spawner in pairs(important:GetChildren()) do
                                if spawner.Name == sName then
                                    for _, bot in pairs(spawner:GetChildren()) do
                                        -- Health Check via Attribute (wie im Bild zu sehen)
                                        local hp = bot:GetAttribute("Health")
                                        if bot:IsA("Model") and hp and hp > 0 then
                                            targetHRP = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                                            if targetHRP then break end
                                        end
                                    end
                                end
                                if targetHRP then break end
                            end
                        end
                        
                        -- Ausführung Teleport (90° Winkel)
                        if targetHRP then
                            char.PrimaryPart.Velocity = Vector3.new(0,0,0)
                            char.PrimaryPart.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                        end
                    end
                end
            end)
        end
        
        -- --- AUTO SWING ---
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)

-- 7. UPGRADES & INCUBATOR LOOP (FIXED INDEX ERROR)
task.spawn(function()
    while true do
        task.wait(1)
        
        -- Auto Upgrade (Fehler behoben: kein ungültiger Index mehr)
        if _G.Hub.Toggles.AutoDungeonUpgrade and selUpgrade then
            pcall(function()
                -- Ruft das Event nur mit dem Upgrade-Namen auf
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade)
            end)
        end
        
        -- Auto Incubator
        if _G.Hub.Toggles.AutoIncubator then
            pcall(function()
                RS.Events.UIAction:FireServer("IncubatorAction", "ClaimAll")
            end)
        end
    end
end)
