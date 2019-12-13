return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)
	local MockServiceWrapper = require(Plugin.Src.TestHelpers.MockServiceWrapper)

	local Slider = require(script.Parent.Slider)

	it("should create and destroy without errors for single caret slider", function()
		local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
			Slider = Roact.createElement(Slider, {
				LayoutOrder = 1,
				Title = "text",
				Enabled = true,

				Min = 0,
				Max = 100,
				SnapIncrement = 1,
				LowerRangeValue = 0,

				MinLabelText = "0%",
				MaxLabelText = "100%",
				UnitsLabelText = "%",

				SetValues = function()
				end,
			}),
		})

		local instance = Roact.mount(mockServiceWrapper)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors for two caret slider", function()
		local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
			Slider = Roact.createElement(Slider, {
				LayoutOrder = 1,
				Title = "text",
				Enabled = true,

				Min = 0,
				Max = 100,
				SnapIncrement = 1,
				LowerRangeValue = 0,
				UpperRangeValue = 100,

				MinLabelText = "0%",
				MaxLabelText = "100%",
				UnitsLabelText = "%",

				SetValues = function()
				end,
			}),
		})

		local instance = Roact.mount(mockServiceWrapper)
		Roact.unmount(instance)
	end)
end