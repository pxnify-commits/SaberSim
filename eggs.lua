-- ========================================================
-- 🥚 FINISHED EGG MODULE (WITH HATCH COUNTER)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}

-- Sicherstellen, dass die Tabellen existieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Zähler Variable (lokal für dieses Script)
local eggsHatchedCount = 0

-- 1. EIER LADEN
local success, PetShopInfo = pcall(function()
    return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo", 10))
end)

if success and PetShopInfo then
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

if #EggList == 0 then EggList = {"Basic Egg"} end

-- 2. UI ELEMENTE
Tab:CreateSection("🥚 Egg Hatching")

Tab:CreateDropdown({
    Name = "Select Egg",
    Options = EggList,
    CurrentOption = EggList[1],
    Callback = function(opt)
        local choice = type(opt) == "table" and opt[1] or opt
        _G.Hub.Config.SelectedEgg = choice
    end
})

-- Startwerte
_G.Hub.Config.SelectedEgg = EggList[1]
_G.Hub.Config.EggHatchDelay = 0.3

Tab:CreateToggle({
    Name = "Auto Hatch",
    CurrentValue = false,
    Callback = function(v) 
        _G.Hub.Toggles.AutoHatch = v 
    end
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

-- DAS LIVE-LABEL FÜR DIE GEÖFFNETEN EIER
local hatchLabel = Tab:CreateLabel("Egg Hatched: 0")

-- 3. DER HATCH-LOOP MIT ZÄHLER
task.spawn(function()
    while true do
        task.wait()
        
        if _G.Hub.Toggles.AutoHatch then
            local currentEgg = _G.Hub.Config.SelectedEgg
            
            if currentEgg and currentEgg ~= "" then
                pcall(function()
                    -- Kauf-Event feuern
                    RS.Events.UIAction:FireServer("BuyEgg", currentEgg)
                    
                    -- Zähler erhöhen und UI aktualisieren
                    eggsHatchedCount = eggsHatchedCount + 1
                    hatchLabel:Set("Egg Hatched: " .. tostring(eggsHatchedCount))
                end)
            end
            
            task.wait(_G.Hub.Config.EggHatchDelay or 0.3)
        end
    end
end)
