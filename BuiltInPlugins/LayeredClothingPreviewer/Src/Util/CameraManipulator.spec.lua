return function()
	local Library = script.Parent
	local CameraManipulator = require(Library.CameraManipulator)

	it("should get created", function()
		local frame = Instance.new("Frame")
		local camera = Instance.new("Camera")
		local result = CameraManipulator.new(camera, frame)
		expect(result).to.be.ok()

		result:disconnect()
		expect(result).to.be.ok()
	end)

	it("should assert if not given a camera", function()
		local frame = Instance.new("Frame")

		local success = pcall(function()
			return CameraManipulator.new(nil, frame)
		end)

		expect(success).to.equal(false)
	end)

	it("should assert if not given an observable", function()
		local camera = Instance.new("Camera")

		local success = pcall(function()
			return CameraManipulator.new(camera, nil)
		end)

		expect(success).to.equal(false)
	end)

	it("should assert if given a focus object which isn't a table", function()
		local frame = Instance.new("Frame")
		local camera = Instance.new("Camera")

		local success = pcall(function()
			return CameraManipulator.new(camera, frame, 22)
		end)

		expect(success).to.equal(false)
	end)
end