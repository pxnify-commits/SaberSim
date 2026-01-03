-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (REORDERED & DYNAMIC)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}
local SelectedEgg = ""

-- 1. DATEN SAMMELN (Reihenfolge erzwingen)
local function GetOrderedEggs()
    local success, PetShopInfo = pcall(function()
        return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo", 10))
    end)

    if success and PetShopInfo then
        -- Wir nutzen eine geordnete Suche nach Welten/Indexen
        local keys = {}
        for k in pairs(PetShopInfo) do table.insert(keys, k) end
        
        -- Sortiere nur die Keys (1, 2, 3...), damit die Welten stimmen
        table.sort(keys, function(a, b)
            if type(a) == "number" and type(b) == "number" then return a < b end
            return tostring(a) < tostring(b)
        end)

        for _, k in ipairs(keys) do
            local v = PetShopInfo[k]
            if type(v) == "table" then
                -- Suche nach EggName in dieser Welt
                local function findDeep(tbl)
                    for _, val in pairs(tbl) do
                        if type(val) == "table" then
                            if val.EggName then
                                if not table.find(EggList, val.EggName) then
                                    table.insert(EggList, val.EggName)
                                end
                            else
                                findDeep(val)
                            end
                        end
                    end
                end
                findDeep(v)
            end
        end
    end
end

-- Ausführen
GetOrderedEggs()

-- Falls immer noch leer, Backup
if #EggList == 0 then EggList = {"Common Egg", "Uncommon Egg"} end
SelectedEgg = EggList[1]

-- 2. DEIN UI LAYOUT (Wird erst hier erstellt)
Tab:CreateSection("🥚 Egg Hatching")

if #EggList > 0 then
    Tab:CreateDropdown({
        Name = "Select Egg",
        Options = EggList,
        CurrentOption = EggList[1],
        Callback = function(opt)
            SelectedEgg = type(opt) == "table" and opt[1] or opt
        end
    })
else
    Tab:CreateLabel("⚠️ Keine Eggs gefunden")
end

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
        _G.Hub.Settings.EggHatchDelay = v
    end
})

Tab:CreateSection("📊 Info")
-- Hier wird die Anzahl jetzt korrekt angezeigt, weil die Liste oben fertig befüllt wurde
Tab:CreateLabel("Gefundene Eggs: " .. tostring(#EggList))

-- 3. HATCH LOOP
task.spawn(function()
    while task.wait() do
        if _G.Hub.Toggles.AutoHatch then
            if SelectedEgg ~= "" then
                RS.Events.UIAction:FireServer("BuyEgg", SelectedEgg)
            end
            task.wait(_G.Hub.Settings.EggHatchDelay or 0.3)
        end
    end
end)
