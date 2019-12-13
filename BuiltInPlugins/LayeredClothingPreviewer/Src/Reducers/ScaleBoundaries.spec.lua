local Plugin = script.Parent.Parent.Parent
local Packages = Plugin.Packages

local ScaleBoundaries = require(script.Parent.ScaleBoundaries)
local TestHelpers = require(Packages.TestHelpers)
local testImmutability = TestHelpers.testImmutability
local Rodux = require(Packages.Rodux)
local SetScaleBoundaries = require(Plugin.Src.Actions.SetScaleBoundaries)

return function()
	it("should return its expected default state", function()
		local r = Rodux.Store.new(ScaleBoundaries)
		expect(r:getState()).to.be.ok()
		expect(r:getState().scaleBoundaries).to.equal(nil)
	end)

	local scaleBoundariesTestData = {
		height = {min=0.9, max=1.05, increment=0.05},
		width = {min=0.7, max=1, increment=0.05},
		head = {min=0.95, max=1, increment=0.05},
		bodyType = {min=0, max=0.3, increment=0.05},
		proportion = {min=0, max=1, increment=0.05},
	}

	describe("SetScaleBoundaries", function()
		it("should set the current scale boundaries", function()
			local state = ScaleBoundaries(nil, SetScaleBoundaries(scaleBoundariesTestData))

			expect(state).to.be.ok()
			expect(state.scaleBoundaries).to.be.ok()
			expect(state.scaleBoundaries).to.equal(scaleBoundariesTestData)
		end)

		it("should assert if passed nil", function()
			local success = pcall(function()
				return ScaleBoundaries(nil, SetScaleBoundaries(nil))
			end)

			expect(success).to.equal(false)
		end)

		it("should preserve immutability", function()
			local immutabilityPreserved = testImmutability(ScaleBoundaries, SetScaleBoundaries(scaleBoundariesTestData))
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)
end