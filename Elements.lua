-- ========================================================
-- 🔥 ELEMENTAL ZONE AUTO FARM - FINAL VERSION
-- ========================================================

if _G.ElementFarmLoaded then
    return
end
_G.ElementFarmLoaded = true

local Tab = _G.Hub["🔥 Elements"]
if not Tab then return end

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Config
_G.EF = _G.EF or {
    Fire = {},
    Water = {},
    Earth = {},
    T = {Fire = false, Water = false, Earth = false, Swing = false},
    C = {Dist = 3, Loaded = {}}
}

-- ========================================================
-- ZONE DEFINITIONEN (KORRIGIERTE STRUKTUR)
-- ========================================================
local ZONES = {
    FIRE = {
        {
            name = "Normal Fire",
            -- Path: Workspace.Gameplay.Map.ElementZones.Fire.Fire.Fire Golem
            path = "Map.ElementZones.Fire.Fire",
            coords = CFrame.new(526.115601, 189.898849, 505.875793, -0.434838206, 0, 0.900508583, 0, 1, 0, -0.900508583, 0, -0.434838206),
            region = nil
        },
        {
            name = "Advanced Fire",
            -- Path: Workspace.Gameplay.RegionsLoaded.AdvancedFireArea.Important.Fire.Earth Golem
            path = "RegionsLoaded.AdvancedFireArea.Important.Fire",
            coords = CFrame.new(-136.174622, 36.0004578, 720.73407, -0.402223319, -1.63293965e-08, 0.915541589, -1.95683096e-08, 1, 9.23886567e-09, -0.915541589, -1.41995145e-08, -0.402223319),
            region = "AdvancedFireArea"
        },
        {
            name = "Master Fire",
            path = "RegionsLoaded.MasterFireArea.Important.Fire",
            coords = CFrame.new(-788.333801, 91.3501282, 743.07373, -0.474422753, 4.84729767e-08, 0.880297124, -2.12631903e-08, 1, -6.65238105e-08, -0.880297124, -5.02783344e-08, -0.474422753),
            region = "MasterFireArea"
        },
        {
            name = "Grandmaster Fire",
            path = "RegionsLoaded.GrandmasterFireArea.Important.Fire",
            coords = CFrame.new(-1487.91064, 88.7130203, 777.639832, -0.284725279, 1.11041021e-09, 0.958609164, -1.99946903e-09, 1, -1.75223613e-09, -0.958609164, -2.41561504e-09, -0.284725279),
            region = "GrandmasterFireArea"
        }
    },
    WATER = {
        {
            name = "Normal Water",
            path = "Map.ElementZones.Water.Water",
            coords = CFrame.new(72.1754227, 281.193573, -541.928223, 0.847862661, 1.83689297e-09, 0.530215919, -5.04716935e-10, 1, -2.65733702e-09, -0.530215919, 1.98544781e-09, 0.847862661),
            region = nil
        },
        {
            name = "Advanced Water",
            path = "RegionsLoaded.AdvancedWaterArea.Important.Water",
            coords = CFrame.new(-189.005905, 17.935297, -792.825195, 0.847863078, 0, 0.530215263, 0, 1, 0, -0.530215263, 0, 0.847863078),
            region = "AdvancedWaterArea"
        },
        {
            name = "Master Water",
            path = "RegionsLoaded.MasterWaterArea.Important.Water",
            coords = CFrame.new(-735.40033, 88.951355, -1004.21191, 0.902788103, 6.04197083e-08, 0.430085629, -5.98376033e-08, 1, -1.48785144e-08, -0.430085629, -1.23031469e-08, 0.902788103),
            region = "MasterWaterArea"
        },
        {
            name = "Grandmaster Water",
            path = "RegionsLoaded.GrandmasterWaterArea.Important.Water",
            coords = CFrame.new(-784.573364, 148.289093, -1568.74023, -0.434830427, -7.10927353e-08, 0.900512338, 4.79472959e-08, 1, 1.020993e-07, -0.900512338, 8.75730137e-08, -0.434830427),
            region = "GrandmasterWaterArea"
        }
    },
    EARTH = {
        {
            name = "Normal Earth",
            path = "Map.ElementZones.Earth.Earth",
            coords = CFrame.new(768.616455, 209.452179, -284.68576, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839),
            region = nil
        },
        {
            name = "Advanced Earth",
            path = "RegionsLoaded.AdvancedEarthArea.Important.Earth",
            coords = CFrame.new(1262.17798, -20.3493195, -917.518066, 0.847853839, 0, 0.530230045, 0, 1, 0, -0.530230045, 0, 0.847853839),
            region = "AdvancedEarthArea"
        },
        {
            name = "Master Earth",
            path = "RegionsLoaded.MasterEarthArea.Important.Earth",
            coords = CFrame.new(1763.40601, 9.96195698, -979.4198, 0.847855389, -2.30705144e-08, 0.530227542, 3.72692632e-08, 1, -1.60844742e-08, -0.530227542, 3.33985e-08, 0.847855389),
            region = "MasterEarthArea"
        },
        {
            name = "Grandmaster Earth",
            path = "RegionsLoaded.GrandmasterEarthArea.Important.Earth",
            coords = CFrame.new(1908.66284, 9.44594669, -1461.03455, 0.847594619, 0, 0.530644298, 0, 1, 0, -0.530644298, 0, 0.847594619),
            region = "GrandmasterEarthArea"
        }
    }
}

-- ========================================================
-- HELPER FUNCTIONS
-- ========================================================
local function loadRegion(rn)
    if not rn or _G.EF.C.Loaded[rn] then return true end
    
    local h = RS:FindFirstChild("HiddenRegions")
    if not h then return false end
    
    local r = h:FindFirstChild(rn)
    if not r then return false end
    
    local g = WS:FindFirstChild("Gameplay")
    if not g then return false end
    
    local l = g:FindFirstChild("RegionsLoaded")
    if not l then return false end
    
    if l:FindFirstChild(rn) then
        _G.EF.C.Loaded[rn] = true
        return true
    end
    
    local ok = pcall(function()
        r:Clone().Parent = l
    end)
    
    if ok then
        _G.EF.C.Loaded[rn] = true
        print("✅ Loaded: " .. rn)
    end
    
    return ok
end

local function getPath(z)
    local g = WS:FindFirstChild("Gameplay")
    if not g then return nil end
    
    local parts = {}
    for p in z.path:gmatch("[^.]+") do
        table.insert(parts, p)
    end
    
    local cur = g
    for _, p in ipairs(parts) do
        cur = cur:FindFirstChild(p)
        if not cur then return nil end
    end
    
    return cur
end

local function hasEnemies(p)
    if not p then return false end
    for _, m in pairs(p:GetChildren()) do
        if m:IsA("Model") and (m.Name:find("Golem") or m.Name:find("Boss")) then
            local h = m:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then return true end
        end
    end
    return false
end

local function tpEnemies(p)
    local c = Player.Character
    if not c then return end
    
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h or not p then return end
    
    for _, m in pairs(p:GetChildren()) do
        if m:IsA("Model") and (m.Name:find("Golem") or m.Name:find("Boss")) then
            pcall(function()
                local e = m:FindFirstChild("HumanoidRootPart")
                local hm = m:FindFirstChildOfClass("Humanoid")
                
                if e and hm and hm.Health > 0 then
                    e.CFrame = h.CFrame * CFrame.new(0, 0, -_G.EF.C.Dist)
                    e.Velocity = Vector3.zero
                    e.AssemblyLinearVelocity = Vector3.zero
                    hm:MoveTo(h.Position)
                end
            end)
        end
    end
end

-- ========================================================
-- FARMING LOOPS
-- ========================================================
task.spawn(function()
    while wait(1) do
        if not _G.EF.T.Fire or #_G.EF.Fire == 0 then continue end
        
        for _, z in ipairs(_G.EF.Fire) do
            if not _G.EF.T.Fire then break end
            
            if not loadRegion(z.region) then 
                task.wait(0.5)
                continue 
            end
            
            task.wait(1)
            
            local p = getPath(z)
            if not p then 
                warn("⚠️ Path not found: " .. z.name)
                continue 
            end
            
            local c = Player.Character
            if c then
                local h = c:FindFirstChild("HumanoidRootPart")
                if h then
                    h.CFrame = z.coords
                    task.wait(2)
                end
            end
            
            local a = 0
            while _G.EF.T.Fire and hasEnemies(p) and a < 30 do
                a = a + 1
                task.wait(1)
            end
            
            print("✅ " .. z.name .. " cleared")
        end
    end
end)

task.spawn(function()
    while wait(1) do
        if not _G.EF.T.Water or #_G.EF.Water == 0 then continue end
        
        for _, z in ipairs(_G.EF.Water) do
            if not _G.EF.T.Water then break end
            
            if not loadRegion(z.region) then 
                task.wait(0.5)
                continue 
            end
            
            task.wait(1)
            
            local p = getPath(z)
            if not p then continue end
            
            local c = Player.Character
            if c then
                local h = c:FindFirstChild("HumanoidRootPart")
                if h then
                    h.CFrame = z.coords
                    task.wait(2)
                end
            end
            
            local a = 0
            while _G.EF.T.Water and hasEnemies(p) and a < 30 do
                a = a + 1
                task.wait(1)
            end
            
            print("✅ " .. z.name .. " cleared")
        end
    end
end)

task.spawn(function()
    while wait(1) do
        if not _G.EF.T.Earth or #_G.EF.Earth == 0 then continue end
        
        for _, z in ipairs(_G.EF.Earth) do
            if not _G.EF.T.Earth then break end
            
            if not loadRegion(z.region) then 
                task.wait(0.5)
                continue 
            end
            
            task.wait(1)
            
            local p = getPath(z)
            if not p then continue end
            
            local c = Player.Character
            if c then
                local h = c:FindFirstChild("HumanoidRootPart")
                if h then
                    h.CFrame = z.coords
                    task.wait(2)
                end
            end
            
            local a = 0
            while _G.EF.T.Earth and hasEnemies(p) and a < 30 do
                a = a + 1
                task.wait(1)
            end
            
            print("✅ " .. z.name .. " cleared")
        end
    end
end)

-- Enemy TP Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        if _G.EF.T.Fire then
            for _, z in ipairs(_G.EF.Fire) do
                tpEnemies(getPath(z))
            end
        end
        if _G.EF.T.Water then
            for _, z in ipairs(_G.EF.Water) do
                tpEnemies(getPath(z))
            end
        end
        if _G.EF.T.Earth then
            for _, z in ipairs(_G.EF.Earth) do
                tpEnemies(getPath(z))
            end
        end
    end)
end)

-- Swing Loop
task.spawn(function()
    while wait(0.1) do
        if _G.EF.T.Swing then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

-- ========================================================
-- UI
-- ========================================================
Tab:CreateSection("🔥 Fire Zones")

local fOpts = {}
for _, z in ipairs(ZONES.FIRE) do table.insert(fOpts, z.name) end

pcall(function()
    Tab:CreateDropdown({
        Name = "Select Fire Zones",
        Options = fOpts,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(s)
            _G.EF.Fire = {}
            for _, n in ipairs(s) do
                for _, z in ipairs(ZONES.FIRE) do
                    if z.name == n then
                        table.insert(_G.EF.Fire, z)
                        break
                    end
                end
            end
            print("🔥 Fire zones: " .. #_G.EF.Fire)
        end
    })
end)

Tab:CreateToggle({
    Name = "🚀 Start Fire Farm",
    CurrentValue = false,
    Callback = function(v) 
        _G.EF.T.Fire = v 
        print(v and "✅ Fire: ON" or "⏸️ Fire: OFF")
    end
})

Tab:CreateSection("💧 Water Zones")

local wOpts = {}
for _, z in ipairs(ZONES.WATER) do table.insert(wOpts, z.name) end

pcall(function()
    Tab:CreateDropdown({
        Name = "Select Water Zones",
        Options = wOpts,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(s)
            _G.EF.Water = {}
            for _, n in ipairs(s) do
                for _, z in ipairs(ZONES.WATER) do
                    if z.name == n then
                        table.insert(_G.EF.Water, z)
                        break
                    end
                end
            end
            print("💧 Water zones: " .. #_G.EF.Water)
        end
    })
end)

Tab:CreateToggle({
    Name = "🚀 Start Water Farm",
    CurrentValue = false,
    Callback = function(v) 
        _G.EF.T.Water = v 
        print(v and "✅ Water: ON" or "⏸️ Water: OFF")
    end
})

Tab:CreateSection("🌍 Earth Zones")

local eOpts = {}
for _, z in ipairs(ZONES.EARTH) do table.insert(eOpts, z.name) end

pcall(function()
    Tab:CreateDropdown({
        Name = "Select Earth Zones",
        Options = eOpts,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(s)
            _G.EF.Earth = {}
            for _, n in ipairs(s) do
                for _, z in ipairs(ZONES.EARTH) do
                    if z.name == n then
                        table.insert(_G.EF.Earth, z)
                        break
                    end
                end
            end
            print("🌍 Earth zones: " .. #_G.EF.Earth)
        end
    })
end)

Tab:CreateToggle({
    Name = "🚀 Start Earth Farm",
    CurrentValue = false,
    Callback = function(v) 
        _G.EF.T.Earth = v 
        print(v and "✅ Earth: ON" or "⏸️ Earth: OFF")
    end
})

Tab:CreateSection("⚙️ Settings")

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v) _G.EF.T.Swing = v end
})

pcall(function()
    Tab:CreateSlider({
        Name = "Distance",
        Range = {2, 15},
        Increment = 1,
        CurrentValue = 3,
        Callback = function(v) _G.EF.C.Dist = v end
    })
end)

Tab:CreateSection("🔍 Debug")

Tab:CreateButton({
    Name = "Test Fire Normal",
    Callback = function()
        local z = ZONES.FIRE[1]
        local p = getPath(z)
        print("Zone: " .. z.name)
        print("Path: " .. (p and p:GetFullName() or "NOT FOUND"))
        if p then
            print("Enemies: " .. tostring(hasEnemies(p)))
        end
    end
})

print("✅ Element Farm loaded!")
print("📂 Path structure fixed based on screenshots")
