local CommandsReleasingMouseList= { 'CameraOrSelectOrMove', 'TurnLeft', 'TurnRight', 'PitchUp', 'PitchDown' }
local CommandsLockingMouseList= { 'TurnOrAction', 'MoveAndSteer', 'MoveForward', 'MoveBackward', 'StrafeLeft', 'StrafeRight' }
-- tracking 'MoveAndSteer' is necessary for CombatMode:UpdateMouselook(), albeit it does the Mouselook locking itself
-- 'TargetPriorityHighlight':  TARGETSCANENEMY

CombatMode.CommandsLockingMouse= {}
CombatMode.CommandsReleasingMouse= {}
local CommandIgnored= {}

function CombatMode.CommandsLockingMouse:Update(possibleTransition, event)
	self.Mouselook=  self.TurnOrAction  or  self.MoveAndSteer  or  self.TargetPriorityHighlight
	self.Move=  self.MoveForward  or  self.MoveBackward
	self.Strafe=  self.StrafeLeft   or  self.StrafeRight
	CombatMode:UpdateMouselook(possibleTransition, event)
end

function CombatMode.CommandsReleasingMouse:Update(possibleTransition, event)
	self.Turn=  cmds.CameraOrSelectOrMove  or  cmds.TurnLeft  or  cmds.TurnRight
	self.Pitch=  cmds.PitchUp  or  cmds.PitchDown
	CombatMode:UpdateMouselook(possibleTransition, event)
end


local function CommandLockStartHook(cmds, cmdName, event)
	if  not CombatMode:IsEnabledWhileMoving()  then  CommandIgnored[cmdName]= true ; return  end
	
	if  cmds[cmdName]  then
		CombatMode:LogAnomaly('CommandLockStartHook('.. cmdName ..'):  key pressed again without being released')
	end
	
	cmds[cmdName]= true
	cmds:Update(true, event)
end


local function CommandLockStopHook(cmds, cmdName, event)
	local cmds= CombatMode.CommandsLockingMouse
	if  not cmds[cmdName]  then
		if  not CommandIgnored[cmdName]  then
			CombatMode:LogAnomaly('CommandLockStopHook('.. cmdName ..'):  key released without being pressed')
		else
			CommandIgnored[cmdName]= nil
		end
		return
	end
	
	cmds[cmdName]= false
	-- false/nil if all false, table if any true
	CombatMode.CommandsLockingMouse.Mouselook= cmds.TurnOrAction or cmds.MoveAndSteer
	local anyTrue=
		cmds.MoveAndSteer   or cmds.TurnOrAction
		or cmds.MoveForward or cmds.MoveBackward
		or cmds.StrafeLeft  or cmds.StrafeRight
	CombatMode.AnyCommandsLocking= anyTrue
	
	--if  CombatMode.CommandsLocking  then  return  end
	CombatMode:UpdateMouselook(false, event)
end



local function CommandReleaseStartHook(cmds, cmdName, event)
	--[[
	Mouse is released for all Turn/Pitch actions even if  not CombatMode:IsEnabledWhileMoving(),
	to work around the default behaviour of TURN* and LEFT* commands,
	which STRAFE* if  IsMouselooking() == true  (as an indicator of BUTTON2 being pressed).
	With CombatMode  BUTTON2 is NOT pressed, but IsMouselooking() == true
	and TURN* should to the original turning action. For this 
	as it prevents the player to turn his character with keys
	--]]
	CombatMode.CommandsReleasingMouse[cmdName]= true
	CombatMode.AnyCommandsReleasing= true
	-- stop Mouselook when Turn/Pitch key pressed
	CombatMode:UpdateMouselook(false, event)
end


local function CommandReleaseStopHook(cmds, cmdName, event)
	local cmds= CombatMode.CommandsReleasingMouse
	if  not cmds[cmdName]  then  CombatMode:LogAnomaly('CommandReleaseStopHook('.. cmdName ..'):  key released without being pressed')  end
	
	cmds[cmdName]= false
	-- false/nil if all false, table if any true
	local anyTrue= cmds.CameraOrSelectOrMove
		or cmds.TurnLeft or cmds.TurnRight
		or cmds.PitchUp  or cmds.PitchDown
	CombatMode.AnyCommandsReleasing= anyTrue
	
	--if  CombatMode.CommandsReleasing  then  return  end
	CombatMode:UpdateMouselook(true, event)
end


CombatMode.CommandsLockingMouse.StartHook= CommandLockStartHook
CombatMode.CommandsLockingMouse.StopHook= CommandLockStopHook
CombatMode.CommandsReleasingMouse.StartHook= CommandReleaseStartHook
CombatMode.CommandsReleasingMouse.StopHook= CommandReleaseStopHook



--[[
local lastMouselook
local function  MouselookChange()
	if  lastMouselook == IsMouselooking()  then  return ''  end
	lastMouselook= IsMouselooking()
  return  'Mouselook  ' .. boolstr(IsMouselooking())
end

local CommandHooks= {}
CombatMode.CommandHooks= CommandHooks

function CommandHooks.ToggleAutoRun()
	print('ToggleAutoRun():  ' .. MouselookChange() )
end

if  _G.StartAutoRun  then
	function CommandHooks.StartAutoRun()
		print('StartAutoRun():  ' .. MouselookChange() )
	end
end


local MoveButtonDown= false
function CommandHooks.MoveAndSteerStart()
	print('MoveAndSteerStart():  ' .. MouselookChange() )
	MoveButtonDown= true
end
function CommandHooks.MoveAndSteerStop()
	print('MoveAndSteerStop():   ' .. MouselookChange() )
	MoveButtonDown= false
	if  MouselookLocked  and not IsMouselooking()  then
	  MouselookStart()
		print('  MouselookLocked->   ' .. MouselookChange() )
  end
end


function CommandHooks.TurnOrActionStart()
	print('TurnOrActionStart():  ' .. MouselookChange() )
end
function CommandHooks.TurnOrActionStop()
	print('TurnOrActionStop():   ' .. MouselookChange() )
	if  MouselookLocked  and not IsMouselooking()  then
	  MouselookStart()
		print('  MouselookLocked->   ' .. MouselookChange() )
  end
end
--]]


local function  HookCommandPrefixed(cmds, cmdName, suffixStart, suffixStop)
	suffixStart= suffixStart or 'Start'
	suffixStop=  suffixStop  or 'Stop'
	hooksecurefunc(cmdName .. suffixStart, function ()  CommandLockStartHook(cmds, cmdName, cmdName .. suffixStart)  end)
	hooksecurefunc(cmdName .. suffixStop , function ()  CommandLockStopHook (cmds, cmdName, cmdName .. suffixStop )  end)
end

function  CombatMode:HookCommands()
	CombatMode:LogInit('HookCommands()')
	if  not CommandsLockingMouseList  then  return false  end
	
	--[[
	for  funcName, hookFunc  in  pairs(CommandHooks)  do
		hooksecurefunc(funcName, hookFunc)
	end
	--]]
	for  idx,cmdName  in  ipairs(CommandsLockingMouseList)  do
		-- CommandLockStartHook and co. are defined as locals therefore need to be before this line
		HookCommandPrefixed(CommandsLockingMouse, cmdName)
	end
	for  idx,cmdName  in  ipairs(CommandsReleasingMouseList)  do
		HookCommandPrefixed(CommandsReleasingMouse, cmdName)
	end
	
	HookCommandPrefixed(CommandsLockingMouse, 'TargetPriorityHighlight', 'Start', 'End')
	
	-- drop entries: not used until /reload, secure hooking is non-reversible
	CommandsLockingMouseList= nil
	CommandsReleasingMouseList= nil
	
	return true
end


