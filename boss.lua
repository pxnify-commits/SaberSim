-- ========================================================
-- 👹 BOSS MODULE (SMART FOLLOW & RETURN HOME)
-- ========================================================

local Tab = _G.Hub["👹 Boss"]
local Player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

local originalPosition = nil
local isFarming = false

-- 1. FUNKTIONEN
local function GetBoss()
    return workspace:FindFirstChild("Gameplay") 
        and workspace.Gameplay.Boss.BossHolder:FindFirstChild("Boss")
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
Tab:CreateSection("👹 Smart Boss Farm")

Tab:CreateToggle({
    Name = "Start Boss Farm (with Return)",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoBoss = v
        if v then
            -- Position merken, wenn der Toggle eingeschaltet wird
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                originalPosition = Player.Character.HumanoidRootPart.CFrame
                print("🏠 Startposition gespeichert.")
            end
        else
            -- Wenn ausgeschaltet wird, sofort zurück teleportieren
            if originalPosition and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = originalPosition
                print("🚀 Zurück zur Basis.")
            end
        end
    end
})

Tab:CreateLabel("Info: Farmt solange Boss da ist,")
Tab:CreateLabel("danach TP zurück zur Startpos.")

-- 3. HAUPT LOGIK LOOP
task.spawn(function()
    while true do
        task.wait(0.05)
        
        if _G.Hub.Toggles.AutoBoss then
            local boss = GetBoss()
            local sword = GetEquippedSword()
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            -- Falls Boss da ist und lebt
            if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and hrp then
                isFarming = true
                
                -- Follow/Stick Logik: Hinter den Boss teleportieren
                hrp.CFrame = boss.CFrame * CFrame.new(0, 0, 4) -- 4 Studs Abstand
                
                -- Damage Logik (Deine SimpleSpy Remote)
                if sword then
                    pcall(function()
                        local args = {[1] = {[1] = boss}}
                        sword.RemoteClick:FireServer(unpack(args))
                    end)
                end
            else
                -- Boss ist weg oder tot -> Zurückkehren, falls wir gerade gefarmt haben
                if isFarming and originalPosition and hrp then
                    hrp.CFrame = originalPosition
                    isFarming = false
                    print("⌛ Boss weg, warte an Startposition...")
                end
            end
        end
    end
end)
