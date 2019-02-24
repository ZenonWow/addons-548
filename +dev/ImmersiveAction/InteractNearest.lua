local _G, ADDON_NAME, _ADDON = _G, ...
local ImmersiveAction = _G.ImmersiveAction or {}  ;  _G.ImmersiveAction = ImmersiveAction
local Log = ImmersiveAction.Log
local Log = ImmersiveAction.Log or {}  ;  ImmersiveAction.Log = Log

local LibShared,CreateFrame,ipairs,GetBindingKey = LibShared,CreateFrame,ipairs,GetBindingKey


---------------------------------
-- TargetNearestAndInteractNpc aka. InteractNearest, InteractNearest, SmartTargeting
---------------------------------

local InteractNearest = CreateFrame('Frame')
ImmersiveAction.InteractNearest = InteractNearest
LibShared.SetScript.OnEvent(InteractNearest)

InteractNearest:Hide()
-- InteractNearest.TargetEnemiesToo = 'TARGETNEAREST'
InteractNearest.TargetCommand = 'TARGETNEARESTFRIEND'
InteractNearest.InteractRange = 3    -- yards
InteractNearest.CheckInterval = 0.3  -- seconds


--- INTERACTTARGET --> TARGETNEARESTFRIEND / INTERACTTARGET depending on range.
-- One-key interact like in all modern/sane RPGs.
InteractNearest.Overrides = {}
InteractNearest.Overrides.INTERACTTARGET  = true
InteractNearest.Overrides.INTERACTNEAREST = true



--[[
Test macro conditionals:
[harm][dead] INTERACTTARGET ; [noharm][nodead] INTERACTTARGET ; TARGETNEARESTFRIEND
In combat:
-- target,interact,target,interact,..  --  Cannot trigger on keypress in secure context to switch the binding.
-- Auto-bind with this StateHandler macro:
[harm][dead] INTERACTTARGET ; [noharm][nodead] INTERACTTARGET ; [combat] TARGETLASTHOSTILE ; TARGETNEAREST
-- Out-of-combat:  check distance, override with TARGETNEAREST if far. OnUpdate and on target change.
-- StateHandler will override on next target change, then the distance logic triggers and overrides, if out-of-combat.

/dump SLASH_TARGET_LAST_ENEMY
/dump SLASH_TARGET_NEAREST_ENEMY
/dump SLASH_TARGET_NEAREST_FRIEND
/targetlastenemy

/console targetNearestDistance 10,000000
/targetenemy [noharm][dead]
/console targetNearestDistance 41.000000
--]]



--[[ Dec 7, 2017 by justice7ca
"Smart Targeting" to replace the default left click, or to be remapped with a keybind.
Essentially it will:
- No Target Selected
	- Scan for Enemy Target
		- No Enemy Target Found, Target Friendly
- Enemy Targeted
	- Scan for Target Enemy (click for new target)
- Friendly Targeted
	- If Friendly Target is within interact range, interact with target, otherwise Select Enemy Player Scan / Select Friendly if none found
The purpose of this is to allow left click to be used for multiple purposes while in ActionMode.
--]]

--[[ Dec 10, 2017 by justice7ca
 I actually ended up handling this slightly differently in 1.2.0.
 Left click selects friendly by default, if you're within range, it will change to interact for you.
 If you're out of range, it's back to select friendly.
 Essentially allowing you to Mouse1 your way to victory while questing / talking to NPC's.
--]]



---------------------------------
-- SecureHandlerStateTemplate for a minimal in-combat functionality
---------------------------------

--- InCombatSnippet(self, stateid, newstate)
-- Set all keys to a best-effort guess by the StateHandler.
--
local InCombatSnippet = [===[
	if newstate=='ignore' then  return  end
	if newstate == self:GetAttribute('InteractBinding') then  print("InCombatSnippet(): newstate == InteractBinding == "..newstate)  end
	self:SetAttribute('InteractBinding', newstate)
]===]

--- AddKey(key, toCmd)
local AddKey = [===[
	local key, toCmd = ...
	DynamicKeys[key] = toCmd
]===]

--- OverrideBindingsSnippet(self, name, value)
-- Set all keys to the new InteractBinding.
--
local OverrideBindingsSnippet = [===[
	if value=='' then  value = nil  end
	if lastInteractBinding == value then  print("OverrideBindingsSnippet(): value == lastInteractBinding == "..value)  end
	lastInteractBinding = value

	local TargetCommand = TargetCommand
	-- local TargetCommand = self:GetAttribute('TargetCommand')

	for key,interactCmd in pairs(DynamicKeys) do
		interactCmd =  value  and  interactCmd
		if interactCmd==true then  interactCmd = value or TargetCommand  end
		self:SetBinding(key, interactCmd)
	end
]===]


function InteractNearest:InitProtectedFrame()
	local NoCombatCondition = "[nocombat] ignore ; "
	local MouseOverCondition = "[@mouseover,harm,dead] INTERACTMOUSEOVER ; [@mouseover,noharm,nodead] INTERACTMOUSEOVER ; "
	local TargetCondition = "[harm,dead] INTERACTTARGET ; [noharm,nodead] INTERACTTARGET"
	-- SecureStateDriverManager:RegisterEvent("UPDATE_MOUSEOVER_UNIT")  -- necessary?

	local handler = CreateFrame('Frame', nil, 'SecureHandlerStateTemplate,SecureHandlerAttributeTemplate')
	self.InCombatHandler = handler
	handler:SetAttribute('_onstate-'..'InteractBinding', InCombatSnippet)
	handler:SetAttribute('_onattribute-'..'InteractBinding', OverrideBindingsSnippet)
	-- InCombatHandler:SetAttribute('_onattribute-'..'DynamicKeys', UpdateKeysSnippet)
	-- InCombatHandler:SetAttribute('_onattribute-'..'TargetCommand', UpdateKeysSnippet)
	
	-- Createthe "globals" available to the snippets in the protected environment.
	-- DynamicKeys (key->toCmd) restricted table:
	handler:Run(" DynamicKeys = newtable() ")
	handler.Env = GetManagedEnvironment(handler)
	-- TargetCommand:  copy of InteractNearest.TargetCommand
	handler:SetAttribute('_setTargetCommand', " TargetCommand = ... ")
	handler:SetAttribute('_set', " local name,value=... ; _G[name] = value ")
	handler:SetAttribute('_addKey', " local key,toCmd=... ; DynamicKeys[key] = toCmd ")
	-- handler.Env.TargetCommand = self.TargetCommand
	handler:RunSnippet('_setTargetCommand', self.TargetCommand)

	_G.RegisterStateDriver(InCombatHandler, 'InteractBinding', NoCombatCondition .. MouseOverCondition .. TargetCommand)
	self.InitProtectedFrame = nil
end


-- Upload the managed keys from the insecure table to the secure (restricted) DynamicKeys table.
function InteractNearest.InCombatHandler:UploadKeys(insecureKeys)
	print("InCombatHandler:UploadKeys()")
	handler:Run(" wipe(DynamicKeys) ")
	for key,toCmd in pairs(insecureKeys) do
		-- handler:RunSnippet('_addKey', key, toCmd)
		-- RunSnippet() is not found on Earth, or in any code. Only "Iriel’s Field Guide to Secure Handlers" mentions it, but not how to set tje snippets.
		handler:Run(" local key,toCmd=... ; DynamicKeys[key] = toCmd ", key, toCmd)
	end
end


---------------------------------
-- InteractNearest periodic OnUpdate to check distance every 0.3 sec.
---------------------------------

InteractNearest.sinceLastCheck = 0

-- OnUpdate() runs if  ==  ImmersiveAction.InteractNearest:IsShown()  ==  ImmersiveAction.DynamicKeys and not InCombatLockdown()
function InteractNearest:OnUpdate(elapsed)
	-- Periodic update every frame (per 33ms at 30fps). Skip frames until CheckInterval passed.
	self.sinceLastCheck = self.sinceLastCheck + elapsed
	if  self.CheckInterval < self.sinceLastCheck  and  self.trackedUnit then
		self.sinceLastCheck = 0
		self:OverrideBindings()
	end
end

InteractNearest:SetScript('OnUpdate', InteractNearest.OnUpdate)


---------------------------------
-- Target change event(s)
---------------------------------

function InteractNearest:UPDATE_MOUSEOVER_UNIT(event, ...)
	Log.Event(event)
	-- Hovering a new mouseover will override the previous trackedUnit if it's 'target'.
	self:TrackUnit('mouseover')
end

function InteractNearest:PLAYER_TARGET_CHANGED(event, ...)
	Log.Event(event)
	-- Selecting a new target after finding a potential mouseover will override the trackedUnit.
	self:TrackUnit('target')
end



---------------------------------
-- Entering/leaving combat
---------------------------------

function InteractNearest:PLAYER_REGEN_ENABLED(event)
	-- Called by ImmersiveAction:PLAYER_REGEN_ENABLED(event)
	-- to update OverridesIn.InteractNearest.*
	-- in TrackUnit(), before OverrideBindings:OverrideCommands(..)
	Log.Event(event)
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')

	-- Try to do  /targetlastenemy  after leaving combat.
	if event == 'PLAYER_REGEN_ENABLED' then  self.TargetLastHostile = 'TARGETLASTHOSTILE'  end

	-- Update TargetCommand in protected environment in case :SetTargetEnemiesToo() was called.
	-- Before OverrideBindings(), that will use it.
	-- self.InCombatHandler.Env.TargetCommand = self.TargetCommand
	self.InCombatHandler:RunSnippet('_setTargetCommand', self.TargetCommand)
	
	self:StartTacking()
end

function InteractNearest:StartTacking()
	-- TrackUnit() calls OverrideBindings() if necessary.
	if  not self:TrackUnit('mouseover')  then  self:TrackUnit('target')  end
	self:Show()    -- Request OnUpdate() calls.
end


function InteractNearest:PLAYER_REGEN_DISABLED(event)
	Log.Event(event)
	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:Hide()    -- Stop OnUpdate() calls.
end


---------------------------------
-- Enable if there are dynamic bindings:  OverridesIn.InteractNearest[dynamicCommand]
---------------------------------

function InteractNearest:SetTargetEnemiesToo(enable)
	self.TargetCommand = enable and 'TARGETNEAREST' or 'TARGETNEARESTFRIEND'
	if not InCombatLockdown() then  self.InCombatHandler.Env.TargetCommand = TargetCommand  end
end


function InteractNearest:Activate()
	local active =  self.enabled  and  nil~=next(self.keyOverrides)
	if self.active == active then  return nil  end
	self.active = active
	ImmersiveAction.commandState.InteractNearest = active

	if active then
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:PLAYER_REGEN_ENABLED('Enable(true)')
	else
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		self:PLAYER_REGEN_DISABLED('Enable(false)')
	end
	return active
end


-- InteractNearest:CaptureBindings() is a bit different from OverrideBindings:CaptureBindings()
-- as it stores  key -> toCmd  in keyOverrides, more suitable for the InCombatHandler.
function InteractNearest:UpdateOverrideBindings()
	local keyOverrides = self.CaptureBindings(self.Overrides)
	self.keyOverrides = keyOverrides
	self.InCombatHandler:UploadKeys(self.keyOverrides)
	self:Activate()
end

function InteractNearest:Enable(enable)
	self.enabled = not not enable
	self:Activate()
end


function InteractNearest.CaptureBindings(overrides)
	local keyOverrides = {}
	for fromCmd,toCmd in pairs(overrides) do
		local keys = { GetBindingKey(fromCmd) }
		for i,key in ipairs(keys) do
			LibShared.softassert(not keyOverrides[key], "")
			keyOverrides[key] = toCmd
		end
	end
end


---------------------------------
-- Check if targeted unit is a good candidate for interaction.
-- This happens on when target or mouseover changes.
---------------------------------

local function CheckUnitIsInteractable(unit)
	-- return  UnitExists(unit)
	return  UnitIsFriend('player', unit)  -- not PlayerCanAttack(unit)
		and  not UnitIsPlayer(unit)         -- not PlayerCanAssist(unit)
		-- The "Ethereal Vendor" is PlayerControlled, but also follows you around, therefore pointless for auto-targeting.
		and  not UnitPlayerControlled(unit)
		-- and  not UnitIsDead(unit)
		and  not UnitIsUnit(unit, 'npc')       -- Already interacting with a vendor, target next nearest.
		and  not UnitIsUnit(unit, 'questnpc')  -- Already interacting with a quest giver, target next nearest.
end

local function CheckUnitIsLootable(unit)
	return  UnitIsEnemy('player', unit)
		and  UnitIsDead(unit)    -- loot
		-- and  select(2, CanLootUnit( UnitGUID(unit) ))
	-- local hasLoot, canLoot = CanLootUnit( UnitGUID(unit)) )
end


function InteractNearest:TrackUnit(unit)
	print("InteractNearest:TrackUnit("..unit..")")

	local interact = CheckUnitIsInteractable(unit)
	local loot = not interact and CheckUnitIsLootable(unit)
	-- Check whether to track this unit.
	if  not interact  and  not loot  then
		-- Don't replace monitored unit with a non-interactable unit.
		if  self.trackedUnit ~= unit  then  return  false  end
		-- trackedUnit is no longer interactable. Stop monitoring.
		unit = nil
	elseif loot then
		-- Managed to target a lootable corpse, don't do TARGETLASTHOSTILE anymore.
		self.TargetLastHostile = nil
	end

	print("InteractNearest:TrackUnit(..) -> new trackedUnit = "..tostring(unit))
	self.trackedUnit = unit
	self.InteractCommand = unit == 'mouseover' and 'INTERACTMOUSEOVER' or 'INTERACTTARGET'
	-- Enable OnUpdate monitor if there is a tracked unit.
	self:SetShown(unit ~= nil)
	self:OverrideBindings()
	return unit
end


---------------------------------
-- Periodically check distance of tracked unit
---------------------------------

function InteractNearest:OverrideBindings()
	local unit = self.trackedUnit
	local interact =  unit  and  CheckInteractDistance(unit, self.InteractRange)
	local interactCmd =
  interact  and  self.InteractCommand
		or  self.TargetLastHostile
		or  self.TargetCommand	

	if  interactCmd == self.currentBinding  then  return  end		-- no changes
	self.currentBinding = interactCmd

	-- Override the bindings with the new command.
	-- This cannot be called InCombatLockdown().
	self.InCombatHandler:SetAttribute('InteractBinding', interactCmd)
end



