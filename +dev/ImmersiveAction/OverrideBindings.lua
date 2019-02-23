local _G, ADDON_NAME, _ADDON = _G, ...
local ImmersiveAction = _G.ImmersiveAction or {}  ;  _G.ImmersiveAction = ImmersiveAction
local Log = ImmersiveAction.Log
local Log = ImmersiveAction.Log or {}  ;  ImmersiveAction.Log = Log

-- Used from LibShared:
local ipairsOrOne,packOrOne,pairsOrNil = LibShared.Import('ipairsOrOne,packOrOne,pairsOrNil,', ImmersiveAction)




------------------------------
-- Declare the command overrides in specific modes
-- OverridesIn[mode][fromCmd] = toCmd
------------------------------

local OverridesIn = { ActionMode = {}, AutoRun = {}, InteractNearest = {}, Mouselook = {}, General = {} }
ImmersiveAction.OverridesIn = OverridesIn

--- INTERACTMOUSEOVER --> TURNORACTION -- Invert Mouselook.
-- InteractMouseover is useless without cursor (in Mouselook mode).
-- Typically pressed if the user wants the mouse to select something so release the cursor with RightButton's command.
-- Only the first binding supported.
OverridesIn.Mouselook.INTERACTMOUSEOVER = 'TURNORACTION'

--- MOVEANDSTEER --> MOVEFORWARD for AutoRun to fix the abrupt stop.
-- MoveAndSteerStop() stops AutoRun, which is very disturbing when turning with MoveAndSteer while in AutoRun mode.
-- Override to TurnOrAction in AutoRun mode to avoid this annoyance. This is effective even out of ActionMode.
OverridesIn.AutoRun.MOVEANDSTEER = 'TURNORACTION'  -- Note: set priority over ActionMode's override, or skip that.
-- Or override with MoveForward in ActionMode, but that's no help out of ActionMode.
-- OverrideBindings.OverridesIn.ActionMode.MOVEANDSTEER = 'MoveForward'

-- TODO: Should only override MouseButton bindings.
-- Override at all times, losing Mouselook, and patch it back in  :SetCommandState()
--OverridesIn.General.MOVEANDSTEER = 'MOVEFORWARD'
-- Override in Mouselook, resulting in stuck Mouselook, and unstuck in  :SetCommandState()
--OverridesIn.Mouselook.MOVEANDSTEER = 'MOVEFORWARD'

--[[ ExpectedMouselook() now inverts Mouselook when RightButton is pressed, solving this issue.
-- RightButton = TURNORACTION:  in ActionMode Turning is always on making RightButton useless
--> change behavior with :ExpectedMouselook()  or  override with:
-- OverrideBindings.OverridesIn.ActionMode.TURNORACTION = 'INTERACTNEAREST'    -- Peaceful
-- if GetCVarBool('interactOnLeftClick') then
	-- OverrideBindings.OverridesIn.ActionMode.TURNORACTION = 'TargetNearestEnemy'
-- end    -- Combatant
--]]

--[[ ExpectedMouselook() also handles this, in a combat-safe mode, without bindings.
-- BUTTON1 = CAMERAORSELECTORMOVE: Select does nothing when mouse is hidden -> override with TargetNearestFriend.
-- Note: Camera needs disabling Mouselook in MouseDown script. Move (BUTTON1+BUTTON2) is pointless in this state.
-- OverrideFrames.Mouselook:OverrideCommand('CameraOrSelectOrMove', 'TargetNearestFriend')
-- if GetCVarBool('interactOnLeftClick') then  OverrideFrames.Mouselook:OverrideCommand('CameraOrSelectOrMove', 'INTERACTNEAREST')  end
--]]




------------------------------
-- User bindings frame
------------------------------

local UserBindings = CreateFrame("Frame")
ImmersiveAction.UserBindings = UserBindings
UserBindings:Hide()
UserBindings.cmdKeyMaps = {}


function ImmersiveAction:SetUserBinding(mode, key, command)
	self.db.profile['bindingsIn'..mode][key] = value
	UserBindings:OverrideOneBinding(mode, key, command)
end


function UserBindings:OverrideOneBinding(mode, newKey, command)
	if newKey=='' then  newKey = nil  end

	local cmdKeyMap = self.cmdKeyMaps[mode]
	if not cmdKeyMap then  cmdKeyMap = {} ; self.cmdKeyMaps[mode] = cmdKeyMap  end

	local oldKey = cmdKeyMap[toCmd]
	if oldKey then  SetOverrideBinding(self, false, oldKey, nil)  end
	cmdKeyMap[toCmd] = newKey
	SetOverrideBinding(self, false, newKey, toCmd)
end



function UserBindings:OverrideBindings(mode, keyBindings)
	if not keyBindings then  return  end

	local cmdKeyMap = self.cmdKeyMaps[mode]
	if not cmdKeyMap then  cmdKeyMap = {} ; self.cmdKeyMaps[mode] = cmdKeyMap  end

	-- Set new overrides
	for newKey,toCmd in pairs(keyBindings) do  if toCmd~='' then
		if newKey=='' then  newKey = nil  end
		local oldKey = cmdKeyMap[toCmd]
		LibShared.softassertf(not oldKey, "UserBindings:OverrideBindings(): command %s already registered, overwriting:  %s  ->  %s", toCmd, oldKey, newKey)
		cmdKeyMap[toCmd] = newKey
		print("UserBindings: SetOverrideBinding(.., "..newKey..", "..tostring(toCmd))
		SetOverrideBinding(self, false, newKey, toCmd)
	end end -- for for
end



function ImmersiveAction:OverrideUserBindings(mode)
	UserBindings:OverrideBindings(mode, self.db.profile['bindingsIn'..mode])
end


function ImmersiveAction:UpdateUserBindings()
	print("ImmersiveAction:UpdateUserBindings()")
	-- First happens in response to ADDON_LOADED. Later on ProfileChanged()  and  when a binding is changed in Config.
	--[[
	MouselookStop() won't interrupt command keys that are pressed, i.e. received "down" event, but not "up"
	Those commands will not run for the "up" event if their binding is changed, instead
	the new binding will receive the "up" event without a "down" event.
	This results in unexpectedly entering or leaving ImmersiveAction when rebinding a command that changes ImmersiveAction.
	--]]
	local wasMouselooking = IsMouselooking()
	if wasMouselooking then
		-- Log.Anomaly('ImmersiveAction:UpdateUserBindings() while IsMouselooking() could cause stuck keys, not updating bindings.')
		-- return
		Log.Anomaly('ImmersiveAction:UpdateUserBindings() while IsMouselooking() could cause stuck keys, temporarily disabling Mouselook.')
		MouselookStop()
	end

	ClearOverrideBindings(UserBindings)
	self:OverrideUserBindings('General')
	self:OverrideUserBindings('ActionMode')

	-- Modifiers (SHIFT/CTRL/ALT) to turn on/off ActionMode.
	-- Currently the ModifiedClick is not used, only the profile.modifiers.* setting.
	SetModifiedClick('ActionModeEnable', profile.modifiers.enableModifier)
	SetModifiedClick('ActionModeDisable', profile.modifiers.disableModifier)

	-- self:ResetState()
	if wasMouselooking then  MouselookStart()  end
end






-------------------------------
-- Command override bindings frame
-------------------------------

local OverrideBindings = CreateFrame('Frame')
ImmersiveAction.OverrideBindings = OverrideBindings
LibShared.SetScript.OnEvent(OverrideBindings)

OverrideBindings:Hide()
OverrideBindings.cmdKeys = {}
OverrideBindings.MouselookOverrides = {}


function OverrideBindings:CaptureBindings(mode, overrides)
	local cmdKeys = self.cmdKeys
	for fromCmd,toCmd in pairs(overrides) do
		if not cmdKeys[fromCmd] then
			-- Keys to override when enabled.
			cmdKeys[fromCmd] = packOrOne( GetBindingKey(fromCmd) )
		end
	end
end


function OverrideBindings:OverrideCommands(overrides, enable)
	for fromCmd,toCmd in pairs(overrides) do
		if not enable then  toCmd = nil  end
		for i,key in ipairsOrOne(self.cmdKeys[fromCmd]) do
			SetOverrideBinding(self, priority, key, toCmd)
		end
	end
end

--[[
-- Store  key -> toCmd  in keyOverrides  just like InteractNearest:CaptureBindings().
function OverrideBindings:CaptureBindings2(mode, overrides)
	local keyOverrides = {}
	for fromCmd,toCmd in pairs(overrides) do
		local keys = { GetBindingKey(fromCmd) }
		for i,key in ipairs(keys) do
			LibShared.softassert(not keyOverrides[key], "Duplicate key override: OverridesIn."..mode.."."..key)
			keyOverrides[key] = toCmd
		end
	end
	self.modeKeyOverrides[overrides] = keyOverrides
end


function OverrideBindings:OverrideCommands2(overrides, enable)
	local keyOverrides = self.modeKeyOverrides[overrides]
	for key,toCmd in pairs(keyOverrides) do
		if not enable then  toCmd = nil  end
		SetOverrideBinding(self, priority, key, toCmd)
	end
end
--]]


function OverrideBindings:ClearMouselookOverrideBindings()
	for key,toCmd in pairsOrNil(self.MouselookOverrides) do
		_G.SetMouselookOverrideBinding(key, nil)
	end
	wipe(self.MouselookOverrides)
end


function OverrideBindings:SetMouselookOverrideBindings(fromCmd, toCmd)
	-- Keys to override when enabled.
	for i,key in ipairsOrOne(self.cmdKeys[fromCmd]) do
		if LibShared.softassert(not self.MouselookOverrides[key]) then
			LibShared.softassertf(fromCmd~='TURNORACTION' and fromCmd~='TARGETSCANENEMY', "SetMouselookOverrideBindings():  overriding bindings of %q to %q will cause stucking in Mouselook mode.', fromCmd, toCmd)
			self.MouselookOverrides[key] = toCmd
			_G.SetMouselookOverrideBinding(key, toCmd)
		end
	end
end




------------------------------
-- Enable the overrides in specific modes.
------------------------------

function ImmersiveAction:OverrideCommandsIn(mode, enable)
	print('  ImmersiveAction:OverrideCommandsIn('..mode..', '..colorBoolStr(enable, true)..')')
	if InCombatLockdown() then
		Log.State("ImmersiveAction:OverrideCommandsIn() ignored:  Can't update bindings when InCombatLockdown()")
	else
		if enable==nil then  enable = self.commandState[mode]  end
		OverrideBindings:OverrideCommands(OverridesIn[mode], enable)
		if mode=='ActionMode' then  self:OverrideUserBindings(mode, enable)  end
	end
end


-- Disable OverrideBindings before combat.
function OverrideBindings:PLAYER_REGEN_DISABLED(event)
	self:OverrideCommandsIn('ActionMode'   , false)
	self:OverrideCommandsIn('AutoRun'      , false)
end

-- Enable OverrideBindings after combat, depending on ImmersiveAction.commandState[mode].
function OverrideBindings:PLAYER_REGEN_ENABLED(event)
	self:OverrideCommandsIn('ActionMode')
	self:OverrideCommandsIn('AutoRun')
end

function OverrideBindings:Enable(enable)
	enable = not not enable
	if self.enable == enable then  return  end
	self.enable = enable

	-- ImmersiveAction.commandState.OverrideBindings = enable
	if enable then
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:PLAYER_REGEN_ENABLED('Enable(true)')
	else
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		self:PLAYER_REGEN_DISABLED('Enable(false)')
	end
end




------------------------------
-- Update when bindings change.
------------------------------

function OverrideBindings:UpdateOverrideBindings(event)
	print("OverrideBindings:UpdateOverrideBindings()")

	ClearOverrideBindings(OverrideBindings)
	OverrideBindings:ClearMouselookOverrideBindings()

	-- Capture bindings of commands for later overriding.
	for mode,overrides in pairs(OverridesIn) do
		OverrideBindings.CaptureBindings(mode, overrides)
	end

	-- Mouselook bindings are activated by the game.
	for fromCmd,toCmd in pairs(OverridesIn.Mouselook) do
		OverrideBindings:SetMouselookOverrideBindings(fromCmd, toCmd)
	end
end


function OverrideBindings:GetBoundKeys(overrides)
	for fromCmd,toCmd in pairs(overrides) do
		local keys = self.cmdKeys[fromCmd]
		if keys then  return keys  end
	end
	return nil
end







-------------------------------
-- Experiment: SecureHandler hooking WorldFrame to capture mouse button commands.
-- Result:  WorldFrame has no OnClick handler (not a Button), and SecureHandlers don't support OnMouseDown/OnMouseUp handlers. Neat. Intended.
-------------------------------


function ImmersiveAction:RegisterOverrides()
	-- Secure wrapper  function  WorldMapFrame_OnClick(self, button, down)
	local preBody = [===[
	print("WorldFrame_OnMouseUp_preBody("..button..")")
	if  down  and  button == 'LeftButton'  then
		self:SetBinding(true, 'BUTTON2', 'AUTORUN')
	end
	]===]
	local postBody = [===[
	print("WorldFrame_OnMouseDown_postBody("..button..")")
	if  not down  and  button == 'LeftButton'  then
		self:ClearBinding('BUTTON2')
	end
	]===]

	-- _G.WorldClickHandler = _G.WorldClickHandler or CreateFrame('Frame', nil, nil, 'SecureHandlerClickTemplate')
	_G.WorldClickHandler = _G.WorldClickHandler or CreateFrame('Frame', nil, nil, 'SecureHandlerMouseUpDownTemplate')
	SecureHandlerWrapScript(WorldFrame, 'OnMouseUp'  , WorldClickHandler, preBody, nil)
	SecureHandlerWrapScript(WorldFrame, 'OnMouseDown', WorldClickHandler, "", postBody)
	-- WorldClickHandler:WrapScript(WorldFrame, 'OnClick', preBody, postBody)
	--WorldFrame:WrapScript(WorldFrame, 'OnClick', preBody, postBody)
end

-- ImmersiveAction:RegisterOverrides()

--[[
/dump WorldFrame:HasScript('OnClick'), WorldFrame:HasScript('PreClick'), WorldFrame:HasScript('PostClick'), WorldFrame:HasScript('OnMouseUp'), WorldFrame:HasScript('OnMouseDown')
--]]




--[[
/run ImmersiveAction:OverrideCommandsIn('ActionMode', true)
/run ImmersiveAction:OverrideCommandsIn('AutoRun', true)
/run SetOverrideBinding(ImmersiveAction.UserBindings, false, 'BUTTON1', nil) ; SetOverrideBinding(ImmersiveAction.UserBindings, false, 'BUTTON2', nil)

/dump  ImmersiveAction.UserBindings.keyMap
/run  ClearOverrideBindings(ImmersiveAction.UserBindings) ; ImmersiveAction.UserBindings.keyMap= nil
/run  SetOverrideBinding(ImmersiveAction.UserBindings, false, 'BUTTON1', nil)
/run  SetOverrideBinding(ImmersiveAction.UserBindings, false, 'BUTTON1', 'TURNORACTION')
/run  ImmersiveAction:UpdateUserBindings()

/run  SetBinding('BUTTON2', 'MOVEANDSTEER')
/run  SetOverrideBinding(ImmersiveAction.OverrideBindings, false, 'BUTTON2', 'MOVEANDSTEER')
/run  SetOverrideBinding(ImmersiveAction.OverrideBindings, false, 'BUTTON2', nil)
/run  SetMouselookOverrideBinding('X')

/run  ImmersiveAction:OverrideCommandsIn('ActionMode',true)
/run  ImmersiveAction:OverrideCommandsIn('AutoRun',true)
--]]



