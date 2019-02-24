local _G, ADDON_NAME, _ADDON = _G, ...
local ImmersiveAction = _G.ImmersiveAction or {}  ;  _G.ImmersiveAction = ImmersiveAction
local Log = ImmersiveAction.Log
local Log = ImmersiveAction.Log or {}  ;  ImmersiveAction.Log = Log


-- TODO: pet battle handling

----------------------
-- Command bindings --
----------------------

-- Label visible in key bindings UI.
BINDING_HEADER_ImmersiveAction = "Immersive Action"

-- Custom commands
BINDING_NAME_INTERACTNEAREST    = "Target and interact with closest friendly npc"
BINDING_NAME_ToggleActionMode   = "Toggle Action mode"
BINDING_NAME_TurnOrActionHijack = "Turn without Interacting"

-- Builtin commands without a description
BINDING_NAME_CAMERAORSELECTORMOVE = "Rotate Camera     (LeftButton default)"
BINDING_NAME_TURNORACTION 				= "Turn or Interact (RightButton default)"


------------------------------------------
-- Model of commands, declarative style --
------------------------------------------

-- Save original MouselookStart, then securehook the global to catch addon usage.
ImmersiveAction.MouselookStart = _G.MouselookStart
ImmersiveAction.MouselookStop  = _G.MouselookStop

ImmersiveAction.commandsHooked = {
	TurnLeft			= 'Turn',
	TurnRight			= 'Turn',
	PitchUp				= 'Pitch',
	PitchDown			= 'Pitch',

	CameraOrSelectOrMove		= false,  -- Solo
	-- TurnOrAction	= 'Mouselook',
	TurnOrAction	= false,            -- Custom: sets Mouselook to inverse of lastMouselook.

	MoveAndSteer	= 'Mouselook',
	-- TargetScanEnemy, TargetNearestEnemy:
	TargetPriorityHighlight	= 'Mouselook',
	Mouselook     = 'Mouselook',      -- Capture addons' usage and take into account.

	MoveForward		= 'MoveKeys',
	MoveBackward	= 'MoveKeys',
	StrafeLeft		= 'MoveKeys',
	StrafeRight		= 'MoveKeys',
}

local CommandStopFunc = {
	TargetPriorityHighlight	= _G.TargetPriorityHighlightStart and 'TargetPriorityHighlightEnd' or false,
}

local StopsAutoRun = {
	MoveAndSteerStart	= 1,
	MoveForwardStart	= 1,
	MoveBackwardStart	= 1,
}

--[[
TurnOrAction, MoveAndSteer, TargetPriorityHighlight  start Mouselook when pushed and stop it when released.
These are the only commands/functions altering Mouselook that I found.
All other functions altering Mouselook will be logged as anomaly.
Sidenote:  when  ActionMode == true  then we want Mouselook to stay ON after releasing these keys,
therefore UpdateMouselook() will override the effect of the Stop functions.
--]]
ImmersiveAction.commandsChangingMouselook = {
	TurnOrActionStart	= true,
	TurnOrActionStop	= false,
	MoveAndSteerStart	= true,
	MoveAndSteerStop	= false,
	-- TargetScanEnemy, TargetNearestEnemy:
	TargetPriorityHighlightStart	= true,
	TargetPriorityHighlightEnd		= false,
}




----------------------------------
-- The entry point of all hooks --
----------------------------------

local UniqueHooks = {}
function UniqueHooks.ToggleAutoRun()  ImmersiveAction:SetCommandState('AutoRun', not ImmersiveAction.commandState.AutoRun)  end
function UniqueHooks.StartAutoRun()  ImmersiveAction:SetCommandState('AutoRun', true)  end
function UniqueHooks.StopAutoRun()  ImmersiveAction:SetCommandState('AutoRun', false)  end


function ImmersiveAction:CommandHook(cmdName, pressed, event)
	if  StopsAutoRun[event]  then  self:SetCommandState('AutoRun', false)  end
	
	local stateOk = self:SetCommandState(cmdName, pressed)
	
	if not stateOk then
		local suffix= pressed  and  "key pressed again without being released. Stuck key?"  or  "key released without being pressed before."
		Log.Anomaly("  CM - CommandHook(".. self.colors.red .. cmdName .."|r):  ".. suffix)
	else
		local keystate=  pressed  and  'down'  or  'up'
		Log.Command("  CM - CommandHook(".. self.colors[keystate] .. cmdName .." ".. keystate:upper() .."|r)")
	end
	
	-- if self.commandsHooked[cmdName]=='Mouselook' then  possibleTransition = pressed  else  possibleTransition = not pressed  end

	-- Do MouselookStart/Stop as necessary
  ImmersiveAction:UpdateMouselook(nil, event)
end




-------------
-- Hooking --
-------------

local function HookCommandPrefixed(ImmersiveAction, cmdName, funcStart, funcStop)
	hooksecurefunc(funcStart, function ()  ImmersiveAction:CommandHook(cmdName, true,  funcStart )  end)
	hooksecurefunc(funcStop , function ()  ImmersiveAction:CommandHook(cmdName, false, funcStop  )  end)
end


function ImmersiveAction:HookCommands()
	Log.Init('CM - HookCommands()')
	
	for  cmdName,group  in  pairs(self.commandsHooked)  do
		local stopFunc = CommandStopFunc[cmdName]
		if stopFunc ~= false then  HookCommandPrefixed(self, cmdName, cmdName..'Start', stopFunc or cmdName..'Stop')  end
	end
	self.hooked= nil		-- free up, not used until /reload
	
	for  funcName,hookFunc  in  pairs(UniqueHooks)  do
		if  _G[funcName]  then
			hooksecurefunc(funcName, hookFunc)
		end
	end

	hooksecurefunc('MouselookStart', ImmersiveAction.NotifyMouselookUsage)
	
	-- Release this function, ensure it's not called again.
	self.HookCommands = nil
end


function ImmersiveAction.NotifyMouselookUsage()
	if  ImmersiveAction.notifiedMouselook  or  ImmersiveAction.db.global.dontNotify  then  return  end
	ImmersiveAction.notifiedMouselook = true
	local callerFrame = 3  -- 0:debugstack, 1:this function, 2:MouselookStart (the hooked one), 3:caller (or another hook added later)
	local callerStack = _G.debugstack(callerFrame,3,0)  -- read 3 frames to allow for tailcails (no filepath in those)
	local callerPath = callerStack and callerStack:match("^(.-): ")
	local msg = ImmersiveAction.colors.yellow.."ImmersiveAction|r:  another addon also uses MouselookStart(). If you experience unexpected mouse beaviour then consider disabling one addon. The call seems to originate from:  "..callerPath
	print(msg)
	LibShared.softassert(false, msg)
end



---------------------------------
-- Bindings.xml implementation --
---------------------------------

function ImmersiveAction:ToggleActionMode(toState)
	-- Invert current state if called without argument.
	if toState==nil then  toState = not IsMouselooking()  end
	-- local inverseState= not self:ExpectedMouselook()
	-- local inverseState= not self.commandState.ActionMode
	
	self:SetActionMode(toState)
	self:UpdateMouselook(toState, 'ToggleActionMode')
end


function ImmersiveAction:TurnOrActionHijack(pressed)
	-- TurnOrAction was pressed, then hijacked just before being released to avoid Interacting. Act as if TurnOrAction was released.
	self:SetCommandState('TurnOrAction', pressed)
	self:UpdateMouselook(nil, 'TurnOrActionHijack')
end



--------------------
-- Event handlers --
--------------------


local isModifierPressedFunc= {
	SHIFT = IsShiftKeyPressed,
	CTRL = IsCtrlKeyPressed,
	ALT = IsAltKeyPressed,
}

function ImmersiveAction:MODIFIER_STATE_CHANGED(event)
	local modifiers = self.db.profile.modifiers
	local IsEnableModPressed  = isModifierPressedFunc[ modifiers.enableModifier ]
	local IsDisableModPressed = isModifierPressedFunc[ modifiers.disableModifier ]
	local cstate = self.commandState
	cstate.enableModPressed  = IsEnableModPressed  and IsEnableModPressed ()
	cstate.disableModPressed = IsDisableModPressed and IsDisableModPressed()
	if cstate.enableModPressed and cstate.disableModPressed then
		-- Both pressed disables both.
		cstate.enableModPressed, cstate.disableModPressed  =  nil,nil
	end
	self:UpdateMouselook(nil, 'Modifier')
end




function ImmersiveAction:CURSOR_UPDATE(event, ...)
	--[[ CURSOR_UPDATE sent when
	1. cursor is shown (as hand) after being hidden for CameraOrSelectOrMove, TurnOrAction, MoveAndSteer, Mouselook
	2. before UPDATE_MOUSEOVER_UNIT:  cursor changes over actionable object to  bubble (gossip) / sword (enemy) / dragon (flightmaster) / mail (mailbox) / satchel (vendor,bank,auction) / hearthstone (innkeeper) / what else?
	-- event is not sent twice when moving over an actionable object:  hidden -> show hand cursor -> action cursor
	-- event is NOT sent when hiding cursor
	3. after/before CURRENT_SPELL_CAST_CHANGED
	--]]
	local cstate= self.commandState
	local lastState = cstate.CursorObjectOrSpellTargeting
	-- cstate.CursorHasItem = CursorHasItem()
	cstate.CursorPickedUp = GetCursorInfo()
	-- cstate.CursorPickedUp = CursorHasItem()  or  CursorHasMacro()  or  CursorHasMoney()  or  CursorHasSpell()
	cstate.SpellIsTargeting = SpellIsTargeting()
	cstate.CursorObjectOrSpellTargeting = cstate.CursorPickedUp or cstate.SpellIsTargeting

	Log.Event(event, '  -> cursorAction=' .. ImmersiveAction.colorBoolStr(cstate.CursorObjectOrSpellTargeting, false))
	if not lastState ~= not cstate.CursorObjectOrSpellTargeting then
		cstate.ActionModeRecent = nil    -- There is a more recent event now.
		self:UpdateMouselook(not cstate.CursorObjectOrSpellTargeting, 'CURSOR_UPDATE')
	end
end


--[[
-- ranged spell targeting starts/ends
function ImmersiveAction:CURRENT_SPELL_CAST_CHANGED()
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
function ImmersiveAction:PET_BAR_UPDATE(event)
	if  self.commandState.CursorObjectOrSpellTargeting  then
		Log.Event(event, '  -> ResetCursor()')
		ResetCursor()
		-- Triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end

function ImmersiveAction:ACTIONBAR_UPDATE_STATE(event)
	if  self.commandState.CursorObjectOrSpellTargeting  then
		Log.Event(event, '  -> ResetCursor()')
		ResetCursor()
		-- Triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end
--]]



