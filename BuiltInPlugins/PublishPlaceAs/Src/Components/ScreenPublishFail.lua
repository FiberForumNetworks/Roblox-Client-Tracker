--[[
	Display page on publish fail
]]
local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Cryo = require(Plugin.Packages.Cryo)
local UILibrary = require(Plugin.Packages.UILibrary)

local SetPublishInfo = require(Plugin.Src.Actions.SetPublishInfo)
local SetScreen = require(Plugin.Src.Actions.SetScreen)

local Constants = require(Plugin.Src.Resources.Constants)

local Theming = require(Plugin.Src.ContextServices.Theming)

local Localizing = UILibrary.Localizing
local RoundTextButton = UILibrary.Component.RoundTextButton

local SettingsImpl = require(Plugin.Src.Network.Requests.SettingsImpl)

local StudioService = game:GetService("StudioService")
local ContentProvider = game:GetService("ContentProvider")

local ICON_SIZE = 150
local BUTTON_WIDTH = 150
local BUTTON_HEIGHT = 40

local ScreenPublishFail = Roact.PureComponent:extend("ScreenPublishFail")

function ScreenPublishFail:init()
	self.state = {
		assetFetchStatus = nil,		
	}
	
	self.finishedConnection = nil

	self.isMounted = false

	self.thumbnailUrl = string.format("rbxthumb://type=Asset&id=%i&w=%i&h=%i", self.props.Id, ICON_SIZE, ICON_SIZE)
end

function ScreenPublishFail:didMount()
	self.isMounted = true
	spawn(function()
		local asset = { self.thumbnailUrl }
		local function setStatus(contentId, status)
			if self.isMounted then
				self:setState({
					assetFetchStatus = status
				})
			end
		end
		ContentProvider:PreloadAsync(asset, setStatus)
	end)

	self.finishedConnection = StudioService.GamePublishFinished:connect(function(success)
		if success then
			self.props.OpenPublishSuccessfulPage(self.props.Id, self.props.Name, self.props.ParentGameName)
		end
	end)
end

function ScreenPublishFail:willUnmount()
	self.isMounted = false
	if self.finishedConnection then
		self.finishedConnection:disconnect()
	end
end

function ScreenPublishFail:render()
	return Theming.withTheme(function(theme)
		return Localizing.withLocalization(function(localization)
            local props = self.props

			local onClose = props.OnClose

            local id = props.Id
			local name = props.Name
            local parentGameName = props.ParentGameName
            local parentGameId = props.ParentGameId
			local settings = props.Settings
			
			local openPublishSuccessfulPage = props.OpenPublishSuccessfulPage

			
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = theme.backgroundColor,
				BorderSizePixel = 0,
			}, {
				Icon = Roact.createElement("ImageLabel", {
					Position = UDim2.new(0.5, 0, 0.2, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
					Image = self.state.assetFetchStatus == Enum.AssetFetchStatus.Success and self.thumbnailUrl or theme.icons.thumbnailPlaceHolder,
					BorderSizePixel = 0,
				}),

				Name = Roact.createElement("TextLabel", {
					Text = name,
					Position = UDim2.new(0.5, 0, 0.35, 0),					
					TextSize = 20,
					BackgroundTransparency = 1,
					TextColor3 = theme.header.text,
					TextXAlignment = Enum.TextXAlignment.Center,
					Font = theme.header.font,
				}),

				Fail = Roact.createElement("TextLabel", {
					Text = localization:getText("PublishFail", "Fail"),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					TextSize = 24,
					BackgroundTransparency = 1,
					TextColor3 = theme.header.text,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextColor3 = theme.failText.text,
					Font = theme.failText.font,
				}),


				Retry = Roact.createElement(RoundTextButton, {
					Position = UDim2.new(0.5, 0, 0.8, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Style = theme.defaultButton,
					Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT),
					Active = true,
					Name = localization:getText("Button", "Retry"),
					TextSize = Constants.TEXT_SIZE,
                    OnClicked = function()
                        if parentGameId == 0 then
                            SettingsImpl.saveAll(settings, localization)
                        else
                            StudioService:publishAs(parentGameId, id)
						end                       
					end,
				})
			})
		end)
	end)
end

local function mapStateToProps(state, props)
	local publishInfo = state.PublishedPlace.publishInfo
	return {
        Id = publishInfo.id,
        Name = publishInfo.name,
        ParentGameName = publishInfo.parentGameName,
        ParentGameId = publishInfo.parentGameId,
        Settings = publishInfo.settings,
	}
end

local function useDispatchForProps(dispatch)
	return {
		OpenPublishSuccessfulPage = function(id, name, parentGameName)
			dispatch(SetPublishInfo({ id = id, name = name, parentGameName = parentGameName, }))
			dispatch(SetScreen(Constants.SCREENS.PUBLISH_SUCCESSFUL))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, useDispatchForProps)(ScreenPublishFail)
