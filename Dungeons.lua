-- ========================================================
-- 🏰 DUNGEON DYNAMIC MASTER (LIVE HEIGHT & BACKUP NAMES)
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
-- Standardhöhe auf 10 setzen
_G.Hub.Config.FarmHeight = _G.Hub.Config.FarmHeight or 10

local currentTarget = nil
local dungeonNames, diffNames, diffMap = {}, {}, {}
local selDungeon, selDiff = "", ""

-- 1. DYNAMISCHE DATEN MIT DEINEN BACKUP-NAMEN
local function RefreshDungeonData()
    local success, Info = pcall(function() 
        return require(RS.Modules:WaitForChild("DungeonInfo", 3)) 
    end)
    
    if success and Info then
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
        dungeonNames = {"Error404", "Error405", "Error406", "Error407", "Error505"}
        diffNames = {"Error408", "Error409", "Error410", "Error411"}
        diffMap = {["Error408"] = 1, ["Error409"] = 2, ["Error410"] = 3, ["Error411"] = 4}
    end
    
    selDungeon = dungeonNames[1] or "Error404"
    selDiff = diffNames[1] or "Easy"
end
RefreshDungeonData()

-- 2. UI SECTION: LOBBY
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

-- 3. UI SECTION: FARMING (JETZT MIT LIVE-SLIDER)
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

-- Der Slider passt _G.Hub.Config.FarmHeight live an
Tab:CreateSlider({
    Name = "Farm Height (Abstand)", 
    Min = 2, 
    Max = 40, 
    CurrentValue = _G.Hub.Config.FarmHeight, 
    Callback = function(v) 
        _G.Hub.Config.FarmHeight = v 
        print("📏 Neue Farm-Höhe: " .. v)
    end
})

-- 4. GEGNER-ERKENNUNG (DYNAMIC)
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

-- 5. LIVE 90° LOGIC (NUTZT DIE SLIDER-VARIABLE)
RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm then
        if not currentTarget or not currentTarget.Parent or (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
            currentTarget = GetNextTarget()
        end
        
        if currentTarget then
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Hier wird der Wert vom Slider direkt benutzt: _G.Hub.Config.FarmHeight
                local targetPos = currentTarget.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)
                hrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- 6. AUTO SWING
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)

print("✅ Dungeon Script mit Live-Slider und Backup-Namen geladen!")
