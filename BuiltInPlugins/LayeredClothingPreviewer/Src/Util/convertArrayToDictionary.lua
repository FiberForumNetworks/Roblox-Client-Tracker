--[[
	this function means you can declare the table like this:

	local myProps = convertArrayToDictionary({
		"HatAccessory",
		"HeightScale"
	})

	and use it like this

	local name = myProps.HatAccessory

	Usually, you'd need to declare it like this, which has the problem of writing
	each string twice, where a typo could cause a bug:

	local myProps = {
		["HatAccessory"] = "HatAccessory",
		["HeightScale"] = "HeightSccle"
	})
]]

local function convertArrayToDictionary(sourceArray)
	local result = {}
	for _, key in ipairs(sourceArray) do
		if result[key] ~= nil then
			error("convertArrayToDictionary: sourceArray should not contain duplicate values")
		else
			result[key] = key
		end
	end
	return result
end

return convertArrayToDictionary
