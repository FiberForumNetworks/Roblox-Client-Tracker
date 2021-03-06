--[[
	
]]

local FFlagStudioGameSettingsRestrictPermissions = game:GetFastFlag("StudioGameSettingsRestrictPermissions")
local FFlagStudioGameSettingsPermisisonUpdateWarning = game:DefineFastFlag("StudioGameSettingsPermissionUpdateWarning", false)

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local withLocalization = require(Plugin.Src.Consumers.withLocalization)
local getThumbnailLoader = require(Plugin.Src.Consumers.getThumbnailLoader)
local getMouse = require(Plugin.Src.Consumers.getMouse)

local StudioService = game:GetService("StudioService")
local TextService = game:GetService("TextService")
--even though this is deprecated, the warning message will only be up for a while before being removed
local GuiService = game:GetService("GuiService")

local PermissionsConstants = require(Plugin.Src.Components.Permissions.PermissionsConstants)
local LOADING = require(Plugin.Src.Keys.loadingInProgress)
local DEFAULT_ADD_ACTION = PermissionsConstants.PlayKey
local MY_FRIENDS_KEY = "MyFriends"

local Searchbar = require(Plugin.Src.Components.Permissions.SearchBar)
local CollaboratorThumbnail = require(Plugin.Src.Components.Permissions.CollaboratorThumbnail)

local createFitToContent = require(Plugin.UILibrary.Components.createFitToContent)
local Hyperlink = require(Plugin.UILibrary.Studio.Hyperlink)

local FitToContent = createFitToContent("Frame", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 32),
})

local TextFitToContent = createFitToContent("Frame", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 0),
	FillDirection = Enum.FillDirection.Horizontal,
})

local PADDING = 16

local function getMatchesFromTable(text, t)
	local matches = {}

	for _,v in pairs(t) do
		if v[PermissionsConstants.SubjectNameKey]:lower():match(text:lower()) then
			table.insert(matches, v)
		end
	end

	return matches
end

local function getIsLoading(searchData)
	local cachedSearchResults = searchData.CachedSearchResults
	local searchTerm = searchData.SearchText

	return searchData.LocalUserGroups == LOADING
		or searchData.LocalUserFriends == LOADING
		or cachedSearchResults[searchTerm] == LOADING
		or (cachedSearchResults[searchTerm] == nil and searchTerm ~= "")
end

local function getIsFriend(subjectId, friendTable)
	for _,v in pairs(friendTable) do
		if subjectId == v[PermissionsConstants.SubjectIdKey] then
			return true
		end
	end
	return false
end

local function getMatches(searchData, permissions, groupMetadata)
	local cachedSearchResults = searchData.CachedSearchResults
	local searchTerm = searchData.SearchText

	local function compare(a,b)
		local a,b = a[PermissionsConstants.SubjectNameKey]:lower(), b[PermissionsConstants.SubjectNameKey]:lower()

		if a == b then return false end
		if a == searchTerm:lower() then return true end
		if b == searchTerm:lower() then return false end

		return a < b
	end
	
	local matches
	if FFlagStudioGameSettingsRestrictPermissions then
		matches = {Users={}}
	else
		matches = {Users={}, Groups={}}
	end
	if cachedSearchResults[searchTerm] and cachedSearchResults[searchTerm] ~= LOADING then
		local rawUserMatches = cachedSearchResults[searchTerm][PermissionsConstants.UserSubjectKey]
		local userMatches = {}

		local rawFriendMatches = typeof(searchData.LocalUserFriends) == "table" and getMatchesFromTable(searchTerm, searchData.LocalUserFriends) or {}
		table.sort(rawFriendMatches, compare)

		local matchedUsers = {}
		for _,v in pairs(rawUserMatches) do
			local subjectId = v[PermissionsConstants.SubjectIdKey]
			if not permissions[PermissionsConstants.UserSubjectKey][subjectId] then
				table.insert(userMatches, v)
				matchedUsers[subjectId] = true
			end
		end

		-- Insert friends after exact match (if it exists), but before the rest of the web results (if they exist)
		local firstUserIsExactMatch = #matchedUsers > 0 and matchedUsers[1][PermissionsConstants.SubjectNameKey]:lower() == searchTerm:lower()
		local position = math.min(firstUserIsExactMatch and 1 or 2, #userMatches + 1)
		for _,v in pairs(rawFriendMatches) do
			local subjectId = v[PermissionsConstants.SubjectIdKey]
			if not (permissions[PermissionsConstants.UserSubjectKey][subjectId] or matchedUsers[subjectId]) then
				table.insert(userMatches, position, v)
				position = position + 1
			end
		end

		matches.Users = userMatches
		
		if not FFlagStudioGameSettingsRestrictPermissions then
			local rawGroupMatches = cachedSearchResults[searchTerm][PermissionsConstants.GroupSubjectKey]
			local groupMatches = {}

			local rawMyGroups = typeof(searchData.LocalUserGroups) == "table" and getMatchesFromTable(searchTerm, searchData.LocalUserGroups) or {}
			table.sort(rawMyGroups, compare)

			local matchedGroups = {}
			for _,v in pairs(rawGroupMatches) do
				if not groupMetadata[v[PermissionsConstants.SubjectIdKey]] then
					table.insert(groupMatches, v)
					matchedGroups[v[PermissionsConstants.SubjectIdKey]] = true
				end
			end

			-- Insert your groups after exact match (if it exists), but before the rest of the web results (if they exist)
			local firstGroupIsExactMatch = #matchedGroups > 0 and matchedGroups[1][PermissionsConstants.SubjectNameKey]:lower() == searchTerm:lower()
			local position = math.min(firstGroupIsExactMatch and 1 or 2, #groupMatches + 1)
			for _,v in pairs(rawMyGroups) do
				-- Group web search already matched this. Don't duplicate it
				
				if not (matchedGroups[v[PermissionsConstants.SubjectIdKey]] or groupMetadata[v[PermissionsConstants.SubjectIdKey]]) then
					table.insert(groupMatches, position, v)
					position = position + 1
				end
			end

			matches.Groups = groupMatches
		end
	end

	return matches
end

local function getResults(searchTerm, matches, thumbnailLoader, localized)
	local results
	if searchTerm == "" then
		return {}
		
		-- TODO (awarwick) 6/3/2019 V2 Access Permissions
		--[[
		results = {
			[localized.AccessPermissions.Collaborators.FriendsCollaboratorType] = {
				{
					Icon = Roact.createElement(CollaboratorThumbnail, {
						Image = "rbxasset://textures/GameSettings/friendsIcon.png",
						Size = UDim2.new(1, 0, 1, 0),
					}),
					Name = localized.AccessPermissions.Collaborators.MyFriendsCollaborator,
					Key = MY_FRIENDS_KEY,
				},
				LayoutOrder = 0,
			}
		}
		]]
	else
		if FFlagStudioGameSettingsRestrictPermissions then
			results = {Users={LayoutOrder=0}}
		else
			results = {Users={LayoutOrder=0}, Groups={LayoutOrder=1}}
		end
		for _, user in pairs(matches.Users) do
			if #results.Users + 1 > PermissionsConstants.MaxSearchResultsPerSubjectType then break end
			
			table.insert(results.Users, {
				Icon = Roact.createElement(CollaboratorThumbnail, {
					Image = thumbnailLoader.getThumbnail(PermissionsConstants.UserSubjectKey, user[PermissionsConstants.SubjectIdKey]),
					Size = UDim2.new(1, 0, 1, 0),
					UseMask = true,
				}),
				Name = user[PermissionsConstants.SubjectNameKey],
				Key = {Type=PermissionsConstants.UserSubjectKey, Id=user[PermissionsConstants.SubjectIdKey], Name=user[PermissionsConstants.SubjectNameKey]},
			})
		end
		if not FFlagStudioGameSettingsRestrictPermissions then
			for _, group in pairs(matches.Groups) do
				if #results.Groups + 1 > PermissionsConstants.MaxSearchResultsPerSubjectType then break end
				table.insert(results.Groups, {
					Icon = Roact.createElement(CollaboratorThumbnail, {
						Image = thumbnailLoader.getThumbnail(PermissionsConstants.GroupSubjectKey, group[PermissionsConstants.SubjectIdKey]),
						Size = UDim2.new(1, 0, 1, 0),
					}),
					Name = group[PermissionsConstants.SubjectNameKey],
					Key = {Type=PermissionsConstants.GroupSubjectKey, Id=group[PermissionsConstants.SubjectIdKey], Name=group[PermissionsConstants.SubjectNameKey]},
				})
			end
		end

		if FFlagStudioGameSettingsRestrictPermissions then
			results = {
				[localized.AccessPermissions.Collaborators.UsersCollaboratorType] = #results.Users > 0 and results.Users or nil,
			}
		else
			results = {
				[localized.AccessPermissions.Collaborators.UsersCollaboratorType] = #results.Users > 0 and results.Users or nil,
				[localized.AccessPermissions.Collaborators.GroupsCollaboratorType] = #results.Groups > 0 and results.Groups or nil,
			}
		end
	end

	return results
end

local CollaboratorSearchWidget = Roact.PureComponent:extend("CollaboratorSearchWidget")

function CollaboratorSearchWidget:render()
	local props = self.props
	local searchData = props.SearchData
	local searchTerm = searchData.SearchText

	local thumbnailLoader = getThumbnailLoader(self)

	local matches = getMatches(searchData, props.Permissions, props.GroupMetadata)
	local isLoading = getIsLoading(searchData)

	local numCollaborators = -1 -- Offset and don't count the owner
	for _,_ in pairs(props.GroupMetadata) do
		numCollaborators = numCollaborators + 1
	end
	for _,_ in pairs(props.Permissions[PermissionsConstants.UserSubjectKey]) do
		numCollaborators = numCollaborators + 1
	end

	local maxCollaborators = game:GetFastInt("MaxAccessPermissionsCollaborators")
	local tooManyCollaborators = numCollaborators >= maxCollaborators

	local function collaboratorAdded(collaboratorType, collaboratorId, collaboratorName, action)
		local newPermissions
		if collaboratorType == PermissionsConstants.UserSubjectKey then
			newPermissions = Cryo.Dictionary.join(props.Permissions, {
				[collaboratorType] = Cryo.Dictionary.join(props.Permissions[collaboratorType], {
					[collaboratorId] = {
						[PermissionsConstants.SubjectNameKey] = collaboratorName,
						[PermissionsConstants.SubjectIdKey] = collaboratorId,
						[PermissionsConstants.ActionKey] = action,
						[PermissionsConstants.IsFriendKey] = getIsFriend(collaboratorId, searchData.LocalUserFriends),
					}
				})
			})
		elseif collaboratorType == PermissionsConstants.GroupSubjectKey then
			props.GroupCollaboratorAdded(collaboratorId, collaboratorName, action)
		else
			error("Unsupported type: "..tostring(collaboratorType))
		end
		
		if newPermissions then
			props.PermissionsChanged(newPermissions)
		end
	end

	return withTheme(function(theme)
		return withLocalization(function(localized)
			local results = getResults(searchTerm, matches, thumbnailLoader, localized)
			local tooManyCollaboratorsText = localized.AccessPermissions.Searchbar.TooManyCollaboratorsText({
				maxNumCollaborators = maxCollaborators,
			})

			local TitleTextSize = TextService:GetTextSize(localized.Title.Collaborators, theme.fontStyle.Subtitle.TextSize, 
				theme.fontStyle.Subtitle.Font, Vector2.new(math.huge, math.huge))
	
			local WarningTextSize = TextService:GetTextSize(localized.AccessPermissions.Update.Text, theme.fontStyle.Smaller.TextSize, 
				theme.fontStyle.Smaller.Font, Vector2.new(math.huge, math.huge))

			local HyperlinkTextSize = TextService:GetTextSize(localized.AccessPermissions.Update.HyperlinkText, theme.fontStyle.Smaller.TextSize, 
				theme.fontStyle.Smaller.Font, Vector2.new(math.huge, math.huge))
	
			return Roact.createElement(FitToContent, {
				BackgroundTransparency = 1,
				LayoutOrder = props.LayoutOrder,
			}, {
				Title = not FFlagStudioGameSettingsPermisisonUpdateWarning and Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Subtitle, {
					LayoutOrder = 0,
					
					Text = localized.Title.Collaborators,
					TextXAlignment = Enum.TextXAlignment.Left,
					
					BackgroundTransparency = 1,
				})),

				WarningLayout = FFlagStudioGameSettingsPermisisonUpdateWarning and Roact.createElement(TextFitToContent, {
					BackgroundTransparency = 1,
					LayoutOrder = 0,
				}, {
					Title = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Subtitle, {
						LayoutOrder = 0,

						Size = UDim2.new(1, -WarningTextSize.X - HyperlinkTextSize.X - PADDING, 0, theme.fontStyle.Subtitle.TextSize),
						
						Text = localized.Title.Collaborators,
						TextXAlignment = Enum.TextXAlignment.Left,
						
						BackgroundTransparency = 1,
					})),

					WarningText = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Smaller, {
						LayoutOrder = 1,

						Size = UDim2.new(0, WarningTextSize.X + PADDING, 0, theme.fontStyle.Smaller.TextSize),
						
						Text = localized.AccessPermissions.Update.Text,
						TextXAlignment = Enum.TextXAlignment.Left,
						
						BackgroundTransparency = 1,
					})),

					Hyperlink = Roact.createElement(Hyperlink, {
						LayoutOrder = 2,
						Enabled = true,
						
						Text = localized.AccessPermissions.Update.HyperlinkText,
						TextSize = theme.fontStyle.Smaller.TextSize,

						OnClick = function()
							GuiService:OpenBrowserWindow("https://devforum.roblox.com/t/introducing-game-permissions/428956")
						end,
						Mouse = getMouse(self):getNativeMouse(),
					}),
				}),

				Searchbar = Roact.createElement(Searchbar, {
					LayoutOrder = 1,
					Enabled = props.Enabled and not tooManyCollaborators,

					HeaderHeight = 25,
					ItemHeight = 50,

					ErrorText = tooManyCollaborators and tooManyCollaboratorsText or nil,
					DefaultText = localized.AccessPermissions.Searchbar.DefaultText,
					NoResultsText = localized.AccessPermissions.Searchbar.NoResultsText,
					LoadingMore = isLoading,

					onSearchRequested = function(text)
						props.SearchRequested(text, true)
					end,
					onTextChanged = function(text)
						props.SearchRequested(text, false)
					end,
					OnItemClicked = function(key)
						if key == MY_FRIENDS_KEY then
							print("TODO: enable friends option")
						else
							collaboratorAdded(key.Type, key.Id, key.Name, DEFAULT_ADD_ACTION)
						end
					end,
					
					Results = results,
				}),
			})
		end)
	end)
end

return CollaboratorSearchWidget