return function()
    local Plugin = script.Parent.Parent.Parent
    local Roact = require(Plugin.Packages.Roact)
    local MockServiceWrapper = require(Plugin.Src.TestHelpers.MockServiceWrapper)

    local ScaleControl = require(script.Parent.ScaleControl)

    it("should create and destroy without errors", function()
        local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
            ScaleControl = Roact.createElement(ScaleControl, {}),
        })
        local instance = Roact.mount(mockServiceWrapper)
        Roact.unmount(instance)
    end)
end