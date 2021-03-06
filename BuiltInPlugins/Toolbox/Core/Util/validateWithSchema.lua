local ANY_NAME = "*"

local function checkName(nameList, instanceName)
	if type(nameList) == "table" then
		for _, name in pairs(nameList) do
			if name == instanceName then
				return true
			end
		end
	elseif type(nameList) == "string" then
		return nameList == instanceName
	end
	return false
end

local function getReadableName(nameList)
	if type(nameList) == "table" then
		return table.concat(nameList, " or ")
	elseif type(nameList) == "string" then
		return nameList
	end
	return ANY_NAME
end

local function validateWithSchemaHelper(schema, instance, authorizedSet)
	-- validate
	if game:GetFastFlag("CMSAdditionalAccessoryTypesV2") then
		if instance.ClassName ~= schema.ClassName or (schema.Name ~= nil and not checkName(schema.Name, instance.Name)) then
			return { success = false }
		end
	else
		if instance.ClassName ~= schema.ClassName or (schema.Name ~= nil and schema.Name ~= instance.Name) then
			return { success = false }
		end
	end

	-- validate children
	if schema._children then
		for _, childSchema in pairs(schema._children) do
			local found = false
			local mostRecentFailure
			for _, child in pairs(instance:GetChildren()) do
				local result = validateWithSchemaHelper(childSchema, child, authorizedSet)
				if result.success then
					found = true
					break
				elseif result.message then
					mostRecentFailure = result
				end
			end
			if not found and not childSchema._optional then
				if mostRecentFailure then
					return mostRecentFailure
				else
					local childSchemaName
					if game:GetFastFlag("CMSAdditionalAccessoryTypesV2") then
						childSchemaName = getReadableName(childSchema.Name)
					else
						childSchemaName = childSchema.Name or ANY_NAME
					end

					return {
						success = false,
						message = "Could not find a "
							.. childSchema.ClassName
							.. " called "
							.. childSchemaName
							.. " inside "
							.. instance.Name
					}
				end
			end
		end
	end

	authorizedSet[instance] = true

	return { success = true }
end

local function validateWithSchema(schema, instance)

	if instance.ClassName ~= schema.ClassName or (schema.Name ~= nil and schema.Name ~= instance.Name) then
		return {
			success = false,
			message = "Expected top-level instance to be a " .. schema.ClassName,
		}
	end

	local authorizedSet = {}
	local result = validateWithSchemaHelper(schema, instance, authorizedSet)

	if not result.success then
		return result
	end

	-- check for extra descendants
	local unauthorizedDescendantPaths = {}
	for _, descendant in pairs(instance:GetDescendants()) do
		if authorizedSet[descendant] == nil then
			unauthorizedDescendantPaths[#unauthorizedDescendantPaths + 1] = descendant:GetFullName()
		end
	end

	if #unauthorizedDescendantPaths > 0 then
		return {
			success = false,
			message = "Unexpected Descendants:\n" .. table.concat(unauthorizedDescendantPaths, "\n")
		}
	end

	return { success = true }
end

return validateWithSchema