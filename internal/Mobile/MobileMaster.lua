local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Modules = CoreGui.RobloxGui.Modules

local Create = require(Modules.Mobile.Create)
local Constants = require(Modules.Mobile.Constants)
local MobileAppState = require(Modules.Mobile.AppState)
local AvatarEditorFlags = require(Modules.LuaApp.Legacy.AvatarEditor.Flags)
local LayoutInfo = require(Modules.LuaApp.Legacy.AvatarEditor.LayoutInfo)
local AppGui = require(Modules.LuaApp.Legacy.AvatarEditor.AppGui)

local AvatarEditorUseModernHeader = AvatarEditorFlags:GetFlag("AvatarEditorUseModernHeader2")

local ChatMaster = nil
local AvatarEditorMain = nil

local AppNames = {
	"AvatarEditor",
	"Chat",
	"ShareGameToChat",
}

local AppNameEnum = {}
for i = 1, #AppNames do
	AppNameEnum[AppNames[i]] = AppNames[i]
end

setmetatable(AppNameEnum, {
	__index = function(self, key)
		error(("Invalid AppNameEnum %q"):format(tostring(key)))
	end
})

--This is to cover the sky while loading, and also prevent the sky from flashing in when the global gui inset changes
local screenGui

if not UserSettings().GameSettings:InStudioMode() then
screenGui = Create.new "ScreenGui" {
	Name = "SkyCoverGui",
	DisplayOrder = 1,

	Create.new "Frame" {
		Name = "HackHeader",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, UserInputService.NavBarSize.Y+UserInputService.StatusBarSize.Y),
		BorderSizePixel = 0,
		BackgroundColor3 = Constants.Color.BLUE_PRESSED,
	},
	Create.new "Frame" {
		Name = "HackBody",
		Position = UDim2.new(0, 0, 0, UserInputService.NavBarSize.Y+UserInputService.StatusBarSize.Y),
		Size = UDim2.new(1, 0, 1, 200),
		BorderSizePixel = 0,
		BackgroundColor3 = Constants.Color.WHITE,
	},
}
else
screenGui = Create.new "ScreenGui" {
	Name = "SkyCoverGui",
	DisplayOrder = 1,

	Create.new "Frame" {
		Name = "HackHeader",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 64),
		BorderSizePixel = 0,
		BackgroundColor3 = Constants.Color.BLUE_PRESSED,
	},
	Create.new "Frame" {
		Name = "HackBody",
		Position = UDim2.new(0, 0, 0, 64),
		Size = UDim2.new(1, 0, 1, 200),
		BorderSizePixel = 0,
		BackgroundColor3 = Constants.Color.WHITE,
	},
}
end
local function adjustScreenGuiLayout()
	local headerHeight = UserInputService.NavBarSize.Y+UserInputService.StatusBarSize.Y
	screenGui.HackHeader.Size = UDim2.new(1, 0, 0, headerHeight)
	screenGui.HackBody.Position = UDim2.new(0, 0, 0, headerHeight)
end
local navBarChanged = UserInputService:GetPropertyChangedSignal("NavBarSize")
navBarChanged:Connect(function()
	adjustScreenGuiLayout()
end)
local statusBarChanged = UserInputService:GetPropertyChangedSignal("StatusBarSize")
statusBarChanged:Connect(function()
	adjustScreenGuiLayout()
end)

screenGui.Parent = CoreGui

--[[
	As long as initializing AvatarEditorMain requires a yield, it has to run in a
	spawned task.  It is then possible for the user to switch apps in the middle of
	initialization.  So, openAvatarEditor and closeAvatarEditor first check to see
	if it's currently initializing, and if it is, they set a bool indicating whether
	to call Start() when initialization is done.
]]
local startAvatarEditorAfterInitializing = false


local function notifyAppReady(appName)
	spawn(function()
		GuiService:BroadcastNotification(appName, GuiService:GetNotificationTypeList().APP_READY)
	end)
end


local function openChat()
	if ChatMaster == nil then
		ChatMaster = require(Modules.ChatMaster).new()
	end

	ChatMaster:Start()
	notifyAppReady(AppNameEnum.Chat)
end


local function closeChat()
	ChatMaster:Stop()
end


local function openShareGameToChat(parameters)
	if ChatMaster == nil then
		ChatMaster = require(Modules.ChatMaster).new()
	end

	ChatMaster:Start(ChatMaster.Type.GameShare, parameters)
	notifyAppReady(AppNameEnum.ShareGameToChat)
end


local function closeShareGameToChat()
	ChatMaster:Stop(ChatMaster.Type.GameShare)
end


local openAvatarEditor = function()
	startAvatarEditorAfterInitializing = true
end


local closeAvatarEditor = function()
	startAvatarEditorAfterInitializing = false
end


local function isV3FeatureOn()
	if LayoutInfo.isLandscape then
		return AvatarEditorFlags:GetFlag("AvatarEditorV3Landscape2")
	else
		return AvatarEditorFlags:GetFlag("AvatarEditorV3Portrait2")
	end
	return false
end


if isV3FeatureOn() then
	spawn(function()

if AvatarEditorUseModernHeader then
		local header
		local appGui

		if not UserSettings().GameSettings:InStudioMode() then
			header = require(Modules.LuaApp.Legacy.AvatarEditor.Header).new("Avatar",
				UserInputService.NavBarSize.Y, UserInputService.StatusBarSize.Y)

			local headerHeight = UserInputService.StatusBarSize.Y + UserInputService.NavBarSize.Y
			appGui = AppGui(
				UDim2.new(0, 0, 0,  headerHeight),
				UDim2.new(1, 0, 1, -headerHeight))

			local function updateUIDimensions()
				header:SetNavAndStatusBarHeight(UserInputService.NavBarSize.Y, UserInputService.StatusBarSize.Y)
				local headerHeight = UserInputService.NavBarSize.Y + UserInputService.StatusBarSize.Y
				appGui:setDimensions(
					UDim2.new(0, 0, 0,  headerHeight),
					UDim2.new(1, 0, 1, -headerHeight))
			end

			UserInputService:GetPropertyChangedSignal("NavBarSize"):Connect( updateUIDimensions )
			UserInputService:GetPropertyChangedSignal("StatusBarSize"):Connect( updateUIDimensions )
		else
			local navBarHeight = 44
			local statusBarHeight = 20

			header = require(Modules.LuaApp.Legacy.AvatarEditor.Header).new("Avatar",
				navBarHeight, statusBarHeight)

			local headerHeight = navBarHeight + statusBarHeight
			appGui = AppGui(
				UDim2.new(0, 0, 0,  headerHeight),
				UDim2.new(1, 0, 1, -headerHeight))
		end

		header.rbx.Parent = appGui.ScreenGui

		AvatarEditorMain =
			require(Modules.LuaApp.Legacy.AvatarEditor.AvatarEditorMain)
				.new(appGui)
else
		local headerHeight
		if not UserSettings().GameSettings:InStudioMode() then
			headerHeight = UserInputService.StatusBarSize.Y + UserInputService.NavBarSize.Y
		else
			headerHeight = 49
		end

		AvatarEditorMain =
			require(Modules.LuaApp.Legacy.AvatarEditor.AvatarEditorMain)
				.new(headerHeight)
end

		local function startAvatarEditor()
			screenGui.HackBody.Visible = false
			AvatarEditorMain:Start()
			notifyAppReady(AppNameEnum.AvatarEditor)
		end

		if startAvatarEditorAfterInitializing then
			startAvatarEditor()
		end

		openAvatarEditor = startAvatarEditor

		closeAvatarEditor = function()
			screenGui.HackBody.Visible = true
			AvatarEditorMain:Stop()
		end
	end)
else
	spawn(function()
		AvatarEditorMain = require(Modules.AvatarEditorMainV2)
		screenGui.HackBody.Visible = false

		local function startAvatarEditor()
			screenGui.HackBody.Visible = false
			AvatarEditorMain.Start()
			notifyAppReady(AppNameEnum.AvatarEditor)
		end

		if startAvatarEditorAfterInitializing then
			startAvatarEditor()
		end

		openAvatarEditor = startAvatarEditor

		closeAvatarEditor = function()
			screenGui.HackBody.Visible = true
			AvatarEditorMain.Stop()
		end
	end)
end


local function installStudioTestingHooks(store)
	local ActionType = require(CoreGui.RobloxGui.Modules.Mobile.ActionType)
	print("Testing in Studio")
	print("")
	print("Use number keys:")
	print("1: AvatarEditor")
	print("2: Chat")
	print("")

	local function onKeyPress(inputObject, gameProcessedEvent)
		local actionMap = {
			[Enum.KeyCode.One] = function()
				store:Dispatch( {type = ActionType.OpenApp, appName = AppNameEnum.AvatarEditor} )
			end;

			[Enum.KeyCode.Two] = function()
				store:Dispatch( {type = ActionType.OpenApp, appName = AppNameEnum.Chat} )
			end;
		}

		(actionMap[inputObject.KeyCode] or function()end)()
	end

	game:GetService("UserInputService").InputBegan:connect(onKeyPress)
end


local initMobile

if not UserSettings().GameSettings:InStudioMode()
then
	initMobile = function()
		local appState = MobileAppState.new()
		local errorReporter = require(Modules.Common.LuaErrorReporter).new()

		GuiService:SetGlobalGuiInset(0, 0, 0, UserInputService.BottomBarSize.Y)
		local bottomBarChanged = UserInputService:GetPropertyChangedSignal("BottomBarSize")
		bottomBarChanged:Connect(function()
			GuiService:SetGlobalGuiInset(0, 0, 0, UserInputService.BottomBarSize.Y)
		end)

		appState.store.Changed:Connect(
			function(newState, oldState)
				if newState.OpenApp ~= oldState.OpenApp then
					errorReporter:setCurrentScreen(newState.OpenApp)
				end

				if oldState.OpenApp ~= newState.OpenApp then
					if newState.OpenApp == AppNameEnum.Chat then
						openChat()
					end

					if newState.OpenApp == AppNameEnum.AvatarEditor then
						openAvatarEditor()
					end

					if newState.OpenApp == AppNameEnum.ShareGameToChat then
						openShareGameToChat(newState.Parameters)
					end

					if oldState.OpenApp == AppNameEnum.Chat then
						closeChat()
					end

					if oldState.OpenApp == AppNameEnum.AvatarEditor then
						closeAvatarEditor()
					end

					if oldState.OpenApp == AppNameEnum.ShareGameToChat then
						closeShareGameToChat()
					end
				end

			end
		)
	end
else
	initMobile = function()
		local appState = MobileAppState.new()

		GuiService:SetGlobalGuiInset(0, 0, 0, 49)

		appState.store.Changed:Connect(
			function(newState, oldState)
				if oldState.OpenApp ~= newState.OpenApp then
					if newState.OpenApp == AppNameEnum.Chat then
						--openChat()
					end

					if newState.OpenApp == AppNameEnum.AvatarEditor then
						openAvatarEditor()
					end

					if oldState.OpenApp == AppNameEnum.Chat then
						--closeChat()
					end

					if oldState.OpenApp == AppNameEnum.AvatarEditor then
						closeAvatarEditor()
					end
				end
			end
		)

		installStudioTestingHooks(appState.store)
	end
end

initMobile()

