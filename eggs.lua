-- ========================================================
-- 🥚 FINISHED EGG MODULE
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}

-- 1. EIER LADEN (Genau wie dein Test-Script)
local success, PetShopInfo = pcall(function()
    return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo"))
end)

if success then
    -- Einfacher Scan ohne Sortierung (behält Original-Reihenfolge)
    local function scan(t)
        for k, v in pairs(t) do
            if type(v) == "table" then
                if v.EggName then
                    if not table.find(EggList, v.EggName) then
                        table.insert(EggList, v.EggName)
                    end
                else
                    scan(v)
                end
            end
        end
    end
    scan(PetShopInfo)
end

-- Falls nichts gefunden wurde (Notfall-Backup)
if #EggList == 0 then EggList = {"Common Egg", "Uncommon Egg"} end

-- Initial-Wert für das ausgewählte Ei setzen
_G.Hub.Config.SelectedEgg = EggList[1]

-- 2. UI ELEMENTE
Tab:CreateSection("🥚 Egg Hatching")

Tab:CreateDropdown({
    Name = "Select Egg",
    Options = EggList,
    CurrentOption = EggList[1],
    Callback = function(opt)
        _G.Hub.Config.SelectedEgg = type(opt) == "table" and opt[1] or opt
    end
})

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
        _G.Hub.Config.EggHatchDelay = v
    end
})

Tab:CreateSection("📊 Info")
Tab:CreateLabel("Gefundene Eggs: " .. tostring(#EggList))

-- 3. DER HATCH-LOOP (Stabil & Getestet)
task.spawn(function()
    while true do
        task.wait(_G.Hub.Config.EggHatchDelay or 0.3)
        
        if _G.Hub.Toggles.AutoHatch then
            local egg = _G.Hub.Config.SelectedEgg
            if egg and egg ~= "" then
                -- Das Event für den Saber Simulator
                RS.Events.UIAction:FireServer("BuyEgg", egg)
            end
        end
    end
end)
