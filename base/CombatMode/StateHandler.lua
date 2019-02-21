-- Methods for event handling, state update of CombatMode, Mouselook, SmartTargeting
local ADDON_NAME, _ADDON = ...

--[[ Analyzing key press state:
-- commands can get stuck in pressed state if the binding is changed and the "up" event goes to a different command
/dump CombatMode.db.profile.enabledOnLogin
/dump CombatMode.commands.state, CombatMode.commands.groups
/run CombatMode:ResetState()
-- Cause of CombatMode:
/dump CombatMode.db.profile.enabledWhileMoving
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
	-- Anomaly= false,
	Anomaly= true,
	Init= false,
	Frame= false,
}
CombatMode.logging.Event= {
	all= false,		-- set to true or false to override individual event settings
	--all= true,
	CURSOR_UPDATE= false,
	PLAYER_TARGET_CHANGED= true,
	-- PET_BAR_UPDATE= true,
	-- ACTIONBAR_UPDATE_STATE= false,
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
		..' CursorHasAny()='.. colorBoolStr(CursorHasAny(),true)
		..' SpellIsTargeting()='.. colorBoolStr(SpellIsTargeting(),true)
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





function CombatMode:ToggleKey()
	local inverseState= not IsMouselooking()
	-- local inverseState= not self:ExpectedMouselook()
	-- local inverseState= not self.enabledActionMode
	
	self:SetActionMode(inverseState)
	self:UpdateMouselook(inverseState, 'ToggleKey')
end	

function CombatMode:EnableKey()
	self:SetActionMode(true)
	self:UpdateMouselook(true, 'ToggleKey')
end	




local isModifierPressedFunc= {
	SHIFT = IsShiftKeyPressed,
	CTRL = IsCtrlKeyPressed,
	ALT = IsAltKeyPressed,
}

function CombatMode:MODIFIER_STATE_CHANGED(event)
	local modifiers = self.db.profile.modifiers
	local IsEnableModPressed  = isModifierPressedFunc[ modifiers.ActionModeEnableModifier ]
	local IsDisableModPressed = isModifierPressedFunc[ modifiers.ActionModeDisableModifier ]
	local state= self.commands.state
	self.EnableModPressed  = IsEnableModPressed  and IsEnableModPressed ()
	self.DisableModPressed = IsDisableModPressed and IsDisableModPressed()
	if self.EnableModPressed and self.DisableModPressed then
		-- Both pressed disables both.
		self.EnableModPressed,self.DisableModPressed  =  nil,nil
	end
	self:UpdateMouselook(nil, 'Modifier')
end




function CombatMode:CURSOR_UPDATE(event, ...)
	--[[ CURSOR_UPDATE sent when
	1. cursor is shown (as hand) after being hidden for CameraOrSelectOrMove, TurnOrAction, MoveAndSteer, Mouselook
	2. before UPDATE_MOUSEOVER_UNIT:  cursor changes over actionable object to  bubble (gossip) / sword (enemy) / dragon (flightmaster) / mail (mailbox) / satchel (vendor,bank,auction) / hearthstone (innkeeper) / what else?
	-- event is not sent twice when moving over an actionable object:  hidden -> show hand cursor -> action cursor
	-- event is NOT sent when hiding cursor
	3. after/before CURRENT_SPELL_CAST_CHANGED
	--]]
	local state= self.commands.state
	local lastState = state.CursorObjectOrSpellTargeting
	-- state.CursorHasItem = CursorHasItem()
	state.CursorHasAny = GetCursorInfo()
	-- state.CursorHasAny = CursorHasItem()  or  CursorHasMacro()  or  CursorHasMoney()  or  CursorHasSpell()
	state.SpellIsTargeting = SpellIsTargeting()
	state.CursorObjectOrSpellTargeting = state.CursorHasAny or state.SpellIsTargeting

	self:LogEvent(event, '  -> cursorAction=' .. colorBoolStr(state.CursorObjectOrSpellTargeting, false))
	if not lastState ~= not state.CursorObjectOrSpellTargeting then
		self:UpdateMouselook(not state.CursorObjectOrSpellTargeting, 'CURSOR_UPDATE')
	end
end


function CombatMode:QUEST_PROGRESS(event)
	-- Event QUEST_PROGRESS received as the quest frame is shown when talking to an npc
	self:LogEvent(colors.show .. event .. colors.restore)
	self.FramesOnScreen:setInsertLast('QUEST_PROGRESS')
	self:UpdateMouselook(false, event)
end

function CombatMode:QUEST_FINISHED(event)
	-- Event QUEST_FINISHED received as the quest frame is closed after talking to an npc
	self:LogEvent(colors.hide .. event .. colors.restore)
	self.FramesOnScreen:removeFirst('QUEST_PROGRESS')
	self:UpdateMouselook(true, event)
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
	if  self.commands.state.CursorObjectOrSpellTargeting  then
		self:LogEvent(event, '  -> ResetCursor()')
		ResetCursor()
		-- Triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end

function CombatMode:ACTIONBAR_UPDATE_STATE(event)
	if  self.commands.state.CursorObjectOrSpellTargeting  then
		self:LogEvent(event, '  -> ResetCursor()')
		ResetCursor()
		-- Triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end
--]]




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


function CombatMode:ExpectedMouselook()
	local groups= self.commands.groups
	local state= self.commands.state
	
	-- Turn,Pitch is first in priority:
	-- Requires Mouselook OFF to actually turn the character; with Mouselook ON it acts as Strafe,Move.
	if  state.Turn   then  return false, 'Turn'   end
	if  state.Pitch  then  return false, 'Pitch'  end
	--if  0 < #groups.NeedCursor		then  return false, table.concat(groups.NeedCursor)  end		-- 'Turn, Pitch, Camera'  end
	
	-- CameraOrSelectOrMove (LeftButton) + TurnOrAction (RightButton)  requires Mouselook ON to actually move the character.
	-- if  state.CameraOrSelectOrMove  and  state.TurnOrAction  then  return true, 'BothCameraAndTurn'  end

	-- TurnOrActionForcesState provides just this result with one exception:
	-- In ActionMode B2+B1=Cursor+Camera (order matters) inverts ActionMode to CursorMode, therefore the character won't move.
	-- B1:MoveAndSteer or B1+B2:MoveAndSteer (depending on ActionModeMoveWithButton1) is the binding for movement.
	

	-- TurnOrAction (RightButton) will _invert_ the Mouselook state active at the time it is pressed.
	-- Even if SpellIsTargeting or CursorHasAny it takes precedence.
	if  state.TurnOrAction  and  nil~=state.TurnOrActionForcesState  then  return state.TurnOrActionForcesState, 'TurnOrAction'  end

	-- CameraOrSelectOrMove (LeftButton) + Mouselook would move the character instead of rotating the camera,
	-- therefore Mouselook is disabled when CameraOrSelectOrMove (LeftButton) is pressed.
	-- Or Button1 becomes MoveAndSteer in ActionMode.
	if  state.CameraOrSelectOrMove  and  not self.db.profile.ActionModeMoveWithButton1  then  return false, 'Camera'  end
	
	-- MoveAndSteer,TargetScanEnemy,TargetNearestEnemy ignores FramesOnScreen, SpellIsTargeting and CursorHasAny.
	-- Maybe all Move,Strafe bound to mouse button should do so. In that case extra logic is needed to detect when Move is caused by a mouse button.
	if  0 < #groups.Mouselook  then  return true, "Mouselook:"..table.concat(groups.Mouselook)  end		-- 'MoveAndSteer, ScanEnemy, HoldToEnable'  end

	if  state.EnableModPressed   then  return true,  'EnableModPressed'   end
	if  state.DisableModPressed  then  return false, 'DisableModPressed'  end
	
	-- Any new event: SpellIsTargeting, CursorHasAny, new FramesOnScreen will delete enabledOverride.
	if  nil~=self.enabledOverride  then  return self.enabledOverride, 'enabledOverride'  end

	-- Cursor actions:
	if  state.SpellIsTargeting	then  return false, 'SpellIsTargeting'  end
	if  state.CursorHasAny			then  return false, 'CursorHasAny'     end
	--if  state.CursorObjectOrSpellTargeting  then  return false, 'CursorObjectOrSpellTargeting'  end
	
	-- FramesOnScreen are higher priority than  enabledWhileMoving:Move,Strafe.
	-- if  self:CheckForFramesOnScreen()  then  return false, 'FramesOnScreen'  end
	if  0 < #CombatMode.FramesOnScreen  then  return false, 'FramesOnScreen:'..(CombatMode.FramesOnScreen[1]:GetName() or "<noname>")  end
	
	-- Move,Strafe commands enable if enabledWhileMoving and no FramesOnScreen.
	if  self.db.profile.enabledWhileMoving  and  0 < #groups.MoveKeys  then
		return true, "enabledWhileMoving:"..table.concat(groups.MoveKeys)
	end

	-- Lowest priority:  enabledActionMode.. in this session, or  enabledOnLogin.. in a session before.
	if  nil~=self.enabledActionMode  then  return self.enabledActionMode, 'enabledActionMode'  end
	if  self.db.profile.enabledOnLogin  then  return true, 'enabledOnLogin'  end
	
	-- By default Mouselook is OFF
	return  false, 'NoKeysPressed'
end



