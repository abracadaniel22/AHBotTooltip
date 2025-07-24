-- Main initialization file - coordinates all modules
-- @author Abracadaniel22

local addonName, addon = ...

local function InitializeAddon()
    addon.API.Initialize()
    addon.TooltipsModule.Initialize()
    addon.API.PrintAddonMessage("Addon loaded. Type /ahbot for options.")
    local publicAHBotTooltipAPI = _G.AHBotTooltipAPI or {}
    publicAHBotTooltipAPI.GetBuyerItemValueFromCache = addon.API.GetBuyerItemValue
    _G.AHBotTooltipAPI = publicAHBotTooltipAPI
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon == addonName then
        InitializeAddon()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)