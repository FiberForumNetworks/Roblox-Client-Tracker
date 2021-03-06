--[[
	This component connects Rodux to the ui and manages its layout. It is
	composed of 3 frames: tabs, tools, and then tool components.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local TerrainEnums = require(Plugin.Src.Util.TerrainEnums)
local TabId = TerrainEnums.TabId

local Theme = require(Plugin.Src.ContextServices.Theming)
local withTheme = Theme.withTheme

local Localizing = require(Plugin.Packages.UILibrary.Localizing)
local withLocalization = Localizing.withLocalization

local Components = Plugin.Src.Components
local Tab = require(Components.Tab)
local ToolManager = require(Components.ToolManager)
local ToolRenderer = require(Components.ToolRenderer)

local Actions = Plugin.Src.Actions
local ChangeTab = require(Actions.ChangeTab)

local FFlagTerrainToolsFixScrollBarResize = game:GetFastFlag("TerrainToolsFixScrollBarResize")

local PADDING = 14
local Manager = Roact.PureComponent:extend(script.Name)
local TabOrder = {
	TabId.Create,
	TabId.Region,
	TabId.Edit,
}

function Manager:init()
	self.state = {
		upperContentYSize = 0,
	}

	self.updateRenderToolContentSize = function(rbx)
		if rbx then
			self:setState({
				upperContentYSize = rbx.AbsoluteContentSize.Y
			})
		end
	end
end
-- Separate because of weird UIListLayout behavior - just creates top tab layer
local function createTabs(props)
	local dispatchChangeTab = props.dispatchChangeTab
	local currTab = props.currentTab

	local buttonSize = UDim2.new(1 / #TabOrder, 0, 1, 0)

	local fragment = {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}),
	}

	for i, tabId in ipairs(TabOrder) do
		fragment[tabId] = Roact.createElement(Tab, {
			TabId = tabId,
			Size = buttonSize,
			OnClick = dispatchChangeTab,
			IsCurrent = currTab == tabId,
			LayoutOrder = i,
		})
	end

	return Roact.createFragment(fragment)
end

function Manager:render()
	local currentTab = self.props.currentTab
	return withTheme(function(theme)
		if FFlagTerrainToolsFixScrollBarResize then
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = theme.backgroundColor,
			}, {
				UILayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, PADDING),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),

				Upper = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, self.state.upperContentYSize),
					BackgroundTransparency = 1,
					[Roact.Ref] = self.upperFrame,
				}, {
					UILayout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, PADDING),
						SortOrder = Enum.SortOrder.LayoutOrder,

						[Roact.Change.AbsoluteContentSize] = self.updateRenderToolContentSize,
					}),

					Tabs = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 0, 29),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
					}, createTabs(self.props)),

					ToolBar = Roact.createElement(ToolManager, {
						CurrentTab = currentTab,
						LayoutOrder = 2,
					}),
				}),

				ToolPanel = Roact.createElement(ToolRenderer, {
					UpperContentYSize = self.state.upperContentYSize + PADDING,
					LayoutOrder = 3,
				}),
			})
		else
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = theme.backgroundColor,
			}, {
				UILayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, PADDING),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),

				Tabs = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 29),
					BackgroundTransparency = 1,
					LayoutOrder = 1,
				}, createTabs(self.props)),

				ToolBar = Roact.createElement(ToolManager, {
					CurrentTab = currentTab,
					LayoutOrder = 2,
				}),

				ToolPanel = Roact.createElement(ToolRenderer, {
					LayoutOrder = 3,
				}),
			})
		end
	end)
end

local function MapStateToProps (state, props)
	return {
		currentTab = state.Tools.currentTab,
	}
end

local function MapDispatchToProps (dispatch)
	return {
		dispatchChangeTab = function (tabName)
			dispatch(ChangeTab(tabName))
		end,
	}
end

return RoactRodux.connect(MapStateToProps, MapDispatchToProps)(Manager)
