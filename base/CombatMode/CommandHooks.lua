local ADDON_NAME, _ADDON = ...
local commands = {}
CombatMode.commands = commands
commands.uniqueHooks = {}
commands.state= {}
commands.map = {}
commands.groups= {
	NeedCursor		= {},
	Mouselook			= {},
	MoveKeys			= {},
}


commands.grouping = {
	CameraOrSelectOrMove		= 'NeedCursor',    -- not if TurnOrAction is pressed
	TurnLeft			= 'NeedCursor',
	TurnRight			= 'NeedCursor',
	PitchUp				= 'NeedCursor',
	PitchDown			= 'NeedCursor',
	
	TurnWithMouse	= 'Mouselook',		-- custom command in Bindings.xml
	-- TurnOrAction	= 'Mouselook',
	TurnOrAction	= false,          -- Inverse of ExpectedMouselook() before pressed.
	
	MoveAndSteer	= 'Mouselook',
	-- TargetScanEnemy, TargetNearestEnemy:
	TargetPriorityHighlight	= 'Mouselook',
	
	MoveForward		= 'MoveKeys',
	MoveBackward	= 'MoveKeys',
	StrafeLeft		= 'MoveKeys',
	StrafeRight		= 'MoveKeys',
}

commands.hooked = {
	TargetPriorityHighlight	= _G.TargetPriorityHighlightStart and 'TargetPriorityHighlightEnd' or false,
}

commands.stopsAutoRun = {
	MoveAndSteerStart	= 1,
	MoveForwardStart	= 1,
	MoveBackwardStart	= 1,
}

--[[
TurnOrAction, MoveAndSteer, TargetPriorityHighlight  start Mouselook when pushed and stop it when released.
These are the only commands/functions altering Mouselook that I found. All other functions
altering Mouselook will be logged as anomaly.
Sidenote:  when  enabledPermanent == true  or  TurnWithMouse == true  then we want Mouselook to stay ON after releasing these keys,
therefore UpdateMouselook() will override the effect of the Stop functions.
--]]
commands.changingMouselook = {
	TurnOrActionStart	= true,
	TurnOrActionStop	= false,
	MoveAndSteerStart	= true,
	MoveAndSteerStop	= false,
	-- TargetScanEnemy, TargetNearestEnemy:
	TargetPriorityHighlightStart	= true,
	TargetPriorityHighlightEnd		= false,
}



-- The entry point of all hooks.
--
function commands:StartStopHook(cmdName, pressed, event)
	if  self.stopsAutoRun[event]  then  self:SwitchAutoRun(false, event)  end
	-- if  cmdName == 'MoveAndSteer'  then  CombatMode:OverrideBindingsIn(cmdName, pressed)  end
	
	local stateOk = self:SetState(cmdName, pressed)
	
	if not stateOk then
		local suffix= pressed  and  "key pressed again without being released. Stuck key?"  or  "key released without being pressed before."
		CombatMode:LogAnomaly("  CM - StartStopHook(".. CombatMode.colors.red .. cmdName .."|r):  ".. suffix)
	else
		local keystate=  pressed  and  'down'  or  'up'
		CombatMode:LogCommand("  CM - StartStopHook(".. CombatMode.colors[keystate] .. cmdName .." ".. keystate:upper() .."|r)")
	end
	
	-- Commands in NeedCursor group disable Mouselook: expected Mouselook state is the opposite of the keypress state
	if  self.grouping[cmdName] == 'NeedCursor'  then  pressed= not pressed  end
	
	-- Do MouselookStart/Stop as necessary
  CombatMode:UpdateMouselook(pressed, event)
end


function commands:SetState(cmdName, pressed)
	-- Allow multiple keys bound to the same command to be pressed at the same time?
	-- That results in multiple calls with same cmdName, pressed.
	-- Press 2 buttons, release 1, state should be pressed.
	-- On the other hand if a binding is changed mid-button-press, then the Up/Stop event won't be called,
	-- the counter remains incremented, and the state is stuck.
	-- That actually happens, while pressing 2 keys bound to the same command not so much.
	if  pressed == (self.state[cmdName] or false)  then
		-- Patch MoveAndSteer press + MouselookOverrideBinding(MoveAndSteer->MoveForward) + MoveForward release
		-- to stop Mouselook started by MoveAndSteer.
		if cmdName == 'MoveForward' and self.state.MoveAndSteer then
			CombatMode:LogAnomaly("  CM - SetState(".. CombatMode.colors[keystate] .. cmdName .." ".. keystate:upper() .."|r) - patched to MoveAndSteer")
			cmdName = 'MoveAndSteer'
		else
			return false
		end
	else
		if cmdName == 'MoveForward' and GetMouseButtonClicked() then
			CombatMode:LogAnomaly("  CM - SetState(".. CombatMode.colors[keystate] .. cmdName .." ".. keystate:upper() .."|r) - patched to MoveAndSteer")
			cmdName = 'MoveAndSteer'
		end
  end
	
	-- TurnOrAction inverts the Mouselook state before it was pressed.
	if cmdName == 'TurnOrAction' then
		if pressed
		then  self.state.TurnOrActionForcesState = not CombatMode:ExpectedMouselook()
		else  self.state.TurnOrActionForcesState = nil
		end
		-- To get the Mouselook state before pressing TurnOrAction
		-- CombatMode:ExpectedMouselook() must be called before  self.state[cmdName]= pressed  is set.
		-- Note: This is the secure hook ran after TurnOrActionStart(), which just enabled Mouselook,
		-- therefore IsMouselooking() returns true in any case.
	end

	if cmdName == 'MoveAndSteer' then  CombatMode.OverrideBindingsIn('MoveAndSteer', press))  end

	if pressed then
		if cmdName == 'MoveAndSteer' and CombatMode.enableWithMoveAndSteer then  CombatMode:SetActionMode(true)  end
	end
	-- TODO:
	-- CombatMode.enableWithBothButtons ", "Enable with both mouse buttons", "After pressing LeftButton and RightButton together: ActionMode will stay enabled."),
	-- CombatMode.enableWithMoveAndSteer", "Enable with Move and steer", "After pressing MoveAndSteer: ActionMode will stay enabled."),
	-- CombatMode.disableWithLookAround ", "Disable with looking around", "Turning the camera away from the direction your character looks (with LeftButton) will disable ActionMode."),

	-- Set command pressed state
	self.state[cmdName]= pressed

	-- Increment/decrement command group's count
	local groupName= self.grouping[cmdName]
	local group= self.groups[groupName]		-- nil, if groupName == nil/false
	if  group  then
		local prefix= '  CM - SetState('.. CombatMode.colors[pressed] .. CombatMode.colorBoolStr(pressed, true) ..'|r):  groups.'.. groupName
		if  pressed  then  
			local removed= _ADDON.tableProto.setReInsertLast(group, cmdName)
			if  removed  then  CombatMode:LogAnomaly(prefix ..'  already contained  '.. CombatMode.colors.red .. tostring(removed) ..'|r')  end
			if  removed  and  type(removed) ~= string  then  _G.CMremoved= removed  end
		else
			local removed= _ADDON.tableProto.removeFirst(group, cmdName)
			if  not removed  then  CombatMode:LogAnomaly(prefix ..'  did not contain  '.. CombatMode.colors.red .. cmdName ..'|r')  end
		end
	end
	
	return true
end




function commands.uniqueHooks.ToggleAutoRun()
	-- No self here: these 3 are called as plain functions, not methods, therefore no ':' before the function name
	commands:SwitchAutoRun(nil, 'ToggleAutoRun')
end

function commands.uniqueHooks.StartAutoRun()
	commands:SwitchAutoRun(true, 'StartAutoRun')
end

function commands.uniqueHooks.StopAutoRun()
	commands:SwitchAutoRun(false, 'StopAutoRun')
end


function commands:SwitchAutoRun(newState, event)
	if  newState == nil  then  newState= not self.state.AutoRun
	elseif  newState == (self.state.AutoRun or false)  then  return  end
	
	self.state.AutoRun= newState
	CombatMode:LogState('  CM - SwitchAutoRun('.. CombatMode.colors.event .. event ..'|r):  ' .. CombatMode.colorBoolStr(newState, true) )
	CombatMode:OverrideBindingsIn('AutoRun', newState)
end




function commands:HookCommandPrefixed(cmdName, funcStart, funcStop)
	hooksecurefunc(funcStart, function ()  self:StartStopHook(cmdName, true,  funcStart )  end)
	hooksecurefunc(funcStop , function ()  self:StartStopHook(cmdName, false, funcStop  )  end)
end

function commands:HookCommands()
	CombatMode:LogInit('CM - HookCommands()')
	
	for  cmdName,group  in  pairs(self.grouping)  do
		local stopFunc = self.hooked[cmdName]
		if stopFunc ~= false then  self:HookCommandPrefixed(cmdName, cmdName..'Start', stopFunc or cmdName..'Stop')  end
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



