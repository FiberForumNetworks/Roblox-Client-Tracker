--[[
	Prompts the user to select an Animation asset to upload, then
	imports the KeyframeSequence from the Roblox asset id.
]]

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local Plugin = script.Parent.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)
local RigUtils = require(Plugin.Src.Util.RigUtils)
local LoadAnimationData = require(Plugin.Src.Thunks.LoadAnimationData)
local SetIsDirty = require(Plugin.Src.Actions.SetIsDirty)

local UseCustomFPS = require(Plugin.LuaFlags.GetFFlagAnimEditorUseCustomFPS)

return function(plugin)
	return function(store)
		local state = store:getState()
		local rootInstance = state.Status.RootInstance
		if not rootInstance then
			return
		end

		local id = plugin:PromptForExistingAssetId("Animation")
		if id and tonumber(id) > 0 then
			local anim = KeyframeSequenceProvider:GetKeyframeSequenceAsync("rbxassetid://" .. id)
			local newData
			if UseCustomFPS() then
				local frameRate = RigUtils.calculateFrameRate(anim)
				newData = RigUtils.fromRigAnimation(anim, frameRate)
			else
				newData = RigUtils.fromRigAnimation(anim, Constants.DEFAULT_FRAMERATE)
			end
			newData.Metadata.Name = Constants.DEFAULT_IMPORTED_NAME
			store:dispatch(LoadAnimationData(newData))
			store:dispatch(SetIsDirty(false))

			state.Analytics:onImportAnimation(id)
		end
	end
end