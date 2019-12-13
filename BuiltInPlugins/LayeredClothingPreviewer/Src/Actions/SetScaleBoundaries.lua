--[[
	Fired when the scale boundaries are being set
]]

local Plugin = script.Parent.Parent.Parent

local Action = require(Plugin.Packages.Action)

return Action(script.Name, function(scaleBoundaries)
	assert(type(scaleBoundaries) == "table",
		string.format("Expected scaleBoundaries to be a table, received %s", tostring(scaleBoundaries)))

	return {
		scaleBoundaries = scaleBoundaries
	}
end)