local FastFlags = require(script.Parent.Parent.FastFlags)
-- singleton
local ThemeData = {}

ThemeData.KeyNames = {
	"BackgroundColorKey",
	"BorderColorKey",
	"TextColorKey",
	"PlaceholderColorKey",
	"ImageKey",
	"ScrollBarColorKey",
}

-- Names for colors/images used in Animation Editor
ThemeData.ColorAndImageNames = {
		"BackgroundColor", "BackgroundColor2", "NotchColor", "NotchesBackgroundColor", "VerticalLine",
		"MenuBorder", "DividerColor", "ShadeColor", "ImageBorder", "FillerColor",
		"PopupBorder", "PopupBorder2", "DisabledColor", "JointSelected", "ScrubberColor",
		"Highlight" ,"InputBorder", "JointListDivider", "Hover", "Header",
		"TextColor", "HeaderTextColor", "DisabledTextColor", "TextPlaceholderColor", "HighlightText",
		"HierarchyLine", "InputField", "ScaleBar", "CheckboxBackground", "EventBar",

		"RoundedButton", "RoundedBorder", "EndButton", "NextButton","PlayButton",
		"PreviousButton", "StartButton", "PauseButton", "HierarchyClosed", "HierarchyOpened",
		"LockButton", "LoopButton", "CloseButton", "RadioDefault", "RadioInner",
		"ZoomButton", "Checkmark", "Slash", "KeyBorder", "KeyIndicatorBorder",
		"KeyIndicatorInner", "KeyIndicatorSelectedBorder", "KeyIndicatorSelectedInner", "KeyInner", "KeySelectedBorder",
		"KeySelectedInner", "ScrubberHead", "DownArrow", "UpArrow", "RadioBackground",
		"TimeTag", "TimeTagBorder", "ScaleArrows", "ScaleArrowsBorder", "PinIcon",
		"HierarchyEnd", "Collapse", "DeleteEvent", "EditEvent", "Expand", "Manage",
		"RemoveEvent", "Search", "GroupMarkerBorderSelected", "GroupMarkerBorder", "GroupMarkerInner",
		"MarkerBorderSelected", "MarkerBorder", "MarkerInner", "MarkerMin", "AddEventBorder",
		"AddEventInner", "ClearText",

		"Linear", "LinearDisabled", "Elastic", "ElasticDisabled", "Bounce", "BounceDisabled",
		"Constant", "ConstantDisabled", "Cubic", "CubicDisabled",
}

-- Colors not provided by API
ThemeData.CustomStyleColors = {
    Linear = {},
    Elastic = {},
    Cubic = {},
    Bounce = {},
    Constant = {},
    KeyBorder = {},
    Lock = {},
    Swizzle = {},
    Zoom = {},
    Joint = {},
    RadioButtonBorder = {},
    TimelineScrollBar = {},
}

ThemeData.CustomColors = {
	[ThemeData.CustomStyleColors.Linear] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(119, 119, 119),
		[Enum.StudioStyleGuideModifier.Disabled] = Color3.fromRGB(64, 64, 64),
	},

	[ThemeData.CustomStyleColors.Elastic] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(104, 167, 29),
		[Enum.StudioStyleGuideModifier.Disabled] = Color3.fromRGB(65, 106, 16),
	},

	[ThemeData.CustomStyleColors.Bounce] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(78, 164, 172),
		[Enum.StudioStyleGuideModifier.Disabled] = Color3.fromRGB(45, 101, 106),
	},

	[ThemeData.CustomStyleColors.Constant] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(127, 111, 253),
		[Enum.StudioStyleGuideModifier.Disabled] = Color3.fromRGB(85, 81, 124),
	},

	[ThemeData.CustomStyleColors.Cubic] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(211, 149, 46),
		[Enum.StudioStyleGuideModifier.Disabled] = Color3.fromRGB(115, 79, 20),
	},

	[ThemeData.CustomStyleColors.KeyBorder] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(185, 185, 185),
		[Enum.StudioStyleGuideModifier.Disabled] = Color3.fromRGB(105, 105, 105),
	},

	[ThemeData.CustomStyleColors.Joint] = {
		[Enum.StudioStyleGuideModifier.Selected] = Color3.fromRGB(11, 90, 175)
	},

	[ThemeData.CustomStyleColors.Lock] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(85, 85, 85),
		[Enum.StudioStyleGuideModifier.Hover] = Color3.fromRGB(102, 102, 102),
		[Enum.StudioStyleGuideModifier.Selected] = Color3.fromRGB(204, 204, 204),
	},

	[ThemeData.CustomStyleColors.Swizzle] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(170, 170, 170),
	},

	[ThemeData.CustomStyleColors.Zoom] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(255, 255, 255),
	},

	[ThemeData.CustomStyleColors.RadioButtonBorder] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(26, 26, 26),
	},

	[ThemeData.CustomStyleColors.TimelineScrollBar] = {
		[Enum.StudioStyleGuideModifier.Default] = Color3.fromRGB(72, 72, 72),
	},
}

function ThemeData:init()
	self.ColorAndImageNamesMap = {}
	for _, name in ipairs(self.ColorAndImageNames) do
		if not self.ColorAndImageNamesMap[name] then
			self.ColorAndImageNamesMap[name] = name
		end
	end

	self.KeyNamesMap = {}
	for _, name in ipairs(self.KeyNames) do
		if not self.KeyNamesMap[name] then
			self.KeyNamesMap[name] = name
		end
	end

	-- if you update any colors/image urls on the elements directly in studio, you will
	-- also need to update these tables as well
	ThemeData.Images = {
		[ThemeData.ColorAndImageNamesMap.RoundedButton] = "rbxasset://textures/AnimationEditor/RoundedBackground.png",
		[ThemeData.ColorAndImageNamesMap.RoundedBorder] = "rbxasset://textures/AnimationEditor/RoundedBorder.png",
		[ThemeData.ColorAndImageNamesMap.EndButton] = "rbxasset://textures/AnimationEditor/button_control_end.png",
		[ThemeData.ColorAndImageNamesMap.NextButton] = "rbxasset://textures/AnimationEditor/button_control_next.png",
		[ThemeData.ColorAndImageNamesMap.PlayButton] = "rbxasset://textures/AnimationEditor/button_control_play.png",
		[ThemeData.ColorAndImageNamesMap.PreviousButton] = "rbxasset://textures/AnimationEditor/button_control_previous.png",
		[ThemeData.ColorAndImageNamesMap.StartButton] = "rbxasset://textures/AnimationEditor/button_control_start.png",
		[ThemeData.ColorAndImageNamesMap.PauseButton] = "rbxasset://textures/AnimationEditor/button_pause_white@2x.png",
		[ThemeData.ColorAndImageNamesMap.HierarchyClosed] = "rbxasset://textures/AnimationEditor/button_hierarchy_closed.png",
		[ThemeData.ColorAndImageNamesMap.HierarchyOpened] = "rbxasset://textures/AnimationEditor/button_hierarchy_opened.png",
		[ThemeData.ColorAndImageNamesMap.LockButton] = "rbxasset://textures/AnimationEditor/button_lock.png",
		[ThemeData.ColorAndImageNamesMap.LoopButton] = "rbxasset://textures/AnimationEditor/button_loop.png",
		[ThemeData.ColorAndImageNamesMap.CloseButton] = "rbxasset://textures/AnimationEditor/button_popup_close.png",
		[ThemeData.ColorAndImageNamesMap.RadioBackground] = "rbxasset://textures/AnimationEditor/button_radio_background.png",
		[ThemeData.ColorAndImageNamesMap.RadioDefault] = "rbxasset://textures/AnimationEditor/button_radio_default.png",
		[ThemeData.ColorAndImageNamesMap.RadioInner] = "rbxasset://textures/AnimationEditor/button_radio_innercircle.png",
		[ThemeData.ColorAndImageNamesMap.ZoomButton] = "rbxasset://textures/AnimationEditor/button_zoom.png",
		[ThemeData.ColorAndImageNamesMap.Checkmark] = "rbxasset://textures/AnimationEditor/icon_checkmark.png",
		[ThemeData.ColorAndImageNamesMap.Slash] = "rbxasset://textures/AnimationEditor/img_forwardslash.png",
		[ThemeData.ColorAndImageNamesMap.KeyBorder] = "rbxasset://textures/AnimationEditor/img_key_border.png",
		[ThemeData.ColorAndImageNamesMap.KeyIndicatorBorder] = "rbxasset://textures/AnimationEditor/img_key_indicator_border.png",
		[ThemeData.ColorAndImageNamesMap.KeyIndicatorInner] = "rbxasset://textures/AnimationEditor/img_key_indicator_inner.png",
		[ThemeData.ColorAndImageNamesMap.KeyIndicatorSelectedBorder] = "rbxasset://textures/AnimationEditor/img_key_indicator_selected_border.png",
		[ThemeData.ColorAndImageNamesMap.KeyIndicatorSelectedInner] = "rbxasset://textures/AnimationEditor/img_key_indicator_selected_inner.png",
		[ThemeData.ColorAndImageNamesMap.KeyInner] = "rbxasset://textures/AnimationEditor/img_key_inner.png",
		[ThemeData.ColorAndImageNamesMap.KeySelectedBorder] ="rbxasset://textures/AnimationEditor/img_key_selected_border.png",
		[ThemeData.ColorAndImageNamesMap.KeySelectedInner] = "rbxasset://textures/AnimationEditor/img_key_selected_inner.png",
		[ThemeData.ColorAndImageNamesMap.ScrubberHead] = "rbxasset://textures/AnimationEditor/img_scrubberhead.png",
		[ThemeData.ColorAndImageNamesMap.DownArrow] = "rbxasset://textures/AnimationEditor/icon_whitetriangle_down.png",
		[ThemeData.ColorAndImageNamesMap.UpArrow] = "rbxasset://textures/AnimationEditor/icon_whitetriangle_up.png",
		[ThemeData.ColorAndImageNamesMap.TimeTag] = "rbxasset://textures/AnimationEditor/img_timetag.png",
		[ThemeData.ColorAndImageNamesMap.TimeTagBorder] = "rbxasset://textures/AnimationEditor/img_timetag_border.png",
		[ThemeData.ColorAndImageNamesMap.ScaleArrows] = "rbxasset://textures/AnimationEditor/img_scalebar_arrows.png",
		[ThemeData.ColorAndImageNamesMap.ScaleArrowsBorder] = "rbxasset://textures/AnimationEditor/img_scalebar_arrows_border.png",
		[ThemeData.ColorAndImageNamesMap.PinIcon] = "rbxasset://textures/AnimationEditor/icon_pin.png",
		[ThemeData.ColorAndImageNamesMap.HierarchyEnd] = "rbxasset://textures/AnimationEditor/icon_hierarchy_end_white.png",
		[ThemeData.ColorAndImageNamesMap.Collapse] = "rbxasset://textures/AnimationEditor/btn_collapse.png",
		[ThemeData.ColorAndImageNamesMap.DeleteEvent] = "rbxasset://textures/AnimationEditor/btn_delete.png",
		[ThemeData.ColorAndImageNamesMap.EditEvent] = "rbxasset://textures/AnimationEditor/btn_edit.png",
		[ThemeData.ColorAndImageNamesMap.Expand] ="rbxasset://textures/AnimationEditor/btn_expand.png",
		[ThemeData.ColorAndImageNamesMap.Manage] = "rbxasset://textures/AnimationEditor/btn_manage.png",
		[ThemeData.ColorAndImageNamesMap.RemoveEvent] = "rbxasset://textures/AnimationEditor/btn_removeEvent.png",
		[ThemeData.ColorAndImageNamesMap.Search] = "rbxasset://textures/AnimationEditor/button_search.png",
		[ThemeData.ColorAndImageNamesMap.GroupMarkerBorderSelected] = "rbxasset://textures/AnimationEditor/img_eventGroupMarker_border_selected.png",
		[ThemeData.ColorAndImageNamesMap.GroupMarkerBorder] = "rbxasset://textures/AnimationEditor/img_eventGroupMarker_border.png",
		[ThemeData.ColorAndImageNamesMap.GroupMarkerInner] = "rbxasset://textures/AnimationEditor/img_eventGroupMarker_inner.png",
		[ThemeData.ColorAndImageNamesMap.MarkerBorderSelected] = "rbxasset://textures/AnimationEditor/img_eventMarker_border_selected.png",
		[ThemeData.ColorAndImageNamesMap.MarkerBorder] = "rbxasset://textures/AnimationEditor/img_eventMarker_border.png",
		[ThemeData.ColorAndImageNamesMap.MarkerInner] = "rbxasset://textures/AnimationEditor/img_eventMarker_inner.png",
		[ThemeData.ColorAndImageNamesMap.MarkerMin] = "rbxasset://textures/AnimationEditor/img_eventMarker_min.png",
		[ThemeData.ColorAndImageNamesMap.AddEventInner] = "rbxasset://textures/AnimationEditor/btn_addEvent_inner.png",
		[ThemeData.ColorAndImageNamesMap.AddEventBorder] = "rbxasset://textures/AnimationEditor/btn_addEvent_border.png",
		[ThemeData.ColorAndImageNamesMap.ClearText] = "rbxasset://textures/AnimationEditor/btn_clearText.png",
	}

	ThemeData.DataStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.MainBackground, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255,255,255),},
		[ThemeData.ColorAndImageNamesMap.BackgroundColor2] = {Style = Enum.StudioStyleGuideColor.ScrollBar, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(244,244,244),},
		[ThemeData.ColorAndImageNamesMap.NotchColor] = {Style = Enum.StudioStyleGuideColor.DimmedText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(127,127,127),},
		[ThemeData.ColorAndImageNamesMap.NotchesBackgroundColor] = {Style = Enum.StudioStyleGuideColor.Tab, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(233, 233, 233),},
		[ThemeData.ColorAndImageNamesMap.VerticalLine] = {Style = Enum.StudioStyleGuideColor.EmulatorDropDown, Modifier = Enum.StudioStyleGuideModifier.Hover, Color = Color3.fromRGB(230, 230, 230),},
		[ThemeData.ColorAndImageNamesMap.MenuBorder] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(204,204,204),},
		[ThemeData.ColorAndImageNamesMap.DividerColor] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(227, 227, 227),},
		[ThemeData.ColorAndImageNamesMap.ShadeColor] = {Style = Enum.StudioStyleGuideColor.Tab, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(245, 245, 245),},
		[ThemeData.ColorAndImageNamesMap.ImageBorder] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(238,238,238),},
		[ThemeData.ColorAndImageNamesMap.FillerColor] = {Style = Enum.StudioStyleGuideColor.MainBackground, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(124,124,124),},
		[ThemeData.ColorAndImageNamesMap.PopupBorder] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(151,151,151),},
		[ThemeData.ColorAndImageNamesMap.PopupBorder2] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(210,210,210),},
		[ThemeData.ColorAndImageNamesMap.DisabledColor] = {Style = Enum.StudioStyleGuideColor.ScrollBar, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(191,191,191),},
		[ThemeData.ColorAndImageNamesMap.JointSelected] = {Style = ThemeData.CustomStyleColors.Joint, Modifier = Enum.StudioStyleGuideModifier.Selected, Color = Color3.fromRGB(95, 138, 208),},
		[ThemeData.ColorAndImageNamesMap.ScrubberColor] = {Style = Enum.StudioStyleGuideColor.MainButton, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(75,170,248),},
		[ThemeData.ColorAndImageNamesMap.Highlight] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(0, 162, 255),},
		[ThemeData.ColorAndImageNamesMap.InputBorder] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(184,184,184),},
		[ThemeData.ColorAndImageNamesMap.JointListDivider] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(182, 182, 182),},
		[ThemeData.ColorAndImageNamesMap.Hover] = {Style = Enum.StudioStyleGuideColor.EmulatorDropDown, Modifier = Enum.StudioStyleGuideModifier.Hover, Color = Color3.fromRGB(228, 238, 254),},
		[ThemeData.ColorAndImageNamesMap.Header] = {Style = Enum.StudioStyleGuideColor.ScrollBar, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(246, 246, 246),},
		[ThemeData.ColorAndImageNamesMap.HierarchyLine] = {Style = Enum.StudioStyleGuideColor.EmulatorDropDown, Modifier = Enum.StudioStyleGuideModifier.Hover, Color = Color3.fromRGB(205, 205, 205),},
		[ThemeData.ColorAndImageNamesMap.InputField] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(254, 254, 254),},
		[ThemeData.ColorAndImageNamesMap.ScaleBar] = {Style = Enum.StudioStyleGuideColor.RibbonTabTopBar, Modifier = Enum.StudioStyleGuideModifier.Selected, Color = Color3.fromRGB(100, 148, 227),},
		[ThemeData.ColorAndImageNamesMap.CheckboxBackground] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(250, 250, 250),},
		[ThemeData.ColorAndImageNamesMap.EventBar] = {Style = Enum.StudioStyleGuideColor.TabBar, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(235, 235, 235),},		
	}

	ThemeData.TextStyleMap = {
		[ThemeData.ColorAndImageNamesMap.TextColor] = {Style = Enum.StudioStyleGuideColor.MainText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(0,0,0),},
		[ThemeData.ColorAndImageNamesMap.HeaderTextColor] = {Style = Enum.StudioStyleGuideColor.MainText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(27,42,53),},
		[ThemeData.ColorAndImageNamesMap.DisabledTextColor] = {Style = Enum.StudioStyleGuideColor.MainText, Modifier = Enum.StudioStyleGuideModifier.Disabled, Color = Color3.fromRGB(184, 184, 184),},
		[ThemeData.ColorAndImageNamesMap.TextPlaceholderColor] = {Style = Enum.StudioStyleGuideColor.DimmedText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(179, 179, 179),},
		[ThemeData.ColorAndImageNamesMap.HighlightText] = {Style = Enum.StudioStyleGuideColor.BrightText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255, 255, 255),},
	}

	ThemeData.ScrollStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.MainBackground, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255, 255, 255),},
		[ThemeData.ColorAndImageNamesMap.BackgroundColor2] = {Style = ThemeData.CustomStyleColors.TimelineScrollBar, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(254, 254, 254)},
	}

	ThemeData.RoundedButtonStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.Button, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255, 255, 255),},
		[ThemeData.ColorAndImageNamesMap.Hover] = {Style = Enum.StudioStyleGuideColor.Button, Modifier = Enum.StudioStyleGuideModifier.Hover, Color = Color3.fromRGB(242, 242, 242),},
		[ThemeData.ColorAndImageNamesMap.Highlight] = {Style = Enum.StudioStyleGuideColor.Button, Modifier = Enum.StudioStyleGuideModifier.Pressed, Color = Color3.fromRGB(184, 184, 184),},
	}

	ThemeData.RoundedBorderStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.Button, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(184, 184, 184),},
	}

	ThemeData.HierarchyIconStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = ThemeData.CustomStyleColors.Swizzle, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(140, 140, 140),},
		[ThemeData.ColorAndImageNamesMap.Highlight] = {Style = Enum.StudioStyleGuideColor.BrightText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255, 255, 255),},
	}

	ThemeData.ScrubberHeadStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.MainButton, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(75, 170, 248),},
	}

	ThemeData.ControlButtonStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.MainText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(0, 0, 0),},
		[ThemeData.ColorAndImageNamesMap.Highlight] = {Style = Enum.StudioStyleGuideColor.BrightText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255, 255, 255),},
	}

	ThemeData.IconStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.BrightText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(0, 0, 0),},
	}

	ThemeData.CloseIconStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.BrightText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(184, 184, 184),},
	}

	ThemeData.KeyIconBorderStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = ThemeData.CustomStyleColors.KeyBorder, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(56, 56, 56),},
		[ThemeData.ColorAndImageNamesMap.DisabledColor] = {Style = ThemeData.CustomStyleColors.KeyBorder, Modifier = Enum.StudioStyleGuideModifier.Disabled, Color = Color3.fromRGB(160, 160, 160),},
	}

	ThemeData.KeyIconSelectedBorderStyleMap = {
		[ThemeData.ColorAndImageNamesMap.Highlight] = {Style = Enum.StudioStyleGuideColor.RibbonTabTopBar, Modifier = Enum.StudioStyleGuideModifier.Selected, Color = Color3.fromRGB(100, 148, 227),},
	}

	ThemeData.LockIconStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = ThemeData.CustomStyleColors.Lock, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(200, 200, 200),},
		[ThemeData.ColorAndImageNamesMap.Hover] = {Style = ThemeData.CustomStyleColors.Lock, Modifier = Enum.StudioStyleGuideModifier.Hover, Color = Color3.fromRGB(117, 117, 117),},
		[ThemeData.ColorAndImageNamesMap.Highlight] = {Style = ThemeData.CustomStyleColors.Lock, Modifier = Enum.StudioStyleGuideModifier.Selected, Color = Color3.fromRGB(0, 0, 0),},
	}

	ThemeData.ZoomIconStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = ThemeData.CustomStyleColors.Swizzle, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(140, 140, 140),},
		[ThemeData.ColorAndImageNamesMap.Highlight] = {Style = ThemeData.CustomStyleColors.Zoom, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(0, 162, 255),},
	}

	ThemeData.RadioButtonBorderStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = ThemeData.CustomStyleColors.RadioButtonBorder, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(147, 147, 147),},
	}

	ThemeData.RadioButtonBackgroundStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.Border, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255, 255, 255),},
	}

	ThemeData.RadioButtonInnerStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.Button, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(147, 147, 147),},
	}

	ThemeData.KeyIconStyleMap = {
		[ThemeData.ColorAndImageNamesMap.LinearDisabled] = {Style = ThemeData.CustomStyleColors.Linear, Modifier = Enum.StudioStyleGuideModifier.Disabled, Color = Color3.fromRGB(223, 223, 223),},
		[ThemeData.ColorAndImageNamesMap.Linear] = {Style = ThemeData.CustomStyleColors.Linear, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(214, 214, 214),},
		[ThemeData.ColorAndImageNamesMap.BounceDisabled] = {Style = ThemeData.CustomStyleColors.Bounce, Modifier = Enum.StudioStyleGuideModifier.Disabled, Color = Color3.fromRGB(202, 225, 227),},
		[ThemeData.ColorAndImageNamesMap.Bounce] = {Style = ThemeData.CustomStyleColors.Bounce, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(151, 212, 218),},
		[ThemeData.ColorAndImageNamesMap.ConstantDisabled] = {Style = ThemeData.CustomStyleColors.Constant, Modifier = Enum.StudioStyleGuideModifier.Disabled, Color = Color3.fromRGB(199, 195, 232),},
		[ThemeData.ColorAndImageNamesMap.Constant] = {Style = ThemeData.CustomStyleColors.Constant, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(156, 147, 226),},
		[ThemeData.ColorAndImageNamesMap.ElasticDisabled] = {Style = ThemeData.CustomStyleColors.Elastic, Modifier = Enum.StudioStyleGuideModifier.Disabled, Color = Color3.fromRGB(206, 222, 187),},
		[ThemeData.ColorAndImageNamesMap.Elastic] = {Style = ThemeData.CustomStyleColors.Elastic, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(168, 214, 113),},
		[ThemeData.ColorAndImageNamesMap.Cubic] = {Style = ThemeData.CustomStyleColors.Cubic, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(225, 205, 122),},
		[ThemeData.ColorAndImageNamesMap.CubicDisabled] = {Style = ThemeData.CustomStyleColors.Cubic, Modifier = Enum.StudioStyleGuideModifier.Disabled, Color = Color3.fromRGB(234, 215, 183),},	
	}

	ThemeData.TimeTagStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.RibbonTabTopBar, Modifier = Enum.StudioStyleGuideModifier.Selected, Color = Color3.fromRGB(100, 148, 227),},
	}

	ThemeData.TimeTagBorderStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.TabBar, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(233, 233, 233),},
	}

	ThemeData.ScaleArrowsStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.RibbonTabTopBar, Modifier = Enum.StudioStyleGuideModifier.Selected, Color = Color3.fromRGB(100, 148, 227),},
	}

	ThemeData.ScaleArrowsBorderStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.MainBackground, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(255,255,255),},
	}

	ThemeData.EventIconStyleMap = {
		[ThemeData.ColorAndImageNamesMap.BackgroundColor] = {Style = Enum.StudioStyleGuideColor.TitlebarText, Modifier = Enum.StudioStyleGuideModifier.Default, Color = Color3.fromRGB(187, 187, 182),},
	}

	ThemeData.AnimationEditorStyleMap =
	{
		Data = ThemeData.DataStyleMap,
		Text = ThemeData.TextStyleMap,
		Scroll = ThemeData.ScrollStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.RoundedButton]] = ThemeData.RoundedButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.RoundedBorder]] = ThemeData.RoundedBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.EndButton]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.NextButton]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.PlayButton]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.PreviousButton]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.StartButton]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.PauseButton]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.HierarchyClosed]] = ThemeData.HierarchyIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.HierarchyOpened]] = ThemeData.HierarchyIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.LockButton]] = ThemeData.LockIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.LoopButton]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.CloseButton]] = ThemeData.CloseIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.RadioBackground]] = ThemeData.RadioButtonBackgroundStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.RadioDefault]] = ThemeData.RadioButtonBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.RadioInner]] = ThemeData.RadioButtonInnerStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.ZoomButton]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.Checkmark]] = ThemeData.IconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.Slash]] = ThemeData.IconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeyBorder]] = ThemeData.KeyIconBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeyIndicatorBorder]] = ThemeData.KeyIconBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeyIndicatorInner]] = ThemeData.KeyIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeyIndicatorSelectedBorder]] = ThemeData.KeyIconSelectedBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeyIndicatorSelectedInner]] = ThemeData.KeyIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeyInner]] = ThemeData.KeyIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeySelectedBorder]] = ThemeData.KeyIconSelectedBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.KeySelectedInner]] = ThemeData.KeyIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.ScrubberHead]] = ThemeData.ScrubberHeadStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.DownArrow]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.UpArrow]] = ThemeData.ControlButtonStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.ScaleArrows]] = ThemeData.ScaleArrowsStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.ScaleArrowsBorder]] = ThemeData.ScaleArrowsBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.TimeTag]] = ThemeData.TimeTagStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.TimeTagBorder]] = ThemeData.TimeTagBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.PinIcon]] = ThemeData.LockIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.HierarchyEnd]] = ThemeData.IconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.Collapse]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.DeleteEvent]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.EditEvent]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.Expand]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.Manage]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.RemoveEvent]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.Search]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.GroupMarkerBorderSelected]] = ThemeData.KeyIconSelectedBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.GroupMarkerBorder]] = ThemeData.KeyIconBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.GroupMarkerInner]] = ThemeData.EventIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.MarkerBorderSelected]] = ThemeData.KeyIconSelectedBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.MarkerBorder]] = ThemeData.KeyIconBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.MarkerInner]] = ThemeData.EventIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.MarkerMin]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.AddEventBorder]] = ThemeData.KeyIconBorderStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.AddEventInner]] = ThemeData.ZoomIconStyleMap,
		[ThemeData.Images[ThemeData.ColorAndImageNamesMap.ClearText]] = ThemeData.ZoomIconStyleMap,
	}
end

function ThemeData:terminate()
	self.ColorAndImageNamesMap = nil
	self.KeyNamesMap = nil
	self.AnimationEditorColorNamesToThemeColorAndImageNamesMap = nil
	self.OriginalColors = nil
end

return ThemeData