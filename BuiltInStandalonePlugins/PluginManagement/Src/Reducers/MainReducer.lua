local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)

local PluginInfo = require(Plugin.Src.Reducers.PluginInfo)
local PluginPermissions = require(Plugin.Src.Reducers.PluginPermissions)
local Management = require(Plugin.Src.Reducers.Management)

local MainReducer = Rodux.combineReducers({
	PluginInfo = PluginInfo,
	PluginPermissions = PluginPermissions,
	Management = Management,
})

return MainReducer