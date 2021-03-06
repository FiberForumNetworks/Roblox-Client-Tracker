local FastFlags = require(script.Parent.Parent.FastFlags)
local AlertDialog = {}

AlertDialog.AlertType = {
	Error = {},
	Warning = {},
}
AlertDialog.Queue = {}
AlertDialog.AlertCount = 0

function AlertDialog:init(Paths)
	self.Paths = Paths
end

local function displayNextAlertIfAny(self)
	local nextAlert = self.Paths.HelperFunctionsTable:firstValue(self.Queue)
	if nextAlert then
		local alertType = nextAlert.Type
		if alertType == self.AlertType.Warning then
			self:showWarning(nextAlert.Warning, nextAlert.Body, nextAlert.Subtext)
		elseif alertType == self.AlertType.Error then
			self:showError(nextAlert.Warning, nextAlert.Body, nextAlert.Subtext)
		end
		table.remove(self.Queue, 1)
	end
end

local function destroy(self)
	if nil ~= self.GUI then
		self.Connections:terminate()
		self.Connections = nil
		
		self.GUI.Parent = nil
		self.GUI:Destroy()
		self.GUI = nil

		self.OKButton:terminate()
		self.HelpButton:terminate()
	end

	if FastFlags:useQWidgetsForPopupsOn() then
		if self.QtWindow then
			self.QtWindow:terminate()
			self.QtWindow = nil
		end
	else
		if self.SubWindow then
			self.SubWindow:terminate()
			self.SubWindow = nil
		end
	end

	displayNextAlertIfAny(self)
end

local function show(self, title, warning, body, subtext)
	self.GUI = self.Paths.GUIPopUpAlert:clone()

	if not FastFlags:useQWidgetsForPopupsOn() then
		self.Paths.UtilityScriptTheme:setColorsToTheme(self.GUI)
	end

	self.Connections = self.Paths.UtilityScriptConnections:new(self.Paths)

	self.OKButton = self.Paths.WidgetCustomImageButton:new(self.Paths, self.GUI.OkHelp.OK)
	self.HelpButton = self.Paths.WidgetCustomImageButton:new(self.Paths, self.GUI.OkHelp.Help)

	self.GUI.Header.TextLabel.Text = warning
	self.GUI.Body.Text = body

	local offsetWithoutSubtext = 0
	local subtextX = 0
	if subtext then
		self.GUI.Subtext.Text = subtext
		subtextX = self.Paths.HelperFunctionsWidget:getTextWidth(self.Paths, subtext, self.GUI.Subtext)
	else
		offsetWithoutSubtext = self.GUI.Subtext.AbsoluteSize.Y
		self.GUI.Subtext.Visible = false
	end

	-- resize popup to fit to largest text element
	local warningX = self.Paths.HelperFunctionsWidget:getTextWidth(self.Paths, warning, self.GUI.Header.TextLabel)
	local bodyTextX = self.Paths.HelperFunctionsWidget:getTextWidth(self.Paths, body, self.GUI.Body)
	local bodyFrameX = self.GUI.Body.Size.X.Offset
	local scaleFactor = math.ceil(bodyTextX / bodyFrameX)
	local bodyTextY = self.Paths.HelperFunctionsWidget:getTextHeight(self.Paths, body, self.GUI.Body)
	local maxX = math.max(warningX, math.max(subtextX, bodyTextX))
	local newSize = Vector2.new(maxX + (self.GUI.Size.X.Offset - self.GUI.Body.Size.X.Offset), self.GUI.Size.Y.Offset - (self.GUI.Body.AbsoluteSize.Y - bodyTextY + offsetWithoutSubtext))
	self.GUI.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
	self.GUI.Body.Size = UDim2.new(0, maxX, 0, bodyTextY)
	self.GUI.Header.Size = UDim2.new(0, maxX, 0, self.GUI.Header.Size.Y.Offset)
	self.GUI.Subtext.Size = UDim2.new(0, maxX, 0, self.GUI.Subtext.Size.Y.Offset)

	if FastFlags:useQWidgetsForPopupsOn() then
		self.QtWindow = self.Paths.GUIScriptQtWindow:new(self.Paths, title ..self.AlertCount, self.GUI, function() destroy(self) end, newSize)
		self.QtWindow:setTitle(title)
		self.AlertCount = self.AlertCount + 1
		self.QtWindow:turnOn(true)
	else
		self.SubWindow = self.Paths.GUIScriptSubWindow:new(self.Paths, self.GUI, self.Paths.GUIPopUps)
		self.SubWindow:turnOn(true)
		self.SubWindow:changeTitle(title)
		self.Connections:add(self.SubWindow.OnCloseEvent:connect(function() destroy(self) end))
	end
	self.Connections:add(self.GUI.OkHelp.OK.MouseButton1Click:connect(function()
		destroy(self)
	end))
	self.Connections:add(self.GUI.OkHelp.Help.MouseButton1Click:connect(function()
		self.Paths.ActionShowContextMenu:execute(self.Paths, self.Paths.ActionShowContextMenu.Type.Help)
	end))
end

function AlertDialog:showWarning(warning, body, subtext)
	if self.GUI then
		table.insert(self.Queue, {Type = self.AlertType.Warning, Warning = warning, Body = body, Subtext = subtext})
	else
		show(self, "Warning", warning, body, subtext)
		self.GUI.Header.ImageLabel.Warning.Visible = true
		self.GUI.Header.ImageLabel.Error.Visible = false
	end
end

function AlertDialog:showError(warning, body, subtext)
	if self.GUI then
		table.insert(self.Queue, {Type = self.AlertType.Error, Warning = warning, Body = body, Subtext = subtext})
	else
		show(self, "Error", warning, body, subtext)
		self.GUI.Header.ImageLabel.Warning.Visible = false
		self.GUI.Header.ImageLabel.Error.Visible = true
	end
end

function AlertDialog:terminate()
	self.Queue = {}
	destroy(self)
	self.Paths = nil
	self.AlertCount = 0
end

return AlertDialog