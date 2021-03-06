return function()
	local FFlagIGPDepSwap = game:GetFastFlag("IGPDepSwap")
	local Root = script.Parent.Parent
	local LuaPackages = FFlagIGPDepSwap and Root.Parent or game:GetService("CorePackages")
	local Rodux = require(LuaPackages.Rodux)

	local Reducer = require(script.Parent.Parent.Reducers.Reducer)

	local MockAnalytics = require(script.Parent.Parent.Test.MockAnalytics)
	local MockPlatformInterface = require(script.Parent.Parent.Test.MockPlatformInterface)

	local Analytics = require(script.Parent.Parent.Services.Analytics)
	local PlatformInterface = require(script.Parent.Parent.Services.PlatformInterface)

	local PromptState = require(script.Parent.Parent.PromptState)
	local Thunk = require(script.Parent.Parent.Thunk)

	local launchRobuxUpsell = require(script.Parent.launchRobuxUpsell)

	it("should run without errors", function()
		local store = Rodux.Store.new(Reducer)

		local thunk = launchRobuxUpsell()
		local analytics = MockAnalytics.new()
		local platformInterface = MockPlatformInterface.new()

		Thunk.test(thunk, store, {
			[Analytics] = analytics.mockService,
			[PlatformInterface] = platformInterface.mockService,
		})

		local state = store:getState()

		if not settings():GetFFlag("ChinaLicensingApp") then
			expect(analytics.spies.reportRobuxUpsellStarted.callCount).to.equal(1)
			expect(platformInterface.spies.startRobuxUpsellWeb.callCount).to.equal(1)
			expect(state.promptState).to.equal(PromptState.UpsellInProgress)
		end
	end)
end