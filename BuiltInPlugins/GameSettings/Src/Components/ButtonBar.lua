--[[
	A horizontal collection of RoundTextButtons.

	Props:
		Enum.HorizontalAlignment HorizontalAlignment = The alignment of the button bar.
			Determines if buttons should be centered or aligned to one corner.
		table Buttons = The buttons to add to this button bar.
]]


local BUTTON_BAR_PADDING = 25
local BUTTON_BAR_EDGE_PADDING = 35

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local getMouse = require(Plugin.Src.Consumers.getMouse)

local RoundTextButton = require(Plugin.UILibrary.Components.RoundTextButton)

local function ButtonBar(props)
	return withTheme(function(theme)
		local horizontalAlignment = props.HorizontalAlignment
		local buttons = props.Buttons

		local components = {
			Layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, BUTTON_BAR_PADDING),
				HorizontalAlignment = horizontalAlignment,
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			})
		}

		if horizontalAlignment ~= Enum.HorizontalAlignment.Center then
			table.insert(components, Roact.createElement("UIPadding", {
				PaddingRight = UDim.new(0, BUTTON_BAR_EDGE_PADDING),
			}))
		end

		for i, button in ipairs(buttons) do
			table.insert(components, Roact.createElement(RoundTextButton, Cryo.Dictionary.join(theme.fontStyle.Normal, {
				LayoutOrder = i,
				Style = button.Default and theme.defaultButton or theme.cancelButton,
				BorderMatchesBackground = button.Default and not theme.isDarkerTheme,
				Size = UDim2.new(0, Constants.BUTTON_WIDTH, 1, 0),
				Active = button.Active,
				Name = button.Name,
				Value = button.Value,
				ZIndex = props.ZIndex or 1,

				OnClicked = function(value)
					props.ButtonClicked(value)
				end,
			})))
		end

		return Roact.createElement("Frame", {
			LayoutOrder = props.LayoutOrder or 1,
			Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
			AnchorPoint = props.AnchorPoint or Vector2.new(0, 0.5),
			Position = props.Position or UDim2.new(0, 0, 0.5, 0),
			BackgroundTransparency = 1,
		}, components)
	end)
end

return ButtonBar