return function()
	local Plugin = script.Parent.Parent.Parent
	local Rodux = require(Plugin.Rodux)
	local Templates = require(Plugin.Src.Util.Templates)

	local MainReducer = require(Plugin.Src.Reducers.MainReducer)
	local SetRootInstance = require(Plugin.Src.Actions.SetRootInstance)
	local LoadAnimationData = require(Plugin.Src.Thunks.LoadAnimationData)
	local AddKeyframe = require(Plugin.Src.Thunks.AddKeyframe)

	local AddTrack = require(Plugin.Src.Thunks.AddTrack)
	local DeleteTrack = require(Plugin.Src.Thunks.DeleteTrack)
	local SortAndSetTracks = require(Plugin.Src.Thunks.SortAndSetTracks)

	local mockSkeleton = {
		ClassName = "MockSkeleton",
		Names = {"Hips", "Torso", "LeftArm", "RightArm", "LeftHand", "RightHand", "Neck", "Head"},
		Parents = {0, 1, 2, 2, 3, 4, 2, 7},
	}

	local testAnimationData = Templates.animationData()
	testAnimationData.Metadata.EndFrame = 10
	testAnimationData.Instances.Root.Tracks = {
		Hips = {
			Keyframes = {0},
		},
	}

	local function createEmptyStore()
		local middlewares = {Rodux.thunkMiddleware}
		local store = Rodux.Store.new(MainReducer, nil, middlewares)
		return store
	end

	local function createTestStore()
		local middlewares = {Rodux.thunkMiddleware}
		local store = Rodux.Store.new(MainReducer, nil, middlewares)
		store:dispatch(SetRootInstance(mockSkeleton))
		store:dispatch(LoadAnimationData(testAnimationData))
		return store
	end

	describe("LoadAnimationData", function()
		it("should add a track for every track in the AnimationData", function()
			local store = createEmptyStore()
			store:dispatch(SetRootInstance(mockSkeleton))
			store:dispatch(LoadAnimationData(testAnimationData))

			local status = store:getState().Status
			expect(#status.Tracks).to.equal(1)
			expect(status.Tracks[1].Name).to.equal("Hips")
		end)
	end)

	describe("AddTrack", function()
		it("should add a track to Tracks", function()
			local store = createTestStore()
			store:dispatch(AddTrack("Root", "Neck"))

			local found = false
			local status = store:getState().Status
			for _, track in ipairs(status.Tracks) do
				if track.Name == "Neck" then
					found = true
					break
				end
			end

			expect(found).to.equal(true)
		end)

		it("should do nothing if a track already exists", function()
			local store = createTestStore()
			store:dispatch(AddTrack("Root", "Hips"))

			local found = 0
			local status = store:getState().Status
			for _, track in ipairs(status.Tracks) do
				if track.Name == "Hips" then
					found = found + 1
				end
			end

			expect(found).to.equal(1)
		end)
	end)

	describe("DeleteTrack", function()
		it("should remove a track from Tracks", function()
			local store = createTestStore()
			store:dispatch(DeleteTrack("Hips"))

			local found = false
			local status = store:getState().Status
			for _, track in ipairs(status.Tracks) do
				if track.Name == "Hips" then
					found = true
					break
				end
			end

			expect(found).to.equal(false)
		end)

		it("should remove the track from animationData", function()
			local store = createTestStore()
			store:dispatch(DeleteTrack("Hips"))

			local data = store:getState().AnimationData
			local tracks = data.Instances.Root.Tracks
			expect(tracks.Hips).never.to.be.ok()
		end)
	end)

	describe("SortAndSetTracks", function()
		it("should set the Tracks", function()
			local store = createEmptyStore()
			store:dispatch(SortAndSetTracks({
				{Name = "Track1"},
			}))
			local status = store:getState().Status
			local tracks = status.Tracks
			expect(tracks).to.be.ok()
			expect(#tracks).to.equal(1)
			expect(tracks[1].Name).to.equal("Track1")
		end)

		it("should sort alphabetically given no hierarchy", function()
			local store = createEmptyStore()
			store:dispatch(SortAndSetTracks({
				{Name = "Track3"},
				{Name = "Track2"},
				{Name = "Track1"},
			}))
			local status = store:getState().Status
			local tracks = status.Tracks
			expect(tracks[1].Name).to.equal("Track1")
			expect(tracks[2].Name).to.equal("Track2")
			expect(tracks[3].Name).to.equal("Track3")
		end)

		it("should set the Depth of flat tracks to 0", function()
			local store = createEmptyStore()
			store:dispatch(SortAndSetTracks({
				{Name = "Track1"},
			}))
			local status = store:getState().Status
			local tracks = status.Tracks
			expect(tracks[1].Depth).to.be.ok()
			expect(tracks[1].Depth).to.equal(0)
		end)

		it("should sort by hierarchy if given one", function()
			local store = createEmptyStore()
			store:dispatch(SetRootInstance(mockSkeleton))
			store:dispatch(SortAndSetTracks({
				{Name = "LeftArm"},
				{Name = "Torso"},
				{Name = "LeftHand"},
			}))
			local status = store:getState().Status
			local tracks = status.Tracks
			expect(tracks[1].Name).to.equal("Torso")
			expect(tracks[2].Name).to.equal("LeftArm")
			expect(tracks[3].Name).to.equal("LeftHand")
		end)

		it("should set the Depth of nested items", function()
			local store = createEmptyStore()
			store:dispatch(SetRootInstance(mockSkeleton))
			store:dispatch(SortAndSetTracks({
				{Name = "LeftArm"},
				{Name = "Torso"},
				{Name = "LeftHand"},
			}))
			local status = store:getState().Status
			local tracks = status.Tracks
			expect(tracks[1].Depth).to.equal(0)
			expect(tracks[2].Depth).to.equal(1)
			expect(tracks[3].Depth).to.equal(2)
		end)

		it("should populate the unused tracks given a hierarchy", function()
			local store = createEmptyStore()
			store:dispatch(SetRootInstance(mockSkeleton))
			store:dispatch(SortAndSetTracks({
				{Name = "Hips"},
				{Name = "Torso"},
				{Name = "LeftArm"},
				{Name = "RightArm"},
				{Name = "LeftHand"},
				{Name = "RightHand"},
			}))
			local status = store:getState().Status
			local unused = status.UnusedTracks
			expect(unused).to.be.ok()
			expect(#unused).to.equal(2)
			expect(unused[1].Name).to.equal("Head")
			expect(unused[2].Name).to.equal("Neck")
		end)
	end)

	describe("AddKeyframe", function()
		it("should add a track if the track does not exist", function()
			local store = createTestStore()
			store:dispatch(AddKeyframe("Root", "Head", 0))

			local found = false
			local status = store:getState().Status
			for _, track in ipairs(status.Tracks) do
				if track.Name == "Head" then
					found = true
					break
				end
			end

			expect(found).to.equal(true)
		end)
	end)
end