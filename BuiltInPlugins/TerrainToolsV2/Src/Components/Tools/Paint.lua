--[[
	Displays panels associated with the Paint tool
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local BaseBrush = require(Plugin.Src.Components.Tools.BaseBrush)

local Actions = Plugin.Src.Actions
local ApplyToolAction = require(Actions.ApplyToolAction)
local ChooseBrushShape = require(Actions.ChooseBrushShape)
local ChangeBaseSize = require(Actions.ChangeBaseSize)
local ChangeHeight = require(Actions.ChangeHeight)
local ChangePivot = require(Actions.ChangePivot)
local SetPlaneLock = require(Actions.SetPlaneLock)
local SetSnapToGrid = require(Actions.SetSnapToGrid)
local SetIgnoreWater = require(Actions.SetIgnoreWater)
local SetMaterial = require(Actions.SetMaterial)
local SetBaseSizeHeightLocked = require(Actions.SetBaseSizeHeightLocked)

local TerrainEnums = require(Plugin.Src.Util.TerrainEnums)

local FFlagTerrainToolsRefactor = game:GetFastFlag("TerrainToolsRefactor")

local REDUCER_KEY = "PaintTool"

local function mapStateToProps(state, props)
	return {
		toolName = TerrainEnums.ToolId.Paint,

		brushShape = state[REDUCER_KEY].brushShape,
		baseSize = state[REDUCER_KEY].baseSize,
		height = state[REDUCER_KEY].height,
		baseSizeHeightLocked = state[REDUCER_KEY].baseSizeHeightLocked,
		pivot = state[REDUCER_KEY].pivot,
		planeLock = state[REDUCER_KEY].planeLock,
		snapToGrid = state[REDUCER_KEY].snapToGrid,
		ignoreWater = state[REDUCER_KEY].ignoreWater,

		material = state[REDUCER_KEY].material,
	}
end

local function mapDispatchToProps(dispatch)
	local dispatchToPaint = function(action)
		dispatch(ApplyToolAction(REDUCER_KEY, action))
	end

	return {
		dispatchChooseBrushShape = function (shape)
			dispatchToPaint(ChooseBrushShape(shape))
		end,
		dispatchChangeBaseSize = function (size)
			dispatchToPaint(ChangeBaseSize(size))
		end,
		dispatchChangeHeight = function (height)
			dispatchToPaint(ChangeHeight(height))
		end,
		dispatchChangePivot = function (pivot)
			dispatchToPaint(ChangePivot(pivot))
		end,
		dispatchSetPlaneLock = function (planeLock)
			dispatchToPaint(SetPlaneLock(planeLock))
		end,
		dispatchSetSnapToGrid = function (snapToGrid)
			dispatchToPaint(SetSnapToGrid(snapToGrid))
		end,
		dispatchSetIgnoreWater = function (ignoreWater)
			dispatchToPaint(SetIgnoreWater(ignoreWater))
		end,
		dispatchSetMaterial = function (material)
			dispatchToPaint(SetMaterial(material))
		end,
		dispatchSetBaseSizeHeightLocked = function (locked)
			dispatchToPaint(SetBaseSizeHeightLocked(locked))
		end,
	}
end

if FFlagTerrainToolsRefactor then
	return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BaseBrush)
else
	local PaintTool = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BaseBrush)

	return function(props)
		return Roact.createElement(PaintTool)
	end
end
