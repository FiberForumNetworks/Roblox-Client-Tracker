--[[
	Displays a slider with one or two carets to allow selection of a single or a range of values.

	Props:
		bool Active = whether to render in the enabled/disabled state
		float Min = min value of the slider
		float Max = max value of the slider
		float SnapIncrement = slider handle snap points
		float LowerRangeValue = current value for the lower range handle
		optional float UpperRangeValue = current value for the upper range handle (if nil, this slider
			acts like a single caret slider)
		function SetValues = a callback for when the lower/upper range value is changed
		string MinLabelText = the text for the left hand side min label
		string MaxLabelText = the text for the right hand side max label
		string UnitsLabelText = the text for the units label placed to the right of the max input box
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local withTheme = require(Plugin.Src.ContextServices.Theming).withTheme

local UILibrary = require(Plugin.Packages.UILibrary)
local RoundTextBox = UILibrary.Component.RoundTextBox

local BACKGROUND_BAR_WIDTH = 262
local BAR_HEIGHT = 6
local BAR_SLICE_CENTER = Rect.new(3, 0, 4, 6)
local SLIDER_HANDLE_WIDTH = 18
local SLIDER_HANDLE_HEIGHT = 18
local TOTAL_HEIGHT = 38
local TEXT_LABEL_BOX_HEIGHT = 20
local LOWER_INPUT_BOX_OFFSET = BACKGROUND_BAR_WIDTH + 29
local INPUT_BOX_WIDTH = 48
local INPUT_BOX_HEIGHT = 38
local DASH_WIDTH = 10
local DASH_HEIGHT = 2
local DASH_HORIZONTAL_PADDING = 7
local UPPER_INPUT_BOX_OFFSET = LOWER_INPUT_BOX_OFFSET + INPUT_BOX_WIDTH + DASH_WIDTH + (2*DASH_HORIZONTAL_PADDING)
local VIRTICAL_DRAG_AREA_TOLERANCE = 300

local Slider = Roact.PureComponent:extend("Slider")

local function calculateUnitsLabelOffset(self)
	local props = self.props
	local upperRangeValue = props.UpperRangeValue

	return (upperRangeValue and UPPER_INPUT_BOX_OFFSET or LOWER_INPUT_BOX_OFFSET) + INPUT_BOX_WIDTH + 15
end

function Slider:init()
	self.sliderFrameRef = Roact.createRef()

	self.state = {
		currentLowerTextInputBoxText = tostring(self.props.LowerRangeValue),
		currentUpperTextInputBoxText = tostring(self.props.UpperRangeValue),
		Pressed = false
	}

	self.currentLowerRangeValue = self.props.LowerRangeValue
	self.currentUpperRangeValue = self.props.UpperRangeValue
	self.havePropsChanged = false
end

function Slider:willUpdate()
	self.currentLowerRangeValue = self.props.LowerRangeValue
	self.currentUpperRangeValue = self.props.UpperRangeValue
	self.havePropsChanged = false
end

function Slider:render()
	return withTheme(function(theme)
		local sliderTheme = theme.Slider

		local props = self.props
		local active = props.Active

		local lowerInputBoxText = self.state.currentLowerTextInputBoxText
		local upperInputBoxText = self.state.currentUpperTextInputBoxText
		self.havePropsChanged = self.currentLowerRangeValue ~= self.props.LowerRangeValue or
			self.currentUpperRangeValue ~= self.props.UpperRangeValue
		if self.havePropsChanged then
			lowerInputBoxText = tostring(self.props.LowerRangeValue)
			upperInputBoxText = tostring(self.props.UpperRangeValue)
		end

		local children = {
			SliderContent = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, TOTAL_HEIGHT)
			}, {
				SliderFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, BACKGROUND_BAR_WIDTH, 0, SLIDER_HANDLE_HEIGHT),

					[Roact.Ref] = self.sliderFrameRef,
				}, {
					ClickHandler = Roact.createElement("ImageButton", {
						Size = UDim2.new(1, SLIDER_HANDLE_WIDTH, 1, self.state.Pressed and VIRTICAL_DRAG_AREA_TOLERANCE or 0),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						ZIndex = 4,

						[Roact.Event.InputBegan] = function(rbx, input)
							if active and input.UserInputType == Enum.UserInputType.MouseButton1 then
								self:setState({
									Pressed = true,
								})
								self.staticRangeDuringInput = self:calculateStaticRangeValueDuringInput(input)
								self:setValuesFromInput(input)
							end
						end,

						[Roact.Event.InputChanged] = function(rbx, input)
							if active and self.state.Pressed and input.UserInputType == Enum.UserInputType.MouseMovement then
								self:setValuesFromInput(input)
							end
						end,

						[Roact.Event.InputEnded] = function(rbx, input)
							if active and input.UserInputType == Enum.UserInputType.MouseButton1 then
								self:setState({
									Pressed = false,
								})
							end
						end,
					}),
					SliderHandleOne = Roact.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, SLIDER_HANDLE_WIDTH, 0, SLIDER_HANDLE_HEIGHT),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(self:calculateLowerHandleHorizontalOffset(), 0, 0, 0),
						Image = sliderTheme.SliderHandleImage,
						Visible = active,
						ZIndex = 3
					}),
					SliderHandleTwo = self.props.UpperRangeValue and Roact.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, SLIDER_HANDLE_WIDTH, 0, SLIDER_HANDLE_HEIGHT),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(self:calculateUpperHandleHorizontalOffset(), 0, 0, 0),
						Image = sliderTheme.SliderHandleImage,
						Visible = active,
						ZIndex = 3
					}),
					BackgroundBar = Roact.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, BACKGROUND_BAR_WIDTH, 0, BAR_HEIGHT),
						Image = sliderTheme.BarImage,
						ImageColor3 = sliderTheme.BarBackgroundColor,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = BAR_SLICE_CENTER,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
					}),
					ForegroundBar = Roact.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(self:calculateForegroundBarHorizontalSize(), 0, 0, BAR_HEIGHT),
						Image = sliderTheme.BarImage,
						ImageColor3 = sliderTheme.BarForegroundColor,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = BAR_SLICE_CENTER,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(self:calculateForegroundBarHorizontalOffset(), 0, 0.5, 0),
						Visible = active,
						ZIndex = 2
					}),
				}),
				LowerLabel = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 0, TEXT_LABEL_BOX_HEIGHT),

					TextColor3 = sliderTheme.TextColor,
					Font = Enum.Font.SourceSans,
					TextSize = theme.Text.LargeSize,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, 0, 1, 0),
					Visible = active,
					Text = self.props.MinLabelText,
				}),
				UpperLabel = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 0, TEXT_LABEL_BOX_HEIGHT),

					TextColor3 = sliderTheme.TextColor,
					Font = Enum.Font.SourceSans,
					TextSize = theme.Text.LargeSize,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(0, BACKGROUND_BAR_WIDTH, 1, 0),
					Visible = active,
					Text = self.props.MaxLabelText,
				}),

				LowerInputBox = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, INPUT_BOX_WIDTH, 0, INPUT_BOX_HEIGHT),
					Position = UDim2.new(0, LOWER_INPUT_BOX_OFFSET, 0, 0),
				}, {
					LowerInputBox = Roact.createElement(RoundTextBox, {
						Active = active,
						MaxLength = 100,
						Text = lowerInputBoxText,
						Height = INPUT_BOX_HEIGHT,
						ShowToolTip = false,
						HorizontalAlignment = Enum.TextXAlignment.Center,
						TextSize = theme.Text.LargeSize,

						SetText = function(text)
							self:setState({
								currentLowerTextInputBoxText = text
							})
						end,

						FocusChanged = function(hasFocus)
							if not hasFocus then
								local wasSet = false

								local value = tonumber(self.state.currentLowerTextInputBoxText)
								if value then
									wasSet = self:setLowerRangeValue(value)
								end

								if not wasSet then
									self:setState({
										currentLowerTextInputBoxText = tostring(self.props.LowerRangeValue)
									})
								end
							end
						end
					}),
				}),

				Dash = self.props.UpperRangeValue and Roact.createElement("Frame", {
					BorderSizePixel = 0,
					Size = UDim2.new(0, DASH_WIDTH, 0, DASH_HEIGHT),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(0, UPPER_INPUT_BOX_OFFSET-DASH_HORIZONTAL_PADDING, 0.5, 0),
					BackgroundColor3 = sliderTheme.TextDescriptionColor
				}),

				UpperInputBox = self.props.UpperRangeValue and Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, INPUT_BOX_WIDTH, 0, INPUT_BOX_HEIGHT),
					Position = UDim2.new(0, UPPER_INPUT_BOX_OFFSET, 0, 0),
				}, {
					UpperInputBox = Roact.createElement(RoundTextBox, {
						Active = active,
						MaxLength = 100,
						Text = upperInputBoxText,
						Height = INPUT_BOX_HEIGHT,
						ShowToolTip = false,
						HorizontalAlignment = Enum.TextXAlignment.Center,
						TextSize = theme.Text.LargeSize,

						SetText = function(text)
							self:setState({
								currentUpperTextInputBoxText = text
							})
						end,

						FocusChanged = function(hasFocus)
							if not hasFocus then
								local wasSet = false

								local value = tonumber(self.state.currentUpperTextInputBoxText)
								if value then
									wasSet = self:setUpperRangeValue(value)
								end

								if not wasSet then
									self:setState({
										currentUpperTextInputBoxText = tostring(self.props.UpperRangeValue)
									})
								end
							end
						end
					}),
				}),

				UnitsLabel = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, calculateUnitsLabelOffset(self), 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					TextColor3 = sliderTheme.TextDescriptionColor,
					Font = Enum.Font.SourceSans,
					TextSize = theme.Text.LargeSize,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					Text = self.props.UnitsLabelText,
				})
			})
		}

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, TOTAL_HEIGHT),
			LayoutOrder = self.props.LayoutOrder or 1,
			BackgroundTransparency = 1,
		}, children)
	end)
end

function Slider:didUpdate()
	if self.havePropsChanged then
		self.havePropsChanged = false
		self:setState({
			currentLowerTextInputBoxText = tostring(self.props.LowerRangeValue),
			currentUpperTextInputBoxText = tostring(self.props.UpperRangeValue),
		})
	end
end

local function calculateSliderTotalRange(self)
	return self.props.Max-self.props.Min
end

function Slider:calculateLowerHandleHorizontalOffset()
	return (self.props.LowerRangeValue-self.props.Min)/calculateSliderTotalRange(self)
end

function Slider:calculateUpperHandleHorizontalOffset()
	return (self.props.UpperRangeValue-self.props.Min)/calculateSliderTotalRange(self)
end

function Slider:calculateForegroundBarHorizontalOffset()
	if not self.props.UpperRangeValue then
		return 0
	end
	return self:calculateLowerHandleHorizontalOffset()
end

function Slider:calculateForegroundBarHorizontalSize()
	if not self.props.UpperRangeValue then
		return self:calculateLowerHandleHorizontalOffset()
	end
	return self:calculateUpperHandleHorizontalOffset()-self:calculateLowerHandleHorizontalOffset()
end

local function calculateIncrementSnappedValue(self, value)
	if self.props.SnapIncrement > 0.001 then
		local prevSnap = math.max(self.props.SnapIncrement*math.floor(value/self.props.SnapIncrement), self.props.Min)
		local nextSnap = math.min(prevSnap+self.props.SnapIncrement, self.props.Max)
		return math.abs(prevSnap-value) < math.abs(nextSnap-value) and prevSnap or nextSnap
	end
	return math.min(self.props.Max, math.max(self.props.Min, value))
end

local function calculateMouseClickValue(self, input)
	local inputHorizontalOffsetNormalized =
		(input.Position.X-self.sliderFrameRef.current.AbsolutePosition.X)/self.sliderFrameRef.current.AbsoluteSize.X
	inputHorizontalOffsetNormalized = math.max(0, math.min(1, inputHorizontalOffsetNormalized))
	local valueBeforeSnapping = self.props.Min + (inputHorizontalOffsetNormalized * calculateSliderTotalRange(self))
	return calculateIncrementSnappedValue(self, valueBeforeSnapping)
end

function Slider:calculateStaticRangeValueDuringInput(input)
	if not self.props.UpperRangeValue then
		return nil
	end

	local mouseClickValue = calculateMouseClickValue(self, input)

	if mouseClickValue < self.props.LowerRangeValue then
		return self.props.UpperRangeValue
	elseif mouseClickValue > self.props.UpperRangeValue then
		return self.props.LowerRangeValue
	end

	local diffToLower = math.abs(mouseClickValue-self.props.LowerRangeValue)
	local diffToUpper = math.abs(mouseClickValue-self.props.UpperRangeValue)

	if diffToLower < diffToUpper then
		return self.props.UpperRangeValue
	end
	return self.props.LowerRangeValue
end

local function clampLowerRangeValue(self, value)
	value = calculateIncrementSnappedValue(self, value)
	return math.min(self.props.UpperRangeValue or self.props.Max, math.max(self.props.Min, value))
end

local function clampUpperRangeValue(self, value)
	value = calculateIncrementSnappedValue(self, value)
	return math.min(self.props.Max, math.max(self.props.LowerRangeValue, value))
end

function Slider:setValuesFromInput(input)
	local mouseClickValue = calculateMouseClickValue(self, input)
	local newLowerValue =
		clampLowerRangeValue(self, math.min(mouseClickValue, self.staticRangeDuringInput or self.props.Max))
	local newUpperValue =
		self.props.UpperRangeValue and
			clampUpperRangeValue(self, math.max(mouseClickValue, self.staticRangeDuringInput))
	self.props.SetValues(newLowerValue, newUpperValue)
end

function Slider:setLowerRangeValue(value)
	value = clampLowerRangeValue(self, value)
	if self.props.LowerRangeValue ~= value then
		self.props.SetValues(value, self.props.UpperRangeValue)
		return true
	end
	return false
end

function Slider:setUpperRangeValue(value)
	value = clampUpperRangeValue(self, value)
	if self.props.UpperRangeValue ~= value then
		self.props.SetValues(self.props.LowerRangeValue, value)
		return true
	end
	return false
end

return Slider