--[[

]]

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

local Constants = require(Plugin.Src.Util.Constants)
local TerrainEnums = require(Plugin.Src.Util.TerrainEnums)
local BrushShape = TerrainEnums.BrushShape
local PivotType = TerrainEnums.PivotType

local AddTool = Rodux.createReducer({
	brushShape = BrushShape.Sphere,
	baseSize = Constants.INITIAL_BRUSH_SIZE,
	height = Constants.INITIAL_BRUSH_SIZE,
	baseSizeHeightLocked = true,
	pivot = PivotType.Center,
	snapToGrid = false,
	ignoreWater = false,
	autoMaterial = false,
	material = Enum.Material.Grass,
}, {
	ChooseBrushShape = function(state, action)
		local brushShape = action.brushShape

		return Cryo.Dictionary.join(state, {
			brushShape = brushShape,
		})
	end,
	ChangeBaseSize = function(state, action)
		local baseSize = action.baseSize

		return Cryo.Dictionary.join(state, {
			baseSize = baseSize,
		})
	end,
	ChangeHeight = function(state, action)
		local height = action.height

		return Cryo.Dictionary.join(state, {
			height = height,
		})
	end,
	ChangePivot = function(state, action)
		local pivot = action.pivot

		return Cryo.Dictionary.join(state, {
			pivot = pivot,
		})
	end,
	SetSnapToGrid = function(state, action)
		local snapToGrid = action.snapToGrid

		return Cryo.Dictionary.join(state, {
			snapToGrid = snapToGrid,
		})
	end,
	SetAutoMaterial = function(state, action)
		local autoMaterial = action.autoMaterial

		return Cryo.Dictionary.join(state, {
			autoMaterial = autoMaterial,
		})
	end,
	SetIgnoreWater = function(state, action)
		local ignoreWater = action.ignoreWater

		return Cryo.Dictionary.join(state, {
			ignoreWater = ignoreWater,
		})
	end,
	SetMaterial = function(state, action)
		local material = action.material
		return Cryo.Dictionary.join(state, {
			material = material,
		})
	end,
	SetBaseSizeHeightLocked = function(state, action)
		local locked = action.locked
		return Cryo.Dictionary.join(state, {
			baseSizeHeightLocked = locked,
		})
	end,
})

return AddTool
