return function()
	local Library = script.Parent
	local ConnectionsManager = require(Library.ConnectionsManager)

	it("should get created", function()
		local result = ConnectionsManager.new()

		expect(result).to.be.ok()

		result:disconnect()
		expect(result).to.be.ok()
		expect(#result.Connect).to.equal(0)
	end)

	it("should get created and disconnect it's connections", function()
		local frame = Instance.new("Frame")

		local result = ConnectionsManager.new({
			frame.InputBegan:Connect(function() end),
			frame.InputChanged:Connect(function() end),
			frame.InputEnded:Connect(function() end)
		})
		expect(result).to.be.ok()
		expect(#result.Connect).to.equal(3)

		result:disconnect()
		expect(#result.Connect).to.equal(0)
	end)

	it("should get created and disconnect it's connections after they are added", function()
		local frame = Instance.new("Frame")

		local result = ConnectionsManager.new()
		expect(result).to.be.ok()
		expect(#result.Connect).to.equal(0)

		result:add(frame.InputBegan:Connect(function() end))
		result:add(frame.InputChanged:Connect(function() end))
		result:add(frame.InputEnded:Connect(function() end))

		expect(#result.Connect).to.equal(3)

		result:disconnect()
		expect(#result.Connect).to.equal(0)
	end)
end