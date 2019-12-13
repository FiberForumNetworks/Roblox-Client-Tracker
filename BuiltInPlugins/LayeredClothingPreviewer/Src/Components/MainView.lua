--[[
	The top level container of the Layered Clothing Previewer window

	Props:
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local UILibrary = require(Plugin.Packages.UILibrary)
local LayoutOrderIterator = UILibrary.Util.LayoutOrderIterator

local ViewportFramesMultiView = require(Plugin.Src.Components.ViewportFramesMultiView)
local withTheme = require(Plugin.Src.ContextServices.Theming).withTheme
local Controls = require(Plugin.Src.Components.Controls)

local MainView = Roact.PureComponent:extend("MainView")

function MainView:init()
	self.baseFrameRef = Roact.createRef()
end

function MainView:render()
	return withTheme(function(theme)
		local orderIterator = LayoutOrderIterator.new()

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0,
			BackgroundColor3 = theme.backgroundColor,

			[Roact.Ref] = self.baseFrameRef,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),

				[Roact.Change.AbsoluteContentSize] = function(rbx)
					if self.baseFrameRef.current then
						self.baseFrameRef.current.ViewportFramesMultiView.Size =
							UDim2.new(1, 0, 1, -self.baseFrameRef.current.Controls.AbsoluteSize.Y)
					end
				end,
			}),
			Controls = Roact.createElement(Controls, {
				LayoutOrder = orderIterator:getNextOrder(),
			}),
			ViewportFramesMultiView = Roact.createElement(ViewportFramesMultiView, {
				LayoutOrder = orderIterator:getNextOrder(),
			})
		})
	end)
end

return MainView