local Plugin = script.Parent.Parent.Parent

local SetPlaceInfo = require(Plugin.Src.Actions.SetPlaceInfo)
local ApiFetchPlacesByUniverseId = require(Plugin.Src.Network.Requests.ApiFetchPlacesByUniverseId)

return function(parentGame, pageCursor)
	return function(store)
		assert(type(parentGame.name) == "string", "LoadExistingPlaces.parentGame must have a string name")
		assert(type(parentGame.universeId) == "number", "LoadExistingPlaces.parentGame must have a number universeId")

		store:dispatch(SetPlaceInfo({ places = {} }))

		local query = ApiFetchPlacesByUniverseId({universeId = parentGame.universeId}, {cursor = pageCursor,})

		query:andThen(function(resp)
			resp.parentGame = parentGame
			store:dispatch(SetPlaceInfo(resp))
		end)
		:catch(function()
			error("Failed to fetch places under parent game" .. parentGame.name)
		end)

	end
end
