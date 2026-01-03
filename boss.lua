-- ========================================================
-- 👹 BOSS MODULE (SMART FOLLOW, AUTO-DAMAGE & RETURN)
-- ========================================================

local Tab = _G.Hub["👹 Boss"]
local Player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

local originalPosition = nil
local isFarming = false
local bossesDefeated = 0

-- 1. HILFSFUNKTIONEN
local function GetBoss()
    -- Pfad aus deinem SimpleSpy Log
    local path = workspace:FindFirstChild("Gameplay")
    if path and path:FindFirstChild("Boss") and path.Boss:FindFirstChild("BossHolder") then
        return path.Boss.BossHolder:FindFirstChild("Boss")
    end
    return nil
end

local function GetEquippedSword()
    local char = Player.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("RemoteClick") then
            return tool
        end
    end
    return nil
end

-- 2. UI ELEMENTE
Tab:CreateSection("👹 Boss Farm Settings")

Tab:CreateToggle({
    Name = "Smart Boss Farm (TP & Return)",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoBoss = v
        if v then
            -- Position speichern beim Einschalten
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                originalPosition = Player.Character.HumanoidRootPart.CFrame
            end
        else
            -- Sofortiger Rück-TP beim Ausschalten
            if originalPosition and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = originalPosition
                isFarming = false
            end
        end
    end
})

Tab:CreateSection("📊 Status & Stats")
local statusLabel = Tab:CreateLabel("Status: IDLE")
local winLabel = Tab:CreateLabel("Boss Siege: 0")

-- 3. HAUPT-LOOP (LOGIK)
task.spawn(function()
    while true do
        task.wait(0.05) -- Schneller Loop für Damage & Follow
        
        if _G.Hub.Toggles.AutoBoss then
            local boss = GetBoss()
            local sword = GetEquippedSword()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            -- Falls Boss existiert und lebt
            if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and hrp then
                isFarming = true
                statusLabel:Set("Status: ⚔️ Kämpfe gegen Boss")
                
                -- SMART TP & FOLLOW: Klebt direkt hinter dem Boss
                hrp.CFrame = boss.CFrame * CFrame.new(0, 0, 4) -- 4 Studs Abstand
                
                -- DYNAMISCHER DAMAGE (Deine SimpleSpy Logik)
                if sword then
                    pcall(function()
                        local args = {
                            [1] = {
                                [1] = boss
                            }
                        }
                        sword.RemoteClick:FireServer(unpack(args))
                    end)
                end
            else
                -- Boss ist tot oder weg
                statusLabel:Set("Status: ⌛ Warte auf Boss...")
                
                -- Falls wir gerade gefarmt haben und der Boss weg ist -> Zurück nach Hause
                if isFarming and originalPosition and hrp then
                    hrp.CFrame = originalPosition
                    isFarming = false
                    
                    -- Kleiner Zähler für die UI
                    bossesDefeated = bossesDefeated + 1
                    winLabel:Set("Boss Siege: " .. tostring(bossesDefeated))
                end
            end
        end
    end
end)
