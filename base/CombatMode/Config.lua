local _G, ADDON_NAME, _ADDON = _G, ...
local ImmersiveAction = _G.ImmersiveAction or {}  ;  _G.ImmersiveAction = ImmersiveAction
-- local Log = ImmersiveAction.Log
-- local Log = ImmersiveAction.Log or {}  ;  ImmersiveAction.Log = Log

local indexOf = _G.LibShared.Require.indexOf


-------------------
-- Configuration
-------------------

local Config = {}
ImmersiveAction.Config = Config
Config.modifierKeys = { '', 'SHIFT', 'CTRL', 'ALT' }

--[[ Commands vocabulary:
turning (character with mouse) = ImmersiveAction (term from GuildWars2 community) = Mouselook (term from Blizzard - Wow lua api)
camera (rotation) = look around with mouse, like turning, but the character does not move / change direction
	- only possible with CAMERAORSELECTORMOVE command and disabled ImmersiveAction
--]]
Config.commands = { 
		'',		-- don't override --

		'CAMERAORSELECTORMOVE',			-- Left Button default:  rotate camera or target mouseover.  Disables Mouselook when pressed, otherwise it acts as MoveAndSteer.
		'TURNORACTION',							-- Right Button default:  Mouselook if hold, InteractMouseover if clicked
		'TURNWITHMOUSE',						-- Turn with mouse, no actions

		-- Interact
		'INTERACTMOUSEOVER',				-- select with mouse + interact, no turning or camera
		-- hook mouse button directly to disable Mouselook while pressed
		-- or override with COMBATMODE_DISABLE
		'INTERACTTARGET',						-- no select, only interact
		-- any valid use-cases for this in ImmersiveAction?

		-- Target (select with mouse)
		'INTERACTNEAREST',	          -- could override INTERACTMOUSEOVER instead: without cursor (in ImmersiveAction) it has no effect
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


Config.commandLabelsCustom = {
	[''] 													= "-- don't override --",
	--[[
	['CAMERAORSELECTORMOVE'] = "Rotate Camera",		 -- targeting  or  camera rotation, original binding of BUTTON1
	['TURNORACTION']         = "Turn or Action",	 -- the original binding of BUTTON2
	['INTERACTNEAREST']      = "Target and interact with closest friendly npc",
	[FocusMouseoverBinding]  = "Focus Mouseover",	 -- no turning or camera
	--]]
}






function Config:GetCommandLabel(command)
	return self.commandLabelsCustom[command]  or  _G['BINDING_NAME_'.. command]  or  command
end

function Config:InitCommandLabels()
	if  self.commandLabels  then  return self.commandLabels  end
	self.commandLabels= {}
	for  i,command  in  ipairs(self.commands)  do
		local label= self:GetCommandLabel(command)
		table.insert(self.commandLabels, label)
	end
	return self.commandLabels
end

--Config:InitCommandLabels()



local optCnt= 0
local function opt(key, name, desc, defValues)
	optCnt= optCnt + 1
	local optInfo= {
		name = name,
		desc = desc,
		order = optCnt,
		type = "select",
		--width = "full",
		values = defValues or Config:InitCommandLabels(),
		get = function()
			local value= ImmersiveAction.db.profile.bindings[key]
			return  indexOf(Config.commands, value)
		end,
		set = function(info, idx)
			local value= Config.commands[idx]
			if value=='' then  value = nil  end
			ImmersiveAction:SetUserBinding('General', key, value)
		end,
	}
	Config.optionsTable.args[key]= optInfo
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
		values = Config.modifierKeys,
		get = function()
			local value= ImmersiveAction.db.profile.modifiers[action]
			return  indexOf(Config.modifierKeys, value)
		end,
		set = function(info, idx)
			--if  value == ''  or  value == 'NONE'  then  value= nil  end
			ImmersiveAction.db.profile.modifiers[action]= Config.modifierKeys[idx]
		end,
	}
	Config.optionsTable.args[action]= optInfo
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
		get = function()  return ImmersiveAction.db.profile[key]  end,
		set = function(info, value)
			ImmersiveAction.db.profile[key]= value
		end,
	}
	Config.optionsTable.args[key]= optInfo
	return optInfo
end


Config.optionsTable = { 
	name = "Immersive Action Settings",
	handler = ImmersiveAction,
	type = "group",
	args = {},
}

Config.optionsTableList = { 
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
	optToggle("enableWithMoveKeys", "Enable while moving", "While pressing any movement key the mouse will turn the camera and your character."),
	optToggle("enableAfterBothButtons", "Enable with both mouse buttons", "After pressing LeftButton and RightButton together:  ActionMode will stay enabled."),
	optToggle("enableAfterMoveAndSteer", "Enable with Move and steer", "After pressing MoveAndSteer:  ActionMode will stay enabled."),
	optToggle("disableWithLookAround", "Disable with looking around", "Clicking LeftButton (turning the camera away from the direction your character looks) will disable ActionMode."),
	optToggle("actionModeMoveWithCameraButton", "Move with LeftButton", "Effective in ActionMode:  You will move forward while pressing LeftButton. Try RightButton as well, and the two together (MouseCursorMode, LookAroundMode)"),
	optMod("enableModifier", "Enable with modifier:", "While pressing this modifier the camera turns with the mouse."),
	optMod("disableModifier", "Disable with modifier:", "While pressing this modifier the mouse cursor is free to move."),
	--opt("smarttargeting", "Smart Targeting", "Buttons that target the closest friendly NPC and interact with it if close enough", SmartTargetValues),
}

