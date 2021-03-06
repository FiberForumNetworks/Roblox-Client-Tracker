-- singleton
local FastFlags = require(script.Parent.Parent.FastFlags)

local WarningsAndPrompts = {}

local function createApplyIKPrompt(Paths, title, desc)
	Paths.GUIScriptPromptYesNo:show(
		title,
		desc,
		"We will check all the existing keys and update them to work in IK",
		nil,
		function()
			Paths.GUIScriptWaitingDialog:show("Apply IK", "Updating keys now...", function()
				Paths.DataModelIKManipulator:requestCancelConstrainJoints()
			end)
			Paths.ActionConstrainKeyData:execute(Paths)
	end)
end

function WarningsAndPrompts:createApplyIKPromptForIsIKModeActive(Paths)
	createApplyIKPrompt(Paths, "Apply IK", "Do you want to apply IK constraint on the existing keys?")
end

function WarningsAndPrompts:createApplyIKPromptForPaste(Paths)
	createApplyIKPrompt(Paths, "Paste Keys", "Do you want to apply IK constraint on these keys?")
end

function WarningsAndPrompts:createApplyIKPromptForLoad(Paths)
	createApplyIKPrompt(Paths, "Load File", "Do you want to apply IK constraint on keys in the loading file?")
end

function WarningsAndPrompts:createRemoveIKPrompt(Paths)
	if not Paths.GUIScriptPromptYesNo:show(
		"Disable IK",
		"Do you want to disable IK for " ..Paths.DataModelRig:getName() .." joints?",
		"The IK constraint will no longer be applied to the joints",
		"Don't show this dialog again",
		function()
			Paths.DataModelIKManipulator:setIsIKModeActive(false)
	end) then
		Paths.DataModelIKManipulator:setIsIKModeActive(false)
	end
end

function WarningsAndPrompts:createInvalidPoseNamesInFileWarning(Paths, animationName, invalidPoseNames)
	if not Paths.HelperFunctionsTable:isNilOrEmpty(invalidPoseNames) then
		local msg = "Some joint names in the file can't match to any " ..Paths.DataModelRig:getName() .." joints: "
		for _, part in pairs(invalidPoseNames) do
			msg = msg ..part .."; "
		end
		Paths.GUIScriptAlertMessage:showWarning(
			"File '" ..animationName .."' can't be loaded correctly",
			msg,
			"Keys of these missing joints can't be loaded into Animation Editor")
	end
end

function WarningsAndPrompts:createNameChangeError(Paths)
	Paths.GUIScriptAlertMessage:showError(
		"Failed to change the joint name",
		"Part names can't be changed in Explorer when Animation Editor is open",
		nil)
end

function WarningsAndPrompts:createRigError(Paths, partsWithMultipleParents, part0MissingMotors, part1MissingMotors, circularRig)
	local msg = ""

	if #partsWithMultipleParents > 0 then
		msg = msg .."The following parts are affected by more than one part via a Motor6D: "
		for _, motor in pairs(partsWithMultipleParents) do
			msg = msg ..motor.Name .."; "
		end
		msg = msg .."\n\n"
	end

	if #part0MissingMotors > 0 then
		msg = msg .."The following Motor6D's do not have Part0 set: "
		for _, motor in pairs(part0MissingMotors) do
			msg = msg ..motor.Name .."; "
		end
		msg = msg .."\n\n"
	end

	if #part1MissingMotors > 0 then
		msg = msg .."The following Motor6D's do not have Part1 set: "
		for _, motor in pairs(part1MissingMotors) do
			msg = msg ..motor.Name .."; "
		end
		msg = msg .."\n\n"
	end

	if circularRig then
		msg = msg .."This rig contains a cycle between the connections of certain parts.\n\n"
	end

	Paths.GUIScriptAlertMessage:showError(
		"Rig Error(s) Detected",
		msg,
		nil)
end

function WarningsAndPrompts:createAnchoredPartsError(Paths)
	Paths.GUIScriptAlertMessage:showError(
		"All parts are anchored",
		"All of the parts on this model are anchored, making it non-animatable. Please un-anchor the parts on this model.",
		nil)
end

function WarningsAndPrompts:createNoMotorsError(Paths)
	Paths.GUIScriptAlertMessage:showError(
		"No Motor6D Joints Found",
		"A model needs to have their parts joined together by Motor6D's in order to properly animate.",
		nil)
end

function WarningsAndPrompts:createAttachmentWarning(Paths)
	Paths.GUIScriptAlertMessage:showWarning(
		"Failed to find matching attachments",
		"Attachment names between two body parts must match in order to properly generate a constraint",
		nil)
end

if FastFlags:isUseHipHeightInKeyframeSequencesOn() then
	function WarningsAndPrompts:createHipHeightMismatchWarning(Paths)
		Paths.GUIScriptAlertMessage:showWarning(
			"Hip Heights Don't Match",
			"The hip height of the model used to author this animation clip does not match the hip height of the model currently in the Animation Editor. Unexpected results may occur during playback.",
			nil)
	end
end

function WarningsAndPrompts:createMissingBodyPartsWarning(Paths, missingBodyParts)
	local msg = "We can't find the following joint names in " ..Paths.DataModelRig:getName() ..": "
	for _, part in ipairs(missingBodyParts) do
		msg = msg ..part .."; "
	end
	Paths.GUIScriptAlertMessage:showWarning(
		"This is not a valid R15 avatar",
		msg,
		"Correct the joint names by the naming requirements (see help) to avoid IK and file loading errors.")
end

return WarningsAndPrompts
