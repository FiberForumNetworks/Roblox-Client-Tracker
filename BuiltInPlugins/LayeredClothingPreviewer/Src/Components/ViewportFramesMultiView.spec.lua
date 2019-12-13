return function()
    local Plugin = script.Parent.Parent.Parent
    local Roact = require(Plugin.Packages.Roact)
    local MockServiceWrapper = require(Plugin.Src.TestHelpers.MockServiceWrapper)

    local ViewportFramesMultiView = require(script.Parent.ViewportFramesMultiView)

    it("should create and destroy without errors", function()
        local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
            ViewportFramesMultiView = Roact.createElement(ViewportFramesMultiView, {}),
        })
        local instance = Roact.mount(mockServiceWrapper)
        Roact.unmount(instance)
    end)
end