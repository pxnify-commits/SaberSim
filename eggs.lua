-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (WITH LOAD INFO)
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
        local function scan(t)
            -- Wir prüfen zuerst auf numerische Indizes (Reihenfolge der Welten)
            local keys = {}
            for k in pairs(t) do table.insert(keys, k) end
            
            -- Sortiere Keys, damit [1] vor [2] kommt
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
                        scan(v) -- Tiefer in die Welten/Bereiche gehen
                    end
                end
            end
        end
        scan(PetShopInfo)
    end
end

CollectEggNames()

-- Notfall-Liste
if #EggList == 0 then
    EggList = {"Common Egg", "Uncommon Egg"}
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

-- 3. INFO SEKTION (Wie viele wurden geladen)
Tab:CreateSection("📊 Status Info")

Tab:CreateLabel("✅ " .. #EggList .. " Eggs erfolgreich geladen")

if #EggList > 0 then
    Tab:CreateLabel("Erstes Ei: " .. EggList[1])
    Tab:CreateLabel("Letztes Ei: " .. EggList[#EggList])
end
