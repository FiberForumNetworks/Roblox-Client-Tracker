--[[
	The frame containing the ViewportFrames

	Props:
		HatId number = the hat for each character to wear
		LayoutOrder
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local UILibrary = require(Plugin.Packages.UILibrary)
local LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator

local ViewportFrameContainer = require(Plugin.Src.Components.ViewportFrameContainer)
local CameraManipulator = require(Plugin.Src.Util.CameraManipulator)
local ConnectionsManager = require(Plugin.Src.Util.ConnectionsManager)

local ViewportFramesMultiView = Roact.PureComponent:extend("ViewportFramesMultiView")

local CELL_PADDING = 5
local CELL_BUNDLE_IDS = {
	{512, 464, 506},
	{361, 332, 442},
	{353, 221, 501},
}

local NUM_VIEWPORTS_PER_ROW = #CELL_BUNDLE_IDS[1]
local NUM_VIEWPORTS_PER_COLUMN = #CELL_BUNDLE_IDS
local NUM_VIEWPORTS = NUM_VIEWPORTS_PER_ROW*NUM_VIEWPORTS_PER_COLUMN

local function generateViewportFrameName(row, col)
	return "ViewportFrame" .. " " .. tostring(row) .. " " .. tostring(col)
end

function ViewportFramesMultiView:init()
	self.frameRef = Roact.createRef()

	self.connections = ConnectionsManager.new()
	self.viewportsRegistered = 0

	self.propogateChangesToViewports = function()
		if self.mainViewport and self.frameRef.current then
			for row=1, NUM_VIEWPORTS_PER_ROW do
				for col=1, NUM_VIEWPORTS_PER_COLUMN do
					local viewport = self.frameRef.current:FindFirstChild(generateViewportFrameName(row, col))
					if self.mainViewport ~= viewport and viewport.CurrentCamera then
						viewport.CurrentCamera.CFrame = self.mainViewport.CurrentCamera.CFrame
					end
				end
			end
		end
	end

	self.initViewportCameras = function()
		local haveAllViewportsRegistered = self.viewportsRegistered == NUM_VIEWPORTS
		if haveAllViewportsRegistered and self.frameRef.current then
			self.initViewportCameras = nil
			self.propogateChangesToViewports()
		end
	end

	self.setupCameras = function()
		if self.mainViewport and self.frameRef.current then
			self.setupCameras = nil
			self.connections:add(self.mainViewport.CurrentCamera.Changed:connect(function(property)
					if property == "CFrame" then
						self.propogateChangesToViewports()
					end
				end)
			)
			local camManipulator =
				CameraManipulator.new(self.mainViewport.CurrentCamera, self.frameRef.current, {self.mainViewport.Player})
			camManipulator:focus()
			self.connections:add(camManipulator)
		end
	end
end

function ViewportFramesMultiView:render()
	local props = self.props
	local hatId = props.HatId
	local layoutOrder = props.LayoutOrder

	local children = {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			CellSize = UDim2.new(1/NUM_VIEWPORTS_PER_ROW, -CELL_PADDING, 1/NUM_VIEWPORTS_PER_COLUMN, -CELL_PADDING),
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellPadding = UDim2.new(0, CELL_PADDING, 0, CELL_PADDING),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	}

	local orderIterator = LayoutOrderIterator.new()
	for row=1, NUM_VIEWPORTS_PER_ROW do
		for col=1, NUM_VIEWPORTS_PER_COLUMN do
			children[generateViewportFrameName(row, col)] = Roact.createElement(ViewportFrameContainer, {
				BundleId = CELL_BUNDLE_IDS[row][col],
				LayoutOrder = orderIterator:getNextOrder(),
				HatId = hatId,

				registerViewport = function(viewport)
					self.viewportsRegistered = self.viewportsRegistered + 1

					if self.setupCameras then
						self.mainViewport = viewport
						self.setupCameras()
					end

					if self.initViewportCameras then
						self.initViewportCameras()
					end
				end
			})
		end
	end

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,

		[Roact.Ref] = self.frameRef,
	}, children)
end

function ViewportFramesMultiView:didMount()
	if self.setupCameras then
		self.setupCameras()
	end

	if self.initViewportCameras then
		self.initViewportCameras()
	end
end

function ViewportFramesMultiView:willUnmount()
	self.setupCameras = nil
	self.initViewportCameras = nil

	self.connections:disconnect()
end

return ViewportFramesMultiView