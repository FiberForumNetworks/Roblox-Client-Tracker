--[[
	The frame containing an input control for an asset

	Props:
		Title string
		LayoutOrder number
		AssetId number
		Height number
		IsOn bool

		setAsset(assetId) function
		onToggle(isOn) function
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local UILibrary = require(Plugin.Packages.UILibrary)
local LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator
local RoundTextBox = UILibrary.Component.RoundTextBox

local withTheme = require(Plugin.Src.ContextServices.Theming).withTheme

local ToggledTitledFrame = require(Plugin.Src.Components.ToggledTitledFrame)

local AssetControl = Roact.PureComponent:extend("AssetControl")

local TEXT_BOX_X_SIZE = 262

local function validateId(text)
	text = tostring(text)
	return text:match("%d+") == text
end

function AssetControl:render()
	return withTheme(function(theme)
		local state = self.state
		local assetIdText = state.assetIdText

		local props = self.props
		local assetId = props.AssetId
		local layoutOrder = props.LayoutOrder
		local height = props.Height
		local title = props.Title
		local isOn = props.IsOn
		local onToggle = props.onToggle

		local assetText = tostring(assetIdText or assetId or "")

		local orderIterator = LayoutOrderIterator.new()

		return Roact.createElement(ToggledTitledFrame, {
			Title = title,
			Height = height,
			LayoutOrder = layoutOrder,
			IsOn = isOn,

			onToggle = onToggle,
		}, {
			RoundTextBox = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, TEXT_BOX_X_SIZE, 0, height),
				LayoutOrder = orderIterator:getNextOrder(),
			}, {
				RoundTextBox = Roact.createElement(RoundTextBox, {
					Text = assetText,
					Active = isOn,
					Multiline = false,
					MaxLength = 1000,
					ShowToolTip = false,
					ErrorBorder = not validateId(assetText),
					Height = height,
					TextSize = theme.Text.LargeSize,

					SetText = function(text)
						self:setState({
							assetIdText = text
						})
					end,

					FocusChanged = function(hasFocus)
						if not hasFocus then
							local id = validateId(assetText) and tonumber(assetText) or nil
							if id then
								self.props.setAsset(id)
							else
								self.props.setAsset(0)
							end
						end
					end
				})
			})
		})
	end)
end

return AssetControl