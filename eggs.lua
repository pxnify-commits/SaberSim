-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (THE FINAL FIX)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}

-- 1. SCAN FUNKTION (DEIN TEST-SCRIPT ALS BASIS)
local function LoadEggs()
    local success, PetShopInfo = pcall(function()
        return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo", 10))
    end)

    if success and PetShopInfo then
        -- Wir leeren die Liste vorher, um sicher zu sein
        EggList = {}
        
        local function scan(t)
            for k, v in pairs(t) do
                if type(v) == "table" then
                    if v.EggName then
                        -- Wir fügen es ein, wenn es "EggName" besitzt
                        table.insert(EggList, v.EggName)
                    else
                        scan(v) -- Untertabellen
                    end
                end
            end
        end
        scan(PetShopInfo)
    end
end

-- 2. ERZWINGE DAS LADEN (Wartet bis Daten da sind)
LoadEggs()

-- Wenn er nach dem ersten Mal nichts findet, versuchen wir es kurz erneut
if #EggList <= 2 then
    task.wait(1)
    LoadEggs()
end

-- Backup nur, wenn ABSOLUT nichts im Modul gefunden wurde
if #EggList == 0 then
    EggList = {"Common Egg", "Uncommon Egg"}
end

-- 3. UI ELEMENTE (DEIN LAYOUT)
Tab:CreateSection("🥚 Egg Hatching")

if #EggList > 2 or EggList[1] ~= "Common Egg" then
    Tab:CreateDropdown({
        Name = "Select Egg",
        Options = EggList,
        CurrentOption = EggList[1],
        Callback = function(opt)
            _G.Hub.Settings.SelectedEgg = type(opt) == "table" and opt[1] or opt
        end
    })
else
    Tab:CreateLabel("⚠️ Nur Backup-Eggs geladen")
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
Tab:CreateLabel("Gefundene Eggs: " .. tostring(#EggList))

-- 4. HATCH LOOP
task.spawn(function()
    while task.wait() do
        if _G.Hub.Toggles.AutoHatch then
            local egg = _G.Hub.Settings.SelectedEgg or EggList[1]
            if egg and egg ~= "" then
                RS.Events.UIAction:FireServer("BuyEgg", egg)
            end
            task.wait(_G.Hub.Settings.EggHatchDelay or 0.3)
        end
    end
end)
