--[[
	An item that displays game owner access permissions and can be interacted with to change them
	if the owner is a group. User owners and group owner roles can never be changed.

	Props:
		string OwnerName - Name of collaborator. Displayed in primary label
		string OwnerThumbnail - Icon to display in item (e.g. user headshot, group logo, etc)
		
		bool Enabled - Whether the component is enabled or not
]]

local FFlagStudioGameSettingsRestrictPermissions = game:GetFastFlag("StudioGameSettingsRestrictPermissions")

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local withLocalization = require(Plugin.Src.Consumers.withLocalization)

local PermissionsConstants = require(Plugin.Src.Components.Permissions.PermissionsConstants)

local getThumbnailLoader = require(Plugin.Src.Consumers.getThumbnailLoader)
local CollaboratorItem = require(Plugin.Src.Components.Permissions.CollaboratorItem)
local GroupCollaboratorItem = require(Plugin.Src.Components.Permissions.GroupCollaboratorItem)


local createFitToContent = require(Plugin.UILibrary.Components.createFitToContent)

local FitToContent = createFitToContent("Frame", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 32),
})

local function getGroupOwnerPermissions(props, localized)
	if not props.CanManage then return {} end
	
	local permissions = {
		Cryo.Dictionary.join({Key = PermissionsConstants.PlayKey, Display = localized.AccessPermissions.ActionDropdown.PlayLabel, Description = localized.AccessPermissions.ActionDropdown.PlayDescription}),
		Cryo.Dictionary.join({Key = PermissionsConstants.EditKey, Display = localized.AccessPermissions.ActionDropdown.EditLabel, Description = localized.AccessPermissions.ActionDropdown.EditDescription}),
	}
	
	if not FFlagStudioGameSettingsRestrictPermissions then
		if props.GroupOwnerUserId and props.GroupOwnerUserId == props.StudioUserId then
			permissions = Cryo.List.join(
				permissions,
				{{Key = PermissionsConstants.AdminKey, Display = localized.AccessPermissions.ActionDropdown.AdminLabel, Description = localized.AccessPermissions.ActionDropdown.AdminDescription}}
			)
		end
	end
	
	return permissions
end

local function getUserOwnerPermissions()
	return {} -- Owner can never be changed
end

local GameOwnerWidget = Roact.PureComponent:extend("GameOwnerWidget")

function GameOwnerWidget:render()
	local props = self.props
	local thumbnailLoader = getThumbnailLoader(self)

	return withLocalization(function(localized)
		return withTheme(function(theme)
			local function rolePermissionChanged(roleId, newPermission)
				-- Cryo does not provide a good way to replace a deep key
				local newPermissions = 	Cryo.Dictionary.join(props.Permissions, {[PermissionsConstants.RoleSubjectKey]=Cryo.Dictionary.join(
											props.Permissions[PermissionsConstants.RoleSubjectKey], {[roleId]=Cryo.Dictionary.join(
												props.Permissions[PermissionsConstants.RoleSubjectKey][roleId], {[PermissionsConstants.ActionKey]=newPermission}
											)}
										)})
				
				props.PermissionsChanged(newPermissions)
			end
		
			local collaboratorItem
			if props.OwnerType == Enum.CreatorType.User then
				collaboratorItem = Roact.createElement(CollaboratorItem, {
					LayoutOrder = 1,
					Removable = false,
					
					CollaboratorName = props.OwnerName,
					CollaboratorId = props.OwnerId,
					CollaboratorIcon = thumbnailLoader.getThumbnail(PermissionsConstants.UserSubjectKey, props.OwnerId),
					UseMask = true,
					
					Action = localized.AccessPermissions.ActionDropdown.OwnerLabel,
					Enabled = props.Enabled,
					
					Items = getUserOwnerPermissions(props),
					RolePermissionChanged = nil, -- Owner permissions can't be changed
				})
			else
				collaboratorItem = Roact.createElement(GroupCollaboratorItem, {
					LayoutOrder = 1,
					Removable = false,
					
					GroupName = props.GroupMetadata[props.OwnerId].Name,
					GroupId = props.OwnerId,
					IsOwner = true,
					Enabled = props.Enabled,

					Items = getGroupOwnerPermissions(props, localized),
					
					RolePermissionChanged = rolePermissionChanged,
					GroupPermissionChanged = nil, -- Cannot be bulk-changed because Owner is locked

					Permissions = props.Permissions,

					Thumbnails = props.Thumbnails,
				})
			end
		
			return Roact.createElement(FitToContent, {
				LayoutOrder = props.LayoutOrder or 0,
				BackgroundTransparency = 1,
			}, {
				Title = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Subtitle, {
					LayoutOrder = 0,
					
					Text = localized.Title.GameOwner,
					TextXAlignment = Enum.TextXAlignment.Left,
					
					BackgroundTransparency = 1,
				})),
				
				Owner = collaboratorItem,
			})
		end)
	end)
end

return GameOwnerWidget