-- ========================================================
-- 🥚 FINISHED EGG MODULE (SIMPLESPY FIX)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}

-- Sicherstellen, dass die Tabellen existieren, damit kein "nil" Fehler kommt
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Standardwerte setzen
_G.Hub.Config.SelectedEgg = "Basic Egg"
_G.Hub.Config.EggHatchDelay = 0.3

-- 1. EIER LADEN (Nativ)
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

if #EggList == 0 then EggList = {"Basic Egg", "Common Egg"} end

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

-- 3. DER HATCH-LOOP (Basierend auf deinem SimpleSpy)
task.spawn(function()
    while true do
        task.wait() -- Verhindert Abstürze
        
        if _G.Hub.Toggles.AutoHatch then
            local currentEgg = _G.Hub.Config.SelectedEgg
            
            if currentEgg and currentEgg ~= "" then
                -- DEINE SIMPLESPY LOGIK
                local args = {
                    [1] = "BuyEgg",
                    [2] = currentEgg
                }
                
                pcall(function()
                    RS.Events.UIAction:FireServer(unpack(args))
                end)
            end
            
            -- Wartezeit basierend auf Slider
            task.wait(_G.Hub.Config.EggHatchDelay or 0.3)
        end
    end
end)
