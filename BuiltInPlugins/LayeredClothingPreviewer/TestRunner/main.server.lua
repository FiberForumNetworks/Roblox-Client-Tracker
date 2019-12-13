if not game:DefineFastFlag("LayeredClothingPreviewer", false) then
	return
end

if not plugin then
	return
end

-- libraries
local Plugin = script.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)
local UILibrary = require(Plugin.Packages.UILibrary)
local MainView = require(Plugin.Src.Components.MainView)

-- components
local ServiceWrapper = require(Plugin.Src.Components.ServiceWrapper)

-- data
local MainReducer = require(Plugin.Src.Reducers.MainReducer)

-- theme
local PluginTheme = require(Plugin.Src.Resources.PluginTheme)

-- localization
local TranslationDevelopmentTable = Plugin.Src.Resources.TranslationDevelopmentTable
local TranslationReferenceTable = Plugin.Src.Resources.TranslationReferenceTable
local Localization = UILibrary.Studio.Localization

local pluginName = "LayeredClothingPreviewer"

-- Plugin Specific Globals
local theme = PluginTheme.new()
local localization = Localization.new({
	stringResourceTable = TranslationDevelopmentTable,
	translationResourceTable = TranslationReferenceTable,
	pluginName = pluginName,
})

-- Widget Gui Elements
local pluginHandle
local pluginGui

-- Fast flags

--Initializes and populates the plugin popup window
local function openPluginWindow()
	if pluginHandle then
		warn("Plugin handle already exists")
		return
	end

	-- create the roact tree
	local servicesProvider = Roact.createElement(ServiceWrapper, {
		plugin = plugin,
		localization = localization,
		theme = theme,
		store = Rodux.Store.new(MainReducer, {
		}, {
			Rodux.thunkMiddleware
		}),
	}, {
		MainView = Roact.createElement(MainView),
	})

	pluginHandle = Roact.mount(servicesProvider, pluginGui)
end

local function closePluginWindow()
	if pluginHandle then
		Roact.unmount(pluginHandle)
		pluginHandle = nil
	end
end

local function toggleWidget()
	pluginGui.Enabled = not pluginGui.Enabled
end


--Binds a toolbar button
local function main()
	plugin.Name = pluginName
	local pluginTitle = localization:getText("Meta", "PluginName")

	local toolbar = plugin:CreateToolbar(localization:getText("Meta", "ToolbarName"))
	local exampleButton = toolbar:CreateButton(
		localization:getText("Meta", "PluginButtonInspect"),
		localization:getText("Meta", "PluginButtonInspectTooltip"),
		theme.values.PluginTheme.Icons.ToolbarIcon
	)

	exampleButton.Click:connect(toggleWidget)

	local function showIfEnabled()
		if pluginGui.Enabled then
			openPluginWindow()
		else
			closePluginWindow()
		end

		-- toggle the plugin UI
		exampleButton:SetActive(pluginGui.Enabled)
	end

	-- create the plugin
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Left,  -- Widget will be initialized docked to the left
		false,   -- Widget will be initially disabled
		false,  -- Don't override the previous enabled state
		640,    -- Default width of the floating window
		480,    -- Default height of the floating window
		320,    -- Minimum width of the floating window (optional)
		240     -- Minimum height of the floating window (optional)
	)
	pluginGui = plugin:CreateDockWidgetPluginGui(pluginTitle, widgetInfo)
	pluginGui.Name = plugin.Name
	pluginGui.Title = pluginTitle
	pluginGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	pluginGui:GetPropertyChangedSignal("Enabled"):connect(showIfEnabled)

	-- configure the widget and button if its visible
	showIfEnabled()
end

main()