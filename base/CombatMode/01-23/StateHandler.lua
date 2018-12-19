-- Methods for event handling, state update of CombatMode, Mouselook, SmartTargeting

--[[ Analyzing key press state:
-- commands can get stuck in pressed state if the binding is changed and the "up" event goes to a different command
/dump CombatMode.commandsLockingMouse
/dump CombatMode.commandsReleasingMouse
-- Cause of CombatMode:
/dump CombatMode.db.profile.enableWhileMoving
/dump CombatMode:EnableWhileMoving()
/dump CombatMode:ExpectedMouselook()
-- Overridden bindings:
/dump CombatMode.MouselookOverrideBindings= {}
/dump CombatMode.MoveAndSteerKeys= {}
-- Settings:
/dump CombatMode.db.profile
/dump CombatModeDB
-- Explicit:
/run MouselookStart()
/run MouselookStop()
-- logging:
/run CombatMode.logging= false
/run CombatMode.loggingAnomaly= false
/run CombatMode.loggingState= false
0/run CombatMode.loggingUpdate= false
-- set to true or false  to override individual event settings
/run CombatMode.loggingEvent.all= false
-- individual events
/run CombatMode.loggingEvent.CURSOR_UPDATE= false
/run CombatMode.loggingEvent.PLAYER_TARGET_CHANGED= false
/run CombatMode.loggingEvent.PET_BAR_UPDATE= false
/run CombatMode.loggingEvent.ACTIONBAR_UPDATE_STATE= false
/run CombatMode.loggingEvent.QUEST_PROGRESS= false
/run CombatMode.loggingEvent.QUEST_FINISHED= false
--]]
CombatMode.logging= true
CombatMode.loggingAnomaly= true
CombatMode.loggingState= true
CombatMode.loggingUpdate= true
CombatMode.loggingInit= true
CombatMode.loggingFrame= true
CombatMode.loggingEvent= {
	all= nil,		-- set to true or false to override individual event settings
	CURSOR_UPDATE= false,
	PLAYER_TARGET_CHANGED= true,
	PET_BAR_UPDATE= true,
	ACTIONBAR_UPDATE_STATE= false,
	QUEST_PROGRESS= true,
	QUEST_FINISHED= true,
}

--[[ Change colors used in logging
/run CombatMode.colors['nil']= CombatMode.colors.blue
/run CombatMode.colors[false]= CombatMode.colors.blue
/run CombatMode.colors[true]= CombatMode.colors.green
/run CombatMode.colors.CombatModeEnabled = CombatMode.colors.purple
/run CombatMode.colors.CombatModeHold = CombatMode.colors.orange
--]]
local colors= {
		black= "|cFF000000",
		white= "|cFFffffff",
		gray= "|cFFbeb9b5",
		blue= "|cFF00b4ff",
		lightblue= "|cFF96c0ff",
		purple= "|cFFcc00ff",
		green= "|cFF00ff00",
		green2= "|cFF66ff00",
		lightgreen= "|cFF98fb98",
		darkred= "|cFFc25b56",
		red= "|cFFff0000",
		orange= "|cFFff9900",
		yellow= "|cFFffff00",
		parent= "|cFFbeb9b5",
		error= "|cFFff0000",
		ok= "|cFF00ff00",
		restore= "|r",
}
CombatMode.colors= colors
colors['nil']= colors.blue
colors[false]= colors.blue
colors[true]= colors.green
colors.CombatModeEnabled= colors.purple
colors.CombatModeHold= colors.orange
colors.Mouselook= colors.yellow
colors.CursorActionActive= colors.yellow


local function  colorBoolStr(value, withColor)
	local bool = value == true  and  'ON'  or  value == false and 'OFF'  or  tostring(value)
	if  withColor == true  then  withColor=  colors[value == nil  and  'nil'  or  value]  end
	return  withColor  and  withColor .. bool .. colors.restore  or  bool
end

function CombatMode:IsLoggingEvent(event)
	if  self.logging  and  self.loggingEvent  then
		if  self.loggingEvent.all ~= nil  then  return  self.loggingEvent.all  end
		return  self.loggingEvent[event]
	end
end


function CombatMode:LogState(...)
	if  self.logging  and  self.loggingState  then  print(...)  end
end

function CombatMode:LogUpdate(...)
	if  self.logging  and  self.loggingUpdate  then  print(...)  end
end

function CombatMode:LogAnomaly(...)
	if  self.logging  and  self.loggingAnomaly  then  print(...)  end
end

function CombatMode:LogEvent(event, extraMsg)
	if  self:IsLoggingEvent(event)  then
		print(event ..':  cursor='.. (GetCursorInfo() or 'hand')
		..' CursorHasItem='.. colorBoolStr(CursorHasItem(),true)
		..' SpellIsTargeting='.. colorBoolStr(SpellIsTargeting(),true)
		..' CursorActionActive='.. colorBoolStr(self.CursorActionActive,true)
		.. (extraMsg or '') )
	end
end




function CombatMode:SetEnabled(enabled)
	-- ignore request to enable when frames or cursor action is disabling combat mode
	if  enabled  and  self:CheckForDisableState()  then  return  end
	
	-- self.CombatModeEnabled  may become out of sync with IsMouselooking() as a result of a few corner cases:
	-- use the actual state as the user expects the new state to be opposite of what he sees
	if  self.CombatModeEnabled == enabled  then
		self.LogAnomaly('  CombatMode already in the requested state  '.. colorBoolStr(self.CombatModeEnabled, colors.red) ..'  - reseting buttons to unstuck')
		self:ResetState()
	end
	
	--self.CombatModeEnabled = not self.CombatModeEnabled
	self.CombatModeEnabled = enabled
end



function CombatMode:ToggleKey()
	local  enabled= not IsMouselooking()
	--local  enabled= not self.CombatModeEnabled
	if  self.CombatModeHold  then
		print('  CombatMode:ToggleKey():  '.. colors.CombatModeHold ..'CombatModeHold|r='.. colorBoolStr(nil, true) ..' reset after being STUCK at '.. colorBoolStr(self.CombatModeHold, true))
		self.CombatModeHold= nil
	end
	self:SetEnabled(enabled)
	self:LogState('  CM:ToggleKey():  '.. colors.CombatModeEnabled ..'CombatModeEnabled|r='.. colorBoolStr(self.CombatModeEnabled, true))
	self:UpdateMouselook(enabled, 'ToggleKey')
end	


function CombatMode:HoldKey(keystate)
	if  keystate == 'down'  and  self.CombatModeHold ~= nil  then
		--[[ Key was pressed but not released, possibly stuck: 'up' event was not received for the command.
		Happens if command is bound to a mouse button and  MouselookStop()  is called after the 'down' event.
		Works as expected if bound to a keyboard key.
		This seems to be a bug in the client, workaround could be to handle the mouse click directly.
		Resolution: do the missed action of the 'up' event, disable CombatModeHold
		--]]
		print('  CombatMode:HoldKey():  PRESSED, but not released, CombatModeHold='.. colorBoolStr(self.CombatModeHold))
		keystate= 'missed-up'
	end
	
	if  keystate == 'down'  then
		self.CombatModeHold= not IsMouselooking()
		--self.CombatModeHold= not self.CombatModeEnabled
		--combatModeTemporaryDisable = true
	else
		self.CombatModeHold= nil
		--combatModeTemporaryDisable = false
	end
	self:LogState('  CM:HoldKey('.. colors.lightgreen .. keystate:upper() ..'|r):  '.. colors.CombatModeHold ..'CombatModeHold|r='.. colorBoolStr(self.CombatModeHold, true))
	self:UpdateMouselook(self.CombatModeHold, 'HoldKey')
end


function CombatMode:EnableKey(keystate)
	local pressedFor= self.enableKeyPressTime  and  GetTime() - self.enableKeyPressTime
	local prefix= '  CM:EnableKey('.. colors.lightgreen .. keystate:upper() ..'|r):'
	local suffix= '  pressedFor='.. tostring(pressedFor)
	local possibleState
	
	if  keystate == 'down'  and  self.enableKeyPressTime  then
		-- Key was pressed but not released, possibly stuck: 'up' event was not received for the command. See reason at HoldKey()
		-- Resolution: do the 'up' event now, before handling the next press ('down' event)
		self:LogAnomaly('  CM:EnableKey() pressed, but not released, CombatModeHold='.. colorBoolStr(self.CombatModeHold))
		self:EnableKey('missed-up')
	end
	
	if  keystate == 'down'  then
		-- Key pressed: Invert the state temporarily while button is pressed
		self.enableKeyPressTime= GetTime()
		--self.CombatModeHold= not self.CombatModeEnabled
		--self.CombatModeHold= not IsMouselooking()		-- invert the actual, effective state:
		-- self.CombatModeEnabled might be out-of-sync if other source modified IsMouselooking()
		self.CombatModeHold=  not IsMouselooking()  and  true  or  nil	-- enable or unstuck CombatModeHold
		possibleState= self.CombatModeHold
		
		local middle= '  '.. colors.CombatModeHold ..'CombatModeHold|r='.. colorBoolStr(self.CombatModeHold, true)
		self:LogState(prefix .. middle .. suffix)
		self:UpdateMouselook(possibleState, 'EnableKeyDOWN')
		
	elseif  not self.enableKeyPressTime  then
		--[[
		To avoid unexpected behaviour the release event is ignored if there was no press event.
		This happens when the key was rebound after being pressed.
		The original binding should handle the release event too, but wow does not work that way.
		Doing nothing in this case is better than doing the unexpected.
		--]]
		--self:LogAnomaly('  CM:EnableKey():  released without being pressed, CombatModeHold='.. colorBoolStr(self.CombatModeHold))
		self:LogState(prefix .. 'released without being pressed, IGNOREing, CombatModeHold='.. colorBoolStr(self.CombatModeHold))
		self:UpdateMouselook(possibleState, 'EnableKeyIGNORE')
		
	else
		-- Key released: restore state before pressed
		local expState= self:ExpectedMouselook()
		local newCombatMode= self.CombatModeHold  or  false
		possibleState= not self.CombatModeHold
		self.enableKeyPressTime= nil
		self.CombatModeHold= nil		-- changes self:ExpectedMouselook()
		local middle= '  '.. colors.CombatModeHold ..'CombatModeHold|r='.. colorBoolStr(self.CombatModeHold, true)
		--self:UpdateMouselook(possibleState, 'EnableKey-')		-- needed only for  self:SetEnabled(IsMouselooking())  to ensure IsMouselooking() is what's expected
		
		if  0.01 < pressedFor  and  pressedFor < 0.3  then		-- GetTime() returns seconds (with 3 decimals, millisecond precision)
			-- if clicked (pressed for < 0.3 sec) then invert/toggle the state permanently
			
			if  newCombatMode ~= expState  then
				self:LogAnomaly('  CM:EnableKey():  new CombatModeEnabled ~= expState='.. colorBoolStr(expState, true) ..' - some state-altering button was pressed?')
			end
			
			--self:SetEnabled(not self.CombatModeEnabled)
			-- the opposite of the know state which can be different from the state visible to the user
			
			--self:SetEnabled(IsMouselooking())
			-- the current state which is likely the inversed state when the button was pressed,
			-- but any transient bug or state change after the down event can change it
			
			self:SetEnabled(newCombatMode)		-- the state when the button was pressed, inversed
			possibleState= self.CombatModeEnabled		-- SetEnabled() updated it, and checked for visible frames
			middle= middle ..'  '.. colors.CombatModeEnabled ..'CombatModeEnabled|r='.. colorBoolStr(self.CombatModeEnabled, true)
		else
			-- if hold (pressed for longer) then restore state before pressed
		end
		
		self:LogState(prefix .. middle .. suffix)
		self:UpdateMouselook(possibleState, 'EnableKeyUP')
		
	end
	
end




function CombatMode_OnUpdate(self, elapsed)
	if SmartTargetingEnabled then
		-- TODO: deprecate periodic update (every 20ms), use trick instead:
		-- after SmartTarget down event check distance in hook, override binding to InteractTarget
		-- "up" event will execute Interact command
		CombatMode:UpdateSmartTarget()
	end
	--[[
	if self.CombatModeEnabled then
		CombatMode:UpdateMouselook()
	end
	--]]
end



local  lastUpdateCursorBusy= false
function CombatMode:CursorAction(newState, event)
	if  self.CursorActionActive == newState  then  return  end
	self.CursorActionActive= newState
	
	-- this happens anytime the mouse moves over objects, or away from objects
	-- only checking if there is a frame (irrelevant) or spell or item on the cursor
	-- it is not an indicator of a busy cursor that should not be hidden
	self:LogState('  '.. event ..':  -> '.. colors.CursorActionActive .. 'CursorActionActive|r=' .. colorBoolStr(newState, false))
end

function CombatMode_OnEvent(event, ...)
	local self= CombatMode
	if  event == "PLAYER_TARGET_CHANGED"  and  SmartTargetingEnabled  then
		if  IsInCombat()  then
			self:LogState("PLAYER_TARGET_CHANGED ignored: Can't update bindings when IsInCombat()=true")
			return
		else
			self:LogEvent(event)
			self:UpdateSmartTarget()
		end
	
	elseif  event == "CURSOR_UPDATE"  then
		--[[ CURSOR_UPDATE sent when
		1. cursor is shown (as hand) after being hidden for CameraOrSelectOrMove, TurnOrAction, MoveAndSteer, Mouselook
		2. cursor changes over actionable object:  bubble (gossip) / sword (enemy) / dragon (flightmaster) / mail (mailbox) / satchel (vendor,bank,auction) / hearthstone (innkeeper) / what else?
		----event is not sent twice when moving over an actionable object:  hidden -> show hand cursor -> action cursor
		event is NOT sent when hiding cursor
		--]]
		self:LogEvent(event)
		local  CursorBusy = CursorHasItem()  or  SpellIsTargeting()
		----[[
		if  not CursorBusy  then  self:CursorAction(true, event)  end
		-- this happens anytime the mouse moves over objects, or away from objects
		-- only checking if there is a frame (irrelevant) or spell or item on the cursor
		-- it is not an indicator of a busy cursor that should not be hidden
		--]]
		
		if  lastUpdateCursorBusy ~= CursorBusy  then
			self:UpdateMouselook(not CursorBusy, 'CURSOR_UPDATE')
			lastUpdateCursorBusy = CursorBusy
		end
	
	elseif  event == "PET_BAR_UPDATE"  and  self.CursorActionActive  then
		self:LogEvent(event, '  -> ResetCursor(), CursorActionActive=false')
		self:CursorAction(false, event)
		ResetCursor()
		-- triggers CURSOR_UPDATE, that will do self:UpdateMouselook(false, event)

	elseif  event == "ACTIONBAR_UPDATE_STATE"  and  self.CursorActionActive  then
		self:LogEvent(event, '  -> ResetCursor(), CursorActionActive=false')
		self:CursorAction(false, event)
		ResetCursor()
		-- triggers CURSOR_UPDATE, that will do self:UpdateMouselook(false, event)

	elseif  event == "QUEST_PROGRESS"  and  not self.CursorActionActive  then
		self:LogEvent(event, '  -> CursorActionActive=true')
		self.FramesOnScreen:setInsert('QUEST_PROGRESS')
		self:CursorAction(false, event)
		self:UpdateMouselook(false, event)
	
	elseif  event == "QUEST_FINISHED"  and  self.CursorActionActive  then
		self:LogEvent(event, '  -> CursorActionActive=false')
		self.FramesOnScreen:removeValue('QUEST_PROGRESS')
		self:CursorAction(false, event)
		self:UpdateMouselook(true, event)
		
	else
		self:LogEvent(event)
	end
	
end


--[[
function  CombatMode:CURSOR_UPDATE()
	CombatMode:LogEvent('CURSOR_UPDATE(2)')
	local  CursorBusy= CursorHasItem()  or  SpellIsTargeting()  or  self.CursorActionActive
	if  lastUpdateCursorBusy ~= CursorBusy  then
		CombatMode:UpdateMouselook(not CursorBusy, 'CURSOR_UPDATE')
		lastUpdateCursorBusy= CursorBusy
	end
end
--]]




function  CombatMode:ResetState()
	CombatMode.AnyCommandsLocking= false
	CombatMode.AnyCommandsLockingWithFrame= false
	local cmds= CombatMode.commandsLockingMouse
	if  not self.CombatModeEnabled  and  cmds  then
		-- a command might be stuck in pressed state, reset state to free mouse
		for  cmd,pressed  in  pairs(cmds)  do  if  pressed  then
			CombatMode:LogState('  '.. cmd ..' was PRESSED, is reset now')
			cmds[cmd]= nil
		end end
	end
	cmds= CombatMode.commandsReleasingMouse
	if  not self.CombatModeEnabled  and  cmds  then
		-- a command might be stuck in pressed state, reset state
		for  cmd,pressed  in  pairs(cmds)  do  if  pressed  then
			CombatMode:LogState('  '.. cmd ..' was PRESSED, is reset now')
			cmds[cmd]= nil
		end end
	end
end



function  CombatMode:UpdateMouselook(possibleTransition, event)
	event= event  or  'nil'
	local currentState= IsMouselooking()
	
	-- Report modified IsMouselooking() to catch commands changing it. Like  MoveAndSteerStart  and  TurnOrActionStart
	if  self.lastMouselook ~= currentState  and  currentState ~= self.CommandsChangingMouselook[event]  then
		CombatMode:LogAnomaly('  '.. colors.red .. event .. '|r changed Mouselook: '.. colorBoolStr(self.lastMouselook, true) ..'->'.. colorBoolStr(currentState, true) )
	end
	
	local expState, reason= self:ExpectedMouselook()
	if  possibleTransition ~= nil  and  expState ~= possibleTransition  and  expState ~= currentState  then
		CombatMode:LogAnomaly('  CM:Update('.. event:sub(1,16) ..'):  '.. colors.yellow .. reason ..'|r->'.. colorBoolStr(expState, colors.red)  ..' is not possibleTransition='.. colorBoolStr(possibleTransition))
	end
	
	-- Report every update, reason and result for debugging
	local stateColor= expState ~= currentState
	-- state in red if the command changed it
	if  self.lastMouselook ~= currentState  then  stateColor= colors.red  end
	local stateStr= colorBoolStr(expState, stateColor)
	local prefix= 'CM:Update('.. colorBoolStr(possibleTransition) ..','.. colors.lightgreen .. event:sub(1,16) ..'|r):  '
	local suffix= colors.lightblue .. reason ..'|r->'.. stateStr .. '|n------'
	
	-- No change?
	self.lastMouselook= currentState
	if  expState == currentState  then
		self:LogUpdate(prefix .. suffix)
		return
	end
	
	----[[
	-- Mouselook == true  hides the cursor
	if  expState  then  self:CursorAction(false, 'CM:Update()')  end
	--]]
	
	-- Commit the change
	self.lastMouselook= expState
	--self.lastMouselookSet= expState
	--local suffix= colors.Mouselook .. 'Mouselook|r=' suffix
	self:LogState(prefix .. suffix)
	if  expState  then  MouselookStart()  else  MouselookStop()  end
end

CombatMode.lastMouselook= false
--CombatMode.lastMouselookSet= false
CombatMode.CommandsChangingMouselook= {
	TurnOrActionStart= true,
	TurnOrActionStop= false,
	MoveAndSteerStart= true,
	MoveAndSteerStop= false,
	-- TargetScanEnemy:
	TargetPriorityHighlightStart= true,
	TargetPriorityHighlightEnd= false,
}



function CombatMode:CheckForFrameOnScreen()
	return  0 < #CombatMode.FramesOnScreen
end

function CombatMode:CheckForDisableState()
	return  self:CheckForFrameOnScreen()  or  CursorHasItem()  or  SpellIsTargeting()--  or  self.CursorActionActive
end


function CombatMode:ExpectedMouselook()
	-- Turn,Pitch  is first in priority: even in combat mode, Turn/Pitch adjustments are possible.
	-- With Mouselook Turn,Pitch acts as Stafe,Move, therefore it is disabled for these commands
	-- Turn,Pitch(release) vs. TurnOrAction(lock)?  -> priority: Turn,Pitch(release)
	if  self.AnyCommandsReleasing  then  return false, 'Turn,Pitch'  end
	
	-- TurnOrAction,MoveAndSteer ignores FramesOnScreen,CursorAction
	-- Maybe it should be all Move,Strafe when bound to mouse button: this requires extra logic to detect
	-- TurnOrAction(lock) vs. CombatModeHold,FramesOnScreen,CursorAction(release)?  -> priority: TurnOrAction(lock)
	if  self.AnyCommandsLockingWithFrame  then  return true, 'TurnOrAction,MoveAndSteer'  end
	
	-- CombatMode EnableKey/HoldKey vs. FramesOnScreen?  -> priority: EnableKey/HoldKey
	if  self.CombatModeHold ~= nil  then  return  self.CombatModeHold, 'CombatModeHold'  end
	
	-- FramesOnScreen,CursorAction(release) vs. Move,Strafe(lock)?  -> priority: CursorAction(release)
	-- consistent with CombatMode:CheckForDisableState():
	if  self:CheckForFrameOnScreen()  then  return false, 'FrameOnScreen'  end
	if  CursorHasItem()  then  return false, 'CursorHasItem'  end
	if  SpellIsTargeting()  then  return false, 'SpellIsTargeting'  end
	--if  self.CursorActionActive  then  return false, 'CursorActionActive'  end
	
	-- Move,Strafe(lock) or CombatMode enabled
	if  self.AnyCommandsLocking  then  return true, 'Move,Strafe'  end
	if  self.CombatModeEnabled  then  return true, 'CombatModeEnabled'  end
	
	return  false, 'NoKeysPressed'
end




