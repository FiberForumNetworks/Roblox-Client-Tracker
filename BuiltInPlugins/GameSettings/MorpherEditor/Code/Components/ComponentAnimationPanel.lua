local paths = require(script.Parent.Parent.Paths)

local FFlagWorldAvatarLocalization = game:GetFastFlag("WorldAvatarLocalization")

local AnimationPanel = paths.Roact.Component:extend("ComponentAnimationPanel")

function AnimationPanel:render()
	local animationTypeSetFunctions = {
		[paths.ConstantTemplate.AnimationStandard] = paths.StateModelTemplate.setAnimationStandard,
		[paths.ConstantTemplate.PlayerChoice] = paths.StateModelTemplate.setAnimationPlayerChoice
	}

	return paths.Roact.createElement(paths.ComponentRadioButtonSetPanel, {
		Title = FFlagWorldAvatarLocalization and self.props.LocalizedContent.Title.Animation or "Animation",
		Buttons = {{
				Id = paths.ConstantTemplate.AnimationStandard,
				Title = FFlagWorldAvatarLocalization and self.props.LocalizedContent.Animation.Standard or "Standard",
			}, {
				Id = paths.ConstantTemplate.PlayerChoice,
				Title = FFlagWorldAvatarLocalization and self.props.LocalizedContent.Animation.PlayerChoice or "Player Choice",
			},
		},
		Enabled = self.props.IsEnabled,
		LayoutOrder = self.props.LayoutOrder,
		Selected = paths.StateInterfaceTemplates.getStateModelTemplate(self.props).AnimationValue,
		Mouse = self.props.Mouse,
		SelectionChanged = function(button)
			local newTemplateModel = paths.StateInterfaceTemplates.getStateModelTemplateCopy(self.props)
			animationTypeSetFunctions[button.Id](newTemplateModel)
			self.props.clobberTemplate(self.props.template, newTemplateModel)
		end,
	})
end

return AnimationPanel