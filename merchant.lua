-- ========================================================
-- 💰 MERCHANT MODULE (LEGACY LOGIC)
-- ========================================================

local Tab = _G.Hub["💰 Merchant"]
local RS = game:GetService("ReplicatedStorage")

-- Sicherstellen, dass die Tabellen existieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Variablen für den Counter
local itemsBoughtCount = 0

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

Tab:CreateToggle({
    Name = "Auto Buy from Merchant",
    CurrentValue = false,
    Callback = function(v) 
        _G.Hub.Toggles.AutoMerchant = v 
    end
})

Tab:CreateSlider({
    Name = "Buy Speed (seconds)",
    Range = {0.5, 5},
    Increment = 0.5,
    CurrentValue = 1,
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
        task.wait(1) -- Status-Check jede Sekunde
        
        -- Status Label aktualisieren
        statusLabel:Set("Status: " .. GetMerchantStatus())
        
        if _G.Hub.Toggles.AutoMerchant then
            -- Check ob Merchant existiert
            local merchant = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Travelling Merchant")
            
            if merchant then
                pcall(function()
                    -- Nutzt die UIAction Remote wie bei den Eggs
                    -- In Saber Sim ist "BuyMerchantItem" oft das Event
                    RS.Events.UIAction:FireServer("BuyMerchantItem")
                    
                    itemsBoughtCount = itemsBoughtCount + 1
                    buyLabel:Set("Items gekauft: " .. tostring(itemsBoughtCount))
                end)
            end
            
            task.wait(_G.Hub.Config.MerchantSpeed or 1)
        end
    end
end)
