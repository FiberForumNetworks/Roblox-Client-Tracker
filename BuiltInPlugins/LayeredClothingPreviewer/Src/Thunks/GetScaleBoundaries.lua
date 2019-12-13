--[[
	Fetch the avatar scale boundaries
]]

local Plugin = script.Parent.Parent.Parent
local WebAPI = require(Plugin.Src.Util.WebAPI)

local SetScaleBoundaries = require(Plugin.Src.Actions.SetScaleBoundaries)

return function()
	return function(store)
		coroutine.wrap(function()
			local status, avatarRulesData = WebAPI.GetAvatarRulesData()
			if status ~= WebAPI.Status.OK then
				warn("GetScaleBoundaries failure in GetAvatarRulesData()")
				return
			end

			if avatarRulesData and avatarRulesData.scales then
				store:dispatch(SetScaleBoundaries(avatarRulesData.scales))
			else
				warn("GetScaleBoundaries failure in GetAvatarRulesData() as result avatar rules data is nil")
			end
		end)()
	end
end