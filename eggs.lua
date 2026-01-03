-- ========================================================
-- 🥚 GITHUB MODULE: EGG HATCHER (FIXED OPENING)
-- ========================================================

local Tab = _G.Hub["🥚 Eggs"]
local RS = game:GetService("ReplicatedStorage")
local EggList = {}

-- 1. EIER LADEN (Nativ)
local function LoadEggs()
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
end

LoadEggs()
if #EggList == 0 then EggList = {"Common Egg", "Uncommon Egg"} end

-- 2. UI ELEMENTE
Tab:CreateSection("🥚 Egg Hatching")

Tab:CreateDropdown({
    Name = "Select Egg",
    Options = EggList,
    CurrentOption = EggList[1],
    Callback = function(opt)
        -- Wir speichern die Auswahl direkt in der Config
        local choice = type(opt) == "table" and opt[1] or opt
        _G.Hub.Config.SelectedEgg = choice
    end
})

-- Initialwert setzen, falls nichts angeklickt wird
_G.Hub.Config.SelectedEgg = EggList[1]

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
        _G.Hub.Config.EggHatchDelay = v
    end
})

Tab:CreateSection("📊 Info")
Tab:CreateLabel("Gefundene Eggs: " .. tostring(#EggList))

-- 3. HATCH LOOP (FIXED)
task.spawn(function()
    while task.wait() do
        if _G.Hub.Toggles.AutoHatch then
            local eggName = _G.Hub.Config.SelectedEgg
            
            if eggName and eggName ~= "" then
                -- Wir versuchen beide gängigen Remotes für Saber Sim
                pcall(function()
                    RS.Events.UIAction:FireServer("BuyEgg", eggName)
                    -- Falls BuyEgg nicht geht, probieren wir das direkte Event:
                    -- RS.Events.OpenEgg:FireServer(eggName) 
                end)
            end
            
            task.wait(_G.Hub.Config.EggHatchDelay or 0.3)
        else
            task.wait(0.5) -- Spart Ressourcen, wenn aus
        end
    end
end)
