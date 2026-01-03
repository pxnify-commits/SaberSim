-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (ORDERED BY DATA)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}
local SelectedEgg = ""

-- 1. LOGIK: EIER IN DER ORIGINAL-REIHENFOLGE EXTRAHIEREN
local function CollectEggNames()
    local success, PetShopInfo = pcall(function()
        return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo"))
    end)

    if success then
        -- Wir gehen die Tabelle so durch, wie sie im Modul steht
        local function scan(t)
            -- Wir nutzen pairs, aber da PetShopInfo oft numerisch indiziert ist, 
            -- bleibt die Reihenfolge der Definition meist erhalten.
            for k, v in pairs(t) do
                if type(v) == "table" then
                    if v.EggName then
                        -- Nur einfügen, wenn noch nicht in der Liste
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
    else
        warn("❌ Fehler beim Laden von PetShopInfo!")
    end
end

-- Eier suchen
CollectEggNames()

-- Falls keine Eier gefunden wurden (Notfall)
if #EggList == 0 then
    EggList = {"Common Egg", "Uncommon Egg", "Rare Egg"}
end

-- WICHTIG: table.sort(EggList) wurde entfernt, damit die 
-- Reihenfolge aus dem PetShopInfo-Modul beibehalten wird.

SelectedEgg = EggList[1]

-- 2. UI ELEMENTE
Tab:CreateSection("🐣 Egg Selection")

Tab:CreateDropdown({ 
    Name = "Select Egg", 
    Options = EggList, 
    CurrentOption = SelectedEgg, 
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
                        RS.Events.UIAction:FireServer("BuyEgg", SelectedEgg) 
                    end 
                    task.wait(0.3) 
                end 
            end)
        end
    end 
})

Tab:CreateLabel("Gefundene Eggs: " .. #EggList)
