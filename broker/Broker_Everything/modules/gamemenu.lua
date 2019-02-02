
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "GameMenu" -- L["Game Menu"]
local tt = nil
local last_click = 0
local iconCoords = "16:16:0:-1:64:64:4:56:4:56" --"16:16:0:-1:64:64:3:58:3:58"
local link = "|T%s:%s|t %s"
local link_disabled = "|T%s:%s:66:66:66|t "..C("gray", "%s")
local gmticket = {}
local customTitle = L[name]

local menu = {
	{name=CHARACTER_BUTTON, 	iconName="Character-{class}",	func=function() ToggleCharacter( "PaperDollFrame") end, }, 
	--{name=SPELLBOOK, 			iconName="Spellbook", 			click='SpellbookMicroButton', 		disabled=IsBlizzCon()}, 
	--{name=TALENTS, 				iconName="Talents", 			click='TalentMicroButton', 			disabled=UnitLevel("player")<10}, 
	--{name=ACHIEVEMENT_BUTTON, 	iconName="Achievments", 		click='AchievementMicroButton', 		}, 
	--{name=QUESTLOG_BUTTON, 		iconName="Questlog", 			click='QuestLogMicroButton', 		}, 
	--[[{name=LOOKINGFORGUILD, 		iconName="LFGuild", 			click='GuildMicroButton', 			disabled=(IsTrialAccount() or IsBlizzCon()), 
	get=function(v)
		if ns.player.faction=="Neutral" then
			v.disabled=true
		end
		if not v.disabled and IsInGuild() then
			v.name=GUILD
			v.iconName = "Guild"
		end
	end, 
	setIcon=function()
		--SetSmallGuildTabardTextures("player", 
	end}, --]]
	{name=SOCIAL_BUTTON, 		iconName="Friends", 		func=function() ToggleFriendsFrame( 1) end, 	disabled=IsTrialAccount()}, 
	--{name=PLAYER_V_PLAYER, 		iconName="PvP-{faction}", 	click='PVPMicroButton', 									disabled=(UnitLevel("player")<SHOW_PVP_LEVEL or IsBlizzCon())}, 
	{name=RAID_FINDER, 			iconName="Raidfinder", 		func=function() PVEFrame_ToggleFrame( 'GroupFinderFrame', RaidFinderFrame) end, 				disabled=(UnitLevel("player")<SHOW_LFD_LEVEL or IsBlizzCon())}, 
	{name=DUNGEONS_BUTTON, 		iconName="LFDungeon", 		func=function() PVEFrame_ToggleFrame( 'GroupFinderFrame', LFDParentFrame) end, 				disabled=(UnitLevel("player")<SHOW_LFD_LEVEL or IsBlizzCon())}, 
	--{name=MOUNTS, 				iconName="Mounts", 			func=function() if not PetJournalParent then PetJournal_LoadUI() end TogglePetJournal( 1) end, 	disabled=UnitLevel("player")<20}, 
	--{name=PET_JOURNAL, 			iconName="Pets", 			func=function() if not PetJournalParent then PetJournal_LoadUI() end TogglePetJournal( 2) end, 	}, 
	{name=ENCOUNTER_JOURNAL, 	iconName="EJ", 				func=function() ToggleEncounterJournal() end, 													iconCoords=""}, 
	--{name=BLIZZARD_STORE, 		iconName="Store", 			click='StoreMicroButton', 														disabled=IsTrialAccount()}, 
	{sep=true}, 
	{name=GAMEMENU_HELP, 		iconName="Help", 			func=function() ToggleHelpFrame() end, 	}, 
	{name=SYSTEMOPTIONS_MENU, 	iconName="SysOpts", 		func=function() ShowUIPanel( VideoOptionsFrame) end, 	}, 
	{name=KEY_BINDINGS, 		iconName="KeyBinds",	 	func=function() KeyBindingFrame_LoadUI() ShowUIPanel( KeyBindingFrame) end, 	}, 
	{name=UIOPTIONS_MENU, 		iconName="UiOpts", 			func=function() ShowUIPanel( InterfaceOptionsFrame) end, 	}, 
	{name=MACROS, 				iconName="Macros", 			func=function() ShowMacroFrame() end, 	}, 
	{name=MAC_OPTIONS, 			iconName="MacOpts", 		func=function() ShowUIPanel( MacOptionsFrame) end, 	 view=IsMacClient()==true}, 
	{name=ADDONS, 				iconName="Addons", 			view=(IsAddOnLoaded("OptionHouse") or IsAddOnLoaded("ACP") or IsAddOnLoaded("Ampere") or IsAddOnLoaded("stAddonManager")), 
	func=function()
		if IsAddOnLoaded("OptionHouse") then
			OptionHouse:Open(1)
		elseif IsAddOnLoaded("ACP") then
			ACP:ToggleUI()
		elseif IsAddOnLoaded("Ampere") then
			InterfaceOptionsFrame_OpenToCategory("Ampere")
		elseif IsAddOnLoaded("stAddonManager") then
			stAddonManager:LoadWindow()
		end
	end}, 
	--{sep=true}, 
	--{name=VIDEO_OPTIONS_WINDOWED.."/"..VIDEO_OPTIONS_FULLSCREEN, 
	--							iconName="Fullscreen", 		macro="/script SetCVar('gxWindow', 1 - GetCVar('gxWindow')) RestartGx()", 	--[[, view=IsMacClient()~=true]]}, 
	--{name=L["Reload UI"], 		iconName="ReloadUi", 		macro="/reload", 															}, 
	--{name=LOGOUT, 				iconName="Logout", 			macro="/logout", 															}, 
	--{name=EXIT_GAME, 			iconName="ExitGame", 		macro="/quit", 																}
}


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --

-- broker button icon
I[name]              = {iconfile="Interface\\Addons\\"..addon.."\\media\\stuff"}

-- game menu entry icons
I["gm_Character-neutral"] = {iconfile="Interface\\buttons\\ui-microbutton-"..ns.player.class, coordsStr="16:16:0:-1:64:64:5:54:32:59"}
--I["gm_Character-mage"]    = {iconfile=""}

I["gm_Spellbook"]         = {iconfile="Interface\\ICONS\\inv_misc_book_09"}
I["gm_Talents"]           = {iconfile="Interface\\ICONS\\ability_marksmanship"}
I["gm_Achievments"]       = {iconfile="Interface\\buttons\\ui-microbutton-achievement-up", coordsStr="16:16:0:-1:64:64:5:54:32:59"}
I["gm_Questlog"]          = {iconfile="interface\\lfgframe\\lfgicon-quest"}
I["gm_LFGuild"]           = {iconfile="Interface\\buttons\\UI-MicroButton-Guild-Disabled-"..ns.player.faction, coordsStr="16:16:0:-1:64:64:8:54:32:59"}
I["gm_Guild"]             = {iconfile="Interface\\buttons\\UI-MicroButton-Guild-Disabled-"..ns.player.faction, coordsStr="16:16:0:-1:64:64:8:54:32:59"}
I["gm_Friends"]           = {iconfile="Interface\\ICONS\\achievement_guildperk_everybodysfriend"}
I["gm_PvP-neutral"]       = {iconfile="Interface\\minimap\\tracking\\BattleMaster", coordsStr="16:16:0:-1:16:16:0:16:0:16"}
I["gm_PvP-alliance"]      = {iconfile="interface\\pvpframe\\pvp-currency-Alliance", coordsStr="16:16:0:-1:16:16:0:16:0:16"}
I["gm_PvP-horde"]         = {iconfile="interface\\pvpframe\\pvp-currency-Horde", coordsStr="16:16:0:-1:16:16:0:16:0:16"}
I["gm_Raidfinder"]        = {iconfile="Interface\\ICONS\\inv_helmet_06"}
I["gm_LFDungeon"]         = {iconfile="Interface\\ICONS\\levelupicon-lfd"}
I["gm_Mounts"]            = {iconfile="Interface\\ICONS\\mountjournalportrait"}
I["gm_Pets"]              = {iconfile="Interface\\ICONS\\inv_box_petcarrier_01"}
I["gm_EJ"]                = {iconfile="Interface\\buttons\\UI-MicroButton-EJ-Up", coordsStr="16:16:0:-1:64:64:8:54:32:59"}
I["gm_Store"]             = {iconfile="Interface\\ICONS\\WoW_Store"}
I["gm_Help"]              = {iconfile="Interface\\ICONS\\inv_misc_questionmark"}
I["gm_SysOpts"]           = {iconfile="Interface\\ICONS\\inv_gizmo_02"}
I["gm_KeyBinds"]          = {iconfile="interface\\macroframe\\macroframe-icon"}
I["gm_UiOpts"]            = {iconfile="Interface\\ICONS\\inv_gizmo_02"}
I["gm_Macros"]            = {iconfile="interface\\macroframe\\macroframe-icon"}
I["gm_MacOpts"]           = {iconfile="Interface\\ICONS\\inv_gizmo_02"}
I["gm_Addons"]            = {iconfile="Interface\\ICONS\\inv_misc_enggizmos_30"}
I["gm_Fullscreen"]        = {iconfile="Interface\\Addons\\"..addon.."\\media\\stuff", coordsStr="16:16:0:-1:16:16:0:16:0:16"}
I["gm_ReloadUi"]          = {iconfile="Interface\\ICONS\\achievement_guildperk_quick and dead"}
--I["gm_Logout"]            = {iconfile="Interface\\buttons\\UI-PAIDCHARACTERCUSTOMIZATION-BUTTON", coordsStr="16:16:0:-1:128:128:76:116:11:51"}
I["gm_Logout"]            = {iconfile="Interface\\icons\\racechange"}
I["gm_ExitGame"]          = {iconfile="Interface\\ICONS\\inv_misc_enggizmos_27"}
I["gm_gmticket"]          = {iconfile="Interface\\CHATFRAME\\UI-CHATICON-BLIZZ", coordsStr="0:2"}
I["gm_gmticket_edit"]     = {iconfile="Interface\\ICONS\\inv_misc_note_05"}
--I["gm_gmticket_cancel"]   = {iconfile="Interface\\ICONS\\inv_misc_note_05"}
I["gm_gmticket_cancel"]   = {iconfile="Interface\\buttons\\ui-grouploot-pass-up",coordsStr="16:16:0:-1:32:32:2:32:2:32"}



---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to allow you to do...Stuff! Switch to windowed mode, reload ui, logout and quit."], 
	events = {
		"UPDATE_WEB_TICKET"
	}, 
	updateinterval = nil, -- 10
	config_defaults = {
		customTitle = nil, 
		hideSection2 = false, 
		hideSection3 = false, 
		disableOnClick = false, 
		customTooltipTitle = false,
		showGMTicket = true
	}, 
	config_allowed = nil, 
	config = {
		height = 85, 
		elements = {
			{
				type = "check",
				name = "hideSection2",
				label = L["Hide section 2"],
				desc = L["Hide section 2 in tooltip"]
			}, 
			{
				type = "check",
				name = "hideSection3",
				label = L["Hide section 3"],
				desc = L["Hide section 3 in tooltip"],
			}, 
			{
				type = "check",
				name = "disableOnClick",
				label = L["Disable Click options"],
				desc = L["Disable the click options on broker button"], 
			}, 
			{ type = "next_row" },
			{
				type = "editbox",
				name = "customTitle",
				label = L["custom Title"],
				desc = L["Set your own Title instead of 'Game Menu'"],
				event = true, 
			}, 
			{
				type = "check",
				name = "customTooltipTitle",
				label = L["As tooltip title"],
				desc = L["Use custom title as tooltip title"]
			},
			{
				type = "check",
				name = "showGMTicket",
				label = L["Show GMTicket"],
				desc = L["Show GMTickets in tooltip and average wait time in broker button"]
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
StaticPopupDialogs["CONFIRM"] = {
	text = L["Are you sure you want to Reload the UI?"], 
	button1 = ACCEPT, 
	button2 = CANCEL, 
	OnAccept = function()
		ReloadUI()
	end, 
	timeout = 20, 
	whileDead = true, 
	hideOnEscape = true, 
	preferredIndex = 5, 
}

local function updateGMTicket()
	local obj = module.obj
	if Broker_EverythingDB[name].showGMTicket and gmticket.hasTicket and gmticket.ticketStatus~=LE_TICKET_STATUS_OPEN then
		local icon = I("gm_gmticket")
		obj.text = C("cyan",SecondsToTime(gmticket.waitTime*60)) .. link:format(icon.iconfile,(icon.coordsStr or iconCoords),"")
	else
		gmticket.hasTicket = false
		module.onevent("BE_DUMMY_EVENT")
	end
end

------------------------------------
-- module (BE internal) functions --
------------------------------------

local function updateCustomTitle(dataobj)
	local modDB = module.modDB
	if  modDB.customTitle == ""  then  modDB.customTitle = nil  end
	customTitle = modDB.customTitle
	dataobj.text = customTitle
	-- dataobj.label =  not customTitle  and  L[name]
end

module.initbroker = updateCustomTitle
	
module.onevent = function(module, ...)
	local event, _ = ...

	if event == "UPDATE_WEB_TICKET" then
		_, gmticket.hasTicket, gmticket.numTickets, gmticket.ticketStatus, gmticket.caseIndex, gmticket.waitTime, gmticket.waitMsg = ...
		updateGMTicket()
	elseif event == "BE_DUMMY_EVENT" then
		updateCustomTitle(module.obj)
	end
end

module.onqtip = function(tt)
	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "LEFT")

	local line, column
	local section, secHide = 1, false
	local oneCell = Broker_EverythingDB[name].hideSection2 and Broker_EverythingDB[name].hideSection3
	local cell = 1

	tt.secureButtons = {}

	if Broker_EverythingDB[name].customTooltipTitle then
		tt:AddHeader(C("dkyellow", customTitle))
	else
		tt:AddHeader(C("dkyellow", L[name]))
	end
	tt:AddSeparator()

	for i, v in ipairs(menu) do
		if v.sep==true then
			section = section + 1
			secHide = (section==2 and Broker_EverythingDB[name].hideSection2) or (section==3 and Broker_EverythingDB[name].hideSection3)

			if not secHide then
				tt:AddSeparator()
				cell=1
			end
		elseif secHide then
			-- nothing
		else
			if v.get~=nil then v.get(v) end
			if v.disabled==nil then v.disabled=false end
			if v.view==nil then v.view=true end
			if v.name~=nil and v.view then
				if cell==1 then line, column = tt:AddLine() end
				local m=v.iconName:match("-%{(.*)%}")
				if m then
					v.iconName = string.gsub(v.iconName, "%{"..m.."%}", ns.player[m]:lower())
					local V = I("gm_"..v.iconName)
					if m=="class" and I["gm_"..v.iconName].iconfile=="interface\\icons\\inv_misc_questionmark" then
						v.iconName = "Character-neutral"
					end
				end
				local icon = I("gm_"..v.iconName)
				tt:SetCell(line, cell, (v.disabled and link_disabled or link):format((icon.iconfile or "interface\\icons\\inv_misc_questionmark"), (icon.coordsStr or iconCoords), v.name), nil, nil, oneCell and 2 or 1)
				if (not v.disabled) or not (InCombatLockdown() and (v.secure or v.click or v.macro)) then
					local e, f
					if v.secure~=nil then
						e, f = "OnEnter", function(self)
							ns.secureButton(self, { {typeName="type", typeValue="click", attrName="clickbutton", attrValue=""}, {typeName="type", typeValue="onmouseup", attrName="_onmouseup", attrValue=v.secure} }, v.name)
							tinsert(tt.secureButtons,v.name)
						end
					elseif v.click~=nil then
						e, f = "OnEnter", function(self)
							ns.secureButton(self, { {typeName="type", typeValue="click", attrName="clickbutton", attrValue=_G[v.click]} }, v.name)
							tinsert(tt.secureButtons,v.name)
						end
					elseif v.macro~=nil then
						e, f = "OnEnter", function(self)
							ns.secureButton(self, { {typeName="type", typeValue="macro", attrName="macrotext", attrValue=v.macro} }, v.name)
							tinsert(tt.secureButtons,v.name)
						end
					else
						e, f = "OnMouseUp", function()
							ns.hideTooltip(tt, nil, true)
							v.func()
						end
					end
					tt:SetCellScript(line, cell, e, f)
				end
				if not oneCell then
					if cell==1 then cell=2 else cell=1 end
				end
			end
		end
	end

	-- Open GM Ticket info Area
	if Broker_EverythingDB[name].showGMTicket and gmticket.hasTicket and (gmticket.ticketStatus~=LE_TICKET_STATUS_RESPONSE or gmticket.ticketStatus~=LE_TICKET_STATUS_SURVEY) then
		waitTime, waitMsg, ticketStatus = gmticket.waitTime,gmticket.waitMsg,gmticket.ticketStatus
		tt:AddSeparator(5,0,0,0,0)
		line, column = tt:AddLine()
		local icon = I("gm_gmticket")
		tt:SetCell(line,1,link:format(icon.iconfile,(icon.coordsStr or iconCoords),C("ltblue",TICKET_STATUS)),tt:GetHeaderFont(),nil,2)
		tt:AddSeparator()
		line,column = tt:AddLine()
		local edit,cancel = I("gm_gmticket_edit"),I("gm_gmticket_cancel")
		tt:SetCell(line,1,link:format(edit.iconfile,(edit.coordsStr or iconCoords),L["Edit ticket"]))
		tt:SetCell(line,2,link:format(cancel.iconfile,(cancel.coordsStr or iconCoords),L["Cancel ticket"]))
		tt:SetCellScript(line,1,"OnMouseUp",function(self,button)
			HelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET)
			if gmticket.caseIndex then
				HelpBrowser:OpenTicket(gmticket.caseIndex)
			end
		end)
		tt:SetCellScript(line,2,"OnMouseUp",function(self,button) 
			if not StaticPopup_Visible("HELP_TICKET_ABANDON_CONFIRM") then
				StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM")
			end
		end)
		if (ticketStatus == LE_TICKET_STATUS_NMI) then -- ticketStatus = 3
			line,column = tt:AddLine()
			tt:SetCell(line,1,TICKET_STATUS_NMI,nil,nil,2)
		elseif (ticketStatus == LE_TICKET_STATUS_OPEN) then -- ticketStatus = 1
			line,column = tt:AddLine()
			if (waitMsg and waitTime > 0) then
				tt:SetCell(line,1,waitMsg:format(SecondsToTime(waitTime*60)),nil,nil,2)
			elseif (waitMsg) then
				tt:SetCell(line,1,waitMsg,nil,nil,2)
			elseif (waitTime > 120) then
				tt:SetCell(line,1,GM_TICKET_HIGH_VOLUME,nil,nil,2)
			elseif (waitTime > 0) then
				tt:SetCell(line,1,format(GM_TICKET_WAIT_TIME, SecondsToTime(waitTime*60)),nil,nil,2)
			else
				tt:SetCell(line,1,GM_TICKET_UNAVAILABLE,nil,nil,2)
			end
		elseif (ticketStatus == LE_TICKET_STATUS_SURVEY) then -- ticketStatus = 2
		elseif (ticketStatus == LE_TICKET_STATUS_RESPONSE) then -- ticketStatus = 4
			
		end
	end
	--

	if Broker_EverythingDB[name].disableOnClick or (not Broker_EverythingDB.showHints) then return end

	tt:AddSeparator(4, 0, 0, 0, 0)
	line, column = tt:AddLine()
	tt:SetCell(line, 1, 
		C("copper", L["Left-click"]).." || "..C("green", L["Logout"])
		.."|n"..
		C("copper", L["Right-click"]).." || "..C("green", L["Quit game"])
		.."|n"..
		C("copper", L["Shift+Left-click"]).." || "..C("green", L["Reload UI"])
	, nil, nil, 2)

end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module.mouseOverTooltip = true

module.onclick = function(display, button)
	if button == "LeftButton" then
		ns.setStayOpen(tt, true, 3)
	elseif button == "RightButton" then
		ns.commands.options.func()
	end

	if Broker_EverythingDB[name].disableOnClick then return end
--[[
	local shift = IsShiftKeyDown() or -1
	local cv = 0

	if button == "RightButton" then
		cv = 1 * shift
	elseif button == "LeftButton" then
		cv = 2 * shift
	end

	if last_click ~= cv then
		last_click = cv
		return
	end

	-- only for windowed mode switching...
	last_click = 0

	if shift > 0 then
		if button == "LeftButton" then
			ReloadUI()
		end
	else
		if button == "LeftButton" then
			Logout()
		elseif button == "RightButton" then
			Quit()
		end
	end
	--]]
end


-- final module registration --
-------------------------------
ns.modules[name] = module

