-- ========================================================
-- 🏰 DUNGEON MASTER ULTIMATE (COMPLETE CONSOLIDATED VERSION)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Initialisierung der globalen Konfiguration
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local currentTarget = nil
local dungeonNames, diffNames, diffMap = {}, {}, {}
local selDungeon, selDiff = "", ""
local selUpgrade = "DungeonDamage"

-- Sicheres Mapping für Upgrades zur Vermeidung von "index nil with number" Fehlern
local upgradeMapping = {
    ["Damage ⚔️"] = "DungeonDamage",
    ["Health ❤️"] = "DungeonHealth",
    ["Crit Chance 💥"] = "DungeonCritChance",
    ["Coins 💰"] = "DungeonCoins",
    ["Egg Slots 🥚"] = "DungeonEggSlots"
}

-- 1. DYNAMISCHE DATEN-LOGIK MIT ERROR-BACKUPS
local function RefreshDungeonData()
    local success, Info = pcall(function() 
        return require(RS.Modules:WaitForChild("DungeonInfo", 3)) 
    end)
    
    if success and Info and Info.Dungeons and Info.Difficulties then
        dungeonNames = {}
        for name, _ in pairs(Info.Dungeons) do table.insert(dungeonNames, name) end
        
        diffNames = {}
        diffMap = {}
        for index, data in ipairs(Info.Difficulties) do
            table.insert(diffNames, data.Name)
            diffMap[data.Name] = index
        end
    else
        warn("⚠️ Modul nicht gefunden! Benutze Error-Backups.")
        -- Deine spezifischen Backup-Vorgaben
        dungeonNames = {"Error404", "Error405", "Error406", "Error407", "Error505"}
        diffNames = {"Error408", "Error409", "Error410", "Error411"}
        diffMap = {
            ["Error408"] = 1, 
            ["Error409"] = 2, 
            ["Error410"] = 3, 
            ["Error411"] = 4
        }
    end
    
    selDungeon = dungeonNames[1] or "Error404"
    selDiff = diffNames[1] or "Error408"
end
RefreshDungeonData()

-- 2. UI SECTION: LOBBY MANAGEMENT
Tab:CreateSection("🏛️ Lobby Management")

Tab:CreateDropdown({
    Name = "Select Dungeon", 
    Options = dungeonNames, 
    CurrentOption = selDungeon, 
    Callback = function(v) 
        selDungeon = (type(v) == "table" and v[1]) or tostring(v) 
    end
})

Tab:CreateDropdown({
    Name = "Select Difficulty", 
    Options = diffNames, 
    CurrentOption = selDiff, 
    Callback = function(v) 
        selDiff = (type(v) == "table" and v[1]) or tostring(v) 
    end
})

Tab:CreateButton({
    Name = "🔨 Create Lobby", 
    Callback = function() 
        local dIndex = diffMap[selDiff] or 1
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", "Public", selDungeon, dIndex) 
    end
})

Tab:CreateButton({
    Name = "▶️ Start Dungeon", 
    Callback = function() 
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Start") 
    end
})

-- 3. UI SECTION: FARMING & LIVE SLIDER
Tab:CreateSection("⚔️ Dungeon Farming")

Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        currentTarget = nil 
    end
})

Tab:CreateToggle({
    Name = "Auto Swing", 
    CurrentValue = false, 
    Callback = function(v) _G.Hub.Toggles.AutoSwing = v end
})

Tab:CreateSlider({
    Name = "Farm Height (Abstand)", 
    Min = 2, 
    Max = 50, 
    CurrentValue = _G.Hub.Config.FarmHeight, 
    Callback = function(v) 
        _G.Hub.Config.FarmHeight = tonumber(v)
    end
})

-- 4. UI SECTION: UPGRADES
Tab:CreateSection("🆙 Dungeon Upgrades")

Tab:CreateDropdown({
    Name = "Select Upgrade Type",
    Options = {"Damage ⚔️", "Health ❤️", "Crit Chance 💥", "Coins 💰", "Egg Slots 🥚"},
    CurrentOption = "Damage ⚔️",
    Callback = function(v)
        local display = (type(v) == "table" and v[1]) or tostring(v)
        selUpgrade = upgradeMapping[display] or "DungeonDamage"
    end
})

Tab:CreateToggle({
    Name = "Auto Buy Upgrades",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoUpgrade = v end
})

-- 5. LOGIK: AUTO UPGRADE LOOP (Sicher gegen Nil-Fehler)
task.spawn(function()
    while true do
        task.wait(1)
        if _G.Hub.Toggles.AutoUpgrade and selUpgrade then
            pcall(function()
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade)
            end)
        end
    end
end)

-- 6. GEGNER-ERKENNUNG (Prüft Attribute und Humanoids)
local function GetNextTarget()
    local dId = Player:GetAttribute("DungeonId")
    if not dId then return nil end
    
    local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
    if not dFolder or not dFolder:FindFirstChild("Important") then return nil end
    
    local target = nil
    for _, folder in pairs(dFolder.Important:GetChildren()) do
        if folder.Name:find("Spawner") then
            for _, bot in pairs(folder:GetChildren()) do
                local hp = bot:GetAttribute("Health") or (bot:FindFirstChildOfClass("Humanoid") and bot:FindFirstChildOfClass("Humanoid").Health) or 0
                if hp > 0 then
                    target = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                    if target then break end
                end
            end
        end
        if target then break end
    end
    return target
end

-- 7. LIVE LOGIK: 90° ROTATION & LIVE HEIGHT POSITIONING
RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm then
        -- Validierung des Ziels
        if not currentTarget or not currentTarget.Parent or (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
            currentTarget = GetNextTarget()
        end
        
        if currentTarget then
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Nutzt den Slider-Wert live aus der globalen Config
                local h = _G.Hub.Config.FarmHeight or 10
                hrp.CFrame = CFrame.new(currentTarget.Position + Vector3.new(0, h, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- 8. AUTO SWING LOOP
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)

print("✅ Dungeon Script geladen: Error-Backups aktiv, Upgrade-Fix integriert und Slider live-fähig.")
