--[[
	Holds onto the current hatId
]]

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

local HumanoidDescriptionReducer = Rodux.createReducer({
	overriddenProps = {}, -- which props are currently being overridden
	propValues = {}, -- values for props
},
{
	SetHumanoidDescriptionOverride = function(state, action)
		local propValues = Cryo.Dictionary.join(state.propValues, {
			[action.prop] = action.doOverride and action.newValue or nil
		})

		local overriddenProps = Cryo.Dictionary.join(state.overriddenProps, {
			[action.prop] = action.doOverride
		})

		return Cryo.Dictionary.join(state, {
			propValues = propValues,
			overriddenProps = overriddenProps,
		})
	end,
})

return HumanoidDescriptionReducer