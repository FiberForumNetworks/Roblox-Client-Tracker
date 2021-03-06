local FastFlags = require(script.Parent.Parent.FastFlags)

local Paste = {}
Paste.__index = Paste

local function getFirstPose(Paths, copyPoseList)
	local firstPart = Paths.HelperFunctionsTable:firstValue(copyPoseList)
	return Paths.HelperFunctionsTable:firstValue(firstPart)
end

local function getNumPosesOutOfBounds(Paths, earliestPoseTime, pasteTime, copyPoseList, timeKey)
	local numPosesOutOfBounds = 0
	for partName, partPoseList in pairs(copyPoseList) do
		for _, poseCopyVars in ipairs(partPoseList) do
			local time = poseCopyVars[timeKey] - earliestPoseTime + pasteTime
			if time > Paths.DataModelClip:getLength() then
				numPosesOutOfBounds = numPosesOutOfBounds + 1
			end
		end
	end
	return numPosesOutOfBounds
end

local function promptPasteOutOfBoundsWarning(Paths, minimumRequiredLength, outOfBoundsPoseCount, okFunc)
	local msg = ""
	if Paths.DataModelClip:isLengthOk(minimumRequiredLength) then
		msg = string.format("%i pose(s) go past the length of this animation and\nwill be clamped. The required animation length to fit all\npose(s) is %.3f seconds. Click OK to proceed.", outOfBoundsPoseCount, minimumRequiredLength)
	else
		msg = string.format("%i pose(s) go past the length of this animation and\nwill be clamped. Animations cannot exceed a length of %i seconds.\nClick OK to proceed.", outOfBoundsPoseCount, Paths.DataModelClip.MaxLength)
	end
	Paths.GUIScriptPromptOKCancel:show(msg, okFunc)
end

local function calculateLatestPoseTime(Paths, copyPoseList, timeKey)
	local max = getFirstPose(Paths, copyPoseList)[timeKey]
	for _, partPoseList in pairs(copyPoseList) do
		for _, pose in ipairs(partPoseList) do
			max = math.max(pose.Time, max)
		end
	end
	return max
end

local function calculateEarliestPoseTime(Paths, copyPoseList, timeKey)
	local min = getFirstPose(Paths, copyPoseList)[timeKey]
	for _, partPoseList in pairs(copyPoseList) do
		for _, pose in ipairs(partPoseList) do
			min = math.min(pose.Time, min)
		end
	end
	return min
end

local function wasEntireKeyframeAtTimeCut(Paths, time)
	local keyframe = Paths.DataModelClip:getKeyframe(time)
	return keyframe == nil or (keyframe ~= nil and not Paths.HelperFunctionsTable:isNilOrEmpty(keyframe.Poses))
end

local function pasteInternal(Paths, atTime, scaleFactor, earliestPoseTime, copyPoseList, copyVariables, copiedInIKMode, registerUndo)
	registerUndo = registerUndo == nil and true or registerUndo
	if registerUndo then
		Paths.UtilityScriptUndoRedo:registerUndo(Paths.ActionPaste:new(Paths))
	end

	local keyframes = {}

	local showWarning = false

	for partName, partPoseList in pairs(copyPoseList) do
		local part = Paths.DataModelRig:getPart(partName)
		if FastFlags:isAutoAddBeginningKeyframeOn() then
			Paths.DataModelKeyframes:addStartingKeyframe(part)
		end
		for _, poseCopyVars in ipairs(partPoseList) do
			local time = poseCopyVars[copyVariables.Time]
			local newTime = nil
			if FastFlags:isFixRenameKeyOptionOn() and scaleFactor then
				local delta = time > atTime and time - atTime or atTime - time
				local sign = time > atTime and 1 or -1
				newTime = Paths.DataModelSession:formatTimeValue(atTime + (sign * delta * scaleFactor))
			else
				local deltaTime = earliestPoseTime - time
				newTime = atTime - deltaTime
			end
			newTime = Paths.DataModelSession:formatTimeValue(newTime)

			if keyframes[newTime] == nil then
				keyframes[newTime] = Paths.DataModelKeyframes:getOrCreateKeyframe(newTime, false)
				if FastFlags:isFixRenameKeyOptionOn() then
					if wasEntireKeyframeAtTimeCut(Paths, time) and Paths.HelperFunctionsTable:isNilOrEmpty(keyframes[newTime].Poses) then
						keyframes[newTime].Name = poseCopyVars.KeyframeName
					end
				end
			end
			local keyframe = keyframes[newTime]

			if (keyframe.Poses[part] == nil) then
				keyframe.Poses[part] = Paths.UtilityScriptPose:initializePose(Paths, keyframe, part)
			else
				showWarning = true
			end
			local targetPose = keyframe.Poses[part]

			if targetPose then
				for _,name in pairs(copyVariables) do
					if name ~= copyVariables.Time then
						targetPose[name] = poseCopyVars[name]
					end
				end
			end

			if FastFlags:isOptimizationsEnabledOn() then
				Paths.DataModelKeyframes:buildKeyframeListDiff(newTime, keyframe)
			end
		end
	end
	if FastFlags:isOptimizationsEnabledOn() then
		Paths.DataModelKeyframes:fireChangedEvent()
	else
		Paths.DataModelKeyframes.ChangedEvent:fire(Paths.DataModelKeyframes.keyframeList)
	end
	if showWarning then
		if FastFlags:isIKModeFlagOn() then
			Paths.GUIScriptPoseOverwriteWarning:show("The keys you're moving have replaced the ones on the original position")
		else
			Paths.GUIScriptPoseOverwriteWarning:show()
		end
	end

	if FastFlags:isIKModeFlagOn() and Paths.DataModelIKManipulator.IsIKModeActive then
		if not copiedInIKMode then
			Paths.HelperFunctionsWarningsAndPrompts:createApplyIKPromptForPaste(Paths)
		end
	end
end

function Paste:execute(Paths, atTime, scaleFactor, copyPoseList, copyVariables, copiedInIKMode, registerUndo)
	if Paths.GUIScriptPromptOKCancel:isActive() then
		return
	end
	local earliestPoseTime = calculateEarliestPoseTime(Paths, copyPoseList, copyVariables.Time)
	local latestPoseTime = calculateLatestPoseTime(Paths, copyPoseList, copyVariables.Time)
	local numPosesOutOfBounds = getNumPosesOutOfBounds(Paths, earliestPoseTime, atTime, copyPoseList, copyVariables.Time)
	local minimumRequiredLength = latestPoseTime - earliestPoseTime + atTime
	if numPosesOutOfBounds > 0 then
		promptPasteOutOfBoundsWarning(Paths, minimumRequiredLength, numPosesOutOfBounds, function()
			pasteInternal(Paths, atTime, scaleFactor, earliestPoseTime, copyPoseList, copyVariables, copiedInIKMode, registerUndo)
		end)
	else
		pasteInternal(Paths, atTime, scaleFactor, earliestPoseTime, copyPoseList, copyVariables, copiedInIKMode, registerUndo)
	end
end

local function getEarliestEventTime(copyEventsList)
	local min = next(copyEventsList)
	for time in pairs(copyEventsList) do
		min = math.min(time, min)
	end
	return min
end

function Paste:executePasteEvents(Paths, atTime, copyEventsList, registerUndo)
	local earliestEventTime = getEarliestEventTime(copyEventsList)
	registerUndo = registerUndo == nil and true or registerUndo
	if registerUndo then
		Paths.UtilityScriptUndoRedo:registerUndo(Paths.ActionPaste:new(Paths))
	end

	for time, markers in pairs(copyEventsList) do
		local offsetTime = earliestEventTime - time
		local newTime = atTime - offsetTime
		newTime = Paths.DataModelSession:formatTimeValue(newTime)
		local keyframe = Paths.DataModelKeyframes:getOrCreateKeyframe(newTime, false)
		keyframe.Markers = markers
		if FastFlags:isOptimizationsEnabledOn() then
			Paths.DataModelKeyframes:buildKeyframeListDiff(newTime, keyframe)
		end
	end

	if FastFlags:isOptimizationsEnabledOn() then
		Paths.DataModelKeyframes:fireChangedEvent()
	else
		Paths.DataModelKeyframes.ChangedEvent:fire(Paths.DataModelKeyframes.keyframeList)
	end
end

function Paste:new(Paths)
	local self = setmetatable({}, Paste)
	self.SubAction = Paths.ActionEditClip:new(Paths, {action = Paths.ActionEditClip.ActionType.paste})
	return self
end

function Paste:undo()
	self.SubAction:undo()
end

function Paste:redo()
	self.SubAction:redo()
end

function Paste:getDescription()
	return "Paste"
end

return Paste
