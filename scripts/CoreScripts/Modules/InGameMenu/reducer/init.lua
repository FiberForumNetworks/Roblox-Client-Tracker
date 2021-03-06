local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local Cryo = InGameMenuDependencies.Cryo

local InGameMenu = script.Parent

local SetMenuOpen = require(InGameMenu.Actions.SetMenuOpen)
local SetCurrentPage = require(InGameMenu.Actions.SetCurrentPage)
local StartLeavingGame = require(InGameMenu.Actions.StartLeavingGame)
local CancelLeavingGame = require(InGameMenu.Actions.CancelLeavingGame)
local SetControlLayout = require(InGameMenu.Actions.SetControlLayout)

local respawn = require(script.respawn)
local invites = require(script.invites)
local localization = require(script.localization)
local report = require(script.report)
local friends = require(script.friends)
local displayOptions = require(script.displayOptions)

local Constants = require(InGameMenu.Resources.Constants)
local Controls = require(InGameMenu.Resources.Controls)

local topLevelHandlers = {
	[SetMenuOpen.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			isMenuOpen = action.isMenuOpen,
		})
	end,
	[StartLeavingGame.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			leavingGame = true,
		})
	end,
	[CancelLeavingGame.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			leavingGame = false,
		})
	end,
	[SetCurrentPage.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			menuPage = action.newPage,
		})
	end,
	[SetControlLayout.name] = function(state, action)
		local controlLayout = action.controlLayout

		return Cryo.Dictionary.join(state, {
			controlLayout = controlLayout,
		})
	end
}

local function reducer(state, action)
	if state == nil then
		state = {
			controlLayout = Controls.ControlLayouts.KEYBOARD,
			isMenuOpen = false,
			leavingGame = false,
			menuPage = Constants.defaultPageKey,
			invites = invites(nil, action),
			respawn = respawn(nil, action),
			localization = localization(nil, action),
			friends = friends(nil, action),
			displayOptions = displayOptions(nil, action),
		}
	end

	local topLevelHandler = topLevelHandlers[action.type]
	if topLevelHandler ~= nil then
		state = topLevelHandler(state, action)
	end

	state.respawn = respawn(state.respawn, action)
	state.invites = invites(state.invites, action)
	state.localization = localization(state.localization, action)
	state.report = report(state.report, action)
	state.friends = friends(state.friends, action)
	state.displayOptions = displayOptions(nil, action)

	return state
end

return reducer