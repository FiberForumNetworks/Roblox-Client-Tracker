--[[
	A camera which provides basic roblox Studio style functionality
]]

local inputService = game:GetService("UserInputService")

local Plugin = script.Parent.Parent.Parent
local ConnectionsManager = require(Plugin.Src.Util.ConnectionsManager)

local CameraManipulator = {}

CameraManipulator.__index = CameraManipulator

function CameraManipulator.new(inputCam, observable, focusableObjects)
	assert(inputCam, "CameraManipulator requires a Camera")
	assert(observable,
		"CameraManipulator requires observable which has events for InputBegan, InputChanged, and InputEnded")
	assert(nil == focusableObjects or type(focusableObjects) == "table",
		"CameraManipulator expected focusableObjects to be an array table")

	local self = setmetatable({}, CameraManipulator)

	local camera = inputCam
	local cf = camera.CFrame
	local boundToPoint = nil
	self.FocusObjects = focusableObjects

	local keyStates = setmetatable({}, {
		__index = function(self, index)
			if index == "Shift" then
				return self.LeftShift or self.RightShift
			end
		end
	})

	local settings = setmetatable({
		LockMouse = true;
		IncreaseSpeedAfter = 2;
		MinPitch = -math.rad(80);
		MaxPitch = math.rad(80);
		CameraRotateSpeed = math.rad(0.25);
	}, {
		__index = function(_, index)
			if index == "CameraSpeed" then
				return settings():GetService("Studio")["Camera Speed"]/2
			elseif index == "CameraShiftSpeed" then
				return settings():GetService("Studio")["Camera Shift Speed"]
			elseif index == "CameraZoomSpeed" then
				return settings():GetService("Studio")["Camera Mouse Wheel Speed"]
			end
		end
	})

	local lastUpdate = tick()
	local activeSince = nil
	self.inputConnections = ConnectionsManager.new()
	self.inputConnections:add(game:GetService("RunService").RenderStepped:connect(function()
			if tick()-lastUpdate > 1 then
				--RenderStepped hasn't fired for a whole second
				-- probably went into different mode and just returned. Verify key states
				activeSince = nil
				for key in next,keyStates do
					if (key ~= "Shift" and not key:find("Mouse")) and not inputService:IsKeyDown(Enum.KeyCode[key]) then
						keyStates[key] = nil
					end
				end
				if not (inputService:IsKeyDown(Enum.KeyCode.LeftShift) or inputService:IsKeyDown(Enum.KeyCode.RightShift)) then
					keyStates.Shift = nil
				end
			end
			lastUpdate = tick()

			if not camera.CameraSubject then
				camera.CameraType = "Scriptable"

				local speed
				if keyStates.Shift then
					speed = settings.CameraSpeed * settings.CameraShiftSpeed
				else
					if activeSince and tick()-activeSince > settings.IncreaseSpeedAfter then
						speed = settings.CameraSpeed + (tick()-(activeSince+settings.IncreaseSpeedAfter))*(settings.CameraSpeed)
					else
						speed = settings.CameraSpeed
					end
				end

				if keyStates.W then
					cf = cf * CFrame.new(0, 0, -speed)
					boundToPoint = nil
				end
				if keyStates.S then
					cf = cf * CFrame.new(0, 0, speed)
					boundToPoint = nil
				end
				if keyStates.A then
					cf = cf * CFrame.new(-speed, 0, 0)
					boundToPoint = nil
				end
				if keyStates.D then
					cf = cf * CFrame.new(speed, 0, 0)
					boundToPoint = nil
				end
				if keyStates.Q then
					cf = cf * CFrame.new(0, -speed, 0)
					boundToPoint = nil
				end
				if keyStates.E then
					cf = cf * CFrame.new(0, speed, 0)
					boundToPoint = nil
				end

				camera.CFrame = cf
			end
		end)
	)

	local function move(change)
		cf = camera.CFrame
		local startLook = boundToPoint and (boundToPoint-cf.p).unit or cf.lookVector
		local zoom = boundToPoint and (cf.p-boundToPoint).magnitude
		local startCFrame = cf
		local startVertical = math.asin(startLook.y)

		local function constrain(num, min, max)
			return (num < min and min) or (num > max and max) or num
		end

		local yTheta = constrain(change.y, -settings.MaxPitch + startVertical, -settings.MinPitch + startVertical)
		local resultLookVector = (CFrame.Angles(0, -change.x, 0) * startCFrame * CFrame.Angles(-yTheta,0,0)).lookVector
		if not boundToPoint then
			cf = CFrame.new(cf.p, cf.p + resultLookVector)
		else
			cf = CFrame.new(boundToPoint - (zoom*resultLookVector), boundToPoint)
		end
	end

	self.focusInternal = function()
		local minX, minY, minZ, maxX, maxY, maxZ

		local function updateBounds(part)
			if part:IsA("BasePart") then
				local min, max = part.CFrame*(-part.Size/2), part.CFrame*(part.Size/2)
				if minX == nil then
					minX, minY, minZ, maxX, maxY, maxZ = min.x, min.y, min.z, max.x, max.y, max.z
				else
					minX = math.min(minX, min.X)
					minY = math.min(minY, min.Y)
					minZ = math.min(minZ, min.Z)
					maxX = math.max(maxX, max.X)
					maxY = math.max(maxY, max.Y)
					maxZ = math.max(maxZ, max.Z)
				end
			end
		end

		if self.FocusObjects then
			for _, obj in ipairs(self.FocusObjects) do
				updateBounds(obj)

				local function recurse(root,callback)
					for i,v in pairs(root:GetChildren()) do
						callback(i,v)

						if #v:GetChildren() > 0 then
							recurse(v,callback)
						end
					end
				end
				recurse(obj, function(_,part) updateBounds(part) end)
			end
		end

		if minX then
			local selectionCenter = Vector3.new((minX+maxX)/2, (minY+maxY)/2, (minZ+maxZ)/2)
			cf = CFrame.new(selectionCenter) *
				(camera.CFrame - camera.CFrame.p) *
				CFrame.new(0, 0, math.max(maxX-minX, maxY-minY, maxZ-minZ))
			camera.CFrame = cf
			boundToPoint = selectionCenter
			move(Vector3.new())
		else
			boundToPoint = nil
		end
	end

	local lastMouse = Vector3.new()
	local function onInput(input, processed)
		local down = input.UserInputState == Enum.UserInputState.Begin

		if (not processed) or (not down) then
			keyStates[input.KeyCode.Name] = down
		end

		if not processed then
			activeSince = (keyStates.W or keyStates.A or keyStates.S or keyStates.D) and (activeSince or tick())
			if (keyStates.W or keyStates.A or keyStates.S or keyStates.D) then
				boundToPoint = nil
			end

			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local direction = (input.Position.Z < 0 and 1 or -1)
				local delta = settings.CameraZoomSpeed * (keyStates.Shift and settings.CameraShiftSpeed or 1)
				cf = cf * CFrame.new(0, 0, delta * direction)
				camera.CFrame = cf
			end
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				keyStates["MouseButton2"] = down and true
				if settings.LockMouse then
					inputService.MouseBehavior = down and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
				end
				lastMouse = input.Position
			end
			if input.UserInputType.Name == "MouseButton3" then
				keyStates["MouseButton3"] = down and true
				lastMouse = input.Position
				boundToPoint = nil
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement and keyStates.MouseButton2 then
				move(settings.CameraRotateSpeed * (settings.LockMouse and input.Delta or (input.Position - lastMouse)))
				lastMouse = input.Position
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement and keyStates.MouseButton3 then
				local delta = input.Position - lastMouse
				local sensitivity = 0.5 * (keyStates.Shift and 0.1 or 1)
				cf = camera.CFrame * CFrame.new(Vector3.new(-delta.X,delta.Y,0)*sensitivity)
				lastMouse = input.Position
			end

			if input.KeyCode == Enum.KeyCode.F and down then
				self.focusInternal()
			end
		end
	end

	self.inputConnections:add(observable.InputBegan:Connect(onInput))
	self.inputConnections:add(observable.InputChanged:Connect(onInput))
	self.inputConnections:add(observable.InputEnded:Connect(onInput))

	return self
end

function CameraManipulator:setFocusableObjects(focusableObjects)
	self.FocusObjects = focusableObjects
end

function CameraManipulator:focus()
	self.focusInternal()
end

function CameraManipulator:disconnect()
	self.inputConnections:disconnect()
end

return CameraManipulator