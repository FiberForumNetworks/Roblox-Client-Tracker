local Plugin = script.parent.parent.parent

local UILibrary = require(Plugin.Packages.UILibrary)
local StudioTheme = UILibrary.Studio.Theme
local StudioStyle = UILibrary.Studio.Style

local Cryo = require(Plugin.Packages.Cryo)

local Theme = {}

local DarkTheme = "Dark"

-- getColor : function<Color3>(color enum)
-- c = Enum.StudioStyleGuideColor
-- m = Enum.StudioStyleGuideModifier
function Theme.createValues(getColor, c, m)
	-- define the color palette for the UILibrary, override where necessary
	local UILibraryStylePalette = StudioStyle.new(getColor, c, m)

	local theme = settings().Studio.Theme
	local function defineTheme(defaults, overrides)
		local override = overrides and overrides[theme.Name]
		if override then
			return Cryo.Dictionary.join(defaults, override)
		else
			return defaults
		end
	end

	local ColorWhite = Color3.new(1, 1, 1)
	local ColorBlueDisabled = Color3.fromRGB(153, 218, 255)

	-- define all the colors used in the plugin
	local PluginTheme = {
		Icons = {
			ToolbarIcon = "rbxasset://textures/LayeredClothingPreviewer/LayeredClothingPreviewerIcon.png",
		},

		backgroundColor = getColor(c.MainBackground),

		Labels = {
			TitleBarText = getColor(c.TitlebarText, m.Default),
			TitleBarBackground = getColor(c.Titlebar, m.Default),
		},

		DefaultButton = defineTheme({
			ButtonColor = getColor(c.CurrentMarker),
			ButtonColor_Hover = getColor(c.LinkText),
			ButtonColor_Disabled = ColorBlueDisabled,
			TextColor = ColorWhite,
			TextColor_Disabled = ColorWhite,
			BorderColor = getColor(c.Light),
		}, {
			[DarkTheme] = {
				ButtonColor = getColor(c.MainButton),
				ButtonColor_Disabled = getColor(c.Button, m.Disabled),
				TextColor_Disabled = getColor(c.ButtonText, m.Disabled),
			},
		}),

		Text = {
			MediumSize = 16,
			LargeSize = 18,
			Font = Enum.Font.SourceSans
		},

		Slider = defineTheme({
			BarImage = "rbxasset://textures/LayeredClothingPreviewer/slider_bar.png",
			SliderHandleImage = "rbxasset://textures/LayeredClothingPreviewer/slider_handle_light.png",
			BarBackgroundColor = getColor(c.CheckedFieldBackground, m.Pressed),
			BarForegroundColor = getColor(c.CheckedFieldBackground, m.Selected),
			TextColor = getColor(c.SubText),
			TextDescriptionColor = getColor(c.DimmedText)
		}, {
			[DarkTheme] = {
				SliderHandleImage = "rbxasset://textures/LayeredClothingPreviewer/slider_handle_dark.png",
				BarForegroundColor = getColor(c.CheckedFieldIndicator, m.Selected),
			},
		}),
	}

	-- define any custom changes to UILibrary elements, use UILibrary's createTheme path syntax
	local UILibraryOverrides = {
		treeView = {
			elementPadding = 0,
		},
		textBox = defineTheme({
			borderHover = getColor(c.CurrentMarker)
		}, {
			[DarkTheme] = {
				borderHover = getColor(c.MainButton),
			},
		})
	}

	return {
		PluginTheme = PluginTheme,
		UILibraryStylePalette = UILibraryStylePalette,
		UILibraryOverrides = UILibraryOverrides,
	}
end

function Theme.new()
	return StudioTheme.new(Theme.createValues)
end

function Theme.mock()
	return StudioTheme.newDummyTheme(Theme.createValues)
end

return Theme