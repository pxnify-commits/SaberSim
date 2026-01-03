-- ========================================================
-- 💰 MERCHANT MODULE (DYNAMIC DATA FETCHING)
-- ========================================================

local Tab = _G.Hub["💰 Merchant"]
local RS = game:GetService("ReplicatedStorage")
local MerchantItems = {} -- Hier landen die dynamischen Daten

-- Sicherstellen, dass die Tabellen existieren
_G.Hub.Config = _G.Hub.Config or {}
_G.Hub.Toggles = _G.Hub.Toggles or {}

-- 1. DATEN AUS DEM MODUL HOLEN (Wie bei den Eggs/Pets)
local function LoadMerchantData()
    local success, Info = pcall(function()
        -- Pfad basierend auf deiner Beschreibung
        return require(RS.Modules:WaitForChild("TravelingMerchantInfo"))
    end)

    if success and Info then
        MerchantItems = {} -- Liste leeren für frischen Scan
        
        -- Wir gehen durch das Modul (oft ist es eine Tabelle mit "Items" oder direkt durchnummeriert)
        for k, v in pairs(Info) do
            if type(v) == "table" then
                -- Wir suchen nach dem Namen des Items (oft "Name" oder "ItemName")
                -- Falls das Modul anders aufgebaut ist, passen wir das hier an
                local name = v.Name or v.ItemName or tostring(k)
                if not table.find(MerchantItems, name) then
                    table.insert(MerchantItems, name)
                end
            end
        end
    end
end

-- Initiales Laden
LoadMerchantData()

-- Fallback falls das Modul leer ist oder anders strukturiert
if #MerchantItems == 0 then
    MerchantItems = {"Strength", "Coins", "Pet XP"}
end

-- 2. FUNKTIONEN FÜR STATUS UND TIMER
local function GetMerchantStatus()
    return workspace:FindFirstChild("Merchant") ~= nil or workspace:FindFirstChild("Travelling Merchant") ~= nil
end

local function GetNextMerchantTime()
    local interval = 3600 -- 1 Stunde
    local timeLeft = interval - (math.floor(os.time() % interval))
    return string.format("%02d:%02d", math.floor(timeLeft / 60), timeLeft % 60)
end

-- 3. UI ELEMENTE
Tab:CreateSection("💰 Merchant Settings")

local itemDropdown = Tab:CreateDropdown({
    Name = "Select Merchant Item",
    Options = MerchantItems,
    CurrentOption = MerchantItems[1],
    Callback = function(opt)
        _G.Hub.Config.SelectedMerchantItem = type(opt) == "table" and opt[1] or opt
    end
})

Tab:CreateToggle({
    Name = "Auto Buy from Merchant",
    CurrentValue = false,
    Callback = function(v) _G.Hub.Toggles.AutoMerchant = v end
})

Tab:CreateSlider({
    Name = "Buy Speed (seconds)",
    Range = {0.1, 3},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(v) _G.Hub.Config.MerchantSpeed = v end
})

Tab:CreateSection("📊 Status & Timer")
local statusLabel = Tab:CreateLabel("Status: Prüfe...")
local timerLabel = Tab:CreateLabel("Nächster Merchant in: --:--")
local buyLabel = Tab:CreateLabel("Items gekauft: 0")
local itemsCount = 0

-- 4. LOGIK LOOP
task.spawn(function()
    while true do
        local isHere = GetMerchantStatus()
        
        -- UI Update
        pcall(function()
            statusLabel:Set(isHere and "Status: ✅ Erschienen!" or "Status: ❌ Nicht da")
            timerLabel:Set(isHere and "Nächster Merchant in: Händler ist da!" or "Nächster Merchant in: ~ " .. GetNextMerchantTime())
        end)

        if _G.Hub.Toggles.AutoMerchant and isHere then
            local selected = _G.Hub.Config.SelectedMerchantItem or MerchantItems[1]
            
            pcall(function()
                -- Nutzt die UIAction Remote mit dem dynamischen Namen
                RS.Events.UIAction:FireServer("BuyMerchantItem", selected)
                
                itemsCount = itemsCount + 1
                buyLabel:Set("Items gekauft: " .. tostring(itemsCount))
            end)
            task.wait(_G.Hub.Config.MerchantSpeed or 0.5)
        else
            task.wait(1)
        end
    end
end)
