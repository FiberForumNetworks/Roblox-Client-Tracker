return function()
    local Plugin = script.Parent.Parent.Parent
    local Roact = require(Plugin.Packages.Roact)
    local MockServiceWrapper = require(Plugin.Src.TestHelpers.MockServiceWrapper)

    local AssetControl = require(script.Parent.AssetControl)

    it("should create and destroy without errors", function()
        local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
            AssetControl = Roact.createElement(AssetControl, {}),
        })
        local instance = Roact.mount(mockServiceWrapper)
        Roact.unmount(instance)
    end)
end