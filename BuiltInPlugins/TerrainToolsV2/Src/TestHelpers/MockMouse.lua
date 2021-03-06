local Plugin = script.Parent.Parent.Parent
local UILibrary = Plugin.Packages.UILibrary
local Signal = require(UILibrary.Utils.Signal)

local MockMouse = {}
MockMouse.__index = MockMouse

function MockMouse.new()
	return setmetatable({
		Origin = CFrame.new(),
		UnitRay = Ray.new(),
		Target = nil,

		WheelForward = Signal.new(),
		WheelBackward = Signal.new(),
	}, MockMouse)
end

return MockMouse
