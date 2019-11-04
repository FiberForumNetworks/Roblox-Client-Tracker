return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local PluginButton = require(script.Parent.PluginButton)

	local function mockToolbar()
		local toolbar = {
			CreateButton = function()
				return {
					Click = {
						Connect = function()
						end,
					},
					SetActive = function()
					end,
					Destroy = function()
					end,
				}
			end,
		}

		return toolbar
	end

	it("should create and destroy without errors", function()
		local element = Roact.createElement(PluginButton, {
			Toolbar = mockToolbar(),
			Title = "Test",
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should expect a Title prop", function()
		local element = Roact.createElement(PluginButton, {
			Toolbar = mockToolbar(),
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect a Toolbar prop", function()
		local element = Roact.createElement(PluginButton, {
			Title = "Test",
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)
end