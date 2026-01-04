-- ========================================================
-- 🏰 DUNGEON AUTOFARM (90° ROTATION FIX)
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
local debugTimer = 0

-- [HIER IST DIE ROTATIONS-LOGIK]
RunService.RenderStepped:Connect(function()
    if _G.Hub.Toggles.AutoFarm and currentTarget then
        local char = Player.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        
        if myHRP and currentTarget.Parent then
            local hp = currentTarget.Parent:GetAttribute("Health")
            if not hp or hp <= 0 then
                currentTarget = nil
                return
            end
            
            -- Berechne Position über dem Gegner
            local targetPosition = currentTarget.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0)
            
            -- DER FIX: CFrame mit 90 Grad Drehung auf der X-Achse
            -- math.rad(-90) lässt den Charakter direkt nach unten schauen
            myHRP.CFrame = CFrame.new(targetPosition) * CFrame.Angles(math.rad(-90), 0, 0)
            
            -- Verhindert Wegdriften
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- [ZIEL-SUCHE LOOP]
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.Hub.Toggles.AutoFarm then
            local dId = Player:GetAttribute("DungeonId")
            if dId then
                pcall(function()
                    local dFolder = WS.DungeonStorage:FindFirstChild(tostring(dId))
                    if dFolder then
                        local important = dFolder:FindFirstChild("Important")
                        local found = false
                        local spawners = {"GreenEnemySpawner", "BlueEnemySpawner", "RedEnemySpawner", "PurpleEnemySpawner", "PurpleBossEnemySpawner"}
                        
                        for _, sName in pairs(spawners) do
                            local sFolder = important:FindFirstChild(sName)
                            if sFolder then
                                for _, bot in pairs(sFolder:GetChildren()) do
                                    local hp = bot:GetAttribute("Health") or 0
                                    if bot:IsA("Model") and hp > 0 then
                                        local hrp = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            currentTarget = hrp
                                            found = true
                                            break
                                        end
                                    end
                                end
                            end
                            if found then break end
                        end
                    end
                end)
            end
        end
    end
end)

-- [RESTLICHE LOGIK: SWING & LOBBY]
-- Hier fügst du einfach deine funktionierenden Buttons für Create/Start ein

Tab:CreateToggle({
    Name = "Enable Autofarm", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoFarm = v 
        currentTarget = nil
        print("🔘 Autofarm: " .. tostring(v))
    end
})

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoSwing = v
    end
})

task.spawn(function()
    while task.wait(0.3) do
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.UIAction:FireServer("Swing")
        end
    end
end)
