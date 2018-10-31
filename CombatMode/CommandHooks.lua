local AddonName, Addon = ...
CombatMode.commands = {}


BINDING_NAME_TURNWITHMOUSE = "Turn with mouse, no actions"

function CombatMode.commands:TurnWithMouseKey(keystate)
	local start= keystate == 'down'
	local event= start  and  'TurnWithMouseDown'  or  'TurnWithMouseUp'
	self:StartStopHook(start, 'TurnWithMouse', event)
end



CombatMode.commands.uniqueHooks = {}
CombatMode.commands.state= {}
CombatMode.commands.groups= {
	NeedCursor		= {},
	Mouselook			= {},
	MoveKeys			= {},
}

CombatMode.commands.grouping = {
	CameraOrSelectOrMove		= 'NeedCursor',    -- not if TurnOrAction is pressed
	TurnLeft			= 'NeedCursor',
	TurnRight			= 'NeedCursor',
	PitchUp				= 'NeedCursor',
	PitchDown			= 'NeedCursor',
	
	TurnWithMouse	= 'Mouselook',		-- custom command in Bindings.xml
	TurnOrAction	= 'Mouselook',
	MoveAndSteer	= 'Mouselook',
	-- TargetScanEnemy, TargetNearestEnemy:
	TargetPriorityHighlight	= 'Mouselook',
	
	MoveForward		= 'MoveKeys',
	MoveBackward	= 'MoveKeys',
	StrafeLeft		= 'MoveKeys',
	StrafeRight		= 'MoveKeys',
	
	HoldToEnable	= 'Mouselook',		-- same action as TurnWithMouse
	HoldToDisable	= 'NeedCursor',		-- this gets stuck if bound to a mouse button: the 'up' event is not received
}

local StartStop = {'Start', 'Stop'}
CombatMode.commands.hooked = {
	CameraOrSelectOrMove	= StartStop,
	TurnLeft			= StartStop,
	TurnRight			= StartStop,
	PitchUp				= StartStop,
	PitchDown			= StartStop,
	
	TurnWithMouse	= nil,
	TurnOrAction	= StartStop,
	MoveAndSteer	= StartStop,
	TargetPriorityHighlight	= {'Start', 'End'},
	
	MoveForward		= StartStop,
	MoveBackward	= StartStop,
	StrafeLeft		= StartStop,
	StrafeRight		= StartStop,
}
StartStop= nil
-- new function in Warlords:
if  not _G.TargetPriorityHighlightStart  then  CombatMode.commands.hooked.TargetPriorityHighlight	= nil		end


CombatMode.commands.stopsAutoRun = {
	MoveAndSteerStart	= 1,
	MoveForwardStart	= 1,
	MoveBackwardStart	= 1,
}

--[[
TurnOrAction, MoveAndSteer, TargetPriorityHighlight  start Mouselook when pushed and stop it when released.
These are the only commands/functions altering Mouselook that I found. All other functions
altering Mouselook will be logged as anomaly.
Sidenote:  when  enableAllways == true  or  holdToEnable == true  then we want Mouselook to stay ON after releasing these keys,
therefore UpdateMouselook() will override the effect of the Stop functions.
--]]
CombatMode.commands.changingMouselook = {
	TurnOrActionStart	= true,
	TurnOrActionStop	= false,
	MoveAndSteerStart	= true,
	MoveAndSteerStop	= false,
	-- TargetScanEnemy, TargetNearestEnemy:
	TargetPriorityHighlightStart	= true,
	TargetPriorityHighlightEnd		= false,
}





function CombatMode.commands:StartStopHook(cmdName, state, event)

	if  self.stopsAutoRun[event]  then  self:SwitchAutoRun(false, event)  end
	
	if  state == self.state[cmdName]  then
		local suffix= state  and  'key pressed again without being released'  or  'key released without being pressed before'
		CombatMode:LogAnomaly('  CM - StartStopHook('.. CombatMode.colors.red .. cmdName ..'|r):  '.. suffix)
		--CombatMode:UpdateMouselook(state, event)
		return
	end
	
	local keystate=  state  and  'down'  or  'up'
	CombatMode:LogCommand('  CM - StartStopHook('.. CombatMode.colors[keystate] .. cmdName ..' '.. keystate:upper() ..'|r)')
	
	self:SetState(cmdName, state)
	
	-- Commands in NeedCursor group disable Mouselook: expected Mouselook state is the opposite of the keypress state
	if  self.grouping[cmdName] == 'NeedCursor'  then  state= not state  end
	
	-- Do MouselookStart/Stop as necessary
  CombatMode:UpdateMouselook(state, event)
end


function CombatMode.commands:SetState(cmdName, state)
	if  state == (self.state[cmdName] or false)  then  return false  end
	
	-- Set command pressed state
	self.state[cmdName]= state
	
	-- Increment/decrement command's group count
	local groupName= self.grouping[cmdName]
	local group= self.groups[groupName]		-- nil, if groupName == nil
	if  group  then
		local prefix= '  CM - SetState('.. CombatMode.colors[state] .. Addon.colorBoolStr(state, true) ..'|r):  groups.'.. groupName
		if  state  then  
			local removed= Addon.tableProto.setReInsertLast(group, cmdName)
			if  removed  then  CombatMode:LogAnomaly(prefix ..'  already contained  '.. CombatMode.colors.red .. tostring(removed) ..'|r')  end
			if  removed  and  type(removed) ~= string  then  _G.CMremoved= removed  end
		else
			local removed= Addon.tableProto.removeFirst(group, cmdName)
			if  not removed  then  CombatMode:LogAnomaly(prefix ..'  did not contain  '.. CombatMode.colors.red .. cmdName ..'|r')  end
		end
	end
	
	return true
end



function CombatMode.commands.uniqueHooks.ToggleAutoRun()
	-- no self, these 3 are called as plain functions, not methods, therefore no ':' before the function name
	CombatMode.commands:SwitchAutoRun(nil, 'ToggleAutoRun')
end

function CombatMode.commands.uniqueHooks.StartAutoRun()
	CombatMode.commands:SwitchAutoRun(true, 'StartAutoRun')
end

function CombatMode.commands.uniqueHooks.StopAutoRun()
	CombatMode.commands:SwitchAutoRun(false, 'StopAutoRun')
end


function CombatMode.commands:SwitchAutoRun(newState, event)
	if  newState == nil  then  newState= not self.stateAutoRun
	elseif  newState == (self.stateAutoRun or false)  then  return  end
	
	self.stateAutoRun= newState
	CombatMode:LogState('  CM - SwitchAutoRun('.. CombatMode.colors.event .. event ..'|r):  ' .. Addon.colorBoolStr(newState, true) )
	CombatMode.OverrideFrames.AutoRun:EnableOverrides(newState)
end




function CombatMode.commands:HookCommandPrefixed(cmdName, suffixStart, suffixStop)
	local  funcStart = cmdName .. (suffixStart or 'Start')
  local  funcStop  = cmdName .. (suffixStop  or 'Stop' )
	hooksecurefunc(funcStart, function ()  self:StartStopHook(cmdName, true,  funcStart )  end)
	hooksecurefunc(funcStop , function ()  self:StartStopHook(cmdName, false, funcStop  )  end)
end

function CombatMode.commands:HookCommands()
	CombatMode:LogInit('CM - HookCommands()')
	
	for  cmdName,suffix  in  pairs(self.hooked)  do if  suffix  then
		self:HookCommandPrefixed(cmdName, suffix[1], suffix[2])
	end end
	self.hooked= nil		-- free up, not used until /reload
	
	for  funcName,hookFunc  in  pairs(self.uniqueHooks)  do
		if  _G[funcName]  then
			hooksecurefunc(funcName, hookFunc)
		elseif  CombatMode.logging.Anomaly  then
			CombatMode:LogInit('  CM - HookCommands():  hooked function not found: '.. CombatMode.colors.red .. funcName .. '|r')
		end
	end
	
	-- Overwrite this function with a dummy, ensure it's not called again
	function self:HookCommands()
		CombatMode:LogAnomaly('  CM - HookCommands() called a second time')
		return false
	end
	
	return true
end



