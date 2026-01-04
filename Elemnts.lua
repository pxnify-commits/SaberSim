-- ========================================================
-- 🌍 ELEMENTAL ZONE LOGIC (MODULE VERSION)
-- ========================================================

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Globale Status-Variablen (damit die Callbacks darauf zugreifen können)
_G.Hub = _G.Hub or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Toggles.EARTH_ZONE_TELEPORT = false
_G.Hub.Toggles.AUTO_SWING_ENABLED = false

-- Pfad zur Earth Zone (Golems & Boss)
local earthSpawnPath = WS:WaitForChild("Gameplay")
    :WaitForChild("Map")
    :WaitForChild("ElementZone")
    :WaitForChild("Earth")
    :WaitForChild("Model")
    :WaitForChild("Earth")

-- ========================================================
-- UI INTEGRATION (Für deinen Loader)
-- ========================================================
-- Hier nutzt du deinen bestehenden 'ElementTab' Loader
local ElementTab = _G.Hub["🌍 Elemental Zone"] -- Annahme: So heißt dein Tab im Loader

ElementTab:CreateSection("🌍 Earth Zone Farming")

ElementTab:CreateToggle({
    Name = "Teleport Earth Golems/Boss to Me",
    CurrentValue = false,
    Callback = function(Value) 
        _G.Hub.Toggles.EARTH_ZONE_TELEPORT = Value 
    end
})

ElementTab:CreateSection("🛠️ Global Tools")

ElementTab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false, 
    Callback = function(Value) 
        _G.Hub.Toggles.AUTO_SWING_ENABLED = Value 
    end
})

-- ========================================================
-- HAUPT-LOGIK (LOOPS)
-- ========================================================

-- Teleport-Loop für Golems & Boss
RunService.RenderStepped:Connect(function()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and _G.Hub.Toggles.EARTH_ZONE_TELEPORT then
        for _, entity in pairs(earthSpawnPath:GetChildren()) do
            if entity:IsA("Model") then
                -- Teleportiert alles im Ordner (Golems/Boss) 3 Studs vor dich
                entity:PivotTo(hrp.CFrame * CFrame.new(0, 0, -3))
                
                -- Verhindert Weglaufen der KI
                local hum = entity:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:MoveTo(hrp.Position)
                end
            end
        end
    end
end)

-- Auto Swing Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AUTO_SWING_ENABLED then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
        if not _G.Hub.Toggles.AUTO_SWING_ENABLED then
            task.wait(0.5) -- CPU schonen wenn aus
        end
    end
end)

return true
