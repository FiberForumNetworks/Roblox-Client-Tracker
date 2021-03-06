local Plugin = script.Parent.Parent.Parent

local Constants = require(Plugin.Src.Util.Constants)
local UILibrary = require(Plugin.UILibrary)
local StudioTheme = UILibrary.Studio.Theme
local StudioStyle = UILibrary.Studio.Style

local Theme = {}

function Theme.isDarkerTheme()
	-- Assume "darker" theme if the average main background colour is darker
	local mainColour = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	return (mainColour.r + mainColour.g + mainColour.b) / 3 < 0.5
end

-- getColor : function<Color3>(getColor enum)
-- StyleColor = Enum.StudioStyleGuideColor
-- StyleModifier = Enum.StudioStyleGuideModifier
function Theme.createValues(getColor, StyleColor, StyleModifier)
	-- define the getColor palette for the UILibrary, override where necessary
	local UILibraryStylePalette = StudioStyle.new(getColor, StyleColor, StyleModifier)
	UILibraryStylePalette.backgroundColor = Color3.new(1, 0, 0)

	local isDark = Theme.isDarkerTheme()

	local fontStyle = {
		Title = {
			Font = Enum.Font.SourceSans,
			TextSize = 24,
			TextColor3 = getColor(StyleColor.TitlebarText),
		},
		Header = {
			Font = Enum.Font.SourceSans,
			TextSize = 24,
			TextColor3 = getColor(StyleColor.BrightText),
		},
		Subtitle = {
			Font = Enum.Font.SourceSans,
			TextSize = 22,
			TextColor3 = getColor(StyleColor.SubText),
		},
		Normal = {
			Font = Enum.Font.SourceSans,
			TextSize = 22,
			TextColor3 = getColor(StyleColor.MainText),
		},
		SemiBold = {
			Font = Enum.Font.SourceSansSemibold,
			TextSize = 22,
			TextColor3 = getColor(StyleColor.MainText),
		},
		Smaller = {
			Font = Enum.Font.SourceSans,
			TextSize = 20,
			TextColor3 = getColor(StyleColor.MainText),
		},
		Warning = {
			Font = Enum.Font.SourceSans,
			TextSize = 20,
			TextColor3 = getColor(StyleColor.WarningText),
		},
		Error = {
			Font = Enum.Font.SourceSans,
			TextSize = 20,
			TextColor3 = getColor(StyleColor.ErrorText),
		},
		Subtext = {
			Font = Enum.Font.SourceSans,
			TextSize = 16,
			TextColor3 = getColor(StyleColor.DimmedText),
		},
		SmallError = {
			Font = Enum.Font.SourceSans,
			TextSize = 16,
			TextColor3 = getColor(StyleColor.ErrorText),
		},
	}

	-- define all the colors used in the plugin
	local PluginTheme = {
		isDarkerTheme = isDark,
		
		fontStyle = fontStyle,

		backgroundColor = getColor(StyleColor.MainBackground),

		hyperlink = getColor(StyleColor.LinkText),
		warningColor = getColor(StyleColor.WarningText),

		separator = isDark and getColor(StyleColor.Border) or getColor(StyleColor.Titlebar),

		scrollBar = isDark and getColor(StyleColor.ScrollBar) or getColor(StyleColor.Border),
		scrollBarBackground = isDark and getColor(StyleColor.ScrollBarBackground) or Color3.fromRGB(245, 245, 245),

		menuBar = {
			backgroundColor = isDark and getColor(StyleColor.ScrollBarBackground) or getColor(StyleColor.MainBackground),
		},

		searchBar = {
			border = getColor(StyleColor.Border),
			borderHover = isDark and getColor(StyleColor.MainButton) or getColor(StyleColor.CurrentMarker),
			borderSelected = isDark and getColor(StyleColor.MainButton) or getColor(StyleColor.CurrentMarker),
			placeholderText = getColor(StyleColor.DimmedText),

			searchIcon = getColor(StyleColor.SubText),

			clearButton = {
				imageSelected = getColor(StyleColor.SubText),
				image = getColor(StyleColor.SubText),
			},

			dropDown = {
				backgroundColor = getColor(StyleColor.InputFieldBackground),
				itemText = getColor(StyleColor.MainText),
				headerText = getColor(StyleColor.SubText),

				hovered = {
					backgroundColor = getColor(StyleColor.Button, StyleModifier.Hover),
					itemText = getColor(StyleColor.ButtonText, StyleModifier.Hover),
				},

				selected = {
					backgroundColor = getColor(StyleColor.Button, StyleModifier.Selected),
				},
			},
		},

		menuEntry = {
			hover = isDark and getColor(StyleColor.CurrentMarker) or getColor(StyleColor.RibbonTab),
			highlight = isDark and getColor(StyleColor.TableItem, StyleModifier.Selected) or getColor(StyleColor.CurrentMarker),
			text = getColor(StyleColor.BrightText),
		},

		footer = {
			gradient = getColor(StyleColor.MainText),
		},

		textBox = {
			background = getColor(StyleColor.InputFieldBackground),
			disabled = getColor(StyleColor.Tab),
			borderDefault = getColor(StyleColor.Border),
			borderHover = isDark and getColor(StyleColor.MainButton) or getColor(StyleColor.CurrentMarker),
			tooltip = getColor(StyleColor.DimmedText),
			text = getColor(StyleColor.MainText),
		},

		radioButton = {
			background = getColor(StyleColor.InputFieldBackground),
			title = getColor(StyleColor.BrightText),
			description = getColor(StyleColor.DimmedText),
		},

		checkBox = {
			background = getColor(StyleColor.InputFieldBackground),
			title = getColor(StyleColor.BrightText),
		},

		dropDown = {
			background = getColor(StyleColor.Button),
			hover = getColor(StyleColor.Button, StyleModifier.Hover),
			text = getColor(StyleColor.BrightText),
			disabled = getColor(StyleColor.Tab),
			handle = getColor(StyleColor.MainText),
			border = getColor(StyleColor.Border),
			gradient = getColor(StyleColor.Dark)
		},

		dropDownEntry = {
			background = getColor(StyleColor.MainBackground),
			hover = isDark and getColor(StyleColor.CurrentMarker) or getColor(StyleColor.RibbonTab),
			highlight = isDark and getColor(StyleColor.TableItem, StyleModifier.Selected) or getColor(StyleColor.CurrentMarker),
			text = getColor(StyleColor.MainText),
		},

		dialog = {
			background = getColor(StyleColor.MainBackground),
			text = getColor(StyleColor.MainText),
		},

		subjectThumbnail = {
			background = getColor(StyleColor.TableItem),
		},

		thumbnail = {
			background = getColor(StyleColor.Dark),
			count = getColor(StyleColor.DimmedText),
		},

		newThumbnail = {
			background = getColor(StyleColor.TableItem),
			border = isDark and getColor(StyleColor.Dark) or getColor(StyleColor.Titlebar),
			plus = isDark and getColor(StyleColor.MainText) or getColor(StyleColor.DimmedText),
		},

		thumbnailDrag = {
			background = getColor(StyleColor.CurrentMarker, StyleModifier.Selected),
			border = getColor(StyleColor.CurrentMarker, StyleModifier.Selected),
		},

		cancelButton = {
			ButtonColor = getColor(StyleColor.Button),
			ButtonColor_Hover = getColor(StyleColor.Button, StyleModifier.Hover),
			ButtonColor_Disabled = getColor(StyleColor.Button, StyleModifier.Disabled),
			TextColor = getColor(StyleColor.MainText),
			TextColor_Disabled = getColor(StyleColor.DimmedText),
			BorderColor = getColor(StyleColor.Border),
		},

		defaultButton = {
			ButtonColor = isDark and getColor(StyleColor.MainButton) or getColor(StyleColor.CurrentMarker),
			ButtonColor_Hover = getColor(StyleColor.LinkText),
			ButtonColor_Disabled = isDark and getColor(StyleColor.Button, StyleModifier.Disabled) or Constants.BLUE_DISABLED,
			TextColor = Color3.new(1, 1, 1),
			TextColor_Disabled = isDark and getColor(StyleColor.ButtonText, StyleModifier.Disabled) or Color3.new(1, 1, 1),
			BorderColor = getColor(StyleColor.Light),
		},

		collaboratorItem = {
			collapseStateArrow = isDark and Color3.fromRGB(204, 204, 204) or Color3.fromRGB(25, 25, 25),
			deleteButton = isDark and Color3.fromRGB(136, 136, 136) or Color3.fromRGB(184, 184, 184),
		},

		table = {
			item = {
				background = getColor(StyleColor.TableItem)
			},
		},

		editButton = {
			image = "rbxasset://textures/GameSettings/edit.png",
			imageColor = isDark and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 25)
		}
	}

	-- define any custom changes to UILibrary elements, use UILibrary's createTheme path syntax
	local UILibraryOverrides = {
		button = {
			LargeHitboxButton = {
				backgroundColor = getColor(StyleColor.MainBackground, StyleModifier.Default),

				hovered = {
					backgroundColor = getColor(StyleColor.Button, StyleModifier.Hover),
				},
			},
		}
	}

	local StyleOverrides = {
		font = Enum.Font.SourceSans,

		backgroundColor = getColor(StyleColor.InputFieldBackground),
		textColor = getColor(StyleColor.MainText),
		subTextColor = getColor(StyleColor.SubText),
		dimmerTextColor = getColor(StyleColor.DimmedText),
		disabledColor = getColor(StyleColor.Tab),
		borderColor = getColor(StyleColor.Border),
		hoverColor = isDark and getColor(StyleColor.MainButton) or getColor(StyleColor.CurrentMarker),
		
		-- Dropdown item
		hoveredItemColor = getColor(StyleColor.Button, StyleModifier.Hover),
		hoveredTextColor = getColor(StyleColor.ButtonText, StyleModifier.Hover),
		
		-- Dropdown button
		selectionColor = getColor(StyleColor.Button, StyleModifier.Selected),
		selectedTextColor = getColor(StyleColor.ButtonText, StyleModifier.Selected),
		selectionBorderColor = getColor(StyleColor.ButtonBorder, StyleModifier.Selected),
		
		errorColor = getColor(StyleColor.ErrorText),

		hyperlinkTextColor = getColor(StyleColor.LinkText),
	}

	return {
		PluginTheme = PluginTheme,
		UILibraryStylePalette = StyleOverrides,
		UILibraryOverrides = UILibraryOverrides,
	}
end

function Theme.new()
	return StudioTheme.new(Theme.createValues)
end

function Theme.newDummyTheme()
	return StudioTheme.newDummyTheme(Theme.createValues)
end

return Theme