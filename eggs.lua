-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (STRICT ORDER)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}
local SelectedEgg = ""

-- 1. LOGIK: EIER IN STRENGER REIHENFOLGE EXTRAHIEREN
local function CollectEggNames()
    local success, PetShopInfo = pcall(function()
        return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo"))
    end)

    if success then
        -- Funktion zum Scannen, die numerische Reihenfolge bevorzugt
        local function scan(t)
            -- Zuerst versuchen wir es numerisch (1, 2, 3...), um die Reihenfolge zu halten
            for i = 1, 100 do -- Geht bis zu 100 mögliche Einträge/Welten durch
                local v = t[i] or t[tostring(i)]
                if v and type(v) == "table" then
                    if v.EggName then
                        table.insert(EggList, v.EggName)
                    else
                        scan(v) -- Tiefer graben (z.B. in Welten-Untertabellen)
                    end
                end
            end
            
            -- Falls die Eier nicht numerisch sind, nutzen wir pairs als Backup
            -- (Aber nur für Dinge, die wir oben nicht schon gefunden haben)
            for k, v in pairs(t) do
                if type(v) == "table" and not tonumber(k) then
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
    else
        warn("❌ Fehler beim Laden von PetShopInfo!")
    end
end

CollectEggNames()

-- Notfall-Eier
if #EggList == 0 then
    EggList = {"Common Egg", "Uncommon Egg", "Rare Egg"}
end

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
