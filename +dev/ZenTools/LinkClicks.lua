local ADDON_NAME, private = ...
local LinkClicks = {}


--[[
function LinkClicks.HandleModifiedItemClick(link)
	if  LinkClicks.lastItemLink == link  then  return  end
	print( "ModifiedItemClick (raw): ".. link:gsub('|', '||') )
end

function LinkClicks.ChatEdit_InsertLink(link)
	print( "Chat-linked (raw): ".. link:gsub('|', '||') )
	LinkClicks.lastItemLink = link
end

function LinkClicks.SetItemRef(link)
	print( "Link clicked (raw): ".. link:gsub('|', '||') )
end

function LinkClicks.SendWho(query)
	ShowWhoPanel()
end

hooksecurefunc('HandleModifiedItemClick', LinkClicks.HandleModifiedItemClick)
hooksecurefunc('ChatEdit_InsertLink', LinkClicks.ChatEdit_InsertLink)
hooksecurefunc('SetItemRef', LinkClicks.SetItemRef)
hooksecurefunc('SendWho', LinkClicks.SendWho)
--]]




function RunFrameScript(frame, scriptName, ...)
	if  not frame  then  return nil  end
	local frameScript = frame:GetScript(scriptName)
	if  not frameScript  then  return  false  end
	return true, frameScript(frame, event, ...)
end

function SendFrameEvent(frame, event, ...)
	return RunFrameScript(frame, 'OnEvent', event, ...)
end

--[[
function SendFrameEvent(frame, event, ...)
	if  not frame  then  return nil  end
	local frameOnEvent = frame:GetScript('OnEvent')
	if  not frameOnEvent  then  return  false  end
	return  true, frameOnEvent(frame, event, ...)
end
--]]

--[[
Returns: name, rebuiltLink (player link rebuilt without chat info)
nil    if failed to parse
false  if not a player/playerGM/BNplayer type link
--]]
function ParseChatLinkPlayer(link)
	if  type(link) ~= 'string'  then  return nil  end
	--assert(linkRef:sub(1,2) ~= "|H", "Expecting the first part of the link between  |H  and  |h")
	--[[
	local isFullLink =  linkRef:sub(1,2) == "|H"
	if  isFullLink  then  linkRef = strsplit('|', linkRef:sub(3))  end
	--]]
	local linkRef =  link:match("|H([^|]*)")  or  link
	local linkType, name, lineid, chatType, chatTarget, extra = strsplit(":", linkRef)
	
	if  linkType == 'player'  or  linkType == 'playerGM'  then
		return name, "|H"..linkType..":"..name.."|h"..name.."|h"
	end
	if  linkType == 'BNplayer'  then
		local presenceID  -- comes first, shift other parts
		presenceID, lineid, chatType, chatTarget  =  lineid, chatType, chatTarget, extra
		return name, "|H"..linkType..":"..name.."|h"..name.."|h"
	end
	return false
end


function LinkClicks.SendChatLink(linkRef, fullLink, mouseButton, sourceFrame)
	-- The focused editbox has priority over registered frames.
	local editbox = GetCurrentKeyBoardFocus()
	local ran, consumed = RunFrameScript(editbox, 'OnChatLink', fullLink, linkRef, sourceFrame)
	-- If it handled the link then the frames won't be notified.
	if  ran and consumed  then  return true  end
	
	-- Builtin: send to BrowseName (auction search), MacroFrameText, TradeSkillFrameSearchBox
	consumed =  consumed  or  ChatEdit_InsertLink(text)
	
	-- Iterate frames registered for the event
	local frames = { GetFramesRegisteredForEvent('CHATLINK') }
	-- All frames receive the event.
	for  i, frame  in ipairs(frames) do
		-- Run only one of the frame's possible handlers
		local ran, handled =
			RunFrameScript(frame, 'OnChatLink', fullLink, linkRef, sourceFrame)
			or  SendFrameEvent(frame, 'CHATLINK', fullLink, linkRef, sourceFrame)
		-- If any frame handles it then it's considered consumed.
		consumed =  consumed  or  ran and handled
	end
	
	return consumed
end


--ChatFrame_OnHyperlinkShow(self, link, text, mouseButton)
--ChatFrame_OnHyperlinkShow(sourceFrame, linkRef, fullLink, mouseButton)    == ChatFrameTemplate:GetScript('OnHyperlinkClick') -> SetItemRef(linkRef, fullLink, mouseButton, sourceFrame)
--function LinkClicks.OnHyperlinkClick(sourceFrame, linkRef, fullLink, mouseButton)
--function LinkClicks.OnChatLinkClick(sourceFrame, linkRef, fullLink, mouseButton)
function LinkClicks.SetItemRefRawHook(linkRef, fullLink, mouseButton, sourceFrame)
	print("SetItemRefRawHook(".. string.join(tostringall( link, text, mouseButton, (sourceFrame and sourceFrame:GetName() or '<source frame unknown>') )) ..")")
	if  IsModifiedClick('CHATLINK')  then
		if  MacroFrameText  then  MacroFrameText:SetScript('OnChatLink', MacroFrameText_OnChatLink)  end
		todo(fullLink, linkRef, sourceFrame)
		if  LinkClicks.SendChatLink(linkRef, fullLink, mouseButton, sourceFrame)  then  return true  end
	end
	return  LinkClicks.hooks.SetItemRef(linkRef, fullLink, mouseButton, sourceFrame)
end


function LinkClicks.HookSetItemRef(enable)
	if  enable  then
		LinkClicks.hooks = LinkClicks.hooks  or  {}
		LinkClicks.hooks.SetItemRef = LinkClicks.hooks.SetItemRef  or  SetItemRef
		SetItemRef = LinkClicks.SetItemRefRawHook
	else
		SetItemRef = LinkClicks.hooks.SetItemRef  or  SetItemRef
	end
end

--[[
/run LinkClicks.HookSetItemRef( true )
/run LinkClicks.HookSetItemRef( false )
--]]




local function StaticPopupEditBox_OnChatLink(editBox, fullLink, linkRef, sourceFrame)
	if  not editBox:IsVisible()  then  return false  end
	local name, link = ParseChatLinkPlayer(linkRef)
	
	if  not name  then  return false  end
	self:SetText(name)
	return true
end


local function ChatFrameEditBox_OnChatLink(editBox, fullLink, linkRef, sourceFrame)
	if  not editBox:IsVisible()  then  return false  end
	--[[ insert any link, not just player names
	local name, link = ParseChatLinkPlayer(linkRef)
	if  not name  then  return false  end
	--]]
	--[[
	-- Add a space at the end if there is none
	local text = self:GetText()  -- todo: use cursor position
	if  0 < #text  and  text[#text] ~= " "  then  name = " "..name  end
	--]]
	self:Insert(fullLink)
	return true
end


local function MacroFrameText_OnChatLink(editBox, text, linkRef, sourceFrame)
	local item;
	if ( strfind(text, "item:", 1, true) ) then
		item = GetItemInfo(text);
	end
	local cursorPosition = MacroFrameText:GetCursorPosition();
	if (cursorPosition == 0 or strsub(MacroFrameText:GetText(), cursorPosition, cursorPosition) == "\n" ) then
		if ( item ) then
			if ( GetItemSpell(text) ) then
				MacroFrameText:Insert(SLASH_USE1.." "..item.."\n");
			else
				MacroFrameText:Insert(SLASH_EQUIP1.." "..item.."\n");
			end
		else
			MacroFrameText:Insert(SLASH_CAST1.." "..text.."\n");
		end
	else
		MacroFrameText:Insert(item or text);
	end
end

function todo(text, linkRef, sourceFrame)
	-- From ChatEdit_InsertLink(text)
	if ( BrowseName and BrowseName:IsVisible() ) then
		local item;
		if ( strfind(text, "battlepet:") ) then
			local petName = strmatch(text, "%[(.+)%]");
			item = petName;
		elseif ( strfind(text, "item:", 1, true) ) then
			item = GetItemInfo(text);
		end
		if ( item ) then
			BrowseName:SetText(item);
			return true;
		end
	end

	if ( TradeSkillFrame and TradeSkillFrame:IsShown() )  then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = GetItemInfo(text);
		end
		if ( item ) then
			TradeSkillFrameSearchBox:SetFontObject("ChatFontSmall");
			TradeSkillFrameSearchBoxSearchIcon:SetVertexColor(1.0, 1.0, 1.0);
			TradeSkillFrameSearchBox:SetText(item);
			return true;
		end
	end
end



--[[
do
	--if  MacroFrameText  then  MacroFrameText:SetScript('OnChatLink', MacroFrameText_OnChatLink)  end
	for  i = 1, STATICPOPUP_NUMDIALOGS  do
		local editBox = _G["StaticPopup"..i.."EditBox"]
		editBox:SetScript('OnChatLink', StaticPopupEditBox_OnChatLink)
	end

	for  i = 1, NUM_CHAT_WINDOWS  do
		local editBox = _G["ChatFrame"..i].editBox
		editBox:SetScript('OnChatLink', ChatFrameEditBox_OnChatLink)
	end
end


1x ZenTools\LinkClicks.lua:223: StaticPopup1EditBox doesn't have a "OnChatLink" script
[game engine]:: ?
[game engine]:: in function 'SetScript'
ZenTools\LinkClicks.lua:223: in main chunk

Locals:
(*temporary) = StaticPopup1EditBox {
 0 = <userdata>
}
(*temporary) = "OnChatLink"
(*temporary) = <function> defined @ZenTools\LinkClicks.lua:139

--]]




-- SetItemRef calls ChatEdit_InsertLink(name) with only the name, not the link


--[[ ChatEdit_InsertLink() does:
-- activeWindow:Insert(" "..text);    -- if ChatEdit_GetActiveWindow();
-- BrowseName:SetText(item);    -- Auction House search field
-- MacroFrameText:Insert()
-- TradeSkillFrameSearchBox:SetText(item);
--]]

--[[ ChatEdit_InsertLink() is called by builtin UI:
-- FrameXML:
-- SetItemRef calls ChatEdit_InsertLink(name) with only the name, not the link
-- ItemButtonTemplate.lua/HandleModifiedItemClick(link):  if ( IsModifiedClick("CHATLINK") ) then ChatEdit_InsertLink
-- QuestFrame:  ChatEdit_InsertLink(GetSpellLink(self.spellID));
-- QuestInfo:  ChatEdit_InsertLink(GetQuestLogSpellLink());  or  ChatEdit_InsertLink(GetQuestSpellLink());
-- QuestLogTitleButton_OnClick:  if ChatEdit_GetActiveWindow() then ChatEdit_InsertLink(questLink);
-- RaidInfoInstance_OnClick:  ChatEdit_InsertLink(GetSavedInstanceChatLink(self:GetID()));
-- SpellButton_OnModifiedClick
-- CoreAbilitySpellTemplate
-- SpellFlyoutButton_OnClick
-- WatchFrameLinkButtonTemplate_OnClick:  if ChatEdit_GetActiveWindow() then ChatEdit_InsertLink(questLink);
-- WatchFrameItem_OnClick:  if ( ChatEdit_GetActiveWindow() ) then ChatEdit_InsertLink(link);
-- ScorePlayer_OnClick:  if ( ChatEdit_GetActiveWindow() ) then ChatEdit_InsertLink(self.text:GetText());
-- AddOns:
-- Blizzard_CombatLog_SpellMenuClick
-- Blizzard_CombatLog.lua/SetItemRef() override
-- EncounterInstanceButtonTemplate:  ChatEdit_GetActiveWindow
-- GlyphFrameGlyph_OnClick:  ChatEdit_GetActiveWindow
-- GuildFrame_LinkItem:  ChatFrame_OpenChat(itemLink);    OPENS
-- InspectGlyphFrameGlyph_OnClick:  ChatEdit_GetActiveWindow
-- InspectTalentFrameTalent_OnClick:  ChatEdit_GetActiveWindow
-- PetJournalListItem_OnClick, PetJournalDragButton_OnClick, PetJournalPetLoadoutDragButton_OnClick, PetJournalPetCard_OnClick
-- MountListDragButton_OnClick, MountListItem_OnClick
-- PlayerTalentFrameTalent_OnClick
-- TradeSkillLinkButton:  if activeEditBox then

function ChatEdit_GetActiveWindow()
	return ACTIVE_CHAT_EDIT_BOX;
end
--]]


--[[
if ( ChatEdit_GetActiveWindow() ) then
	ChatEdit_InsertLink(name)
if ( IsModifiedClick() ) then
	local fixedLink = GetFixedLink(text);
	HandleModifiedItemClick(fixedLink);
else
	FloatingPetBattleAbility_Show(tonumber(abilityID), tonumber(maxHealth), tonumber(power), tonumber(speed));
end
--]]



--[[
-- Based on FrameXML/ItemRef.lua
function LinkClicks.SetItemRef(link, text, button, chatFrame)
	if ( strsub(link, 1, 6) == "player" ) then
		local namelink, isGMLink
		if ( strsub(link, 7, 8) == "GM" ) then
			namelink = strsub(link, 10)
			isGMLink = true
		else
			namelink = strsub(link, 8)
		end
		
		local name, lineid, chatType, chatTarget = strsplit(":", namelink)
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				local staticPopup= StaticPopup_Visible("ADD_IGNORE")
				or  StaticPopup_Visible("ADD_MUTE")
				or  StaticPopup_Visible("ADD_FRIEND")
				or  StaticPopup_Visible("ADD_GUILDMEMBER")
				or  StaticPopup_Visible("ADD_RAIDMEMBER")
				or  StaticPopup_Visible("CHANNEL_INVITE")
				
				--FocusUnit(name)  -- can't do, it's protected function
				local openWhoFrame= not staticPopup  and  not ChatEdit_GetActiveWindow()
				if  openWhoFrame  then
					--SendWho(WHO_TAG_EXACT..name)
					ShowWhoPanel()
					WhoFrameEditBox:SetText(name)
					WhoFrameEditBox:HighlightText()
					WhoFrameEditBox:SetFocus()
				end
				
			elseif  button == "LeftButton"  then
				if  IsAltKeyDown()  then  InspectUnit(name)  end
			elseif  button == "RightButton"  then
				--if  IsShiftKeyDown()  then  InspectUnit(name)  end
				if  IsAltKeyDown()  then  InspectUnit(name)  end
				end
			end
		end
		return
	end
	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text)
		HandleModifiedItemClick(fixedLink)
	else
		ShowUIPanel(ItemRefTooltip)
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		end
		ItemRefTooltip:SetHyperlink(link)
	end
end
--]]

