local Plugin = script.Parent.Parent.Parent.Parent

local Util = Plugin.Core.Util
local PreviewModelGetter = require(Util.PreviewModelGetter)

local SetPreviewModel = require(Plugin.Core.Actions.SetPreviewModel)

return function(assetId)
	return function(store)
		return PreviewModelGetter(assetId):andThen(function(result)
			if type(result) == "String" then
				-- failed to get the object
				store:dispatch(SetPreviewModel(nil))
			else
				store:dispatch(SetPreviewModel(result))
			end
		end)
	end
end
