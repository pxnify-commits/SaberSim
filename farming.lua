-- ========================================================
-- 📜 GITHUB MODULE: FARMING & PRIORITY (SORTED UI)
-- ========================================================

local Tab = _G.Hub["🏠 Farming"]
local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

-- 1. UI ELEMENTE IN DEINER GEWÜNSCHTEN REIHENFOLGE
Tab:CreateSection("⚔️ Basic Farming")

Tab:CreateToggle({
    Name = "Auto Swing",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoSwing = v end
})

Tab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoSell = v end
})

Tab:CreateToggle({
    Name = "Auto Pick up",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoMagnet = v end
})

Tab:CreateSection("🛒 Auto Buy Main")

Tab:CreateToggle({
    Name = "Auto Sabers",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.BuySabers = v end
})

Tab:CreateToggle({
    Name = "Auto DNAs",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.BuyDNA = v end
})

Tab:CreateToggle({
    Name = "Auto Classes",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.BuyClasses = v end
})

Tab:CreateSection("✨ Auto Buy Others")

Tab:CreateToggle({
    Name = "Auto bosshits",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.BuyBossHits = v end
})

Tab:CreateToggle({
    Name = "Auto Auras",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.BuyAuras = v end
})

Tab:CreateToggle({
    Name = "Auto PetAuras",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.BuyPetAuras = v end
})

Tab:CreateSection("⚡ Priority Settings (1-100)")

Tab:CreateToggle({
    Name = "Use Priority System",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.UsePriority = v end
})

Tab:CreateSlider({
    Name = "Priority Sabers",
    Range = {1, 100}, Increment = 1, CurrentValue = 1,
    Callback = function(v) _G.Hub.Config.SaberPrio = v end
})

Tab:CreateSlider({
    Name = "Priority DNAs",
    Range = {1, 100}, Increment = 1, CurrentValue = 2,
    Callback = function(v) _G.Hub.Config.DNAPrio = v end
})

Tab:CreateSlider({
    Name = "Priority Classes",
    Range = {1, 100}, Increment = 1, CurrentValue = 3,
    Callback = function(v) _G.Hub.Config.ClassPrio = v end
})

-- 2. DIE LOGIK-LOOPS (Bleiben im Hintergrund aktiv)

-- Farming Loop
task.spawn(function()
    while task.wait() do
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.SwingSaber:FireServer("Slash1")
            RS.Events.SwingSaber:FireServer("Slash2")
            RS.Events.SwingSaber:FireServer("Slash3")
        end
        if _G.Hub.Toggles.AutoSell then RS.Events.SellStrength:FireServer() end
        if _G.Hub.Toggles.AutoMagnet then
            pcall(function()
                local hrp = Player.Character.HumanoidRootPart
                for _, v in pairs(Workspace.Gameplay.Coins:GetChildren()) do
                    if v:IsA("BasePart") then v.CFrame = hrp.CFrame end
                end
            end)
        end
    end
end)

-- Buy & Priority Loop
task.spawn(function()
    while task.wait(0.5) do
        if _G.Hub.Toggles.BuyAuras then RS.Events.UIAction:FireServer("BuyAllAuras") end
        if _G.Hub.Toggles.BuyPetAuras then RS.Events.UIAction:FireServer("BuyAllPetAuras") end
        if _G.Hub.Toggles.BuyBossHits then RS.Events.UIAction:FireServer("BuyAllBossHits") end

        if _G.Hub.Toggles.UsePriority then
            local pQueue = {
                {ID = "S", P = _G.Hub.Config.SaberPrio or 1, Active = _G.Hub.Toggles.BuySabers, Remote = "BuyAllWeapons"},
                {ID = "D", P = _G.Hub.Config.DNAPrio or 2, Active = _G.Hub.Toggles.BuyDNA, Remote = "BuyAllDNAs"},
                {ID = "C", P = _G.Hub.Config.ClassPrio or 3, Active = _G.Hub.Toggles.BuyClasses}
            }
            table.sort(pQueue, function(a, b) return a.P < b.P end)
            for _, item in ipairs(pQueue) do
                if item.Active then
                    if item.ID == "C" then
                        pcall(function()
                            local classes = require(RS.Modules.ItemInfo.Classes)
                            for name, _ in pairs(classes) do RS.Events.UIAction:FireServer("BuyClass", name) end
                        end)
                    else
                        RS.Events.UIAction:FireServer(item.Remote)
                    end
                end
            end
        end
    end
end)
