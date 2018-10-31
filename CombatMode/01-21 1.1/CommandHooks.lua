
local CommandsReleasingMouse= { 'CameraOrSelectOrMove', 'TurnLeft', 'TurnRight', 'PitchUp', 'PitchDown' }
local CommandsLockingMouse= { 'TurnOrAction', 'MoveAndSteer', 'MoveForward', 'MoveBackward', 'StrafeLeft', 'StrafeRight' }
-- tracking 'MoveAndSteer' is necessary for CombatMode:UpdateState(), albeit it does the Mouselook locking itself


local function CommandLockStartHook(cmdName)
	-- no Mouselook if shift pressed, todo: configure modifier: Shift/Alt/Ctrl
	if  IsShiftKeyDown()  then  return  end
	
	-- no Mouselook if frame open, not even after it's closed
  --if  checkForDisableState()  then  return  end
	
	local cmds= CommandsLockingMouse
	cmds[cmdName]= true
	CombatMode.CommandsLockingWithFrame= cmds.TurnOrAction or cmds.MoveAndSteer
	CombatMode.CommandsLocking= cmds
	-- start/continue Mouselook when movement key pressed
	CombatMode:UpdateState(true, cmdName ..'Start')
end

local function CommandLockStopHook(cmdName)
	local cmds= CommandsLockingMouse
	if  not cmds[cmdName]  then  print('CommandLockStopHook('.. cmdName ..'):  key released without being pressed')  end
	
	cmds[cmdName]= false
	-- false/nil if all false, table if any true
	CombatMode.CommandsLockingWithFrame= cmds.TurnOrAction or cmds.MoveAndSteer
	local anyTrue=
		cmds.MoveAndSteer   or cmds.TurnOrAction
		or cmds.MoveForward or cmds.MoveBackward
		or cmds.StrafeLeft  or cmds.StrafeRight
	CombatMode.CommandsLocking= anyTrue  and  CommandsLockingMouse
	
	--if  CombatMode.CommandsLocking  then  return  end
	CombatMode:UpdateState(false, cmdName ..'Stop')
end


local function CommandReleaseStartHook(cmdName)
	-- no Mouselook if shift pressed, todo: configure modifier: Shift/Alt/Ctrl
	--if  IsShiftKeyDown()  then  return  end
	
	-- no Mouselook if frame open, not even after it's closed
  --if  checkForDisableState()  then  return  end
	
	CommandsReleasingMouse[cmdName]= true
	CombatMode.CommandsReleasing= CommandsReleasingMouse
	-- stop Mouselook when movement key pressed
	CombatMode:UpdateState(false, cmdName ..'Start')
end

local function CommandReleaseStopHook(cmdName)
	local cmds= CommandsReleasingMouse
	if  not cmds[cmdName]  then  print('CommandReleaseStopHook('.. cmdName ..'):  key released without being pressed')  end
	
	cmds[cmdName]= false
	-- false/nil if all false, table if any true
	local anyTrue= cmds.CameraOrSelectOrMove
		or cmds.TurnLeft or cmds.TurnRight
		or cmds.PitchUp  or cmds.PitchDown
	CombatMode.CommandsReleasing= anyTrue  and  CommandsReleasingMouse
	
	--if  CombatMode.CommandsReleasing  then  return  end
	CombatMode:UpdateState(true, cmdName ..'Stop')
end




local lastMouselook
local function  MouselookChange()
	if  lastMouselook == IsMouselooking()  then  return ''  end
	lastMouselook= IsMouselooking()
  return  'Mouselook  ' .. boolstr(IsMouselooking())
end

--[[
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




function  CombatMode:HookCommands()
	--print('HookCommands()')
	if  self.HookCommandsDone  then  return false  end
	
	--[[
	for  funcName, hookFunc  in  pairs(CommandHooks)  do
		print('HookCommands(): ' .. funcName)
		hooksecurefunc(funcName, hookFunc)
	end
	--]]
	for  idx,cmdName  in  ipairs(CommandsLockingMouse)  do
		hooksecurefunc(cmdName ..'Start', function ()  CommandLockStartHook(cmdName)  end)
		hooksecurefunc(cmdName ..'Stop', function ()  CommandLockStopHook(cmdName)  end)
	end
	for  idx,cmdName  in  ipairs(CommandsReleasingMouse)  do
		hooksecurefunc(cmdName ..'Start', function ()  CommandReleaseStartHook(cmdName)  end)
		hooksecurefunc(cmdName ..'Stop', function ()  CommandReleaseStopHook(cmdName)  end)
	end
	-- drop entries: not used until /reload, secure hooking is non-reversible
	CommandsLockingMouse= {}
	CommandsReleasingMouse= {}
	
	self.HookCommandsDone= true
	return true
end



