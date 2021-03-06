--[[
	The toolbox itself

	Props (many of these come from the store):
		number initialWidth = 0
		number initialSelectedBackgroundIndex = 1
		number initialSelectedCategoryIndex = 1
		string initialSearchTerm = ""
		number initialSelectedSortIndex = 1

		Backgrounds backgrounds
		Categories categories
		Suggestions suggestions
		Sorts sorts

		callback updatePageInfo()
		callback tryOpenAssetConfig, invoke assetConfig page with an assetId.
]]

local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local Util = Plugin.Core.Util
local Constants = require(Util.Constants)
local ContextGetter = require(Util.ContextGetter)
local ContextHelper = require(Util.ContextHelper)
local PageInfoHelper = require(Util.PageInfoHelper)
local getTabs = require(Util.getTabs)
local Analytics = require(Util.Analytics.Analytics)

local Types = Plugin.Core.Types
local Sort = require(Types.Sort)
local Category = require(Types.Category)
local RequestReason = require(Types.RequestReason)

local getNetwork = ContextGetter.getNetwork
local getSettings = ContextGetter.getSettings
local withTheme = ContextHelper.withTheme
local withLocalization = ContextHelper.withLocalization

local Components = Plugin.Core.Components
local TabSet = require(Components.TabSet)
local Footer = require(Components.Footer.Footer)
local Header = require(Components.Header)
local MainView = require(Components.MainView.MainView)
local SoundPreviewComponent = require(Components.SoundPreviewComponent)

local Requests = Plugin.Core.Networking.Requests
local UpdatePageInfoAndSendRequest = require(Requests.UpdatePageInfoAndSendRequest)
local ChangeMarketplaceTab = require(Requests.ChangeMarketplaceTab)
local GetRolesRequest = require(Requests.GetRolesRequest)
local GetRobuxBalance = require(Requests.GetRobuxBalance)

local FFlagFixToolboxInitLoad = settings():GetFFlag("FixToolboxInitLoad")
local FFlagStudioToolboxPluginPurchaseFlow = game:GetFastFlag("StudioToolboxPluginPurchaseFlow")

local Toolbox = Roact.PureComponent:extend("Toolbox")

function Toolbox:handleInitialSettings(categories)
	local networkInterface = getNetwork(self)
	local settings = getSettings(self)
	local initialSettings = settings:loadInitialSettings()

	local initialTab = Category.MARKETPLACE_KEY
	local initialSelectedCategoryIndex
	local initialSelectedSortIndex
	local initialSearchTerm
	local initialSelectedBackgroundIndex
	-- We should reset the categoryIndex and sortIndex since release of tabs.
	if FFlagFixToolboxInitLoad then
		initialSelectedCategoryIndex =  1
		initialSelectedSortIndex = 1
		initialSearchTerm = ""
		initialSelectedBackgroundIndex = initialSettings.backgroundIndex or 1
	else
		-- Load the initial values and make sure they're safe
		initialSelectedCategoryIndex = initialSettings.categoryIndex or 1
		if initialSelectedCategoryIndex < 1 or initialSelectedCategoryIndex > #self.props.categories then
			initialSelectedCategoryIndex = 1
		end

		-- We don't want initial search based on last search text for toolbox.
		-- But let's keep the option to re-add this in the future
		initialSearchTerm = ""

		initialSelectedSortIndex = initialSettings.sortIndex or 1
		if initialSelectedSortIndex < 1 or initialSelectedSortIndex > #self.props.sorts then
			initialSelectedSortIndex = Sort.getDefaultSortForCategory(initialSelectedCategoryIndex)
		end

		 initialSelectedBackgroundIndex = initialSettings.backgroundIndex or 1
	end

	-- Set the initial page info for the toolbox
	-- This will trigger a web request to load the first round of assets
	self.props.updatePageInfo(networkInterface, settings, {
		-- We should think about removing the index pattern
		currentTab = initialTab,
		categories = Category.MARKETPLACE,
		categoryIndex = initialSelectedCategoryIndex,
		searchTerm = initialSearchTerm,
		sorts = Sort.SORT_OPTIONS,
		sortIndex = initialSelectedSortIndex,
		groupIndex = 0,
		targetPage = 1,
		selectedBackgroundIndex = initialSelectedBackgroundIndex,
		requestReason = RequestReason.InitLoad,
	})
end

function Toolbox:init(props)
	self.state = {
		toolboxWidth = math.max(props.initialWidth or 0, Constants.TOOLBOX_MIN_WIDTH),
		showSearchOptions = false,
	}

	self.toolboxRef = Roact.createRef()

	-- If flag is on, use function that gets ref, else use old with rbx param
	self.onAbsoluteSizeChange = function()
		local toolboxWidth = math.max(self.toolboxRef.current.AbsoluteSize.x,
			Constants.TOOLBOX_MIN_WIDTH)
		if self.state.toolboxWidth ~= toolboxWidth then
			self:setState({
				toolboxWidth = toolboxWidth,
			})
		end
	end

	self:handleInitialSettings()

	self.toggleSearchOptions = function()
		local showSearchOptions = self.state.showSearchOptions

		if not showSearchOptions then
			Analytics.onSearchOptionsOpened()
		end

		self:setState({
			showSearchOptions = not showSearchOptions
		})
	end

	local networkInterface = getNetwork(self)
	local settings = getSettings(self)

	local function determineCategoryIndexOnTabChange(tabName, newCategories)
		if Category.CREATIONS_KEY == tabName then
			for index, data in ipairs(newCategories) do
				local isSelectable = data and (nil == data.selectable or data.selectable) -- nil for selectable defalts to selectable true
				if isSelectable then
					return index
				end
			end
		end
		return 1
	end

	self.changeMarketplaceTab = function(tabName)
		-- Change tab will always reset categoryIndex to 1.
		local newCategoryIndex = 1
		local newCategories = Category.getCategories(tabName, self.props.roles)
		local options = {
			categoryIndex = determineCategoryIndexOnTabChange(tabName, newCategories) or newCategoryIndex,
			searchTerm = "",
			sortIndex = 1,
			groupIndex = 0,
			selectedBackgroundIndex = 0,
		}
		self.props.changeMarketplaceTab(networkInterface, tabName, newCategories, settings, options)

		local currentCategory = PageInfoHelper.getCategory(self.props.categories, self.props.categoryIndex)
		local newCategory = Category.CREATIONS_KEY == tabName and "" or PageInfoHelper.getCategory(newCategories, newCategoryIndex)

		Analytics.onCategorySelected(
			currentCategory,
			newCategory
		)
	end
end

function Toolbox:didMount()
	if self.toolboxRef.current then
		self.toolboxRef.current:GetPropertyChangedSignal("AbsoluteSize"):connect(self.onAbsoluteSizeChange)
	end

	self:handleInitialSettings(self.props.categories)

	self.props.setRoles(getNetwork(self))

	if FFlagStudioToolboxPluginPurchaseFlow then
		self.props.getRobuxBalance(getNetwork(self))
	end
end

function Toolbox:render()
	return withTheme(function(theme)
		return withLocalization(function(_, localizedContent)
			local props = self.props
			local state = self.state

			local toolboxWidth = state.toolboxWidth
			local showSearchOptions = state.showSearchOptions

			local backgrounds = props.backgrounds
			local suggestions = props.suggestions or {}
			local currentTab = props.currentTab
			local tryOpenAssetConfig = props.tryOpenAssetConfig
			local pluginGui = props.pluginGui

			local toolboxTheme = theme.toolbox

			local onAbsoluteSizeChange = self.onAbsoluteSizeChange

			local tabHeight = Constants.TAB_WIDGET_HEIGHT
			local headerOffset = tabHeight

			return Roact.createElement("Frame", {
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),

				BorderSizePixel = 0,
				BackgroundColor3 = toolboxTheme.backgroundColor,

				[Roact.Ref] = self.toolboxRef,
				[Roact.Change.AbsoluteSize] = onAbsoluteSizeChange,
			}, {
				Tabs = Roact.createElement(TabSet, {
					Size = UDim2.new(1, 0, 0, Constants.TAB_WIDGET_HEIGHT),
					Tabs = getTabs(localizedContent),
					CurrentTab = currentTab,
					onTabSelected = self.changeMarketplaceTab,
				}),

				Header = Roact.createElement(Header, {
					Position = UDim2.new(0, 0, 0, headerOffset),
					maxWidth = toolboxWidth,
					onSearchOptionsToggled = self.toggleSearchOptions,
					pluginGui = pluginGui,
				}),

				MainView = Roact.createElement(MainView, {
					Position = UDim2.new(0, 0, 0, headerOffset + Constants.HEADER_HEIGHT + 1),
					Size = UDim2.new(1, 0, 1, -(Constants.HEADER_HEIGHT + Constants.FOOTER_HEIGHT + headerOffset + 2)),

					maxWidth = toolboxWidth,
					suggestions = suggestions,
					showSearchOptions = showSearchOptions,
					onSearchOptionsToggled = self.toggleSearchOptions,
					tryOpenAssetConfig = tryOpenAssetConfig,
				}),

				Footer = Roact.createElement(Footer, {
					backgrounds = backgrounds,
				}),

				AudioPreview = Roact.createElement(SoundPreviewComponent),
			})
		end)
	end)
end

local function mapStateToProps(state, props)
	state = state or {}
	local pageInfo = state.pageInfo or {}

	return {
		categories = pageInfo.categories or {},
		categoryIndex = pageInfo.categoryIndex or 1,
		currentTab = pageInfo.currentTab or Category.MARKETPLACE_KEY,
		sorts = pageInfo.sorts or {},
		roles = state.roles or {}
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setRoles = function(networkInterface)
			dispatch(GetRolesRequest(networkInterface))
		end,

		updatePageInfo = function(networkInterface, settings, newPageInfo)
			dispatch(UpdatePageInfoAndSendRequest(networkInterface, settings, newPageInfo))
		end,

		changeMarketplaceTab = function(networkInterface, tabName, newCategories, settings, options)
			dispatch(ChangeMarketplaceTab(networkInterface, tabName, newCategories, settings, options))
		end,

		getRobuxBalance = function(networkInterface)
			dispatch(GetRobuxBalance(networkInterface))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Toolbox)