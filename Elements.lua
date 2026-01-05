-- ========================================================
-- 🔥 ELEMENTAL ZONE AUTO FARM - COMPLETE REWRITE
-- ========================================================

-- KRITISCHER GUARD - Verhindert doppeltes Laden
if _G.ElemFarmActive then
    warn("⚠️ Script bereits aktiv! Bitte rejoin für Neustart.")
    return
end
_G.ElemFarmActive = true

local Tab = _G.Hub["🔥 Elements"]
if not Tab then 
    warn("❌ Tab nicht gefunden!")
    _G.ElemFarmActive = nil
    return 
end

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ========================================================
-- CONFIG
-- ========================================================
local Config = {
    Fire = {},
    Water = {},
    Earth = {},
    Active = {Fire = false, Water = false, Earth = false},
    Settings = {
        AutoSwing = false,
        Distance = 3,
        WaitAfterTP = 3,
        CheckInterval = 1,
        MaxAttempts = 60
    },
    LoadedRegions = {}
}

-- ========================================================
-- ZONES (KORREKTE STRUKTUR)
-- ========================================================
local ZONES = {
    FIRE = {
        {n = "Normal Fire", p = "Map.ElementZones.Fire.Fire", c = CFrame.new(526.115601, 189.898849, 505.875793), r = nil},
        {n = "Advanced Fire", p = "RegionsLoaded.AdvancedFireArea.Important.Fire", c = CFrame.new(-136.174622, 36.0004578, 720.73407), r = "AdvancedFireArea"},
        {n = "Master Fire", p = "RegionsLoaded.MasterFireArea.Important.Fire", c = CFrame.new(-788.333801, 91.3501282, 743.07373), r = "MasterFireArea"},
        {n = "Grandmaster Fire", p = "RegionsLoaded.GrandmasterFireArea.Important.Fire", c = CFrame.new(-1487.91064, 88.7130203, 777.639832), r = "GrandmasterFireArea"}
    },
    WATER = {
        {n = "Normal Water", p = "Map.ElementZones.Water.Water", c = CFrame.new(72.1754227, 281.193573, -541.928223), r = nil},
        {n = "Advanced Water", p = "RegionsLoaded.AdvancedWaterArea.Important.Water", c = CFrame.new(-189.005905, 17.935297, -792.825195), r = "AdvancedWaterArea"},
        {n = "Master Water", p = "RegionsLoaded.MasterWaterArea.Important.Water", c = CFrame.new(-735.40033, 88.951355, -1004.21191), r = "MasterWaterArea"},
        {n = "Grandmaster Water", p = "RegionsLoaded.GrandmasterWaterArea.Important.Water", c = CFrame.new(-784.573364, 148.289093, -1568.74023), r = "GrandmasterWaterArea"}
    },
    EARTH = {
        {n = "Normal Earth", p = "Map.ElementZones.Earth.Earth", c = CFrame.new(768.616455, 209.452179, -284.68576), r = nil},
        {n = "Advanced Earth", p = "RegionsLoaded.AdvancedEarthArea.Important.Earth", c = CFrame.new(1262.17798, -20.3493195, -917.518066), r = "AdvancedEarthArea"},
        {n = "Master Earth", p = "RegionsLoaded.MasterEarthArea.Important.Earth", c = CFrame.new(1763.40601, 9.96195698, -979.4198), r = "MasterEarthArea"},
        {n = "Grandmaster Earth", p = "RegionsLoaded.GrandmasterEarthArea.Important.Earth", c = CFrame.new(1908.66284, 9.44594669, -1461.03455), r = "GrandmasterEarthArea"}
    }
}

-- ========================================================
-- FUNCTIONS
-- ========================================================
local function loadReg(r)
    if not r or Config.LoadedRegions[r] then return true end
    
    local h = RS:FindFirstChild("HiddenRegions")
    local g = WS:FindFirstChild("Gameplay")
    if not h or not g then return false end
    
    local l = g:FindFirstChild("RegionsLoaded")
    if not l then return false end
    
    if l:FindFirstChild(r) then
        Config.LoadedRegions[r] = true
        return true
    end
    
    local rf = h:FindFirstChild(r)
    if not rf then return false end
    
    local ok, err = pcall(function()
        rf:Clone().Parent = l
    end)
    
    if ok then
        Config.LoadedRegions[r] = true
        print("✅ Loaded region: " .. r)
        return true
    else
        warn("❌ Failed to load: " .. r .. " | " .. tostring(err))
        return false
    end
end

local function getP(z)
    local g = WS:FindFirstChild("Gameplay")
    if not g then return nil end
    
    local cur = g
    for part in z.p:gmatch("[^.]+") do
        cur = cur:FindFirstChild(part)
        if not cur then return nil end
    end
    
    return cur
end

local function countEnemies(p)
    if not p then return 0 end
    
    local count = 0
    for _, m in pairs(p:GetChildren()) do
        if m:IsA("Model") and (m.Name:find("Golem") or m.Name:find("Boss")) then
            local h = m:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                count = count + 1
            end
        end
    end
    
    return count
end

local function tpAll(p)
    local c = Player.Character
    if not c then return end
    
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp or not p then return end
    
    for _, m in pairs(p:GetChildren()) do
        if m:IsA("Model") and (m.Name:find("Golem") or m.Name:find("Boss")) then
            pcall(function()
                local e = m:FindFirstChild("HumanoidRootPart")
                local h = m:FindFirstChildOfClass("Humanoid")
                
                if e and h and h.Health > 0 then
                    -- Teleport direkt vor Spieler
                    e.CFrame = hrp.CFrame * CFrame.new(0, 0, -Config.Settings.Distance)
                    
                    -- Alle Velocity entfernen
                    e.Velocity = Vector3.zero
                    e.AssemblyLinearVelocity = Vector3.zero
                    e.AssemblyAngularVelocity = Vector3.zero
                    
                    -- Anchoring testen
                    if e:IsA("BasePart") then
                        e.Anchored = false
                    end
                    
                    -- AI Movement stoppen
                    if h then
                        h:MoveTo(hrp.Position)
                        h.WalkSpeed = 0
                    end
                end
            end)
        end
    end
end

-- ========================================================
-- FARMING LOOP (FIRE)
-- ========================================================
task.spawn(function()
    while task.wait(Config.Settings.CheckInterval) do
        if not Config.Active.Fire or #Config.Fire == 0 then continue end
        
        for idx, zone in ipairs(Config.Fire) do
            if not Config.Active.Fire then break end
            
            print("\n🔥 [FIRE " .. idx .. "/" .. #Config.Fire .. "] " .. zone.n)
            
            -- Load Region
            if not loadReg(zone.r) then
                warn("⚠️ Failed to load region, skipping")
                continue
            end
            
            task.wait(1)
            
            -- Get Path
            local path = getP(zone)
            if not path then
                warn("⚠️ Path not found: " .. zone.p)
                continue
            end
            
            print("✅ Path valid: " .. path:GetFullName())
            
            -- Teleport Player
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = zone.c
                    print("📍 Teleported to zone")
                    task.wait(Config.Settings.WaitAfterTP)
                end
            end
            
            -- Farm Loop
            local attempts = 0
            local lastCount = -1
            
            while Config.Active.Fire and attempts < Config.Settings.MaxAttempts do
                local enemyCount = countEnemies(path)
                
                -- Log nur wenn sich was ändert
                if enemyCount ~= lastCount then
                    print("👹 Enemies: " .. enemyCount)
                    lastCount = enemyCount
                end
                
                if enemyCount == 0 then
                    print("✅ Zone cleared!")
                    break
                end
                
                attempts = attempts + 1
                task.wait(Config.Settings.CheckInterval)
            end
            
            if attempts >= Config.Settings.MaxAttempts then
                warn("⏱️ Timeout reached, moving to next zone")
            end
        end
        
        print("🔁 Fire cycle complete, restarting...")
    end
end)

-- ========================================================
-- FARMING LOOP (WATER)
-- ========================================================
task.spawn(function()
    while task.wait(Config.Settings.CheckInterval) do
        if not Config.Active.Water or #Config.Water == 0 then continue end
        
        for idx, zone in ipairs(Config.Water) do
            if not Config.Active.Water then break end
            
            print("\n💧 [WATER " .. idx .. "/" .. #Config.Water .. "] " .. zone.n)
            
            if not loadReg(zone.r) then continue end
            task.wait(1)
            
            local path = getP(zone)
            if not path then continue end
            
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = zone.c
                    task.wait(Config.Settings.WaitAfterTP)
                end
            end
            
            local attempts = 0
            while Config.Active.Water and attempts < Config.Settings.MaxAttempts do
                if countEnemies(path) == 0 then
                    print("✅ Zone cleared!")
                    break
                end
                attempts = attempts + 1
                task.wait(Config.Settings.CheckInterval)
            end
        end
        
        print("🔁 Water cycle complete")
    end
end)

-- ========================================================
-- FARMING LOOP (EARTH)
-- ========================================================
task.spawn(function()
    while task.wait(Config.Settings.CheckInterval) do
        if not Config.Active.Earth or #Config.Earth == 0 then continue end
        
        for idx, zone in ipairs(Config.Earth) do
            if not Config.Active.Earth then break end
            
            print("\n🌍 [EARTH " .. idx .. "/" .. #Config.Earth .. "] " .. zone.n)
            
            if not loadReg(zone.r) then continue end
            task.wait(1)
            
            local path = getP(zone)
            if not path then continue end
            
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = zone.c
                    task.wait(Config.Settings.WaitAfterTP)
                end
            end
            
            local attempts = 0
            while Config.Active.Earth and attempts < Config.Settings.MaxAttempts do
                if countEnemies(path) == 0 then
                    print("✅ Zone cleared!")
                    break
                end
                attempts = attempts + 1
                task.wait(Config.Settings.CheckInterval)
            end
        end
        
        print("🔁 Earth cycle complete")
    end
end)

-- ========================================================
-- ENEMY TELEPORT LOOP (SCHNELL)
-- ========================================================
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.Active.Fire then
            for _, z in ipairs(Config.Fire) do
                tpAll(getP(z))
            end
        end
        if Config.Active.Water then
            for _, z in ipairs(Config.Water) do
                tpAll(getP(z))
            end
        end
        if Config.Active.Earth then
            for _, z in ipairs(Config.Earth) do
                tpAll(getP(z))
            end
        end
    end)
end)

-- ========================================================
-- AUTO SWING LOOP
-- ========================================================
task.spawn(function()
    while task.wait(0.1) do
        if Config.Settings.AutoSwing then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

-- ========================================================
-- UI CREATION
-- ========================================================
Tab:CreateSection("🔥 Fire Zones")

local fOpts = {}
for _, z in ipairs(ZONES.FIRE) do table.insert(fOpts, z.n) end

pcall(function()
    Tab:CreateDropdown({
        Name = "Select Zones",
        Options = fOpts,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(sel)
            Config.Fire = {}
            for _, name in ipairs(sel) do
                for _, zone in ipairs(ZONES.FIRE) do
                    if zone.n == name then
                        table.insert(Config.Fire, zone)
                        break
                    end
                end
            end
            print("🔥 Selected: " .. #Config.Fire .. " zones")
        end
    })
end)

Tab:CreateToggle({
    Name = "🚀 Start Fire Farm",
    CurrentValue = false,
    Callback = function(v)
        Config.Active.Fire = v
        print(v and "✅ Fire: ON" or "⏸️ Fire: OFF")
    end
})

Tab:CreateSection("💧 Water Zones")

local wOpts = {}
for _, z in ipairs(ZONES.WATER) do table.insert(wOpts, z.n) end

pcall(function()
    Tab:CreateDropdown({
        Name = "Select Zones",
        Options = wOpts,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(sel)
            Config.Water = {}
            for _, name in ipairs(sel) do
                for _, zone in ipairs(ZONES.WATER) do
                    if zone.n == name then
                        table.insert(Config.Water, zone)
                        break
                    end
                end
            end
            print("💧 Selected: " .. #Config.Water .. " zones")
        end
    })
end)

Tab:CreateToggle({
    Name = "🚀 Start Water Farm",
    CurrentValue = false,
    Callback = function(v)
        Config.Active.Water = v
        print(v and "✅ Water: ON" or "⏸️ Water: OFF")
    end
})

Tab:CreateSection("🌍 Earth Zones")

local eOpts = {}
for _, z in ipairs(ZONES.EARTH) do table.insert(eOpts, z.n) end

pcall(function()
    Tab:CreateDropdown({
        Name = "Select Zones",
        Options = eOpts,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(sel)
            Config.Earth = {}
            for _, name in ipairs(sel) do
                for _, zone in ipairs(ZONES.EARTH) do
                    if zone.n == name then
                        table.insert(Config.Earth, zone)
                        break
                    end
                end
            end
            print("🌍 Selected: " .. #Config.Earth .. " zones")
        end
    })
end)

Tab:CreateToggle({
    Name = "🚀 Start Earth Farm",
    CurrentValue = false,
    Callback = function(v)
        Config.Active.Earth = v
        print(v and "✅ Earth: ON" or "⏸️ Earth: OFF")
    end
})

Tab:CreateSection("⚙️ Settings")

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v)
        Config.Settings.AutoSwing = v
    end
})

pcall(function()
    Tab:CreateSlider({
        Name = "Enemy Distance",
        Range = {2, 15},
        Increment = 1,
        CurrentValue = 3,
        Callback = function(v)
            Config.Settings.Distance = v
        end
    })
end)

pcall(function()
    Tab:CreateSlider({
        Name = "Wait After TP (seconds)",
        Range = {1, 10},
        Increment = 1,
        CurrentValue = 3,
        Callback = function(v)
            Config.Settings.WaitAfterTP = v
        end
    })
end)

Tab:CreateSection("🔍 Debug")

Tab:CreateButton({
    Name = "📊 Show Status",
    Callback = function()
        print("\n📊 STATUS:")
        print("Fire: " .. tostring(Config.Active.Fire) .. " | Zones: " .. #Config.Fire)
        print("Water: " .. tostring(Config.Active.Water) .. " | Zones: " .. #Config.Water)
        print("Earth: " .. tostring(Config.Active.Earth) .. " | Zones: " .. #Config.Earth)
        print("Swing: " .. tostring(Config.Settings.AutoSwing))
    end
})

Tab:CreateButton({
    Name = "🧪 Test Fire Normal",
    Callback = function()
        local z = ZONES.FIRE[1]
        local p = getP(z)
        print("\n🧪 TEST:")
        print("Zone: " .. z.n)
        print("Path: " .. (p and p:GetFullName() or "NOT FOUND"))
        if p then
            print("Enemies: " .. countEnemies(p))
        end
    end
})

print("✅ Element Farm loaded!")
print("🔒 Doppel-UI verhindert mit _G.ElemFarmActive")
print("⚡ Heartbeat für schnelleres Enemy-TP")
