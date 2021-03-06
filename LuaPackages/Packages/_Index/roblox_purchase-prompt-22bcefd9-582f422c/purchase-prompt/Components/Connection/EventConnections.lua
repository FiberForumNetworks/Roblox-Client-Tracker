--[[
	Connects relevant Roblox engine events to the rodux store
]]
local FFlagIGPDepSwap = game:GetFastFlag("IGPDepSwap")
local Root = script.Parent.Parent.Parent
local LuaPackages = FFlagIGPDepSwap and Root.Parent or game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")

local Roact = require(LuaPackages.Roact)

local UpsellFlow = require(script.Parent.Parent.Parent.UpsellFlow)

local MarketplaceServiceEventConnector = require(script.Parent.MarketplaceServiceEventConnector)
local InputTypeManager = require(script.Parent.InputTypeManager)

local BrowserPurchaseFinishedConnector = require(script.Parent.BrowserPurchaseFinishedConnector)
local NativePurchaseFinishedConnector = require(script.Parent.NativePurchaseFinishedConnector)
local PlayerConnector = require(script.Parent.PlayerConnector)

local getUpsellFlow = require(script.Parent.Parent.Parent.NativeUpsell.getUpsellFlow)

local function EventConnections()
	local upsellConnector
	local upsellFlow = getUpsellFlow(UserInputService:GetPlatform())
	if upsellFlow == UpsellFlow.Web then
		upsellConnector = Roact.createElement(BrowserPurchaseFinishedConnector)
	elseif upsellFlow == UpsellFlow.Mobile then
		upsellConnector = Roact.createElement(NativePurchaseFinishedConnector)
	end

	return Roact.createElement("Folder", {}, {
		MarketPlaceServiceEventConnector = Roact.createElement(MarketplaceServiceEventConnector),
		InputTypeManager = Roact.createElement(InputTypeManager),
		UpsellFinishedConnector = upsellConnector,
		PlayerConnector = game:GetFastFlag("EnableRobuxABTest") and Roact.createElement(PlayerConnector) or nil,
	})
end

return EventConnections