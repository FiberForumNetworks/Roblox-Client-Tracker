--[[
	A scroll frame that will check the left space between currently rendered asset
    When scrolling down, it will try to re-render. If we found less than defined space or empty space 
    between the render asset and the canvas, then we will try to call request more function defined in the property 
    to fetch more assets. The function is responsible for the paging method to fetch more assets.
    After the asset is returned, we will re-calculate canvase size.
	This component will send out request to try to load more pages on didMount and after didUpdate.

	Necesarry Properties:
		UDim2 Position - The position of the scrolling frame.
		UDim2 Size - The size of the scrolling frame.

		function NextPageFunc - called during re-render when there is more empty spaces. This function should includes all the
			parameters needed for the request except for the currentPage. Target page will be determined by the infiScroller.

	Optional Properties:
        int LayoutOrder - sets order of element in layout
		int NextPageRequestDistance - space left in layout before making request to fetch more elements
		int CanvasHeight - used to specify height of canvas.
		Roact ref LayoutRef - used to calculate the height of the canvas.
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Roact)

local StyledScrollingFrame = require(Library.Components.StyledScrollingFrame)

local InfiniteScrollingFrame = Roact.PureComponent:extend("InfiniteScrollingFrame")

local DEFAULT_CANVAS_HEIGHT = 900

local DEFAULT_REQUEST_DISTANCE = 0

function InfiniteScrollingFrame:init(props)
	self.state = {
		isRequestingNextPage = false,
	}

	self.scrollingFrameRef = Roact.createRef()

	self.checkCanvasAndRequest = function(self)
		local scrollingFrame = self.scrollingFrameRef.current
		if not scrollingFrame then return end
		local canvasY = scrollingFrame.CanvasPosition.Y
		local windowHeight = scrollingFrame.AbsoluteWindowSize.Y
        local canvasHeight = scrollingFrame.CanvasSize.Y.Offset
        
        local requestDistance = self.props.NextPageRequestDistance or DEFAULT_REQUEST_DISTANCE

		-- Where the bottom of the scrolling frame is relative to canvas size
		local bottom = canvasY + windowHeight
		local dist = canvasHeight - bottom

		if dist <= requestDistance and not self.state.isRequestingNextPage then
			self:setState({
				isRequestingNextPage = true,
			})
			self.requestNextPage()
		end
	end

	self.onScroll = function()
		self.checkCanvasAndRequest(self)
	end

	self.requestNextPage = function()
		if self.props.NextPageFunc then
			self.props.NextPageFunc()
		end
	end
end

function InfiniteScrollingFrame:didMount()
	self.checkCanvasAndRequest(self)
end

function InfiniteScrollingFrame:didUpdate(previousProps, previousState)
	-- check if request has fetched more children
	if previousState.isRequestingNextPage then
		for k,v in pairs(self.props[Roact.Children]) do
			if v ~= previousProps[Roact.Children][k] then
				self:setState({
					isRequestingNextPage = false,
				})
				self.checkCanvasAndRequest(self)
			end
		end
	end
end

function InfiniteScrollingFrame:render()
    local props = self.props
    local state = self.state

    local Position = props.Position
    local Size = props.Size
    local LayoutOrder = props.LayoutOrder

    local layoutRef = props.LayoutRef and props.LayoutRef.current
	local canvasHeight = DEFAULT_CANVAS_HEIGHT
	if layoutRef then
		canvasHeight = layoutRef.AbsoluteContentSize.Y 
	elseif props.CanvasHeight then
		canvasHeight = props.CanvasHeight
	end

    return Roact.createElement(StyledScrollingFrame, {
        Position = Position,
        Size = Size,
        CanvasSize = UDim2.new(1, 0, 0, canvasHeight),
        LayoutOrder = LayoutOrder,
        ZIndex = 1,

        ScrollingEnabled = true,

        [Roact.Ref] = self.scrollingFrameRef,
        onScroll = self.onScroll,
    },
    props[Roact.Children])
end

return InfiniteScrollingFrame
