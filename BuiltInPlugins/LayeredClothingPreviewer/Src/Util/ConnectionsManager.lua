--[[
	A simple class to hold a table of connections, add to the table, and disconnect all the connections at the end
]]

local ConnectionsManager = {}
ConnectionsManager.__index = ConnectionsManager

function ConnectionsManager.new(initialConnections)
	local self = setmetatable({}, ConnectionsManager)
	self.Connect = initialConnections or {}
	return self
end

function ConnectionsManager:add(newConnection)
	self.Connect[#self.Connect + 1] = newConnection
end

function ConnectionsManager:disconnect()
	for _,connected in ipairs(self.Connect) do
		connected:disconnect()
	end
	self.Connect = {}
end

return ConnectionsManager
