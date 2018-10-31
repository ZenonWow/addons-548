CombatMode = LibStub("AceAddon-3.0"):NewAddon("CombatMode", "AceConsole-3.0", "AceEvent-3.0")
--BINDING_NAME_COMBATMODE_ENABLE="Enable Combat Mode (Hold/Toggle)"

--[[
Ingame macro to check non-CombatMode mouse bindings:
/run for i=1,5 do print('BUTTON'..i..' -> '..tostring(GetBindingByKey('BUTTON'..i))) end
/dump GetBindingByKey('BUTTON1'),GetBindingByKey('BUTTON2'),GetBindingByKey('BUTTON5')
--]]

local databaseDefaults = {
	global = {
	  version = "1.0.0",
	},
	profile = {
		bindings = {
			button1 = {
				key = "BUTTON1",
				value = "TARGETNEARESTFRIEND",
			},
			button2 = {
				key = "BUTTON2",
				value = "TARGETSCANENEMY",
			},
			shiftbutton1 = {
				key = "SHIFT-BUTTON1",
				value = "TARGETPREVIOUSFRIEND",
			},
			shiftbutton2 = {
				key = "SHIFT-BUTTON2",
				value = "INTERACTTARGET",
			},
			ctrlbutton1 = {
				key = "CTRL-BUTTON1",
				value = "TARGETNEARESTFRIEND",
			},
			ctrlbutton2 = {
				key = "CTRL-BUTTON2",
				value = "INTERACTTARGET",
			},
		},
	}
}

function CombatMode:OnInitialize()

	-- vocabulary:
	-- turning (character with mouse) = CombatMode (term from GuildWars2 community) = Mouselook (term from Blizzard - Wow lua api)
	-- camera (rotation) = look around with mouse, like turning, but the character does not move / change direction - only possible with CAMERAORSELECTORMOVE command and disabled CombatMode
	defaultButtonValues = {
		-- Target (select with mouse)
		TARGETSCANENEMY = "TARGETSCANENEMY",						-- with turning (Mouselook)
		-- TARGETSCANENEMY: turning + click=scanenemy
		-- vs  TURNORACTION: turning + click=action or move-to-click, don't want it
		-- TARGETSCANENEMY does the turning (Mouselook), and provides an action-combat style tool to select (tho only enemy)
		-- TURNORACTION does the turning (Mouselook), but without turning (if the mouse does not move between press and release),
		-- it acts similar to INTERACTMOUSEOVER: selects or interacts,
		-- with the major difference of doing click-to-move if click on terrain and it is enabled in settings
		-- enabling click-to-move for INTERACTMOUSEOVER is beneficial
		TARGETMOUSEOVER = "TARGETMOUSEOVER",						-- no turning or camera -> hook mouse directly to enable Mouselook
		FOCUSMOUSEOVER = "FOCUSMOUSEOVER",							-- no turning or camera
		CAMERAORSELECTORMOVE = "CAMERAORSELECTORMOVE",	-- targeting  or  camera rotation, original binding of BUTTON1
		-- must disable Mouselook otherwise it is MoveForward + Mouselook
		-- almost like MoveAndSteer, but does not stop if MoveForward is pressed too and this one released,
		-- while releasing MoveAndSteer interrupts the effect of MoveForward too)
		TURNORACTION= "TURNORACTION",										-- the original binding of BUTTON2
		
		-- Interact
		INTERACTMOUSEOVER = "INTERACTMOUSEOVER",				-- select with mouse + interact, no turning or camera
		-- -> hook mouse button directly to enable CombatMode
		INTERACTTARGET = "INTERACTTARGET",							-- no select, only interact
		-- any valid use-cases for this in CombatMode, where INTERACTMOUSEOVER is not a better fit?
		
		-- Target Nearest (tab select, no turning or camera, mouse maybe influences direction to look for nearest?)
		TARGETNEARESTFRIEND = "TARGETNEARESTFRIEND",
		TARGETNEARESTFRIENDPLAYER = "TARGETNEARESTFRIENDPLAYER",
		TARGETPREVIOUSFRIEND = "TARGETPREVIOUSFRIEND",
		TARGETNEARESTENEMY = "TARGETNEARESTENEMY",
		TARGETNEARESTENEMYPLAYER = "TARGETNEARESTENEMYPLAYER",
		-- Move
		MOVEANDSTEER = "MOVEANDSTEER",
		MOVEFORWARD = "MOVEFORWARD",
		STRAFELEFT = "STRAFELEFT",
		STRAFERIGHT = "STRAFERIGHT",
		JUMP = "JUMP",
		SITORSTAND = "SITORSTAND",
		-- ActionBar
		ACTIONBUTTON1 = "ACTIONBUTTON1",
		ACTIONBUTTON2 = "ACTIONBUTTON2",
		ACTIONBUTTON3 = "ACTIONBUTTON3",
		ACTIONBUTTON4 = "ACTIONBUTTON4",
		ACTIONBUTTON5 = "ACTIONBUTTON5",
		ACTIONBUTTON6 = "ACTIONBUTTON6",
		ACTIONBUTTON7 = "ACTIONBUTTON7",
		ACTIONBUTTON8 = "ACTIONBUTTON8",
		ACTIONBUTTON9 = "ACTIONBUTTON9",
		ACTIONBUTTON10 = "ACTIONBUTTON10",
		ACTIONBUTTON11 = "ACTIONBUTTON11",
		ACTIONBUTTON12 = "ACTIONBUTTON12"
	}

	CombatModeOptions = { 
		name = "Combat Mode Settings",
		
		handler = CombatMode,
		type = "group",
		args = {
			button1 = {
				name = "Left Click",
				desc = "Left Click",
				type = "select",
				width = "full",
				order = 1,
				values = defaultButtonValues,
				set = function(info, value)
					self.db.profile.bindings.button1.value = value
					CombatMode:BindBindingOverrides()
				end,
				get = function()
					return self.db.profile.bindings.button1.value
				end
			},
			button2 = {
				name = "Right Click",
				desc = "Right Click",
				type = "select",
				width = "full",
				order = 2,
				values = defaultButtonValues,
				set = function(info, value)
					self.db.profile.bindings.button2.value = value
					CombatMode:BindBindingOverrides()
				end,
				get = function()
					return self.db.profile.bindings.button2.value
				end
			},			
			ctrlbutton1 = {
				name = "Control + Left Click",
				desc = "Control + Left Click",
				type = "select",
				width = "full",
				order = 3,
				values = defaultButtonValues,
				set = function(info, value)
					self.db.profile.bindings.ctrlbutton1.value = value
					CombatMode:BindBindingOverrides()
					
				end,
				get = function()
					return self.db.profile.bindings.ctrlbutton1.value
				end
			},	
			ctrlbutton2 = {
				name = "Control + Right Click",
				desc = "Control + Right Click",
				type = "select",
				width = "full",
				order = 4,
				values = defaultButtonValues,
				set = function(info, value)
					self.db.profile.bindings.ctrlbutton2.value = value
					CombatMode:BindBindingOverrides()
				end,
				get = function()
					return self.db.profile.bindings.ctrlbutton2.value
				end
			},	
			shiftbutton1 = {
				name = "Shift + Left Click",
				desc = "Shift + Left Click",
				type = "select",
				width = "full",
				order = 5,
				values = defaultButtonValues,
				set = function(info, value)
					self.db.profile.bindings.shiftbutton1.value = value
					CombatMode:BindBindingOverrides()
				end,
				get = function()
					return self.db.profile.bindings.shiftbutton1.value
				end
			},	
			shiftbutton2 = {
				name = "Shift + Right Click",
				desc = "Shift + Right Click",
				type = "select",
				width = "full",
				order = 6,
				values = defaultButtonValues,
				set = function(info, value)
					self.db.profile.bindings.shiftbutton2.value = value
					CombatMode:BindBindingOverrides()
				end,
				get = function()
					return self.db.profile.bindings.shiftbutton2.value
				end
			},	
		}
	}
		
	-- Code that you want to run when the addon is first loaded goes here.
	self.db = LibStub("AceDB-3.0"):New("CombatModeDB")



	-- Called when the addon is loaded
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Combat Mode", CombatModeOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Combat Mode", "Combat Mode")
	self:RegisterChatCommand("cm", "ChatCommand")
	self:RegisterChatCommand("combatmode", "ChatCommand")
	
	self.db = LibStub("AceDB-3.0"):New("CombatModeDB", databaseDefaults, true)

	CombatMode:HookCommands()
	CombatMode:HookUpFrames()
	CombatMode:BindBindingOverrides()
end

function CombatMode:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("cm", "CombatMode", input)
    end
end

function CombatMode:OnEnable()
	-- Called when the addon is enabled
	self:RegisterEvent('CURSOR_UPDATE')
end

function CombatMode:OnDisable()
    -- Called when the addon is disabled
	self:UnregisterEvent('CURSOR_UPDATE')
end

function CombatMode:BindBindingOverrides()
	-- must not do SetMouselookOverrideBinding() on any key that is bound to TURNORACTION or TARGETSCANENEMY
	-- the key gets pressed, Mouselook is turned on, the binding is overridden
	-- the override command does not get the 'down' event, but the key is in pressed state
	-- the key release event goes to the override command, unexpectedly selecting a unit
	-- TURNORACTION / TARGETSCANENEMY does not get release event -> Mouselook is stuck enabled
	for  idx, bind  in  pairs(self.db.profile.bindings)  do
		local  origCmd= GetBindingByKey(bind.key)
		if  origCmd == 'TURNORACTION'  or  origCmd == 'TARGETSCANENEMY'  then
			if  origCmd ~= bind.value  then
				print('BindBindingOverrides():  '.. bind.key ..' binding to '.. origCmd ..' not overridden with '.. bind.value .. ' as it would cause stucking in Combat Mode.')
			end
		else
			SetMouselookOverrideBinding(bind.key, bind.value)
		end
	end
end


local combatModeAddonSwitch = false
--[[
local combatModeTemporaryDisable = false

local combatMode_UpdateInterval = 0.025;
local TimeSinceLastUpdate = 0;
--]]

--[[
local function UnmouseableFrameOnScreen()
	for index in pairs(CombatMode_FramesToCheck) do
		local curFrame = getglobal(CombatMode_FramesToCheck[index])
		if (curFrame and curFrame:IsVisible()) then
			return true
		end
	end
end
--]]

function CombatMode_Toggle()
	if  combatModeAddonSwitch ~= IsMouselooking()  then
		print('Combat Mode flag was out-of-sync, old and new state='.. tostring(combatModeAddonSwitch))
	end
	
	combatModeAddonSwitch = not IsMouselooking()
	if combatModeAddonSwitch then
		MouselookStart()
		--CombatMode:BindBindingOverrides()
	else
		MouselookStop()
	end
end

--[[
local function checkForDisableState()
	return (UnmouseableFrameOnScreen() or CursorHasItem() or SpellIsTargeting())	
end
local function updateCombatState()
	if MouseLookTempDisabled then
		-- if we're in a disabled state, check to see if we should get out of it
		if not checkForDisableState() then
			MouseLookTempDisabled = false
			MouselookStart()
		end
	else
		-- combat mode is on and checking if we need to go into a disabled state
		if checkForDisableState() then
			MouseLookTempDisabled = true
			MouselookStop()
		end
	end
end
--]]
local BeforeHoldState= false
function CombatMode_Hold(keystate)
	if  keystate == "down"  then
		BeforeHoldState= IsMouselooking()
		CombatMode_Toggle()
	elseif  BeforeHoldState~= IsMouselooking()  then
		CombatMode_Toggle()
	end
end
--[[
function CombatMode_OnLoad(self, elapsed)

end
--]]


--[[
local  lastUpdateCursorBusy= false

function CombatMode_OnUpdate(self, elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed; 	
	if  TimeSinceLastUpdate > combatMode_UpdateInterval  then
		local  CursorBusy= CursorHasItem()  or  SpellIsTargeting()
		if  lastUpdateCursorBusy ~= CursorBusy  then
			CombatMode:UpdateState(not CursorBusy, 'OnUpdate')
			lastUpdateCursorBusy= CursorBusy
		end
		TimeSinceLastUpdate = 0
	end
end
--]]




local function UnmouseableFrameOnScreen()
	return  0 < #CombatMode.FramesOnScreen
	--[[
	for index in pairs(CombatMode_FramesToCheck) do
		local curFrame = getglobal(CombatMode_FramesToCheck[index])
		if (curFrame and curFrame:IsVisible()) then
			return true
		end
	end
	--]]
end


local  lastUpdateCursorBusy= false

function  CombatMode:CURSOR_UPDATE(msg)
		local  CursorBusy= CursorHasItem()  or  SpellIsTargeting()
		if  lastUpdateCursorBusy ~= CursorBusy  then
			CombatMode:UpdateState(not CursorBusy, 'CURSOR_UPDATE')
			lastUpdateCursorBusy= CursorBusy
		end
end


function  CombatMode:UpdateState(possibleTransition, event)
	event= event or 'nil'
	
	local newState, reason= self:ExpectedState()
	--if  newState ~= possibleTransition  then  print(prefix ..' - not taking effect'.. suffix)  end
	if  newState == IsMouselooking()  then  return  end
	
	local prefix= 'CombatMode:UpdateState('.. tostring(possibleTransition) ..', '.. event ..'):  '
	local suffix= ' was='.. tostring(IsMouselooking()) ..' new='.. tostring(newState) ..' reason='.. reason
	print(prefix ..' - CHANGE' .. suffix)
	
	if  newState  then  MouselookStart()  else  MouselookStop()  end
end


function CombatMode:ExpectedState()
	-- Turn,Pitch  is first in priority: even if turning with mouse, short turn/pitch adjustments are possible
	-- otherwise TurnOrAction would lock the direction to the mouse and disable turning
	-- Turn,Pitch(release) and TurnOrAction(lock)?  -> priority: Turn,Pitch(release)
	if  self.CommandsReleasing  then  return false, 'Turn,Pitch'  end
	
	-- TurnOrAction,MoveAndSteer ignores FramesOnScreen -- or it should be all Move,Strafe when bound to mouse button?
	-- TurnOrAction(lock) and FramesOnScreen,CursorBusy(release)?  -> priority: TurnOrAction(lock)
	if  self.CommandsLockingWithFrame  then  return true, 'TurnOrAction,MoveAndSteer'  end
	
	-- FramesOnScreen,CursorBusy(release) and Move,Strafe(lock)?  -> priority: CursorBusy(release)
	if  UnmouseableFrameOnScreen()  then  return false, 'FramesOnScreen'  end
	if  CursorHasItem()  then  return false, 'CursorHasItem'  end
	if  SpellIsTargeting()  then  return false, 'SpellIsTargeting'  end
	
	-- Move,Strafe(lock) or CombatMode enabled
	if  self.CommandsLocking  then  return true, 'Move,Strafe'  end
	if  combatModeAddonSwitch  then  return true, 'CombatMode'  end
	
	return  false, 'NoCauses'
end




