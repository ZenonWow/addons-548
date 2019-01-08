local LIB, REVISION = "LibStateDriver-1.3", 0
if not LibStub then error(LIB .. " requires LibStub", 0) end

local lib, oldRevision = LibStub:NewLibrary(LIB, REVISION)
if not lib then return end

local ERROR_TYPE = "bad argument #%d to %q (%s expected, got %s)"

local gmatch, gsub, tremove = string.gmatch, string.gsub, table.remove
local pcall, setmetatable, type = pcall, setmetatable, type
local SecureCmdOptionParse, AND, OR, XOR = SecureCmdOptionParse, bit.band, bit.bor, bit.bxor

--[[----------------------------------------------------------------------------
Version bridge
------------------------------------------------------------------------------]]
local callback, enabled, monitor, mt, object, parameters, state

if oldRevision then
	callback, enabled, monitor, mt, object, parameters, state = lib.__void()
else
	callback, enabled, monitor, mt, object, parameters, state = { }, { }, CreateFrame('Frame'), { }, { }, { }, { }
	monitor:Hide()
end

local isValid = parameters														-- Alias for readability

--[[----------------------------------------------------------------------------
Constants
------------------------------------------------------------------------------]]
local ACTIVE_FLAG, EVENT_MASK = 0x80000000, 0x7FFFFFFF

local conditionMask = {
	actionbar		= 0x00000001,	-- bar
	bar				= 0x00000001,
	bonusbar		= 0x00002000,
	canexitvehicle	= 0x00000080,
	channeling		= 0x00001000,
	combat			= 0x00000100,
	equipped		= 0x00000040,	-- worn
	extrabar		= 0x00004000,
	form			= 0x00022000,	-- Not the same as bonusbar
	group			= 0x00000008,
	mod				= 0x00000010,
	modifier		= 0x00000010,	-- mod
	mounted			= 0x00000004,	-- COMPANION_UPDATE fires frequently but its better than OnUpdate
	overridebar		= 0x00008000,
	pet				= 0x00000800,
	petbattle		= 0x00000020,
	possessbar		= 0x00010000,
	resting			= 0x00000200,
	spec			= 0x00000002,
	stance			= 0x00022000,	-- form
	stealth			= 0x00040000,
	vehicleui		= 0x00000400,
	worn			= 0x00000040
}

local eventMask = {		-- eventMask[index] = 2^(index - 1)
	0x00000001, 0x00000002, 0x00000004, 0x00000008,
	0x00000010, 0x00000020, 0x00000040, 0x00000080,
	0x00000100, 0x00000200, 0x00000400, 0x00000800,
	0x00001000, 0x00002000, 0x00004000, 0x00008000,
	0x00010000, 0x00020000, 0x00040000
}

-- Channeling START and STOP enough?

local events = {
	'ACTIONBAR_PAGE_CHANGED', 'ACTIVE_TALENT_GROUP_CHANGED', 'COMPANION_UPDATE', 'GROUP_ROSTER_UPDATE',
	'MODIFIER_STATE_CHANGED', 'PET_BATTLE_OPENING_START', 'PLAYER_EQUIPMENT_CHANGED', 'PLAYER_GAINS_VEHICLE_DATA',
	'PLAYER_REGEN_DISABLED', 'PLAYER_UPDATE_RESTING', 'UNIT_ENTERED_VEHICLE', 'UNIT_PET',
	'UNIT_SPELLCAST_CHANNEL_START', 'UPDATE_BONUS_ACTIONBAR', 'UPDATE_EXTRA_ACTIONBAR', 'UPDATE_OVERRIDE_ACTIONBAR',
	'UPDATE_POSSESS_BAR', 'UPDATE_SHAPESHIFT_FORM', 'UPDATE_STEALTH'
}

local linkedEvent = {				-- These events need to resolve to a unique root event and never be in 'events' above
	PET_BATTLE_OPENING_START		= 'PET_BATTLE_CLOSE',
	PLAYER_GAINS_VEHICLE_DATA		= 'PLAYER_LOSES_VEHICLE_DATA',
	PLAYER_REGEN_DISABLED			= 'PLAYER_REGEN_ENABLED',
	UNIT_ENTERED_VEHICLE			= 'UNIT_EXITED_VEHICLE',
	UNIT_SPELLCAST_CHANNEL_START	= 'UNIT_SPELLCAST_CHANNEL_STOP',
	UPDATE_SHAPESHIFT_FORM			= 'UPDATE_SHAPESHIFT_FORMS'
}

local unitEvent = {
	UNIT_PET						= 'player',
	UNIT_ENTERED_VEHICLE			= 'player',
	UNIT_EXITED_VEHICLE				= 'player',
	UNIT_SPELLCAST_CHANNEL_START	= 'player',
	UNIT_SPELLCAST_CHANNEL_STOP		= 'player'
}

--[[----------------------------------------------------------------------------
Status flag cache for parameters: status[parameters] = flags
------------------------------------------------------------------------------]]
local status = setmetatable({ }, { __mode = 'k',
	__index = function(self, index)
		local status = 0
		for conditional in gmatch(index, "%b[]") do
			local emptyBraces = true
			-- Substitute '@' for 'target=' and get each condition, ignoring @unit and only returning "mod" for "mod:alt"
			for condition in gmatch(gsub(conditional, "([%[,])%s*target%s*=%s*", "%1@"), "[%[,]%s*(%a+)") do
				status = OR(status, conditionMask[condition] or ACTIVE_FLAG)
				emptyBraces = nil
			end
			if emptyBraces then break end										-- No conditions or only has @unit
		end
		self[index] = status
		return status
	end
})

--[[----------------------------------------------------------------------------
Monitors: Active, Event, and Modifier
------------------------------------------------------------------------------]]
local function EvaluateStates(registry, event)
	if event then
		registry = registry[event]
	end
	for index = #registry, 1, -1 do												-- Processed in reverse order in case
		local driver = registry[index]											-- the callback removes the driver
		local newState = SecureCmdOptionParse(parameters[driver])
		if state[driver] ~= newState then
			state[driver] = newState
			local ok, err = pcall(callback[driver], object[driver], newState)
			if not ok then
				geterrorhandler()(err)
			end
		end
	end
end

monitor:SetScript('OnEvent', EvaluateStates)

do
	local timer = 0
	monitor:SetScript('OnUpdate', function(self, elapsed)
		timer = timer + elapsed
		if timer < 0.2 then return end
		timer = 0
		EvaluateStates(self)
	end)
end

--[[----------------------------------------------------------------------------
Support
------------------------------------------------------------------------------]]
local function Register(driver, status)
	if AND(status, ACTIVE_FLAG) ~= 0 then
		if #monitor == 0 then
			monitor:Show()
		end
		monitor[#monitor + 1] = driver
	end
	if AND(status, EVENT_MASK) ~= 0 then
		for index = 1, #events do
			if AND(status, eventMask[index]) ~= 0 then
				local event = events[index]
				local registry = monitor[event]
				if registry then
					registry[#registry + 1] = driver
				else
					registry = { driver }
					repeat
						monitor[event] = registry
						if not unitEvent[event] then
							monitor:RegisterEvent(event)
						else
							monitor:RegisterUnitEvent(event, unitEvent[event])
						end
						event = linkedEvent[event]
					until not event
				end
			end
		end
	end
end

local function Unregister(driver, status)
	if AND(status, ACTIVE_FLAG) ~= 0 then
		for index = #monitor, 1, -1 do
			if monitor[index] == driver then
				tremove(monitor, index)
				if #monitor == 0 then
					monitor:Hide()
				end
				break
			end
		end
	end
	if AND(status, EVENT_MASK) ~= 0 then
		for index = 1, #events do
			if AND(status, eventMask[index]) ~= 0 then
				local event = events[index]
				local registry = monitor[event]
				if registry then
					for index = #registry, 1, -1 do
						if registry[index] == driver then
							tremove(registry, index)
							if #registry == 0 then
								repeat
									monitor:UnregisterEvent(event)
									monitor[event] = nil
									event = linkedEvent[event]
								until not event
							end
							break
						end
					end
				end
			end
		end
	end
end

local function Update(driver, stateOverride, enabledOverride)
	if callback[driver] and (enabled[driver] or enabledOverride) then
		local newState = SecureCmdOptionParse(parameters[driver])
		if state[driver] ~= newState or stateOverride then
			state[driver] = newState
			local ok, err = pcall(callback[driver], object[driver], newState)
			if ok then return end
			geterrorhandler()(err)
		end
	end
end

--[[----------------------------------------------------------------------------
Methods
------------------------------------------------------------------------------]]
mt.__call = Update

mt.__index = {
	["GetCallback"] = function(self)
		return callback[self]
	end,

	["GetObject"] = function(self)
		return object[self]
	end,

	["GetParameters"] = function(self, readable)
		return parameters[self]
	end,

	["GetState"] = function(self)
		return state[self]
	end,

	["IsActive"] = function(self)
		return enabled[self] and callback[self] and status[parameters[self]] ~= 0
	end,

	["IsEnabled"] = function(self)
		return enabled[self]
	end,

	["Recycle"] = function(self)
		if isValid[self] then
			if enabled[self] and callback[self] then
				Unregister(self, status[parameters[self]])
			end
			callback[self], enabled[self], object[self], parameters[self], state[self] = nil, nil, nil, nil, nil
			mt.__metatable = nil
			pcall(setmetatable, self, nil)
			mt.__metatable = LIB
		end
	end,

	["SetCallback"] = function(self, handler)
		if handler and type(handler) ~= 'function' then
			error(ERROR_TYPE:format(1, "SetCallback", "function or nil", type(handler)), 2)
		elseif isValid[self] and callback[self] ~= (handler or nil) then
			callback[self], handler = handler or nil, callback[self]
			if enabled[self] then
				if callback[self] then
					if not handler then
						Register(self, status[parameters[self]])
					end
					Update(self, true)
				elseif handler then
					Unregister(self, status[parameters[self]])
				end
			end
		end
	end,

	["SetEnabled"] = function(self, mode)
		if isValid[self] then
			mode = mode and true or nil
			if enabled[self] ~= mode then
				enabled[self] = mode
				if callback[self] then
					if mode then
						Register(self, status[parameters[self]])
						Update(self, true)
					else
						Unregister(self, status[parameters[self]])
					end
				end
			end
		end
	end,

	["SetObject"] = function(self, value)
		if isValid[self] then
			object[self] = value
		end
	end,

	["SetParameters"] = function(self, params, force)
		if params and type(params) ~= 'string' then
			error(ERROR_TYPE:format(1, "SetParameters", "string or nil", type(params)), 2)
		elseif isValid[self] then
			params = params or ""
			if parameters[self] ~= params then
				if enabled[self] and callback[self] then
					local newStatus, oldStatus = status[params], status[parameters[self]]
					if oldStatus ~= newStatus then
						local delta = XOR(oldStatus, newStatus)
						Unregister(self, AND(delta, oldStatus))
						Register(self, AND(delta, newStatus))
					end
				end
				parameters[self] = params
				Update(self, force)
			elseif force then
				Update(self, true)
			end
		end
	end,

	["Update"] = Update
}

mt.__metatable = LIB

--[[----------------------------------------------------------------------------
Private API
------------------------------------------------------------------------------]]
function lib.__void()
	monitor[0], monitor = monitor[0], wipe(monitor)
	monitor:UnregisterAllEvents()
	monitor:Hide()
	monitor:SetScript('OnEvent', nil)
	monitor:SetScript('OnUpdate', nil)

	wipe(lib)
	wipe(mt)
	return callback, enabled, monitor, mt, object, parameters, state
end

--[[----------------------------------------------------------------------------
Public API
------------------------------------------------------------------------------]]
function lib.New(enable, ...)
	local driver = setmetatable({ }, mt)
	object[driver], parameters[driver] = driver, ""								-- Needed so isValid works

	local method = mt.__index
	for index = 1, select('#', ...), 2 do
		local key, value = select(index, ...)
		if method[key] then
			if key == "SetEnabled" then
				enable = value
			elseif key:match("^Set") then										-- Ignore Is/Get... and Recycle
				local ok, err = pcall(method[key], driver, value)
				if not ok then
					geterrorhandler()(err)
				end
			end
		elseif key ~= nil then
			driver[key] = value
		end
	end

	if enable then
		driver:SetEnabled(true)
	end
	return driver
end

--[[----------------------------------------------------------------------------
Druid specific condition/event data
------------------------------------------------------------------------------]]
local _, class = UnitClass('player')
if class == 'DRUID' then
	local level = UnitLevel('player')
	if level >= 16 then															-- Travel Form
		local index = #events + 1
		local mask = 2^(index - 1)
		events[index], eventMask[index] = 'UPDATE_SHAPESHIFT_USABLE', mask
		conditionMask['indoors'] = mask
		conditionMask['outdoors'] = mask
		if level >= 18 then														-- Aquatic Form
			conditionMask['swimming'] = mask
			if level >= 58 then													-- Flight Form
				conditionMask['flyable'] = mask
			end
		end
	end
end

--[[----------------------------------------------------------------------------
Add 'no' versions to conditionMask and re-register state drivers
------------------------------------------------------------------------------]]
local new = { }
for key, value in pairs(conditionMask) do
	new[key], new['no' .. key] = value, value
end
conditionMask = new

for driver in pairs(enabled) do
	if callback[driver] then
		Register(driver, status[parameters[driver]])
		Update(driver)
	end
end
