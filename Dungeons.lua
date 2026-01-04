-- ========================================================
-- 🏰 DUNGEON ULTIMATE - CLEAN VERSION (LOBBY + 90° FARM)
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
local selDungeon, selDiff = "Space", "Easy"
local diffMap = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3, ["Nightmare"] = 4}

-- ========================================================
-- UI SECTION: LOBBY MANAGEMENT
-- ========================================================
Tab:CreateSection("🏛️ Lobby Management")

Tab:CreateDropdown({
    Name = "Select Dungeon", 
    Options = {"Space", "Castle", "Forest", "Desert"}, 
    CurrentOption = "Space", 
    Callback = function(v) selDungeon = v end
})

Tab:CreateDropdown({
    Name = "Select Difficulty", 
    Options = {"Easy", "Medium", "Hard", "Nightmare"}, 
    CurrentOption = "Easy", 
    Callback = function(v) selDiff = v end
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

-- ========================================================
-- UI SECTION: FARMING
-- ========================================================
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
    Name = "Farm Height", 
    Min = 5, Max = 30, 
    CurrentValue = 10, 
    Callback = function(v) _G.Hub.Config.FarmHeight = v end
})

-- ========================================================
-- LOGIC: AGGRESSIVE TARGET SCANNER
-- ========================================================
local function GetNextTarget()
    local dId = Player:GetAttribute("DungeonId")
    if not dId then return nil end
    
    local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
    if not dFolder or not dFolder:FindFirstChild("Important") then return nil end
    
    -- Sucht in allen möglichen Spawner-Ordnern
    local spawners = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "BlueEnemySpawner", "PurpleBossEnemySpawner"}
    
    for _, sName in pairs(spawners) do
        local folder = dFolder.Important:FindFirstChild(sName)
        if folder then
            for _, bot in pairs(folder:GetChildren()) do
                -- Prüft sowohl das Attribut "Health" als auch einen möglichen Humanoid
                local hp = bot:GetAttribute("Health") or (bot:FindFirstChildOfClass("Humanoid") and bot:FindFirstChildOfClass("Humanoid").Health) or 0
                if hp > 0 then
                    local hrp = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                    if hrp then return hrp end
                end
            end
        end
    end
    return nil
end

-- ========================================================
-- LOGIC: 90° ROTATION & FOLLOW (RENDERSTEPPED)
-- ========================================================
RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm then
        -- Falls kein Ziel oder Ziel tot, such ein neues
        if not currentTarget or not currentTarget.Parent or (currentTarget.Parent:GetAttribute("Health") or 0) <= 0 then
            currentTarget = GetNextTarget()
        end
        
        if currentTarget then
            local char = Player.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            
            if myHRP then
                -- Positionierung exakt über dem Gegner mit 90 Grad Neigung
                local targetPos = currentTarget.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)
                myHRP.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
                
                -- Physik stoppen
                myHRP.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- ========================================================
-- LOGIC: AUTO SWING
-- ========================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)

print("✅ Dungeon Script geladen - Upgrade-Logik entfernt, 90° Farm aktiv.")
