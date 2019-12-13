local Plugin = script.Parent.Parent.Parent
local Packages = Plugin.Packages

local HumanoidDescription = require(script.Parent.HumanoidDescription)
local TestHelpers = require(Packages.TestHelpers)
local testImmutability = TestHelpers.testImmutability
local Rodux = require(Packages.Rodux)
local SetHumanoidDescriptionOverride = require(Plugin.Src.Actions.SetHumanoidDescriptionOverride)
local HumanoidDescriptionOverrideProps = require(Plugin.Src.Util.Constants.HumanoidDescriptionProps)

return function()
	it("should return its expected default state", function()
		local r = Rodux.Store.new(HumanoidDescription)
		expect(r:getState()).to.be.ok()
		expect(r:getState().overriddenProps).to.be.ok()
		expect(r:getState().propValues).to.be.ok()
	end)

	describe("SetHumanoidDescriptionOverride", function()
		it("should set the current hatId", function()
			local state =
				HumanoidDescription(nil, SetHumanoidDescriptionOverride(HumanoidDescriptionOverrideProps.HeightScale, true, 2))

			expect(state).to.be.ok()

			expect(state.overriddenProps).to.be.ok()
			expect(state.overriddenProps[HumanoidDescriptionOverrideProps.HeightScale]).to.equal(true)

			expect(state.propValues).to.be.ok()
			expect(state.propValues[HumanoidDescriptionOverrideProps.HeightScale]).to.equal(2)

		end)

		it("should assert if passed a nil hat", function()
			local success = pcall(function()
				return HumanoidDescription(nil, SetHumanoidDescriptionOverride(nil))
			end)

			expect(success).to.equal(false)
		end)

		it("should preserve immutability", function()
			local setOverride = SetHumanoidDescriptionOverride(HumanoidDescriptionOverrideProps.WidthScale, true, 3)
			local immutabilityPreserved = testImmutability(HumanoidDescription, setOverride)
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)
end