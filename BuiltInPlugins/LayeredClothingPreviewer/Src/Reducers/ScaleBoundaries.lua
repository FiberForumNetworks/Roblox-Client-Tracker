--[[
	Holds onto the current scale boundaries
]]

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)


local ScaleBoundariesReducer = Rodux.createReducer({
	scaleBoundaries = nil,
},
{
	SetScaleBoundaries = function(state, action)
		local scaleBoundaries = action.scaleBoundaries

		return Cryo.Dictionary.join(state, {
			scaleBoundaries = scaleBoundaries
		})
	end,
})

return ScaleBoundariesReducer