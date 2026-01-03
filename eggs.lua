-- ========================================================
-- 🥚 GITHUB MODULE: AUTO EGG OPENER
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer

-- Auswahl-Speicher
_G.Hub.EggConfig = {
    SelectedEgg = "Common Egg",
    MultiOpen = false
}

-- 1. UI ELEMENTE
Tab:CreateSection("🐣 Egg Opener")

local EggList = {}
-- Holt alle verfügbaren Eier aus dem Spiel (dynamisch)
for _, egg in pairs(game:GetService("Workspace").Gameplay.Eggs:GetChildren()) do
    table.insert(EggList, egg.Name)
end

Tab:CreateDropdown({
    Name = "Select Egg",
    Options = EggList,
    CurrentOption = "Common Egg",
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

Tab:CreateSection("🗑️ Management")

Tab:CreateToggle({
    Name = "Auto Delete Commons",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.DeleteCommon = v end
})

-- 2. EGG LOGIK LOOP
task.spawn(function()
    while task.wait(0.5) do
        if _G.Hub.Toggles.AutoEgg then
            pcall(function()
                local args = {
                    [1] = _G.Hub.EggConfig.SelectedEgg,
                    [2] = _G.Hub.EggConfig.MultiOpen and "Triple" or "Single"
                }
                -- Remote für das Öffnen von Eiern
                RS.Events.EggOpened:FireServer(unpack(args))
            end)
        end
    end
end)

-- Auto-Delete Logik (Beispielhaft, je nach Remote-Name)
task.spawn(function()
    while task.wait(2) do
        if _G.Hub.Toggles.DeleteCommon then
            -- Hier müsste die spezifische Remote für das Löschen von Pets rein
            -- RS.Events.PetAction:FireServer("DeleteLowTier") 
        end
    end
end)

print("✅ Egg Modul erfolgreich geladen.")
