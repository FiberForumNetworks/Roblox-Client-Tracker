--[[
	get the outfit HumanoidDescription from the bundle id
]]

local Players = game:GetService("Players")
local AssetService = game:GetService("AssetService")

local function tryGet(context, object, funcName, ...)
	local success, result = pcall(object[funcName], object, ...)

	if success then
		return result
	else
		warn("Invalid", context .. ':', ..., "(Error:", result .. ')')
	end
end

local function getOutfitId(bundleId)
	if bundleId > 0 then
		local info = tryGet("BundleId", AssetService, "GetBundleDetailsAsync", bundleId)
		if info then
			for _,item in pairs(info.Items) do
				if item.Type == "UserOutfit" then
					return item.Id
				end
			end
		end
	end
end

local function getOutfitHumanoidDescription(bundleId)
	local itemId = getOutfitId(bundleId)
	return (itemId and itemId > 0) and
		tryGet("Bundle", Players, "GetHumanoidDescriptionFromOutfitId", itemId) or
		Instance.new("HumanoidDescription")
end

return getOutfitHumanoidDescription