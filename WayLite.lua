--[[
    WayLite by FiveStar
    (C) 2022
]]

local WLCOLOR_TITLE = "|cFFE6A009"
local WLCOLOR_ERROR = "|cFFAA0000"
local WLCOLOR_CMD = "|cFF00CCFF"
local WLCOLOR_OPTIONAL = "|cFFCCCCCC"

local addonName, addon = ...
local WayLite = addon
_G[addonName] = addon

WayLite.name = addonName
WayLite.CompatibilityMode = false -- disable /way command if another addon handles it
WayLite.HasShownActivityMessage = false

local frame = CreateFrame("Frame", addonName .. "EventFrame")
frame:RegisterEvent("ADDON_LOADED");
local function eventHandler(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            WayLite:Initialize()
        end
    elseif type(addon[event]) == "function" then
        addon[event](addon, ...)
    end
end
frame:SetScript("OnEvent", eventHandler);
WayLite.eventFrame = frame

function WayLite:Initialize()
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function WayLite:PLAYER_ENTERING_WORLD(...)
    self.CompatibilityMode = IsAddOnLoaded("TomTom") or IsAddOnLoaded("MapPinEnhanced")
    if not self.CompatibilityMode then
        SLASH_WAYLITE2 = "/way" -- enable /way handling
    end

    if not self.HasShownActivityMessage then
        self.HasShownActivityMessage = true
        if self.CompatibilityMode then
            self:PrintMsg("WayLite is in compatibility mode. " .. WLCOLOR_CMD .. "/way|r commands will defer to other addons. Use " .. WLCOLOR_CMD .. "/waylite|r instead.")
        else
            self:PrintMsg("WayLite active. Use " .. WLCOLOR_CMD .. "/way|r or " .. WLCOLOR_CMD .. "/waylite|r to add map pins.")
        end
    end
end

function WayLite:PrintMsg(msg)
    DEFAULT_CHAT_FRAME:AddMessage(string.format(WLCOLOR_TITLE .. "WayLite:|r %s", msg))
end

function WayLite:GetPinCmdHere()
    local mapID = C_Map.GetBestMapForUnit("player")
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    local cmdStr = string.format("/way %.2f, %.2f", pos.x*100, pos.y*100)
    self:PrintMsg(cmdStr)
    --local eb = DEFAULT_CHAT_FRAME.editBox
    --ChatEdit_ActivateChat(eb)
    --eb:Insert(cmdStr)
end

function WayLite:SetMapPin(x, y)
    local mapID = C_Map.GetBestMapForUnit("player")
    if not C_Map.CanSetUserWaypointOnMap(mapID) then
        WayLite:PrintMsg("Cannot set waypoints on this map")
        return
    end
    local mapPoint = UiMapPoint.CreateFromCoordinates(mapID, x, y, 0)
    C_Map.SetUserWaypoint(mapPoint)
    self:PrintMsg(string.format("Map pin set!"))
end

function WayLite:PrintHelp(errMsg)
    if errMsg then
        DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_TITLE .. "WayLite:|r " .. WLCOLOR_ERROR .. errMsg)
    end
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_TITLE .. "WayLite help:|r")
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_CMD .. "/way " .. WLCOLOR_OPTIONAL .. " [zone]|r x, y|r " .. WLCOLOR_OPTIONAL .. "[name]|r -- Add a waypoint to the map. Zone and name parameters are ignored for compatibility with TomTom /way commands")
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_CMD .. "/way here|r -- Get the " .. WLCOLOR_CMD .. "/way|r command for your current position.")
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_CMD .. "/way remove|r -- Remove the map pin.")
end

SLASH_WAYLITE1="/waylite"

-- Much of this comes straight from TomTom
local wrongseparator = "(%d)" .. (tonumber("1.1") and "," or ".") .. "(%d)"
local rightseparator =   "%1" .. (tonumber("1.1") and "." or ",") .. "%2"

SlashCmdList["WAYLITE"] = function(msg)
    -- Same parsing as TomTom (mostly)
    msg = msg:gsub("(%d)[%.,] (%d)", "%1 %2"):gsub(wrongseparator, rightseparator)
    local tokens = {}
    for token in msg:gmatch("%S+") do table.insert(tokens, token) end
    local ltoken = tokens[1] and tokens[1]:lower()

    if msg == "" or msg == nil or ltoken == "help" then
        WayLite:PrintHelp()
    elseif ltoken == "here" then
        WayLite:GetPinCmdHere()
    elseif ltoken == "remove" or ltoken == "clear" then
        C_Map.ClearUserWaypoint()
        WayLite:PrintMsg("Map pin removed.")
    elseif not tonumber(ltoken[1]) then
        -- Strip out the optional zone name
        local zoneEnd
        for idx = 1, #tokens do
            local token = tokens[idx]
            if tonumber(token) then
                zoneEnd = idx - 1
                break
            end
        end
        if not zoneEnd then
            WayLite:PrintHelp()
            return
        end
        local x,y = select(zoneEnd + 1, unpack(tokens))
        x = x and tonumber(x)
        y = y and tonumber(y)
        if not x or not y then
            WayLite:PrintHelp("Invalid /way usage. See help below.")
            return
        end
        x, y = x / 100, y / 100
        WayLite:SetMapPin(x,y)
    elseif tonumber(ltoken[1]) then
        local x,y = unpack(tokens)
        x = x and tonumber(x)
        y = y and tonumber(y)
        if not x or not y then
            WayLite:PrintHelp("Invalid /way usage. See help below.")
            return
        end
        x, y = x / 100, y / 100
        WayLite:SetMapPin(x,y)
    else
        WayLite:PrintHelp("Invalid /way usage. See help below.")
    end
end