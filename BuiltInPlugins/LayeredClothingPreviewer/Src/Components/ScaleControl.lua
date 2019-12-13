--[[
	The frame containing the controls

	Props:
		LayoutOrder number
		Active bool
		IsOn bool = whether the toggle is on
		Title string
		Min number = scale minimum for slider
		Max number = scale maximum for slider
		Increment number = increment for slider
		ScaleValue number caret value of slider
		Height number = height of this control

		onToggle(isOn) function = whether to use the value from this control
		setValue(value) function = gives the value of this control when it's changed
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local UILibrary = require(Plugin.Packages.UILibrary)
local LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator
local withLocalization = UILibrary.Localizing.withLocalization

local withTheme = require(Plugin.Src.ContextServices.Theming).withTheme

local Slider = require(Plugin.Src.Components.Slider)
local ToggledTitledFrame = require(Plugin.Src.Components.ToggledTitledFrame)

local ScaleControl = Roact.PureComponent:extend("ScaleControl")

function ScaleControl:render()
	return withTheme(function(theme)
		return withLocalization(function(localization)
			local props = self.props
			local active = props.Active
			local isOn = props.IsOn
			local title = props.Title
			local layoutOrder = props.LayoutOrder
			local min = props.Min or 0
			local max = props.Max or 100
			local increment = props.Increment or 5
			local scaleValue = props.ScaleValue
			local height = props.Height
			local onToggle = props.onToggle
			local setValue = props.setValue

			local orderIterator = LayoutOrderIterator.new()

			return Roact.createElement(ToggledTitledFrame, {
				Title = title,
				Height = height,
				LayoutOrder = layoutOrder,
				IsOn = isOn,

				onToggle = onToggle,
			}, {
				Slider = Roact.createElement(Slider, {
					LayoutOrder = orderIterator:getNextOrder(),
					Active = active and isOn,

					Min = min,
					Max = max,
					SnapIncrement = increment,
					LowerRangeValue = (active and isOn) and scaleValue or min,

					MinLabelText = localization:getText("Controls", "SliderLabel", tostring(min)),
					MaxLabelText = localization:getText("Controls", "SliderLabel", tostring(max)),
					UnitsLabelText = localization:getText("Controls", "Units"),

					SetValues = function(newValue)
						setValue(newValue)
					end,
				}),
			})
		end)
	end)
end

return ScaleControl