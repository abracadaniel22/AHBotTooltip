-- This file contains shared functionality used by other modules
-- @author Abracadaniel22
-- .ahbot buyeritemvalue 2319
-- AHBOT_BUYERITEMVALUE:2319:10000

local addonName, addon = ...
local API = {}
local pendingQueries = {}
API.cache = {}

AHBotTooltipDB = AHBotTooltipDB or {
    debug = false
}

AHBOT_QUERY_PREFIX = "AHBOT_BUYERITEMVALUE"

AHBOT_ADDON_COLOUR="fc6203"
AHBOT_COLOUR_TEXT="|cFF" .. AHBOT_ADDON_COLOUR .. "%s|r"

function API.ColourText(text)
    return string.format(AHBOT_COLOUR_TEXT, text)
end

function API.PrintAddonMessage(text)
    print(string.format(AHBOT_COLOUR_TEXT, "[AHBotTooltip]") .. " " .. text)
end

function API.FormatNumberWithCommas(n)
    local str = tostring(n)
    local result = str:reverse():gsub("(%d%d%d)", "%1,")
    result = result:reverse()
    if result:sub(1,1) == "," then
        result = result:sub(2)
    end
    return result
end

function API.FormatMoney(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copper = copper % 100

    local result = ""
    if gold > 0 then
        result = result .. API.FormatNumberWithCommas(gold) .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t "
    end
    if silver > 0 then
        result = result .. silver .. "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t "
    end
    if copper > 0 or result == "" then
        result = result .. copper .. "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"
    end
    return result
end

-- TODO add support for querying multiple items at once and make addon batch queries if they happen less than .2s apart
function API.QueryBuyerItemValue(itemId, forceServerCheck)
    if not forceServerCheck and API.cache[itemId] ~= nil then
        return API.cache[itemId]
    end
    if pendingQueries[itemId] then
        return
    end
    pendingQueries[itemId] = true
    SendChatMessage(".ahbot buyeritemvalue " .. itemId, "GUILD")
end

function API.HandleChatMessage(message)
    if message:find("^" .. AHBOT_QUERY_PREFIX) then
        local hideServerMessage = not AHBotTooltipDB.debug
        local itemId, status = message:match(AHBOT_QUERY_PREFIX..":(%d+):(%d+)")
        if itemId and status then
            itemId = tonumber(itemId)
            price = tonumber(status)
            
            API.cache[itemId] = price
            pendingQueries[itemId] = nil

            if API.OnCacheUpdated then
                API.OnCacheUpdated(itemId, price)
            end
        end
        return hideServerMessage
    end
    
    return false -- Message not handled by us. Don't hide it.
end

function API.GetBuyerItemValue(itemId)
    return API.cache[itemId]
end

function API.HandleSlashCommand(msg)
    msg = msg:lower()
    
    if msg == "debug" then
        AHBotTooltipDB.debug = not AHBotTooltipDB.debug
        API.PrintAddonMessage("Server messages will" .. (AHBotTooltipDB.debug and " " or " not ") .. "be shown.")
    elseif msg == "clear" then
        API.cache = {}
        pendingQueries = {}
        API.PrintAddonMessage("Cache cleared.")
    elseif msg == "status" then
        local cacheSize = 0
        for _ in pairs(API.cache) do
            cacheSize = cacheSize + 1
        end
        API.PrintAddonMessage("Status:")
        print("  Server messages: " .. (AHBotTooltipDB.debug and "Not hidden" or "Hidden"))
        print("  Cached items: " .. cacheSize)
    else
        API.PrintAddonMessage("Commands:")
        print("  /ahbot clear - Clear the in-memory cache (or you can log out/log back in)")
        print("  /ahbot debug - Toggle hiding or showing server messages")
        print("  /ahbot status - Show addon status")
    end
end 

function API.Initialize()
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, message, ...)
        return API.HandleChatMessage(message)
    end)

    SLASH_AHBOTTOOLTIP1 = "/ahbot"
    SlashCmdList["AHBOTTOOLTIP"] = addon.API.HandleSlashCommand
end

addon.API = API