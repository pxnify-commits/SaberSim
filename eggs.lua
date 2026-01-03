-- ========================================================
-- 🥚 GITHUB MODULE: ADVANCED EGG HATCHER
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"] -- Holt den Tab vom Loader
local RS = game:GetService("ReplicatedStorage")

-- 1. EGG LISTE AUS DEN SPIEL-DATEN HOLEN
local EggList = {}
local SelectedEgg = ""

pcall(function() 
    -- Lädt die offiziellen Spieldaten für Eier
    local info = require(RS.Modules.ItemInfo.PetShopInfo) -- Pfad evtl. ItemInfo oder PetsInfo
    local function collect(t) 
        for k,v in pairs(t) do 
            if type(v) == "table" then 
                if v.EggName then 
                    table.insert(EggList, v.EggName) 
                else 
                    collect(v) 
                end 
            end 
        end 
    end
    collect(info)
end)

-- Falls das Modul nicht gefunden wurde, Standard-Eier setzen
if #EggList == 0 then 
    EggList = {"Common Egg", "Uncommon Egg", "Rare Egg", "Epic Egg"} 
end

SelectedEgg = EggList[1]

-- 2. UI ELEMENTE
Tab:CreateSection("🐣 Selection")

Tab:CreateDropdown({ 
    Name = "Select Egg", 
    Options = EggList, 
    CurrentOption = EggList[1], 
    Callback = function(o) 
        SelectedEgg = type(o) == "table" and o[1] or o 
    end 
})

Tab:CreateSection("🔥 Hatching")

Tab:CreateToggle({ 
    Name = "Auto Hatch", 
    CurrentValue = false, 
    Callback = function(v) 
        _G.Hub.Toggles.AutoHatch = v 
        if v then
            task.spawn(function() 
                while _G.Hub.Toggles.AutoHatch do 
                    if SelectedEgg and SelectedEgg ~= "" then 
                        -- Saber Simulator nutzt oft "BuyEgg" für das Öffnen
                        RS.Events.UIAction:FireServer("BuyEgg", SelectedEgg) 
                    end 
                    task.wait(0.3) -- Geschwindigkeit des Öffnens
                end 
            end)
        end
    end 
})

Tab:CreateSection("📊 Info")
Tab:CreateLabel("Gefundene Eier: " .. #EggList)
