--[[
	Name alternatives:
FreeCursorMode (normal) / FreeCameraMode (LeftButton) / MouselookMode (RightButton).
FreeCameraMode = LookAroundMode = CameraMode
FreeCursorMode = MouseCursorMode = CursorMode, for short.
MouselookMode = RightClick
ActionMode = ActionCameraMode = MouselookMode without pressing RightButton. Riding the hypetrain of ActionCombat (not in wow...) and ActionCamera (this is a thing, try DynamicCam addon).
ActionControls..  found it..  ImmersiveActionControls  ImmersiveActionMode  ImmersiveAction
ImmersiveControls  ImmersionControls  ImmersionCamera

Actually you can be in CursorMode while in ActionMode by pressing RightButton.
Pressing LeftButton will go into CameraMode or start moving (MoveAndSteer) in ActionMode,
depending on the setting of actionModeMoveWithCameraButton.

ImmersiveAction
CameraMode
MouseCameraMode-MouseCursorMode-MouselookMode
Mouselook
https://en.wikipedia.org/wiki/Free_look

	Inspired by:
Immersive Immersive Combat for Guild Wars 2    http://wesslen.org/ICM/
ImmersiveAction addon
Mouse_Look_Lock     https://github.com/DWishR/Mouse-Look-Lock
MouselookHandler    https://github.com/meribold/MouselookHandler
ConsolePort         https://github.com/seblindfors/ConsolePort

https://wow.curseforge.com/projects/combat-mode
https://www.wowinterface.com/downloads/info24776-ImmersiveActionReborn.html
https://wow.curseforge.com/projects/mouse-look-lock
-- It also causes the mouse buttons to remap to movement (forward and backward) keys to match the configuration found in Dark Age of Camelot.
https://wow.curseforge.com/projects/kiki-utils
-- Mouselook : Real DAoC mouse look mode. Key1 switch to and from Mouselook on each press. Hold Key2 to move the camera (when in Mouselook mode). In Mouselook mode, Button1 and Button2 are remapped to MoveForward and MoveBackward. Mouselook mode does NOT break follow mode.
https://wow.curseforge.com/projects/mouselookhandler
https://wow.curseforge.com/projects/mouselook
https://wow.curseforge.com/projects/mouselook-binding
https://wow.curseforge.com/projects/mouse-combat


Targeting without mouse press:  cast spell when releasing bound key.
https://wow.curseforge.com/projects/aoeonrelease
https://www.mmo-champion.com/threads/2110112-GW2-Style-Ground-Targeted-Casting
--]]

--[[
/targetenemy [noharm][dead]
/target[harm][dead]
-> InteractTarget -> loot?

/dump GetBindingByKey('BUTTON1'), GetBindingByKey('BUTTON2')
/dump GetBindingKey('CAMERAORSELECTORMOVE'), GetBindingKey('TURNORACTION'), GetBindingKey('TARGETNEARESTFRIEND')
Reset to default:
/run ImmersiveAction.ResetMouseButton12Bindings()
/run SetBinding('BUTTON1','CAMERAORSELECTORMOVE');SetBinding('BUTTON2','TURNORACTION')
Additional:
/run SetBinding('BUTTON4','MOVEANDSTEER');SetBinding('BUTTON5','COMBATMODE_ENABLE')
/run SetBinding('ALT-BUTTON4','TOGGLEAUTORUN')
My favourite:
/run SetBinding('BUTTON1','MOVEANDSTEER');SetBinding('ALT-BUTTON1','CAMERAORSELECTORMOVE');SetBinding('BUTTON2','TURNORACTION');SetBinding('BUTTON4','TOGGLEAUTORUN')

Debug:
/dump ImmersiveAction.config.optionsFrame
--]]


-- _ADDON main: Ace libs, initialization, settings, bindings
local _G, ADDON_NAME, _ADDON = _G, ...
local ImmersiveAction = _G.ImmersiveAction or {}
_G.ImmersiveAction = LibStub("AceAddon-3.0"):NewAddon(ImmersiveAction, "ImmersiveAction", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
local Log = ImmersiveAction.Log or {}  ;  ImmersiveAction.Log = Log

-- GLOBALS:
-- Upvalued Lua globals: 
-- Used from _G:  




-- Init state:
-- ImmersiveAction.commandState.ActionMode= nil
-- ImmersiveAction.commandState.ActionModeRecent= nil
ImmersiveAction.BoundCommand= 'TARGETNEARESTFRIEND'  -- default action for INTERACTNEAREST: INTERACTTARGET or TARGETNEARESTFRIEND




---------------------------
-- Log: print state transitions, commands, etc.
---------------------------

--[[
-- logging:
/run ImmersiveAction.logging.all= false
/run ImmersiveAction.logging.Anomaly= false
/run ImmersiveAction.logging.State= false
/run ImmersiveAction.logging.Update= true
/run ImmersiveAction.logging.Command= true
-- set to true or false  to override individual event settings
/run ImmersiveAction.logging.Event.all= false
-- individual events
/run ImmersiveAction.logging.Event.CURSOR_UPDATE= false
/run ImmersiveAction.logging.Event.PLAYER_TARGET_CHANGED= false
/run ImmersiveAction.logging.Event.PET_BAR_UPDATE= false
/run ImmersiveAction.logging.Event.ACTIONBAR_UPDATE_STATE= false
/run ImmersiveAction.logging.Event.QUEST_PROGRESS= false
/run ImmersiveAction.logging.Event.QUEST_FINISHED= false
--]]
ImmersiveAction.logging= {
	-- all= false,		-- set to false/true to override individual event settings.
	-- all= true,
	State= false,
	Update= false,
	Command= false,
	-- Anomaly= false,
	Anomaly= true,
	Init= false,
	Frame= false,
}
ImmersiveAction.logging.Event= {
	all= false,		-- set to false/true to override individual event settings.
	-- all= true,
	CURSOR_UPDATE= false,
	PLAYER_TARGET_CHANGED= true,
	-- PET_BAR_UPDATE= true,
	-- ACTIONBAR_UPDATE_STATE= false,
	QUEST_PROGRESS= true,
	QUEST_FINISHED= true,
}


local function makeLogFunc(Log, logging, categ)
	Log[categ] =  function(...)  if logging:_on(categ) then print(...) end  end
end
function ImmersiveAction.logging:_on(categ)
	return  self.all~=false  and  (self[categ] or self.all)
end

ImmersiveAction.logging.Event._on = ImmersiveAction.logging._on
function ImmersiveAction.logging:_onevent(event)
	return  self.all ~= false  and  self.Event  and  self.Event:_on(event)
end

makeLogFunc(Log, ImmersiveAction.logging, 'State')
makeLogFunc(Log, ImmersiveAction.logging, 'Update')
makeLogFunc(Log, ImmersiveAction.logging, 'Command')
makeLogFunc(Log, ImmersiveAction.logging, 'Anomaly')
makeLogFunc(Log, ImmersiveAction.logging, 'Init')
makeLogFunc(Log, ImmersiveAction.logging, 'Frame')

function Log.Event(event, extraMessage)
	if  ImmersiveAction.logging:_onevent(event)  then
		print(event ..':  cursor='.. (GetCursorInfo() or 'hand')
		..' CursorPickedUp()='.. colorBoolStr(CursorPickedUp(),true)
		..' SpellIsTargeting()='.. colorBoolStr(SpellIsTargeting(),true)
		.. (extraMessage or '') )
	end
end



--[[ Change colors used in logging
/run ImmersiveAction.colors['nil']= ImmersiveAction.colors.blue
/run ImmersiveAction.colors[false]= ImmersiveAction.colors.blue
/run ImmersiveAction.colors[true]= ImmersiveAction.colors.green
--]]
ImmersiveAction.colors = {
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
local colors = ImmersiveAction.colors
colors['nil']			= colors.lightblue
colors[false]			= colors.lightblue
colors[true]			= colors.green
colors.missedup		= colors.orange
colors.up					= colors.orange
colors.down				= colors.green		--colors.purple
colors.show				= colors.green
colors.hide				= colors.lightblue
colors.event			= colors.lightgreen
-- colors.ActionMode   = colors.orange
colors.Mouselook  = colors.yellow

function ImmersiveAction.colorBoolStr(value, withColor)
	local boolStr=  value == true and 'ON'  or  value == false and 'OFF'  or  tostring(value)
	if  withColor == true  then  withColor= ImmersiveAction.colors[value == nil  and  'nil'  or  value]  end
	return  withColor  and  withColor .. boolStr .. ImmersiveAction.colors.restore  or  boolStr
end
local colorBoolStr = ImmersiveAction.colorBoolStr




---------------------------
-- Default configuration
---------------------------

ImmersiveAction.defaultSettings= {
	--global = { version = "1.0.0", },
	profile= {
		enabledOnLogin= false,
		enableWithMoveKeys= false,
		enableAfterBothButtons= true,
		enableAfterMoveAndSteer= true,
		disableWithLookAround= true,
		actionModeMoveWithCameraButton= false,
		bindingsInGeneral = {},
		bindingsInActionMode = {},
		bindings= {  -- 2018-10-21:
			--['BUTTON1']				= "INTERACTNEAREST",
			['BUTTON1']				= "CAMERAORSELECTORMOVE",  -- Rotate Camera (LeftButton default),
			['BUTTON2']				= "TURNORACTION",  -- Turn or Action (RightButton default),
			['ALT-BUTTON1']		= "MOVEANDSTEER",
			['ALT-BUTTON2']		= "AUTORUN",
			['SHIFT-BUTTON1'] = "STRAFELEFT",
			['SHIFT-BUTTON2'] = "STRAFERIGHT",
			['CTRL-BUTTON1']	= "INTERACTNEAREST",
			['CTRL-BUTTON2']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			--[[
			['BUTTON1']				= "MOVEANDSTEER",
			['BUTTON2']				= "TURNORACTION",
			['ALT-BUTTON1']		= "CAMERAORSELECTORMOVE",  -- Rotate Camera (LeftButton default),
			['ALT-BUTTON2']		= "TURNORACTION",  -- Turn or Action (RightButton default),
			['SHIFT-BUTTON1'] = "TARGETNEARESTFRIEND",
			['SHIFT-BUTTON2'] = "TARGETNEARESTENEMY",
			['CTRL-BUTTON1']	= "INTERACTNEAREST",
			['CTRL-BUTTON2']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			--]]
			--[[
			['BUTTON1']				= "INTERACTNEAREST",
			--['BUTTON1']				= "MOVEANDSTEER",
			['BUTTON2']				= "TARGETSCANENEMY",
			['ALT-BUTTON1']		= "CAMERAORSELECTORMOVE",  -- Rotate Camera (LeftButton default),
			['ALT-BUTTON2']		= "TURNORACTION",  -- Turn or Action (RightButton default),
			['SHIFT-BUTTON1'] = FocusMouseoverBinding,
			['SHIFT-BUTTON2'] = "TARGETNEARESTENEMY",
			['CTRL-BUTTON1']	= "INTERACTMOUSEOVER",  -- Does INTERACTTARGET if there is nothing under the mouse (no mouseover)
			['CTRL-BUTTON2']	= "INTERACTNEAREST",
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




--------------------------
-- Addon loading events
--------------------------

function ImmersiveAction:OnInitialize()
	-- Run on own ADDON_LOADED event
	Log.Init('  ImmersiveAction:OnInitialize()')
	self.commands:HookCommands()
	--self:HookUpFrames()		-- is it necessary before OnEnable() calling it again?
	self:RegisterChatCommand("cm", "ChatCommand")
	self:RegisterChatCommand("combatmode", "ChatCommand")
	
	--[[
	Use one profile called 'Default' for all characters originally
	Name of default profile can be changed with setting  profileKeys['default']
	To have character-specific profiles when creating/initializing a new character
	/run  ImmersiveActionDB.profileKeys['default']= false
	--]]
	local defaultProfile= ImmersiveActionDB  and  ImmersiveActionDB.profileKeys  and  ImmersiveActionDB.profileKeys.Default
	if  defaultProfile == nil  then  defaultProfile= true  end		-- false to have character-specific profiles

	self.db = LibStub("AceDB-3.0"):New("ImmersiveActionDB", self.config.defaultSettings, defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	--self.db.RegisterCallback(self, "OnDatabaseShutdown", "OnDisable")
	
	--self.config:InitCommandLabels()
	--self.config:InitOptionsTable()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(self.config.name, self.config.optionsTable)
	self.config.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.config.name, self.config.name)

	self.commandState.ActionMode = self.db.profile.enabledOnLogin
	self:ProfileChanged()
end	


function ImmersiveAction:OnEnable()
	-- Run on PLAYER_LOGIN, before PLAYER_ENTERING_WORLD
	-- frame sizes and positions are loaded before this event
	Log.Init('  ImmersiveAction:OnEnable()')

	-- UpdateOverrideBindings() is called when key bindings change.
	self:UpdateOverrideBindings()
	self:RegisterBucketEvent('UPDATE_BINDINGS', 0.3, 'UpdateOverrideBindings')
	self.OverrideBindings:Enable(true)
	self.InteractNearest:Enable(true)

	-- Find frames now, after addons loaded.
	self:HookUpFrames()
	-- Find missing frames when delayed loading any addon.
	self:RegisterEvent('ADDON_LOADED')

	-- Monitor Shift/Ctrl/Alt.
	self:RegisterEvent('MODIFIER_STATE_CHANGED')

	-- Targeting and questing shows cursor.
	self:RegisterEvent('CURSOR_UPDATE')
	self:RegisterEvent('QUEST_PROGRESS')
	self:RegisterEvent('QUEST_FINISHED')
	-- self:RegisterEvent('PET_BAR_UPDATE')
	-- self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
end


function ImmersiveAction:OnDisable()
	Log.Init('  ImmersiveAction:OnDisable()')
	-- Called when the addon is disabled

	self.commandState.ActionMode = false
	self.commandState.ActionModeRecent = nil

	self:UnregisterEvent('ADDON_LOADED')

	self:UnregisterEvent('MODIFIER_STATE_CHANGED')
	self:UnregisterEvent('CURSOR_UPDATE')
	self:UnregisterEvent('QUEST_PROGRESS')
	self:UnregisterEvent('QUEST_FINISHED')
	-- self:UnregisterEvent('PET_BAR_UPDATE')
	-- self:UnregisterEvent('ACTIONBAR_UPDATE_STATE')

	-- Disable UpdateOverrideBindings().
	self:UnregisterBucketEvent('UPDATE_BINDINGS')
	self.OverrideBindings:Enable(false)
	self.InteractNearest:Enable(false)
end


function ImmersiveAction:ADDON_LOADED(event, addonName)
	-- registered for event after PLAYER_LOGIN fires:
	-- static loaded addons already received it
	-- only delay-loaded addons will trigger
	-- ex.: Blizzard_BindingUI -> KeyBindingFrame
	Log.Init('  ImmersiveAction:ADDON_LOADED('.. self.colors.green .. addonName ..'|r)')
	self:HookUpFrames()
end


function ImmersiveAction:ProfileChanged()
	-- Update loaded user binding overrides.
	self:UpdateUserBindings()
end


-- UpdateOverrideBindings() is called when key bindings change.
function ImmersiveAction:UpdateOverrideBindings(event)
	self.OverrideBindings:UpdateOverrideBindings()
	self.InteractNearest:UpdateOverrideBindings()
end



----------------------
-- Binding settings
----------------------

function ImmersiveAction.ResetMouseButton12Bindings()
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
	print('ImmersiveAction updating binding  "'.. name ..'":  '.. table.concat(keys, ', '))
end




----------------------
-- Chat command /ia
----------------------

function ImmersiveAction:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.config.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.config.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("ia", "ImmersiveAction", input)
    end
end





----------------------
-- Shared functions
----------------------

LibShared.DefineTable.SetScript()
LibShared.SetScript.OnEvent = LibShared.SetScript.OnEvent  or  function(frame, event, ...)  if frame[event] then  frame[event](frame, event, ...)  end end


