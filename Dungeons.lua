-- ========================================================
-- 🏰 DUNGEON MASTER: FULLY FIXED & STABLE REWORK
-- ========================================================

local Tab = _G.Hub["🏰 Dungeons"]
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- ========================
-- GLOBAL CONFIG SAFE INIT
-- ========================
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}
_G.Hub.Config.FarmHeight = tonumber(_G.Hub.Config.FarmHeight) or 10

-- ========================
-- STATE VARIABLES
-- ========================
local currentTarget = nil
local dungeonNames = {}
local diffNames = {}
local diffMap = {}
local selDungeon = nil
local selDiff = nil
local selUpgrade = "DungeonDamage"

-- ========================
-- UPGRADE DISPLAY → SERVER ID
-- ========================
local upgradeMapping = {
    ["Damage ⚔️"] = "DungeonDamage",
    ["Health ❤️"] = "DungeonHealth",
    ["Crit Chance 💥"] = "DungeonCritChance",
    ["Coins 💰"] = "DungeonCoins",
    ["Egg Slots 🥚"] = "DungeonEggSlots"
}

-- ========================
-- SAFE DUNGEON DATA LOADER
-- ========================
local function RefreshDungeonData()
    table.clear(dungeonNames)
    table.clear(diffNames)
    table.clear(diffMap)

    local success, Info = pcall(function()
        return require(RS.Modules:WaitForChild("DungeonInfo"))
    end)

    if not success or not Info then
        warn("❌ DungeonInfo konnte nicht geladen werden")
        return
    end

    if type(Info.Dungeons) == "table" then
        for name in pairs(Info.Dungeons) do
            table.insert(dungeonNames, name)
        end
    end

    if type(Info.Difficulties) == "table" then
        for index, data in ipairs(Info.Difficulties) do
            if data and data.Name then
                table.insert(diffNames, data.Name)
                diffMap[data.Name] = index
            end
        end
    end

    selDungeon = dungeonNames[1]
    selDiff = diffNames[1]

    print("✅ DungeonInfo geladen")
end

RefreshDungeonData()

-- ========================
-- UI: LOBBY & FARM
-- ========================
Tab:CreateSection("🏛️ Lobby & Farming")

Tab:CreateDropdown({
    Name = "Select Dungeon",
    Options = dungeonNames,
    CurrentOption = selDungeon,
    Callback = function(v)
        selDungeon = type(v) == "table" and v[1] or v
    end
})

Tab:CreateDropdown({
    Name = "Select Difficulty",
    Options = diffNames,
    CurrentOption = selDiff,
    Callback = function(v)
        selDiff = type(v) == "table" and v[1] or v
    end
})

Tab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoFarm = v
        currentTarget = nil
    end
})

Tab:CreateSlider({
    Name = "Farm Height",
    Min = 2,
    Max = 50,
    CurrentValue = _G.Hub.Config.FarmHeight,
    Callback = function(v)
        _G.Hub.Config.FarmHeight = tonumber(v) or 10
    end
})

-- ========================
-- UI: UPGRADE SYSTEM
-- ========================
Tab:CreateSection("🆙 Upgrade Rework")

Tab:CreateDropdown({
    Name = "Target Upgrade",
    Options = {"Damage ⚔️", "Health ❤️", "Crit Chance 💥", "Coins 💰", "Egg Slots 🥚"},
    CurrentOption = "Damage ⚔️",
    Callback = function(v)
        local key = type(v) == "table" and v[1] or v
        selUpgrade = upgradeMapping[key] or "DungeonDamage"
        print("🎯 Upgrade:", selUpgrade)
    end
})

Tab:CreateToggle({
    Name = "Smart Auto-Upgrade",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoUpgrade = v
    end
})

-- ========================
-- AUTO UPGRADE LOOP (SAFE)
-- ========================
task.spawn(function()
    while task.wait(1.2) do
        if _G.Hub.Toggles.AutoUpgrade and selUpgrade then
            pcall(function()
                RS.Events.UIAction:FireServer("BuyDungeonUpgrade", selUpgrade)
            end)
        end
    end
end)

-- ========================
-- TARGET SELECTION
-- ========================
local function GetNextTarget()
    local dId = Player:GetAttribute("DungeonId")
    if not dId then return nil end

    local dungeonFolder = WS:FindFirstChild("DungeonStorage")
    if not dungeonFolder then return nil end

    local activeDungeon = dungeonFolder:FindFirstChild(tostring(dId))
    if not activeDungeon then return nil end

    local important = activeDungeon:FindFirstChild("Important")
    if not important then return nil end

    for _, folder in ipairs(important:GetChildren()) do
        if folder.Name:find("Spawner") then
            for _, mob in ipairs(folder:GetChildren()) do
                local hp = mob:GetAttribute("Health")
                if hp and hp > 0 then
                    return mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart")
                end
            end
        end
    end
    return nil
end

-- ========================
-- AUTO FARM LOOP
-- ========================
RunService.RenderStepped:Connect(function()
    if not _G.Hub.Toggles.AutoFarm then return end

    if not currentTarget or not currentTarget.Parent then
        currentTarget = GetNextTarget()
    end

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and currentTarget then
        hrp.CFrame =
            CFrame.new(currentTarget.Position + Vector3.new(0, _G.Hub.Config.FarmHeight, 0))
            * CFrame.Angles(math.rad(-90), 0, 0)
        hrp.Velocity = Vector3.zero
    end
end)

-- ========================
-- LOBBY CONTROLS (SAFE)
-- ========================
Tab:CreateSection("🛠️ Tools")

Tab:CreateButton({
    Name = "🔨 Create Lobby",
    Callback = function()
        local diffIndex = diffMap[selDiff]
        if not selDungeon or not diffIndex then
            warn("❌ Lobby Create fehlgeschlagen (Dungeon/Difficulty nil)")
            return
        end

        RS.Events.UIAction:FireServer(
            "DungeonGroupAction",
            "Create",
            "Public",
            selDungeon,
            diffIndex
        )
    end
})

Tab:CreateButton({
    Name = "▶️ Start Dungeon",
    Callback = function()
        RS.Events.UIAction:FireServer("DungeonGroupAction", "Start")
    end
})

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v)
        _G.Hub.Toggles.AutoSwing = v
    end
})

-- ========================
-- AUTO SWING LOOP
-- ========================
task.spawn(function()
    while task.wait(0.1) do
        if _G.Hub.Toggles.AutoSwing then
            pcall(function()
                RS.Events.UIAction:FireServer("Swing")
            end)
        end
    end
end)

print("✅ Dungeon Master FULLY FIXED geladen – keine Nil Errors mehr.")
