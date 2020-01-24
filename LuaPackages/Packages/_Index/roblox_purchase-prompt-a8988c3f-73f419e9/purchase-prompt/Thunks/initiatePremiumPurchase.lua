local Root = script.Parent.Parent

local Promise = require(Root.Promise)
local Thunk = require(Root.Thunk)
local PurchaseError = require(Root.Enums.PurchaseError)

local RequestPremiumPurchase = require(Root.Actions.RequestPremiumPurchase)
local ErrorOccurred = require(Root.Actions.ErrorOccurred)
local getPremiumProductInfo = require(Root.Network.getPremiumProductInfo)
local getAccountInfo = require(Root.Network.getAccountInfo)
local Network = require(Root.Services.Network)
local ExternalSettings = require(Root.Services.ExternalSettings)
local resolvePremiumPromptState = require(Root.Thunks.resolvePremiumPromptState)
local hasPendingRequest = require(Root.Utils.hasPendingRequest)

local requiredServices = {
	Network,
	ExternalSettings,
}

local function initiatePremiumPurchase(id, infoType, equipIfPurchased)
	return Thunk.new(script.Name, requiredServices, function(store, services)
		local network = services[Network]
		local externalSettings = services[ExternalSettings]

		if hasPendingRequest(store:getState()) then
			return nil
		end
		store:dispatch(RequestPremiumPurchase())

		if externalSettings.getFlagOrder66() then
			store:dispatch(ErrorOccurred(PurchaseError.PurchaseDisabled))
			return nil
		end

		return Promise.all({
			premiumProductInfo = getPremiumProductInfo(network),
			accountInfo = getAccountInfo(network, externalSettings),
		})
			:andThen(function(results)
				store:dispatch(resolvePremiumPromptState(results.accountInfo, results.premiumProductInfo))
			end)
			:catch(function(errorReason)
				warn(errorReason)
				store:dispatch(ErrorOccurred(errorReason))
			end)
	end)
end

return initiatePremiumPurchase