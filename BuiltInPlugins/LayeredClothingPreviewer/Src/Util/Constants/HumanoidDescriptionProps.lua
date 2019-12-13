--[[
	The names of the props in a HumanoidDescription (not an exhaustive list, just those props used in this plugin)
]]

local Plugin = script.Parent.Parent.Parent.Parent
local convertArrayToDictionary = require(Plugin.Src.Util.convertArrayToDictionary)

local HumanoidDescriptionProps = convertArrayToDictionary({
	"HatAccessory",
	"HeightScale",
	"WidthScale",
	"HeadScale",
	"ProportionScale",
	"BodyTypeScale",
})

return HumanoidDescriptionProps