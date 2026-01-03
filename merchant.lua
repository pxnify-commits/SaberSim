-- ========================================================
-- 💰 MERCHANT MODULE (SMART TYPE SCANNER)
-- ========================================================

local Tab = _G.Hub["💰 Merchant"]
local RS = game:GetService("ReplicatedStorage")

_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

local itemsBoughtCount = 0
local AvailableTypes = {"Boosts", "Pets", "Charms"}
_G.Hub.Config.SelectedMerchantType = "Pets"

-- 1. FUNKTION: LIVE-DATEN HOLEN
local function GetMerchantData()
    local success, data = pcall(function()
        -- Wir brauchen die Daten, um zu wissen, was in welchem Slot liegt
        return require(RS.Modules.ClientDataManager).Data.TravelingMerchant
    end)
    return success and data or nil
end

-- 2. FUNKTION: MODUL FÜR TYPES (Für das Dropdown)
local function GetTypesFromModule()
    local success, Info = pcall(function()
        return require(RS.Modules:WaitForChild("TravelingMerchantInfo", 10))
    end)
    if success and Info and Info.Listings then
        local types = {}
        for _, v in pairs(Info.Listings) do
            if v.Type and not table.find(types, v.Type) then
                table.insert(types, v.Type)
            end
        end
        return types
    end
    return AvailableTypes
end

-- 3. UI ELEMENTE
Tab:CreateSection("💰 Smart Auto-Buy")

Tab:CreateDropdown({
    Name = "Select Type to Buy",
    Options = GetTypesFromModule(),
    CurrentOption = "Pets",
    Callback = function(opt)
        _G.Hub.Config.SelectedMerchantType = type(opt) == "table" and opt[1] or opt
    end
})

Tab:CreateToggle({
    Name = "Auto Buy Selected Type",
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

Tab:CreateSection("📊 Info")
local statusLabel = Tab:CreateLabel("Status: Warten...")
local buyLabel = Tab:CreateLabel("Gekaufte Items: 0")

-- 4. SMART LOGIK LOOP
task.spawn(function()
    -- Wir brauchen auch das Info-Modul, um IDs in Typen zu übersetzen
    local InfoModule = require(RS.Modules:WaitForChild("TravelingMerchantInfo"))

    while true do
        local merchantData = GetMerchantData()
        local isHere = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Travelling Merchant")
        
        if isHere then
            statusLabel:Set("Status: ✅ Händler aktiv")
        else
            statusLabel:Set("Status: ❌ Händler nicht da")
        end

        if _G.Hub.Toggles.AutoMerchant and isHere and merchantData then
            local targetType = _G.Hub.Config.SelectedMerchantType
            
            -- Wir scannen die aktuellen Items im Shop (merchantData.Items)
            for slotIndex, itemData in pairs(merchantData.Items) do
                -- itemData.Index sagt uns, welches Item aus dem Info-Modul es ist
                local itemInfo = InfoModule.Listings[itemData.Index]
                
                if itemInfo and itemInfo.Type == targetType then
                    -- Nur kaufen, wenn noch Käufe übrig sind
                    if itemData.BuysLeft and itemData.BuysLeft > 0 then
                        pcall(function()
                            RS.Events.UIAction:FireServer(
                                "TravelingMerchantBuyItem", 
                                slotIndex, 
                                merchantData.ResetDT
                            )
                            itemsBoughtCount = itemsBoughtCount + 1
                            buyLabel:Set("Gekaufte Items: " .. tostring(itemsBoughtCount))
                        end)
                    end
                end
            end
        end
        task.wait(_G.Hub.Config.MerchantSpeed or 0.5)
    end
end)
