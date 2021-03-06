--[[
    Prompts the user to confirm whether they want to discard the selected drafts

    Props:
    Drafts - The list of draft instances that will be discarded
    ChoiceSelected - Callback to invoke whenever the user selects an option
        in the dialog. True for confirm, false for cancel / closing the dialog
--]]

local TextService = game:GetService("TextService")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local UILibrary = require(Plugin.Packages.UILibrary)

local withTheme = require(Plugin.Src.ContextServices.Theming).withTheme
local withLocalization = UILibrary.Localizing.withLocalization

local BulletPoint = UILibrary.Component.BulletPoint
local createFitToContent = UILibrary.Component.createFitToContent
local StyledDialog = UILibrary.Component.StyledDialog
local StyledScrollingFrame = UILibrary.Component.StyledScrollingFrame

local FitToContent = createFitToContent("Frame", "UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    FillDirection = Enum.FillDirection.Vertical,
})

local HEADER_TEXT_SIZE = 22
local BUTTON_TEXT_SIZE = 22
local BULLET_TEXT_SIZE = 18

local DIALOG_SIZE = Vector2.new(473, 300)
local DIALOG_CONTENTS_PADDING = 32

local BORDER_PADDING = 35
local BUTTON_PADDING = 25
local BUTTON_HEIGHT = 35
local BUTTON_WIDTH = 125

local DraftDiscardDialog = Roact.PureComponent:extend("DraftDiscardDialog")

function DraftDiscardDialog:init()
    self:setState({})

    self.canvasRef = Roact.createRef()
    self.headerRef = Roact.createRef()

	self.contentSizeChanged = function(contentSize)
		local canvas = self.canvasRef.current
		if canvas then
			canvas.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
		end
    end

    -- Update header height based on text size, and then offset the canvas to be below the header
    self.updateContentGeometry = function()
        local header = self.headerRef.current
        local canvas = self.canvasRef.current
		local textSize = TextService:GetTextSize(
			header.Text,
			HEADER_TEXT_SIZE,
			Enum.Font.SourceSans,
			Vector2.new(header.AbsoluteSize.X, math.huge)
        )

        local headerHeight = textSize.Y
        local canvasOffset = headerHeight + DIALOG_CONTENTS_PADDING
        header.Size = UDim2.new(1, 0, 0, headerHeight)
        canvas.Parent.Size = UDim2.new(1, 0, 1, -canvasOffset)
        canvas.Parent.Position = UDim2.new(0, 0, 0, canvasOffset)
	end
end

function DraftDiscardDialog:didMount()
	local header = self.headerRef.current
	self.textConnection = header:GetPropertyChangedSignal("AbsoluteSize"):connect(self.updateContentGeometry)
	self.updateContentGeometry()
end

function DraftDiscardDialog:render()
    local drafts = self.props.Drafts
    local choiceSelected = self.props.ChoiceSelected

    local bullets = {}
    for i,draft in ipairs(drafts) do
        bullets[draft] = Roact.createElement(BulletPoint, {
            Text = draft.Name,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextSize = BULLET_TEXT_SIZE,

            LayoutOrder = i,
        })
    end

    return withTheme(function(theme)
        return withLocalization(function(localization)
            return Roact.createElement(StyledDialog, {
                Buttons = {
                    {Key = true, Text = localization:getText("Dialog", "Yes")},
                    {Key = false, Style = "Primary", Text = localization:getText("Dialog", "No")},
                },
                OnButtonClicked = choiceSelected,
                OnClose = function() choiceSelected(false) end,

                TextSize = BUTTON_TEXT_SIZE,
                Size = DIALOG_SIZE,
                BorderPadding = BORDER_PADDING,
                ButtonPadding = BUTTON_PADDING,
                ButtonHeight = BUTTON_HEIGHT,
                ButtonWidth = BUTTON_WIDTH,

                Title = localization:getText("DiscardDialog", "Title"),
            }, {
                Header = Roact.createElement("TextLabel", {
                    BackgroundTransparency = 1,

                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,

                    Text = localization:getText("DiscardDialog", "ConfirmQuestion"),
                    TextSize = HEADER_TEXT_SIZE,
                    Font = theme.Dialog.HeaderFont,
                    TextColor3 = theme.Dialog.HeaderTextColor,

                    [Roact.Ref] = self.headerRef,
                }),

                DraftList = Roact.createElement(StyledScrollingFrame, {
                    BackgroundTransparency = 1,
				    [Roact.Ref] = self.canvasRef,
                }, {
                    UIListLayout = Roact.createElement("UIListLayout", {
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        Padding = UDim.new(0, 0),

                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,

                        [Roact.Change.AbsoluteContentSize] = function(rbx)
                            self.contentSizeChanged(rbx.AbsoluteContentSize)
                        end,
                    }),

                    FitContent = Roact.createElement(FitToContent, {
                        BackgroundTransparency = 1,
                    }, bullets),
                })
            })
        end)
    end)
end

return DraftDiscardDialog