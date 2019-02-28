local G, ADDON_NAME, ADDON = _G, ...
local IA = G.ImmersiveAction or {}  ;  G.ImmersiveAction = IA
local Log = IA.Log or {}  ;  IA.Log = Log


-- TODO: pet battle handling

----------------------
-- Command bindings --
----------------------

-- Label visible in key bindings UI.
BINDING_HEADER_ImmersiveAction    = "Immersive Action"

-- Custom commands
BINDING_NAME_INTERACTNEAREST      = "Target and interact closest friendly npc"
BINDING_NAME_ToggleActionMode     = "Toggle Action mode"
BINDING_NAME_TurnWithoutInteract  = "Turn without Interacting"

-- Builtin commands without a description
BINDING_NAME_CAMERAORSELECTORMOVE = "Rotate Camera     (LeftButton default)"
BINDING_NAME_TURNORACTION 				= "Turn or Interact (RightButton default)"


------------------------------------------
-- Model of commands, declarative style --
------------------------------------------

-- Save original MouselookStart, then securehook the global to catch addon usage.
IA.IsMouselooking = G.IsMouselooking
IA.MouselookStart = G.MouselookStart
IA.MouselookStop  = G.MouselookStop

IA.commandsHooked = {
	TurnLeft			= 'Turn',
	TurnRight			= 'Turn',
	PitchUp				= 'Pitch',
	PitchDown			= 'Pitch',

	CameraOrSelectOrMove = 'MouseCursor',  -- Solo
	TurnOrAction	= 'MouseTurn',
	-- TurnOrAction	= false,            -- Custom: sets Mouselook to inverse of lastMouselook.

	MoveAndSteer	= 'MouseTurn',
	-- TargetScanEnemy, TargetNearestEnemy:
	TargetPriorityHighlight	= 'MouseTurn',
	Mouselook     = 'MouseTurn',      -- Capture addons' usage and take into account.

	MoveForward		= 'MoveKeys',
	MoveBackward	= 'MoveKeys',
	StrafeLeft		= 'MoveKeys',
	StrafeRight		= 'MoveKeys',
}

local CommandStopFunc = {
	TargetPriorityHighlight	= G.TargetPriorityHighlightStart and 'TargetPriorityHighlightEnd' or false,
}

--[[
local StopsAutoRun = {
	MoveAndSteerStart	= 1,
	MoveForwardStart	= 1,
	MoveBackwardStart	= 1,
}
--]]

--[[
TurnOrAction, MoveAndSteer, TargetPriorityHighlight  start Mouselook when pushed and stop it when released.
These are the only commands/functions altering Mouselook that I found.
All other functions altering Mouselook will be logged as anomaly.
Sidenote:  when  ActionMode == true  then we want Mouselook to stay ON after releasing these keys,
therefore UpdateMouselook() will override the effect of the Stop functions.
--]]
IA.commandsChangingMouselook = {
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
function UniqueHooks.ToggleAutoRun()  IA:SetCommandState('AutoRun', not IA.commandState.AutoRun)  end
function UniqueHooks.StartAutoRun()  IA:SetCommandState('AutoRun', true)  end
function UniqueHooks.StopAutoRun()  IA:SetCommandState('AutoRun', false)  end


function IA:CommandHook(cmdName, pressed, event)
	self:ProcessCommand(cmdName, pressed)
	-- if self.commandsHooked[cmdName]=='MouseTurn' then  possibleTransition = pressed  else  possibleTransition = not pressed  end
	-- Do MouselookStart/Stop as necessary
  self:UpdateMouselook(nil, event)
end


function IA:PLAYER_STARTED_MOVING(event)
	Log.Event(event)
end

function IA:PLAYER_STOPPED_MOVING(event)
	Log.Event(event)
	if self.commandState.AutoRun then
		IA:SetCommandState('AutoRun', false)
		Log.Anomaly("  IA:PLAYER_STOPPED_MOVING():  Disabled commandState."..colors.AutoRun.."AutoRun|r, state would have been inverted, and MoveAndSteer rebinding to TurnWithoutAction stuck.")
		-- UpdateMouselook() does not depend on AutoRun, therefore not called.
	end
end


-------------
-- Hooking --
-------------

local function HookCommandPrefixed(IA, cmdName, funcStart, funcStop)
	hooksecurefunc(funcStart, function ()  IA:CommandHook(cmdName, true,  funcStart )  end)
	hooksecurefunc(funcStop , function ()  IA:CommandHook(cmdName, false, funcStop  )  end)
end


function IA:HookCommands()
	Log.Init('IA - HookCommands()')
	
	for  cmdName,group  in  pairs(self.commandsHooked)  do
		local stopFunc = CommandStopFunc[cmdName]
		if stopFunc ~= false then  HookCommandPrefixed(self, cmdName, cmdName..'Start', stopFunc or cmdName..'Stop')  end
	end
	self.hooked= nil		-- free up, not used until /reload
	
	for  funcName,hookFunc  in  pairs(UniqueHooks)  do
		if  G[funcName]  then
			hooksecurefunc(funcName, hookFunc)
		end
	end

	hooksecurefunc('MouselookStart', IA.NotifyMouselookUsage)
	
	-- Release this function, ensure it's not called again.
	self.HookCommands = nil
end


function IA.NotifyMouselookUsage()
	if  IA.notifiedMouselook  or  IA.db.global.dontNotify  then  return  end
	IA.notifiedMouselook = true
	local callerFrame = 3  -- 0:debugstack, 1:this function, 2:MouselookStart (the hooked one), 3:caller (or another hook added later)
	local callerStack = G.debugstack(callerFrame,3,0)  -- read 3 frames to allow for tailcails (no filepath in those)
	local callerPath = callerStack and callerStack:match("^(.-): ")
	local msg = IA.colors.yellow.."ImmersiveAction|r:  another addon also uses MouselookStart(). If you experience unexpected mouse beaviour then consider disabling one addon. The call seems to originate from:  "..callerPath
	print(msg)
	LibShared.softassert(false, msg)
end



---------------------------------
-- Bindings.xml implementation --
---------------------------------

function IA:ToggleActionMode(toState)
	-- Invert current state if called without argument.
	if toState==nil then  toState = not IsMouselooking()  end
	-- local inverseState= not self:ExpectedMouselook()
	-- local inverseState= not self.commandState.ActionMode
	
	self:SetActionMode(toState)
	self:UpdateMouselook(toState, 'ToggleActionMode')
end


function IA:TurnWithoutInteract(pressed)
	-- Like TurnOrAction (RightButton), without accidental interacting / pull / target change when released.
	self:SetCommandState('TurnWithoutInteract', pressed)
	self:UpdateMouselook(true, 'TurnWithoutInteract')
end

function IA:ReleaseCursor(pressed)
	-- RightButton in ActionMode.
	self:SetCommandState('ReleaseCursor', pressed)
	self:UpdateMouselook(false, 'ReleaseCursor')
end

--[[
function IA:TurnOrActionHijack(pressed)
	-- TurnOrAction was pressed, then hijacked just before being released to avoid Interacting. Act as if TurnOrAction was released.
	self:SetCommandState('TurnOrAction', pressed)
	self:UpdateMouselook(nil, 'TurnOrActionHijack')
end
--]]




--------------------
-- Event handlers --
--------------------

function IA:RegisterCommandEvents(enable)
	if enable ~= false then
		self:RegisterEvent('MODIFIER_STATE_CHANGED')
		self:RegisterEvent('CURSOR_UPDATE')
		-- self:RegisterEvent('PET_BAR_UPDATE')
		-- self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
		self:RegisterEvent('PLAYER_STARTED_MOVING')
		self:RegisterEvent('PLAYER_STOPPED_MOVING')
	else
		self:UnregisterEvent('MODIFIER_STATE_CHANGED')
		self:UnregisterEvent('CURSOR_UPDATE')
		-- self:UnregisterEvent('PET_BAR_UPDATE')
		-- self:UnregisterEvent('ACTIONBAR_UPDATE_STATE')
		self:UnregisterEvent('PLAYER_STARTED_MOVING')
		self:UnregisterEvent('PLAYER_STOPPED_MOVING')
	end
end


local isModifierPressedFunc= {
	SHIFT = IsShiftKeyPressed,
	CTRL = IsCtrlKeyPressed,
	ALT = IsAltKeyPressed,
}


function IA:MODIFIER_STATE_CHANGED(event)
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




function IA:CURSOR_UPDATE(event, ...)
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

	Log.Event(event, '  -> cursorAction=' .. IA.colorBoolStr(cstate.CursorObjectOrSpellTargeting, false))
	if not lastState ~= not cstate.CursorObjectOrSpellTargeting then
		cstate.ActionModeRecent = nil    -- There is a more recent event now.
		self:UpdateMouselook(not cstate.CursorObjectOrSpellTargeting, 'CURSOR_UPDATE')
	end
end


--[[
-- ranged spell targeting starts/ends
function IA:CURRENT_SPELL_CAST_CHANGED()
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
function IA:PET_BAR_UPDATE(event)
	if  self.commandState.CursorObjectOrSpellTargeting  then
		Log.Event(event, '  -> ResetCursor()')
		ResetCursor()
		-- Triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end

function IA:ACTIONBAR_UPDATE_STATE(event)
	if  self.commandState.CursorObjectOrSpellTargeting  then
		Log.Event(event, '  -> ResetCursor()')
		ResetCursor()
		-- Triggers CURSOR_UPDATE, that will do self:UpdateMouselook(not cursorAction, event)
	end
end
--]]



