--[[
	Container for the Timeline. Responsible for calculating proper time intervals.
	Also handles logic to scrub through the timeline.

	Properties:
		int StartFrame = beginning frame of timeline range
		int EndFrame = end frame of timeline range
		int LastFrame = The last frame of the animation
		int FrameRate = the rate (frames per second) of the animation
		int LayoutOrder = The layout order of the frame, if in a Layout.
		Vector2 ParentSize = size of the frame this frame is parented to
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)

local TrackUtils = require(Plugin.Src.Util.TrackUtils)
local Constants = require(Plugin.Src.Util.Constants)

local Theme = require(Plugin.Src.Context.Theme)
local withTheme = Theme.withTheme

local Timeline = require(Plugin.Src.Components.Timeline.Timeline)

local TimelineContainer = Roact.PureComponent:extend("TimelineContainer")

local function getExponent(value)
	local tens = -1
	while value > 1 do
		tens = tens + 1
		value = value / 10
	end
	return tens
end

local function calculateIntervals(width, startFrame, endFrame)
	local length = endFrame - startFrame
	local scale = Constants.TICK_SPACING * length / width
	local powTen = math.pow(10, getExponent(scale))
	local mult3 = 3 * powTen
	if scale < mult3 then
		return powTen, math.max(powTen / Constants.NUM_TICKS, 1)
	else
		return mult3, math.max(mult3 / Constants.NUM_TICKS, 1)
	end
end

function TimelineContainer:init()
	self.onScrubberMoved = function(input)
		if self.props.StepAnimation then
			local frame = TrackUtils.getKeyframeFromPosition(
				input.Position,
				self.props.StartFrame,
				self.props.EndFrame,
				self.props.ParentPosition.X + (Constants.TRACK_PADDING / 2),
				self.props.ParentSize.X - Constants.TRACK_PADDING)

			frame = math.clamp(frame, self.props.StartFrame, self.props.EndFrame)
			if self.props.SnapToKeys then
				self.props.SnapToNearestKeyframe(frame, self.props.ParentSize.X - Constants.TRACK_PADDING)
			else
				self.props.StepAnimation(frame)
			end
		end
	end

	self.onTimelineClicked = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.onScrubberMoved(input)
		end
	end
end

function TimelineContainer:render()
	return withTheme(function(theme)
		local props = self.props

		local startFrame = props.StartFrame
		local endFrame = props.EndFrame
		local lastFrame = props.LastFrame
		local frameRate = props.FrameRate
		local showAsSeconds = props.ShowAsSeconds
		local layoutOrder = props.LayoutOrder
		local parentSize = props.ParentSize

		local majorInterval, minorInterval = calculateIntervals(
			parentSize.X - Constants.TRACK_PADDING,
			startFrame,
			endFrame)

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, Constants.TIMELINE_HEIGHT),
			LayoutOrder = layoutOrder,
			BorderSizePixel = 1,
			BackgroundColor3 = theme.timelineTheme.backgroundColor,
			BorderColor3 = theme.borderColor,
			ZIndex = 1,
		}, {
			Timeline = Roact.createElement(Timeline, {
				StartFrame = startFrame,
				EndFrame = endFrame,
				LastFrame = lastFrame,
				MajorInterval = majorInterval,
				MinorInterval = minorInterval,
				Position = UDim2.new(0, Constants.TRACK_PADDING / 2, 0, 0),
				Height = Constants.TIMELINE_HEIGHT,
				Width = parentSize.X - Constants.TRACK_PADDING,
				TickHeightScale = 0.7,
				SmallTickHeightScale = 0.3,
				SampleRate = frameRate,
				ShowAsTime = showAsSeconds,
				OnInputBegan = self.onTimelineClicked,
				OnDragMoved = self.onScrubberMoved,
			}),
		})
	end)
end

return TimelineContainer