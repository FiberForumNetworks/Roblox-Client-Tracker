if not settings():GetFFlag("StudioGameSettingsAccessPermissions") then return nil end

local runService = game:GetService("RunService")

local PageName = "Access Permissions"

local FFlagGameSettingsReorganizeHeaders = settings():GetFFlag("GameSettingsReorganizeHeaders")
local FFlagStudioGameSettingsDisablePlayabilityForDrafts = settings():GetFFlag("StudioGameSettingsDisablePlayabilityForDrafts")

local FFlagStudioGameSettingsRestrictPermissions = game:DefineFastFlag("StudioGameSettingsRestrictPermissions", false)

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)

local Separator = require(Plugin.Src.Components.Separator)
local Header = require(Plugin.Src.Components.Header)
local RadioButtonSet = require(Plugin.Src.Components.RadioButtonSet)
local GameOwnerWidget = require(Plugin.Src.Components.Permissions.GameOwnerWidget)
local CollaboratorsWidget = require(Plugin.Src.Components.Permissions.CollaboratorsWidget)
local SearchbarWidget = require(Plugin.Src.Components.Permissions.CollaboratorSearchWidget)
local PlayabilityWidget = require(Plugin.Src.Components.PlayabilityWidget)

local AddChange = require(Plugin.Src.Actions.AddChange)
local AddWarning = require(Plugin.Src.Actions.AddWarning)
local DiscardWarning = require(Plugin.Src.Actions.DiscardWarning)
local SearchCollaborators = require(Plugin.Src.Thunks.SearchCollaborators)
local AddGroupCollaborator = require(Plugin.Src.Thunks.AddGroupCollaborator)

local createSettingsPage = require(Plugin.Src.Components.SettingsPages.createSettingsPage)

--Loads settings values into props by key
local function loadValuesToProps(getValue, state)
	local loadedProps = {
		IsActive = getValue("isActive"),
		IsFriendsOnly = getValue("isFriendsOnly"),
		Permissions = getValue("permissions"),
		GroupMetadata = getValue("groupMetadata"),
		OwnerThumbnail = getValue("ownerThumbnail"),
		OwnerName = getValue("creatorName"),
		OwnerId = getValue("creatorId"),
		OwnerType = getValue("creatorType"),
		Thumbnails = state.Thumbnails,
		SearchData = state.CollaboratorSearch,
		PrivacyType = getValue("privacyType"),
		StudioUserId = getValue("studioUserId"),
		GroupOwnerUserId = getValue("groupOwnerUserId"),
		IsCurrentlyActive = state.Settings.Current.isActive,
		CanManage = getValue("canManage"),
	}

	return loadedProps
end

--Implements dispatch functions for when the user changes values
local function dispatchChanges(setValue, dispatch)
	local dispatchFuncs = {
		IsFriendsOnlyChanged = setValue("isFriendsOnly"),
		PermissionsChanged = setValue("permissions"),
		GroupMetadataChanged = setValue("groupMetadata"),
		
		IsActiveChanged = function(button, willShutdown)
			if willShutdown then
				dispatch(AddWarning("isActive"))
			else
				dispatch(DiscardWarning("isActive"))
			end
			dispatch(AddChange("isActive", button.Id))
		end,

		SearchRequested = function(...)
			dispatch(SearchCollaborators(...))
		end,
		GroupCollaboratorAdded = function(...)
			dispatch(AddGroupCollaborator(...))
		end,
	}
	
	return dispatchFuncs
end

--Uses props to display current settings values
local function displayContents(page, localized, theme)
	local props = page.props

	-- The endpoint to check this fails a permission error if you do not have Manage, so we have
	-- to check it with a hack. In non-TC games you are running both client/server in Edit, but in
	-- TC you are only running the client. The server is run by RCC
	local isTeamCreate = runService:IsEdit() and not runService:IsServer()
	local accessPermissionsEnabled = isTeamCreate
	
	return {
		Header = FFlagGameSettingsReorganizeHeaders and Roact.createElement(Header, {
			Title = localized.Category[PageName],
			LayoutOrder = 0,
		}),

		Playability = FFlagStudioGameSettingsDisablePlayabilityForDrafts and Roact.createElement(PlayabilityWidget, {
			LayoutOrder = 10,
			Group = props.Group,
			Enabled = (props.PrivacyType ~= nil and props.PrivacyType ~= "Draft"),
			Selected = props.IsFriendsOnly and "Friends" or props.IsActive,
			SelectionChanged = function(button)
				if button.Id == "Friends" then
					props.IsFriendsOnlyChanged(true)
					props.IsActiveChanged({Id = true})
				else
					props.IsFriendsOnlyChanged(false)
					local willShutdown = (function()
						return props.IsCurrentlyActive and not button.Id
					end)()
					props.IsActiveChanged(button, willShutdown)
				end
			end,
		}),

		DEPRECATED_Playability = not FFlagStudioGameSettingsDisablePlayabilityForDrafts and Roact.createElement(RadioButtonSet, {
			Title = localized.Title.Playability,
			Description = localized.Playability.Header,
			LayoutOrder = 10,
			Buttons = {{
					Id = true,
					Title = localized.Playability.Public.Title,
					Description = localized.Playability.Public.Description,
				}, {
					Id = "Friends",
					Title = props.Group and localized.Playability.Group.Title or localized.Playability.Friends.Title,
					Description = props.Group and localized.Playability.Group.Description({group = props.Group})
						or localized.Playability.Friends.Description,
				}, {
					Id = false,
					Title = localized.Playability.Private.Title,
					Description = localized.Playability.Private.Description,
				},
			},
			Enabled = props.IsActive ~= nil and props.CanManage,
			--Functionality
			Selected = props.IsFriendsOnly and "Friends" or props.IsActive,
			SelectionChanged = function(button)
				if button.Id == "Friends" then
					props.IsFriendsOnlyChanged(true)
					props.IsActiveChanged({Id = true})
				else
					props.IsFriendsOnlyChanged(false)
					local willShutdown = (function()
						return props.IsCurrentlyActive and not button.Id
					end)()
					props.IsActiveChanged(button, willShutdown)
				end
			end,
		}),

		Separator1 = Roact.createElement(Separator, {
			LayoutOrder = 20,
			Size = UDim2.new(1, 0, 0, 1),
		}),
		
		OwnerWidget = Roact.createElement(GameOwnerWidget, {
			LayoutOrder = 30,
			
			Enabled = props.IsActive ~= nil and accessPermissionsEnabled,
			OwnerName = props.OwnerName,
			OwnerId = props.OwnerId,
			OwnerType = props.OwnerType,
			
			StudioUserId = props.StudioUserId,
			GroupOwnerUserId = props.GroupOwnerUserId,
			CanManage = props.CanManage,
			
			GroupMetadata = props.GroupMetadata,
			Permissions = props.Permissions,
			PermissionsChanged = props.PermissionsChanged,
			Thumbnails = props.Thumbnails,
		}),

		Separator2 = Roact.createElement(Separator, {
			LayoutOrder = 40,
			Size = UDim2.new(1, 0, 0, 1),
		}),

		TeamCreateWarning = (not accessPermissionsEnabled) and Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Subtitle, {
			Text = localized.AccessPermissions.TeamCreateWarning,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.warningColor,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = 50,
		})),
		
		SearchbarWidget = accessPermissionsEnabled and props.CanManage and Roact.createElement(SearchbarWidget, {
			LayoutOrder = 50,
			Enabled = props.IsActive ~= nil,

			SearchRequested = props.SearchRequested,
			SearchData = props.SearchData,
			Thumbnails = props.Thumbnails,
			Permissions = props.Permissions,
			GroupMetadata = props.GroupMetadata,
			GroupCollaboratorAdded = props.GroupCollaboratorAdded,
			PermissionsChanged = props.PermissionsChanged,
		}),
		
		CollaboratorListWidget = accessPermissionsEnabled and props.CanManage and Roact.createElement(CollaboratorsWidget, {
			LayoutOrder = 60,
			Enabled = props.IsActive ~= nil,

			StudioUserId = props.StudioUserId,
			GroupOwnerUserId = props.GroupOwnerUserId,
			OwnerId = props.OwnerId,
			OwnerType = props.OwnerType,
			CanManage = props.CanManage,

			GroupMetadata = props.GroupMetadata,
			Permissions = props.Permissions,
			PermissionsChanged = props.PermissionsChanged,
			GroupMetadataChanged = props.GroupMetadataChanged,
			Thumbnails = props.Thumbnails,
		}),
	}
end

local SettingsPage = createSettingsPage(PageName, loadValuesToProps, dispatchChanges)

local function AccessPermissions(props)
	return Roact.createElement(SettingsPage, {
		ContentHeightChanged = props.ContentHeightChanged,
		SetScrollbarEnabled = props.SetScrollbarEnabled,
		LayoutOrder = props.LayoutOrder,
		Content = displayContents,

		AddLayout = true,
	})
end

return AccessPermissions