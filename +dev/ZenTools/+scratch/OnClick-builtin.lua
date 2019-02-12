-- FrameXML/ItemRef.lua:
function SetItemRef(link, text, button, chatFrame) 
	if ( IsModifiedClick("CHATLINK") ) then 
		if ( ChatEdit_GetActiveWindow() ) then
			ChatEdit_InsertLink(name);
		else
			SendWho(WHO_TAG_EXACT..name);
		end 
	elseif ( button == "RightButton" and (not isGMLink) ) then
		FriendsFrame_ShowDropdown(name, 1, lineid, chatType, chatFrame);
	else
		ChatFrame_SendTell(name, chatFrame);
	end
end

-- FrameXML/ChatFrame.xml:
			<OnHyperlinkClick>
				ChatFrame_OnHyperlinkShow(self, link, text, button);
			</OnHyperlinkClick> 
			
-- FrameXML/FriendsFrame.lua:
WhoFrame.selectedName = name
WhoFrame.selectedWho = index

-- FrameXML/UIPanelTemplates.xml:
<ScrollFrame name="InputScrollFrameTemplate" inherits="UIPanelScrollFrameTemplate" virtual="true"> 
	<Scripts>
		<OnHyperlinkEnter function="InlineHyperlinkFrame_OnEnter"/>
		<OnHyperlinkLeave function="InlineHyperlinkFrame_OnLeave"/>
		<OnHyperlinkClick function="InlineHyperlinkFrame_OnClick"/>
	</Scripts> 
</Frame>

-- FrameXML/UIPanelTemplates.lua:
function InlineHyperlinkFrame_OnClick(self, link, text, button)
	...
	SetItemRef(link, text, button);
end 


-- FrameXML/UnitPopup.lua  highlights:

function UnitPopup_OnClick (self)
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU;
	local button = self.value;
	local unit = dropdownFrame.unit;
	local name = dropdownFrame.name;
	local server = dropdownFrame.server;
	local fullname = name;

	if ( server and ((not unit and GetNormalizedRealmName() ~= server) or (unit and UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME)) ) then
		fullname = name.."-"..server;
	end

	local inParty = IsInGroup();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");

	if ( button == "TRADE" ) then 
	...
	end
end

UnitPopupButtons = {
	["CANCEL"] = { text = CANCEL, dist = 0, space = 1 },
	["TRADE"] = { text = TRADE, dist = 2 },
	["INSPECT"] = { text = INSPECT, dist = 0, disabledInKioskMode = true },
	["ACHIEVEMENTS"] = { text = COMPARE_ACHIEVEMENTS, dist = 1, disabledInKioskMode = true },
	["TARGET"] = { text = TARGET, dist = 0 },
	["IGNORE"]	= {
		dist = 0,
		text = function(dropdownMenu)
			return IsIgnored(dropdownMenu.name) and IGNORE_REMOVE or IGNORE;
		end,
	}, 
	["WHISPER"]	= { text = WHISPER, dist = 0 },
	["INVITE"]	= { text = PARTY_INVITE, dist = 0 }, 
	["SET_NOTE"]	= { text = SET_NOTE, dist = 0 }, 
	["LEAVE"] = { text = PARTY_LEAVE, dist = 0 }, 
	["PVP_FLAG"] = { text = PVP_FLAG, dist = 0, nested = 1 },
	["PVP_ENABLE"] = { text = ENABLE, dist = 0, checkable = 1, checkable = 1 },
	["PVP_DISABLE"] = { text = DISABLE, dist = 0, checkable = 1, checkable = 1 }, 
	["VEHICLE_LEAVE"] = { text = VEHICLE_LEAVE, dist = 0 },

	["SET_FOCUS"] = { text = SET_FOCUS, dist = 0 },
	["CLEAR_FOCUS"] = { text = CLEAR_FOCUS, dist = 0 },
	-- Voice Chat Related
	["MUTE"] = { text = MUTE, dist = 0 },
	["UNMUTE"] = { text = UNMUTE, dist = 0 },
	-- ...
}
 
-- First level menus  
UnitPopupMenus = {
	["PLAYER"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAF_GRANT_LEVEL", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "CANCEL" },
	["FRIEND"] = { "POP_OUT_CHAT", "TARGET", "SET_NOTE", "INTERACT_SUBSECTION_TITLE", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "IGNORE", "REMOVE_FRIEND", "REPORT_PLAYER", "PVP_REPORT_AFK", "CANCEL" },
	["FRIEND_OFFLINE"] = { "SET_NOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "REMOVE_FRIEND", "CANCEL" },
	["TARGET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["FOCUS"] = { "RAID_TARGET_ICON", "CLEAR_FOCUS", "OTHER_SUBSECTION_TITLE", "LARGE_FOCUS", "MOVE_FOCUS_FRAME", "CANCEL" },
	-- Second level menus
	["ADD_FRIEND_MENU"] = { "BATTLETAG_FRIEND", "CHARACTER_FRIEND" },
	["PVP_FLAG"] = { "PVP_ENABLE", "PVP_DISABLE"},
	["LOOT_METHOD"] = { "PERSONAL_LOOT", "GROUP_LOOT", "FREE_FOR_ALL", }
	-- ...
}

function UnitPopup_AddDropDownButton (info, dropdownMenu, cntButton, buttonIndex, level)
	...
	UIDropDownMenu_AddButton(info, level);
end


-- Prat-3.0  PopupMenu  modification:

function Prat_WhoIs()
	UnitPopupButtons["WHOIS"] = {
		text = "Who Is?",
		dist = 0,
		func = function()
			local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
			local name = dropdownFrame.name

			if name then
				SendWho(name)
			end
		end
	}
	tinsert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"] - 1, "WHOIS");

	Prat:RegisterDropdownButton("WHOIS")
end



-- PopupMenu  init:

ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor"); 

function FriendsFrameWhoButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		WhoFrame.selectedWho = _G["WhoFrameButton"..self:GetID()].whoIndex;
		WhoFrame.selectedName = _G["WhoFrameButton"..self:GetID().."Name"]:GetText();
		WhoList_Update();
	else
		local name = _G["WhoFrameButton"..self:GetID().."Name"]:GetText();
		FriendsFrame_ShowDropdown(name, 1);
	end
end 

function TargetFrameDropDown_Initialize (self)
	local id = nil;
	if ( UnitIsUnit("target", "player") ) then
		menu = "SELF";
		...
	elseif ( UnitIsPlayer("target") ) then
		id = UnitInRaid("target");
		if ( id ) then
			menu = "RAID_PLAYER";
		elseif ( UnitInParty("target") ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(self, menu, "target", name, id);
	end
end

function FocusFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "FOCUS", "focus", SET_FOCUS);
end	
	
function ChannelRosterDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "CHAT_ROSTER", nil, ChannelRosterDropDown.name);
end
 
function FriendsFrameDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "FRIEND", nil, FriendsDropDown.name);
end

function FriendsFrameOfflineDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "FRIEND_OFFLINE", nil, FriendsDropDown.name);
end
 

function ChatEdit_OnEscapePressed(editBox)
	if ( not AutoCompleteEditBox_OnEscapePressed(editBox) ) then
		ChatEdit_ClearChat(editBox);
	end
end




ChatFrame_SendTell
ChatEdit_InsertLink(text) / ChatEdit_TryInsertChatLink(link)
ChatEdit_GetLastTellTarget()

-- in FrameXML/UIDropDownMenu.lua:
UIDropDownMenu_AddButton

-- text widget after Enter:  self:ClearFocus();


