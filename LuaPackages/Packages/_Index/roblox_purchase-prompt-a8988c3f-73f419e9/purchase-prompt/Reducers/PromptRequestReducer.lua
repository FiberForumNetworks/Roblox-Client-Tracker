local Root = script.Parent.Parent
local LuaPackages = Root.Parent

local Rodux = require(LuaPackages.Rodux)

local RequestAssetPurchase = require(Root.Actions.RequestAssetPurchase)
local RequestBundlePurchase = require(Root.Actions.RequestBundlePurchase)
local RequestGamepassPurchase = require(Root.Actions.RequestGamepassPurchase)
local RequestProductPurchase = require(Root.Actions.RequestProductPurchase)
local RequestPremiumPurchase = require(Root.Actions.RequestPremiumPurchase)
local CompleteRequest = require(Root.Actions.CompleteRequest)
local RequestType = require(Root.Enums.RequestType)

local EMPTY_STATE = { requestType = RequestType.None }

local RequestReducer = Rodux.createReducer(EMPTY_STATE, {
	[RequestAssetPurchase.name] = function(state, action)
		return {
			id = action.id,
			infoType = Enum.InfoType.Asset,
			requestType = RequestType.Asset,
			equipIfPurchased = action.equipIfPurchased,
		}
	end,
	[RequestGamepassPurchase.name] = function(state, action)
		return {
			id = action.id,
			infoType = Enum.InfoType.GamePass,
			requestType = RequestType.GamePass,
		}
	end,
	[RequestProductPurchase.name] = function(state, action)
		return {
			id = action.id,
			infoType = Enum.InfoType.Product,
			requestType = RequestType.Product,
		}
	end,
	[RequestBundlePurchase.name] = function(state, action)
		return {
			id = action.id,
			infoType = Enum.InfoType.Bundle,
			requestType = RequestType.Bundle,
		}
	end,
	[RequestPremiumPurchase.name] = function(state, action)
		return {
			requestType = RequestType.Premium,
		}
	end,
	[CompleteRequest.name] = function(state, action)
		-- Clear product info when we hide the prompt
		return EMPTY_STATE
	end,
})

return RequestReducer