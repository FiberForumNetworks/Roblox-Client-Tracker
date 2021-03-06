local Plugin = script.Parent.Parent.Parent
local UILibrary = Plugin.Packages.UILibrary
local Signal = require(UILibrary.Utils.Signal)
local Cryo = require(Plugin.Packages.Cryo)

local Constants = require(Plugin.Src.Util.Constants)
local TerrainEnums = require(Plugin.Src.Util.TerrainEnums)
local BrushShape = TerrainEnums.BrushShape
local FlattenMode = TerrainEnums.FlattenMode
local PivotType = TerrainEnums.PivotType
local ToolId = TerrainEnums.ToolId

local quickWait = require(Plugin.Src.Util.quickWait)

local TerrainBrushCursor = require(Plugin.Src.TerrainWorldUI.TerrainBrushCursor)
local TerrainBrushCursorGrid = require(Plugin.Src.TerrainWorldUI.TerrainBrushCursorGrid)

local performTerrainBrushOperation = require(Plugin.Src.TerrainOperations.performTerrainBrushOperation)

local AnalyticsService = game:GetService("RbxAnalyticsService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Players = game:GetService("Players")
local StudioService = game:GetService("StudioService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

game:DefineFastFlag("TerrainToolsBrushOnlyUndoWhenDirty", false)
game:DefineFastFlag("TerrainToolsFixAutoMaterial", false)
game:DefineFastFlag("TerrainToolsFixFlattenToolPlanePosition", false)
game:DefineFastFlag("TerrainToolsBrushUseIsKeyDown", false)

local FFlagTerrainToolMetrics = settings():GetFFlag("TerrainToolMetrics")
local FFlagTerrainToolsBrushOnlyUndoWhenDirty = game:GetFastFlag("TerrainToolsBrushOnlyUndoWhenDirty")
local FFlagTerrainToolsFixAutoMaterial = game:GetFastFlag("TerrainToolsFixAutoMaterial")
local FFlagTerrainToolsFixFlattenToolPlanePosition = game:GetFastFlag("TerrainToolsFixFlattenToolPlanePosition")
local FFlagTerrainToolsBrushUseIsKeyDown = game:GetFastFlag("TerrainToolsBrushUseIsKeyDown")

local CLICK_THRESHOLD = 0.1

local function lineToPlaneIntersection(linePoint, lineDirection, planePoint, planeNormal)
	local denominator = lineDirection:Dot(planeNormal)
	if denominator == 0 then
		return linePoint
	end
	local distance = (planePoint - linePoint):Dot(planeNormal) / denominator
	return linePoint + lineDirection * distance
end

local function round(n)
	return math.floor(n + 0.5)
end

local function getCameraLookSnappedForPlane()
	local camera = Workspace.CurrentCamera
	local lookVector = camera.CoordinateFrame.lookVector
	return Vector3.new(round(lookVector.x), round(lookVector.y), round(lookVector.z)).unit
end

local function isShiftKeyDown()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

local function isCtrlKeyDown()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
end

local function isAltKeyDown()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
end

local TerrainBrush = {}
TerrainBrush.__index = TerrainBrush

function TerrainBrush.new(options)
	assert(options and type(options) == "table", "TerrainBrush requires an options table")

	local self = setmetatable({
		_terrain = options.terrain,
		_mouse = options.mouse,

		_operationSettings = {
			currentTool = ToolId.None,
			brushShape = BrushShape.Sphere,

			cursorSize = Constants.INITIAL_BRUSH_SIZE,
			cursorHeight = Constants.INITIAL_BRUSH_SIZE,
			strength = Constants.INITIAL_BRUSH_STRENGTH,
			centerPoint = Vector3.new(0, 0, 0),

			material = Enum.Material.Grass,
			autoMaterial = false,

			flattenMode = FlattenMode.Both,
			pivot = PivotType.Center,

			ignoreWater = true,
			planeLock = false,
			fixedPlane = false,
			snapToGrid = false,
			heightPicker = false,

			planePositionY = Constants.INITIAL_PLANE_POSITION_Y,
		},

		_isRunning = false,
		_currentLoopTag = nil,

		_mouseDown = false,
		_mouseClick = false,
		_downKeys = not FFlagTerrainToolsBrushUseIsKeyDown and {} or nil,
		_connections = {},

		_cursor = TerrainBrushCursor.new(options.terrain),
		_cursorGrid = TerrainBrushCursorGrid.new(),

		-- Set in :_run(), used for positioning cursor part and grid
		_cursorTargetLocation = Vector3.new(0, 0, 0),
		_lastNormal = Vector3.new(0, 1, 0),

		_planePositionYChanged = Signal.new(),
		_heightPickerSet = Signal.new(),
		_requestBrushSizeChanged = Signal.new(),
		_requestBrushStrengthChanged = Signal.new(),
		_materialSelectRequested = Signal.new(),

		_isTerrainDirty = false,
	}, TerrainBrush)

	assert(self._terrain, "TerrainBrush needs a terrain instance")
	assert(self._mouse, "TerrainBrush needs a mouse instance")

	return self
end

function TerrainBrush:destroy()
	self:stop()
end

function TerrainBrush:subscribeToPlanePositionYChanged(...)
	return self._planePositionYChanged:connect(...)
end

function TerrainBrush:subscribeToHeightPickerSet(...)
	return self._heightPickerSet:connect(...)
end

function TerrainBrush:subscribeToRequestBrushSizeChanged(...)
	return self._requestBrushSizeChanged:connect(...)
end

function TerrainBrush:subscribeToRequestBrushStrengthChanged(...)
	return self._requestBrushStrengthChanged:connect(...)
end

function TerrainBrush:subscribeToMaterialSelectRequested(...)
	return self._materialSelectRequested:connect(...)
end

function TerrainBrush:updateSettings(newSettings)
	self._operationSettings = Cryo.Dictionary.join(self._operationSettings, newSettings)
	self:_updateCursor()
end

function TerrainBrush:startWithTool(newTool)
	if FFlagTerrainToolsFixAutoMaterial then
		self:updateSettings({
			currentTool = newTool,

			-- The flatten tool requires autoMaterial to be true
			-- Else just use what's already there
			autoMaterial = newTool == ToolId.Flatten
				or self._operationSettings.autoMaterial,
		})
	else
		self:updateSettings({
			currentTool = newTool,
			autoMaterial = newTool == ToolId.Flatten,
		})
	end

	if newTool == ToolId.None then
		self:stop()
		return
	end

	if self._isRunning then
		return
	end
	self._isRunning = true

	self:_connectInput()
	self:_run()
end

function TerrainBrush:stop()
	if FFlagTerrainToolsBrushOnlyUndoWhenDirty then
		self:_saveChanges()
	end
	if not self._isRunning then
		return
	end
	self._currentLoopTag = nil

	self._mouseDown = false
	self._mouseClick = false
	if not FFlagTerrainToolsBrushUseIsKeyDown then
		self._downKeys = {}
	end
	self:_disconnectAllConnections()

	self:_destroyCursor()

	self._isRunning = false
end

function TerrainBrush:_updateCursor()
	if TerrainBrushCursor.isVisibleForOperation(self._operationSettings) then
		self._cursor:maybeCreate()
		self._cursor:update({
			size = self._operationSettings.cursorSize,
			height = self._operationSettings.cursorHeight,
			strength = self._operationSettings.strength,
			location = self._cursorTargetLocation,
			shape = self._operationSettings.brushShape,
			pivot = self._operationSettings.pivot,
			mouseDown = self._mouseDown,
		})
	else
		self._cursor:hide()
	end

	if TerrainBrushCursorGrid.isVisibleForOperation(self._operationSettings) then
		self._cursorGrid:maybeCreate()
		self._cursorGrid:update({
			currentTool = self._operationSettings.currentTool,
			cursorSize = self._operationSettings.cursorSize,

			fixedPlane = self._operationSettings.fixedPlane,
			planeLock = self._operationSettings.planeLock,
			planePositionY = self._operationSettings.planePositionY,
			heightPicker = self._operationSettings.heightPicker,

			mouseDown = self._mouseDown,

			mainPoint = self._cursorTargetLocation,
			lastNormal = self._lastNormal,
		})
	else
		self._cursorGrid:hide()
	end
end

function TerrainBrush:_destroyCursor()
	self._cursor:destroy()
	self._cursorGrid:destroy()
end

function TerrainBrush:_disconnectAllConnections()
	for _, connection in pairs(self._connections) do
		connection:Disconnect()
	end
	self._connections = {}
end

function TerrainBrush:_saveChanges()
	if self._isTerrainDirty then
		ChangeHistoryService:SetWaypoint("Terrain " .. self._operationSettings.currentTool)
		self._isTerrainDirty = false
	end
end

function TerrainBrush:_connectInput()
	local function connectHelper(event, func)
		if self._connections[event] then
			self._connections[event]:Disconnect()
		end

		self._connections[event] = event:Connect(func)
	end

	connectHelper(UserInputService.InputBegan, function(event, soaked)
		if not FFlagTerrainToolsBrushUseIsKeyDown then
			self._downKeys[event.KeyCode] = true
		end

		if event.UserInputType == Enum.UserInputType.MouseButton1 and not soaked and self._isRunning then
			self._mouseDown = true
			self._mouseClick = true
		end
	end)

	connectHelper(UserInputService.InputEnded, function(event, soaked)
		if not FFlagTerrainToolsBrushUseIsKeyDown then
			self._downKeys[event.KeyCode] = nil
		end

		if event.UserInputType == Enum.UserInputType.MouseButton1 and self._mouseDown then
			self._mouseDown = false

			if FFlagTerrainToolsBrushOnlyUndoWhenDirty then
				self:_saveChanges()
			else
				ChangeHistoryService:SetWaypoint("Terrain " .. self._operationSettings.currentTool)
			end
		end
	end)

	if not FFlagTerrainToolsBrushUseIsKeyDown then
		connectHelper(UserInputService.WindowFocusReleased, function()
			self._downKeys = {}
		end)
	end

	local function handleScrollWheel(direction)
		local shiftDown
		if FFlagTerrainToolsBrushUseIsKeyDown then
			shiftDown = isShiftKeyDown()
		else
			shiftDown = self._downKeys[Enum.KeyCode.LeftShift] or self._downKeys[Enum.KeyCode.RightShift]
		end
		if shiftDown then
			local scalingChange = direction / 10

			local sizeGrow = self._operationSettings.cursorSize * scalingChange
			local heightGrow = self._operationSettings.cursorHeight * scalingChange

			-- If the amount we grow by is less than 1, then it's possible we'll get stuck at a position
			-- e.g. If cursorSize = 2, sizeGrow = 0.2, round(cursorSize + sizeGrow) = 2, and we're stuck there forever
			-- But if we clamp it to be bigger than 1, then round(cursorSize + sizeGrow) = 3
			if math.abs(sizeGrow) < 1 then
				sizeGrow = math.sign(sizeGrow)
			end

			if math.abs(heightGrow) < 1 then
				heightGrow = math.sign(heightGrow)
			end

			local newSize = round(self._operationSettings.cursorSize + sizeGrow)
			local newHeight = round(self._operationSettings.cursorHeight + heightGrow)

			local newSizeClamped = math.max(Constants.MIN_BRUSH_SIZE, math.min(Constants.MAX_BRUSH_SIZE, newSize))
			local newHeightClamped = math.max(Constants.MIN_BRUSH_SIZE, math.min(Constants.MAX_BRUSH_SIZE, newHeight))

			self._requestBrushSizeChanged:fire(newSizeClamped, newHeightClamped)
		end

		local ctrlDown
		if FFlagTerrainToolsBrushUseIsKeyDown then
			ctrlDown = isCtrlKeyDown()
		else
			ctrlDown = self._downKeys[Enum.KeyCode.LeftControl] or self._downKeys[Enum.KeyCode.RightControl]
		end
		if ctrlDown then
			local newStrength = math.max(0.1, math.min(1, self._operationSettings.strength + (direction * 0.1)))

			self._requestBrushStrengthChanged:fire(newStrength)
		end
	end

	connectHelper(self._mouse.WheelForward, function()
		handleScrollWheel(1)
	end)

	connectHelper(self._mouse.WheelBackward, function()
		handleScrollWheel(-1)
	end)
end

function TerrainBrush:_run()
	self._isRunning = true

	local lastCursorDistance = 300
	local lastPlanePoint = Vector3.new(0, 0, 0)
	local lastNormal = Vector3.new(0, 1, 0)
	local lastMainPoint = Vector3.new(0, 0, 0)
	local firstOperation = tick()

	local reportClick = true

	local loopTag = {}
	self._currentLoopTag = loopTag

	while self._currentLoopTag and self._currentLoopTag == loopTag do
		if not self._mouse then
			warn("No mouse in TerrainBrush:_run()")
			break
		end

		local currentTick = tick()
		local radius = self._operationSettings.cursorSize * 0.5 * Constants.VOXEL_RESOLUTION

		-- Why is mouse used for camera?
		local cameraPos = self._mouse.Origin.p

		local ignoreList = {self._cursor:getCursorPart()}
		if Players.LocalPlayer and Players.LocalPlayer.Character then
			table.insert(ignoreList, Players.LocalPlayer.Character)
		end

		local unitRay = self._mouse.UnitRay.Direction
		local mouseRay = Ray.new(cameraPos, unitRay * 10000)
		local rayHit, mainPoint, _, hitMaterial = Workspace:FindPartOnRayWithIgnoreList(mouseRay, ignoreList,
			false, self._operationSettings.ignoreWater)

		if not FFlagTerrainToolsFixFlattenToolPlanePosition then
			if self._operationSettings.heightPicker then
				self._planePositionYChanged:fire(mainPoint.y - 1)
			end
		end

		local currentTool = self._operationSettings.currentTool
		if currentTool == ToolId.Add then
			mainPoint = mainPoint - unitRay * 0.05
		elseif currentTool == ToolId.Subtract or currentTool == ToolId.Paint or currentTool == ToolId.Grow then
			mainPoint = mainPoint + unitRay * 0.05
		end

		if FFlagTerrainToolsFixFlattenToolPlanePosition then
			if self._operationSettings.heightPicker
				or (currentTool == ToolId.Flatten and self._mouseClick
					and not self._operationSettings.fixedPlane and not self._operationSettings.planeLock) then
				self._planePositionYChanged:fire(mainPoint.y - 1)
			end
		end

		if not self._mouse.Target then
			mainPoint = cameraPos + unitRay * lastCursorDistance
		end

		local shiftDown
		if FFlagTerrainToolsBrushUseIsKeyDown then
			shiftDown = isShiftKeyDown()
		else
			shiftDown = self._downKeys[Enum.KeyCode.LeftShift] or self._downKeys[Enum.KeyCode.RightShift]
		end
		if not self._operationSettings.planeLock
			or not shiftDown then
			if not self._mouseDown or self._mouseClick then
				lastPlanePoint = mainPoint
				lastNormal = currentTool == ToolId.Flatten and Vector3.new(0, 1, 0) or getCameraLookSnappedForPlane()
				reportClick = true
			end
		end

		if self._operationSettings.planeLock then
			mainPoint = lineToPlaneIntersection(cameraPos, unitRay, lastPlanePoint, lastNormal)
		end

		if self._operationSettings.snapToGrid then
			local snapOffset = Vector3.new(1, 1, 1) * (radius % Constants.VOXEL_RESOLUTION)
			local tempMainPoint = ((mainPoint - snapOffset) / Constants.VOXEL_RESOLUTION) + Vector3.new(0.5, 0.5, 0.5)
			mainPoint = (Vector3.new(math.floor(tempMainPoint.x),
				math.floor(tempMainPoint.y),
				math.floor(tempMainPoint.z)) * Constants.VOXEL_RESOLUTION) + snapOffset
		end

		if self._mouseDown then
			if self._mouseClick then
				firstOperation = currentTick
				lastMainPoint = mainPoint
			end

			if self._mouseClick or currentTick > firstOperation + CLICK_THRESHOLD then
				self._mouseClick = false

				if reportClick then
					if FFlagTerrainToolMetrics then
						AnalyticsService:SendEventDeferred("studio", "TerrainEditorV2", "UseTerrainTool", {
							userId = StudioService:GetUserId(),
							toolName = currentTool,
							studioSId = AnalyticsService:GetSessionId(),
							placeId = game.PlaceId,
						})
					end
					reportClick = false
				end

				local altDown
				if FFlagTerrainToolsBrushUseIsKeyDown then
					altDown = isAltKeyDown()
				else
					altDown = self._downKeys[Enum.KeyCode.LeftAlt] or self._downKeys[Enum.KeyCode.RightAlt]
				end
				if altDown then
					if rayHit and rayHit:IsA("Terrain") then
						self._materialSelectRequested:fire(hitMaterial)
					end
				else
					local difference = mainPoint - lastMainPoint
					local dragDistance = difference.magnitude
					local crawlDistance = radius * 0.5

					if dragDistance > crawlDistance then
						local differenceVector = difference.unit
						local dragDistance = math.min(dragDistance, (crawlDistance * 2) + 20)
						local samples = math.ceil((dragDistance / crawlDistance) - 0.1)

						for i = 1, samples, 1 do
							self._operationSettings.centerPoint = lastMainPoint + (differenceVector * dragDistance * (i / samples))
							performTerrainBrushOperation(self._terrain, self._operationSettings)
						end
						mainPoint = lastMainPoint + differenceVector * dragDistance
					else
						self._operationSettings.centerPoint = mainPoint
						performTerrainBrushOperation(self._terrain, self._operationSettings)
					end

					self._isTerrainDirty = true

					lastMainPoint = mainPoint
				end
			end

			if currentTool == ToolId.Flatten and self._operationSettings.heightPicker then
				self._heightPickerSet:fire(false)
			end
		end

		self._cursorTargetLocation = mainPoint
		self._lastNormal = lastNormal

		self:_updateCursor()

		lastCursorDistance = math.max(20 + (self._operationSettings.cursorSize * Constants.VOXEL_RESOLUTION * 1.5),
			(mainPoint - cameraPos).magnitude)

		quickWait()
	end
end

return TerrainBrush
