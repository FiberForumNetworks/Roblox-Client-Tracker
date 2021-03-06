return function()
	local FFlagIGPDepSwap = game:GetFastFlag("IGPDepSwap")
	local Root = script.Parent.Parent.Parent
	local LuaPackages = FFlagIGPDepSwap and Root.Parent or game:GetService("CorePackages")
	local Roact = require(LuaPackages.Roact)
	local Rodux = require(LuaPackages.Rodux)

	local Reducer = require(script.Parent.Parent.Parent.Reducers.Reducer)

	local PromptState = require(script.Parent.Parent.Parent.PromptState)

	local UnitTestContainer = require(script.Parent.Parent.Parent.Test.UnitTestContainer)

	local PromptContents = require(script.Parent.PromptContents)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(UnitTestContainer, {
			promptState = PromptState.PromptPurchase,
			overrideStore = Rodux.Store.new(Reducer, {
				promptState = PromptState.PromptPurchase,
				accountInfo = {
					balance = 100,
				},
				productInfo = {
					assetTypeId = 2, -- T-shirt
					price = 10,
					itemType = 2,
				},
			})
		}, {
			Roact.createElement(PromptContents, {
				layoutOrder = 1,
				onClose = function()
				end,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end