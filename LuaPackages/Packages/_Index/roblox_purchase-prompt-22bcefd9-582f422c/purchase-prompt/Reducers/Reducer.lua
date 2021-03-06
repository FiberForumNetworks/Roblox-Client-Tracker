--[[
	The main reducer for the app's store
]]
local FFlagIGPDepSwap = game:GetFastFlag("IGPDepSwap")
local Root = script.Parent.Parent
local LuaPackages = FFlagIGPDepSwap and Root.Parent or game:GetService("CorePackages")
local Rodux = require(LuaPackages.Rodux)

local ProductReducer = require(script.Parent.ProductReducer)
local ProductInfoReducer = require(script.Parent.ProductInfoReducer)
local NativeUpsellReducer = require(script.Parent.NativeUpsellReducer)
local PromptStateReducer = require(script.Parent.PromptStateReducer)
local PurchaseErrorReducer = require(script.Parent.PurchaseErrorReducer)
local AccountInfoReducer = require(script.Parent.AccountInfoReducer)
local PurchasingStartTimeReducer = require(script.Parent.PurchasingStartTimeReducer)
local GamepadEnabledReducer = require(script.Parent.GamepadEnabledReducer)
local ABVariationReducer = require(script.Parent.ABVariationReducer)

local Reducer = Rodux.combineReducers({
	product = ProductReducer,
	productInfo = ProductInfoReducer,
	nativeUpsell = NativeUpsellReducer,
	promptState = PromptStateReducer,
	purchaseError = PurchaseErrorReducer,
	accountInfo = AccountInfoReducer,
	purchasingStartTime = PurchasingStartTimeReducer,
	gamepadEnabled = GamepadEnabledReducer,
	abVariations = ABVariationReducer,
})

return Reducer