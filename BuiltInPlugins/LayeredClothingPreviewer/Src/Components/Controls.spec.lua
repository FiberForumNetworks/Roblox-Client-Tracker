return function()
    local Plugin = script.Parent.Parent.Parent
    local Roact = require(Plugin.Packages.Roact)
    local MockServiceWrapper = require(Plugin.Src.TestHelpers.MockServiceWrapper)

    local Controls = require(script.Parent.Controls)

    it("should create and destroy without errors", function()
        local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
            Controls = Roact.createElement(Controls, {}),
        })
        local instance = Roact.mount(mockServiceWrapper)
        Roact.unmount(instance)
    end)
end