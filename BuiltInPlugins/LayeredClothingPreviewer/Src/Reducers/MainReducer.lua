local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)

local HumanoidDescription = require(Plugin.Src.Reducers.HumanoidDescription)
local ScaleBoundaries = require(Plugin.Src.Reducers.ScaleBoundaries)

local MainReducer = Rodux.combineReducers({
	HumanoidDescriptionState = HumanoidDescription,
	ScaleBoundariesState = ScaleBoundaries,
})

return MainReducer