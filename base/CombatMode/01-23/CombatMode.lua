-- Addon main: Ace libs, initialization, settings, bindings
CombatMode = LibStub("AceAddon-3.0"):NewAddon("CombatMode", "AceConsole-3.0", "AceEvent-3.0")

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

CombatMode.DatabaseDefaults= {
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
	}
}
--[[ Dec 5, 2017 
I had to update the Keybindings again, there were a lot of issues binding Target Friendly to a ctrl+click key, it doesn't have the same affect as putting it on a basic click.
SO, Left click now selects a friendly target, right click will select an enemy target.  Control or Shift click to interact.  Much simpler, I am still building the ui for the config, that's coming.
--]]


function CombatMode:LogInit(...)
	if  self.logging  and  self.loggingInit  then  print(...)  end
end


function CombatMode:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("cm", "CombatMode", input)
    end
end




function CombatMode:OnInitialize()

	self:LogInit('CombatMode:OnInitialize()')
	self:HookCommands()
	self:HookUpFrames()
	self:RegisterChatCommand("cm", "ChatCommand")
	self:RegisterChatCommand("combatmode", "ChatCommand")
	
	local defaultProfile= CombatModeDB.profileKeys.Default  or  true
	self.db = LibStub("AceDB-3.0"):New("CombatModeDB", self.DatabaseDefaults, defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	--self.db.RegisterCallback(self, "OnDatabaseShutdown", "OnDisable")
	self:ProfileChanged()
	
	
	local ButtonOverrideLabels= {}
	CombatMode.ButtonOverrideLabels= ButtonOverrideLabels
	
	--local ButtonOverrideLabelsReverse = {}
	--local valIdx= 10
	local function b(command, label)
		--valIdx= valIdx + 1		-- for sorting
		label= label  or  _G['BINDING_NAME_'.. command]
		--CombatMode.ButtonOverrideLabels[valIdx ..'-'.. command]= label
		CombatMode.ButtonOverrideLabels[command]= label
		--ButtonOverrideLabelsReverse[label]= command
		return label
	end
	
	--[[ Vocabulary:
	turning (character with mouse) = CombatMode (term from GuildWars2 community) = Mouselook (term from Blizzard - Wow lua api)
	camera (rotation) = look around with mouse, like turning, but the character does not move / change direction
		- only possible with CAMERAORSELECTORMOVE command and disabled CombatMode
	--]]
	local ButtonOverrideValuesList = { 
		b('', "-- Don't override --"),
		
		-- Target (select with mouse)
		b('TARGETSCANENEMY'),						-- with turning/lock (Mouselook)
		b('TARGETMOUSEOVER'),						-- no turning or camera -> hook mouse directly to enable Mouselook
		b('FOCUSMOUSEOVER', "Focus Mouseover"),							-- no turning or camera
		b('CAMERAORSELECTORMOVE', "Rotate Camera"),	-- targeting  or  camera rotation, original binding of BUTTON1
		-- must disable Mouselook otherwise it is MoveForward + Mouselook
		-- almost like MoveAndSteer, but does not stop if MoveForward is pressed too and this one released,
		-- while releasing MoveAndSteer interrupts the effect of MoveForward too)
		b('TURNORACTION', "Turn or Action"),										-- the original binding of BUTTON2
		
		-- Target Nearest (tab select, no turning or camera, mouse maybe influences direction to look for nearest?)
		b('SMARTTARGETANDINTERACTNPC', "Smart Target: target closest and interact"),
		b('TARGETNEARESTFRIEND'),
		b('TARGETNEARESTFRIENDPLAYER'),
		b('TARGETPREVIOUSFRIEND'),
		b('TARGETNEARESTENEMY'),
		b('TARGETNEARESTENEMYPLAYER'),
		
		-- Interact
		b('INTERACTMOUSEOVER'),				-- select with mouse + interact, no turning or camera
		-- -> hook mouse button directly to enable CombatMode
		b('INTERACTTARGET'),							-- no select, only interact
		-- any valid use-cases for this in CombatMode, where INTERACTMOUSEOVER is not a better fit?
		
		-- Move
		b('MOVEANDSTEER'),
		b('MOVEFORWARD'),
		b('STRAFELEFT'),
		b('STRAFERIGHT'),
		b('JUMP'),
		b('SITORSTAND'),
		
		-- ActionBar
		b('ACTIONBUTTON1'),
		b('ACTIONBUTTON2'),
		b('ACTIONBUTTON3'),
		b('ACTIONBUTTON4'),
		b('ACTIONBUTTON5'),
		b('ACTIONBUTTON6'),
		b('ACTIONBUTTON7'),
		b('ACTIONBUTTON8'),
		b('ACTIONBUTTON9'),
		b('ACTIONBUTTON10'),
		b('ACTIONBUTTON11'),
		b('ACTIONBUTTON12'),
	}
	
	local ModifierKeyValues = { 'NONE', 'SHIFT', 'CTRL', 'ALT' }

	--[[
	local SmartTargetValues = {
		LEFT = "Left Mouse Button",
		RIGHT = "Right Mouse Button",
		BOTH = "Both Mouse Buttons",
		DISABLED = "Disabled",
	}
	--]]
	
	CombatMode.CombatModeOptions = { 
		name = "Combat Mode Settings",
		handler = CombatMode,
		type = "group",
		args = {},
	}
	
	local function buttonSet(key, value)
		-- self == CombatMode
		-- cut the number prefix "12-"  used for ordering
		--local value= ButtonOverrideLabelsReverse[label]
		self.db.profile.bindings= self.db.profile.bindings or {}
		self.db.profile.bindings[key]= value
		self:BindBindingOverrides()
	end
	
	local optCnt= 0
	local function opt(key, name, desc, defValues)
		optCnt= optCnt + 1
		local optInfo= {
			name = name,
			desc = desc,
			order = optCnt,
			type = "select",
			--width = "full",
			values = defValues or ButtonOverrideLabels,
			get = function()  return self.db.profile.bindings[key] or ''  end,
			set = function(info, value)  buttonSet(key, value)  end,
		}
		self.CombatModeOptions.args[key]= optInfo
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
			values = ModifierKeyValues,
			get = function()  return self.db.profile.modifiers and self.db.profile.modifiers[key] or 'NONE'  end,
			set = function(info, value)
				self.db.profile.modifiers= self.db.profile.modifiers or {}
				self.db.profile.modifiers[key]= value == 'NONE' and nil or value
			end,
		}
		self.CombatModeOptions.args[key]= optInfo
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
			--values = { [true]= 'Enable', [false]= 'Disable' },
			--values = {},
			get = function()  return self.db.profile[key]  end,
			set = function(info, value)  self.db.profile[key]= value  end,
		}
		self.CombatModeOptions.args[key]= optInfo
		return optInfo
	end
	
	local CombatModeOptionsList = { 
		opt("BUTTON1", "Left Click", "Override original behavior of Left Mouse Button"),
		opt("BUTTON2", "Right Click", "Override original behavior of Right Mouse Button"),
		opt("ALT-BUTTON1", "Shift + Left Click"),
		opt("ALT-BUTTON2", "Shift + Right Click"),
		opt("SHIFT-BUTTON1", "Shift + Left Click"),
		opt("SHIFT-BUTTON2", "Shift + Right Click"),
		opt("CTRL-BUTTON1", "Control + Left Click"),
		opt("CTRL-BUTTON2", "Control + Right Click"),
		optCheck("enableWhileMoving", "Enable while moving", "While pressing any movement key CombatMode is enabled"),
		optMod("CombatModeEnableModifier", "Enable while moving with modifier:", "While pressing this modifier and any movement key CombatMode is enabled"),
		optMod("CombatModeDisableModifier", "Disable while moving with modifier:", "While pressing this modifier and any movement key CombatMode is disabled"),
		--opt("smarttargeting", "Smart Targeting", "Buttons that target the closest friendly NPC and interact with it if close enough", SmartTargetValues),
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Combat Mode", self.CombatModeOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Combat Mode", "Combat Mode")
	
end		-- CombatMode:OnInitialize()




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
	self:MigrateSettings()
	self:BindBindingOverrides()
end




local function SetBindings(keys, command)
	for  i,key  in  ipairs(keys)  do
		SetBinding(key, command)
	end
	local name= _G['BINDING_NAME_'.. command]  or  command
	print('CombatMode updating binding  "'.. name ..'":  '.. table.concat(keys, ', '))
end


function CombatMode:MigrateSettings()
	local bindings= self.db.profile.bindings
	
	local function MigrateBinding(key, newCmd)
		local oldCmd= bindings[key] or ''
		bindings[key]= newCmd
		local oldCmdLabel= oldCmd == ''  and  ''  or  (self.ButtonOverrideLabels[oldCmd] or oldCmd) ..'  '
		local newCmdLabel= self.ButtonOverrideLabels[newCmd]
		local keyName= self.CombatModeOptions.args[key]
		print('CombatMode updating binding  '.. keyName ..':  '.. oldCmdLabel ..'->  '.. newCmdLabel)
	end
	
	-- migrate bindings.*button*
	for  newKey,defValue  in  pairs(self.DatabaseDefaults.profile.bindings)  do  if  bindings[oldKey]  then
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

	--[[
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




CombatMode.MouselookOverrideBindings= {}
CombatMode.MoveAndSteerKeys= {}


function CombatMode:BindBindingOverrides()
	local wasMouselooking= IsMouselooking()
	if  wasMouselooking  then  MouselookStop()  end
	--[[
	MouselookStop() won't interrupt command keys that are pressed, i.e. received "down" event, but not "up"
	Those commands will not run for the "up" event if their binding is changed, instead
	the new binding will receive the "up" event without a "down" event.
	This results in unexpectedly entering or leaving CombatMode when rebinding a command that changes CombatMode.
	--]]
	
	SmartTargetingEnabled= nil		-- reset
	local profile= self.db.profile
	
	--[[ Override MOVEANDSTEER with MOVEFORWARD in CombatMode.
	MoveAndSteerStop()  calls  MouselookStop()  on release, disabling CombatMode.
	UpdateStatus()  re-enables Mouselook therefore this is not necessary for this reason.
	If a bug is caused by the  MouselookStop() -> MouselookStart()  transient,
	then enable this to remove the tansient and the bug with it.
	--]]
	for  i,key  in  ipairs(self.MoveAndSteerKeys)  do
		-- Remove previous overrides
		SetMouselookOverrideBinding(key, nil)
	end
	self.MoveAndSteerKeys= { GetBindingKey('MOVEANDSTEER') }
	for  i,key  in  ipairs(self.MoveAndSteerKeys)  do
		-- New overrides
		SetMouselookOverrideBinding(key, 'MOVEFORWARD')
	end
	
	
	-- Modifiers (SHIFT/CTRL/ALT) to turn on/off EnableWhileMoving()
	if  profile.modifiers  then  for  key,binding  in  pairs(profile.modifiers)  do
		SetModifiedClick(key,binding)
	end end
	
	
	-- Remove previous overrides
	for  key,binding  in  pairs(self.MouselookOverrideBindings)  do
		SetMouselookOverrideBinding(key, nil)
	end
	self.MouselookOverrideBindings= {}		-- reset
	
	--[[
	Must not do SetMouselookOverrideBinding() on any key that is bound to TURNORACTION or TARGETSCANENEMY
	the key gets pressed, Mouselook is turned on, the binding is overridden
	the override command does not get the 'down' event, but the key is in pressed state
	the key release event goes to the override command, unexpectedly selecting a unit
	TURNORACTION / TARGETSCANENEMY does not get release event -> Mouselook is stuck enabled
	--]]
	if  profile.bindings  then  for  key,binding  in  pairs(profile.bindings)  do
		local  origCmd= GetBindingByKey(key)
		if  binding == nil  or  binding == ''  then		-- or  binding == 'NOCHANGE'
			-- ignore
		elseif  origCmd == 'TURNORACTION'  or  origCmd == 'TARGETSCANENEMY'  then
			if  origCmd ~= binding  then
				print('BindBindingOverrides():  '.. key ..' binding to '.. origCmd ..' not overridden with '.. binding .. ' as it would cause stucking in Combat Mode.')
			end
		else
			local cmd= binding
			if  cmd == 'SMARTTARGETANDINTERACTNPC'  then
				-- SmartTargetingEnabled collects the keys to update for smarttargeting
				-- and enables OnEvent, OnUpdate to update bindings with CombatMode:UpdateSmartTarget()
				SmartTargetingEnabled = SmartTargetingEnabled or {}
				SmartTargetingEnabled[key] = true
				-- smart targeting does Interact when in range with the target, otherwise targets the nearest
				cmd= self:CheckSmartTarget()  and  "INTERACTTARGET"  or  "TARGETNEARESTFRIEND"
			end
			SetMouselookOverrideBinding(key, cmd)
			self.MouselookOverrideBindings[key]= cmd
		end
	end end
	--[[ Dec 7, 2017
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
	--[[ Dec 10, 2017
	 I actually ended up handling this slightly differently in 1.2.0.
	 Left click selects friendly by default, if you're within range, it will change to interact for you.
	 If you're out of range, it's back to select friendly.
	 Essentially allowing you to Mouse1 your way to victory while questing / talking to NPC's.
	--]]

	if  wasMouselooking  then  MouselookStart()  end
end




function CombatMode:EnableWhileMoving()
	local profile= self.db.profile
	return  profile.enableWhileMoving and not IsModifiedClick('CombatModeDisableModifier')  or  IsModifiedClick('CombatModeEnableModifier')
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




