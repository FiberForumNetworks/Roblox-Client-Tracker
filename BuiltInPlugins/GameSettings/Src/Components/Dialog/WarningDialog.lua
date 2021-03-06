--[[
	A dialog that displays a warning image and message.
	Used with the showDialog function.

	Props:
		string Header = The header text to display at the top of this Dialog.
		string Description = The main message to display in this Dialog.
		table Buttons = {string cancelButtonName, string confirmButtonName}
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local Constants = require(Plugin.Src.Util.Constants)

local BaseDialog = require(Plugin.Src.Components.Dialog.BaseDialog)

local function WarningDialog(props)
	return withTheme(function(theme)
		local buttons = props.Buttons
		local header = props.Header
		local description = props.Description

		return Roact.createElement(BaseDialog, {
			Buttons = buttons,
			OnResult = props.OnResult,
		}, {
			Header = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Title, {
				Size = UDim2.new(1, -60, 0, 23),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 30),
				BackgroundTransparency = 1,
				Text = header,
				TextXAlignment = Enum.TextXAlignment.Left,
			})),

			Description = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Warning, {
				Size = UDim2.new(0, 387, 0, 40),
				Position = UDim2.new(0, 56, 0, 65),
				BackgroundTransparency = 1,
				Text = description,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
			})),

			Warning = Roact.createElement("ImageLabel", {
				Image = Constants.WARNING_IMAGE,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 30, 0, 68),
			}),
		})
	end)
end

return WarningDialog