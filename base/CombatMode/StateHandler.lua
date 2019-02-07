-- Methods for event handling, state update of CombatMode, Mouselook, SmartTargeting
local ADDON_NAME, _ADDON = ...

--[[ Analyzing key press state:
-- commands can get stuck in pressed state if the binding is changed and the "up" event goes to a different command
/dump CombatMode.enabledPermanent, CombatMode.holdKeyState
/dump CombatMode.commands.state, CombatMode.commands.groups
/run CombatMode:ResetState()
-- Cause of CombatMode:
/dump CombatMode.db.profile.enabledWhileMoving
/dump CombatMode.enabledWhileMoving
/dump CombatMode:IsEnabledWhileMoving()
/dump CombatMode:ExpectedMouselook()
/dump CombatMode.FramesOnScreen
-- Overridden bindings:

/dump CombatMode.MouselookOverrideBindings= {}
/dump CombatMode.MoveAndSteerKeys= {}

-- Settings:
/dump CombatMode.db.profile
/dump CombatModeDB
-- Explicit:
/run CombatMode:ResetState()
/run MouselookStart()
/run MouselookStop()
-- logging:
/dump 'Me:'..(UnitIsPVP('player') and 'PvP' or 'non-pvp'), UnitName('target')..':'..(UnitIsPVP('target') and 'PvP' or 'non-pvp')
/run CombatMode.logging.all= false
/run CombatMode.logging.Anomaly= false
/run CombatMode.logging.State= false
/run CombatMode.logging.Update= true
/run CombatMode.logging.Command= true
-- set to true or false  to override individual event settings
/run CombatMode.logging.Event.all= false
-- individual events
/run CombatMode.logging.Event.CURSOR_UPDATE= false
/run CombatMode.logging.Event.PLAYER_TARGET_CHANGED= false
/run CombatMode.logging.Event.PET_BAR_UPDATE= false
/run CombatMode.logging.Event.ACTIONBAR_UPDATE_STATE= false
/run CombatMode.logging.Event.QUEST_PROGRESS= false
/run CombatMode.logging.Event.QUEST_FINISHED= false
--]]
CombatMode.logging= {
	all= nil,		-- set to true or false to override individual settings
	--all= true,
	State= false,
	Update= false,
	Command= false,
	Anomaly= false,
--	Anomaly= true,
	Init= false,
	Frame= false,
}
CombatMode.logging.Event= {
	all= false,		-- set to true or false to override individual event settings
	--all= true,
	CURSOR_UPDATE= false,
	PLAYER_TARGET_CHANGED= true,
	PET_BAR_UPDATE= true,
	ACTIONBAR_UPDATE_STATE= false,
	QUEST_PROGRESS= true,
	QUEST_FINISHED= true,
}


local colorBoolStr = CombatMode.colorBoolStr
local colors = CombatMode.colors



local function makeLogFunc(logType)
	--return  function (self, ...)  if  self:IsLogging(logType)  then  print(...)  end  end
	return  function (self, ...)  self:Log(logType, ...)  end
end
CombatMode.LogState   = makeLogFunc('State')
CombatMode.LogUpdate  = makeLogFunc('Update')
CombatMode.LogCommand = makeLogFunc('Command')
CombatMode.LogAnomaly = makeLogFunc('Anomaly')
CombatMode.LogInit    = makeLogFunc('Init')
CombatMode.LogFrame   = makeLogFunc('Frame')
-- 1<->1 mapping:   :LogState(...)  <->  :Log('State',...)

function CombatMode:Log(logType, ...)  if  self:IsLogging(logType)  then  print(...)  end  end
function CombatMode:LogEvent(event, extraMessage)
	if  self:IsLoggingEvent(event)  then
		print(event ..':  cursor='.. (GetCursorInfo() or 'hand')
		..' CursorHasItem()='.. colorBoolStr(CursorHasItem(),true)
		..' SpellIsTargeting()='.. colorBoolStr(SpellIsTargeting(),true)
		..' CursorActionActive='.. colorBoolStr(self.CursorActionActive,true)
		.. (extraMessage or '') )
	end
end

function CombatMode:IsLogging(logType)
	if  self.logging  then
		if  self.logging.all ~= nil  then  return  self.logging.all  end
		return  self.logging[logType]
	end
end

function CombatMode:IsLoggingEvent(event)
	if  self.logging  and  self.logging.all ~= false  and  self.logging.Event  then
		if  self.logging.Event.all ~= nil  then  return  self.logging.Event.all  end
		return  self.logging.Event[event]
	end
end



function CombatMode:SetEnableState(enable)
	--[[
	-- To reset if some key state is stuck click ToggleKey / EnableKey while pressing HoldKey
	if  self.holdKeyState  then
		print('CombatMode:SetEnableState():  '.. colors.holdKeyState .. self.holdKeyState .. '|r stuck or pressed -> RESETing all keypress state')
		self.commands:SetState(self.holdKeyState, false)
		self.holdKeyState= nil
		self:ResetState()
	end
	--]]
	-- Ignore request to enable when frames or cursor action is disabling combat mode
	if  enable  and  self:CheckForDisableState()  then  return  end
	
	local stateStr
	if  0 == #self.commands.groups.MoveKeys  then
		-- if toggled while NOT moving then turn on/off enabledPermanent
    stateStr=  self.enabledPermanent and 'enabledPermanent'
    self:SetEnabledPermanent(enable)
	elseif  not enable  then
		-- if toggled OFF while MOVING then turn off both enabledWhileMoving and enabledPermanent
		stateStr=  self.enabledPermanent and self.enabledWhileMoving and 'enabledPermanent,enabledWhileMoving'
			or  self.enabledPermanent and 'enabledPermanent'  or  self.enabledWhileMoving and 'enabledWhileMoving'
		
		self:SetEnabledPermanent(enable)
		self:SetEnabledWhileMoving(enable)
	else
		-- if toggled ON while MOVING then turn on enabledWhileMoving
		stateStr=  self.enabledWhileMoving ~= enable  and  'enabledWhileMoving'
		self:SetEnabledWhileMoving(enable)
	end
	
	if  stateStr  then  self:LogState('  CM:SetEnableState():  '.. colors.enabledPermanent .. stateStr ..'|r='.. colorBoolStr(enable) ..'|r')  end
	--self:ScheduleUpdateBindingsState()
end



function CombatMode:ToggleKey()
	local inverseState= not IsMouselooking()
	--local enable= not self.enabledPermanent
	
	self:SetEnableState(inverseState)
	self:UpdateMouselook(inverseState, 'ToggleKey')
end	


--[=[ Use BUTTON2 = TurnOrAction
function CombatMode:HoldKey(keystate)
	local start= keystate == 'down'
	local possibleState= nil
	
	if  start  and  self.holdKeyState ~= nil  then
		--[[
		If HoldKey() is bound to a MOUSE button, it won't return to CombatMode. Cause: HoldKey('up') is not called.
		Happens after calling MouselookStop() from UpdateMouselook(). Exact reason unknown.
		--]]
		print('  CombatMode:HoldKey():  PRESSED, but not released, holdKeyState='.. self.holdKeyState)
		--self:HoldKey('missedup')
		return
	end
	
	if  start  then
		possibleState= not IsMouselooking()
		self.holdKeyState=  possibleState  and  'HoldToEnable'  or  'HoldToDisable'
	elseif  self.holdKeyState == nil  then
		print('  CombatMode:HoldKey():  RELEASED, but was not pressed, holdKeyState=nil')
		return
	end
	
	self.commands:SetState(self.holdKeyState, start)
	self:LogState('  CM:HoldKey('.. colors[keystate] .. keystate:upper() ..'|r):  '.. colors.holdKeyState .. tostring(self.holdKeyState) ..'|r='.. colorBoolStr(start, true))
	self:UpdateMouselook(possibleState, 'HoldKey')		-- self.holdKeyState) ??
	
	if  not start  then  self.holdKeyState= nil  end
end
--]=]

function CombatMode:EnableKey(keystate)
	local pressedFor= self.enableKeyPressTime  and  GetTime() - self.enableKeyPressTime
	local prefix= '  CM:EnableKey('.. colors[keystate] .. keystate:upper() ..'|r'
	if  pressedFor  then  prefix= prefix .. string.format(',%.2fs',pressedFor)  end
	prefix= prefix ..')'
	local possibleState
	
	if  keystate == 'down'  and  self.enableKeyPressTime  then
		-- Key was pressed but not released, possibly stuck: 'up' event was not received for the command. See reason at HoldKey()
		-- Resolution: do the 'up' event now, before handling the next press ('down' event)
		self:LogAnomaly('  CM:EnableKey()  PRESSED, but not released, holdKeyState='.. colors.holdKeyState .. tostring(self.holdKeyState) ..'|r')
		self:EnableKey('missedup')
	end
	
	if  keystate == 'down'  then
		-- Key pressed: Invert the state temporarily while button is pressed
		self.enableKeyPressTime= GetTime()
		
		-- Invert the current Mouselook state visible to the user.  enabledPermanent
		local enable= not IsMouselooking()
		possibleState= enable  or  nil
		
		if  self.holdKeyState  then
			self:LogAnomaly(':  '.. prefix ..'  stuck '.. colors.red ..'holdKeyState|r='.. colors.holdKeyState .. tostring(self.holdKeyState) ..'|r')
			self.commands:SetState(self.holdKeyState, false)
		end
		
		self.holdKeyState=  enable  and  'HoldToEnable'  or  nil	-- enable or reset holdKeyState
		local suffix= ''
		if  self.holdKeyState  then
			suffix= ':  '.. colors.holdKeyState .. self.holdKeyState ..'|r='.. colorBoolStr(true, true)
			self.commands:SetState(self.holdKeyState, true)
		end
		
		self:LogState(prefix .. suffix)
		self:UpdateMouselook(possibleState, 'EnableKey DOWN')
		
	elseif  not self.enableKeyPressTime  then
		--[[
		To avoid unexpected behaviour the release event is ignored if there was no press event.
		This might happen when the key was rebound after being pressed.
		--]]
		--self:LogAnomaly('  CM:EnableKey():  released without being pressed, holdKeyState='.. colors.holdKeyState .. tostring(self.holdKeyState) ..'|r')
		self:LogState(prefix .. '  released without being pressed, IGNOREing, holdKeyState='.. colors.holdKeyState .. tostring(self.holdKeyState) ..'|r')
		self:UpdateMouselook(possibleState, 'EnableKey IGNORE')
		
	else
		-- Key released: restore state before pressed
		--local expState= self:ExpectedMouselook()
		local newEnableState= self.commands.state.HoldToEnable or false
		possibleState= not newEnableState
		
		local suffix= ''
		if  self.holdKeyState  then
			suffix= ':  '.. colors.holdKeyState .. self.holdKeyState ..'|r='.. colorBoolStr(false, true)
			self.commands:SetState(self.holdKeyState, false)
			self.holdKeyState= nil
		end
		
		if  0.01 < pressedFor  and  pressedFor < 0.3  then		-- GetTime() returns seconds (with 3 decimals, millisecond precision)
			-- if clicked (pressed for < 0.3 sec) then invert/toggle the state permanently
			self:SetEnableState(newEnableState)		-- the state when the button was pressed, inversed
			possibleState= self.enabledPermanent		-- SetEnableState() updated it, and checked for visible frames
		else
			-- if hold (pressed for longer) then restore state before pressed
		end
		
		self.enableKeyPressTime= nil
		self:LogState(prefix .. suffix)
		self:UpdateMouselook(possibleState, 'EnableKey UP')
		
	end
	
end


function CombatMode:MODIFIER_STATE_CHANGED(event)
	self:UpdateMouselook(nil, 'Modifier')
end




CombatMode.lastUpdateCursorAction= false

function CombatMode:CURSOR_UPDATE(event, ...)
	--[[ CURSOR_UPDATE sent when
	1. cursor is shown (as hand) after being hidden for CameraOrSelectOrMove, TurnOrAction, MoveAndSteer, Mouselook
	2. cursor changes over actionable object:  bubble (gossip) / sword (enemy) / dragon (flightmaster) / mail (mailbox) / satchel (vendor,bank,auction) / hearthstone (innkeeper) / what else?
	----event is not sent twice when moving over an actionable object:  hidden -> show hand cursor -> action cursor
	event is NOT sent when hiding cursor
	--]]
	local cursorAction =  CursorHasItem()  or  SpellIsTargeting()
	self:LogEvent(event, '  -> cursorAction=' .. colorBoolStr(cursorAction, false))
	--if  cursorAction  then  self:CursorAction(cursorAction, event)  end
	self:CursorAction(cursorAction, event)
	--[[
	-- this happens anytime the mouse moves over objects, or away from objects
	-- only checking if there is a frame (irrelevant) or spell or item on the cursor
	-- it is not an indicator of a busy cursor that should not be hidden
	--]]
	
	if  self.lastUpdateCursorAction ~= cursorAction  then
		self:UpdateMouselook(not cursorAction, 'CURSOR_UPDATE')
		self.lastUpdateCursorAction = cursorAction
	end
end

--[[
-- ranged spell targeting starts/ends
function CombatMode:CURRENT_SPELL_CAST_CHANGED()
	-- start:
	--CURSOR_UPDATE
	--CURRENT_SPELL_CAST_CHANGED
	--CURSOR_UPDATE
	--ACTIONBAR_UPDATE_STATE
	-- + CURSOR_UPDATE
	-- + CURSOR_UPDATE
	
	-- end:
	--UNIT_SPELL_CAST_FAILED_QUIET
	--UNIT_SPELL_CAST_FAILED_QUIET
	--CURSOR_UPDATE
	--CURRENT_SPELL_CAST_CHANGED
	--ACTIONBAR_UPDATE_STATE
	
	-- additional:
	--PLAYER_STARTED_MOVING
	--PLAYER_STOPPED_MOVING
	--MODIFIER_STATE_CHANGED
end
--]]

--[[ No need for these to my best knowledge. CURSOR_UPDATE handles it.
function CombatMode:PET_BAR_UPDATE(event)
	if  self.CursorActionActive  then
		local cursorAction =  CursorHasItem()  or  SpellIsTargeting()
		self:LogEvent(event, '  -> ResetCursor(), cursorAction=' .. colorBoolStr(cursorAction, false))
		self:CursorAction(cursorAction, event)
		ResetCursor()
		-- triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end

function CombatMode:ACTIONBAR_UPDATE_STATE(event)
	if  self.CursorActionActive  then
		local cursorAction =  CursorHasItem()  or  SpellIsTargeting()
		self:LogEvent(event, '  -> ResetCursor(), cursorAction=' .. colorBoolStr(cursorAction, false))
		self:CursorAction(cursorAction, event)
		ResetCursor()
		-- triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end
--]]

function CombatMode:QUEST_PROGRESS(event)
	-- Event QUEST_PROGRESS received as the quest frame is shown when talking to an npc
	local cursorAction =  CursorHasItem()  or  SpellIsTargeting()
	self:LogEvent(colors.show .. event .. colors.restore)
	self.FramesOnScreen:setInsertLast('QUEST_PROGRESS')
	self:CursorAction(cursorAction, event)
	self:UpdateMouselook(false, event)
end

function CombatMode:QUEST_FINISHED(event)
	-- Event QUEST_FINISHED received as the quest frame is closed after talking to an npc
	local cursorAction =  CursorHasItem()  or  SpellIsTargeting()
	self:LogEvent(colors.hide .. event .. colors.restore)
	self.FramesOnScreen:removeFirst('QUEST_PROGRESS')
	self:CursorAction(cursorAction, event)
	self:UpdateMouselook(not cursorAction, event)
end




--[[
function  CombatMode:CURSOR_UPDATE()
	self:LogEvent('CURSOR_UPDATE(2)')
	local  cursorBusy= CursorHasItem()  or  SpellIsTargeting()  or  self.CursorActionActive
	if  self.lastUpdateCursorAction ~= cursorBusy  then
		self:UpdateMouselook(not cursorBusy, 'CURSOR_UPDATE')
		self.lastUpdateCursorAction= cursorBusy
	end
end
--]]


function CombatMode:CursorAction(newState, event)
	if  self.CursorActionActive == newState  then  return  end
	self.CursorActionActive= newState
	
	-- this happens anytime the mouse moves over objects, or away from objects
	-- only checking if there is a frame (irrelevant) or spell or item on the cursor
	-- it is not an indicator of a busy cursor that should not be hidden
	self:LogState('  '.. event ..':  -> '.. colors.CursorActionActive .. 'CursorActionActive|r=' .. colorBoolStr(newState, false))
end


function  CombatMode:ResetState()
	CombatMode:LogState(colors.red .. 'RESETing|r keypress state')
	
	-- A command might be stuck in pressed state, reset state to free mouse
	local cmds= self.commands.state
	for  cmdName,pressed  in  pairs(cmds)  do  if  pressed == true  then
		CombatMode:LogState('  '.. colors.red .. cmdName ..'|r was PRESSED, is reset now')
		cmds[cmdName]= nil
	end end
	
	-- Reset group counters
	local groups= self.commands.groups
	for  groupName,group  in  pairs(groups)  do  if  0 ~= #group  then
		CombatMode:LogState('  Group "'.. colors.yellow .. groupName ..'"|r had '.. table.concat(group) ..' keys pressed, is reset now')
		groups[groupName]= {}
	end end
end




function  CombatMode:UpdateMouselook(possibleTransition, event)
	event= event  or  'nil'
	local currentState= not not IsMouselooking()
	local outsideChange= self.lastMouselook ~= currentState
	
	-- Report modified IsMouselooking() to catch commands changing it. Like  MoveAndSteerStart  and  TurnOrActionStart
	if  outsideChange  and  currentState ~= self.commands.changingMouselook[event]  then
		CombatMode:LogAnomaly('  '.. colors.red .. event .. '|r changed Mouselook: '.. colorBoolStr(self.lastMouselook, true) ..'->'.. colorBoolStr(currentState, true) )
	end
	
	local expState, reason= self:ExpectedMouselook()
	if  possibleTransition ~= nil  and  expState ~= possibleTransition  and  expState ~= currentState  and  not outsideChange  then
		CombatMode:LogAnomaly('  CM:Update('.. event:sub(1,16) ..'):  '.. colors.yellow .. reason ..'|r->'.. colorBoolStr(expState, colors.red)  ..' is not possibleTransition='.. colorBoolStr(possibleTransition))
	end
	
	-- MouselookStart() will hide cursor -> unflag CursorAction
	if  not currentState  and  expState  then  self:CursorAction(false, 'CM:Update()')  end
	
	-- Report every update, reason and result for debugging
	-- Show state in red if it was outsideChange (the command or other event changed it)
	local stateColor= (expState ~= currentState)  or  outsideChange and colors.red
	
	local stateStr= colorBoolStr(expState, stateColor)
	local prefix= 'CM:Update('.. colorBoolStr(possibleTransition) ..','.. colors.event .. event:sub(1,16) ..'|r):  '
	--local suffix= colors.lightblue .. reason ..'|r->'.. stateStr .. '|n------'
	local suffix= reason ..'->'.. stateStr			-- .. '|n------'
	
	if  (self.lastMouselook ~= expState)  or  outsideChange
  then  self:LogState(prefix .. suffix)
	else  self:LogUpdate(prefix .. suffix)
  end
	self.lastMouselook= expState
	
	-- Commit the change
	if  expState ~= currentState  then
    if  SpellIsTargeting()  then  return  end  -- otherwise spell targeting does nothing
		if  expState  then  MouselookStart()  else  MouselookStop()  end
		--self.lastMouselookSet= expState
	end
end

CombatMode.lastMouselook= not not IsMouselooking()
--CombatMode.lastMouselookSet= false



function CombatMode:CheckForFramesOnScreen()
	return  0 < #CombatMode.FramesOnScreen
end

function CombatMode:CheckForDisableState()
	return
		self:CheckForFramesOnScreen()	--	and  'FramesOnScreen'
		or  CursorHasItem()						--	and  'CursorHasItem'
		or  SpellIsTargeting()				--	and  'SpellIsTargeting'
		--  or  self.CursorActionActive
end


function CombatMode:ExpectedMouselook()
	local groups= self.commands.groups
	local state= self.commands.state
	
	--[[
	CameraOrSelectOrMove (LeftButton) + TurnOrAction (RightButton)  requires Mouselook ON to actually move the character.
	if  state.CameraOrSelectOrMove  and  state.TurnOrAction  then  return true, 'BothButtons'  end
	--]]
	
	--[[
	Turn,Pitch is first in priority:
	Requires Mouselook OFF to actually turn the character; with Mouselook ON it acts as Strafe,Move.
	--]]
	if  state.Turn  then  return false, 'Turn'  end
	if  state.Pitch  then  return false, 'Pitch'  end
	--if  0 < #groups.NeedCursor		then  return false, table.concat(groups.NeedCursor)  end		-- 'Turn, Pitch, Camera, HoldToDisable'  end
	
	-- Cursor actions also top priority:
	if  SpellIsTargeting()			then  return false, 'SpellIsTargeting'  end
	if  CursorHasItem()					then  return false, 'CursorHasItem'  end
	--if  self.CursorActionActive  then  return false, 'CursorActionActive'  end
	
	--[[
	TurnOrAction,MoveAndSteer,TargetScanEnemy,TargetNearestEnemy ignores FramesOnScreen,CursorAction
	Maybe it should be all Move,Strafe when bound to mouse button: this requires extra logic to detect
	--]]
	if  0 < #groups.Mouselook					then  return true, table.concat(groups.Mouselook)  end		-- 'MoveAndSteer, ScanEnemy, HoldToEnable'  end
	
	--[[
	CameraOrSelectOrMove (LeftButton) + Mouselook would move the character instead of rotating the camera,
	therefore Mouselook is disabled if TurnOrAction (RightButton) is not pressed
	--]]
	if  state.CameraOrSelectOrMove  then  return false, 'Camera'  end
	if  state.HoldToDisable  then  return false, 'HoldToDisable'  end
	-- if  state.TurnOrAction  then  return not self.enabledPermanent, 'TurnOrAction'  end
	local ena, dis = self:IsEnablePressed(), self:IsDisablePressed()
	if  ena and not dis  then  return true, 'EnablePressed'  end
	if  dis and not ena  then  return false, 'DisablePressed'  end
	
	-- FramesOnScreen higher priority than Move,Strafe
	if  self:CheckForFramesOnScreen()  then  return false, 'FramesOnScreen'  end
	
	-- Move,Strafe commands and enabledPermanent are the lowest priority
	if  self.enabledWhileMoving  then
		if  0 < #groups.MoveKeys					then  return true, table.concat(groups.MoveKeys)  end		-- 'Move,Strafe'  end
	end
	if  self.enabledPermanent				then  return true, 'enabledPermanent'  end
	
	-- By default Mouselook is OFF
	return  false, 'NoKeysPressed'
end



