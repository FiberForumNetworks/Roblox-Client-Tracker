local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Rodux = require(Libs.Rodux)

local DebugFlags = require(Plugin.Core.Util.DebugFlags)

local Reducers = Plugin.Core.Reducers
local Assets = require(Reducers.Assets)
local NetworkErrors = require(Reducers.NetworkErrors)
local PageInfo = require(Reducers.PageInfo)
local ReducerLogger = require(Reducers.ReducerLogger)
local Sound = require(Reducers.Sound)
local VotingReducer = require(Reducers.VotingReducer)
local LiveSearch = require(Reducers.LiveSearch)
local Favorite = require(Reducers.Favorite)
local RolesReducer = require(Reducers.RolesReducer)
local ItemTagsReducer = require(Reducers.ItemTagsReducer)
local Purchase = require(Reducers.Purchase)
local Packages = require(Reducers.Packages)

-- TODO CLIDEVSRVS-1595: Error handling/promise rejections

local ToolboxReducer = Rodux.combineReducers({
		assets = Assets,
		networkErrors = NetworkErrors,
		pageInfo = PageInfo,
		sound = Sound,
		voting = VotingReducer,
		liveSearch = LiveSearch,
		favorite = Favorite,
		roles = RolesReducer,
		itemTags = ItemTagsReducer,
		purchase = Purchase,
		packages = Packages,
	})

return function(state, action)
	if DebugFlags.shouldDebugState() then
		return ReducerLogger(ToolboxReducer, state, action)
	else
		return ToolboxReducer(state, action)
	end
end