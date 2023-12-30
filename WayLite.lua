--[[
    WayLite by FiveStar
    (C) 2022
]]

local WLCOLOR_TITLE = "|cFFE6A009"
local WLCOLOR_ERROR = "|cFFFF3333"
local WLCOLOR_WARN = "|cFFFF3333"
local WLCOLOR_CMD = "|cFF00CCFF"
local WLCOLOR_OPTIONAL = "|cFFCCCCCC"

local WLTEXT_INVALID_USAGE = "Invalid " .. WLCOLOR_CMD .. "/way|r usage. See help below."

local OptionsDefaults = {
    QuietMode = false
}

local addonName, addon = ...
local WayLite = addon
WayLite.name = addonName
_G[addonName] = addon

local frame = CreateFrame("Frame", addonName .. "EventFrame")
WayLite.eventFrame = frame
frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", function(this, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            WayLite:Initialize()
            WayLite:UnregisterEvent("ADDON_LOADED")
        end
    elseif type(WayLite[event]) == "function" then
        WayLite[event](WayLite, ...)
    else
        DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_ERROR .. "WayLite unhandled event:|r " .. event)
    end
end)

function WayLite:PrintMsg(msg)
    DEFAULT_CHAT_FRAME:AddMessage(string.format(WLCOLOR_TITLE .. "WayLite:|r %s", msg))
end

function WayLite:PrintMsgC(color, msg)
    DEFAULT_CHAT_FRAME:AddMessage(string.format(WLCOLOR_TITLE .. "WayLite:|r " .. color .. "%s", msg))
end

function WayLite:RegisterEvent(event)
    if type(WayLite[event]) == "function" then
        self.eventFrame:RegisterEvent(event)
    else
        WayLite:PrintMsg(WLCOLOR_ERROR .. "Invalid event registration:|r " .. event)
    end
end

function WayLite:UnregisterEvent(event)
    self.eventFrame:UnregisterEvent(event)
end

function WayLite:PLAYER_LOGOUT(...)
    WayLiteDB = self.DB
end

function WayLite:PLAYER_ENTERING_WORLD(...)
    self.CompatibilityMode = IsAddOnLoaded("TomTom") or IsAddOnLoaded("MapPinEnhanced")
    if not self.CompatibilityMode then
        SLASH_WAYLITE2 = "/way" -- enable /way handling
    end

    if not self.DB.QuietMode and not self.HasShownActivityMessage then
        self.HasShownActivityMessage = true
        if self.CompatibilityMode then
            self:PrintMsg("WayLite is in compatibility mode. " .. WLCOLOR_CMD .. "/way|r commands will defer to other addons. Use " .. WLCOLOR_CMD .. "/waylite|r instead.")
        else
            self:PrintMsg("Use " .. WLCOLOR_CMD .. "/way|r or " .. WLCOLOR_CMD .. "/waylite|r to add map pins. Please report issues on github.")
        end
    end
end

function WayLite:GetPinCmdHere()
    local mapID = C_Map.GetBestMapForUnit("player")
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    local cmdStr = string.format("/way #%d %.2f, %.2f", mapID, pos.x*100, pos.y*100)
    return cmdStr
end

function WayLite:SetMapPin(x, y, zoneID)
    local mapID = zoneID or C_Map.GetBestMapForUnit("player")
    if not C_Map.CanSetUserWaypointOnMap(mapID) then
        WayLite:PrintMsgC(WLCOLOR_ERROR, "Cannot set waypoints on this map")
        return
    end
    local mapPoint = UiMapPoint.CreateFromCoordinates(mapID, x, y, 0)
    C_Map.SetUserWaypoint(mapPoint)
    self:PrintMsg("Map pin set!")
end

function WayLite:PrintHelp(errMsg)
    if errMsg then
        DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_TITLE .. "WayLite:|r " .. WLCOLOR_ERROR .. errMsg)
    else
        DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_TITLE .. "WayLite help:")
    end
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_CMD .. "/way " .. WLCOLOR_OPTIONAL .. " [zone]|r x, y|r " .. WLCOLOR_OPTIONAL .. "[name]|r -- Add a waypoint to the map. Zone and name parameters are ignored for compatibility with TomTom /way commands")
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_CMD .. "/way here|r -- Get the " .. WLCOLOR_CMD .. "/way|r command for your current position for sharing.")
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_CMD .. "/way options|r -- Show options")
    DEFAULT_CHAT_FRAME:AddMessage(WLCOLOR_CMD .. "/way remove|r -- Remove the map pin.")
end

function WayLite:InitializeOptions()
    local options = CreateFrame("Frame")
    options.name = self.name
    self.OptionsFrame = options

    local quietModeCB = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
    quietModeCB:SetPoint("TOPLEFT", 20, -20)
    quietModeCB.Text:SetText("Be quiet! (don't print the welcome message at startup)")
    quietModeCB:SetChecked(self.DB.QuietMode)
    quietModeCB:HookScript("OnClick", function(_, btn, down)
        self.DB.QuietMode = quietModeCB:GetChecked()
    end)

    InterfaceOptions_AddCategory(options)
end

function WayLite:Initialize()
    if not WayLiteDB then
        WayLiteDB = OptionsDefaults
    end
    self.DB = WayLiteDB

    self.CompatibilityMode = false -- disable /way command if another addon handles it
    self.HasShownActivityMessage = false

    self:InitializeOptions()

    self:RegisterEvent("PLAYER_LOGOUT")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
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
        WayLite:PrintMsg(WayLite:GetPinCmdHere())
    elseif ltoken == "remove" or ltoken == "clear" then
        C_Map.ClearUserWaypoint()
        WayLite:PrintMsg("Map pin removed.")
    elseif ltoken == "options" then
	    InterfaceOptionsFrame_OpenToCategory(WayLite.OptionsFrame)
    elseif not tonumber(string.sub(ltoken, 1,1)) then
        -- Strip out the optional zone name
        local zoneID
        local zoneEnd
        if string.sub(ltoken, 1, 1) == "#" and string.len(ltoken) > 1 then
            local parsedZoneID = tonumber(string.sub(ltoken, 2))
            WayLite:PrintMsg("Zone ID detected " .. WLCOLOR_CMD .. parsedZoneID)
            if not parsedZoneID then
                WayLite:PrintHelp(WLTEXT_INVALID_USAGE)
                return
            end
            zoneID = parsedZoneID
        else
            WayLite:PrintMsg("WayLite ignores zone names. To use a waypoint from another zone, use the map ID like so;")
            WayLite:PrintMsg(WLCOLOR_CMD .. WayLite:GetPinCmdHere())
        end

        -- Strip zone name or ID
        for idx = 1, #tokens do
            local token = tokens[idx]
            if tonumber(token) then
                zoneEnd = idx - 1
                break
            end
        end

        if not zoneEnd then
            WayLite:PrintHelp(WLTEXT_INVALID_USAGE)
            return
        end

        local x,y = select(zoneEnd + 1, unpack(tokens))
        x = x and tonumber(x)
        y = y and tonumber(y)
        if not x or not y then
            WayLite:PrintHelp(WLTEXT_INVALID_USAGE)
            return
        end
        x, y = x / 100, y / 100
        WayLite:SetMapPin(x,y,zoneID)
    elseif tonumber(string.sub(ltoken, 1, 1)) then
        local x,y = unpack(tokens)
        x = x and tonumber(x)
        y = y and tonumber(y)
        if not x or not y then
            WayLite:PrintHelp(WLTEXT_INVALID_USAGE)
            return
        end
        x, y = x / 100, y / 100
        WayLite:SetMapPin(x,y)
    else
        WayLite:PrintHelp(WLTEXT_INVALID_USAGE)
    end
end