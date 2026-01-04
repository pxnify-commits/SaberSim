-- ========================================================
-- 🔥 ELEMENTAL ZONE AUTO FARM MODULE
-- Für Error Dynamics Modular System
-- ========================================================

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Zugriff auf das Tab aus dem Loader
local Tab = _G.Hub["🔥 Elements"]

-- Initialisiere globale Variablen
_G.Hub.Toggles.AUTO_SWING_ENABLED = _G.Hub.Toggles.AUTO_SWING_ENABLED or false
_G.Hub.Toggles.AUTO_FARM_ENABLED = _G.Hub.Toggles.AUTO_FARM_ENABLED or false
_G.Hub.Config.SelectedZones = _G.Hub.Config.SelectedZones or {}
_G.Hub.Config.CurrentZoneIndex = _G.Hub.Config.CurrentZoneIndex or 1

-- ========================================================
-- ZONE DEFINITIONEN
-- ========================================================
local ZONES = {
    -- FIRE ZONES
    FIRE = {
        {
            name = "🔥 Normal Fire",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Fire.Fire.Fire",
            coords = CFrame.new(526.115601, 189.898849, 505.875793, -0.434838206, 0, 0.900508583, 0, 1, 0, -0.900508583, 0, -0.434838206)
        },
        {
            name = "🔥 Advanced Fire",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedFireArea.Important.Fire.Fire",
            coords = CFrame.new(-136.174622, 36.0004578, 720.73407, -0.402223319, -1.63293965e-08, 0.915541589, -1.95683096e-08, 1, 9.23886567e-09, -0.915541589, -1.41995145e-08, -0.402223319)
        },
        {
            name = "🔥 Master Fire",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterFireArea.Important.Fire.Fire",
            coords = CFrame.new(-788.333801, 91.3501282, 743.07373, -0.474422753, 4.84729767e-08, 0.880297124, -2.12631903e-08, 1, -6.65238105e-08, -0.880297124, -5.02783344e-08, -0.474422753)
        },
        {
            name = "🔥 Grandmaster Fire",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterFireArea.Important.Fire.Fire",
            coords = CFrame.new(-1487.91064, 88.7130203, 777.639832, -0.284725279, 1.11041021e-09, 0.958609164, -1.99946903e-09, 1, -1.75223613e-09, -0.958609164, -2.41561504e-09, -0.284725279)
        }
    },
    
    -- WATER ZONES
    WATER = {
        {
            name = "💧 Normal Water",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Water.Water.Water",
            coords = CFrame.new(72.1754227, 281.193573, -541.928223, 0.847862661, 1.83689297e-09, 0.530215919, -5.04716935e-10, 1, -2.65733702e-09, -0.530215919, 1.98544781e-09, 0.847862661)
        },
        {
            name = "💧 Advanced Water",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedWaterArea.Important.Water.Water",
            coords = CFrame.new(-189.005905, 17.935297, -792.825195, 0.847863078, 0, 0.530215263, 0, 1, 0, -0.530215263, 0, 0.847863078)
        },
        {
            name = "💧 Master Water",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterWaterArea.Important.Water.Water",
            coords = CFrame.new(-735.40033, 88.951355, -1004.21191, 0.902788103, 6.04197083e-08, 0.430085629, -5.98376033e-08, 1, -1.48785144e-08, -0.430085629, -1.23031469e-08, 0.902788103)
        },
        {
            name = "💧 Grandmaster Water",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterWaterArea.Important.Water.Water",
            coords = CFrame.new(-784.573364, 148.289093, -1568.74023, -0.434830427, -7.10927353e-08, 0.900512338, 4.79472959e-08, 1, 1.020993e-07, -0.900512338, 8.75730137e-08, -0.434830427)
        }
    },
    
    -- EARTH ZONES
    EARTH = {
        {
            name = "🌍 Normal Earth",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Earth.Earth.Earth",
            coords = CFrame.new(768.616455, 209.452179, -284.68576, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839)
        },
        {
            name = "🌍 Advanced Earth",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedEarthArea.Important.Earth.Earth",
            coords = CFrame.new(1262.17798, -20.3493195, -917.518066, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839)
        },
        {
            name = "🌍 Master Earth",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterEarthArea.Important.Earth.Earth",
            coords = CFrame.new(1763.40601, 9.96195698, -979.4198, 0.847855389, -2.30705144e-08, 0.530227542, 3.72692632e-08, 1, -1.60844742e-08, -0.530227542, 3.33985e-08, 0.847855389)
        },
        {
            name = "🌍 Grandmaster Earth",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterEarthArea.Important.Earth.Earth",
            coords = CFrame.new(1908.66284, 9.44594669, -1461.03455, 0.847594619, 0, 0.530644298, 0, 1, 0, -0.530644298, 0, 0.847594619)
        }
    }
}

-- ========================================================
-- HELPER FUNCTIONS
-- ========================================================
local function getZonePath(zone)
    local parts = {}
    for part in string.gmatch(zone.path, "[^.]+") do
        table.insert(parts, part)
    end
    
    local current = WS
    for _, part in ipairs(parts) do
        current = current:FindFirstChild(part)
        if not current then
            return nil
        end
    end
    return current
end

local function hasEnemiesInZone(zonePath)
    if not zonePath then return false end
    
    for _, entity in pairs(zonePath:GetChildren()) do
        if entity:IsA("Model") then
            local hum = entity:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function teleportEnemiesToPlayer(zonePath)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not zonePath then return end
    
    for _, entity in pairs(zonePath:GetChildren()) do
        if entity:IsA("Model") then
            local hum = entity:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetCFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                pcall(function()
                    entity:PivotTo(targetCFrame)
                    hum:MoveTo(hrp.Position)
                end)
            end
        end
    end
end

local function getNextZone()
    if #_G.Hub.Config.SelectedZones == 0 then return nil end
    
    _G.Hub.Config.CurrentZoneIndex = _G.Hub.Config.CurrentZoneIndex + 1
    if _G.Hub.Config.CurrentZoneIndex > #_G.Hub.Config.SelectedZones then
        _G.Hub.Config.CurrentZoneIndex = 1
    end
    
    return _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
end

-- ========================================================
-- AUTO FARM LOOP (NUR EINMAL STARTEN)
-- ========================================================
if not _G.Hub.Functions.ElementFarmLoop then
    _G.Hub.Functions.ElementFarmLoop = true
    
    task.spawn(function()
        while true do
            task.wait(0.5)
            
            if _G.Hub.Toggles.AUTO_FARM_ENABLED and #_G.Hub.Config.SelectedZones > 0 then
                local currentZone = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
                local zonePath = getZonePath(currentZone)
                
                -- Teleport zur Zone
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    local distance = (hrp.Position - currentZone.coords.Position).Magnitude
                    
                    if distance > 50 then
                        hrp.CFrame = currentZone.coords
                        print("📍 Teleporting to: " .. currentZone.name)
                        task.wait(2)
                    end
                end
                
                -- Check ob Zone clear ist
                if not hasEnemiesInZone(zonePath) then
                    print("✅ Zone cleared: " .. currentZone.name)
                    getNextZone()
                    task.wait(1)
                end
            end
        end
    end)
end

-- ========================================================
-- ENEMY TELEPORT LOOP
-- ========================================================
if not _G.Hub.Functions.ElementTeleportLoop then
    _G.Hub.Functions.ElementTeleportLoop = true
    
    RunService.RenderStepped:Connect(function()
        if _G.Hub.Toggles.AUTO_FARM_ENABLED and #_G.Hub.Config.SelectedZones > 0 then
            local currentZone = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
            local zonePath = getZonePath(currentZone)
            
            if zonePath then
                teleportEnemiesToPlayer(zonePath)
            end
        end
    end)
end

-- ========================================================
-- AUTO SWING LOOP
-- ========================================================
if not _G.Hub.Functions.AutoSwingLoop then
    _G.Hub.Functions.AutoSwingLoop = true
    
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
end

-- ========================================================
-- UI CREATION
-- ========================================================

-- ========== FIRE ZONES ==========
Tab:CreateSection("🔥 Fire Zones")

for _, zone in ipairs(ZONES.FIRE) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Flag = "Fire_" .. zone.name,
        Callback = function(Value)
            if Value then
                table.insert(_G.Hub.Config.SelectedZones, zone)
                print("✅ Added: " .. zone.name)
            else
                for i, z in ipairs(_G.Hub.Config.SelectedZones) do
                    if z.name == zone.name then
                        table.remove(_G.Hub.Config.SelectedZones, i)
                        print("❌ Removed: " .. zone.name)
                        break
                    end
                end
            end
        end
    })
end

Tab:CreateLabel("🔥 Fire Farm [BETA]")

-- ========== WATER ZONES ==========
Tab:CreateSection("💧 Water Zones")

for _, zone in ipairs(ZONES.WATER) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Flag = "Water_" .. zone.name,
        Callback = function(Value)
            if Value then
                table.insert(_G.Hub.Config.SelectedZones, zone)
                print("✅ Added: " .. zone.name)
            else
                for i, z in ipairs(_G.Hub.Config.SelectedZones) do
                    if z.name == zone.name then
                        table.remove(_G.Hub.Config.SelectedZones, i)
                        print("❌ Removed: " .. zone.name)
                        break
                    end
                end
            end
        end
    })
end

-- ========== EARTH ZONES ==========
Tab:CreateSection("🌍 Earth Zones")

for _, zone in ipairs(ZONES.EARTH) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Flag = "Earth_" .. zone.name,
        Callback = function(Value)
            if Value then
                table.insert(_G.Hub.Config.SelectedZones, zone)
                print("✅ Added: " .. zone.name)
            else
                for i, z in ipairs(_G.Hub.Config.SelectedZones) do
                    if z.name == zone.name then
                        table.remove(_G.Hub.Config.SelectedZones, i)
                        print("❌ Removed: " .. zone.name)
                        break
                    end
                end
            end
        end
    })
end

-- ========== CONTROLS ==========
Tab:CreateSection("⚙️ Controls")

Tab:CreateToggle({
    Name = "🚀 Start Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm_Toggle",
    Callback = function(Value)
        _G.Hub.Toggles.AUTO_FARM_ENABLED = Value
        
        if Value then
            if #_G.Hub.Config.SelectedZones == 0 then
                warn("⚠️ No zones selected! Please select at least one zone.")
                _G.Hub.Toggles.AUTO_FARM_ENABLED = false
            else
                print("🚀 Auto Farm Started! Farming " .. #_G.Hub.Config.SelectedZones .. " zones.")
            end
        else
            print("⏹️ Auto Farm Stopped!")
        end
    end
})

Tab:CreateToggle({
    Name = "⚔️ Auto Swing",
    CurrentValue = false,
    Flag = "AutoSwing_Toggle",
    Callback = function(Value)
        _G.Hub.Toggles.AUTO_SWING_ENABLED = Value
        print(Value and "⚔️ Auto Swing: ON" or "⚔️ Auto Swing: OFF")
    end
})

Tab:CreateButton({
    Name = "🗑️ Clear All Selections",
    Callback = function()
        _G.Hub.Config.SelectedZones = {}
        _G.Hub.Config.CurrentZoneIndex = 1
        print("🗑️ All zone selections cleared!")
    end
})

Tab:CreateButton({
    Name = "📊 Show Selected Zones",
    Callback = function()
        if #_G.Hub.Config.SelectedZones == 0 then
            print("📊 No zones selected.")
        else
            print("📊 Selected Zones (" .. #_G.Hub.Config.SelectedZones .. "):")
            for i, zone in ipairs(_G.Hub.Config.SelectedZones) do
                print("  " .. i .. ". " .. zone.name)
            end
        end
    end
})

print("✅ Element Farm Module loaded successfully!")
```

**Änderungen für deinen Loader:**
1. ✅ **`local Tab = _G.Hub["🔥 Elements"]`** - Greift auf dein Tab zu
2. ✅ **Alle Variablen in `_G.Hub`** gespeichert (Toggles, Config, Functions)
3. ✅ **Loop-Guards** verhindern Doppel-Ausführung
4. ✅ **Flags für Rayfield Config-Saving** hinzugefügt
5. ✅ **Debug-Prints** für besseres Tracking

**Upload auf GitHub:**
```
https://raw.githubusercontent.com/pxnify-commits/SaberSim/main/Elements.lua
