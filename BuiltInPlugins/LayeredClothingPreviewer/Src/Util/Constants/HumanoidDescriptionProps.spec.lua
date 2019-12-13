return function()
	local Library = script.Parent
	local HumanoidDescriptionProps = require(Library.HumanoidDescriptionProps)

	it("all props should be in a HumanoidDescription", function()
		local decription = Instance.new("HumanoidDescription")
		local numProps = 0
		local numPropsExist = 0
		for key, _ in pairs(HumanoidDescriptionProps) do
			local success = pcall(function()
				return decription[key]
			end)
			numProps = numProps + 1
			if success then
				numPropsExist = numPropsExist + 1
			end
		end
		expect(numProps).to.equal(numPropsExist)
	end)
end