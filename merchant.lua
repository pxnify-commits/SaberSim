-- ========================================================
-- 💰 MERCHANT MODULE (TYPE SELECTION FIXED)
-- ========================================================

local Tab = _G.Hub["💰 Merchant"]
local RS = game:GetService("ReplicatedStorage")

-- Sicherstellen, dass die Tabellen existieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Variablen für den Counter
local itemsBoughtCount = 0
local MerchantOptions = {"Strength", "Coins", "Pet XP"}
_G.Hub.Config.SelectedMerchantItem = MerchantOptions[1]

-- 1. FUNKTION: MERCHANT STATUS PRÜFEN
local function GetMerchantStatus()
    local merchant = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Travelling Merchant")
    if merchant then
        return "✅ Erschienen"
    else
        return "❌ Nicht da"
    end
end

-- 2. UI ELEMENTE
Tab:CreateSection("💰 Merchant Settings")

Tab:CreateDropdown({
    Name = "Select Item Type",
    Options = MerchantOptions,
    CurrentOption = MerchantOptions[1],
    Callback = function(opt)
        _G.Hub.Config.SelectedMerchantItem = type(opt) == "table" and opt[1] or opt
    end
})

Tab:CreateToggle({
    Name = "Auto Buy from Merchant",
    CurrentValue = false,
    Callback = function(v) 
        _G.Hub.Toggles.AutoMerchant = v 
    end
})

Tab:CreateSlider({
    Name = "Buy Speed (seconds)",
    Range = {0.1, 3},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(v)
        _G.Hub.Config.MerchantSpeed = v
    end
})

Tab:CreateSection("📊 Status & Info")
local statusLabel = Tab:CreateLabel("Status: " .. GetMerchantStatus())
local buyLabel = Tab:CreateLabel("Items gekauft: 0")

-- 3. MERCHANT LOGIK LOOP
task.spawn(function()
    while true do
        task.wait(0.5) -- Status-Check
        
        -- Status Label aktualisieren
        statusLabel:Set("Status: " .. GetMerchantStatus())
        
        if _G.Hub.Toggles.AutoMerchant then
            local merchant = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Travelling Merchant")
            local itemToBuy = _G.Hub.Config.SelectedMerchantItem
            
            if merchant and itemToBuy then
                pcall(function()
                    -- Die korrekte Remote-Logik für den Merchant
                    -- Argument 1: Aktion, Argument 2: Typ (Strength, Coins, etc.)
                    RS.Events.UIAction:FireServer("BuyMerchantItem", itemToBuy)
                    
                    itemsBoughtCount = itemsBoughtCount + 1
                    buyLabel:Set("Items gekauft: " .. tostring(itemsBoughtCount))
                end)
            end
            
            task.wait(_G.Hub.Config.MerchantSpeed or 0.5)
        end
    end
end)
