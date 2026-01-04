-- ========================================================
-- 🌍 ELEMENTAL ZONE LOGIC (FIXED PATH: ElementZones)
-- ========================================================

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Globale Tabellen sicherstellen
_G.Hub = _G.Hub or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Pfad-Fix: ElementZones (Plural)
local earthSpawnPath = nil
local function UpdatePath()
    local path = WS:FindFirstChild("Gameplay") 
        and WS.Gameplay:FindFirstChild("Map") 
        and WS.Gameplay.Map:FindFirstChild("ElementZones") -- Hier war der Fehler
        and WS.Gameplay.Map.ElementZones:FindFirstChild("Earth") 
        and WS.Gameplay.Map.ElementZones.Earth:FindFirstChild("Model") 
        and WS.Gameplay.Map.ElementZones.Earth.Model:FindFirstChild("Earth")
    earthSpawnPath = path
end

-- Einmal initial suchen
UpdatePath()

-- Zugriff auf den Tab in deinem Loader
local ElementTab = _G.Hub["🌍 Elemental Zone"]

if ElementTab then
    ElementTab:CreateSection("🌍 Earth Zone Farming")

    ElementTab:CreateToggle({
        Name = "Teleport Earth Golems/Boss to Me",
        CurrentValue = false,
        Callback = function(Value) 
            _G.Hub.Toggles.EARTH_ZONE_TELEPORT = Value 
            if Value then UpdatePath() end -- Pfad beim Aktivieren nochmal prüfen
        end
    })

    ElementTab:CreateSection("🛠️ Global Tools")

    -- Slider-Fix (Sicher gegen den 'nil with number' Error)
    ElementTab:CreateSlider({
        Name = "Teleport Distance",
        Min = 0,
        Max = 10,
        CurrentValue = 3,
        Callback = function(Value)
            _G.Hub.EarthDistance = tonumber(Value) or 3
        end
    })

    ElementTab:CreateToggle({
        Name = "Auto Swing",
        CurrentValue = false, 
        Callback = function(Value) 
            _G.Hub.Toggles.AUTO_SWING_ENABLED = Value 
        end
    })
end

-- ========================================================
-- HAUPT-LOGIK (LOOPS)
-- ========================================================

RunService.RenderStepped:Connect(function()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and _G.Hub.Toggles.EARTH_ZONE_TELEPORT then
        -- Falls der Pfad erst später geladen wird
        if not earthSpawnPath then UpdatePath() end
        
        if earthSpawnPath then
            local distance = _G.Hub.EarthDistance or 3
            for _, entity in pairs(earthSpawnPath:GetChildren()) do
                if entity:IsA("Model") then
                    -- Teleportiert Golems/Boss direkt vor dich
                    entity:PivotTo(hrp.CFrame * CFrame.new(0, 0, -distance))
                    
                    -- Verhindert, dass sie weglaufen
                    local hum = entity:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:MoveTo(hrp.Position)
                    end
                end
            end
        end
    end
end)

-- Separater Swing-Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Hub.Toggles.AUTO_SWING_ENABLED then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

return true
