return function()
	local Players = game:GetService("Players")
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)

	local Components = script.Parent.Parent
	local Connection = Components.Connection
	local LayoutValues = require(Connection.LayoutValues)
	local LayoutValuesProvider = LayoutValues.Provider

	local PlayerList = Components.Parent
	local CreateLayoutValues = require(PlayerList.CreateLayoutValues)

	local PlayerNameTag = require(script.Parent.PlayerNameTag)

	local FFlagPlayerListDesignUpdate = settings():GetFFlag("PlayerListDesignUpdate")

	if FFlagPlayerListDesignUpdate then
		it("should create and destroy without errors", function()
			local layoutValues = CreateLayoutValues(false, false)

			local element = Roact.createElement(LayoutValuesProvider, {
				layoutValues = layoutValues
			}, {
				PlayerNameTag = Roact.createElement(PlayerNameTag, {
					player = Players.LocalPlayer,
					isTitleEntry = false,
					isHovered = false,
					layoutOrder = 2,

					textStyle = {
						Color = Color3.new(1, 1, 1),
						Transparency = 1,
					},
					textFont = {
						Size = 20,
						Font = Enum.Font.Gotham,
					},
				})
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should create and destroy without errors tenfoot", function()
			local layoutValues = CreateLayoutValues(true, false)

			local element = Roact.createElement(LayoutValuesProvider, {
				layoutValues = layoutValues
			}, {
				PlayerNameTag = Roact.createElement(PlayerNameTag, {
					player = Players.LocalPlayer,
					isTitleEntry = true,
					isHovered = true,
					layoutOrder = 1,

					textStyle = layoutValues.DefaultTextStyle,
					textFont = {
						Size = 32,
						Font = Enum.Font.Gotham,
					},
				})
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	else
		it("should create and destroy without errors", function()
			local layoutValues = CreateLayoutValues(false, false)

			local element = Roact.createElement(LayoutValuesProvider, {
				layoutValues = layoutValues
			}, {
				PlayerNameTag = Roact.createElement(PlayerNameTag, {
					player = Players.LocalPlayer,
					isTitleEntry = false,
					isHovered = false,
					layoutOrder = 2,

					textStyle = layoutValues.TextStyle.Default,
				})
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should create and destroy without errors tenfoot", function()
			local layoutValues = CreateLayoutValues(true, false)

			local element = Roact.createElement(LayoutValuesProvider, {
				layoutValues = layoutValues
			}, {
				PlayerNameTag = Roact.createElement(PlayerNameTag, {
					player = Players.LocalPlayer,
					isTitleEntry = true,
					isHovered = true,
					layoutOrder = 1,

					textStyle = layoutValues.TextStyle.Default,
				})
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end
end