local addon, ns = ...
local L = ns.L
local GetTime = GetTime

local AceEvent = LibStub:GetLibrary("AceEvent-3.0")
local AceTimer = LibStub:GetLibrary("AceTimer-3.0")

-- ------------------------------- --
-- modules table and init function --
-- ~Hizuro                         --
-- ------------------------------- --
ns.modules = {}
-- ns.updateList = {}
-- ns.timeoutList = {}
ns.updateTimers = {}

ns.frame = CreateFrame('Frame')
-- ns.animGroup = ns.frame:CreateAnimationGroup()
-- ns.animGroup:SetLooping("REPEAT")

local function callOnUpdate(timer)
	local now = GetTime()
	local elapsed = now - timer.lastTime
	timer.lastTime = now
	timer.modData:onupdate(elapsed)
end

local function createUpdater(name, modData)
	local animGroup = ns.frame:CreateAnimationGroup()
	animGroup:SetLooping('REPEAT')
	local timer = animGroup:CreateAnimation()
	timer:SetScript('OnFinished', callOnUpdate)
	
	timer.animGroup = animGroup
	timer.modData = modData
	timer.lastTime = GetTime()
	
	local interval = modData.updateinterval
	if not interval or interval < 0.01 then
		interval = 0.01    -- on every frame, up to 100fps
	end
	timer:SetDuration(interval)
	
	-- TODO: possible to add anim to animGroup while Play()-ing?
	animGroup:Play()
	-- ns.updateTimers[name] = timer
	return timer
end

local function stopUpdater(name)
	local timer = ns.updateTimers[name]
	if not timer then  return  end

	timer.animGroup:Stop()
	timer.animGroup:SetParent(nil)
	timer.animGroup:SetLooping('NONE')
	timer.animGroup = nil
	timer.modData = nil
	timer.lastTime = nil
	timer:SetScript('OnFinished', nil)
	timer:SetParent(nil)
	ns.updateTimers[name] = nil
end


-- Forward declaration
local sendEvent    -- function sendEvent(modData, event)

-- pairs(nil or EMPTYTABLE) to not crash
local EMPTYTABLE = setmetatable({}, { __newindex = function()  error("Can't add properties to the EMPTYTABLE.")  end, __metatable = "EMPTYTABLE is not to be modified." })



local function moduleInit(name, modData)
		modData.name  = name
		modData.label = modData.label or L[name]

		if  not ns.isEnabled(name)  then  return  end


		local modDB = Broker_EverythingDB[name]
		modData.modDB = modDB
		if  not modDB  then  modDB = {}  Broker_EverythingDB[name] = modDB  end

		-- Reset disallowed values.
		for  varname,allowed  in  pairs(modData.config_allowed or EMPTYTABLE)  do
			if  not allowed[ modDB[varname] ]  then  modDB[varname] = nil  end
		end
		if  not CONFIG_USE_META  and  modData.config_defaults  then
			-- Copy missing default values.
			for  varname,default  in  pairs(modData.config_defaults or EMPTYTABLE)  do
				if modDB[varname] == nil then  modDB[varname] = default  end
			end
		elseif  modData.config_defaults  then
			-- Or use metatable to lookup defaults when value is nil.
			setmetatable(modDB, { __index = modData.config_defaults })
		end

		-- if  ns.isEnabled(name)  then

		if  modData.onupdate  then
			ns.updateTimers[name] = createUpdater(name, modData)
		end

		if  modData.ontimeout  and  type(modData.timeout)=="number"  and  modData.timeout > 0  then
			local afterEvent = modData.timeoutAfterEvent or modData.afterEvent
			local function startTimeout(event)
				if  afterEvent  then  AceEvent.UnregisterEvent(modData, afterEvent)  end
				AceTimer.ScheduleTimer(modData, 'ontimeout', modData.timeout)
			end
			if  afterEvent  then  AceEvent.RegisterEvent(modData, afterEvent, startTimeout)
			else  startTimeout()
			end
		end

		-- event handler registration
		if modData.onevent then
			modData.UnregisterEvent = AceEvent.UnregisterEvent
			for _, event in pairs(modData.events) do
				AceEvent.RegisterEvent(modData, event, 'onevent')
			end
		end

		-- pre LDB init
		if modData.preinit then  modData.preinit()  end
		-- modData.preinit = nil
		if modData.init then
			print("Broker_Everything.moduleInit("..name.."): module.init() deprecated, use .preinit() or .initbroker(dataobj) instead.")
			modData.init()
		end

		if  not modData.noBroker  then
--[[
	module.onqtip(module.tooltip)

module.onqtip = function(tt)
	if  not tt  or  tt.key ~= module.name  then  return  end
	if  not tt  or  tt.key ~= module.name  or  not tt:IsShown()  then  return  end
	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "RIGHT")
..end
module.mouseOverTooltip = true
module.onenter = function(display)
	ns.defaultOnEnter(module, display)
end
--]]
			if  modData.onqtip  then
				-- Migration to onqtip:  move tt:SetColumnLayout(count, ...) from onenter() to ontooltip(), then rename to onqtip(), insert tt:Clear()
				modData.onenter = modData.onenter  or  function (displayFrame)  ns.defaultOnEnter(modData, displayFrame)  end
				modData.onleave = modData.onleave  or  function (displayFrame)  ns.defaultOnLeave(modData, displayFrame)  end
				
			elseif  modData.ontooltip  and  not modData.onenter  then
				-- modData.ontooltipshow = modData.ontooltip
				modData.ontooltipshow = function (tooltip)  ns.defaultOnTooltipShow(modData, tooltip)  end
			end

			local ldbName =  Broker_EverythingDB.usePrefix  and  "BE"..name  or  name
			local icon = ns.I( name..(modData.icon_suffix or "") )
			local iColor = Broker_EverythingDB.iconcolor
			local default = {
				-- button data
				type          = "data source",
				name          = ldbName,
				label         = modData.label,
				icon          = icon.iconfile, -- default or custom icon
				staticIcon    = icon.iconfile, -- default icon only
				iconCoords    = icon.coords or {0, 1, 0, 1},

				-- button event functions
				OnEnter       = modData.onenter or nil,
				OnLeave       = modData.onleave or nil,
				OnClick       = modData.onclick or nil,
				OnDoubleClick = modData.ondblclick or nil,
				OnTooltipShow = modData.ontooltipshow or nil
			}

			local obj = modData.obj
			if  obj  then
				for k,v in pairs(obj) do
					if  obj[k] == nil  then  obj[k] = default[k]  end
				end
			end

			modData.obj = ns.LDB:NewDataObject(ldbName, obj or default)
			ns.updateIconColor(modData)

			if Broker_EverythingDB.libdbicon then
				if  not modDB.dbi  then  modDB.dbi = {}  end
				ns.LDBI:Register(ldbName,modData.obj,modDB.dbi)
				modData.dbi = true
			end

			-- post LDB init
			if modData.initbroker then  modData.initbroker(modData.obj)  end
			-- modData.initbroker = nil

		end  -- if  not modData.noBroker

		-- post LDB init: deprecated .init(module)
		if modData.init then  modData.init(modData)  end
		-- modData.init = nil

		-- panels for single modules
		if modData.optionpanel then
			ns.OP[name.."Subpanel"] = ns.LSO.AddSuboptionsPanel(addon, modData.label, modData.optionspanel)
		end

		-- chat command registration
		if modData.chatcommands then
			for i,v in pairs(modData.chatcommands) do
				if type(i)=="string" and ns.commands[i]==nil then -- prevents overriding
					ns.commands[i] = v
				end
			end
		end

		-- startup events mocked if loading later
		if modData.onevent and modData.events and IsLoggedIn() then
			sendEvent(modData, "ADDON_LOADED")
			sendEvent(modData, "VARIABLES_LOADED")
			sendEvent(modData, "SPELLS_CHANGED")
			sendEvent(modData, "PLAYER_LOGIN")
			if IsPlayerInWorld() then  sendEvent(modData, "PLAYER_ENTERING_WORLD")  end
		end
end

local function tindexOf(t, item)
	for  i = 1,t and #t or 0  do  if  t[i] == item  then  return i  end end
end

--local
function sendEvent(modData, event)
	if  tindexOf(modData.events, event)  then  modData.onevent(modData, event)  end
end


local function moduleDisable(name, module)
	stopUpdater(name)
	AceEvent.UnregisterAllEvents(module)
	AceTimer.CancelAllTimers(module)

	if module.tooltip  then
		ns.LQT:Release(module.tooltip)
	end
	if module.tooltip  then
		module.tooltip:Hide()
		module.tooltip = nil
	end

	if ns.LDB.RemoveDataObject then
		ns.LDB:RemoveDataObject(module.obj)
		-- module.obj = false  -- Keep it, might reenable.
	end
	if module.dbi then
		ns.LDBI:Hide(ldbName)
		if ns.LDBI.Unregister then
			ns.LDBI:Unregister(ldbName, module.obj)
			module.dbi = false
		end
	end

	if module.ondisable then  module:ondisable()  end
end



function ns.modulesInit()
	local i = 0
	for name, module in pairs(ns.modules) do
		moduleInit(name, module)
		i = i+1
	end
end

function ns.modulesOnLogout()
	-- Remove defaults from SavedVariables, like AceDB does, except for tables, those aren't checked in depth.
	for  name,module  in  pairs(ns.modules)  do
		local modDB = Broker_EverythingDB[name]
		-- Also check modDB ~= nil for safety.
		for  varname,default  in pairs(modDB and module.config_defaults or EMPTYTABLE)  do
			if  modDB[varname] == default  then  modDB[varname] = nil  end
		end
	end
end



function ns.isEnabled(name)
	local enabled = Broker_EverythingDB[name] and Broker_EverythingDB[name].enabled
	if  enabled == nil  then  enabled = ns.modules[name].enabled  end
	return  enabled ~= false
end

--[[
function ns.isEnabled(name)
	local enabled = Broker_EverythingDB[name].enabled
	if  enabled ~= nil  then  return enabled  end
	return  ns.modules[name].enabled ~= false
end
--]]

function ns.enableModule(name, enable)
	local was, default = ns.isEnabled(name), ns.modules[name].enabled ~= false
	
	if  enable == default  then  Broker_EverythingDB[name].enabled = nil
	else  Broker_EverythingDB[name].enabled = enable
	end
	
	if  enable == was  then  return false  end
	
	local module = ns.modules[name]
	if  enable  then  moduleInit(name, module)
	else  moduleDisable(name, module)
	end
	return true
end


function ns.highlightOnMouseover(tt, line)
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
end

