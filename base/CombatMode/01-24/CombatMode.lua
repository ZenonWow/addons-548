-- Addon main: Ace libs, initialization, settings, bindings
local AddonName, Addon = ...
CombatMode = LibStub("AceAddon-3.0"):NewAddon("CombatMode", "AceConsole-3.0", "AceEvent-3.0")

--[[ Debug:
/dump CombatMode.config.optionsFrame
--]]

-- Key bindings' labels
BINDING_NAME_COMBATMODE_ENABLE= "Enable while holding or toggle with click"
BINDING_NAME_COMBATMODE_TOGGLE= "Toggle Combat Mode when clicked"
BINDING_NAME_COMBATMODE_HOLD= "Switch Combat Mode while holding"
--BINDING_NAME_COMBATMODE_HOLDTOGGLE= "Toggle Combat Mode (hold or click)"

CombatMode.CombatModeEnabled= false		-- permanent combat mode with no buttons pressed
CombatMode.CombatModeHold= nil				-- temporarily change combat mode (if not nil) while bound key/button is pressed
CombatMode.CursorActionActive= false
--local combatModeTemporaryDisable = true		-- combatModeTemporaryDisable is expected to be == not IsMouselooking()
local SmartTargetingEnabled= true
local SmartTargetingCanInteract= false

CombatMode.config= {}
CombatMode.config.settingsDefaults= {
	--global = { version = "1.0.0", },
	profile= {
		enableWhileMoving= true,
		bindings= {
			['BUTTON1']				= "SMARTTARGETANDINTERACTNPC",
			['ALT-BUTTON1']		= nil,  --"",
			['SHIFT-BUTTON1'] = "TARGETPREVIOUSFRIEND",
			['CTRL-BUTTON1']	= "TARGETNEARESTFRIEND",
			['BUTTON2']				= "TARGETSCANENEMY",
			['ALT-BUTTON2']		= nil,  --"",
			['SHIFT-BUTTON2'] = "TARGETNEARESTENEMY",
			['CTRL-BUTTON2']	= "INTERACTTARGET",
		},
		modifiers= {
		},
	}
}
--[[ Dec 5, 2017 by justice7ca
I had to update the Keybindings again, there were a lot of issues binding Target Friendly to a ctrl+click key, it doesn't have the same affect as putting it on a basic click.
SO, Left click now selects a friendly target, right click will select an enemy target.  Control or Shift click to interact.  Much simpler, I am still building the ui for the config, that's coming.
--]]




function CombatMode:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.config.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("cm", "CombatMode", input)
    end
end


function CombatMode:OnInitialize()

	self:LogInit('CombatMode:OnInitialize()')
	self:HookCommands()
	self:HookUpFrames()		-- is it necessary before OnEnable() calling it again?
	self:RegisterChatCommand("cm", "ChatCommand")
	self:RegisterChatCommand("combatmode", "ChatCommand")
	
	--[[
	Use one profile called 'Default' for all characters (by default)
	Name of default profile can be changed with setting  profileKeys['default']
	To have character-specific profiles when creating/initializing a new character
	set  profileKeys['default']= false
	--]]
	local defaultProfile= CombatModeDB.profileKeys.default
	if  defaultProfile == nil  then  defaultProfile= true  end		-- false to have character-specific profiles
	self.db = LibStub("AceDB-3.0"):New("CombatModeDB", self.config.settingsDefaults, defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	--self.db.RegisterCallback(self, "OnDatabaseShutdown", "OnDisable")
	
	--self.config:InitOverrideLabels()
	--self.config:InitOptionsTable()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Combat Mode", self.config.optionsTable)
	self.config.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Combat Mode", "Combat Mode")

	self:ProfileChanged()
end	

--[[
function CombatMode_OnLoad(self, elapsed)
	CombatMode:LogInit('CombatMode_OnLoad()')
	--CombatMode:HookUpFrames()
end
--]]

function CombatMode:OnEnable()
	self:LogInit('CombatMode:OnEnable()')
	self:HookUpFrames()
	-- Register Events
	-- find missing frames when delayed loading any addon
	self:RegisterEvent("ADDON_LOADED", function ()  self:HookUpFrames()  end)
	--[[
	self:RegisterEvent("CURSOR_UPDATE", CombatMode_OnEvent)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", CombatMode_OnEvent)
	self:RegisterEvent("PET_BAR_UPDATE", CombatMode_OnEvent)
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE", CombatMode_OnEvent)
	self:RegisterEvent("QUEST_PROGRESS", CombatMode_OnEvent)
	self:RegisterEvent("QUEST_FINISHED", CombatMode_OnEvent)
	self:RegisterEvent('CURSOR_UPDATE')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('PET_BAR_UPDATE')
	self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
	self:RegisterEvent('QUEST_PROGRESS')
	self:RegisterEvent('QUEST_FINISHED')
	--]]
end

function CombatMode:OnDisable()
	self:LogInit('CombatMode:OnDisable()')
	-- Called when the addon is disabled
	self:UnregisterEvent('CURSOR_UPDATE')
	self:UnregisterEvent('PLAYER_TARGET_CHANGED')
	self:UnregisterEvent('PET_BAR_UPDATE')
	self:UnregisterEvent('ACTIONBAR_UPDATE_STATE')
	self:UnregisterEvent('QUEST_PROGRESS')
	self:UnregisterEvent('QUEST_FINISHED')
end

function CombatMode:ProfileChanged()
	self.config:MigrateSettings()
	self:BindBindingOverrides()
end




BINDING_NAME_FOCUSMOUSEOVER 						= "Focus Mouseover"		-- no turning or camera
BINDING_NAME_CAMERAORSELECTORMOVE 			= "Rotate Camera"			-- targeting  or  camera rotation, original binding of BUTTON1
BINDING_NAME_TURNORACTION 							= "Turn or Action"		-- the original binding of BUTTON2
BINDING_NAME_SMARTTARGETANDINTERACTNPC 	= "Smart Target: target and interact closest friendly npc"

CombatMode.config.commandLabels = {
		[''] 													= "-- don't override --",
		--[[
		['FOCUSMOUSEOVER'] 						= "Focus Mouseover",	-- no turning or camera
		['CAMERAORSELECTORMOVE'] 			= "Rotate Camera",		-- targeting  or  camera rotation, original binding of BUTTON1
		['TURNORACTION'] 							= "Turn or Action",		-- the original binding of BUTTON2
		['SMARTTARGETANDINTERACTNPC'] = "Smart Target: target and interact closest friendly npc",
		--]]
}


CombatMode.config.modifierKeys = { '', 'SHIFT', 'CTRL', 'ALT' }

--[[ Commands vocabulary:
turning (character with mouse) = CombatMode (term from GuildWars2 community) = Mouselook (term from Blizzard - Wow lua api)
camera (rotation) = look around with mouse, like turning, but the character does not move / change direction
	- only possible with CAMERAORSELECTORMOVE command and disabled CombatMode
--]]
CombatMode.config.overrideCommands = { 
		'',		-- don't override --
		
		-- Target (select with mouse)
		'SMARTTARGETANDINTERACTNPC',	-- could override INTERACTMOUSEOVER instead: without cursor (in CombatMode) it has no effect
		'TARGETSCANENEMY',					-- with turning/lock (Mouselook)
		'TARGETNEARESTENEMY',				-- acts similar to TargetScanEnemy, what are the differences?
		
		'TARGETMOUSEOVER',					-- no turning or camera -> hook mouse button directly to disable Mouselook while pressed
		'FOCUSMOUSEOVER',						-- no turning or camera
		'CAMERAORSELECTORMOVE',			-- targeting  or  camera rotation, original binding of BUTTON1
		-- Must disable Mouselook otherwise it acts as MoveAndSteer
		'TURNORACTION',							-- Mouselook if hold, InteractMouseover if clicked, original binding of BUTTON2
		
		-- Target Nearest (tab targeting, no turning or camera, mouse influences direction to look for the nearest)
		'TARGETNEARESTFRIENDPLAYER',
		'TARGETNEARESTENEMYPLAYER',
		'TARGETNEARESTFRIEND',			-- SmartTarget uses it; this one is less useful, candidate for removal
		'TARGETPREVIOUSFRIEND',
		
		-- Interact
		'INTERACTMOUSEOVER',				-- select with mouse + interact, no turning or camera
		-- hook mouse button directly to disable Mouselook while pressed
		-- or override with COMBATMODE_DISABLE/COMBATMODE_HOLD
		'INTERACTTARGET',						-- no select, only interact
		-- any valid use-cases for this in CombatMode?
		
		-- Move
		'MOVEANDSTEER',
		'MOVEFORWARD',
		'MOVEBACKWARD',
		'STRAFELEFT',
		'STRAFERIGHT',
		'JUMP',
		'SITORSTAND',
		
		-- ActionBar
		'ACTIONBUTTON1',
		'ACTIONBUTTON2',
		'ACTIONBUTTON3',
		'ACTIONBUTTON4',
		'ACTIONBUTTON5',
		'ACTIONBUTTON6',
		'ACTIONBUTTON7',
		'ACTIONBUTTON8',
		'ACTIONBUTTON9',
		'ACTIONBUTTON10',
		'ACTIONBUTTON11',
		'ACTIONBUTTON12',
}


function CombatMode.config:GetCommandLabel(command)
	return self.commandLabels[command]  or  _G['BINDING_NAME_'.. command]  or  command
end

function CombatMode.config:InitOverrideLabels()
	if  self.overrideLabels  then  return self.overrideLabels  end
	self.overrideLabels= {}
	for  i,command  in  ipairs(self.overrideCommands)  do
		local label= self:GetCommandLabel(command)
		--self.commandLabels[command]= label
		table.insert(self.overrideLabels, label)
	end
	return self.overrideLabels
end

--CombatMode.config:InitOverrideLabels()



local optCnt= 0
local function opt(key, name, desc, defValues)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "select",
		--width = "full",
		values = defValues or CombatMode.config:InitOverrideLabels(),
		get = function()
			local value= CombatMode.db.profile.bindings[key]
			return  Addon.tableProto.indexOf(CombatMode.config.overrideCommands, value)
		end,
		set = function(info, idx)
			CombatMode.db.profile.bindings[key]= CombatMode.config.overrideCommands[idx]
			CombatMode:BindBindingOverrides()
		end,
	}
	CombatMode.config.optionsTable.args[key]= optInfo
	return optInfo
end

local function optMod(key, name, desc, defValues)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "select",
		--width = "full",
		values = CombatMode.config.modifierKeys,
		get = function()
			local value= CombatMode.db.profile.modifiers[key]
			return  Addon.tableProto.indexOf(CombatMode.config.modifierKeys, value)
		end,
		set = function(info, idx)
			--if  value == ''  or  value == 'NONE'  then  value= nil  end
			CombatMode.db.profile.modifiers[key]= CombatMode.config.modifierKeys[idx]
			CombatMode:BindBindingOverrides()
		end,
	}
	CombatMode.config.optionsTable.args[key]= optInfo
	return optInfo
end

local function optCheck(key, name, desc)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "toggle",
		--width = "full",
		get = function()  return CombatMode.db.profile[key]  end,
		set = function(info, value)  CombatMode.db.profile[key]= value  end,
	}
	CombatMode.config.optionsTable.args[key]= optInfo
	return optInfo
end


CombatMode.config.optionsTable = { 
	name = "Combat Mode Settings",
	handler = CombatMode,
	type = "group",
	args = {},
}

CombatMode.config.optionsTableList = { 
	opt("BUTTON1", "Left Click", "Override original behavior of Left Mouse Button"),
	opt("BUTTON2", "Right Click", "Override original behavior of Right Mouse Button"),
	opt("ALT-BUTTON1", "Shift + Left Click"),
	opt("ALT-BUTTON2", "Shift + Right Click"),
	opt("SHIFT-BUTTON1", "Shift + Left Click"),
	opt("SHIFT-BUTTON2", "Shift + Right Click"),
	opt("CTRL-BUTTON1", "Control + Left Click"),
	opt("CTRL-BUTTON2", "Control + Right Click"),
	optCheck("enableWhileMoving", "Enable while moving", "While pressing any movement key CombatMode is enabled"),
	optMod("CM_ENABLE_MOD", "Enable while moving with modifier:", "While pressing this modifier and any movement key CombatMode is enabled"),
	optMod("CM_DISABLE_MOD", "Disable while moving with modifier:", "While pressing this modifier and any movement key CombatMode is disabled"),
	--opt("smarttargeting", "Smart Targeting", "Buttons that target the closest friendly NPC and interact with it if close enough", SmartTargetValues),
}




local function SetBindings(keys, command)
	for  i,key  in  ipairs(keys)  do
		SetBinding(key, command)
	end
	local name= _G['BINDING_NAME_'.. command]  or  command
	print('CombatMode updating binding  "'.. name ..'":  '.. table.concat(keys, ', '))
end


function CombatMode.config:MigrateSettings()
	CombatMode.db.profile.bindings= CombatMode.db.profile.bindings or {}
	CombatMode.db.profile.modifiers= CombatMode.db.profile.modifiers or {}
	local bindings= CombatMode.db.profile.bindings
	
	local function MigrateBinding(key, newCmd)
		local oldCmd= bindings[key] or ''
		bindings[key]= newCmd
		local oldCmdLabel= oldCmd == ''  and  ''  or  self:GetCommandLabel(oldCmd) ..'  '
		local newCmdLabel= self:GetCommandLabel(newCmd)
		local keyName= self.optionsTable.args[key].name
		print('CombatMode updating binding  '.. keyName ..':  '.. oldCmdLabel ..'->  '.. newCmdLabel)
	end
	
	-- migrate bindings.*button*
	for  newKey,defValue  in  pairs(self.settingsDefaults.profile.bindings)  do  if  bindings[oldKey]  then
		local oldKey= newKey:gsub('-',''):lower()
		local old=  bindings[oldKey]
		if  old  then
			bindings[newKey]= old.value == 'NOCHANGE'  and  ''  or  old.value
			bindings[oldKey]= nil
		end
	end end
	
	-- migrate bindings.smarttargeting
	local smartButton= bindings.smarttargeting  and  bindings.smarttargeting.value
	if  smartButton == 'LEFT'  then
		MigrateBinding('BUTTON1', 'SMARTTARGETANDINTERACTNPC')
	elseif  smartButton == 'RIGHT'  then
		MigrateBinding('BUTTON2', 'SMARTTARGETANDINTERACTNPC')
	elseif  smartButton == 'BOTH'  then
		MigrateBinding('BUTTON1', 'SMARTTARGETANDINTERACTNPC')
		MigrateBinding('BUTTON2', 'SMARTTARGETANDINTERACTNPC')
	elseif  smartButton ~= 'DISABLED'  then
		smartButton= nil	-- don't delete unknown, unprocessed setting
	end
	if  smartButton  then  bindings.smarttargeting= nil  end

	--[[ 2018-01-23
	Renamed commands: keep the old as hidden and rebind to new on load
	"Combat Mode Toggle" -> COMBATMODE_TOGGLE
	"(Hold) Switch Mode" -> COMBATMODE_HOLD
	--]]
	local  keys1= { GetBindingKey("Combat Mode Toggle") }
	local  keys2= { GetBindingKey("(Hold) Switch Mode") }
	if  #keys1 == 0  then  keys1= nil  end
	if  #keys2 == 0  then  keys2= nil  end

  if  keys1  and  keys2  then
		SetBindings(keys1, "COMBATMODE_TOGGLE")
	  SetBindings(keys2, "COMBATMODE_HOLD")
	elseif  key1  or  key2  then
		-- If only one is bound -> COMBATMODE_ENABLE
	  SetBindings(key1 or key2, "COMBATMODE_ENABLE")
	end
end




CombatMode.overridden = { Mouselook = {}, CombatMode = {}, AutoRun = {} }

CombatMode.overrideBindings = {
	Mouselook = {
	},
	CombatMode = {
		MoveAndSteer = 'MoveForward',
		InteractMouseover = 'CombatMode_Disable',
	},
	AutoRun = {
		MoveAndSteer = 'TurnOrAction',
	},
}


function CombatMode.overridden.CombatMode:BindFrameOverrides(fromCmd, toCmd)
	--[[ Override MOVEANDSTEER with MOVEFORWARD in CombatMode.
	MoveAndSteerStop()  calls  MouselookStop()  on release, disabling CombatMode.
	UpdateMouselook()  re-enables Mouselook therefore it's not necessary for this reason.
	If a bug is caused by the  MouselookStop() -> MouselookStart()  transient,
	then enable this to remove the transient and the bug with it.
	--]]
	--self.frame= self.frame or CreateFrame("Frame", nil) --, UIParent)
	
	for  i,key  in  ipairs(self[fromCmd] or {})  do
		-- Remove previous overrides
		SetMouselookOverrideBinding(key, nil)
	end
	--[[ Only override in explicit CombatMode.
	Overriding when MoveAndSteer is pressed (mouselook is temporary) would cause
	not running the key release handler, resulting in stuck Mouselook.
	--]]
	self[fromCmd]= CombatMode.CombatModeEnabled  and  { GetBindingKey('MOVEANDSTEER') }  or  {}
	for  i,key  in  ipairs(self[fromCmd])  do
		-- New overrides
		SetMouselookOverrideBinding(key, toCmd)
	end
end	


function CombatMode:BindBindingOverrides()
	--[[
	local wasMouselooking= IsMouselooking()
	if  wasMouselooking  then  MouselookStop()  end
	
	MouselookStop() won't interrupt command keys that are pressed, i.e. received "down" event, but not "up"
	Those commands will not run for the "up" event if their binding is changed, instead
	the new binding will receive the "up" event without a "down" event.
	This results in unexpectedly entering or leaving CombatMode when rebinding a command that changes CombatMode.
	--]]
	
	CombatMode.overridden.CombatMode:BindFrameOverrides('MoveAndSteer', 'MoveForward')
	
	SmartTargetingEnabled= nil		-- reset
	local profile= self.db.profile
	
	-- Modifiers (SHIFT/CTRL/ALT) to turn on/off EnableWhileMoving()
	if  profile.modifiers  then  for  key,binding  in  pairs(profile.modifiers)  do
		SetModifiedClick(key,binding)
	end end
	
	
	-- Remove previous overrides
	for  key,binding  in  pairs(self.overridden.Mouselook)  do
		SetMouselookOverrideBinding(key, nil)
	end
	table.wipe(self.overridden.Mouselook)		-- reset
	
	--[[
	Do not SetMouselookOverrideBinding() on any key that is bound to TURNORACTION, MOVEANDSTEER, TARGETSCANENEMY, TARGETNEARESTENEMY.
	These commands run MouselookStart() when pressed, and MouselookStop() when released.
	Overriding them will cause a different key release handler to be called, missing MouselookStop(),
	and result in stuck Mouselook state.
	--]]
	if  profile.bindings  then  for  key,cmd  in  pairs(profile.bindings)  do
		local  origCmd= GetBindingByKey(key)
		if  cmd == nil  or  cmd == ''	 or  cmd == origCmd		then
			-- ignore
		elseif  origCmd == 'TURNORACTION'  or  origCmd == 'TARGETSCANENEMY'  then
			print('BindBindingOverrides():  '.. key ..' binding to '.. origCmd ..' not overridden with '.. cmd .. ' as it would cause stucking in Combat Mode.')
		else
			if  cmd == 'SMARTTARGETANDINTERACTNPC'  then
				-- SmartTargetingEnabled collects the keys to update for smarttargeting
				-- and enables OnEvent, OnUpdate to update bindings with CombatMode:UpdateSmartTarget()
				SmartTargetingEnabled = SmartTargetingEnabled or {}
				SmartTargetingEnabled[key] = true
				-- smart targeting does Interact when in range with the target, otherwise targets the nearest
				cmd= self:CheckSmartTarget()  and  "INTERACTTARGET"  or  "TARGETNEARESTFRIEND"
			end
			SetMouselookOverrideBinding(key, cmd)
			self.overridden.Mouselook[key]= cmd
		end
	end end
	
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
	The purpose of this is to allow left click to be used for multiple purposes while in Combat Mode.
	--]]
	
	--[[ Dec 10, 2017 by justice7ca
	 I actually ended up handling this slightly differently in 1.2.0.
	 Left click selects friendly by default, if you're within range, it will change to interact for you.
	 If you're out of range, it's back to select friendly.
	 Essentially allowing you to Mouse1 your way to victory while questing / talking to NPC's.
	--]]

	--if  wasMouselooking  then  MouselookStart()  end
end




function CombatMode:EnableWhileMoving()
	local profile= self.db.profile
	return  profile.enableWhileMoving and not IsModifiedClick('CM_DISABLE_MOD')  or  IsModifiedClick('CM_ENABLE_MOD')
end



function CombatMode:CheckSmartTarget()
	return  UnitExists("target")
		and  UnitIsFriend("player", "target")
		and  not UnitPlayerControlled("target")
		and  CheckInteractDistance("target", 3)
end

function CombatMode:UpdateSmartTarget()
	local newInteract= self:CheckSmartTarget()
	if  newInteract == SmartTargetingCanInteract  then  return  end		-- no changes
	SmartTargetingCanInteract = newInteract
	self:BindBindingOverrides()
end




BINDING_NAME_TURNWITHMOUSE = "Turn with mouse, no actions"
local TurnWithMouseKeyRestore

function CombatMode.TurnWithMouseKey(keystate)
	if ( keystate == "down" ) then
		--self.commandsLockingMouse.TurnWithMouse= true
		TurnWithMouseKeyRestore= not IsMouselooking()
		if  TurnWithMouseKeyRestore  then  MouselookStart()  end
	else
		if  TurnWithMouseKeyRestore  then  MouselookStop()  end
		TurnWithMouseKeyRestore= nil
	end
end



