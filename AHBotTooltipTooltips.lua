-- Handles showing data in tooltip
-- @author Abracadaniel22

local addonName, addon = ...
local TooltipsModule = {}
local API = addon.API

function TooltipsModule.GetItemIdFromTooltip(tooltip)
    local name, link = tooltip:GetItem()
    if not link then
        return nil, nil, nil, nil
    end
    return tonumber(link:match("item:(%d+)"))
end

function TooltipsModule.UpdateTooltip(tooltip)
    local itemId = TooltipsModule.GetItemIdFromTooltip(tooltip)
    if not itemId then
        return
    end
    API.QueryBuyerItemValue(itemId)
    local value = API.GetBuyerItemValue(itemId)
    if value ~= nil then
        tooltip:AddDoubleLine("AH bot pays", API.FormatMoney(value))
    end
end

function TooltipsModule.HookTooltip(tooltip)
    if tooltip.AhBotTooltipHooked then
        return
    end
    tooltip.AhBotTooltipHooked = true
    local originalOnTooltipSetItem = tooltip:GetScript("OnTooltipSetItem")
    tooltip:SetScript("OnTooltipSetItem", function(self, ...)
        if originalOnTooltipSetItem then
            originalOnTooltipSetItem(self, ...)
        end
        TooltipsModule.UpdateTooltip(self)
    end)
end

function TooltipsModule.Initialize()
	-- TODO run a test .ahbot buyeritemvalue 2319 command on the server to see if 
	-- api is available. If not, print warning and do not hook up tooltip
    TooltipsModule.HookTooltip(GameTooltip)
    TooltipsModule.HookTooltip(ItemRefTooltip)
    if ShoppingTooltip1 then TooltipsModule.HookTooltip(ShoppingTooltip1) end
    if ShoppingTooltip2 then TooltipsModule.HookTooltip(ShoppingTooltip2) end
end

addon.TooltipsModule = TooltipsModule