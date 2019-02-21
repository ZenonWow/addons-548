--[[
	Name alternatives:
CursorMode (normal) / LookAroundMode (LeftButton) / MouselookMode (RightButton).
ActionMode = MouselookMode without pressing RightButton. Riding the hypetrain of ActionCombat (not in wow...) and ActionCamera (this is a thing, try DynamicCam addon, will change your life).
ActionCameraMode? ?? (as opposite of FreeCameraMode makes sense)
FreeCameraMode = LookAroundMode = CameraMode
MouseCursorMode = FreeCursorMode = CursorMode, for short.

Actually you can be in CursorMode while in ActionMode by pressing RightButton.
Pressing LeftButton will go into CameraMode or start moving (MoveAndSteer) in ActionMode,
depending on the setting of ActionModeMoveWithButton1.

CombatMode
CameraMode
MouseCameraMode-MouseCursorMode-MouselookMode
Mouselook
https://en.wikipedia.org/wiki/Free_look

	Inspired by:
Immersive Combat Mode for Guild Wars 2    http://wesslen.org/ICM/
CombatMode addon
CombatMode Reborn addon
Mouse_Look_Lock    https://github.com/DWishR/Mouse-Look-Lock
MouselookHandler    https://github.com/meribold/MouselookHandler

https://www.wowinterface.com/downloads/info24776-CombatModeReborn.html
https://wow.curseforge.com/projects/combat-mode
https://wow.curseforge.com/projects/mouse-look-lock
-- It also causes the mouse buttons to remap to movement (forward and backward) keys to match the configuration found in Dark Age of Camelot.
https://wow.curseforge.com/projects/kiki-utils
-- Mouselook : Real DAoC mouse look mode. Key1 switch to and from Mouselook on each press. Hold Key2 to move the camera (when in Mouselook mode). In Mouselook mode, Button1 and Button2 are remapped to MoveForward and MoveBackward. Mouselook mode does NOT break follow mode.
https://wow.curseforge.com/projects/mouselookhandler
https://wow.curseforge.com/projects/mouselook
https://wow.curseforge.com/projects/mouselook-binding
https://wow.curseforge.com/projects/mouse-combat
--]]

--[[
/targetenemy [noharm][dead]
/target[harm][dead]
-> InteractTarget -> loot?

/dump GetBindingByKey('BUTTON1'), GetBindingByKey('BUTTON2')
/dump GetBindingKey('CAMERAORSELECTORMOVE'), GetBindingKey('TURNORACTION'), GetBindingKey('TARGETNEARESTFRIEND')
Reset to default:
/run CombatMode.ResetMouseButton12Bindings()
/run SetBinding('BUTTON1','CAMERAORSELECTORMOVE');SetBinding('BUTTON2','TURNORACTION')
Additional:
/run SetBinding('BUTTON4','MOVEANDSTEER');SetBinding('BUTTON5','COMBATMODE_ENABLE')
/run SetBinding('ALT-BUTTON4','TOGGLEAUTORUN')
My favourite:
/run SetBinding('BUTTON1','MOVEANDSTEER');SetBinding('ALT-BUTTON1','CAMERAORSELECTORMOVE');SetBinding('BUTTON2','TURNORACTION');SetBinding('BUTTON4','TOGGLEAUTORUN')

/run  ClearOverrideBindings(CombatMode.CustomBindings) ; CombatMode.CustomBindings.keyMap= nil
/run  ClearOverrideBindings(CombatMode.CustomBindings) ; CombatMode.CustomBindings.keyMap= nil
/run  SetOverrideBinding(CombatMode.CustomBindings, false, 'BUTTON1', nil)
/run  SetOverrideBinding(CombatMode.CustomBindings, false, 'BUTTON1', 'TURNORACTION')
/run  CombatMode.CustomBindings.keyMap= nil ; CombatMode.CustomBindings:Update()
/run  ClearOverrideBindings(CombatMode.CustomBindings) ; CombatMode.CustomBindings:Update()

Debug:
/dump CombatMode.config.optionsFrame
--]]


-- _ADDON main: Ace libs, initialization, settings, bindings
local _G, ADDON_NAME, _ADDON = _G, ...
local CombatMode = LibStub("AceAddon-3.0"):NewAddon("CombatMode", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
_G.CombatMode = CombatMode

local pairsOrOne,ipairsOrOne,packOrOne = LibCommon:Import("pairsOrOne,ipairsOrOne,packOrOne", CombatMode)


-- Key bindings' labels
BINDING_HEADER_CombatMode= "Combat Mode"
BINDING_NAME_COMBATMODE_ENABLE= "Enable Action mode"
BINDING_NAME_COMBATMODE_TOGGLE= "Toggle Action mode"

-- Builtin commands
BINDING_NAME_CAMERAORSELECTORMOVE 			= "Rotate Camera (Left Button default)"			-- targeting  or  camera rotation, original binding of BUTTON1
BINDING_NAME_TURNORACTION 							= "Turn or Action (Right Button default)"		-- the original binding of BUTTON2
-- Custom commands
BINDING_NAME_SMARTTARGETANDINTERACTNPC 	= "Smart Target: target and interact closest friendly npc"

local FocusMouseoverBinding = 'BINDING_NAME_CLICK FocusMouseoverButton:LeftButton'

do
	-- BINDING_NAME_FOCUSMOUSEOVER 						= "Focus Mouseover"		-- no turning or camera
	_G[FocusMouseoverBinding] = "Focus Mouseover"
	local FocusMouseoverButton = CreateFrame('Button', 'FocusMouseoverButton', UIParent, 'SecureActionButtonTemplate')
	FocusMouseoverButton:SetAttribute('type', 'macro')
	FocusMouseoverButton:SetAttribute('macrotext', '/focus mouseover')
end


-- Init state:
CombatMode.enabledActionMode= nil
CombatMode.enabledOverride= nil
--local combatModeTemporaryDisable = true		-- combatModeTemporaryDisable is expected to be == not IsMouselooking()
CombatMode.BoundCommand= 'TARGETNEARESTFRIEND'  -- default action for TARGETNEARESTANDINTERACTNPC: INTERACTTARGET or TARGETNEARESTFRIEND


---------------------------
-- Default configuration
---------------------------

CombatMode.config= {}
CombatMode.config.settingsDefaults= {
	--global = { version = "1.0.0", },
	profile= {
		enabledOnLogin= false,
		enabledWhileMoving= false,
		enableWithBothButtons= true,
		enableWithMoveAndSteer= true,
		disableWithLookAround= true,
		ActionModeMoveWithButton1= false,
		bindings= {  -- 2018-10-21:
			--['BUTTON1']				= "TARGETNEARESTANDINTERACTNPC",
			['BUTTON1']				= "CAMERAORSELECTORMOVE",  -- Rotate Camera (LeftButton default),
			['BUTTON2']				= "TURNORACTION",  -- Turn or Action (RightButton default),
			['ALT-BUTTON1']		= "MOVEANDSTEER",
			['ALT-BUTTON2']		= "AUTORUN",
			['SHIFT-BUTTON1'] = "STRAFELEFT",
			['SHIFT-BUTTON2'] = "STRAFERIGHT",
			['CTRL-BUTTON1']	= "TARGETNEARESTANDINTERACTNPC",
			['CTRL-BUTTON2']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			--[[
			['BUTTON1']				= "MOVEANDSTEER",
			['BUTTON2']				= "TURNORACTION",
			['ALT-BUTTON1']		= "CAMERAORSELECTORMOVE",  -- Rotate Camera (LeftButton default),
			['ALT-BUTTON2']		= "TURNORACTION",  -- Turn or Action (RightButton default),
			['SHIFT-BUTTON1'] = "TARGETNEARESTFRIEND",
			['SHIFT-BUTTON2'] = "TARGETNEARESTENEMY",
			['CTRL-BUTTON1']	= "TARGETNEARESTANDINTERACTNPC",
			['CTRL-BUTTON2']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			--]]
			--[[
			['BUTTON1']				= "TARGETNEARESTANDINTERACTNPC",
			--['BUTTON1']				= "MOVEANDSTEER",
			['BUTTON2']				= "TARGETSCANENEMY",
			['ALT-BUTTON1']		= "CAMERAORSELECTORMOVE",  -- Rotate Camera (LeftButton default),
			['ALT-BUTTON2']		= "TURNORACTION",  -- Turn or Action (RightButton default),
			['SHIFT-BUTTON1'] = FocusMouseoverBinding,
			['SHIFT-BUTTON2'] = "TARGETNEARESTENEMY",
			['CTRL-BUTTON1']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			['CTRL-BUTTON2']	= "TARGETNEARESTANDINTERACTNPC",
			--]]
			--[[
			['SHIFT-BUTTON1'] = "TARGETMOUSEOVER",
			['SHIFT-BUTTON2'] = FocusMouseoverBinding,
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
		-- or override with COMBATMODE_DISABLE
		'INTERACTTARGET',						-- no select, only interact
		-- any valid use-cases for this in CombatMode?

		-- Target (select with mouse)
		'TARGETNEARESTANDINTERACTNPC',	-- could override INTERACTMOUSEOVER instead: without cursor (in CombatMode) it has no effect
		'TARGETSCANENEMY',						-- target npc/player in crosshair (middle of screen), can be far away, with turning/lock (Mouselook)
		'TARGETNEARESTENEMY',					-- target nearest, no turning

		'TARGETMOUSEOVER',						-- no turning or camera -> hook mouse button directly to disable Mouselook while pressed
		FocusMouseoverBinding,							-- no turning or camera

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
		['TARGETNEARESTANDINTERACTNPC'] = "Target and interact closest friendly npc",
		[FocusMouseoverBinding] 						= "Focus Mouseover",	-- no turning or camera
		--]]
}




----------------------
-- Common functions
----------------------

--[[ Change colors used in logging
/run CombatMode.colors['nil']= CombatMode.colors.blue
/run CombatMode.colors[false]= CombatMode.colors.blue
/run CombatMode.colors[true]= CombatMode.colors.green
/run CombatMode.colors.enabledActionMode = CombatMode.colors.orange
--]]
CombatMode.colors = {
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
local colors = CombatMode.colors
colors['nil']			= colors.lightblue
colors[false]			= colors.lightblue
colors[true]			= colors.green
colors.missedup		= colors.orange
colors.up					= colors.orange
colors.down				= colors.green		--colors.purple
colors.show				= colors.green
colors.hide				= colors.lightblue
colors.event			= colors.lightgreen
colors.enabledActionMode    = colors.orange
colors.Mouselook          = colors.yellow

function CombatMode.colorBoolStr(value, withColor)
	local boolStr=  value == true and 'ON'  or  value == false and 'OFF'  or  tostring(value)
	if  withColor == true  then  withColor= CombatMode.colors[value == nil  and  'nil'  or  value]  end
	return  withColor  and  withColor .. boolStr .. CombatMode.colors.restore  or  boolStr
end
local colorBoolStr = CombatMode.colorBoolStr


function CombatMode:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.config.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.config.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("cm", "CombatMode", input)
    end
end




------------
-- Events
------------

function CombatMode:OnInitialize()
	-- Run on own ADDON_LOADED event
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
	local defaultProfile= CombatModeDB  and  CombatModeDB.profileKeys  and  CombatModeDB.profileKeys.Default
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


function CombatMode:OnEnable()
	-- Run on PLAYER_LOGIN, before PLAYER_ENTERING_WORLD
	-- frame sizes and positions are loaded before this event
	self:LogInit('  CombatMode:OnEnable()')

	-- Do self.SmartInteract:Enable(true)
	-- self:UpdateOverrideBindings()

	-- Find frames now.
	self:HookUpFrames()
	-- Find missing frames when delayed loading any addon.
	self:RegisterEvent('ADDON_LOADED')

	-- Disable OverrideBindings before combat.
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	-- Monitor Shift/Ctrl/Alt.
	self:RegisterEvent('MODIFIER_STATE_CHANGED')

	-- Targeting and questing shows cursor.
	self:RegisterEvent('CURSOR_UPDATE')
	self:RegisterEvent('QUEST_PROGRESS')
	self:RegisterEvent('QUEST_FINISHED')
	-- self:RegisterEvent('PET_BAR_UPDATE')
	-- self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
end

function CombatMode:OnDisable()
	self:LogInit('  CombatMode:OnDisable()')
	-- Called when the addon is disabled

	self.enabledActionMode = false
	self.enabledOverride = nil

	self:UnregisterEvent('ADDON_LOADED')
	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:UnregisterEvent('MODIFIER_STATE_CHANGED')

	self:UnregisterEvent('CURSOR_UPDATE')
	self:UnregisterEvent('QUEST_PROGRESS')
	self:UnregisterEvent('QUEST_FINISHED')
	-- self:UnregisterEvent('PET_BAR_UPDATE')
	-- self:UnregisterEvent('ACTIONBAR_UPDATE_STATE')

	self.SmartInteract:Enable(false)
	self.SmartInteract:UnregisterEvent('PLAYER_REGEN_ENABLED')
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
	-- self:UpdateEnableModifiers()
	-- SmartTargeting, OverrideCommands
	self.CustomBindings:Update()
end




------------------
-- Enable state
------------------

function CombatMode:IsEnabledWhileMoving()  return self.db.profile.enabledWhileMoving  end
function CombatMode:SetEnabledWhileMoving(enable)  self.db.profile.enabledWhileMoving= enable  end

function CombatMode:SetActionMode(enable)
	self.enabledActionMode = enable
	self.enabledOverride = nil
	if enable ~= self:ExpectedMouselook() then  self.enabledOverride = enable  end
	self:OverrideBindingsIn('ActionMode', enable)
end



-------------------
-- Configuration
-------------------

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
			return  _ADDON.tableProto.indexOf(CombatMode.config.commands, value)
		end,
		set = function(info, idx)
			local value= CombatMode.config.commands[idx]
			CombatMode.db.profile.bindings[key]= value ~= '' and value or nil
			CombatMode.CustomBindings:Update()
		end,
	}
	CombatMode.config.optionsTable.args[key]= optInfo
	return optInfo
end

local function optMod(action, name, desc, defValues)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "select",
		--width = "full",
		values = CombatMode.config.modifierKeys,
		get = function()
			local value= CombatMode.db.profile.modifiers[action]
			return  _ADDON.tableProto.indexOf(CombatMode.config.modifierKeys, value)
		end,
		set = function(info, idx)
			--if  value == ''  or  value == 'NONE'  then  value= nil  end
			CombatMode.db.profile.modifiers[action]= CombatMode.config.modifierKeys[idx]
			-- CombatMode:UpdateEnableModifiers()
		end,
	}
	CombatMode.config.optionsTable.args[action]= optInfo
	return optInfo
end

local function optToggle(key, name, desc)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "toggle",
		--width = "full",
		-- setting = link(db).profile[key],
		get = function()  return CombatMode.db.profile[key]  end,
		set = function(info, value)
			CombatMode.db.profile[key]= value
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
	opt("X", "X"),
	opt("ALT-BUTTON1", "Alt + Left Click"),
	opt("ALT-BUTTON2", "Alt + Right Click"),
	opt("X", "X"),
	opt("SHIFT-BUTTON1", "Shift + Left Click"),
	opt("SHIFT-BUTTON2", "Shift + Right Click"),
	opt("X", "X"),
	opt("CTRL-BUTTON1", "Control + Left Click"),
	opt("CTRL-BUTTON2", "Control + Right Click"),
	opt("X", "X"),
	optToggle("enabledOnLogin", "Enable on login", "Surprise your little brother/sister next time he/she logs in."),
	optToggle("enabledWhileMoving", "Enable while moving", "While pressing any movement key the mouse will turn the camera and your character."),
	optToggle("enableWithBothButtons", "Enable with both mouse buttons", "After pressing LeftButton and RightButton together: ActionMode will stay enabled."),
	optToggle("enableWithMoveAndSteer", "Enable with Move and steer", "After pressing MoveAndSteer: ActionMode will stay enabled."),
	optToggle("disableWithLookAround", "Disable with looking around", "Turning the camera away from the direction your character looks (with LeftButton) will disable ActionMode."),
	optToggle("ActionModeMoveWithButton1", "Move with LeftButton", "Effective in ActionMode you will move forward while pressing LeftButton. Try RightButton as well, and the two together (MouseCursorMode, LookAroundMode)"),
	optMod("ActionModeEnableModifier", "Enable with modifier:", "While pressing this modifier the camera turns with the mouse."),
	optMod("ActionModeDisableModifier", "Disable with modifier:", "While pressing this modifier the mouse cursor is free to move."),
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
	if not keys then  return  end
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
		MigrateBinding('BUTTON1', 'TARGETNEARESTANDINTERACTNPC')
	elseif  smartButton == 'RIGHT'  then
		MigrateBinding('BUTTON2', 'TARGETNEARESTANDINTERACTNPC')
	elseif  smartButton == 'BOTH'  then
		MigrateBinding('BUTTON1', 'TARGETNEARESTANDINTERACTNPC')
		MigrateBinding('BUTTON2', 'TARGETNEARESTANDINTERACTNPC')
	elseif  smartButton ~= 'DISABLED'  then
		smartButton= nil	-- don't delete unknown, unprocessed setting
	end
	if  smartButton  then  bindings.smarttargeting= nil  end

	--[[ 2018-01-23
	Renamed commands: keep the old as hidden and rebind to new on load
	"Combat Mode Toggle" -> COMBATMODE_TOGGLE
	"(Hold) Switch Mode" -> Use RightClick = TURNORACTION
	--]]
	local  keys1= { GetBindingKey("Combat Mode Toggle") }
	local  keys2= { GetBindingKey("(Hold) Switch Mode") }
	SetBindings(keys1, "COMBATMODE_TOGGLE")
	SetBindings(keys2, "TURNORACTION")
end




-------------------------------
-- Command binding overrides
-------------------------------

CombatMode.OverrideFrames = { Static = CreateFrame("Frame"), ActionMode = CreateFrame("Frame"), AutoRun = CreateFrame("Frame"), MoveAndSteer = CreateFrame("Frame"), Mouselook = {} }
local OverrideFrames = CombatMode.OverrideFrames
-- OverrideFrames.CombatMode.SetBinding = SetOverrideBinding

function OverrideFrames.ActionMode:SetBinding(priority, key, toUpper)
	print("SetOverrideBinding(_, "..tostring(priority)..", "..key..", "..tostring(toUpper))
	SetOverrideBinding(self, priority, key, toUpper)
end
OverrideFrames.AutoRun.SetBinding = OverrideFrames.ActionMode.SetBinding
OverrideFrames.MoveAndSteer.SetBinding = OverrideFrames.ActionMode.SetBinding
OverrideFrames.Static.SetBinding = OverrideFrames.ActionMode.SetBinding

function OverrideFrames.Mouselook:SetBinding(priority, key, toUpper)
	print("SetMouselookOverrideBinding("..key..", "..tostring(toUpper))
	SetMouselookOverrideBinding(key, toUpper)
end





local function OverrideCommand(frame, fromUpper, toUpper, priority)
	frame.cmdKeys= frame.cmdKeys  or  {}

	-- Previously overridden keys
	local oldKeys= frame.cmdKeys[fromUpper]  --  or  {}
	for  i,key  in  ipairsOrOne(oldKeys)  do
		-- Remove previous overrides before GetBindingKey() to get the original.
		frame:SetBinding(false, key, nil)
	end

	-- Keys to override now (if toUpper ~= nil).
	local newKeys=  toUpper  and  packOrOne( GetBindingKey(fromUpper) )  or nil
	-- if  #newKeys <= 1  then  newKeys = newKeys[1]  end
	
	if  toUpper == 'TARGETNEARESTANDINTERACTNPC'  then
		toUpper = CombatMode.BoundCommand
		local dynKeys = CombatMode.SmartInteract.DynamicKeys or {}
		
		for  i,key  in ipairsOrOne(oldKeys) do  dynKeys[key] = nil  end
		for  i,key  in ipairsOrOne(newKeys) do
			assert(not dynKeys[key], "Repeated declaration of DynamicKeys['"..key.."']. Only one shall remain.")
			dynKeys[key] = frame
		end
		
		-- if  not next(dynKeys)  then  dynKeys= nil  end
		CombatMode.SmartInteract.DynamicKeys = dynKeys
	end
	
	-- priority if 'AutoRun'
	for  i,key  in  ipairsOrOne(newKeys)  do
		-- Set new overrides
		frame:SetBinding(priority, key, toUpper)
	end
	
	-- Make it nil if empty
	-- if  not next(newKeys)  then  newKeys= nil  end
	-- Save overridden keys
	frame.cmdKeys[fromUpper]= newKeys
end


function OverrideFrames.ActionMode:OverrideCommand(fromCmd, toCmd, priority)
	OverrideCommand(self, fromCmd:upper(), toCmd and toCmd:upper(), priority)
end

OverrideFrames.AutoRun.OverrideCommand = OverrideFrames.ActionMode.OverrideCommand
OverrideFrames.MoveAndSteer.OverrideCommand = OverrideFrames.ActionMode.OverrideCommand


function OverrideFrames.Mouselook:OverrideCommand(fromCmd, toCmd)
	local fromUpper,toUpper= fromCmd:upper(), toCmd:upper()
	--[[
	Do not SetMouselookOverrideBinding() on any key that is bound to TURNORACTION, MOVEANDSTEER, TARGETSCANENEMY, TARGETNEARESTENEMY.
	These commands run MouselookStart() when pressed, and MouselookStop() when released.
	Overriding them will cause a different key release handler to be called, missing MouselookStop(),
	and result in stuck Mouselook state.
	--]]
	if  fromUpper == 'TURNORACTION'  or  fromUpper == 'TARGETSCANENEMY'  then
		print('CombatMode.OverrideFrames.Mouselook:OverrideCommand():  overriding bindings of '.. fromCmd ..' to '.. toCmd ..' not possible, as it would cause stucking in Combat Mode.')
		return false
	end
	OverrideCommand(self, fromUpper, toUpper)
end



function CombatMode:UpdateOverrideBindings()
	print("CombatMode:UpdateOverrideBindings()")

	-- MoveAndSteerStop() stops AutoRun, which is very disturbing when turning with MoveAndSteer while in AutoRun mode.
	-- Override with MoveForward in ActionMode to avoid this annoyance.
	-- OverrideFrames.ActionMode:OverrideCommand('MoveAndSteer', 'MoveForward')
	-- Or override to TurnOrAction in AutoRun mode.
	-- OverrideFrames.AutoRun:OverrideCommand('MoveAndSteer', 'TurnOrAction', true)  -- priority over ActionMode's override

	-- BUTTON2 = TURNORACTION: Turning is always on and Action does nothing when mouse is hidden -> override with:
	-- OverrideFrames.ActionMode:OverrideCommand('TurnOrAction', 'TARGETNEARESTANDINTERACTNPC')    -- Peaceful
	-- if GetCVarBool('interactOnLeftClick') then  OverrideFrames.ActionMode:OverrideCommand('TurnOrAction', 'TargetNearestEnemy')  end    -- Combatant
	-- if true then  OverrideFrames.ActionMode:OverrideCommand('TurnOrAction', 'TurnOrAction')  end    -- Regain mouse while pressed. Do instead MouselookStop().
	-- if true then  OverrideFrames.ActionMode:OverrideCommand('TurnOrAction', 'CombatMode_Disable')  end    -- Regain mouse.

	-- MoveAndSteer stops MoveForward when released while MoveForward is still pressed. Minor annoyance.
	OverrideFrames.Static:OverrideCommand('MoveAndSteer', 'MOVEFORWARD')    -- TODO: Should only override MouseButton bindings.
	OverrideFrames.Mouselook:OverrideCommand('MoveAndSteer', 'MOVEFORWARD')

	-- InteractMouseover is useless in Mouselook mode.
	-- Typically pressed if the user wants the mouse to select something.
	OverrideFrames.Mouselook:OverrideCommand('InteractMouseover', 'TURNORACTION')    -- Regain mouse.
	-- OverrideFrames.Mouselook:OverrideCommand('InteractMouseover', 'TARGETNEARESTANDINTERACTNPC')

	-- InteractTarget does nothing if there is no target.
	OverrideFrames.Mouselook:OverrideCommand('InteractTarget', 'TARGETNEARESTANDINTERACTNPC')

	-- BUTTON1 = CAMERAORSELECTORMOVE: Select does nothing when mouse is hidden -> override with TargetNearestFriend.
	-- Note: Camera needs disabling Mouselook in MouseDown script. Move (BUTTON1+BUTTON2) is pointless in this state.
	-- OverrideFrames.Mouselook:OverrideCommand('CameraOrSelectOrMove', 'TargetNearestFriend')
	-- if GetCVarBool('interactOnLeftClick') then  OverrideFrames.Mouselook:OverrideCommand('CameraOrSelectOrMove', 'TARGETNEARESTANDINTERACTNPC')  end

	-- Handler for TARGETNEARESTANDINTERACTNPC
	CombatMode.SmartInteract:Enable(true)

end  -- function CombatMode:UpdateOverrideBindings()

-- Call when key bindings change.
-- CombatMode:RegisterBucketEvent('UPDATE_BINDINGS', 0.3, 'UpdateOverrideBindings')




function CombatMode:OverrideBindingsIn(mode, enable)
	print('  CombatMode:OverrideBindingsIn('..mode..', '..colorBoolStr(enable, true)..')')
	local frame = self.OverrideFrames[mode]

	if  mode == 'ActionMode'  then
		-- frame:SetBinding(false, 'BUTTON2', enable and 'MOVEFORWARD' or nil)
		-- frame:OverrideCommand('MoveAndSteer', enable and 'MoveForward')
		-- frame:OverrideCommand('TurnOrAction', enable and 'TARGETNEARESTANDINTERACTNPC')    -- Peaceful
	end
	if  mode == 'AutoRun'  then
		frame:OverrideCommand('MoveAndSteer', enable and 'TurnOrAction', true)  -- priority over ActionMode's override
		-- frame:SetBinding(true, 'BUTTON1', enable and 'TURNORACTION')
		-- frame:SetBinding(true, 'BUTTON1', enable and 'CAMERAORSELECTORMOVE')
	end
	if  mode == 'MoveAndSteer'  then
		-- frame:OverrideCommand('TurnOrAction', enable and 'AutoRun', true)
		-- frame:SetBinding(true, 'BUTTON2', enable and 'AUTORUN')
		-- frame:SetBinding(true, 'BUTTON5', enable and 'COMBATMODE_TOGGLE')
	end

	if enable then  self:CheckOverrides(frame)  end
end


function CombatMode:CheckOverrides(frame)
	for  cmd,keys  in pairsOrOne(frame.cmdKeys) do  if  CombatMode.commands.state[cmd]  then
		CombatMode:LogAnomaly("CombatMode:CheckOverrides(): "..cmd.." is pressed, overriding may cause stuck key: "..strjoin(", ", keys))
	end end  -- for if
end


function CombatMode:PLAYER_REGEN_DISABLED()
	CombatMode:OverrideBindingsIn('ActionMode',   false)
	CombatMode:OverrideBindingsIn('AutoRun',      false)
	CombatMode:OverrideBindingsIn('MoveAndSteer', false)
end

function CombatMode:PLAYER_REGEN_ENABLED()
	CombatMode:OverrideBindingsIn('ActionMode',   self.enabledActionMode)
	CombatMode:OverrideBindingsIn('AutoRun',      self.commands.state.TurnOrAction)
	CombatMode:OverrideBindingsIn('MoveAndSteer', self.commands.state.MoveAndSteer)
end





local WorldClickHandler = CreateFrame('Frame', nil, nil, 'SecureHandlerClickTemplate')

function CombatMode:RegisterOverrides()
	-- Secure wrapper  function  WorldMapFrame_OnClick(self, button, down)
	local preBody = [===[
	print("WorldMapFrame_OnMouseUp_preBody("..button..")")
	if  down  and  button == 'LeftButton'  then
		self:SetBinding(true, 'BUTTON2', 'AUTORUN')
	end
	]===]
	local postBody = [===[
	print("WorldMapFrame_OnMouseDown_postBody("..button..")")
	if  not down  and  button == 'LeftButton'  then
		self:ClearBinding('BUTTON2')
	end
	]===]

	SecureHandlerWrapScript(WorldFrame, 'OnMouseUp'  , WorldClickHandler, preBody, nil)
	SecureHandlerWrapScript(WorldFrame, 'OnMouseDown', WorldClickHandler, "", postBody)
	-- WorldClickHandler:WrapScript(WorldFrame, 'OnClick', preBody, postBody)
	--WorldFrame:WrapScript(WorldFrame, 'OnClick', preBody, postBody)
end

-- CombatMode:RegisterOverrides()

--[[
/dump WorldFrame:HasScript('OnClick'), WorldFrame:HasScript('PreClick'), WorldFrame:HasScript('PostClick'), WorldFrame:HasScript('OnMouseUp'), WorldFrame:HasScript('OnMouseDown')
--]]


-------------------------------
-- User set command bindings
-------------------------------

CombatMode.CustomBindings = CreateFrame("Frame")
-- CombatMode.CustomBindings.SetBinding = SetOverrideBinding
function CombatMode.CustomBindings:SetBinding(priority, key, toUpper)
	print("SetOverrideBinding(_, "..tostring(priority)..", "..key..", "..tostring(toUpper))
	SetOverrideBinding(self, priority, key, toUpper)
end

function CombatMode.CustomBindings:BindKeys(newKeyMap)
	local oldKeyMap = self.keyMap  or  {}
	newKeyMap = newKeyMap  or  {}
	local dynKeys = CombatMode.SmartInteract.DynamicKeys
	
	-- Remove previous overrides
	ClearOverrideBindings(self)
	for  key,cmd  in  pairs(oldKeyMap)  do  if  newKeyMap[key] == nil  then
		-- Remove previous overrides
		-- self:SetBinding(false, key, nil)
	end end
	
	for  key,cmd  in  pairs(oldKeyMap)  do
		if  cmd == 'TARGETNEARESTANDINTERACTNPC'  and  dynKeys  then  dynKeys[key] = nil  end
	end
	
	for  key,cmd  in  pairs(newKeyMap)  do  --if  oldKeyMap[key] ~= cmd  then
		if  cmd == 'TARGETNEARESTANDINTERACTNPC'  then
			-- smart targeting does Interact when in range with the target, otherwise targets the nearest
			cmd = CombatMode.BoundCommand
			-- DynamicKeys collects the keys to update for smarttargeting
			-- and enables PLAYER_TARGET_CHANGED, OnUpdate to update bindings with CombatMode:UpdateSmartInteractKeys()
			-- dynKeys = dynKeys or {}
			dynKeys[key] = self
		end
		
		if cmd ~= "" then
			-- Set new overrides
			self:SetBinding(false, key, cmd)
		end
	end --end
	
	-- Make it nil if empty
	if  not next(newKeyMap)  then  newKeyMap= nil  end
	-- Save overridden keys
	self.keyMap= newKeyMap
	
	-- if  not next(dynKeys)  then  dynKeys= nil  end
	CombatMode.SmartInteract.DynamicKeys = dynKeys
	CombatMode.SmartInteract:Enable(true)
	
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


function CombatMode.CustomBindings:Update()
	print("CombatMode.CustomBindings:Update()")
	--[[
	MouselookStop() won't interrupt command keys that are pressed, i.e. received "down" event, but not "up"
	Those commands will not run for the "up" event if their binding is changed, instead
	the new binding will receive the "up" event without a "down" event.
	This results in unexpectedly entering or leaving CombatMode when rebinding a command that changes CombatMode.
	--]]
	local wasMouselooking = IsMouselooking()
		if wasMouselooking then
		CombatMode:LogAnomaly('CombatMode.CustomBindings:Update() while IsMouselooking() could cause stuck keys, not updating bindings.')
		return
		--CombatMode:LogAnomaly('CombatMode.CustomBindings:Update() while IsMouselooking() could cause stuck keys, temporarily disabling Mouselook.')
		--MouselookStop()
	end

	local profile = CombatMode.db.profile
	self:BindKeys(profile.bindings)

	-- Modifiers (SHIFT/CTRL/ALT) to turn on/off IsEnabledWhileMoving()
	if profile.modifiers then  for  key,binding  in  pairs(profile.modifiers)  do
		SetModifiedClick(key,binding)
	end end

	if wasMouselooking then
		--CombatMode:LogAnomaly('CombatMode.CustomBindings:Update() restoring Mouselook.')
		MouselookStart()
	end
end


CombatMode:OverrideBindingsIn('CombatMode', false)
CombatMode:OverrideBindingsIn('AutoRun', false)
CombatMode.CustomBindings:Hide()


--[[
/run CombatMode:OverrideBindingsIn('CombatMode', true)
/run CombatMode:OverrideBindingsIn('AutoRun', true)
/run CombatMode.CustomBindings:Show()
/run CombatMode.CustomBindings:SetBinding(false, 'BUTTON1', nil) ; CombatMode.CustomBindings:SetBinding(false, 'BUTTON2', nil)

/dump  CombatMode.CustomBindings.keyMap
/dump  CombatMode.OverrideFrames.AutoRun.cmdKeys
/dump  CombatMode.OverrideFrames.CombatMode.cmdKeys
/dump  CombatMode.OverrideFrames.Mouselook.cmdKeys
--]]

--[[
/run  SetBinding('BUTTON2', 'MOVEANDSTEER')
/run  SetOverrideBinding(CombatMode.OverrideFrames.CombatMode, false, 'BUTTON2', 'MOVEANDSTEER')
/run  SetOverrideBinding(CombatMode.OverrideFrames.AutoRun, false, 'BUTTON2', nil)
/run  SetMouselookOverrideBinding('X')
/run  CombatMode.OverrideFrames.CombatMode:Show()
/run  CombatMode:OverrideBindingsIn('CombatMode',true)
/run  CombatMode:OverrideBindingsIn('AutoRun',true)
--]]




---------------------------------
-- TargetNearestAndInteractNpc    aka. SmartInteract, smarttargeting
---------------------------------

local SmartInteract = CreateFrame('Frame', 'CombatModeFrame')
SmartInteract.DynamicKeys= {}  -- List of smart interact keys. If not nil then check periodically (OnUpdate) for target being in interact range.


local function CheckSmartInteractUnit(unit)
	-- return  UnitExists(unit)
	return  UnitIsFriend('player', unit)    -- not PlayerCanAttack(unit)
		and  not UnitIsPlayer(unit)    -- not PlayerCanAssist(unit)
		-- The Ethereal Vendor is PlayerControlled, but also follows you around, therefore pointless for smarttargeting.
		and  not UnitPlayerControlled(unit)
		-- and  not UnitIsDead(unit)
		and  not UnitIsUnit(unit, 'npc')    -- already interacting with a vendor, target next nearest
		and  not UnitIsUnit(unit, 'questnpc')    -- already interacting with a quest giver, target next nearest
	or  UnitIsEnemy('player', unit)
		and  UnitIsDead(unit)    -- loot
end


function SmartInteract:CheckUnit(unit)
	if  not self.DynamicKeys  then  self:Enable(false) ; return  end
	print("SmartInteract:CheckUnit("..unit..")")

	-- Check whether to track this unit.
	if  not CheckSmartInteractUnit(unit)  then
		if  self.monitorUnit ~= unit  then  return  false  end    -- Don't replace.
		unit = nil    -- Stop monitoring.
	end

	print("SmartInteract:CheckUnit(..) -> "..tostring(unit))
	self.monitorUnit = unit
	-- Monitor interact distance?
	self:SetShown(unit ~= nil)
	self:UpdateSmartInteractKeys(unit)
	return unit
end


function SmartInteract:UpdateSmartInteractKeys(unit)
	-- local loot, interact = CanLootUnit('target') ??
	local interact =  unit  and  CheckInteractDistance(unit, 3)  and  unit
	local cmd =
		    interact == 'target'     and  "INTERACTTARGET"
		or  interact == 'mouseover'  and  "INTERACTMOUSEOVER"
		or  self.SmartInteractLoots  and  "TARGETNEAREST"  or  "TARGETNEARESTFRIEND"
	
	if  cmd == self.BoundCommand  then  return  end		-- no changes
	
	if  InCombatLockdown()  then
		self:Enable(false)
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:LogState("CombatMode:UpdateSmartInteractKeys() ignored: Can't update bindings when InCombatLockdown()")
		return
	end
	
	for  key,frame  in  pairs(self.DynamicKeys)  do
		frame:SetBinding(false, key, cmd)
	end
	
	self.BoundCommand = cmd
end



-- OnUpdate() runs if  ==  CombatMode.SmartInteract:IsShown()  ==  CombatMode.DynamicKeys and not InCombatLockdown()
function SmartInteract:OnUpdate(elapsed)
	if  not self.DynamicKeys  then
		self:Enable(false)
		error("SmartInteract:OnUpdate(): frame should be hidden if SmartInteract.DynamicKeys == nil")
	elseif  self.monitorUnit  then
		-- Periodic update (every frame - per 33ms at 30fps) to check distance of target.
		self:UpdateSmartInteractKeys(self.monitorUnit)
	end
end



function SmartInteract:PLAYER_REGEN_DISABLED(event, ...)
	CombatMode:LogEvent(event)
	self:Enable(false)
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
end

function SmartInteract:PLAYER_REGEN_ENABLED(event, ...)
	CombatMode:LogEvent(event)
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:Enable(true)
end

function SmartInteract:UPDATE_MOUSEOVER_UNIT(event, ...)
	CombatMode:LogEvent(event)
	-- Hovering a new mouseover will override the previous monitorUnit if it's 'target'.
	self:CheckUnit('mouseover')
end

function SmartInteract:PLAYER_TARGET_CHANGED(event, ...)
	CombatMode:LogEvent(event)
	-- Selecting a new target after finding a potential mouseover will override the monitorUnit.
	self:CheckUnit('target')
end


function SmartInteract:Enable(enable)
	if  enable  and  next(self.DynamicKeys)  then
		self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
		self:RegisterEvent('PLAYER_TARGET_CHANGED')
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		if  not self:CheckUnit('mouseover')  then  self:CheckUnit('target')  end
	else
		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
		self:Hide()
	end
end


SmartInteract:SetScript('OnUpdate', SmartInteract.OnUpdate)
SmartInteract:Hide()
CombatMode.SmartInteract = SmartInteract



