local Plugin = script.Parent.Parent.Parent
local StudioService = game:GetService("StudioService")
local HttpService = game:GetService("HttpService")
local GetPluginInfoRequest = require(Plugin.Src.Thunks.GetPluginInfoRequest)
local MultiGetPluginInfoRequest = require(Plugin.Src.Thunks.MultiGetPluginInfoRequest)
local SetPluginInfo = require(Plugin.Src.Actions.SetPluginInfo)
local ClearAllPluginData = require(Plugin.Src.Actions.ClearAllPluginData)

local FFlagPluginManagementAllowLotsOfPlugins = settings():GetFFlag("PluginManagementAllowLotsOfPlugins")

local function extractPluginsFromJsonString(json)
	local success, decoded = xpcall(
		function()
			return HttpService:JSONDecode(json)
		end,
		function(_)
			return {}
		end
	)
	if not success then return {} end

	local result = {}
	for id, data in pairs(decoded) do
		local newEntry = {}
		newEntry.assetId = id
		newEntry.enabled = data.Enabled
		newEntry.installedVersion = data.AssetVersion
		newEntry.isModerated = data.Moderated
		result[#result+1] = newEntry
	end
	return result
end

return function(apiImpl, marketplaceService)
	return function(store)
		local plugins = extractPluginsFromJsonString(StudioService.InstalledPluginData)
		local assetIds = {}
		for index, data in pairs(plugins) do
			plugins[index].assetId = tonumber(data.assetId)
			assetIds[#assetIds+1] = data.assetId
		end

		if FFlagPluginManagementAllowLotsOfPlugins then
			store:dispatch(ClearAllPluginData())
			if #assetIds > 0 then
				store:dispatch(MultiGetPluginInfoRequest(apiImpl, marketplaceService, assetIds, plugins))
			end
		else
			if #assetIds > 0 then
				store:dispatch(GetPluginInfoRequest(apiImpl, assetIds, plugins))
			else
				store:dispatch(SetPluginInfo({}, {}))
			end
		end
	end
end