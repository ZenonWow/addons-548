local _G, ADDON_NAME, _ADDON = _G, ...
local ImmersiveAction = _G.ImmersiveAction or {}  ;  _G.ImmersiveAction = ImmersiveAction
local Log = ImmersiveAction.Log
local Log = ImmersiveAction.Log or {}  ;  ImmersiveAction.Log = Log


------------------------------------------
-- Bindings --
------------------------------------------

-- Key bindings' labels
BINDING_HEADER_ImmersiveAction = "Immersive Action"
BINDING_NAME_COMBATMODE_TOGGLE = "Toggle Action mode"
--[[
BINDING_NAME_COMBATMODE_ENABLE= "Enable Action mode"
BINDING_NAME_COMBATMODE_DISABLE= "Disable Action mode"

function ImmersiveAction:EnableKey()
	self:SetActionMode(true)
	self:UpdateMouselook(true, 'EnableKey')
end	

<Binding name="COMBATMODE_ENABLE" header="ImmersiveAction">
	-- description="Enable Action mode"
	ImmersiveAction:EnableKey(keystate)
</Binding>
--]]	


-- Builtin commands
BINDING_NAME_CAMERAORSELECTORMOVE  = "Rotate Camera (Left Button default)"    -- targeting  or  camera rotation, original binding of BUTTON1
BINDING_NAME_TURNORACTION 				 = "Turn or Action (Right Button default)"  -- the original binding of BUTTON2
-- Custom commands
BINDING_NAME_INTERACTNEAREST       = "Target and interact with closest friendly npc"

local FocusMouseoverBinding = 'BINDING_NAME_CLICK FocusMouseoverButton:LeftButton'
do
	-- BINDING_NAME_FOCUSMOUSEOVER 						= "Focus Mouseover"		-- no turning or camera
	_G[FocusMouseoverBinding] = "Focus Mouseover"
	local FocusMouseoverButton = CreateFrame('Button', 'FocusMouseoverButton', UIParent, 'SecureActionButtonTemplate')
	FocusMouseoverButton:SetAttribute('type', 'macro')
	FocusMouseoverButton:SetAttribute('macrotext', '/focus mouseover')
end



------------------------------------------
-- Model of commands, declarative style --
------------------------------------------

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
		Log.Anomaly("  CM - CommandHook(".. ImmersiveAction.colors.red .. cmdName .."|r):  ".. suffix)
	else
		local keystate=  pressed  and  'down'  or  'up'
		Log.Command("  CM - CommandHook(".. ImmersiveAction.colors[keystate] .. cmdName .." ".. keystate:upper() .."|r)")
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
	
	-- Release this function, ensure it's not called again.
	self.HookCommands = nil
end




---------------------------------
-- Bindings.xml implementation --
---------------------------------

function ImmersiveAction:ToggleKey(toState)
	-- Invert current state if called without argument.
	if toState==nil then  toState = not IsMouselooking()  end
	-- local inverseState= not self:ExpectedMouselook()
	-- local inverseState= not self.commandState.ActionMode
	
	self:SetActionMode(toState)
	self:UpdateMouselook(toState, 'ToggleKey')
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

	Log.Event(event, '  -> cursorAction=' .. colorBoolStr(cstate.CursorObjectOrSpellTargeting, false))
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



