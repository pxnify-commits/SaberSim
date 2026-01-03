-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (NATIVE ORDER)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}

-- 1. EIER DIREKT AUS DEM MODUL SAMMELN (Nativ)
local success, PetShopInfo = pcall(function()
    return require(RS.Modules.PetsInfo:WaitForChild("PetShopInfo"))
end)

if success then
    -- Funktion scannt einfach alles durch
    local function scan(t)
        for k, v in pairs(t) do
            if type(v) == "table" then
                if v.EggName then
                    -- Einfach in die Liste werfen (Reihenfolge bleibt nativ)
                    if not table.find(EggList, v.EggName) then
                        table.insert(EggList, v.EggName)
                    end
                else
                    scan(v) -- Untertabellen scannen
                end
            end
        end
    end
    scan(PetShopInfo)
end

-- 2. UI ELEMENTE (Dein Layout)
Tab:CreateSection("🥚 Egg Hatching")

if #EggList > 0 then
    Tab:CreateDropdown({
        Name = "Select Egg",
        Options = EggList,
        CurrentOption = EggList[1],
        Callback = function(opt)
            _G.Hub.Settings.SelectedEgg = type(opt) == "table" and opt[1] or opt
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
-- Dieses Label zeigt jetzt die exakte Zahl aus der unberührten Liste an
Tab:CreateLabel("Gefundene Eggs: " .. tostring(#EggList))

-- 3. HATCH LOOP
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
