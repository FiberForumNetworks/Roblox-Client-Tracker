local Plugin = script.Parent.Parent.Parent.Parent

local RequestReason = require(Plugin.Core.Types.RequestReason)

local UpdatePageInfoAndSendRequest = require(Plugin.Core.Networking.Requests.UpdatePageInfoAndSendRequest)

return function(networkInterface, settings)
	return function(store)
		-- This make sure we don't request more page when we are already requesting a new page.
		if store:getState().assets.isLoading or store:getState().assets.hasReachedBottom then
			return
		end

		local currentPage = store:getState().pageInfo.currentPage or 0
		store:dispatch(UpdatePageInfoAndSendRequest(networkInterface, settings, {
			-- Page need to increase by 1
			targetPage = currentPage + 1,
			requestReason = RequestReason.NextPage,
		}))
	end
end
