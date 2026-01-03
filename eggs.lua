-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHING
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"] -- Muss exakt wie im Loader heißen
local RS = game:GetService("ReplicatedStorage")

-- Variablen im globalen Speicher registrieren
_G.Hub.Settings = _G.Hub.Settings or {}
_G.Hub.Settings.SelectedEgg = "Common Egg"
_G.Hub.Settings.EggHatchDelay = 0.3

-- Eier suchen
local EggList = {}
local eggsFolder = workspace:WaitForChild("Gameplay"):WaitForChild("Eggs", 5)

if eggsFolder then
    for _, v in pairs(eggsFolder:GetChildren()) do
        table.insert(EggList, v.Name)
    end
end

-- 1. UI ELEMENTE (Dein Layout)
Tab:CreateSection("🥚 Egg Hatching")

if #EggList > 0 then
    Tab:CreateDropdown({
        Name = "Select Egg",
        Options = EggList,
        CurrentOption = EggList[1],
        Callback = function(opt)
            -- Fix für Rayfield-Tabellen-Rückgabe
            _G.Hub.Settings.SelectedEgg = type(opt) == "table" and opt[1] or opt
        end
    })
else
    Tab:CreateLabel("⚠️ Keine Eggs gefunden")
end

Tab:CreateToggle({
    Name = "Auto Hatch",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoHatch = v end
})

Tab:CreateToggle({
    Name = "Hide Egg Open Animation",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.HideEggAnimation = v end
})

Tab:CreateSlider({
    Name = "Hatch Delay (seconds)",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.3,
    Callback = function(v)
        _G.Hub.Settings.EggHatchDelay = v
    end
})

Tab:CreateSection("📊 Info")
Tab:CreateLabel("Gefundene Eggs: " .. #EggList)

-- 2. DER HATCH-LOOP
task.spawn(function()
    while task.wait() do
        if _G.Hub.Toggles.AutoHatch then
            pcall(function()
                -- Das Event im Saber Simulator zum Öffnen
                RS.Events.EggOpened:FireServer(_G.Hub.Settings.SelectedEgg)
            end)
            task.wait(_G.Hub.Settings.EggHatchDelay)
        end
    end
end)
