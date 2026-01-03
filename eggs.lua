-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (DATA-DRIVEN)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}
local SelectedEgg = ""

-- 1. LOGIK: EIER AUS PETSHOPINFO EXTRAHIEREN
local function CollectEggNames()
    local success, PetShopInfo = pcall(function()
        -- Wir nutzen deinen Pfad aus PetsInfo
        return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo"))
    end)

    if success then
        local function scan(t)
            for k, v in pairs(t) do
                if type(v) == "table" then
                    -- Wenn eine Tabelle "EggName" enthält, speichern wir diesen
                    if v.EggName then
                        if not table.find(EggList, v.EggName) then
                            table.insert(EggList, v.EggName)
                        end
                    else
                        -- Falls nicht, suchen wir eine Ebene tiefer
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

-- Notfall-Liste, falls das Modul leer ist
if #EggList == 0 then
    EggList = {"Common Egg", "Uncommon Egg", "Rare Egg"}
end

-- Sortierung der Liste für bessere Übersicht
table.sort(EggList)
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
                        -- Remote-Befehl für den Kauf/Hatch
                        RS.Events.UIAction:FireServer("BuyEgg", SelectedEgg) 
                    end 
                    task.wait(0.3) -- Hatch-Geschwindigkeit
                end 
            end)
        end
    end 
})

Tab:CreateSection("📊 Stats")
Tab:CreateLabel("Verfügbare Eggs: " .. #EggList)

print("✅ Egg-Modul mit " .. #EggList .. " Eiern geladen.")
