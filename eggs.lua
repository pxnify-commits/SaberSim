-- ========================================================
-- 🥚 GITHUB MODULE: AUTO EGG OPENER (FIXED)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer

-- Sicherer Zugriff auf den Egg-Ordner
local Gameplay = game:GetService("Workspace"):WaitForChild("Gameplay")
local EggsFolder = Gameplay:WaitForChild("Eggs", 10) -- Wartet bis zu 10 Sek

-- Falls der Ordner immer noch nicht gefunden wird, breche ab um Fehler zu vermeiden
if not EggsFolder then
    warn("❌ Egg-Ordner konnte im Workspace nicht gefunden werden!")
    return
end

-- Auswahl-Speicher
_G.Hub.EggConfig = {
    SelectedEgg = "Common Egg",
    MultiOpen = false
}

-- 1. UI ELEMENTE
Tab:CreateSection("🐣 Egg Opener")

local EggList = {}
for _, egg in pairs(EggsFolder:GetChildren()) do
    table.insert(EggList, egg.Name)
end

Tab:CreateDropdown({
    Name = "Select Egg",
    Options = EggList,
    CurrentOption = EggList[1] or "None",
    Callback = function(Option)
        _G.Hub.EggConfig.SelectedEgg = Option
    end,
})

Tab:CreateToggle({
    Name = "Auto Open Egg",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoEgg = v end
})

Tab:CreateToggle({
    Name = "Triple Open (If owned)",
    CurrentValue = false,
    Callback = function(v) _G.Hub.EggConfig.MultiOpen = v end
})

-- 2. EGG LOGIK LOOP
task.spawn(function()
    while task.wait(0.5) do
        if _G.Hub.Toggles.AutoEgg then
            pcall(function()
                -- Remote Namen müssen evtl. je nach Game-Update geprüft werden
                local args = {
                    [1] = _G.Hub.EggConfig.SelectedEgg,
                    [2] = _G.Hub.EggConfig.MultiOpen and "Triple" or "Single"
                }
                RS.Events.EggOpened:FireServer(unpack(args))
            end)
        end
    end
end)

print("✅ Egg Modul erfolgreich geladen.")
