local GuiService = game:GetService("GuiService")

local InGameMenu = script.Parent.Parent
local SetMenuOpenAction = require(InGameMenu.Actions.SetMenuOpen)

return function(store)
	GuiService:SetMenuIsOpen(false, "InGameMenu")
	store:dispatch(SetMenuOpenAction(false))
end