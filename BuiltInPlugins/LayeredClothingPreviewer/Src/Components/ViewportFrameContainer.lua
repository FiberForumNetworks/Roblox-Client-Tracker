--[[
	The frame containing a single ViewportFrame

	Props:
		BundleId number = the bundle id of the outfit to show
		LayoutOrder number
		HatId number = the hat for the character to wear

		registerViewport(viewport) function = allow the container to set the camera position
]]

local Players = game:GetService("Players")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local rebuildJoints = require(Plugin.Src.Util.rebuildJoints)
local getOutfitHumanoidDescription = require(Plugin.Src.Util.getOutfitHumanoidDescription)

local ViewportFrameContainer = Roact.PureComponent:extend("ViewportFrameContainer")

function ViewportFrameContainer:init()
	self.viewportFrameRef = Roact.createRef()
end

function ViewportFrameContainer:applyDescription()
	coroutine.wrap(function()
		local props = self.props
		local overriddenProps = props.overriddenProps
		local propValues = props.propValues

		if self.character and self.bundleDescription then
			local humanoid = self.character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = self.bundleDescription:Clone()

				for descriptionProp, isOverridden in pairs(overriddenProps) do
					if isOverridden and propValues[descriptionProp] ~= nil then
						descriptionClone[descriptionProp] = propValues[descriptionProp]
					end
				end

				self.character.Parent = game.ReplicatedStorage
				humanoid:ApplyDescription(descriptionClone)
				self.character.Parent = self.viewportFrameRef.current
				rebuildJoints(self.character)
			end
		end
	end)()
end

function ViewportFrameContainer:render()
	local props = self.props
	local layoutOrder = props.LayoutOrder

	self:applyDescription()

	return Roact.createElement("ViewportFrame", {
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,

		[Roact.Ref] = self.viewportFrameRef,
	})
end

function ViewportFrameContainer:didMount()
	coroutine.wrap(function()
		if self.viewportFrameRef.current then
			self.bundleDescription = getOutfitHumanoidDescription(self.props.BundleId)
			self.character = Players:CreateHumanoidModelFromDescription(self.bundleDescription, Enum.HumanoidRigType.R15)
			self.character.HumanoidRootPart.Position = Vector3.new()

			-- the above yield function (Players:CreateHumanoidModelFromDescription) means that
			-- self.viewportFrameRef.current may have been cleaned up already, so let's check again
			-- (this only occurs in test code that is quickly mounting and unmounting the components)
			if self.viewportFrameRef.current then
				self.character.Parent = self.viewportFrameRef.current
				rebuildJoints(self.character)

				-- the above yield function (rebuildJoints) means that
				-- self.viewportFrameRef.current may have been cleaned up already, so let's check again
				-- (this only occurs in test code that is quickly mounting and unmounting the components)
				if self.viewportFrameRef.current then
					local camera = Instance.new("Camera", self.viewportFrameRef.current)
					self.viewportFrameRef.current.CurrentCamera = camera
					local cameraTarget = self.character.HumanoidRootPart.Position
					local cameraOffset = Vector3.new(0, 0, 1)
					local cameraPosition = cameraTarget - cameraOffset
					camera.CFrame = CFrame.new(cameraPosition, cameraTarget)
					self.props.registerViewport(self.viewportFrameRef.current)
				end
			end
		end
	end)()
end

function ViewportFrameContainer:willUnmount()
    self.character = nil
end

local function addRoduxStateToProps(state, props)
	state = state or {}
	local HumanoidDescriptionState = state.HumanoidDescriptionState or {}

	return {
		overriddenProps = HumanoidDescriptionState.overriddenProps,
		propValues = HumanoidDescriptionState.propValues,
	}
end

return RoactRodux.connect(addRoduxStateToProps)(ViewportFrameContainer)