--[[
	Fired when any HumanoidDescription override values need to change
]]

local Plugin = script.Parent.Parent.Parent

local Action = require(Plugin.Packages.Action)

local HumanoidDescriptionProps = require(Plugin.Src.Util.Constants.HumanoidDescriptionProps)

return Action(script.Name, function(prop, doOverride, newValue)
	assert(HumanoidDescriptionProps[prop] ~= nil,
		string.format("%s is not a valid HumanoidDescription prop", tostring(prop)))
	assert("boolean" == type(doOverride),
		string.format("Expected doOverride to be a boolean, received %s", type(doOverride)))

	return {
		prop = prop,
		doOverride = doOverride,
		newValue = newValue
	}
end)