-- ========================================================
-- 👹 BOSS MODULE (DYNAMIC TOOL DAMAGE LOGIC)
-- ========================================================

local Tab = _G.Hub["👹 Boss"]
local Player = game.Players.LocalPlayer

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

local bossesDefeated = 0

-- 1. UI ELEMENTE
Tab:CreateSection("👹 Boss Farm Settings")

Tab:CreateToggle({
    Name = "Auto Boss Damage (Smart)",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoBoss = v end
})

Tab:CreateToggle({
    Name = "Auto Teleport to Boss",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.BossTP = v end
})

local winLabel = Tab:CreateLabel("Boss Siege: 0")

-- 2. FUNKTION: DAS AUSGERÜSTETE SCHWERT FINDEN
local function GetEquippedSword()
    local char = Player.Character
    if char then
        -- Sucht nach einem Tool im Charakter
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("RemoteClick") then
            return tool
        end
    end
    return nil
end

-- 3. FUNKTION: DEN BOSS IM WORKSPACE FINDEN (Basierend auf deinem Log)
local function GetBossTarget()
    -- Laut deinem Spy-Log liegt der Boss hier:
    local path = workspace:FindFirstChild("Gameplay")
    if path and path:FindFirstChild("Boss") and path.Boss:FindFirstChild("BossHolder") then
        return path.Boss.BossHolder:FindFirstChild("Boss")
    end
    return nil
end

-- 4. BOSS DAMAGE LOOP
task.spawn(function()
    while true do
        task.wait(0.05) -- Schnelle Klicks
        
        if _G.Hub.Toggles.AutoBoss then
            local sword = GetEquippedSword()
            local target = GetBossTarget()
            
            if sword and target then
                -- Teleport zum Boss (falls an)
                if _G.Hub.Toggles.BossTP and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 10, 0)
                end
                
                -- DEINE SPY-LOGIK (Dynamisch angepasst)
                pcall(function()
                    local args = {
                        [1] = {
                            [1] = target
                        }
                    }
                    -- Feuert die RemoteClick des aktuell gehaltenen Schwerts
                    sword.RemoteClick:FireServer(unpack(args))
                end)
            end
        end
    end
end)

-- 5. WIN DETECTION
task.spawn(function()
    while true do
        task.wait(1)
        local target = GetBossTarget()
        if _G.Hub.Toggles.AutoBoss and target and target:FindFirstChild("Humanoid") then
            if target.Humanoid.Health <= 0 then
                bossesDefeated = bossesDefeated + 1
                winLabel:Set("Boss Siege: " .. tostring(bossesDefeated))
                task.wait(5) -- Warten auf Respawn
            end
        end
    end
end)
