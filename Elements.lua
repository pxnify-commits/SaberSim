-- ========================================================
-- 🔥 ELEMENTAL ZONE AUTO FARM ULTIMATE (WITH REGION LOADING)
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

-- ========================================================
-- 1. ZONE DEFINITIONEN (MIT REGION NAMES)
-- ========================================================
local ZONES = {
    FIRE = {
        {
            name = "🔥 Normal Fire",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Fire.Fire.Fire",
            coords = CFrame.new(526.115601, 189.898849, 505.875793, -0.434838206, 0, 0.900508583, 0, 1, 0, -0.900508583, 0, -0.434838206),
            regionName = nil -- Normal Zone ist bereits geladen
        },
        {
            name = "🔥 Advanced Fire",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedFireArea.Important.Fire.Fire",
            coords = CFrame.new(-136.174622, 36.0004578, 720.73407, -0.402223319, -1.63293965e-08, 0.915541589, -1.95683096e-08, 1, 9.23886567e-09, -0.915541589, -1.41995145e-08, -0.402223319),
            regionName = "AdvancedFireArea"
        },
        {
            name = "🔥 Master Fire",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterFireArea.Important.Fire.Fire",
            coords = CFrame.new(-788.333801, 91.3501282, 743.07373, -0.474422753, 4.84729767e-08, 0.880297124, -2.12631903e-08, 1, -6.65238105e-08, -0.880297124, -5.02783344e-08, -0.474422753),
            regionName = "MasterFireArea"
        },
        {
            name = "🔥 Grandmaster Fire",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterFireArea.Important.Fire.Fire",
            coords = CFrame.new(-1487.91064, 88.7130203, 777.639832, -0.284725279, 1.11041021e-09, 0.958609164, -1.99946903e-09, 1, -1.75223613e-09, -0.958609164, -2.41561504e-09, -0.284725279),
            regionName = "GrandmasterFireArea"
        }
    },
    
    WATER = {
        {
            name = "💧 Normal Water",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Water.Water.Water",
            coords = CFrame.new(72.1754227, 281.193573, -541.928223, 0.847862661, 1.83689297e-09, 0.530215919, -5.04716935e-10, 1, -2.65733702e-09, -0.530215919, 1.98544781e-09, 0.847862661),
            regionName = nil
        },
        {
            name = "💧 Advanced Water",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedWaterArea.Important.Water.Water",
            coords = CFrame.new(-189.005905, 17.935297, -792.825195, 0.847863078, 0, 0.530215263, 0, 1, 0, -0.530215263, 0, 0.847863078),
            regionName = "AdvancedWaterArea"
        },
        {
            name = "💧 Master Water",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterWaterArea.Important.Water.Water",
            coords = CFrame.new(-735.40033, 88.951355, -1004.21191, 0.902788103, 6.04197083e-08, 0.430085629, -5.98376033e-08, 1, -1.48785144e-08, -0.430085629, -1.23031469e-08, 0.902788103),
            regionName = "MasterWaterArea"
        },
        {
            name = "💧 Grandmaster Water",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterWaterArea.Important.Water.Water",
            coords = CFrame.new(-784.573364, 148.289093, -1568.74023, -0.434830427, -7.10927353e-08, 0.900512338, 4.79472959e-08, 1, 1.020993e-07, -0.900512338, 8.75730137e-08, -0.434830427),
            regionName = "GrandmasterWaterArea"
        }
    },
    
    EARTH = {
        {
            name = "🌍 Normal Earth",
            displayName = "Farm Normal Zone",
            path = "Gameplay.Map.ElementZone.Earth.Earth.Earth",
            coords = CFrame.new(768.616455, 209.452179, -284.68576, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839),
            regionName = nil
        },
        {
            name = "🌍 Advanced Earth",
            displayName = "Farm Advanced Zone",
            path = "Gameplay.RegionsLoaded.AdvancedEarthArea.Important.Earth.Earth",
            coords = CFrame.new(1262.17798, -20.3493195, -917.518066, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839),
            regionName = "AdvancedEarthArea"
        },
        {
            name = "🌍 Master Earth",
            displayName = "Farm Master Zone",
            path = "Gameplay.RegionsLoaded.MasterEarthArea.Important.Earth.Earth",
            coords = CFrame.new(1763.40601, 9.96195698, -979.4198, 0.847855389, -2.30705144e-08, 0.530227542, 3.72692632e-08, 1, -1.60844742e-08, -0.530227542, 3.33985e-08, 0.847855389),
            regionName = "MasterEarthArea"
        },
        {
            name = "🌍 Grandmaster Earth",
            displayName = "Farm Grandmaster Zone",
            path = "Gameplay.RegionsLoaded.GrandmasterEarthArea.Important.Earth.Earth",
            coords = CFrame.new(1908.66284, 9.44594669, -1461.03455, 0.847594619, 0, 0.530644298, 0, 1, 0, -0.530644298, 0, 0.847594619),
            regionName = "GrandmasterEarthArea"
        }
    }
}

-- ========================================================
-- 2. REGION LOADING FUNCTIONS
-- ========================================================
local function loadRegion(regionName)
    if not regionName then return true end -- Normal Zones brauchen kein Loading
    
    -- Check ob bereits geladen
    if _G.Hub.Config.LoadedRegions[regionName] then 
        return true 
    end
    
    local hiddenRegions = RS:FindFirstChild("HiddenRegions")
    if not hiddenRegions then 
        warn("⚠️ HiddenRegions nicht gefunden!")
        return false 
    end
    
    local regionFolder = hiddenRegions:FindFirstChild(regionName)
    if not regionFolder then
        warn("⚠️ Region nicht gefunden: " .. regionName)
        return false
    end
    
    -- Clone Region nach RegionsLoaded
    local regionsLoaded = WS.Gameplay:FindFirstChild("RegionsLoaded")
    if not regionsLoaded then
        warn("⚠️ RegionsLoaded nicht gefunden!")
        return false
    end
    
    -- Check ob bereits existiert
    if regionsLoaded:FindFirstChild(regionName) then
        print("✅ Region bereits geladen: " .. regionName)
        _G.Hub.Config.LoadedRegions[regionName] = true
        return true
    end
    
    -- Clone die Region
    local clonedRegion = regionFolder:Clone()
    clonedRegion.Parent = regionsLoaded
    
    _G.Hub.Config.LoadedRegions[regionName] = true
    print("✅ Region geladen: " .. regionName)
    
    return true
end

local function unloadRegion(regionName)
    if not regionName then return end
    
    local regionsLoaded = WS.Gameplay:FindFirstChild("RegionsLoaded")
    if not regionsLoaded then return end
    
    local region = regionsLoaded:FindFirstChild(regionName)
    if region then
        region:Destroy()
        _G.Hub.Config.LoadedRegions[regionName] = nil
        print("🗑️ Region entladen: " .. regionName)
    end
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
        if entity:IsA("Model") and (entity.Name:find("Golem") or entity.Name:find("Boss")) then
            local hum = entity:FindFirstChildOfClass("Humanoid") or 
                       entity:FindFirstChild("Humanoid", true)
            
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
        if entity:IsA("Model") and (entity.Name:find("Golem") or entity.Name:find("Boss")) then
            pcall(function()
                local enemyHRP = entity:FindFirstChild("HumanoidRootPart", true) or
                                entity:FindFirstChild("Torso", true) or
                                entity.PrimaryPart
                
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
                -- Lade Region falls nötig
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
                warn("⚠️ No zones selected! Please select at least one zone.")
                _G.Hub.Toggles.ElementAutoFarm = false
            else
                print("✅ Auto Farm aktiviert - Farming " .. #_G.Hub.Config.SelectedZones .. " zones")
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
-- 8. UI SECTION: DEBUG & QUICK ACTIONS
-- ========================================================
Tab:CreateSection("🔍 Debug Tools")

Tab:CreateButton({
    Name = "🔍 Print Zone Structure",
    Callback = function()
        local currentZone = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
        if not currentZone then 
            print("❌ No zone selected")
            return 
        end
        
        local zonePath = getZonePath(currentZone)
        if not zonePath then
            print("❌ Zone path not found")
            return
        end
        
        print("📂 Zone Structure for: " .. currentZone.name)
        for _, child in pairs(zonePath:GetChildren()) do
            print("  ├─ " .. child.Name .. " (" .. child.ClassName .. ")")
            
            if child:IsA("Model") then
                local hrp = child:FindFirstChild("HumanoidRootPart", true)
                print("    └─ HumanoidRootPart: " .. tostring(hrp and "FOUND ✅" or "NOT FOUND ❌"))
                
                local hum = child:FindFirstChildOfClass("Humanoid")
                if hum then
                    print("    └─ Humanoid Health: " .. hum.Health)
                end
            end
        end
    end
})

Tab:CreateButton({
    Name = "📋 Show Loaded Regions",
    Callback = function()
        print("📋 Currently Loaded Regions:")
        for regionName, _ in pairs(_G.Hub.Config.LoadedRegions) do
            print("  ✅ " .. regionName)
        end
    end
})

Tab:CreateSection("⚙️ Quick Actions")

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

Tab:CreateButton({
    Name = "🔄 Force Zone Refresh",
    Callback = function()
        local current = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
        if current then
            print("🔄 Refreshing zone: " .. current.name)
            getNextZone()
        else
            print("⚠️ No active zone")
        end
    end
})

-- ========================================================
-- 9. HAUPT-FARMING LOOP (ZONE ROTATION)
-- ========================================================
task.spawn(function()
    while task.wait(0.5) do
        if not _G.Hub.Toggles.ElementAutoFarm then continue end
        if #_G.Hub.Config.SelectedZones == 0 then continue end
        
        pcall(function()
            local currentZone = _G.Hub.Config.SelectedZones[_G.Hub.Config.CurrentZoneIndex]
            if not currentZone then return end
            
            -- Stelle sicher dass Region geladen ist
            if not loadRegion(currentZone.regionName) then
                print("⚠️ Failed to load region, skipping...")
                getNextZone()
                return
            end
            
            local zonePath = getZonePath(currentZone)
            
            -- Teleport zur Zone
            local char = Player.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local distance = (hrp.Position - currentZone.coords.Position).Magnitude
            
            if distance > 50 then
                hrp.CFrame = currentZone.coords
                print("📍 Teleported to: " .. currentZone.name)
                task.wait(2)
            end
            
            -- Check ob Zone clear ist
            if not hasEnemiesInZone(zonePath) then
                print("✅ Zone cleared: " .. currentZone.name)
                getNextZone()
                task.wait(1)
            end
        end)
    end
end)

-- ========================================================
-- 10. ENEMY TELEPORT LOOP (RENDERSTEP)
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

print("✅ Element Farm ULTIMATE geladen!")
print("📋 Alle Systeme bereit (mit Region Loading)")
