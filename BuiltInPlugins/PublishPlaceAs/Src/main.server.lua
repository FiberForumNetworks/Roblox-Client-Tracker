if not plugin then
	return
end

-- Fast flags
local FFlagPublishPlaceToRobloxLuaPlugin = settings():GetFFlag("PublishPlaceToRobloxLuaPlugin")

if not FFlagPublishPlaceToRobloxLuaPlugin then
	return
end

-- libraries
local Plugin = script.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)
local UILibrary = require(Plugin.Packages.UILibrary)

-- components
local ServiceWrapper = require(Plugin.Src.Components.ServiceWrapper)
local ScreenSelect = require(Plugin.Src.Components.ScreenSelect)

-- data
local MainReducer = require(Plugin.Src.Reducers.MainReducer)
local MainMiddleware = require(Plugin.Src.Middleware.MainMiddleware)
local ResetInfo = require(Plugin.Src.Actions.ResetInfo)

-- theme
local PluginTheme = require(Plugin.Src.Resources.PluginTheme)

-- localization
local TranslationDevelopmentTable = Plugin.Src.Resources.TranslationDevelopmentTable
local TranslationReferenceTable = Plugin.Src.Resources.TranslationReferenceTable
local Localization = UILibrary.Studio.Localization

-- Plugin Specific Globals
local StudioService = game:GetService("StudioService")
local dataStore = Rodux.Store.new(MainReducer, {}, MainMiddleware)
local theme = PluginTheme.new()
local localization = Localization.new({
	stringResourceTable = TranslationDevelopmentTable,
	translationResourceTable = TranslationReferenceTable,
	pluginName = "PublishPlaceAs",
})

-- Widget Gui Elements
local pluginHandle
local pluginGui

local function closePlugin()
	if pluginHandle then
		Roact.unmount(pluginHandle)
		pluginHandle = nil
	end
	pluginGui.Enabled = false
end

local function makePluginGui()
	pluginGui = plugin:CreateQWidgetPluginGui(plugin.Name, {
		Size = Vector2.new(960, 650),
		MinSize = Vector2.new(960, 650),
		Resizable = false,
		Modal = true,
		InitialEnabled = false,
	})
	pluginGui.Name = plugin.Name
	pluginGui.Title = plugin.Name
	pluginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	pluginGui:BindToClose(function()
		closePlugin()
	end)
end

--Initializes and populates the plugin popup window
local function openPluginWindow()
	if pluginHandle then
		warn("Plugin handle already exists")
		return
	end

	local servicesProvider = Roact.createElement(ServiceWrapper, {
		plugin = plugin,
		localization = localization,
		theme = theme,
		focusGui = pluginGui,
		store = dataStore,
	}, {
		Roact.createElement(ScreenSelect, {
			OnClose = closePlugin,
		})
	})

	dataStore:dispatch(ResetInfo())
	pluginHandle = Roact.mount(servicesProvider, pluginGui)
	pluginGui.Enabled = true
end

local function main()
	plugin.Name = localization:getText("General", "PublishPlace")
	makePluginGui()

	StudioService.OnPublishPlaceToRoblox:Connect(function()
		openPluginWindow()
	end)
end

main()
