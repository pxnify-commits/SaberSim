-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (FIXED INFO)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}
local SelectedEgg = ""

-- 1. LOGIK: EIER IN STRENGER REIHENFOLGE EXTRAHIEREN
local function CollectEggNames()
    local success, PetShopInfo = pcall(function()
        -- Wir warten kurz, bis das Modul wirklich da ist
        return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo", 10))
    end)

    if success and PetShopInfo then
        local function scan(t)
            local keys = {}
            for k in pairs(t) do table.insert(keys, k) end
            
            -- Numerische Sortierung der Welten/Eier
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then return a < b end
                return tostring(a) < tostring(b)
            end)

            for _, k in ipairs(keys) do
                local v = t[k]
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
end

-- Suche ausführen
CollectEggNames()

-- Notfall-Liste falls leer
if #EggList == 0 then
    EggList = {"Common Egg", "Uncommon Egg"}
end
SelectedEgg = EggList[1]

-- 2. UI ELEMENTE (Jetzt werden sie erstellt)
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

-- 3. INFO SEKTION (Fest im Menü verankert)
Tab:CreateSection("📊 Status Info")

-- Wir erstellen das Label mit der Anzahl
local infoLabel = Tab:CreateLabel("Geladene Eier: " .. tostring(#EggList))

-- Ein kleiner Test-Print in die Console (F9), damit du siehst ob es im Hintergrund klappt
print("--- SABER SIM DEBUG ---")
print("Anzahl Eier in Liste: " .. #EggList)
for i, name in ipairs(EggList) do
    print(i .. ". " .. name)
end
