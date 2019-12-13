--[[
	The frame containing the controls

	Props:
		LayoutOrder number
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local UILibrary = require(Plugin.Packages.UILibrary)
local LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator
local withLocalization = UILibrary.Localizing.withLocalization

local AssetControl = require(Plugin.Src.Components.AssetControl)
local ScaleControl = require(Plugin.Src.Components.ScaleControl)

local HumanoidDescriptionProps = require(Plugin.Src.Util.Constants.HumanoidDescriptionProps)
local SetHumanoidDescriptionOverride = require(Plugin.Src.Actions.SetHumanoidDescriptionOverride)

local GetScaleBoundaries = require(Plugin.Src.Thunks.GetScaleBoundaries)

local ROW_HEIGHT = 38

local Controls = Roact.PureComponent:extend("Controls")

function Controls:init()
	self.baseFrameRef = Roact.createRef()
end

function Controls:createScaleControl(order, boundary, title, descriptionProp)
	local props = self.props
	local setHumanoidDescriptionOverride = props.setHumanoidDescriptionOverride

	local descriptionPropValues = props.descriptionPropValues
	local value = descriptionPropValues[descriptionProp]

	local descriptionOverriddenProps = props.descriptionOverriddenProps
	local isOn = descriptionOverriddenProps[descriptionProp] and true or false

	local function toIntegerPercentage(val)
		local percentage = val * 100
		local shouldRoundUp = (percentage - math.floor(percentage)) >= 0.5
		return shouldRoundUp and math.ceil(percentage) or math.floor(percentage)
	end

	return Roact.createElement(ScaleControl, {
		LayoutOrder = order,
		Active = boundary ~= nil,
		IsOn = isOn,
		Title = title,
		Min = (boundary and boundary.min) and toIntegerPercentage(boundary.min) or nil,
		Max = (boundary and boundary.max) and toIntegerPercentage(boundary.max) or nil,
		Increment = (boundary and boundary.increment) and toIntegerPercentage(boundary.increment) or nil,
		ScaleValue = value and toIntegerPercentage(value),
		Height = ROW_HEIGHT,
		onToggle = function(toggledOn)
			if boundary ~= nil then
				setHumanoidDescriptionOverride(descriptionProp, toggledOn, toggledOn and value or boundary.min)
			end
		end,
		setValue = function(newValue)
			local function toBoundary(value)
				value = value / 100
				if boundary.increment > 0.001 then
					local prevSnap = math.max(boundary.increment*math.floor(value/boundary.increment), boundary.min)
					local nextSnap = math.min(prevSnap+boundary.increment, boundary.max)
					return math.abs(prevSnap-value) < math.abs(nextSnap-value) and prevSnap or nextSnap
				end
				return math.min(boundary.max, math.max(boundary.min, value))
			end
			setHumanoidDescriptionOverride(descriptionProp, true, toBoundary(newValue))
		end,
	})
end

function Controls:render()
	return withLocalization(function(localization)
		local props = self.props
		local layoutOrder = props.LayoutOrder

		local descriptionPropValues = props.descriptionPropValues
		local hatAccessory = descriptionPropValues[HumanoidDescriptionProps.HatAccessory]

		local descriptionOverriddenProps = props.descriptionOverriddenProps
		local hatAccessoryOverridden = descriptionOverriddenProps[HumanoidDescriptionProps.HatAccessory]

		local scaleBoundaries = props.ScaleBoundaries
		local setHumanoidDescriptionOverride = props.setHumanoidDescriptionOverride

		local orderIterator = LayoutOrderIterator.new()

		return Roact.createElement("Frame", {
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,

			[Roact.Ref] = self.baseFrameRef,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,

				[Roact.Change.AbsoluteContentSize] = function(rbx)
					self.baseFrameRef.current.Size = UDim2.new(1, 0, 0, rbx.AbsoluteContentSize.y)
				end,
			}),

			HatControl = Roact.createElement(AssetControl, {
				LayoutOrder = orderIterator:getNextOrder(),
				Title = localization:getText("Controls", "Hat"),
				AssetId = hatAccessory,
				Height = ROW_HEIGHT,
				IsOn = hatAccessoryOverridden,

				setAsset = function(assetId)
					setHumanoidDescriptionOverride(HumanoidDescriptionProps.HatAccessory, true, assetId)
				end,

				onToggle = function(isOn)
					setHumanoidDescriptionOverride(HumanoidDescriptionProps.HatAccessory, isOn, isOn and (hatAccessory or 0) or nil)
				end
			}),

			HeightControl = self:createScaleControl(
				orderIterator:getNextOrder(),
				scaleBoundaries and scaleBoundaries.height or nil,
				localization:getText("Controls", "Height"),
				HumanoidDescriptionProps.HeightScale
			),

			WidthControl = self:createScaleControl(
				orderIterator:getNextOrder(),
				scaleBoundaries and scaleBoundaries.width or nil,
				localization:getText("Controls", "Width"),
				HumanoidDescriptionProps.WidthScale
			),

			HeadControl = self:createScaleControl(
				orderIterator:getNextOrder(),
				scaleBoundaries and scaleBoundaries.head or nil,
				localization:getText("Controls", "Head"),
				HumanoidDescriptionProps.HeadScale
			),

			ProportionControl = self:createScaleControl(
				orderIterator:getNextOrder(),
				scaleBoundaries and scaleBoundaries.proportion or nil,
				localization:getText("Controls", "Proportions"),
				HumanoidDescriptionProps.ProportionScale
			),

			BodyTypeControl = self:createScaleControl(
				orderIterator:getNextOrder(),
				scaleBoundaries and scaleBoundaries.bodyType or nil,
				localization:getText("Controls", "BodyType"),
				HumanoidDescriptionProps.BodyTypeScale
			),
		})
	end)
end

function Controls:didMount()
	self.props.getScaleBoundaries()
end

local function addRoduxStateToProps(state, props)
	state = state or {}
	local HumanoidDescriptionState = state.HumanoidDescriptionState or {}
	local ScaleBoundariesState = state.ScaleBoundariesState or {}

	return {
		descriptionPropValues = HumanoidDescriptionState.propValues,
		descriptionOverriddenProps = HumanoidDescriptionState.overriddenProps,

		ScaleBoundaries = ScaleBoundariesState.scaleBoundaries,
	}
end

local function addDispatchToProps(dispatch)
	return {
		setHumanoidDescriptionOverride = function(prop, override, value)
			dispatch(SetHumanoidDescriptionOverride(prop, override, value))
		end,

		getScaleBoundaries = function()
			dispatch(GetScaleBoundaries())
		end,
	}
end

return RoactRodux.connect(addRoduxStateToProps, addDispatchToProps)(Controls)