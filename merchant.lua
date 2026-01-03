-- ========================================================
-- 💰 MERCHANT MODULE (PRO LOGIC - FIXED)
-- ========================================================

local Tab = _G.Hub["💰 Merchant"]
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- Variablen für Counter und Auswahl
local itemsBoughtCount = 0
local SlotOptions = {"Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5"}
_G.Hub.Config.SelectedMerchantSlot = 1

-- 1. FUNKTION: DATEN AUSLESEN (Wichtig für den Zeitstempel)
local function GetMerchantData()
    local player = game.Players.LocalPlayer
    -- Wir versuchen die Daten aus dem ClientDataManager oder PlayerGui zu fischen
    local success, data = pcall(function()
        return require(RS.Modules.ClientDataManager).Data.TravelingMerchant
    end)
    return success and data or nil
end

-- 2. STATUS & TIMER FUNKTIONEN
local function GetNextMerchantTime()
    local timeLeft = 3600 - (os.time() % 3600)
    return string.format("%02d:%02d", math.floor(timeLeft / 60), timeLeft % 60)
end

-- 3. UI ELEMENTE
Tab:CreateSection("💰 Merchant Auto-Buy")

Tab:CreateDropdown({
    Name = "Select Shop Slot",
    Options = SlotOptions,
    CurrentOption = "Slot 1",
    Callback = function(opt)
        -- Extrahiert die Nummer aus "Slot 1" -> 1
        local num = tostring(opt):match("%d+")
        _G.Hub.Config.SelectedMerchantSlot = tonumber(num) or 1
    end
})

Tab:CreateToggle({
    Name = "Auto Buy Selected Slot",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoMerchant = v end
})

Tab:CreateSlider({
    Name = "Buy Speed (seconds)",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(v) _G.Hub.Config.MerchantSpeed = v end
})

Tab:CreateSection("📊 Info & Live Timer")
local statusLabel = Tab:CreateLabel("Status: Prüfe...")
local timerLabel = Tab:CreateLabel("Timer: --:--")
local buyLabel = Tab:CreateLabel("Gekaufte Items: 0")

-- 4. DER KAUF-LOOP (Basierend auf SimpleSpy)
task.spawn(function()
    while true do
        local merchantData = GetMerchantData()
        local merchantExists = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Travelling Merchant")
        
        -- UI Updates
        pcall(function()
            statusLabel:Set(merchantExists and "Status: ✅ Händler ist da!" or "Status: ❌ Nicht da")
            timerLabel:Set("Nächster Merchant in: ~ " .. GetNextMerchantTime())
        end)

        if _G.Hub.Toggles.AutoMerchant and merchantExists and merchantData then
            pcall(function()
                -- Das Event aus deinem SimpleSpy
                -- args[2] = Slot Index
                -- args[3] = ResetDT (Zeitstempel aus den Spieldaten)
                RS.Events.UIAction:FireServer(
                    "TravelingMerchantBuyItem", 
                    _G.Hub.Config.SelectedMerchantSlot, 
                    merchantData.ResetDT
                )
                
                itemsBoughtCount = itemsBoughtCount + 1
                buyLabel:Set("Gekaufte Items: " .. tostring(itemsBoughtCount))
            end)
            task.wait(_G.Hub.Config.MerchantSpeed or 0.5)
        else
            task.wait(1)
        end
    end
end)
