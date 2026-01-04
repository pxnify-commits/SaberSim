-- ========================================================
-- 🔥 ELEMENTAL ZONE AUTO FARM ULTIMATE (DEBUG VERSION)
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
_G.Hub.Config.CurrentZoneIndex = _G.Hub.Config.CurrentZoneIndex or 1
_G.Hub.Config.ElementFarmHeight = _G.Hub.Config.ElementFarmHeight or 3
_G.Hub.Config.LoadedRegions = _G.Hub.Config.LoadedRegions or {}

-- Verhindere doppeltes Laden
if _G.Hub.ElementModuleLoaded then
    warn("⚠️ Element Module bereits geladen!")
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
-- 2. REGION LOADING FUNCTIONS
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
        warn("❌ Region nicht in HiddenRegions gefunden: " .. regionName)
        return false
    end
    
    local gameplay = WS:FindFirstChild("Gameplay")
    if not gameplay then
        warn("❌ Workspace.Gameplay nicht gefunden!")
        return false
    end
    
    local regionsLoaded = gameplay:FindFirstChild("RegionsLoaded")
    if not regionsLoaded then
        warn("❌ Workspace.Gameplay.RegionsLoaded nicht gefunden!")
        return false
    end
    
    if regionsLoaded:FindFirstChild(regionName) then
        _G.Hub.Config.LoadedRegions[regionName] = true
        return true
    end
    
    local success, err = pcall(function()
        local clonedRegion = regionFolder:Clone()
        clonedRegion.Parent = regionsLoaded
        print("✅ Region geladen: " .. regionName)
    end)
    
    if success then
        _G.Hub.Config.LoadedRegions[regionName] = true
        return true
    else
        warn("❌ Fehler beim Laden: " .. tostring(err))
        return false
    end
end

-- ========================================================
-- 3. HELPER FUNCTIONS (VERBESSERT MIT DEBUG)
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
        if not current then 
            return nil 
        end
    end
    return current
end

local function hasEnemiesInZone(zonePath)
    if not zonePath then 
        warn("⚠️ hasEnemiesInZone: zonePath ist nil!")
        return false 
    end
    
    local foundEnemies = 0
    
    for _, entity in pairs(zonePath:GetChildren()) do
        -- DEBUG: Zeige alle Children
        print("  Checking: " .. entity.Name .. " (" .. entity.ClassName .. ")")
        
        if entity:IsA("Model") then
            local hrp = entity:FindFirstChild("HumanoidRootPart")
            local hum = entity:FindFirstChildOfClass("Humanoid")
            
            print("    HRP: " .. tostring(hrp ~= nil) .. " | Humanoid: " .. tostring(hum ~= nil))
            
            if hrp and hum and hum.Health > 0 then
                foundEnemies = foundEnemies + 1
                print("    ✅ Found alive enemy: " .. entity.Name .. " (HP: " .. hum.Health .. ")")
            end
        end
    end
    
    print("📊 Total enemies found: " .. foundEnemies)
    return foundEnemies > 0
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
                
                if enemyHRP then
                    local targetCFrame = hrp.CFrame * CFrame.new(0, 0, -h)
                    enemyHRP.CFrame = targetCFrame
                    enemyHRP.Velocity = Vector3.new(0, 0, 0)
                    enemyHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    local hum = entity:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:MoveTo(hrp.Position)
                    end
                end
            end)
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
-- 4. UI SECTION: FIRE ZONES
-- ========================================================
Tab:CreateSection("🔥 Fire Zones")

for _, zone in ipairs(ZONES.FIRE) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                if loadRegion(zone.regionName) then
                    table.insert(_G.Hub.Config.SelectedZones, zone)
                    print("✅ Added: " .. zone.name)
                else
                    warn("❌ Failed to load region for: " .. zone.name)
                end
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

-- ========================================================
-- 5. UI SECTION: WATER ZONES
-- ========================================================
Tab:CreateSection("💧 Water Zones")

for _, zone in ipairs(ZONES.WATER) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                if loadRegion(zone.regionName) then
                    table.insert(_G.Hub.Config.SelectedZones, zone)
                    print("✅ Added: " .. zone.name)
                else
                    warn("❌ Failed to load region for: " .. zone.name)
                end
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

-- ========================================================
-- 6. UI SECTION: EARTH ZONES
-- ========================================================
Tab:CreateSection("🌍 Earth Zones")

for _, zone in ipairs(ZONES.EARTH) do
    Tab:CreateToggle({
        Name = zone.displayName,
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                if loadRegion(zone.regionName) then
                    table.insert(_G.Hub.Config.SelectedZones, zone)
                    print("✅ Added: " .. zone.name)
                else
                    warn("❌ Failed to load region for: " .. zone.name)
                end
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

-- ========================================================
-- 7. UI SECTION: FARMING CONTROLS
-- ========================================================
Tab:CreateSection("⚔️ Element Farming")

Tab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.ElementAutoFarm = v
        
        if v then
            if #_G.Hub.Config.SelectedZones == 0 then
                warn("⚠️ No zones selected!")
                _G.Hub.Toggles.ElementAutoFarm = false
            else
                print("✅ Auto Farm aktiviert - " .. #_G.Hub.Config.SelectedZones .. " zones")
            end
        else
            print("⏸️ Auto Farm deaktiviert")
        end
    end
})

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
        CurrentValue = _G.Hub.Config.ElementFarmHeight or 3,
        Callback = function(v)
            _G.Hub.Config.ElementFarmHeight = tonumber(v) or 3
        end
    })
end)

-- ========================================================
-- 8. UI SECTION: DEBUG TOOLS
-- ========================================================
Tab:CreateSection("🔍 Debug Tools")

Tab:CreateButton({
    Name = "🔍 Deep Scan Current Zone",
    Callback = function()
        local currentZone = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
        if not currentZone then 
            print("❌ No zone selected")
            return 
        end
        
        print("=" .. string.rep("=", 50))
        print("🔍 DEEP SCAN: " .. currentZone.name)
        print("=" .. string.rep("=", 50))
        
        local zonePath = getZonePath(currentZone)
        if not zonePath then
            print("❌ Zone path not found!")
            print("   Expected path: " .. currentZone.path)
            return
        end
        
        print("✅ Zone path found: " .. zonePath:GetFullName())
        print("\n📂 Children in zone:")
        
        for _, child in pairs(zonePath:GetChildren()) do
            print("\n├─ " .. child.Name .. " (" .. child.ClassName .. ")")
            
            if child:IsA("Model") then
                print("│  ├─ Is a Model ✅")
                
                -- Suche HumanoidRootPart
                local hrp = child:FindFirstChild("HumanoidRootPart")
                if hrp then
                    print("│  ├─ HumanoidRootPart: ✅ FOUND")
                    print("│  │  └─ Position: " .. tostring(hrp.Position))
                else
                    print("│  ├─ HumanoidRootPart: ❌ NOT FOUND")
                end
                
                -- Suche Humanoid
                local hum = child:FindFirstChildOfClass("Humanoid")
                if hum then
                    print("│  ├─ Humanoid: ✅ FOUND")
                    print("│  │  ├─ Health: " .. hum.Health)
                    print("│  │  └─ MaxHealth: " .. hum.MaxHealth)
                else
                    print("│  ├─ Humanoid: ❌ NOT FOUND")
                end
                
                -- Zeige alle Children des Models
                print("│  └─ Model Children:")
                for _, modelChild in pairs(child:GetChildren()) do
                    print("│     ├─ " .. modelChild.Name .. " (" .. modelChild.ClassName .. ")")
                end
            end
        end
        
        print("\n" .. string.rep("=", 50))
    end
})

Tab:CreateSection("⚙️ Quick Actions")

Tab:CreateButton({
    Name = "🗑️ Clear All Selections",
    Callback = function()
        _G.Hub.Config.SelectedZones = {}
        _G.Hub.Config.CurrentZoneIndex = 1
        print("🗑️ Cleared!")
    end
})

Tab:CreateButton({
    Name = "📊 Show Selected Zones",
    Callback = function()
        if #_G.Hub.Config.SelectedZones == 0 then
            print("📊 No zones selected.")
        else
            print("📊 Selected (" .. #_G.Hub.Config.SelectedZones .. "):")
            for i, zone in ipairs(_G.Hub.Config.SelectedZones) do
                print("  " .. i .. ". " .. zone.name)
            end
        end
    end
})

-- ========================================================
-- 9. HAUPT-FARMING LOOP
-- ========================================================
task.spawn(function()
    while task.wait(1) do -- Langsamer für besseres Debugging
        if not _G.Hub.Toggles.ElementAutoFarm then continue end
        if #_G.Hub.Config.SelectedZones == 0 then continue end
        
        pcall(function()
            local currentZone = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
            if not currentZone then return end
            
            if not loadRegion(currentZone.regionName) then
                getNextZone()
                return
            end
            
            task.wait(1) -- Warte länger nach Region Load
            
            local zonePath = getZonePath(currentZone)
            if not zonePath then 
                warn("⚠️ Zone path not found!")
                return 
            end
            
            print("\n🔄 Checking zone: " .. currentZone.name)
            
            local char = Player.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local distance = (hrp.Position - currentZone.coords.Position).Magnitude
            
            if distance > 50 then
                hrp.CFrame = currentZone.coords
                print("📍 Teleported to: " .. currentZone.name)
                task.wait(3) -- Längere Wartezeit nach Teleport
            end
            
            if not hasEnemiesInZone(zonePath) then
                print("✅ Zone cleared: " .. currentZone.name)
                getNextZone()
                task.wait(2)
            end
        end)
    end
end)

-- ========================================================
-- 10. ENEMY TELEPORT LOOP
-- ========================================================
RunService.RenderStepped:Connect(function()
    if not _G.Hub.Toggles.ElementAutoFarm then return end
    if #_G.Hub.Config.SelectedZones == 0 then return end
    
    pcall(function()
        local currentZone = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
        if not currentZone then return end
        
        local zonePath = getZonePath(currentZone)
        if zonePath then
            teleportEnemiesToPlayer(zonePath)
        end
    end)
end)

-- ========================================================
-- 11. AUTO SWING LOOP
-- ========================================================
task.spawn(function()
    while task.wait(0.1) do
        if _G.Hub.Toggles.ElementAutoSwing and _G.Hub.Toggles.ElementAutoFarm then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

print("✅ Element Farm ULTIMATE geladen! (DEBUG MODE)")
print("🔍 Nutze 'Deep Scan Current Zone' um die Struktur zu sehen")
