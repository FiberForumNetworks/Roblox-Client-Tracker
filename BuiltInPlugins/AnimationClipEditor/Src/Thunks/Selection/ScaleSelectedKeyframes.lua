--[[
	Scales the selected keyframes around a pivot.
	The scale parameter determines the new scale of the keyframes.
	If keyframes are at the pivot, they won't move, but the pivot
	doesn't have to be a keyframe.

	Keyframes are rounded to the nearest frame after scaling so that
	they cannot be placed in between frames.

	Currently, if keyframes are scaled such that multiple keyframes
	will end up on the same frame, one of the overlapping keyframes
	will be deleted and replaced by the other overlapping keyframe.
	The outer keyframes have precedence over the inner keyframes
	when this situation has to occur.
]]

local Plugin = script.Parent.Parent.Parent.Parent

local Cryo = require(Plugin.Cryo)
local deepCopy = require(Plugin.Src.Util.deepCopy)
local Constants = require(Plugin.Src.Util.Constants)
local KeyframeUtils = require(Plugin.Src.Util.KeyframeUtils)
local TrackUtils = require(Plugin.Src.Util.TrackUtils)
local AnimationData = require(Plugin.Src.Util.AnimationData)
local SetSelectedKeyframes = require(Plugin.Src.Actions.SetSelectedKeyframes)
local UpdateAnimationData = require(Plugin.Src.Thunks.UpdateAnimationData)


-- Helper function which allows us to snap keyframes
-- to exact frames, preventing keyframes between frames.
local function roundToInt(num)
	return math.floor(num + 0.5)
end

return function(pivotFrame, scale)
	return function(store)
		local state = store:getState()
		local scroll = state.Status.Scroll
		local zoom = state.Status.Zoom
		local editingLength = state.Status.EditingLength
		local selectedKeyframes = state.Status.SelectedKeyframes
		local animationData = state.AnimationData
		if not (animationData and selectedKeyframes) then
			return
		end

		local newData = deepCopy(animationData)

		local range = TrackUtils.getZoomRange(animationData, scroll, zoom, editingLength)
		local startFrame = range.Start

		local maxLength = animationData.Metadata and animationData.Metadata.FrameRate
			and AnimationData.getMaximumLength(animationData.Metadata.FrameRate)
			or AnimationData.getMaximumLength(Constants.DEFAULT_FRAMERATE)

		local newSelectedKeyframes = deepCopy(selectedKeyframes)

		for instanceName, instance in pairs(selectedKeyframes) do
			local dataInstance = newData.Instances[instanceName]

			if scale > 1 then
				for trackName, _ in pairs(instance) do
					local keyframes = Cryo.Dictionary.keys(instance[trackName])
					table.sort(keyframes)
					local track = dataInstance.Tracks[trackName]

					-- Everything below the pivot is moving left, so perform
					-- the move from left to right to avoid clobbering
					for index = 1, #keyframes, 1 do
						local oldFrame = keyframes[index]
						local insertFrame = roundToInt(pivotFrame + ((oldFrame - pivotFrame) * scale))
						insertFrame = math.clamp(insertFrame, startFrame, maxLength)
						if insertFrame >= pivotFrame then
							break
						end
						AnimationData.moveKeyframe(track, oldFrame, insertFrame)
						AnimationData.moveNamedKeyframe(newData, oldFrame, insertFrame)

						newSelectedKeyframes[instanceName][trackName][oldFrame] = nil
						newSelectedKeyframes[instanceName][trackName][insertFrame] = true
					end

					-- Everything above the pivot is moving right, so perform
					-- the move from right to left to avoid clobbering
					for index = #keyframes, 1, -1 do
						local oldFrame = keyframes[index]
						local insertFrame = roundToInt(pivotFrame + ((oldFrame - pivotFrame) * scale))
						insertFrame = math.clamp(insertFrame, startFrame, maxLength)
						if insertFrame <= pivotFrame then
							break
						end
						AnimationData.moveKeyframe(track, oldFrame, insertFrame)
						AnimationData.moveNamedKeyframe(newData, oldFrame, insertFrame)

						newSelectedKeyframes[instanceName][trackName][oldFrame] = nil
						newSelectedKeyframes[instanceName][trackName][insertFrame] = true
					end
				end
			else
				for trackName, _ in pairs(instance) do
					local keyframes = Cryo.Dictionary.keys(instance[trackName])
					table.sort(keyframes)
					local track = dataInstance.Tracks[trackName]

					local lowPivot, highPivot = KeyframeUtils.findNearestKeyframes(keyframes, pivotFrame)
					if highPivot == nil then
						highPivot = lowPivot + 1
					end

					-- Everything below the pivot is moving right, so perform
					-- the move from right to left to avoid clobbering
					for index = lowPivot, 1, -1 do
						local oldFrame = keyframes[index]
						local insertFrame = roundToInt(pivotFrame + ((oldFrame - pivotFrame) * scale))
						insertFrame = math.clamp(insertFrame, startFrame, maxLength)
						AnimationData.moveKeyframe(track, oldFrame, insertFrame)
						AnimationData.moveNamedKeyframe(newData, oldFrame, insertFrame)

						newSelectedKeyframes[instanceName][trackName][oldFrame] = nil
						newSelectedKeyframes[instanceName][trackName][insertFrame] = true
					end

					-- Everything above the pivot is moving left, so perform
					-- the move from left to right to avoid clobbering
					for index = highPivot, #keyframes, 1 do
						local oldFrame = keyframes[index]
						local insertFrame = roundToInt(pivotFrame + ((oldFrame - pivotFrame) * scale))
						insertFrame = math.clamp(insertFrame, startFrame, maxLength)
						AnimationData.moveKeyframe(track, oldFrame, insertFrame)
						AnimationData.moveNamedKeyframe(newData, oldFrame, insertFrame)

						newSelectedKeyframes[instanceName][trackName][oldFrame] = nil
						newSelectedKeyframes[instanceName][trackName][insertFrame] = true
					end
				end
			end
		end

		store:dispatch(UpdateAnimationData(newData))
		store:dispatch(SetSelectedKeyframes(newSelectedKeyframes))
	end
end