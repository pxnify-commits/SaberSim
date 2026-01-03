
-- ========================================================
-- ⚔️ ULTIMATE FARMING & PRIORITY MODULE (RAW)
-- ========================================================
local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

-- [1] HAUPT-LOOP: KAMPF & SAMMELN (Schnell)
task.spawn(function()
    while task.wait() do
        -- Auto Swing (Slash 1-3 Combo)
        if _G.SaberHub.Toggles.AutoSwing then
            RS.Events.SwingSaber:FireServer("Slash1")
            RS.Events.SwingSaber:FireServer("Slash2")
            RS.Events.SwingSaber:FireServer("Slash3")
        end
        
        -- Auto Sell
        if _G.SaberHub.Toggles.AutoSell then
            RS.Events.SellStrength:FireServer()
        end
        
        -- Auto Magnet (Coins & Elemente)
        if _G.SaberHub.Toggles.AutoMagnet then
            pcall(function()
                local hrp = Player.Character.HumanoidRootPart
                -- Münzen einsammeln
                for _, v in pairs(Workspace.Gameplay.Coins:GetChildren()) do
                    if v:IsA("BasePart") then v.CFrame = hrp.CFrame end
                end
                -- Elemente einsammeln
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

-- [2] PRIORITY & AUTO-BUY LOOP (Mittel-Schnell)
task.spawn(function()
    while task.wait(0.8) do
        -- A) Allgemeine Auto-Buys (Immer wenn aktiv)
        if _G.SaberHub.Toggles.BuyAuras then RS.Events.UIAction:FireServer("BuyAllAuras") end
        if _G.SaberHub.Toggles.BuyPetAuras then RS.Events.UIAction:FireServer("BuyAllPetAuras") end
        if _G.SaberHub.Toggles.BuyBossHits then RS.Events.UIAction:FireServer("BuyAllBossHits") end

        -- B) Das Priority System (Sabers, DNA, Classes)
        if _G.SaberHub.Toggles.UsePriority then
            -- Liste erstellen und nach Slider-Rang sortieren
            local pQueue = {
                {ID = "Sabers", P = _G.SaberHub.Config.Prio.Sabers, Active = _G.SaberHub.Toggles.BuySabers, Remote = "BuyAllWeapons"},
                {ID = "DNA", P = _G.SaberHub.Config.Prio.DNA, Active = _G.SaberHub.Toggles.BuyDNA, Remote = "BuyAllDNAs"},
                {ID = "Classes", P = _G.SaberHub.Config.Prio.Classes, Active = _G.SaberHub.Toggles.BuyClasses}
            }
            
            -- Sortierung: Kleinste Zahl (Prio 1) zuerst
            table.sort(pQueue, function(a, b) return a.P < b.P end)

            -- Käufe in der richtigen Reihenfolge ausführen
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

print("✅ Farming & Priority Module erfolgreich geladen.")
