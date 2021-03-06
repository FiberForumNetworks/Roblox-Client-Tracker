--[[
	Main reducer for all settings values.
	Saves a table of current settings and local changes.

	Changes are finally saved when the SaveChanges thunk is dispatched.
	Alternatively, they can be reset if DiscardChanges is dispatched.

	The state table:
		- Contains all settings and values under the Current key, loaded from a Settings Interface.
		- Contains a table under the Changed key, which keeps track of all changed settings.

	When saving changes, only settings in the Changed table are saved.
	When discarding changes, the Changed table is deleted.
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)

local SetCurrentSettings = require(Plugin.Src.Actions.SetCurrentSettings)
local AddChange = require(Plugin.Src.Actions.AddChange)
local AddErrors = require(Plugin.Src.Actions.AddErrors)
local DiscardChanges = require(Plugin.Src.Actions.DiscardChanges)
local DiscardErrors = require(Plugin.Src.Actions.DiscardErrors)

local AddTableChange = require(Plugin.Src.Actions.AddTableChange)
local DiscardTableChanges = require(Plugin.Src.Actions.DiscardTableChanges)
local DiscardTableErrors = require(Plugin.Src.Actions.DiscardTableErrors)

local AddTableKeyChange = require(Plugin.Src.Actions.AddTableKeyChange)
local AddTableKeyErrors = require(Plugin.Src.Actions.AddTableKeyErrors)
local DiscardTableKeyChanges = require(Plugin.Src.Actions.DiscardTableKeyChanges)
local DiscardTableKeyErrors = require(Plugin.Src.Actions.DiscardTableKeyErrors)

local AddWarning = require(Plugin.Src.Actions.AddWarning)
local DiscardWarning = require(Plugin.Src.Actions.DiscardWarning)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local DeepMergeTables = require(Plugin.Src.Util.DeepMergeTables)

local Scales = require(Plugin.Src.Util.Scales)
local AssetOverrides = require(Plugin.Src.Util.AssetOverrides)

local DFFlagDeveloperSubscriptionsEnabled = settings():GetFFlag("DeveloperSubscriptionsEnabled")

local equalityCheckFunctions = {
	universeAvatarAssetOverrides = AssetOverrides.isEqual,
	universeAvatarMinScales = Scales.isEqual,
	universeAvatarMaxScales = Scales.isEqual,
}

local function isEqualCheck(current, changed)
	if current == nil or changed == nil then
		return current == changed
	end
	if isEmpty(current) ~= isEmpty(changed) then
		return false
	end

	local equal = true
	for key, value in pairs(current) do
		if changed[key] ~= value then
			equal = false
			break
		end
	end
	for key, value in pairs(changed) do
		if current[key] ~= value then
			equal = false
			break
		end
	end
	return equal
end

local function getTableValue(table, tableName, tableKey, valueKey)
	if table ~= nil and table[tableName] ~= nil then
		if valueKey ~= nil then
			if table[tableName][tableKey] ~= nil then
				return table[tableName][tableKey][valueKey]
			end
		else
			return table[tableName][tableKey]
		end
	end
	return nil
end

local function Settings(state, action)
	state = state or {
		Current = {},
		Changed = {},
		Errors = {},
		Warnings = {},
	}

	if action.type == AddChange.name then
		local newValue = action.value
		if state.Current[action.setting] == newValue then
			newValue = Cryo.None
		elseif type(newValue) == "table" then
			local isEqual = equalityCheckFunctions[action.setting] or isEqualCheck
			if isEqual(state.Current[action.setting], newValue) then
				newValue = Cryo.None
			end
		end

		return Cryo.Dictionary.join(state, {
			Changed = Cryo.Dictionary.join(state.Changed, {
				[action.setting] = newValue,
			}),
			Errors = Cryo.Dictionary.join(state.Errors, {
				[action.setting] = Cryo.None,
			}),
        })

	elseif DFFlagDeveloperSubscriptionsEnabled and action.type == AddTableChange.name then
		local newValue = action.value

		local currValue = getTableValue(state.Current, action.tableName, action.tableKey)
        if currValue == newValue then
			newValue = Cryo.None
		elseif type(newValue) == "table" then
            if isEqualCheck(currValue, newValue) then
				newValue = Cryo.None
			end
		end

		local changed = {
			[action.tableName] = {
				[action.tableKey] = newValue
			}
		}

		local errors = nil
		if getTableValue(state.Errors, action.tableName, action.tableKey) ~= nil then
			errors = {
				[action.tableName] = {
					[action.tableKey] = Cryo.None
				}
			}
		end

		return Cryo.Dictionary.join(state, {
			Changed = DeepMergeTables.Merge(state.Changed, changed) or {},
			Errors = DeepMergeTables.Merge(state.Errors, errors) or {},
		})
		
	elseif DFFlagDeveloperSubscriptionsEnabled and action.type == AddTableKeyChange.name then
		local newValue = action.value

		local currValue = getTableValue(state.Current, action.tableName, action.tableKey, action.valueKey)
        if currValue == newValue then
			newValue = Cryo.None
		elseif type(newValue) == "table" then
            if isEqualCheck(currValue, newValue) then
				newValue = Cryo.None
			end
		end

		local changed = {
			[action.tableName] = {
				[action.tableKey] = {
					[action.valueKey] = newValue
				}
			}
		}

		local errors = nil
		if getTableValue(state.Errors, action.tableName, action.tableKey, action.valueKey) ~= nil then
			errors = {
				[action.tableName] = {
					[action.tableKey] = {
						[action.valueKey] = Cryo.None
					}
				}
			}
		end

		return Cryo.Dictionary.join(state, {
			Changed = DeepMergeTables.Merge(state.Changed, changed) or {},
			Errors = DeepMergeTables.Merge(state.Errors, errors) or {},
        })

	elseif action.type == AddErrors.name then
		return Cryo.Dictionary.join(state, {
			Errors = Cryo.Dictionary.join(state.Errors, action.errors)
        })
        
    elseif DFFlagDeveloperSubscriptionsEnabled and action.type == AddTableKeyErrors.name then
		return Cryo.Dictionary.join(state, {
			Errors = DeepMergeTables.Merge(state.Errors, {
				[action.tableName] = {
					[action.tableKey] = {
						[action.valueKey] = action.errors
					}
				}
			}) or {},
		})

	elseif action.type == DiscardChanges.name then
		return Cryo.Dictionary.join(state, {
			Changed = {},
		})

	elseif action.type == DiscardErrors.name then
		return Cryo.Dictionary.join(state, {
			Errors = {},
			Warnings = {},
		})

	elseif DFFlagDeveloperSubscriptionsEnabled and action.type == DiscardTableErrors.name then
		return Cryo.Dictionary.join(state, {
			Errors = DeepMergeTables.Merge(state.Errors, {
				[action.tableName] = {
					[action.tableKey] = Cryo.None,
				},
			}) or {},
		})

	elseif DFFlagDeveloperSubscriptionsEnabled and action.type == DiscardTableKeyErrors.name then
		return Cryo.Dictionary.join(state, {
			Errors = DeepMergeTables.Merge(state.Errors, {
				[action.tableName] = {
					[action.tableKey] = {
						[action.valueKey] = Cryo.None,
					},
				},
			}) or {},
		})

	elseif DFFlagDeveloperSubscriptionsEnabled and action.type == DiscardTableChanges.name then
		local changed = {
			[action.tableName] = {
				[action.tableKey] = Cryo.None,
			},
		}

		local errors = nil
		if getTableValue(state.Errors, action.tableName, action.tableKey) ~= nil then
			errors = {
				[action.tableName] = {
					[action.tableKey] = Cryo.None,
				},
			}
		end

		return Cryo.Dictionary.join(state, {
			Changed = DeepMergeTables.Merge(state.Changed, changed) or {},
			Errors = DeepMergeTables.Merge(state.Errors, errors) or {},
        })
		
	elseif DFFlagDeveloperSubscriptionsEnabled and action.type == DiscardTableKeyChanges.name then
		local changed = {
			[action.tableName] = {
				[action.tableKey] = {
					[action.valueKey] = Cryo.None,
				},
			},
		}

		local errors = nil
		if getTableValue(state.Errors, action.tableName, action.tableKey, action.valueKey) ~= nil then
			errors = {
				[action.tableName] = {
					[action.tableKey] = {
						[action.valueKey] = Cryo.None
					}
				}
			}
		end

		return Cryo.Dictionary.join(state, {
			Changed = DeepMergeTables.Merge(state.Changed, changed) or {},
			Errors = DeepMergeTables.Merge(state.Errors, errors) or {},
        })

	elseif action.type == SetCurrentSettings.name then
		return Cryo.Dictionary.join(state, {
			Current = action.settings,
		})

	elseif action.type == AddWarning.name then
		if not Cryo.List.find(state.Warnings, action.key) then
			return Cryo.Dictionary.join(state, {
				Warnings = Cryo.List.join(state.Warnings, {action.key})
			})
		end

	elseif action.type == DiscardWarning.name then
		return Cryo.Dictionary.join(state, {
			Warnings = Cryo.List.removeValue(state.Warnings, action.key)
		})
	end

	return state
end

return Settings
