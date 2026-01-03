-- ========================================================
-- 📜 GITHUB MODULE: FARMING & PRIORITY WITH UI
-- ========================================================

-- Zugriff auf den Tab aus dem Loader
local Tab = _G.Hub["🏠 Farming"]
local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

-- 1. UI ELEMENTE ERSTELLEN
Tab:CreateSection("⚔️ Auto Farming")

Tab:CreateToggle({
    Name = "Auto Swing (Slash 1-3)",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoSwing = v end
})

Tab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoSell = v end
})

Tab:CreateToggle({
    Name = "Auto Magnet",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoMagnet = v end
})

Tab:CreateSection("⚡ Priorities (1-100)")

Tab:CreateToggle({
    Name = "Use Priority System",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.UsePriority = v end
})

Tab:CreateSlider({
    Name = "Sabers Prio",
    Range = {1, 100}, Increment = 1, CurrentValue = 1,
    Callback = function(v) _G.Hub.Config.SaberPrio = v end
})

Tab:CreateSlider({
    Name = "DNA Prio",
    Range = {1, 100}, Increment = 1, CurrentValue = 2,
    Callback = function(v) _G.Hub.Config.DNAPrio = v end
})

Tab:CreateSlider({
    Name = "Classes Prio",
    Range = {1, 100}, Increment = 1, CurrentValue = 3,
    Callback = function(v) _G.Hub.Config.ClassPrio = v end
})

Tab:CreateSection("💎 Auto Purchases")
Tab:CreateToggle({Name = "Buy Sabers", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.BuySabers = v end})
Tab:CreateToggle({Name = "Buy DNA", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.BuyDNA = v end})
Tab:CreateToggle({Name = "Buy Classes", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.BuyClasses = v end})
Tab:CreateToggle({Name = "Buy Auras", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.BuyAuras = v end})
Tab:CreateToggle({Name = "Buy Pet Auras", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.BuyPetAuras = v end})
Tab:CreateToggle({Name = "Buy Boss Hits", CurrentValue = false, Callback = function(v) _G.Hub.Toggles.BuyBossHits = v end})

-- 2. DEINE ORIGINAL-LOGIK (Loops)

-- [1] HAUPT-LOOP: KAMPF & SAMMELN
task.spawn(function()
    while task.wait() do
        if _G.Hub.Toggles.AutoSwing then
            RS.Events.SwingSaber:FireServer("Slash1")
            RS.Events.SwingSaber:FireServer("Slash2")
            RS.Events.SwingSaber:FireServer("Slash3")
        end
        
        if _G.Hub.Toggles.AutoSell then
            RS.Events.SellStrength:FireServer()
        end
        
        if _G.Hub.Toggles.AutoMagnet then
            pcall(function()
                local hrp = Player.Character.HumanoidRootPart
                for _, v in pairs(Workspace.Gameplay.Coins:GetChildren()) do
                    if v:IsA("BasePart") then v.CFrame = hrp.CFrame end
                end
                local elFolder = Workspace:FindFirstChild("Elements") or Workspace.Gameplay:FindFirstChild("Elements")
                if elFolder then
                    for _, e in pairs(elFolder:GetChildren()) do
                        local part = e:IsA("BasePart") and e or e:FindFirstChildWhichIsA("BasePart")
                        if part then part.CFrame = hrp.CFrame end
                    end
                end
            end)
        end
    end
end)

-- [2] PRIORITY & AUTO-BUY LOOP
task.spawn(function()
    while task.wait(0.8) do
        -- Allgemeine Auto-Buys
        if _G.Hub.Toggles.BuyAuras then RS.Events.UIAction:FireServer("BuyAllAuras") end
        if _G.Hub.Toggles.BuyPetAuras then RS.Events.UIAction:FireServer("BuyAllPetAuras") end
        if _G.Hub.Toggles.BuyBossHits then RS.Events.UIAction:FireServer("BuyAllBossHits") end

        -- Priority System
        if _G.Hub.Toggles.UsePriority then
            local pQueue = {
                {ID = "Sabers", P = _G.Hub.Config.SaberPrio or 1, Active = _G.Hub.Toggles.BuySabers, Remote = "BuyAllWeapons"},
                {ID = "DNA", P = _G.Hub.Config.DNAPrio or 2, Active = _G.Hub.Toggles.BuyDNA, Remote = "BuyAllDNAs"},
                {ID = "Classes", P = _G.Hub.Config.ClassPrio or 3, Active = _G.Hub.Toggles.BuyClasses}
            }
            
            table.sort(pQueue, function(a, b) return a.P < b.P end)

            for _, item in ipairs(pQueue) do
                if item.Active then
                    if item.ID == "Classes" then
                        pcall(function()
                            local classData = require(RS.Modules.ItemInfo.Classes)
                            for className, _ in pairs(classData) do 
                                RS.Events.UIAction:FireServer("BuyClass", className) 
                            end
                        end)
                    else
                        RS.Events.UIAction:FireServer(item.Remote)
                    end
                end
            end
        end
    end
end)

print("✅ Farming Tab erfolgreich von GitHub initialisiert.")
