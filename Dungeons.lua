-- ========================================================
-- 🏰 DUNGEON MASTER ULTIMATE (ALL-IN-ONE & SAFE)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Globale Tabellen initialisieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local currentTarget = nil
local dungeonNames = {"Error404", "Error405", "Error406", "Error407", "Error505"}
local diffNames = {"Error408", "Error409", "Error410", "Error411"}
local diffMap = {["Error408"] = 1, ["Error409"] = 2, ["Error410"] = 3, ["Error411"] = 4}
local selDungeon, selDiff = dungeonNames[1], diffNames[1]
local selUpgrade = "DungeonDamage"

-- Sicheres Upgrade-Mapping
local upgradeMapping = {
    ["Damage ⚔️"] = "DungeonDamage",
    ["Health ❤️"] = "DungeonHealth",
    ["Crit Chance 💥"] = "DungeonCritChance",
    ["Coins 💰"] = "DungeonCoins",
    ["Egg Slots 🥚"] = "DungeonEggSlots"
}

-- 1. DYNAMISCHE DATEN-LOGIK (SICHERER REWORK)
local function RefreshDungeonData()
    local success, Info = pcall(function() 
        return require(RS.Modules:WaitForChild("DungeonInfo", 2)) 
    end)
    
    if success and Info and type(Info.Dungeons) == "table" then
        dungeonNames = {}
        for name, _ in pairs(Info.Dungeons) do table.insert(dungeonNames, name) end
        
        if type(Info.Difficulties) == "table" then
            diffNames = {}
            diffMap = {}
            for index, data in ipairs(Info.Difficulties) do
                table.insert(diffNames, data.Name)
                diffMap[data.Name] = index
            end
        end
    else
        warn("⚠️ Nutze Error-Backups für Namen.")
    end
end
RefreshDungeonData()

-- 2. UI: LOBBY & FARMING
Tab:CreateSection("🏛️ Lobby & Farming")

Tab:CreateDropdown({
    Name = "Select Dungeon", Options = dungeonNames, CurrentOption = selDungeon, 
    Callback = function(v) selDungeon = (type(v) == "table" and v[1]) or tostring(v) end
})

Tab:CreateDropdown({
    Name = "Select Difficulty", Options = diffNames, CurrentOption = selDiff, 
    Callback = function(v) selDiff = (type(v) == "table" and v[1]) or tostring(v) end
})

Tab:CreateButton({
    Name = "🔨 Create Lobby", 
    Callback = function() 
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Create", "Public", selDungeon, diffMap[selDiff] or 1) 
    end
})

Tab:CreateButton({
    Name = "▶️ Start Dungeon", 
    Callback = function() 
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Start") 
    end
})

Tab:CreateToggle({
    Name = "Enable Autofarm", CurrentValue = false, 
    Callback = function(v) _G.Hub.Toggles.AutoFarm = v currentTarget = nil end
})

Tab:CreateSlider({
    Name = "Farm Height (Abstand)", Min = 2, Max = 50, CurrentValue = _G.Hub.Config.FarmHeight, 
    Callback = function(v) _G.Hub.Config.FarmHeight = tonumber(v) end
})

-- 3. UI: UPGRADES
Tab:CreateSection("🆙 Smart Upgrades")

Tab:CreateDropdown({
    Name = "Target Upgrade",
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

-- 4. LOGIK: UPGRADE LOOP (ABSOLUT SICHER)
task.spawn(function()
    while true do
        task.wait(1.5)
        if _G.Hub.Toggles.AutoUpgrade and selUpgrade then
            pcall(function()
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade)
            end)
        end
    end
end)

-- 5. GEGNER-ERKENNUNG (AGRESSIV & FEHLERFREI)
local function GetNextTarget()
    local dId = Player:GetAttribute("DungeonId")
    if not dId then return nil end
    local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
    if not dFolder or not dFolder:FindFirstChild("Important") then return nil end
    
    for _, folder in pairs(dFolder.Important:GetChildren()) do
        if folder.Name:find("Spawner") then
            for _, bot in pairs(folder:GetChildren()) do
                local hp = bot:GetAttribute("Health") or (bot:FindFirstChildOfClass("Humanoid") and bot:FindFirstChildOfClass("Humanoid").Health) or 0
                if hp > 0 then
                    return bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                end
            end
        end
    end
    return nil
end

-- 6. POSITIONIERUNG (LIVE & ROTIERT)
RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm then
        if not currentTarget or not currentTarget.Parent or (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
            currentTarget = GetNextTarget()
        end
        if currentTarget then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local h = _G.Hub.Config.FarmHeight or 10
                hrp.CFrame = CFrame.new(currentTarget.Position + Vector3.new(0, h, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- 7. TOOLS
Tab:CreateSection("🛠️ Tools")
Tab:CreateToggle({Name = "Auto Swing", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.AutoSwing = v end})

task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)

print("✅ Full Script geladen: Alle Funktionen aktiv & Safe-Mode für Upgrades.")
