return function()
    local Plugin = script.Parent.Parent.Parent
    local Roact = require(Plugin.Packages.Roact)
    local MockServiceWrapper = require(Plugin.Src.TestHelpers.MockServiceWrapper)

    local MainView = require(script.Parent.MainView)

    it("should create and destroy without errors", function()
        local mockServiceWrapper = Roact.createElement(MockServiceWrapper, {}, {
            MainView = Roact.createElement(MainView, {}),
        })
        local instance = Roact.mount(mockServiceWrapper)
        Roact.unmount(instance)
    end)
end