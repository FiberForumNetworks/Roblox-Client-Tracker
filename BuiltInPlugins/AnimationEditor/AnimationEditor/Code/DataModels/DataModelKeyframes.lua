-- singleton

local FastFlags = require(script.Parent.Parent.FastFlags)

local Keyframes = {}

Keyframes.keyframeList = {}
if FastFlags:isOptimizationsEnabledOn() then
	Keyframes.keyframeChanges = {}
end
Keyframes.ChangedEvent = nil
Keyframes.PoseTransformChangedEvent = nil

function Keyframes:init(Paths)
	self.Paths = Paths
	Keyframes.ChangedEvent = Paths.UtilityScriptEvent:new()
	Keyframes.PoseTransformChangedEvent = Paths.UtilityScriptEvent:new()
end

function Keyframes:terminate()
	Keyframes.PoseTransformChangedEvent = nil
	Keyframes.ChangedEvent = nil
end

function Keyframes:initPostGUICreate()
	self.Connections = self.Paths.UtilityScriptConnections:new(self.Paths)
	Keyframes.Connections:add(self.Paths.InputKeyboard.KeyPressedEvent:connect(function(theKey)
		if Enum.KeyCode.K == theKey and self.Paths.DataModelSession:areAnyDataItemsSelected() then				
			local dataItems = self.Paths.DataModelSession:getSelectedDataItems()			
			self:getOrCreateKeyframes(dataItems, self.Paths.DataModelSession:getScrubberTime())						
		elseif self.Paths.InputKeyboard:isKeyBackSpaceOrDelete(theKey) then
			self:deleteSelectedPosesAndEmptyKeyframes()
		end
	end))
end

function Keyframes:terminatePreGUIDestroy()
	self.Connections:terminate()
	self.Connections = nil
end

function deletePose(self, keyframe, part)
	if self:canDeletePose(keyframe, part) then
		keyframe.Poses[part] = nil
		if FastFlags:isOptimizationsEnabledOn() then
			self:buildKeyframeListDiff(keyframe.Time, keyframe)
		end
	end
end

function Keyframes:buildKeyframeListDiff(originalTime, newKeyframe)
	if newKeyframe then
		self.keyframeChanges[originalTime] = newKeyframe
	else
		self.keyframeChanges[originalTime] = {}
	end
end

function Keyframes:fireChangedEvent()
	self.ChangedEvent:fire(self.keyframeChanges)
	self.keyframeChanges = {}
end

function Keyframes:deleteSelectedPosesAndEmptyKeyframes(registerUndo)
	registerUndo = registerUndo == nil and true or registerUndo
	local keyframes = self.Paths.DataModelSession:getSelectedKeyframes()

	-- we only want to register undo for the first key that gets deleted, this
	-- way when we undo the deletion all of the keys come back at once, rather
	-- then having to undo for each key
	local firstUndo = true and registerUndo
	for time, poses in pairs(keyframes) do
		for _, pose in pairs(poses) do
			if self.Paths.DataModelRig:getPartInclude(pose.Name) then
				self:deletePoseAndEmptyKeyframe(pose:getPart(), time, firstUndo, false)
				if firstUndo then firstUndo = false end
			end
		end
	end
	self.Paths.DataModelSession:selectNone()
	if FastFlags:isOptimizationsEnabledOn() then
		self:fireChangedEvent()
	else
		self.ChangedEvent:fire(self.keyframeList)
	end
end

function Keyframes:deletePoseAndEmptyKeyframe(part, time, doHandleUndoRedo, fireChangeEvent)
	fireChangeEvent = fireChangeEvent == nil and true or fireChangeEvent
	time = self.Paths.DataModelClip:keyframeTimeClamp(time)
	local keyframe = self.keyframeList[time]
	if (keyframe ~= nil) then	
		local doDeleteKey = false
		local doDeletePose = false
		local keyContainsZeroPoses = self.Paths.HelperFunctionsTable:isNilOrEmpty(keyframe.Poses)
		if keyContainsZeroPoses then
			if FastFlags:isAnimationEventsOn() then
				doDeleteKey = self.Paths.HelperFunctionsTable:isNilOrEmpty(keyframe.Markers) -- key is already empty and has no event markers, so we'll delete
			else
				doDeleteKey = true
			end
		else
			local keyContainsPoseForPart = nil ~= keyframe.Poses[part]
			doDeletePose = keyContainsPoseForPart and self:canDeletePose(keyframe, part)				
			if doDeletePose then
				local keyContainsPoseForPartOnly = self.Paths.HelperFunctionsTable:containsOneKeyOnly(keyframe.Poses)			
				doDeleteKey = keyContainsPoseForPartOnly and (not FastFlags:isAnimationEventsOn() or self.Paths.HelperFunctionsTable:isNilOrEmpty(keyframe.Markers))
			end
		end	
		
		if doHandleUndoRedo then
			if doDeleteKey then
				self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.deleteKeyframe)
			elseif doDeletePose then
				self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.deletePose)
			end
		end

		if doDeletePose then
			deletePose(self, keyframe, part)
		end
		
		if doDeleteKey then
			self.keyframeList[time] = nil
			if FastFlags:isOptimizationsEnabledOn() then
				self:buildKeyframeListDiff(time)
			end
		end
	
		if doDeleteKey or doDeletePose then
			if fireChangeEvent then 
				if FastFlags:isOptimizationsEnabledOn() then
					self:fireChangedEvent()
				else
					self.ChangedEvent:fire(self.keyframeList)
				end
			end
		end
	end
end

local function deleteKeyframe(self, time, undoRegister)
	if undoRegister == true then
		self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.deleteKeyframe)
	end
	time = self.Paths.DataModelClip:keyframeTimeClamp(time)
	local keyframe = self.keyframeList[time]
	if (keyframe ~= nil) then
		for part, pose in pairs(keyframe.Poses) do
			deletePose(self, keyframe, pose.Item.Item)
		end
		self.keyframeList[time] = nil
		if FastFlags:isOptimizationsEnabledOn() then
			self:buildKeyframeListDiff(time)
		end
		return true
	else
		return false
	end
end

function Keyframes:deleteKeyframeAndPoses(time, undoRegister)
	local success = deleteKeyframe(self, time, undoRegister)
	if success then
		if FastFlags:isOptimizationsEnabledOn() then
			self:fireChangedEvent()
		else
			self.ChangedEvent:fire(self.keyframeList)
		end
	end
end

if FastFlags:isScaleKeysOn() and not FastFlags:isFixRenameKeyOptionOn() then
	function Keyframes:getOrCreateKeyframesAtTimes(keyframes, cframes)
		for time, dataItems in pairs(keyframes) do
			self:getOrCreateKeyframes(dataItems, time, false, false)
			if FastFlags:isIKModeFlagOn() then
				for part, dataItem in pairs(dataItems) do
					self.keyframeList[time].Poses[part].CFrame = cframes[time][part]
				end
			end
			self.Paths.DataModelSession:addPosesToSelectedKeyframes(time, dataItems)
		end
		self.ChangedEvent:fire(self.keyframeList)
		self.Paths.DataModelSession.SelectedChangeEvent:fire()
	end
end

function Keyframes:getOrCreateKeyframes(dataItems, time, fireChangeEvent, registerUndo)
	if FastFlags:isScaleKeysOn() then
		fireChangeEvent = fireChangeEvent == nil and true or fireChangeEvent
		registerUndo = registerUndo == nil and true or registerUndo
	end
	for _, dataItem in pairs(dataItems) do
		if FastFlags:isScaleKeysOn() then
			self:getOrCreateKeyframeData(self.Paths.DataModelRig:getPart(dataItem.Name), time, false, registerUndo)
		else
			self:getOrCreateKeyframeData(self.Paths.DataModelRig:getPart(dataItem.Name), time, false)
		end
	end
	if not FastFlags:isScaleKeysOn() or fireChangeEvent then 
		if FastFlags:isOptimizationsEnabledOn() then
			self:fireChangedEvent()
		else
			self.ChangedEvent:fire(self.keyframeList)
		end
	end
end

function Keyframes:getOrCreateKeyframeData(part, time, fireChangeEvent, registerUndo)
	if FastFlags:isScaleKeysOn() then
		registerUndo = registerUndo == nil and true or registerUndo
	end
	fireChangeEvent = fireChangeEvent == nil and true or fireChangeEvent
	local keyframe = self.Paths.DataModelClip:getKeyframe(time)
	local wasNewKeyFrameRequired = nil == keyframe
	if wasNewKeyFrameRequired then
		if not FastFlags:isScaleKeysOn() or registerUndo then self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.createKeyframe) end
		keyframe = self:createKeyframe(time, false)
	end
	local isChangeEventRequiredToFire = nil ~= keyframe and wasNewKeyFrameRequired

	local poseForPart = nil
	if keyframe ~= nil and self.Paths.DataModelRig.partToItemMap[part] ~= nil and self.Paths.DataModelRig.partToItemMap[part].Motor6D ~= nil then
		if keyframe.Poses[part] == nil then
			if not wasNewKeyFrameRequired then
				if not FastFlags:isScaleKeysOn() or registerUndo then self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.createKeyframe) end
			end
			self.Paths.UtilityScriptPose:initializePose(self.Paths, keyframe, part)
			if FastFlags:isOptimizationsEnabledOn() then
				self:buildKeyframeListDiff(time, keyframe)
			end
			if FastFlags:isAutoAddBeginningKeyframeOn() and time ~= 0 then
				self:addStartingKeyframe(part)
			end
			isChangeEventRequiredToFire = true
		end
		poseForPart = keyframe.Poses[part]
	end

	if isChangeEventRequiredToFire then
		if fireChangeEvent then 
			if FastFlags:isOptimizationsEnabledOn() then
				self:fireChangedEvent()
			else
				self.ChangedEvent:fire(self.keyframeList)
			end
		end
	end
	return poseForPart
end

function Keyframes:getCurrentKeyframeData(part, fireChangeEvent, registerUndo)
	if FastFlags:isIKModeFlagOn() then
		registerUndo = registerUndo == nil and true or registerUndo
	end
	return self:getOrCreateKeyframeData(part, self.Paths.DataModelSession:getScrubberTime(), fireChangeEvent, registerUndo)
end

function Keyframes:resetKeyframes(doFire)	
	doFire = doFire == nil and true or doFire
	for time, keyframe in pairs(self.keyframeList) do
		deleteKeyframe(self, time)
	end

	self.keyframeList = {}

	if not FastFlags:isCheckForSavedChangesOn() or doFire then
		if FastFlags:isOptimizationsEnabledOn() then
			self:fireChangedEvent()
		else
			self.ChangedEvent:fire(self.keyframeList)
		end
	end
end

function Keyframes:getPose(part, time)
	local key = self.keyframeList[time]
	if nil ~= key then
		return key.Poses[part]
	end
end

function Keyframes:getPoseFromPartName(partName, time)
	return Keyframes:getPose(self.Paths.DataModelRig:getPart(partName), time)
end

function Keyframes:doesPoseExist(partName, time)
	return nil ~= self:getPoseFromPartName(partName, time)
end

function Keyframes:doAnyPosesExist()
	return self.Paths.HelperFunctionsIteration:ifAny(self.keyframeList, function(_, keyframe) return not self.Paths.HelperFunctionsTable:isNilOrEmpty(keyframe.Poses) end)
end

function Keyframes:doAnyPosesExistForPart(part)
	return self.Paths.HelperFunctionsIteration:ifAny(self.keyframeList, function(_, keyframe) return keyframe.Poses[part] end)
end

function Keyframes:insertTime(at, addedTime)
	--First step. Copy all of these keyframes and wipe the list.
	local keyframeListCache = {}
	for timePosition, keyframe in pairs(self.keyframeList) do
		keyframeListCache[timePosition] = keyframe
	end
	
	--Second step. Wipe the list, and adjust times.
	self.keyframeList = {}
	for timePosition, keyframe in pairs(keyframeListCache) do
		if keyframe.Time > at then
			keyframe.Time = self.Paths.DataModelSession:formatTimeValue(keyframe.Time + addedTime)
			for _, pose in pairs(keyframe.Poses) do
				pose.Time = keyframe.Time
			end
			if FastFlags:isOptimizationsEnabledOn() then
				self:buildKeyframeListDiff(timePosition, keyframe)
			end
		end
	end
	
	--Third step.Repopulate original self.keyframeList
	for ignore, keyframe in pairs(keyframeListCache) do
		self.keyframeList[keyframe.Time] = keyframe
	end
	if FastFlags:isOptimizationsEnabledOn() then
		self:fireChangedEvent()
	else
		self.ChangedEvent:fire(self.keyframeList)
	end
end

function Keyframes:eraseTime(at, removeTime)
	--First step. Copy all of these keyframes and wipe the list.
	local keyframeListCache = {}
	for timePosition, keyframe in pairs(self.keyframeList) do
		--If in the "erase zone", don't store it
		if timePosition > at and timePosition < at + removeTime then
			--Ignore it. It's in the killzone.
		else
			keyframeListCache[timePosition] = keyframe
		end
	end
	
	--Second step. Wipe the list, and adjust times.
	self.keyframeList = {}
	for timePosition, keyframe in pairs(keyframeListCache) do
		if keyframe.Time > at then
			keyframe.Time = self.Paths.DataModelSession:formatTimeValue(keyframe.Time - removeTime)
			if FastFlags:isOptimizationsEnabledOn() then
				self:buildKeyframeListDiff(timePosition, keyframe)
			end
		end
	end
	
	--Third step.Repopulate original self.keyframeList
	for ignore, keyframe in pairs(keyframeListCache) do
		self.keyframeList[keyframe.Time] = keyframe
	end
	if FastFlags:isOptimizationsEnabledOn() then
		self:fireChangedEvent()
	else
		self.ChangedEvent:fire(self.keyframeList)
	end
end 

function Keyframes:getOrCreateKeyframe(time, registerUndo)
	local key = self.Paths.DataModelClip:getKeyframe(time)
	if (key == nil) then
		key = Keyframes:createKeyframe(time, registerUndo)
	end
	return key
end

function Keyframes:createAndSelectKeyframe(dataItem, time)
	if dataItem and time then
		self:getOrCreateKeyframeData(self.Paths.DataModelRig:getPart(dataItem.Name), time)
		self.Paths.DataModelSession:selectKeyframe(time, dataItem)
	end
end

function Keyframes:createAndSelectMultipleKeys(dataItems, time)
	if not self.Paths.HelperFunctionsTable:isNilOrEmpty(dataItems) and time then
		self:getOrCreateKeyframes(dataItems, time)
		self.Paths.DataModelSession:addPosesToSelectedKeyframes(time, dataItems)
	end
end

local function reinitializePose(self, keyframe, part, item)
	local pose = self.Paths.UtilityScriptPose:initializePose(self.Paths, keyframe, part)
	if pose then
		pose.CFrame = CFrame.new()	
		item.Motor6D.C1 = item.OriginC1
		pose.EasingStyle = self.Paths.UtilityScriptPose:getDefaultEasingStyle()
		pose.EasingDirection = self.Paths.UtilityScriptPose:getDefaultEasingDirection()			
	end
end

if FastFlags:isAutoAddBeginningKeyframeOn() then
	function Keyframes:addStartingKeyframe(part)
		local time0key = self:getOrCreateKeyframe(0, false)
		if time0key and not time0key.Poses[part] then
			reinitializePose(self, time0key, part, self.Paths.DataModelRig.partToItemMap[part])
		end
	end
end

function Keyframes:resetKeyframeToDefaultPose(time)
	-- we only need to reset if any poses actually exist
	if self:doAnyPosesExist() then
		self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.resetKeyframe)
		local keyframe = self:getOrCreateKeyframe(time, false)
				
		for part, item in pairs(self.Paths.DataModelRig.partList) do
			if self:doAnyPosesExistForPart(part) then
				reinitializePose(self, keyframe, part, item)
			end
		end
		if FastFlags:isOptimizationsEnabledOn() then
			self:fireChangedEvent()
		else
			self.ChangedEvent:fire(self.keyframeList)
		end
	end
end

function Keyframes:resetPartsToDefaultPose(dataItems, time)
	self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.resetKeyframe)
	local keyframe = self:getOrCreateKeyframe(time, false)
	for _, dataItem in pairs(dataItems) do
		reinitializePose(self, keyframe, dataItem.Item, dataItem)
	end
	if FastFlags:isOptimizationsEnabledOn() then
		self:fireChangedEvent()
	else
		self.ChangedEvent:fire(self.keyframeList)
	end
end

function Keyframes:resetPartToDefaultPose(part, time)
	self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.resetKeyframe)
	local keyframe = self:getOrCreateKeyframe(time, false)				
	reinitializePose(self, keyframe, part, self.Paths.DataModelRig.partList[part])
	if FastFlags:isOptimizationsEnabledOn() then
		self:fireChangedEvent()
	else
		self.ChangedEvent:fire(self.keyframeList)
	end
end

function Keyframes:canDeletePose(keyframe, part)
	local active = self.Paths.DataModelRig.partInclude[part.Name]
	return (active and keyframe ~= nil and self.Paths.DataModelRig.partToItemMap[part] ~= nil and self.Paths.DataModelRig.partToItemMap[part].Motor6D ~= nil and keyframe.Poses[part] ~= nil)
end

function Keyframes:createKeyframe(time, undoRegister)
	undoRegister = nil == undoRegister and true or undoRegister -- nil defaults to true
	if undoRegister == true then
		self.Paths.ActionEditClip:execute(self.Paths, self.Paths.ActionEditClip.ActionType.createKeyframe)
	end
	time = self.Paths.DataModelClip:keyframeTimeClamp(time)
	local newKeyframe = self.keyframeList[time]
	if (newKeyframe == nil) then
		if FastFlags:isAnimationEventsOn() then
			newKeyframe = {Time = time, Poses = {}, Name = "Keyframe", Markers = {}}
		else
			newKeyframe = {Time = time, Poses = {}, Name = "Keyframe"}
		end

		self.keyframeList[time] = newKeyframe
		if FastFlags:isOptimizationsEnabledOn() then
			self:buildKeyframeListDiff(time, newKeyframe)
		end

		if undoRegister then
			if FastFlags:isOptimizationsEnabledOn() then
				self:fireChangedEvent()
			else
				self.ChangedEvent:fire(self.keyframeList)
			end
		end
	end
	return newKeyframe
end

local function loadPose(self, keyframe, pose, invalidPoseNames)
	local item = self.Paths.DataModelRig.partListByName[pose.Name]
	if item ~= nil and pose.Weight > 0 then
		local LocalPose = self.Paths.UtilityScriptPose:initializePose(self.Paths, keyframe, item.Item, pose, true)
		if (LocalPose ~= nil) then
			if (item.OriginC1 ~= nil) then
				LocalPose.CFrame = item.OriginC1*pose.CFrame:inverse()*item.OriginC1:inverse()
			else
				LocalPose.CFrame = pose.CFrame
			end
			
			--Easing Style Importing
			LocalPose.EasingStyle = pose.EasingStyle
			LocalPose.EasingDirection = pose.EasingDirection
		end
	elseif FastFlags:isIKModeFlagOn() and item == nil then
		invalidPoseNames[pose.Name] = pose.Name
	end

	for id, childPose in pairs(pose:GetChildren()) do
		loadPose(self, keyframe, childPose, invalidPoseNames)
	end
end

local function loadMarker(self, keyframe, marker)
	self.Paths.DataModelAnimationEvents:createEvent(keyframe.Time, marker.Name, marker.Value, false, false)
end

function Keyframes:loadKeyframeSequence(kfs)
	local keyframes = kfs:GetChildren()
	if FastFlags:isAnimationEventsOn() then
		self.Paths.DataModelAnimationEvents.AnimationEventNames = {}
	end
	
	local newAnimLength = 0
	for i, v in pairs(keyframes) do
		if v.Time > newAnimLength then
			newAnimLength = v.time
		end
	end
	if FastFlags:isCheckForSavedChangesOn() then
		self.Paths.DataModelClip:setLength(newAnimLength, false, false)
	else
		self.Paths.DataModelClip:setLength(newAnimLength)
	end
	
	--import the poses
	local invalidPoseNames = {}
	local LocalKeyframe = nil
	for _, keyframe in pairs(keyframes) do
		local time = self.Paths.DataModelSession:formatTimeValue(keyframe.Time)
		if time <= self.Paths.DataModelClip:getLength() then
			LocalKeyframe = self:createKeyframe(time, false)
			LocalKeyframe.Name = keyframe.Name
			for __, pose in pairs(keyframe:GetChildren()) do
				if FastFlags:isAnimationEventsOn() then
					if pose:isA("Pose") then
						if FastFlags:isIKModeFlagOn() then
							loadPose(self, LocalKeyframe, pose, invalidPoseNames)
						else
							loadPose(self, LocalKeyframe, pose)
						end
					elseif pose:isA("KeyframeMarker") then
						loadMarker(self, LocalKeyframe, pose)
					end
				else
					if FastFlags:isIKModeFlagOn() then
						loadPose(self, LocalKeyframe, pose, invalidPoseNames)
					else
						loadPose(self, LocalKeyframe, pose)
					end
				end
			end
		end
	end

	if FastFlags:isIKModeFlagOn() then
		self.Paths.HelperFunctionsWarningsAndPrompts:createInvalidPoseNamesInFileWarning(self.Paths, kfs.Name, invalidPoseNames)
	end

	if FastFlags:isCheckForSavedChangesOn() then
		self.Paths.DataModelClip:setLooping(kfs.Loop, false)
	else
		self.Paths.DataModelClip:setLooping(kfs.Loop)
	end
	self.Paths.DataModelClip:setPriority(kfs.Priority.Name and kfs.Priority.Name or "Core")
	if FastFlags:isUseHipHeightInKeyframeSequencesOn() then
		if self.Paths.HelperFunctionsMath:isCloseToZero(kfs.AuthoredHipHeight) then
			self.Paths.DataModelClip:setAuthoredHipHeight(self.Paths.DataModelRig:getHipHeight())
		else
			self.Paths.DataModelClip:setAuthoredHipHeight(kfs.AuthoredHipHeight)
		end
		if self.Paths.DataModelClip:getAuthoredHipHeight() ~= self.Paths.DataModelRig:getHipHeight() then
			self.Paths.HelperFunctionsWarningsAndPrompts:createHipHeightMismatchWarning(self.Paths)
		end
	end

	if self.Paths.DataModelSession.ScrubberTime > self.Paths.DataModelClip:getLength() then
		self.Paths.DataModelSession.ScrubberTime = 0
	end
	
	if FastFlags:isOptimizationsEnabledOn() then
		for time, keyframe in pairs(self.keyframeList) do
			self.keyframeChanges[time] = keyframe
		end
		self:fireChangedEvent()
		self.PoseTransformChangedEvent:fire()
	else
		self.ChangedEvent:fire(self.keyframeList)
	end
end

return Keyframes