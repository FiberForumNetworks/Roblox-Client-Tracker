local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local Symbol = require(Plugin.Packages.Symbol)

local pluginThemeKey = Symbol.named("PluginTheme")

local PluginThemeProvider = Roact.PureComponent:extend("PluginThemeProvider")

-- self.props.theme : (table)
--	Theme is expected to be a PluginTheme object. This is an extension of the UILibrary/Studio/StudioTheme object.
--	This object creates a symantic mapping of Studio enum colors to human-readable names
function PluginThemeProvider:init()
	local pluginTheme = self.props.theme
	assert(pluginTheme ~= nil, "No theme was given to this PluginThemeProvider.")

	self._context[pluginThemeKey] = pluginTheme
end

function PluginThemeProvider:render()
	self._context[pluginThemeKey] = self.props.theme
	return Roact.oneChild(self.props[Roact.Children])
end



-- the consumer should complain if it doesn't have a theme
local PluginThemeConsumer = Roact.PureComponent:extend("PluginThemeConsumer")
function PluginThemeConsumer:init()
	assert(self._context[pluginThemeKey] ~= nil, "No PluginThemeProvider found.")
	local pluginTheme = self._context[pluginThemeKey]

	self.state = {
		themeValues = pluginTheme.values,
	}

	-- observe any changes and force a re-render
	self.themeConnection = pluginTheme:connect(function(newValues)
		self:setState({
			themeValues = newValues,
		})
	end)
end

function PluginThemeConsumer:render()
	local tv = self.state.themeValues
	return self.props.themedRender(tv.PluginTheme, tv.UILibraryStylePalette, tv.UILibraryOverrides)
end

function PluginThemeConsumer:willUnmount()
	if self.themeConnection then
		self.themeConnection:disconnect()
	end
end



-- withTheme should provide a simple way to style elements
-- callback : function<RoactElement>(theme)
local function withTheme(callback)
	return Roact.createElement(PluginThemeConsumer, {
		themedRender = callback
	})
end


return {
	Provider = PluginThemeProvider,
	Consumer = PluginThemeConsumer,
	withTheme = withTheme,
}