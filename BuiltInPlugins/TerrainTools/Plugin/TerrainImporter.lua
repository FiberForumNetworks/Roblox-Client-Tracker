-- 24RightAngles

local module = {}

local GuiUtilities = require(script.Parent.Parent.Libs.GuiUtilities)
local VerticallyScalingListFrame = require(script.Parent.Parent.Libs.VerticallyScalingListFrame)
local CollapsibleTitledSection = require(script.Parent.Parent.Libs.CollapsibleTitledSection)
local ImageButtonWithText = require(script.Parent.Parent.Libs.ImageButtonWithText)
local LabeledTextInput = require(script.Parent.Parent.Libs.LabeledTextInput)
local CustomTextButton = require(script.Parent.Parent.Libs.CustomTextButton)
local i18n = require(script.Parent.Parent.Libs.Localization)

local ProgressFrame = require(script.Parent.ProgressFrame)
local ImageSelector = require(script.Parent.ImageSelector)
local AssetIdSelector = require(script.Parent.AssetIdSelector)
local TabbableVector3Input = require(script.Parent.TabbableVector3Input)

local coreGui = game:GetService('CoreGui')
local ChangeHistoryService = game:GetService('ChangeHistoryService')
local AnalyticsService = game:GetService("RbxAnalyticsService")
local StudioService = game:GetService("StudioService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local FFlagTerrainToolMetrics = settings():GetFFlag("TerrainToolMetrics")

local OFF_LIGHT = "rbxasset://textures/TerrainTools/import_toggleOff.png"
local OFF_DARK = "rbxasset://textures/TerrainTools/import_toggleOff_dark.png"
local ON_LIGHT = "rbxasset://textures/TerrainTools/import_toggleOn.png"
local ON_DARK = "rbxasset://textures/TerrainTools/import_toggleOn_dark.png"

local toggleOnImage = ON_LIGHT
local toggleOffImage = OFF_LIGHT

local supportedFileType = {"png"}
local terrain
local useColorMap = false

local mouse = nil
local pluginGui	= nil
local screenGui = nil

local progressFrameObj = nil
local progressFrame = nil

local MIN_STUDS = 5
local MAX_STUDS = 16384

-- be sure to localize these strings when we move to Roact
local MIN_STUDS_ERROR_STR = string.format("Input must be greater than %d studs.", MIN_STUDS - 1)
local MAX_STUDS_ERROR_STR = string.format("Input can not exceed %d studs.", MAX_STUDS)
local INVALID_INPUT_ERROR = "Input is not a valid number."

local WARN_HEIGHTMAP_MISSING = "Valid HeightMap required to begin importing Terrain"
local WARN_INVALID_POS_INPUT = "Position has invalid input"
local WARN_INVALID_SIZE_INPUT = "Size has invalid input."
local WARN_SIZE_REQUIRED = "Size of region must be defined."
local WARN_PUBLISHED_ONLY = "Game must be published before importing terrain."

-- these two targets are ImageSelectors that
-- hold the target files
local targetHeightMap = nil
local targetColorMap = nil

local regionPosition = nil
local regionSize = nil

-- for each of x, y, z
local posHasError = {false, false, false}
local sizeHasError = {false, false, false}

local terrainImporterFrame = nil

local SECOND_COLUMN_OFFSET = 90 + GuiUtilities.StandardLineLabelLeftMargin
local TEXTBOX_HEIGHT = 22
local LABEL_HEIGHT = 16

local SECTION_PADDING = 12
local PADDING = 4

local IMAGE_SELECT_FRAME_SIZE = UDim2.new(1, 0, 0, 22)

module.FirstTimeSetup = function(mouse, thePluginGui, theContentFrame)
	mouse = theMouse
	pluginGui = thePluginGui
	contentFrame = theContentFrame

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TerrainImportGui"

	progressFrameObj = ProgressFrame.new()
	progressFrame = progressFrameObj:GetFrame()
	progressFrameObj:GetPauseButton().Visible = false
	progressFrameObj:GetCancelButton().Visible = false
	progressFrame.Parent = screenGui

	terrain = workspace.Terrain

	terrain.TerrainProgressUpdate:connect(function(completionPercent)
		if completionPercent < 1 then
			progressFrame.Visible = true
			progressFrameObj:GetFill().Size = UDim2.new(completionPercent,0,1,0)
		else
			progressFrame.Visible = false
		end
	end)

	terrainImporterFrame = MakeTerrainImporterFrame()
	terrainImporterFrame.Parent = contentFrame

	terrainImporterFrame.ImportButton.ImportTerrainButton.MouseButton1Down:connect(function()
		importTerrain()
	end)
end

function MakeTerrainImporterFrame()
	local verticallyScalingListFrameObj = VerticallyScalingListFrame.new("GenerationFrame")
	local verticallyScalingListFrame = verticallyScalingListFrameObj:GetFrame()

	local mapSettingsFrame = MakeMapSettingsFrame()
	mapSettingsFrame.Parent = verticallyScalingListFrame
	mapSettingsFrame.LayoutOrder = 2

	local materialSettingsFrame = MakeMaterialSettingsFrame()
	materialSettingsFrame.Parent = verticallyScalingListFrame
	materialSettingsFrame.LayoutOrder = 3

	local importButtonFrame = MakeButtonsFrame()
	importButtonFrame.Parent = verticallyScalingListFrame
	importButtonFrame.LayoutOrder = 4

	return verticallyScalingListFrame
end


function MakeMapSettingsFrame()
	local mapSettingsObj = CollapsibleTitledSection.new('MapSettingsFrame',
		"Map Settings", -- need to localize
		true, -- show title
		true, -- minimizable
		false)-- init minimized

	local contentFrame = mapSettingsObj:GetContentsFrame()

	local hackPadding = Instance.new("Frame")
	hackPadding.BorderSizePixel = 0
	hackPadding.LayoutOrder = 1
	hackPadding.Parent = contentFrame

	targetHeightMap = AssetIdSelector.new("Heightmap")
	targetHeightMap:getFrame().LayoutOrder = 2
	targetHeightMap:getFrame().Parent = contentFrame

	regionPosition = TabbableVector3Input.new("Position", {0, 0, 0})
	regionPosition:GetFrame().LayoutOrder = 3
	regionPosition:GetFrame().Parent = contentFrame

	regionPosition:SetWarningFunc(function(text, index)
		local num = tonumber(text)
		if num then
			posHasError[index] = false
			return true
		end
		posHasError[index] = true
		return false, INVALID_INPUT_ERROR
	end)

	regionSize = TabbableVector3Input.new("Size", {1024, 512, 1024})
	regionSize:GetFrame().LayoutOrder = 4
	regionSize:GetFrame().Parent = contentFrame


	-- these error messages should be localized when we submit changes for the final
	regionSize:SetWarningFunc(function(text, index)
		local num = tonumber(text)
		sizeHasError[index] = true
		if not num then
			return false, INVALID_INPUT_ERROR
		end

		if num < MIN_STUDS then
			return false, MIN_STUDS_ERROR_STR
		end

		if num > MAX_STUDS then
			return false, MAX_STUDS_ERROR_STR
		end

		sizeHasError[index] = false
		return true
	end)

	--link the position and region so we can tab across them
	regionPosition:LinkToNextTabbableVector3Input(regionSize)
	regionSize:LinkToNextTabbableVector3Input(regionPosition)

	local hackPadding2 = Instance.new("Frame")
	hackPadding2.BorderSizePixel = 0
	hackPadding2.LayoutOrder = 6
	hackPadding2.Parent = contentFrame

	local sectionUIListLayout = Instance.new("UIListLayout")
	sectionUIListLayout.Padding = UDim.new(0, SECTION_PADDING)
	sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionUIListLayout.FillDirection = Enum.FillDirection.Vertical
	sectionUIListLayout.Parent = contentFrame

	GuiUtilities.AdjustHeightDynamicallyToLayout(contentFrame, sectionUIListLayout)

	return mapSettingsObj:GetSectionFrame()
end

function MakeMaterialSettingsFrame()
	local materialFrameObj = CollapsibleTitledSection.new('MaterialSettings',
		"Material Settings", -- need localize
		true, -- show title
		true, -- minimizable
		false-- init minimized
	 )

	local materialFrame = materialFrameObj:GetContentsFrame()

	local hackPadding = Instance.new("Frame")
	hackPadding.BorderSizePixel = 0
	hackPadding.LayoutOrder = 1
	hackPadding.Parent = materialFrame

	local colorMatSliderFrame = Instance.new("Frame")
	colorMatSliderFrame.Size = UDim2.new(1, 0, 0, TEXTBOX_HEIGHT)
	colorMatSliderFrame.BackgroundTransparency = 1
	colorMatSliderFrame.LayoutOrder = 2
	colorMatSliderFrame.Parent = materialFrame

	local colorMapLabel = GuiUtilities.MakeStandardPropertyLabel("Use Colormap")
	colorMapLabel.TextYAlignment = Enum.TextYAlignment.Top
	colorMapLabel.AnchorPoint = Vector2.new(0, 0)
	colorMapLabel.Parent = colorMatSliderFrame

	local initTheme = settings().Studio["UI Theme"]
	toggleOffImage = initTheme == Enum.UITheme.Dark and OFF_DARK or OFF_LIGHT
	toggleOnImage = initTheme == Enum.UITheme.Dark and ON_DARK or ON_LIGHT

	local toggleButton = Instance.new("ImageButton")
	toggleButton.Size = UDim2.new(0, 27, 0, LABEL_HEIGHT)
	toggleButton.Position = UDim2.new(0, SECOND_COLUMN_OFFSET, 1, -LABEL_HEIGHT)
	toggleButton.Image = toggleOffImage
	toggleButton.BackgroundTransparency = 1
	toggleButton.Parent = colorMatSliderFrame

	-- button Toggle
	toggleButton.Activated:connect(function()
		useColorMap = not useColorMap
		if useColorMap then
			toggleButton.Image = toggleOnImage
		else
			toggleButton.Image = toggleOffImage
		end
	end)

	settings().Studio.ThemeChanged:connect(function()
		if settings().Studio["UI Theme"] == Enum.UITheme.Dark then
			toggleOffImage = OFF_DARK
			toggleOnImage = ON_DARK
		else -- we could check for light but since it's the fall back no need
			toggleOffImage = OFF_LIGHT
			toggleOnImage = ON_LIGHT
		end

		toggleButton.Image = useColorMap and toggleOnImage or toggleOffImage
	end)

	targetColorMap = AssetIdSelector.new("")
	targetColorMap:getFrame().Position = UDim2.new(0, SECOND_COLUMN_OFFSET, 0, 0)
	targetColorMap:getFrame().LayoutOrder = 4
	targetColorMap:getFrame().Parent = materialFrame

	targetColorMap:setImageSelectedCallback(function()
		useColorMap = true
		toggleButton.Image = toggleOnImage
	end)

	local hackPadding2 = Instance.new("Frame")
	hackPadding2.BorderSizePixel = 0
	hackPadding2.LayoutOrder = 5
	hackPadding2.Parent = materialFrame

	local sectionUIListLayout = Instance.new("UIListLayout")
	sectionUIListLayout.Padding = UDim.new(0, 8)
	sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionUIListLayout.FillDirection = Enum.FillDirection.Vertical
	sectionUIListLayout.Parent = materialFrame

	GuiUtilities.AdjustHeightDynamicallyToLayout(materialFrame, sectionUIListLayout)

	return materialFrameObj:GetSectionFrame()
end

function MakeButtonsFrame()
	local frame = GuiUtilities.MakeFixedHeightFrame("ImportButton", GuiUtilities.kBottomButtonsFrameHeight)
	frame.BackgroundTransparency = 1

	local importButtonObj = CustomTextButton.new("ImportTerrainButton", "Import")
	local importButton = importButtonObj:getButton()

	importButton.Size = UDim2.new(.7, 0, 0, GuiUtilities.kBottomButtonsHeight)
	importButton.Position = UDim2.new(.15, 0, 1, -GuiUtilities.kBottomButtonsHeight)
	importButton.Parent = frame

	return frame
end

function importTerrain()
	if tonumber(game.GameId) == 0 then
		warn(WARN_PUBLISHED_ONLY)
		return
	end

	local heightValidated = targetHeightMap:isValidated()

	if not heightValidated then
		warn(WARN_HEIGHTMAP_MISSING)
		return
	end

	if posHasError[1] or posHasError[2] or posHasError[3] then
		warn(WARN_INVALID_POS_INPUT)
		return
	end

	if sizeHasError[1] or sizeHasError[2] or sizeHasError[3] then
		warn(WARN_INVALID_SIZE_INPUT)
		return
	end

	terrain = workspace.Terrain
	if not generating then
		generating = true


		local size = regionSize:GetVector3()

		-- center represents the center of the bottom plane
		local center = regionPosition:GetVector3() or Vector3.new(0, 0, 0)
		center = center + Vector3.new(0, size.Y/2, 0)

		if size then
			-- expect Studs
			local offset = size / 2
			local regionStart = (center - offset)
			local regionEnd = (center + offset)
			local region = Region3.new(regionStart, regionEnd)
			region = region:ExpandToGrid(4)

			local status, err = pcall(function()
				local heightUrl = targetHeightMap:getAssetUrl()
				local colorUrl = nil
				if useColorMap and targetColorMap:isValidated() then
					colorUrl = targetColorMap:getAssetUrl()
				end
				terrain:ImportHeightMap(heightUrl, colorUrl, region)
			end)

			if FFlagTerrainToolMetrics then
				AnalyticsService:SendEventDeferred("studio", "TerrainEditor", "ImportTerrain", {
					userId = StudioService:GetUserId(),
					regionDims = string.format("%d,%d,%d)", region.Size.x, region.Size.y, region.Size.z),
					useColorMap = binary2 ~= nil,
				})
			end

			if not status then
				warn(err)
			end
		else
			warn(WARN_SIZE_REQUIRED)
		end

		generating = false
	end
end

module.On = function(theTool)
	screenGui.Parent = coreGui
	terrainImporterFrame.Visible = true
	on = true
end

module.Off = function()
	on = false
	screenGui.Parent = nil
	terrainImporterFrame.Visible = false
end

return module