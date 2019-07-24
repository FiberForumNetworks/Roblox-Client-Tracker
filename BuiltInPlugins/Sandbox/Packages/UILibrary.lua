--[[
	Public interface for UILibrary
]]

local Src = script
local Components = Src.Components
local Utils = Src.Utils

local BulletPoint = require(Components.BulletPoint)
local Button = require(Components.Button)
local CheckBox = require(Components.CheckBox)
local createFitToContent = require(Components.createFitToContent)
local DragTarget = require(Components.DragTarget)
local DropdownMenu = require(Components.DropdownMenu)
local DropShadow = require(Components.DropShadow)
local ExpandableList = require(Components.ExpandableList)
local Keyframe = require(Components.Timeline.Keyframe)
local LoadingIndicator = require(Components.LoadingIndicator)
local RoundFrame = require(Components.RoundFrame)
local RoundTextBox = require(Components.RoundTextBox)
local RoundTextButton = require(Components.RoundTextButton)
local Scrubber = require(Components.Timeline.Scrubber)
local Separator = require(Components.Separator)
local StyledDialog = require(Components.StyledDialog)
local StyledDropdown = require(Components.StyledDropdown)
local StyledScrollingFrame = require(Components.StyledScrollingFrame)
local Timeline = require(Components.Timeline.Timeline)
local TimelineTick = require(Components.Timeline.TimelineTick)
local TitledFrame = require(Components.TitledFrame)
local Tooltip = require(Components.Tooltip)

local Spritesheet = require(Utils.Spritesheet)

local Focus = require(Src.Focus)

local UILibrary = {
	Component = {
		BulletPoint = BulletPoint,
		Button = Button,
		CheckBox = CheckBox,
		createFitToContent = createFitToContent,
		DragTarget = DragTarget,
		DropdownMenu = DropdownMenu,
		DropShadow = DropShadow,
		ExpandableList = ExpandableList,
		Keyframe = Keyframe,
		LoadingIndicator = LoadingIndicator,
		RoundFrame = RoundFrame,
		RoundTextBox = RoundTextBox,
		RoundTextButton = RoundTextButton,
		Scrubber = Scrubber,
		Separator = Separator,
		StyledDialog = StyledDialog,
		StyledDropdown = StyledDropdown,
		StyledScrollingFrame = StyledScrollingFrame,
		Timeline = Timeline,
		TimelineTick = TimelineTick,
		TitledFrame = TitledFrame,
		Tooltip = Tooltip,
	},

	Studio = {
		Localization = require(Src.Studio.Localization),
		Style = require(Src.Studio.StudioStyle),
		Theme = require(Src.Studio.StudioTheme),
	},

	Focus = {
		CaptureFocus = Focus.CaptureFocus,
		ShowOnTop = Focus.ShowOnTop,
		KeyboardListener = Focus.KeyboardListener,
	},
	
	Util = {
		Spritesheet = Spritesheet,
	},

	Localizing = require(Src.Localizing),
	Wrapper = require(Src.UILibraryWrapper),

	createTheme = require(Src.createTheme),
}

return UILibrary