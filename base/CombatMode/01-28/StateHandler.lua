-- Methods for event handling, state update of CombatMode, Mouselook, SmartTargeting
local AddonName, Addon = ...

--[[ Analyzing key press state:
-- commands can get stuck in pressed state if the binding is changed and the "up" event goes to a different command
/dump CombatMode.enableAllways, CombatMode.holdKeyState
/dump CombatMode.commands.state, CombatMode.commands.groups
/run CombatMode:ResetState()
-- Cause of CombatMode:
/dump CombatMode.db.profile.enableWhileMoving
/dump CombatMode.enableWhileMoving
/dump CombatMode:EnableWhileMoving()
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
	State= true,
	Update= false,
	Command= false,
	Anomaly= true,
	Init= true,
	Frame= false,
}
CombatMode.logging.Event= {
	all= true,		-- set to true or false to override individual event settings
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
/run CombatMode.colors.holdKeyState = CombatMode.colors.purple
/run CombatMode.colors.enableAllways = CombatMode.colors.orange
--]]
local colors = {
		black			= "|cFF000000",
		white			= "|cFFffffff",
		gray			= "|cFFbeb9b5",
		blue			= "|cFF00b4ff",
		lightblue	= "|cFF96c0ff",
		purple		= "|cFFcc00ff",
		green			= "|cFF00ff00",
		green2		= "|cFF66ff00",
		lightgreen= "|cFF98fb98",
		darkred		= "|cFFc25b56",
		red				= "|cFFff0000",
		orange		= "|cFFff9900",
		yellow		= "|cFFffff00",
		parent		= "|cFFbeb9b5",
		error			= "|cFFff0000",
		ok				= "|cFF00ff00",
		restore		= "|r",
}
CombatMode.colors = colors
colors['nil']			= colors.lightblue
colors[false]			= colors.lightblue
colors[true]			= colors.green
colors.missedup		= colors.orange
colors.up					= colors.orange
colors.down				= colors.green		--colors.purple
colors.show				= colors.green
colors.hide				= colors.lightblue
colors.event			= colors.lightgreen
colors.holdKeyState			= colors.event
colors.enableAllways	= colors.orange
colors.Mouselook					= colors.yellow
colors.CursorActionActive	= colors.yellow


function Addon.colorBoolStr(value, withColor)
	local bool=  value == true and 'ON'  or  value == false and 'OFF'  or  tostring(value)
	if  withColor == true  then  withColor= colors[value == nil  and  'nil'  or  value]  end
	return  withColor  and  withColor .. bool .. colors.restore  or  bool
end
local colorBoolStr = Addon.colorBoolStr



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
		..' CursorHasItem='.. colorBoolStr(CursorHasItem(),true)
		..' SpellIsTargeting='.. colorBoolStr(SpellIsTargeting(),true)
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
	-- To reset if some key state is stuck click ToggleKey / EnableKey while pressing HoldKey
	if  self.holdKeyState  then
		print('CombatMode:SetEnableState():  '.. colors.holdKeyState .. self.holdKeyState .. '|r stuck or pressed -> RESETing all keypress state')
		self.commands:SetState(self.holdKeyState, false)
		self.holdKeyState= nil
		self:ResetState()
	end
	
	-- Ignore request to enable when frames or cursor action is disabling combat mode
	if  enable  and  self:CheckForDisableState()  then  return  end
	
	local stateStr
	if  0 == self.commands.groups.MoveKeys  then
		-- if toggled while NOT moving then turn on/off enableAllways
		stateStr=  self.enableAllways ~= enable  and  'enableAllways'
		self.enableAllways= enable
	elseif  not enable  then
		-- if toggled OFF while MOVING then turn off both enableWhileMoving and enableAllways
		stateStr=  self.enableAllways and self.enableWhileMoving and 'enableAllways,enableWhileMoving'
			or  self.enableAllways and 'enableAllways'  or  self.enableWhileMoving and 'enableWhileMoving'
		
		self.enableAllways= enable
		self:SetEnableWhileMoving(enable)
	else
		-- if toggled ON while MOVING then turn on enableWhileMoving
		stateStr=  self.enableWhileMoving ~= enable  and  'enableWhileMoving'
		self:SetEnableWhileMoving(enable)
	end
	
	if  stateStr  then  self:LogState('  CM:SetEnableState():  '.. colors.enableAllways .. stateStr ..'|r='.. colorBoolStr(enable) ..'|r')  end
	--self:ScheduleUpdateBindingsState()
end



function CombatMode:ToggleKey()
	local inverseState= not IsMouselooking()
	--local enable= not self.enableAllways
	
	self:SetEnableState(inverseState)
	self:UpdateMouselook(inverseState, 'ToggleKey')
end	


function CombatMode:HoldKey(keystate)
	local start= keystate == 'down'
	local possibleState= nil
	
	if  start  and  self.holdKeyState ~= nil  then
		--[[
		If HoldKey() is bound to a MOUSE button, it won't return to CombatMode. Cause: HoldKey('up') is not called.
		Happens after calling MouselookStop() from UpdateMouselook(). Exact reason unknown.
		--]]
		print('CombatMode:HoldKey():  PRESSED, but not released, holdKeyState='.. self.holdKeyState)
		--self:HoldKey('missedup')
		return
	end
	
	if  start  then
		possibleState= not IsMouselooking()
		self.holdKeyState=  possibleState  and  'HoldToEnable'  or  'HoldToDisable'
	elseif  self.holdKeyState == nil  then
		print('CombatMode:HoldKey():  RELEASED, but was not pressed, holdKeyState=nil')
		return
	end
	
	self.commands:SetState(self.holdKeyState, start)
	self:LogState('CM:HoldKey('.. colors[keystate] .. keystate:upper() ..'|r):  '.. colors.holdKeyState .. self.holdKeyState ..'|r='.. colorBoolStr(start, true))
	self:UpdateMouselook(possibleState, 'HoldKey')		-- self.holdKeyState) ??
	
	if  not start  then  self.holdKeyState= nil  end
end


function CombatMode:EnableKey(keystate)
	local pressedFor= self.enableKeyPressTime  and  GetTime() - self.enableKeyPressTime
	local prefix= 'CM:EnableKey('.. colors[keystate] .. keystate:upper() ..'|r'
	if  pressedFor  then  prefix= prefix .. string.format(',%.2fs',pressedFor)  end
	prefix= prefix ..')'
	local possibleState
	
	if  keystate == 'down'  and  self.enableKeyPressTime  then
		-- Key was pressed but not released, possibly stuck: 'up' event was not received for the command. See reason at HoldKey()
		-- Resolution: do the 'up' event now, before handling the next press ('down' event)
		self:LogAnomaly('  CM:EnableKey()  PRESSED, but not released, holdKeyState='.. tostring(colors.holdKeyState) .. self.holdKeyState ..'|r')
		self:EnableKey('missedup')
	end
	
	if  keystate == 'down'  then
		-- Key pressed: Invert the state temporarily while button is pressed
		self.enableKeyPressTime= GetTime()
		
		-- Invert the current Mouselook state visible to the user.  enableAllways
		local enable= not IsMouselooking()
		possibleState= enable  or  nil
		
		if  self.holdKeyState  then
			self:LogAnomaly(':  '.. prefix ..'  stuck '.. colors.red ..'holdKeyState|r='.. tostring(colors.holdKeyState) .. self.holdKeyState ..'|r')
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
		--self:LogAnomaly('  CM:EnableKey():  released without being pressed, holdKeyState='.. tostring(colors.holdKeyState) .. self.holdKeyState ..'|r')
		self:LogState(prefix .. '  released without being pressed, IGNOREing, holdKeyState='.. tostring(colors.holdKeyState) .. self.holdKeyState ..'|r')
		self:UpdateMouselook(possibleState, 'EnableKey IGNORE')
		
	else
		-- Key released: restore state before pressed
		--local expState= self:ExpectedMouselook()
		local newEnableState= self.commands.state.HoldToEnable or false
		possibleState= not self.commands.state.HoldToEnable
		
		local suffix= ''
		if  self.holdKeyState  then
			suffix= ':  '.. colors.holdKeyState .. self.holdKeyState ..'|r='.. colorBoolStr(false, true)
			self.commands:SetState(self.holdKeyState, false)
			self.holdKeyState= nil
		end
		
		if  0.01 < pressedFor  and  pressedFor < 0.3  then		-- GetTime() returns seconds (with 3 decimals, millisecond precision)
			-- if clicked (pressed for < 0.3 sec) then invert/toggle the state permanently
			self:SetEnableState(newEnableState)		-- the state when the button was pressed, inversed
			possibleState= self.enableAllways		-- SetEnableState() updated it, and checked for visible frames
		else
			-- if hold (pressed for longer) then restore state before pressed
		end
		
		self.enableKeyPressTime= nil
		self:LogState(prefix .. suffix)
		self:UpdateMouselook(possibleState, 'EnableKey UP')
		
	end
	
end




function CombatMode_OnUpdate(self, elapsed)
	if SmartTargetingEnabled then
		-- TODO: deprecate periodic update (every 20ms), use trick instead:
		-- after SmartTarget down event check distance in hook, override binding to InteractTarget
		-- "up" event will execute Interact command
		CombatMode:UpdateSmartTarget()
	end
end



function CombatMode:CursorAction(newState, event)
	if  self.CursorActionActive == newState  then  return  end
	self.CursorActionActive= newState
	
	-- this happens anytime the mouse moves over objects, or away from objects
	-- only checking if there is a frame (irrelevant) or spell or item on the cursor
	-- it is not an indicator of a busy cursor that should not be hidden
	self:LogState('  '.. event ..':  -> '.. colors.CursorActionActive .. 'CursorActionActive|r=' .. colorBoolStr(newState, false))
end


CombatMode.lastUpdateCursorBusy= false

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
		local  cursorBusy = CursorHasItem()  or  SpellIsTargeting()
		self:LogEvent(event, cursorBusy  and  'CursorActionActive=false')
		if  not cursorBusy  then  self:CursorAction(true, event)  end
		--[[
		-- this happens anytime the mouse moves over objects, or away from objects
		-- only checking if there is a frame (irrelevant) or spell or item on the cursor
		-- it is not an indicator of a busy cursor that should not be hidden
		--]]
		
		if  self.lastUpdateCursorBusy ~= cursorBusy  then
			self:UpdateMouselook(not cursorBusy, 'CURSOR_UPDATE')
			self.lastUpdateCursorBusy = cursorBusy
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

	elseif  event == "QUEST_PROGRESS"  then
		self:LogEvent(colors.show .. event .. colors.restore)
		self.FramesOnScreen:setInsertLast('QUEST_PROGRESS')
		self:CursorAction(false, event)
		self:UpdateMouselook(false, event)
	
	elseif  event == "QUEST_FINISHED"  then
		self:LogEvent(colors.hide .. event .. colors.restore)
		self.FramesOnScreen:removeFirst('QUEST_PROGRESS')
		self:CursorAction(false, event)
		self:UpdateMouselook(true, event)
		
	else
		self:LogEvent(event)
	end
	
end


--[[
function  CombatMode:CURSOR_UPDATE()
	self:LogEvent('CURSOR_UPDATE(2)')
	local  cursorBusy= CursorHasItem()  or  SpellIsTargeting()  or  self.CursorActionActive
	if  self.lastUpdateCursorBusy ~= cursorBusy  then
		self:UpdateMouselook(not cursorBusy, 'CURSOR_UPDATE')
		self.lastUpdateCursorBusy= cursorBusy
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
	for  groupName,count  in  pairs(groups)  do  if  0 ~= count  then
		CombatMode:LogState('  Group "'.. colors.yellow .. groupName ..'"|r had '.. count ..' keys pressed, is reset now')
		groups[groupName]= 0
	end end
end



function  CombatMode:UpdateMouselook(possibleTransition, event)
	event= event  or  'nil'
	local currentState= IsMouselooking()
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
		if  expState  then  MouselookStart()  else  MouselookStop()  end
		--self.lastMouselookSet= expState
	end
end

CombatMode.lastMouselook= false
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
	
	--[[ Turn,Pitch,Camera is first in priority:
	Turn,Pitch requires Mouselook OFF to actually turn the character; with Mouselook ON it acts as Strafe,Move.
	CameraOrSelectOrMove also moves the character while Mouselook is ON, therefore Mouselook is disabled for these.
	--]]
	if  0 < groups.NeedCursor		then  return false, 'Turn, Pitch, Camera, HoldToDisable'  end
	
	-- Cursor actions also top priority:
	if  SpellIsTargeting()			then  return false, 'SpellIsTargeting'  end
	if  CursorHasItem()					then  return false, 'CursorHasItem'  end
	--if  self.CursorActionActive  then  return false, 'CursorActionActive'  end
	
	-- TurnOrAction,MoveAndSteer,TargetScanEnemy,TargetNearestEnemy ignores FramesOnScreen,CursorAction
	-- Maybe it should be all Move,Strafe when bound to mouse button: this requires extra logic to detect
	if  0 < groups.Mouselook					then  return true, 'MoveAndSteer, ScanEnemy, HoldToEnable'  end
	
	-- FramesOnScreen higher priority than Move,Strafe
	if  self:CheckForFramesOnScreen()	then  return false, 'FramesOnScreen'  end
	
	-- Move,Strafe commands and enableAllways are the lowest priority
	if  self:EnableWhileMoving()  then
		if  0 < groups.MoveKeys					then  return true, 'Move,Strafe'  end
	end
	if  self.enableAllways				then  return true, 'enableAllways'  end
	
	-- By default Mouselook is OFF
	return  false, 'NoKeysPressed'
end



