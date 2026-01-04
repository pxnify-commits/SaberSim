-- ========================================================
-- 🔥 ELEMENTAL ZONE AUTO FARM ULTIMATE V2 (FULL DEBUG)
-- ========================================================

local Tab = _G.Hub["🔥 Elements"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Globale Tabellen initialisieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.SelectedZones = _G.Hub.Config.SelectedZones or {}
_G.Hub.Config.FireZones = _G.Hub.Config.FireZones or {}
_G.Hub.Config.WaterZones = _G.Hub.Config.WaterZones or {}
_G.Hub.Config.EarthZones = _G.Hub.Config.EarthZones or {}
_G.Hub.Config.CurrentZoneIndex = _G.Hub.Config.CurrentZoneIndex or 1
_G.Hub.Config.ElementFarmHeight = _G.Hub.Config.ElementFarmHeight or 3
_G.Hub.Config.LoadedRegions = _G.Hub.Config.LoadedRegions or {}
_G.Hub.Toggles.FireAutoFarm = false
_G.Hub.Toggles.WaterAutoFarm = false
_G.Hub.Toggles.EarthAutoFarm = false

-- Verhindere doppeltes Laden
if _G.Hub.ElementModuleLoaded then
    warn("⚠️ Element Module bereits geladen! Reload prevented.")
    return
end
_G.Hub.ElementModuleLoaded = true

-- ========================================================
-- 1. ZONE DEFINITIONEN
-- ========================================================
local ZONES = {
    FIRE = {
        {
            name = "🔥 Normal Fire",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Fire.Fire",
            coords = CFrame.new(526.115601, 189.898849, 505.875793, -0.434838206, 0, 0.900508583, 0, 1, 0, -0.900508583, 0, -0.434838206),
            regionName = nil
        },
        {
            name = "🔥 Advanced Fire",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedFireArea.Important.Fire",
            coords = CFrame.new(-136.174622, 36.0004578, 720.73407, -0.402223319, -1.63293965e-08, 0.915541589, -1.95683096e-08, 1, 9.23886567e-09, -0.915541589, -1.41995145e-08, -0.402223319),
            regionName = "AdvancedFireArea"
        },
        {
            name = "🔥 Master Fire",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterFireArea.Important.Fire",
            coords = CFrame.new(-788.333801, 91.3501282, 743.07373, -0.474422753, 4.84729767e-08, 0.880297124, -2.12631903e-08, 1, -6.65238105e-08, -0.880297124, -5.02783344e-08, -0.474422753),
            regionName = "MasterFireArea"
        },
        {
            name = "🔥 Grandmaster Fire",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterFireArea.Important.Fire",
            coords = CFrame.new(-1487.91064, 88.7130203, 777.639832, -0.284725279, 1.11041021e-09, 0.958609164, -1.99946903e-09, 1, -1.75223613e-09, -0.958609164, -2.41561504e-09, -0.284725279),
            regionName = "GrandmasterFireArea"
        }
    },
    
    WATER = {
        {
            name = "💧 Normal Water",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Water.Water",
            coords = CFrame.new(72.1754227, 281.193573, -541.928223, 0.847862661, 1.83689297e-09, 0.530215919, -5.04716935e-10, 1, -2.65733702e-09, -0.530215919, 1.98544781e-09, 0.847862661),
            regionName = nil
        },
        {
            name = "💧 Advanced Water",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedWaterArea.Important.Water",
            coords = CFrame.new(-189.005905, 17.935297, -792.825195, 0.847863078, 0, 0.530215263, 0, 1, 0, -0.530215263, 0, 0.847863078),
            regionName = "AdvancedWaterArea"
        },
        {
            name = "💧 Master Water",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterWaterArea.Important.Water",
            coords = CFrame.new(-735.40033, 88.951355, -1004.21191, 0.902788103, 6.04197083e-08, 0.430085629, -5.98376033e-08, 1, -1.48785144e-08, -0.430085629, -1.23031469e-08, 0.902788103),
            regionName = "MasterWaterArea"
        },
        {
            name = "💧 Grandmaster Water",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterWaterArea.Important.Water",
            coords = CFrame.new(-784.573364, 148.289093, -1568.74023, -0.434830427, -7.10927353e-08, 0.900512338, 4.79472959e-08, 1, 1.020993e-07, -0.900512338, 8.75730137e-08, -0.434830427),
            regionName = "GrandmasterWaterArea"
        }
    },
    
    EARTH = {
        {
            name = "🌍 Normal Earth",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Earth.Earth",
            coords = CFrame.new(768.616455, 209.452179, -284.68576, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839),
            regionName = nil
        },
        {
            name = "🌍 Advanced Earth",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedEarthArea.Important.Earth",
            coords = CFrame.new(1262.17798, -20.3493195, -917.518066, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839),
            regionName = "AdvancedEarthArea"
        },
        {
            name = "🌍 Master Earth",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterEarthArea.Important.Earth",
            coords = CFrame.new(1763.40601, 9.96195698, -979.4198, 0.847855389, -2.30705144e-08, 0.530227542, 3.72692632e-08, 1, -1.60844742e-08, -0.530227542, 3.33985e-08, 0.847855389),
            regionName = "MasterEarthArea"
        },
        {
            name = "🌍 Grandmaster Earth",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterEarthArea.Important.Earth",
            coords = CFrame.new(1908.66284, 9.44594669, -1461.03455, 0.847594619, 0, 0.530644298, 0, 1, 0, -0.530644298, 0, 0.847594619),
            regionName = "GrandmasterEarthArea"
        }
    }
}

-- ========================================================
-- 2. REGION LOADING
-- ========================================================
local function loadRegion(regionName)
    if not regionName then return true end
    
    if _G.Hub.Config.LoadedRegions[regionName] then 
        return true 
    end
    
    local hiddenRegions = RS:FindFirstChild("HiddenRegions")
    if not hiddenRegions then 
        warn("❌ ReplicatedStorage.HiddenRegions nicht gefunden!")
        return false 
    end
    
    local regionFolder = hiddenRegions:FindFirstChild(regionName)
    if not regionFolder then
        warn("❌ Region nicht gefunden: " .. regionName)
        return false
    end
    
    local gameplay = WS:FindFirstChild("Gameplay")
    if not gameplay then return false end
    
    local regionsLoaded = gameplay:FindFirstChild("RegionsLoaded")
    if not regionsLoaded then return false end
    
    if regionsLoaded:FindFirstChild(regionName) then
        _G.Hub.Config.LoadedRegions[regionName] = true
        return true
    end
    
    local success = pcall(function()
        local clonedRegion = regionFolder:Clone()
        clonedRegion.Parent = regionsLoaded
        print("✅ Region geladen: " .. regionName)
    end)
    
    if success then
        _G.Hub.Config.LoadedRegions[regionName] = true
        return true
    end
    return false
end

-- ========================================================
-- 3. HELPER FUNCTIONS
-- ========================================================
local function getZonePath(zone)
    if not zone or not zone.path then return nil end
    
    local parts = {}
    for part in string.gmatch(zone.path, "[^.]+") do
        table.insert(parts, part)
    end
    
    local current = WS
    for _, part in ipairs(parts) do
        current = current:FindFirstChild(part)
        if not current then return nil end
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
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not zonePath then return end
    
    local h = _G.Hub.Config.ElementFarmHeight or 3
    
    for _, entity in pairs(zonePath:GetChildren()) do
        if entity:IsA("Model") then
            pcall(function()
                local enemyHRP = entity:FindFirstChild("HumanoidRootPart")
                local hum = entity:FindFirstChildOfClass("Humanoid")
                
                if enemyHRP and hum and hum.Health > 0 then
                    -- Teleport mit Offset
                    local targetCFrame = hrp.CFrame * CFrame.new(0, 0, -h)
                    enemyHRP.CFrame = targetCFrame
                    
                    -- Velocity entfernen
                    enemyHRP.Velocity = Vector3.new(0, 0, 0)
                    enemyHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    -- Anchoring für bessere Kontrolle
                    if enemyHRP:IsA("BasePart") then
                        enemyHRP.Anchored = false
                    end
                    
                    hum:MoveTo(hrp.Position)
                end
            end)
        end
    end
end

-- ========================================================
-- 4. FARMING LOOPS (GETRENNT PRO ELEMENT)
-- ========================================================

-- FIRE FARMING LOOP
task.spawn(function()
    while task.wait(2) do
        if not _G.Hub.Toggles.FireAutoFarm then continue end
        if #_G.Hub.Config.FireZones == 0 then continue end
        
        pcall(function()
            for zoneIndex, zone in ipairs(_G.Hub.Config.FireZones) do
                if not _G.Hub.Toggles.FireAutoFarm then break end
                
                print("\n🔥 [FIRE] Processing: " .. zone.name)
                
                -- Load Region
                if not loadRegion(zone.regionName) then
                    warn("⚠️ Failed to load region")
                    continue
                end
                
                task.wait(1)
                
                local zonePath = getZonePath(zone)
                if not zonePath then
                    warn("⚠️ Zone path not found")
                    continue
                end
                
                -- Teleport to zone
                local char = Player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = zone.coords
                        print("📍 Teleported to zone")
                        task.wait(3)
                    end
                end
                
                -- Farm until cleared
                local attempts = 0
                while _G.Hub.Toggles.FireAutoFarm and hasEnemiesInZone(zonePath) and attempts < 60 do
                    attempts = attempts + 1
                    task.wait(2)
                end
                
                print("✅ Zone cleared or timeout")
            end
        end)
    end
end)

-- WATER FARMING LOOP
task.spawn(function()
    while task.wait(2) do
        if not _G.Hub.Toggles.WaterAutoFarm then continue end
        if #_G.Hub.Config.WaterZones == 0 then continue end
        
        pcall(function()
            for zoneIndex, zone in ipairs(_G.Hub.Config.WaterZones) do
                if not _G.Hub.Toggles.WaterAutoFarm then break end
                
                print("\n💧 [WATER] Processing: " .. zone.name)
                
                if not loadRegion(zone.regionName) then continue end
                task.wait(1)
                
                local zonePath = getZonePath(zone)
                if not zonePath then continue end
                
                local char = Player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = zone.coords
                        task.wait(3)
                    end
                end
                
                local attempts = 0
                while _G.Hub.Toggles.WaterAutoFarm and hasEnemiesInZone(zonePath) and attempts < 60 do
                    attempts = attempts + 1
                    task.wait(2)
                end
                
                print("✅ Zone cleared")
            end
        end)
    end
end)

-- EARTH FARMING LOOP
task.spawn(function()
    while task.wait(2) do
        if not _G.Hub.Toggles.EarthAutoFarm then continue end
        if #_G.Hub.Config.EarthZones == 0 then continue end
        
        pcall(function()
            for zoneIndex, zone in ipairs(_G.Hub.Config.EarthZones) do
                if not _G.Hub.Toggles.EarthAutoFarm then break end
                
                print("\n🌍 [EARTH] Processing: " .. zone.name)
                
                if not loadRegion(zone.regionName) then continue end
                task.wait(1)
                
                local zonePath = getZonePath(zone)
                if not zonePath then continue end
                
                local char = Player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = zone.coords
                        task.wait(3)
                    end
                end
                
                local attempts = 0
                while _G.Hub.Toggles.EarthAutoFarm and hasEnemiesInZone(zonePath) and attempts < 60 do
                    attempts = attempts + 1
                    task.wait(2)
                end
                
                print("✅ Zone cleared")
            end
        end)
    end
end)

-- ========================================================
-- 5. UNIVERSAL TELEPORT LOOP
-- ========================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Fire Zones
        if _G.Hub.Toggles.FireAutoFarm then
            for _, zone in ipairs(_G.Hub.Config.FireZones) do
                local zonePath = getZonePath(zone)
                if zonePath then
                    teleportEnemiesToPlayer(zonePath)
                end
            end
        end
        
        -- Water Zones
        if _G.Hub.Toggles.WaterAutoFarm then
            for _, zone in ipairs(_G.Hub.Config.WaterZones) do
                local zonePath = getZonePath(zone)
                if zonePath then
                    teleportEnemiesToPlayer(zonePath)
                end
            end
        end
        
        -- Earth Zones
        if _G.Hub.Toggles.EarthAutoFarm then
            for _, zone in ipairs(_G.Hub.Config.EarthZones) do
                local zonePath = getZonePath(zone)
                if zonePath then
                    teleportEnemiesToPlayer(zonePath)
                end
            end
        end
    end)
end)

-- ========================================================
-- 6. AUTO SWING LOOP
-- ========================================================
task.spawn(function()
    while task.wait(0.1) do
        if _G.Hub.Toggles.ElementAutoSwing then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

-- ========================================================
-- 7. UI: FIRE ZONES
-- ========================================================
Tab:CreateSection("🔥 Fire Zones")

for _, zone in ipairs(ZONES.FIRE) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Callback = function(Value)
            pcall(function()
                if Value then
                    -- Prüfe ob schon vorhanden
                    local exists = false
                    for _, z in ipairs(_G.Hub.Config.FireZones) do
                        if z.name == zone.name then
                            exists = true
                            break
                        end
                    end
                    
                    if not exists then
                        if loadRegion(zone.regionName) then
                            table.insert(_G.Hub.Config.FireZones, zone)
                            print("✅ [FIRE] Added: " .. zone.name)
                        end
                    end
                else
                    for i, z in ipairs(_G.Hub.Config.FireZones) do
                        if z.name == zone.name then
                            table.remove(_G.Hub.Config.FireZones, i)
                            print("❌ [FIRE] Removed: " .. zone.name)
                            break
                        end
                    end
                end
            end)
        end
    })
end

Tab:CreateToggle({
    Name = "🚀 Start Fire Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.FireAutoFarm = v
        print(v and "✅ Fire Auto Farm: ON" or "⏸️ Fire Auto Farm: OFF")
    end
})

Tab:CreateButton({
    Name = "🔍 Debug Fire Zones",
    Callback = function()
        print("\n" .. string.rep("=", 50))
        print("🔥 FIRE ZONES DEBUG")
        print(string.rep("=", 50))
        print("Selected Zones: " .. #_G.Hub.Config.FireZones)
        for i, zone in ipairs(_G.Hub.Config.FireZones) do
            print("  " .. i .. ". " .. zone.name)
            local zonePath = getZonePath(zone)
            print("     Path Valid: " .. tostring(zonePath ~= nil))
            if zonePath then
                print("     Enemies: " .. tostring(hasEnemiesInZone(zonePath)))
            end
        end
        print(string.rep("=", 50))
    end
})

Tab:CreateLabel("🔥 Fire Farm [BETA]")

-- ========================================================
-- 8. UI: WATER ZONES
-- ========================================================
Tab:CreateSection("💧 Water Zones")

for _, zone in ipairs(ZONES.WATER) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Callback = function(Value)
            pcall(function()
                if Value then
                    local exists = false
                    for _, z in ipairs(_G.Hub.Config.WaterZones) do
                        if z.name == zone.name then
                            exists = true
                            break
                        end
                    end
                    
                    if not exists then
                        if loadRegion(zone.regionName) then
                            table.insert(_G.Hub.Config.WaterZones, zone)
                            print("✅ [WATER] Added: " .. zone.name)
                        end
                    end
                else
                    for i, z in ipairs(_G.Hub.Config.WaterZones) do
                        if z.name == zone.name then
                            table.remove(_G.Hub.Config.WaterZones, i)
                            print("❌ [WATER] Removed: " .. zone.name)
                            break
                        end
                    end
                end
            end)
        end
    })
end

Tab:CreateToggle({
    Name = "🚀 Start Water Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.WaterAutoFarm = v
        print(v and "✅ Water Auto Farm: ON" or "⏸️ Water Auto Farm: OFF")
    end
})

Tab:CreateButton({
    Name = "🔍 Debug Water Zones",
    Callback = function()
        print("\n" .. string.rep("=", 50))
        print("💧 WATER ZONES DEBUG")
        print(string.rep("=", 50))
        print("Selected Zones: " .. #_G.Hub.Config.WaterZones)
        for i, zone in ipairs(_G.Hub.Config.WaterZones) do
            print("  " .. i .. ". " .. zone.name)
            local zonePath = getZonePath(zone)
            print("     Path Valid: " .. tostring(zonePath ~= nil))
            if zonePath then
                print("     Enemies: " .. tostring(hasEnemiesInZone(zonePath)))
            end
        end
        print(string.rep("=", 50))
    end
})

-- ========================================================
-- 9. UI: EARTH ZONES
-- ========================================================
Tab:CreateSection("🌍 Earth Zones")

for _, zone in ipairs(ZONES.EARTH) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Callback = function(Value)
            pcall(function()
                if Value then
                    local exists = false
                    for _, z in ipairs(_G.Hub.Config.EarthZones) do
                        if z.name == zone.name then
                            exists = true
                            break
                        end
                    end
                    
                    if not exists then
                        if loadRegion(zone.regionName) then
                            table.insert(_G.Hub.Config.EarthZones, zone)
                            print("✅ [EARTH] Added: " .. zone.name)
                        end
                    end
                else
                    for i, z in ipairs(_G.Hub.Config.EarthZones) do
                        if z.name == zone.name then
                            table.remove(_G.Hub.Config.EarthZones, i)
                            print("❌ [EARTH] Removed: " .. zone.name)
                            break
                        end
                    end
                end
            end)
        end
    })
end

Tab:CreateToggle({
    Name = "🚀 Start Earth Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.EarthAutoFarm = v
        print(v and "✅ Earth Auto Farm: ON" or "⏸️ Earth Auto Farm: OFF")
    end
})

Tab:CreateButton({
    Name = "🔍 Debug Earth Zones",
    Callback = function()
        print("\n" .. string.rep("=", 50))
        print("🌍 EARTH ZONES DEBUG")
        print(string.rep("=", 50))
        print("Selected Zones: " .. #_G.Hub.Config.EarthZones)
        for i, zone in ipairs(_G.Hub.Config.EarthZones) do
            print("  " .. i .. ". " .. zone.name)
            local zonePath = getZonePath(zone)
            print("     Path Valid: " .. tostring(zonePath ~= nil))
            if zonePath then
                print("     Enemies: " .. tostring(hasEnemiesInZone(zonePath)))
            end
        end
        print(string.rep("=", 50))
    end
})

-- ========================================================
-- 10. UI: GLOBAL CONTROLS
-- ========================================================
Tab:CreateSection("⚔️ Global Settings")

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.ElementAutoSwing = v
    end
})

pcall(function()
    Tab:CreateSlider({
        Name = "Enemy Distance",
        Range = {2, 20},
        Increment = 1,
        CurrentValue = 3,
        Callback = function(v)
            _G.Hub.Config.ElementFarmHeight = v
        end
    })
end)

-- ========================================================
-- 11. UI: DEBUG SECTION
-- ========================================================
Tab:CreateSection("🔍 Advanced Debug")

Tab:CreateButton({
    Name = "📊 Full System Status",
    Callback = function()
        print("\n" .. string.rep("=", 60))
        print("📊 ELEMENT FARM SYSTEM STATUS")
        print(string.rep("=", 60))
        print("\n🔥 FIRE:")
        print("   Auto Farm: " .. tostring(_G.Hub.Toggles.FireAutoFarm))
        print("   Zones Selected: " .. #_G.Hub.Config.FireZones)
        
        print("\n💧 WATER:")
        print("   Auto Farm: " .. tostring(_G.Hub.Toggles.WaterAutoFarm))
        print("   Zones Selected: " .. #_G.Hub.Config.WaterZones)
        
        print("\n🌍 EARTH:")
        print("   Auto Farm: " .. tostring(_G.Hub.Toggles.EarthAutoFarm))
        print("   Zones Selected: " .. #_G.Hub.Config.EarthZones)
        
        print("\n⚙️ GLOBAL:")
        print("   Auto Swing: " .. tostring(_G.Hub.Toggles.ElementAutoSwing))
        print("   Distance: " .. _G.Hub.Config.ElementFarmHeight)
        
        print("\n📂 LOADED REGIONS:")
        for name, _ in pairs(_G.Hub.Config.LoadedRegions) do
            print("   ✅ " .. name)
        end
        print("\n" .. string.rep("=", 60))
    end
})

Tab:CreateButton({
    Name = "🔍 Deep Scan All Zones",
    Callback = function()
        local allZones = {}
        for _, z in ipairs(_G.Hub.Config.FireZones) do table.insert(allZones, z) end
        for _, z in ipairs(_G.Hub.Config.WaterZones) do table.insert(allZones, z) end
        for _, z in ipairs(_G.Hub.Config.EarthZones) do table.insert(allZones, z) end
        
        print("\n" .. string.rep("=", 60))
        print("🔍 DEEP SCAN - ALL SELECTED ZONES")
        print(string.rep("=", 60))
        
        for _, zone in ipairs(allZones) do
            print("\n📂 " .. zone.name)
            local zonePath = getZonePath(zone)
            
            if not zonePath then
                print("   ❌ Path not found!")
            else
                print("   ✅ Path: " .. zonePath:GetFullName())
                print("   📊 Children:")
                
                for _, child in pairs(zonePath:GetChildren()) do
                    if child:IsA("Model") then
                        local hrp = child:FindFirstChild("HumanoidRootPart")
                        local hum = child:FindFirstChildOfClass("Humanoid")
                        
                        print("      ├─ " .. child.Name)
                        print("      │  ├─ HRP: " .. tostring(hrp ~= nil))
                        print("      │  └─ Humanoid: " .. tostring(hum ~= nil))
                        
                        if hum then
                            print("      │     └─ HP: " .. hum.Health .. "/" .. hum.MaxHealth)
                        end
                    end
                end
            end
        end
        print("\n" .. string.rep("=", 60))
    end
})

Tab:CreateButton({
    Name = "🗑️ Clear All Selections",
    Callback = function()
        _G.Hub.Config.FireZones = {}
        _G.Hub.Config.WaterZones = {}
        _G.Hub.Config.EarthZones = {}
        print("🗑️ All zones cleared!")
    end
})

Tab:CreateButton({
    Name = "🔄 Restart All Farms",
    Callback = function()
        _G.Hub.Toggles.FireAutoFarm = false
        _G.Hub.Toggles.WaterAutoFarm = false
        _G.Hub.Toggles.EarthAutoFarm = false
        task.wait(1)
        print("🔄 All farms stopped. Please restart manually.")
    end
})

print("✅ Element Farm ULTIMATE V2 geladen!")
print("📋 Features:")
print("   ✅ Separate farming per element")
print("   ✅ Can toggle zones during farming")
print("   ✅ Advanced debug tools")
print("   ✅ Improved enemy teleport")
