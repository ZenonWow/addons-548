--[[
/dump GetBindingByKey('BUTTON1'), GetBindingByKey('BUTTON2')
Reset to default:
/run CombatMode.ResetMouseButton12Bindings()
/run SetBinding('BUTTON1','CAMERAORSELECTORMOVE');SetBinding('BUTTON2','TURNORACTION')
Additional:
/run SetBinding('BUTTON4','MOVEANDSTEER');SetBinding('BUTTON5','COMBATMODE_ENABLE')
/run SetBinding('ALT-BUTTON4','TOGGLEAUTORUN')
My favourite:
/run SetBinding('BUTTON1','MOVEANDSTEER');SetBinding('ALT-BUTTON1','CAMERAORSELECTORMOVE');SetBinding('BUTTON2','TURNORACTION');SetBinding('BUTTON4','TOGGLEAUTORUN')

/run  ClearOverrideBindings(CombatMode.OverrideFrames.CustomBindings) ; CombatMode.OverrideFrames.CustomBindings.keyMap= nil
/run  ClearOverrideBindings(CombatMode.OverrideFrames.CustomBindings) ; CombatMode.OverrideFrames.CustomBindings.keyMap= nil
/run  SetOverrideBinding(CombatMode.OverrideFrames.CustomBindings, false, 'BUTTON1', nil)
/run  SetOverrideBinding(CombatMode.OverrideFrames.CustomBindings, false, 'BUTTON1', 'TURNORACTION')
/run  CombatMode.OverrideFrames.CustomBindings.keyMap= nil ; CombatMode:UpdateOverrideBindings()
/run  ClearOverrideBindings(CombatMode.OverrideFrames.CustomBindings) ; CombatMode:UpdateOverrideBindings()

Debug:
/dump CombatMode.config.optionsFrame
--]]


-- Addon main: Ace libs, initialization, settings, bindings
local AddonName, Addon = ...
CombatMode = LibStub("AceAddon-3.0"):NewAddon("CombatMode", "AceConsole-3.0", "AceEvent-3.0")

-- Key bindings' labels
BINDING_HEADER_CombatMode= "Combat Mode"
BINDING_NAME_COMBATMODE_ENABLE= "Enable while holding or toggle with click"
BINDING_NAME_COMBATMODE_TOGGLE= "Toggle Combat Mode when clicked"
BINDING_NAME_COMBATMODE_HOLD= "Switch Combat Mode while holding"
--BINDING_NAME_COMBATMODE_HOLDTOGGLE= "Toggle Combat Mode (hold or click)"

CombatMode.enableAllways= false		-- permanent combat mode with no buttons pressed
CombatMode.holdKeyState= nil			-- 'HoldToEnable' or 'HoldToDisable': temporarily change combat mode (if not nil) while bound key/button is pressed
CombatMode.CursorActionActive= false
--local combatModeTemporaryDisable = true		-- combatModeTemporaryDisable is expected to be == not IsMouselooking()
local SmartTargetingEnabled= nil  -- if list of smart interact keys then check periodically (OnUpdate) for target being in interact range
local SmartTargetingCommand= nil  -- default action for SMARTTARGETANDINTERACTNPC: INTERACTTARGET or TARGETNEARESTFRIEND

CombatMode.config= {}
CombatMode.config.settingsDefaults= {
	--global = { version = "1.0.0", },
	profile= {
		enableWhileMoving= true,
		bindings= {  -- 2018-10-21:
			--['BUTTON1']				= "SMARTTARGETANDINTERACTNPC",
			['BUTTON1']				= "MOVEANDSTEER",
			['BUTTON2']				= "TURNORACTION",
			['ALT-BUTTON1']		= "CAMERAORSELECTORMOVE",  -- Rotate Camera (Left Button default),
			['ALT-BUTTON2']		= "TURNORACTION",  -- Turn or Action (Right Button default),
			['SHIFT-BUTTON1'] = "TARGETNEARESTFRIEND",
			['SHIFT-BUTTON2'] = "TARGETNEARESTENEMY",
			['CTRL-BUTTON1']	= "SMARTTARGETANDINTERACTNPC",
			['CTRL-BUTTON2']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			--[[
			['BUTTON1']				= "SMARTTARGETANDINTERACTNPC",
			--['BUTTON1']				= "MOVEANDSTEER",
			['BUTTON2']				= "TARGETSCANENEMY",
			['ALT-BUTTON1']		= "CAMERAORSELECTORMOVE",  -- Rotate Camera (Left Button default),
			['ALT-BUTTON2']		= "TURNORACTION",  -- Turn or Action (Right Button default),
			['SHIFT-BUTTON1'] = "FOCUSMOUSEOVER",
			['SHIFT-BUTTON2'] = "TARGETNEARESTENEMY",
			['CTRL-BUTTON1']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			['CTRL-BUTTON2']	= "SMARTTARGETANDINTERACTNPC",
			--]]
			--[[
			['SHIFT-BUTTON1'] = "TARGETMOUSEOVER",
			['SHIFT-BUTTON2'] = "FOCUSMOUSEOVER",
			['SHIFT-BUTTON1'] = "TARGETPREVIOUSFRIEND",
			['CTRL-BUTTON1']	= "TARGETNEARESTFRIEND",
			['CTRL-BUTTON2']	= "INTERACTTARGET",
			--]]
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
        InterfaceOptionsFrame_OpenToCategory(self.config.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("cm", "CombatMode", input)
    end
end


function CombatMode:OnInitialize()

	self:LogInit('  CombatMode:OnInitialize()')
	self.commands:HookCommands()
	--self:HookUpFrames()		-- is it necessary before OnEnable() calling it again?
	self:RegisterChatCommand("cm", "ChatCommand")
	self:RegisterChatCommand("combatmode", "ChatCommand")
	
	--[[
	Use one profile called 'Default' for all characters originally
	Name of default profile can be changed with setting  profileKeys['default']
	To have character-specific profiles when creating/initializing a new character
	/run  CombatModeDB.profileKeys['default']= false
	--]]
	local defaultProfile= CombatModeDB  and  CombatModeDB.profileKeys  and  CombatModeDB.profileKeys.default
	if  defaultProfile == nil  then  defaultProfile= true  end		-- false to have character-specific profiles
	self.db = LibStub("AceDB-3.0"):New("CombatModeDB", self.config.settingsDefaults, defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	--self.db.RegisterCallback(self, "OnDatabaseShutdown", "OnDisable")
	
	--self.config:InitCommandLabels()
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
	self:LogInit('  CombatMode:OnEnable()')
	--self:HookUpFrames()
	-- Register Events
	-- find missing frames when delayed loading any addon
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('CURSOR_UPDATE', CombatMode_OnEvent)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', CombatMode_OnEvent)
	self:RegisterEvent('QUEST_PROGRESS', CombatMode_OnEvent)
	self:RegisterEvent('QUEST_FINISHED', CombatMode_OnEvent)
	--[[
	self:RegisterEvent('PET_BAR_UPDATE', CombatMode_OnEvent)
	self:RegisterEvent('ACTIONBAR_UPDATE_STATE', CombatMode_OnEvent)
	self:RegisterEvent('CURSOR_UPDATE')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('PET_BAR_UPDATE')
	self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
	self:RegisterEvent('QUEST_PROGRESS')
	self:RegisterEvent('QUEST_FINISHED')
	--]]
end

function CombatMode:OnDisable()
	self:LogInit('  CombatMode:OnDisable()')
	-- Called when the addon is disabled
	self:UnregisterEvent('CURSOR_UPDATE')
	self:UnregisterEvent('PLAYER_TARGET_CHANGED')
	self:UnregisterEvent('PET_BAR_UPDATE')
	self:UnregisterEvent('ACTIONBAR_UPDATE_STATE')
	self:UnregisterEvent('QUEST_PROGRESS')
	self:UnregisterEvent('QUEST_FINISHED')
end

function CombatMode:PLAYER_LOGIN(event)
	-- run once per session (/reload) before PLAYER_ENTERING_WORLD
	-- frame sizes and positions are loaded before this event
	self:LogInit('  CombatMode:PLAYER_LOGIN()')
	self:HookUpFrames()
	
	self:UnregisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('ADDON_LOADED')
end

function CombatMode:ADDON_LOADED(event, addonName)
	-- registered for event after PLAYER_LOGIN fires:
	-- static loaded addons already received it
	-- only delayed-load addons will trigger
	-- ex.: Blizzard_BindingUI -> KeyBindingFrame
	self:LogInit('  CombatMode:ADDON_LOADED('.. self.colors.green .. addonName ..'|r)')
	self:HookUpFrames()
end

function CombatMode:ProfileChanged()
	self.config:MigrateSettings()
	-- on-load value of enableWhileMoving
	--self.enableWhileMoving= self.db.profile.enableWhileMoving
	self:UpdateEnableModifiers()
	self:SetEnableWhileMoving(self.db.profile.enableWhileMoving)
	-- SmartTargeting, OverrideCommands
	self:UpdateOverrideBindings()
end



-- Builtin commands
BINDING_NAME_CAMERAORSELECTORMOVE 			= "Rotate Camera (Left Button default)"			-- targeting  or  camera rotation, original binding of BUTTON1
BINDING_NAME_TURNORACTION 							= "Turn or Action (Right Button default)"		-- the original binding of BUTTON2
-- Custom commands
BINDING_NAME_SMARTTARGETANDINTERACTNPC 	= "Smart Target: target and interact closest friendly npc"
BINDING_NAME_FOCUSMOUSEOVER 						= "Focus Mouseover"		-- no turning or camera


CombatMode.config.modifierKeys = { '', 'SHIFT', 'CTRL', 'ALT' }

--[[ Commands vocabulary:
turning (character with mouse) = CombatMode (term from GuildWars2 community) = Mouselook (term from Blizzard - Wow lua api)
camera (rotation) = look around with mouse, like turning, but the character does not move / change direction
	- only possible with CAMERAORSELECTORMOVE command and disabled CombatMode
--]]
CombatMode.config.commands = { 
		'',		-- don't override --
		
		'CAMERAORSELECTORMOVE',			-- Left Button default:  rotate camera or target mouseover.  Must disable Mouselook when pressed, otherwise it acts as MoveAndSteer.
		'TURNORACTION',							-- Right Button default:  Mouselook if hold, InteractMouseover if clicked
		'TURNWITHMOUSE',						-- Turn with mouse, no actions
		
		-- Interact
		'INTERACTMOUSEOVER',				-- select with mouse + interact, no turning or camera
		-- hook mouse button directly to disable Mouselook while pressed
		-- or override with COMBATMODE_DISABLE/COMBATMODE_HOLD
		'INTERACTTARGET',						-- no select, only interact
		-- any valid use-cases for this in CombatMode?
		
		-- Target (select with mouse)
		'SMARTTARGETANDINTERACTNPC',	-- could override INTERACTMOUSEOVER instead: without cursor (in CombatMode) it has no effect
		'TARGETSCANENEMY',						-- target npc/player in crosshair (middle of screen), can be far away, with turning/lock (Mouselook)
		'TARGETNEARESTENEMY',					-- target nearest, no turning
		                            
		'TARGETMOUSEOVER',						-- no turning or camera -> hook mouse button directly to disable Mouselook while pressed
		'FOCUSMOUSEOVER',							-- no turning or camera
    
		-- Target Nearest (tab targeting, no turning or camera, mouse influences direction to look for the nearest)
		'TARGETNEARESTFRIENDPLAYER',
		'TARGETNEARESTENEMYPLAYER',
		'TARGETNEARESTFRIEND',				-- SmartTarget uses it; this one is less useful, candidate for removal
		'TARGETPREVIOUSFRIEND',
		
		-- Move
		'MOVEANDSTEER',
		'TOGGLEAUTORUN',
		
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


CombatMode.config.commandLabelsCustom = {
		[''] 													= "-- don't override --",
		--[[
		['CAMERAORSELECTORMOVE'] 			= "Rotate Camera",		-- targeting  or  camera rotation, original binding of BUTTON1
		['TURNORACTION'] 							= "Turn or Action",		-- the original binding of BUTTON2
		['SMARTTARGETANDINTERACTNPC'] = "Smart Target: target and interact closest friendly npc",
		['FOCUSMOUSEOVER'] 						= "Focus Mouseover",	-- no turning or camera
		--]]
}

function CombatMode.config:GetCommandLabel(command)
	return self.commandLabelsCustom[command]  or  _G['BINDING_NAME_'.. command]  or  command
end

function CombatMode.config:InitCommandLabels()
	if  self.commandLabels  then  return self.commandLabels  end
	self.commandLabels= {}
	for  i,command  in  ipairs(self.commands)  do
		local label= self:GetCommandLabel(command)
		table.insert(self.commandLabels, label)
	end
	return self.commandLabels
end

--CombatMode.config:InitCommandLabels()



local optCnt= 0
local function opt(key, name, desc, defValues)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "select",
		--width = "full",
		values = defValues or CombatMode.config:InitCommandLabels(),
		get = function()
			local value= CombatMode.db.profile.bindings[key]
			return  Addon.tableProto.indexOf(CombatMode.config.commands, value)
		end,
		set = function(info, idx)
			local value= CombatMode.config.commands[idx]
			CombatMode.db.profile.bindings[key]= value ~= '' and value or nil
			CombatMode:UpdateOverrideBindings()
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
			CombatMode:UpdateEnableModifiers()
		end,
	}
	CombatMode.config.optionsTable.args[key]= optInfo
	return optInfo
end

local function optMoving(key, name, desc)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "toggle",
		--width = "full",
		get = function()  return CombatMode.db.profile[key]  end,
		set = function(info, value)
			CombatMode.db.profile[key]= value
			CombatMode:SetEnableWhileMoving(value)
		end,
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
	opt("ALT-BUTTON1", "Alt + Left Click"),
	opt("ALT-BUTTON2", "Alt + Right Click"),
	opt("SHIFT-BUTTON1", "Shift + Left Click"),
	opt("SHIFT-BUTTON2", "Shift + Right Click"),
	opt("CTRL-BUTTON1", "Control + Left Click"),
	opt("CTRL-BUTTON2", "Control + Right Click"),
	optMoving("enableWhileMoving", "Enable while moving", "While pressing any movement key CombatMode is enabled"),
	optMod("CM_ENABLE_MOD", "Enable with this modifier while moving:", "While pressing this modifier and any movement key CombatMode is enabled"),
	optMod("CM_DISABLE_MOD", "Disable with this modifier while moving:", "While pressing this modifier and any movement key CombatMode is disabled"),
	--opt("smarttargeting", "Smart Targeting", "Buttons that target the closest friendly NPC and interact with it if close enough", SmartTargetValues),
}



function CombatMode.ResetMouseButton12Bindings()
	SetBinding('BUTTON1','CAMERAORSELECTORMOVE')
	SetBinding('BUTTON2','TURNORACTION')
	SetBinding('ALT-BUTTON1',nil)
	SetBinding('ALT-BUTTON2',nil)
	SetBinding('CTRL-BUTTON1',nil)
	SetBinding('CTRL-BUTTON2',nil)
	SetBinding('SHIFT-BUTTON1',nil)
	SetBinding('SHIFT-BUTTON2',nil)
end


local function SetBindings(keys, command)
	for  i,key  in  ipairs(keys)  do
		SetBinding(key, command)
	end
	local name= _G['BINDING_NAME_'.. command]  or  command
	print('CombatMode updating binding  "'.. name ..'":  '.. table.concat(keys, ', '))
end


function CombatMode.config:MigrateSettings()
	CombatMode.db.profile.bindings  = CombatMode.db.profile.bindings  or {}
	CombatMode.db.profile.modifiers = CombatMode.db.profile.modifiers or {}
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




CombatMode.OverrideCommands = {
	CombatMode = {
	--[[ Override MOVEANDSTEER with MOVEFORWARD in CombatMode (not Mouselook).
	Overriding when MoveAndSteer is pressed (Mouselook is temporary) would cause
	not running the MoveAndSteerStop() key release handler, resulting in stuck Mouselook.
	MoveAndSteerStop()  calls  MouselookStop()  on release, disabling Mouselook.
	UpdateMouselook()  re-enables Mouselook, but causes a MouselookStop() -> MouselookStart()  transient.
	If this causes any bugs, then override MoveAndSteer to MoveForward to remove the transient.
	--]]
		MoveAndSteer = 'MoveForward',
		--CameraOrSelectOrMove = 'TargetNearestFriend',
		--TurnOrAction = 'TargetNearestEnemy',
	},
	AutoRun = {
    --[[ Right Click (MoveAndSteerStop()) would stop AutoRun,
    which is very disturbing when steering with AutoRun.
    Revert to TurnOrAction to fix this annoyance.
    --]]
		MoveAndSteer = 'TurnOrAction',
	},
	Mouselook = {
		InteractMouseover = 'CombatMode_Hold',
	},
	--[[
	SmartTarget = {
		InteractTarget = 'TargetNearestFriend',
		--InteractMouseover = 'TargetNearestFriend',
		--TargetNearestFriend = 'TargetNearestFriend',
		--TargetNearestEnemy = 'TargetNearestEnemy',
	},
	SmartInteract = {
		InteractTarget = 'InteractTarget',
		--InteractMouseover = 'InteractTarget',
		--TargetNearestFriend = 'InteractTarget',
		--TargetNearestEnemy = 'InteractTarget',
	},
	--]]
}



CombatMode.OverrideFrames = { CustomBindings = CreateFrame("Frame"), CombatMode = CreateFrame("Frame"), AutoRun = CreateFrame("Frame"), Mouselook = {} }
CombatMode.OverrideFrames.CustomBindings.overrideWhen = 'CustomBindings'
CombatMode.OverrideFrames.CombatMode.overrideWhen = 'CombatMode'
CombatMode.OverrideFrames.AutoRun.overrideWhen = 'AutoRun'
CombatMode.OverrideFrames.Mouselook.overrideWhen = 'Mouselook'

function CombatMode.OverrideFrames.CustomBindings:BindKeys(newKeyMap)
	local frame= self
	local oldKeyMap = self.keyMap  or  {}
	newKeyMap = newKeyMap  or  {}
	
	-- Remove previous overrides
	ClearOverrideBindings(self)
	--[[
	for  key,cmd  in  pairs(oldKeyMap)  do  if  newKeyMap[key] == nil  then
		-- Remove previous overrides
		SetOverrideBinding(frame, false, key, nil)
	end end
	--]]
	
	SmartTargetingEnabled= nil		-- reset
  SmartTargetingCommand= GetCVarBool('interactOnLeftClick')  and  "INTERACTTARGET"  or  "TARGETNEARESTFRIEND"
  
	for  key,cmd  in  pairs(newKeyMap)  do  --if  oldKeyMap[key] ~= cmd  then
    if  cmd == 'SMARTTARGETANDINTERACTNPC'  then
      -- SmartTargetingEnabled collects the keys to update for smarttargeting
      -- and enables OnEvent, OnUpdate to update bindings with CombatMode:UpdateSmartTarget()
      SmartTargetingEnabled = SmartTargetingEnabled or {}
      -- smart targeting does Interact when in range with the target, otherwise targets the nearest
      cmd= SmartTargetingCommand
      SmartTargetingEnabled[key] = cmd
    end
    
		-- Set new overrides
		SetOverrideBinding(frame, false, key, cmd)
	end --end
	
	-- Make it nil if empty
	--if  not next(newKeyMap)  then  newKeyMap= nil  end
	-- Save overridden keys
	self.keyMap= newKeyMap
	
	if  SmartTargetingEnabled  then  CombatMode:UpdateSmartTarget()  end
	
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
end


function CombatMode.OverrideFrames.CombatMode:BindCmdKeys(fromCmd, toCmd)
	local frame= self
	local fromUpper, toUpper= fromCmd:upper(), toCmd:upper()
	frame.cmdKeys= frame.cmdKeys  or  {}
	-- Previously overridden keys
	local oldKeys= frame.cmdKeys[fromCmd]  or  {}
	-- Keys to override now
	local newKeys= { GetBindingKey(fromUpper) }
	
	for  i,key  in  ipairs(oldKeys)  do
		-- Remove previous overrides
		SetOverrideBinding(frame, false, key, nil)
	end
	
	local priority = false  -- (self.overrideWhen == 'AutoRun')
	for  i,key  in  ipairs(newKeys)  do
		-- Set new overrides
		SetOverrideBinding(frame, priority, key, toUpper)
	end
	
	-- Make it nil if empty
	if  not next(newKeys)  then  newKeys= nil  end
	-- Save overridden keys
	frame.cmdKeys[fromCmd]= newKeys
end

function CombatMode.OverrideFrames.CombatMode:BindCmdOverrides(cmdMap)
  for  fromCmd, toCmd  in  pairs(cmdMap)  do
    self:BindCmdKeys(fromCmd, toCmd)
  end
end


function CombatMode.OverrideFrames.Mouselook:BindCmdKeys(fromCmd, toCmd)
	local fromUpper, toUpper= fromCmd:upper(), toCmd:upper()
	--[[
	Do not SetMouselookOverrideBinding() on any key that is bound to TURNORACTION, MOVEANDSTEER, TARGETSCANENEMY, TARGETNEARESTENEMY.
	These commands run MouselookStart() when pressed, and MouselookStop() when released.
	Overriding them will cause a different key release handler to be called, missing MouselookStop(),
	and result in stuck Mouselook state.
	--]]
	if  fromUpper == 'TURNORACTION'  or  fromUpper == 'TARGETSCANENEMY'  then
    print('CombatMode.OverrideFrames.Mouselook:BindCmdKeys():  overriding bindings of '.. fromCmd ..' to '.. toCmd ..' not possible, as it would cause stucking in Combat Mode.')
    return false
  end
  
	self.cmdKeys= self.cmdKeys  or  {}
	local oldKeys= self.cmdKeys[fromCmd]  or  {}
	local newKeys= { GetBindingKey(fromUpper) }
	
	for  key,_  in  pairs(oldKeys)  do
		-- Remove previous overrides
		SetMouselookOverrideBinding(key, nil)
	end
	
	for  key,_  in  pairs(newKeys)  do
		-- New overrides
		SetMouselookOverrideBinding(key, toUpper)
	end
	-- Make it nil if empty
	if  not next(newKeys)  then  newKeys= nil  end
	
	self.cmdKeys[fromCmd]= newKeys
end	



function CombatMode.OverrideFrames.CombatMode:EnableOverrides(enable)
  CombatMode:LogState('  ...' .. self.overrideWhen .. ':EnableOverrides(' .. Addon.colorBoolStr(enable, true) .. ')')
  self:SetShown(enable)
end

CombatMode.OverrideFrames.CustomBindings.EnableOverrides = CombatMode.OverrideFrames.CombatMode.EnableOverrides
CombatMode.OverrideFrames.CustomBindings.DisableOverrides = CombatMode.OverrideFrames.CombatMode.DisableOverrides

CombatMode.OverrideFrames.AutoRun.BindCmdKeys = CombatMode.OverrideFrames.CombatMode.BindCmdKeys
CombatMode.OverrideFrames.AutoRun.BindCmdOverrides = CombatMode.OverrideFrames.CombatMode.BindCmdOverrides
CombatMode.OverrideFrames.AutoRun.EnableOverrides = CombatMode.OverrideFrames.CombatMode.EnableOverrides
CombatMode.OverrideFrames.AutoRun.DisableOverrides = CombatMode.OverrideFrames.CombatMode.DisableOverrides

CombatMode.OverrideFrames.Mouselook.BindCmdOverrides = CombatMode.OverrideFrames.CombatMode.BindCmdOverrides

CombatMode.OverrideFrames.CombatMode:Hide()
CombatMode.OverrideFrames.AutoRun:Hide()
CombatMode.OverrideFrames.CustomBindings:Show()
--[[
CombatMode.OverrideFrames.CustomBindings:EnableOverrides(true)  -- Addon.colorBoolStr() not defined yet, would crash silently
CombatMode.OverrideFrames.CombatMode:DisableOverrides()
CombatMode.OverrideFrames.AutoRun:DisableOverrides()
--]]

--[[
/dump  CombatMode.OverrideFrames.CustomBindings.keyMap
/dump  CombatMode.OverrideFrames.AutoRun.cmdKeys
/dump  CombatMode.OverrideFrames.CombatMode.cmdKeys
/dump  CombatMode.OverrideFrames.Mouselook.cmdKeys
--]]

--[[
/run  SetBinding('BUTTON2', 'MOVEANDSTEER')
/run  SetOverrideBinding(CombatMode.OverrideFrames.CombatMode, false, 'BUTTON2', 'MOVEANDSTEER')
/run  SetOverrideBinding(CombatMode.OverrideFrames.AutoRun, false, 'BUTTON2', nil)
/run  SetMouselookOverrideBinding('X', 'COMBATMODE_HOLD')
/run  SetMouselookOverrideBinding('X')
/run  CombatMode.OverrideFrames.CombatMode:Show()
/run  CombatMode.OverrideFrames.CombatMode:EnableOverrides(true)
/run  CombatMode.OverrideFrames.AutoRun:EnableOverrides(true)
--]]



function CombatMode:UpdateOverrideBindings()
	--[[
	MouselookStop() won't interrupt command keys that are pressed, i.e. received "down" event, but not "up"
	Those commands will not run for the "up" event if their binding is changed, instead
	the new binding will receive the "up" event without a "down" event.
	This results in unexpectedly entering or leaving CombatMode when rebinding a command that changes CombatMode.
	--]]
	local wasMouselooking= IsMouselooking()
	if  wasMouselooking  then
    CombatMode:LogAnomaly('CombatMode:UpdateOverrideBindings() while IsMouselooking() could cause stuck keys, not updating bindings.')
    return
    --CombatMode:LogAnomaly('CombatMode:UpdateOverrideBindings() while IsMouselooking() could cause stuck keys, temporarily disabling Mouselook.')
    --MouselookStop()
	end
	
	local profile= CombatMode.db.profile
	CombatMode.OverrideFrames.CustomBindings:BindKeys(profile.bindings)
	CombatMode.OverrideFrames.CombatMode:BindCmdOverrides(CombatMode.OverrideCommands.CombatMode)
	CombatMode.OverrideFrames.AutoRun:BindCmdOverrides(CombatMode.OverrideCommands.AutoRun)
	CombatMode.OverrideFrames.Mouselook:BindCmdOverrides(CombatMode.OverrideCommands.Mouselook)
	--CombatMode.OverrideFrames.CombatMode:BindCmdKeys('MoveAndSteer', 'MoveForward')
	--CombatMode.OverrideFrames.AutoRun:BindCmdKeys('MoveAndSteer', 'TurnOrAction')
	--CombatMode.OverrideFrames.Mouselook:BindCmdKeys('InteractMouseover', 'CombatMode_Disable')

	-- Modifiers (SHIFT/CTRL/ALT) to turn on/off EnableWhileMoving()
	if  profile.modifiers  then  for  key,binding  in  pairs(profile.modifiers)  do
		SetModifiedClick(key,binding)
	end end

	if  wasMouselooking  then
    --CombatMode:LogAnomaly('CombatMode:UpdateOverrideBindings() restoring Mouselook.')
    MouselookStop()
	end
end




--[[   Simple EnableWhileMoving()   ]]--
function CombatMode:EnableWhileMoving()
	return  self.enableWhileMoving  and  not self.IsDisableModifierPressed()  or  self.IsEnableModifierPressed()
	--return  self.enableWhileMoving  and  not IsModifiedClick('CM_DISABLE_MOD')  or  IsModifiedClick('CM_ENABLE_MOD')
end

function CombatMode:SetEnableWhileMoving(enable)
	self.enableWhileMoving= enable
end

function CombatMode:SetEnableAllways(enable)
  if  self.enableAllways == enable  then  return  end
	self.enableAllways= enable
  self.OverrideFrames.CombatMode:EnableOverrides(enable)
end


local falseFunc= function ()  return false  end
local trueFunc=  function ()  return true  end
local isModifierPressedFunc= {
	SHIFT = IsShiftKeyPressed,
	CTRL = IsCtrlKeyPressed,
	ALT = IsAltKeyPressed,
}

function CombatMode:UpdateEnableModifiers()
	self.IsEnableModifierPressed  = isModifierPressedFunc[ self.db.profile.modifiers.CM_ENABLE_MOD ]  or  falseFunc
	self.IsDisableModifierPressed = isModifierPressedFunc[ self.db.profile.modifiers.CM_DISABLE_MOD ]  or  falseFunc
end	

--[[ Experiment: Optimized EnableWhileMoving with complex setup
function CombatMode:UpdateEnableModifiers()
	-- Make a closure with the above calculated values.
	-- This is just for experimenting with alternative designs:
	-- overriding SetEnableWhileMoving and EnableWhileMoving is confusing.
	function CombatMode:SetEnableWhileMoving(enable)
		self.enableWhileMoving= enable
		self.EnableWhileMoving= enable  and  self.IsNotDisableModifierPressed  or  self.IsEnableModifierPressed
	end
	self.IsNotDisableModifierPressed=  IsDisableModifierPressed == falseFunc  and  trueFunc  or  function () return not IsDisableModifierPressed() end
	CombatMode:SetEnableWhileMoving(self.enableWhileMoving)
end
--]]




function CombatMode:CheckSmartTarget()
	return  UnitExists("target")
		and  UnitIsFriend("player", "target")
		and  not UnitPlayerControlled("target")
		and  CheckInteractDistance("target", 3)
end

function CombatMode:UpdateSmartTarget()
	local cmd= self:CheckSmartTarget()  and  "INTERACTTARGET"  or  "TARGETNEARESTFRIEND"
	if  cmd == SmartTargetingCommand  then  return  end		-- no changes
	for  key,oldCmd  in  pairs(SmartTargetingEnabled)  do
		SetOverrideBinding(CombatMode.OverrideFrames.CustomBindings, false, key, cmd)
    SmartTargetingEnabled[key] = cmd
  end
	SmartTargetingCommand = cmd
end



