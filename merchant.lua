-- ========================================================
-- 💰 MERCHANT MODULE (60 MIN TIMER)
-- ========================================================

local Tab = _G.Hub["💰 Merchant"]
local RS = game:GetService("ReplicatedStorage")

-- Sicherstellen, dass die Tabellen existieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Variablen
local itemsBoughtCount = 0
local MerchantOptions = {"Strength", "Coins", "Pet XP"}
_G.Hub.Config.SelectedMerchantItem = MerchantOptions[1]

-- 1. FUNKTIONEN FÜR STATUS UND TIMER
local function GetMerchantStatus()
    local merchant = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Travelling Merchant")
    return merchant ~= nil
end

local function GetNextMerchantTime()
    -- Berechnung für 60 Minuten (3600 Sekunden)
    local interval = 3600
    local timeInSeconds = math.floor(os.time() % interval)
    local timeLeft = interval - timeInSeconds
    
    local minutes = math.floor(timeLeft / 60)
    local seconds = timeLeft % 60
    return string.format("%02d:%02d", minutes, seconds)
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

Tab:CreateSection("📊 Status & Timer")
local statusLabel = Tab:CreateLabel("Status: Prüfe...")
local timerLabel = Tab:CreateLabel("Nächster Merchant in: --:--")
local buyLabel = Tab:CreateLabel("Items gekauft: 0")

-- 3. MERCHANT LOGIK & TIMER LOOP
task.spawn(function()
    while true do
        local isHere = GetMerchantStatus()
        
        -- Update Status & Timer
        if isHere then
            statusLabel:Set("Status: ✅ Erschienen!")
            timerLabel:Set("Nächster Merchant in: Händler ist da!")
        else
            statusLabel:Set("Status: ❌ Nicht da")
            timerLabel:Set("Nächster Merchant in: ~ " .. GetNextMerchantTime())
        end
        
        -- Auto Buy Logik
        if _G.Hub.Toggles.AutoMerchant and isHere then
            local itemToBuy = _G.Hub.Config.SelectedMerchantItem
            pcall(function()
                -- Nutzt die UIAction Remote
                RS.Events.UIAction:FireServer("BuyMerchantItem", itemToBuy)
                itemsBoughtCount = itemsBoughtCount + 1
                buyLabel:Set("Items gekauft: " .. tostring(itemsBoughtCount))
            end)
            task.wait(_G.Hub.Config.MerchantSpeed or 0.5)
        else
            task.wait(1) -- Normaler Update-Takt jede Sekunde
        end
    end
end)
