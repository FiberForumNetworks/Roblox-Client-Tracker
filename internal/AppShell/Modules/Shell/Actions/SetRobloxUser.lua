local CoreGui = Game:GetService("CoreGui")
local Action = require(CoreGui.RobloxGui.Modules.Common.Action)

return Action("SetRobloxUser", function(userInfo)
	return {
		robloxName = userInfo.robloxName,
		rbxuid = userInfo.rbxuid,
		under13 = userInfo.under13
	}
end)