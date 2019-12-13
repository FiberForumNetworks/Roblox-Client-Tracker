return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)
	local MockServiceWrapper = require(Plugin.Src.TestHelpers.MockServiceWrapper)

	local ViewportFrameContainer = require(script.Parent.ViewportFrameContainer)

	it("should create and destroy without errors", function()
		local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
			ViewportFrameContainer = Roact.createElement(ViewportFrameContainer, {
				BundleId = 0,
				LayoutOrder = 0,

				registerViewport = function()
				end
			}),
		})
		local instance = Roact.mount(mockServiceWrapper)
		Roact.unmount(instance)
	end)
end