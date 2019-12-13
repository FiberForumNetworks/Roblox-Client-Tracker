--[[
	The frame containing a titled frame and a toggle button

	Props:
		Title string
		LayoutOrder number
		Height number
		IsOn bool

		onToggle(isOn) function
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local UILibrary = require(Plugin.Packages.UILibrary)
local LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator

local ToggleButton = UILibrary.Component.ToggleButton
local TitledFrame = UILibrary.Component.TitledFrame

local withTheme = require(Plugin.Src.ContextServices.Theming).withTheme

local ToggledTitledFrame = Roact.PureComponent:extend("ToggledTitledFrame")

local PADDING = 20
local TOGGLE_BUTTON_WIDTH_OFFSET = 50
local TOGGLE_BUTTON_HEIGHT_OFFSET = 27

function ToggledTitledFrame:render()
	return withTheme(function(theme)
		local props = self.props
		local layoutOrder = props.LayoutOrder
		local height = props.Height
		local title = props.Title
		local isOn = props.IsOn
		local onToggle = props.onToggle

		local orderIterator = LayoutOrderIterator.new()

		return Roact.createElement(TitledFrame, {
			Title = title,
			MaxHeight = height,
			LayoutOrder = layoutOrder,
			TextSize = theme.Text.LargeSize,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, PADDING)
			}),

			ToggleButton = Roact.createElement(ToggleButton, {
				LayoutOrder = orderIterator:getNextOrder(),
				IsOn = isOn,
				Enabled = true,
				Size = UDim2.new(0, TOGGLE_BUTTON_WIDTH_OFFSET, 0, TOGGLE_BUTTON_HEIGHT_OFFSET),

				onToggle = onToggle,
			}),

			Content = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -(TOGGLE_BUTTON_WIDTH_OFFSET+PADDING), 1, 0),
				LayoutOrder = orderIterator:getNextOrder(),
			}, props[Roact.Children])
		})
	end)
end

return ToggledTitledFrame