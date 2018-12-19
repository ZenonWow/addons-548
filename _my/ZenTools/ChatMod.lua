--[[ To change the moderated channel:
right-click a player in the Chat Channels window,
the selected channel will be the moderated channel.
Alternatively:
Enable the worldchannel languages you moderate, to have them 1 click away.
--]]
ChatMod= ChatMod or {}
ChatMod.PopupButtons= {
	'CHAT_KICK_AUTO',
	--'CHAT_KICK_EN',
	--'CHAT_KICK_ES',
	--'CHAT_KICK_FR',
	--'CHAT_KICK_RU',
	--'CHAT_KICK_DE',
	--'CHAT_KICK',	-- CHAT_KICK does not show up. It is builtin by blizzard, and might be disabled by some logic.
}
UnitPopupButtons.CHAT_KICK_EN = { channelName= 'world_en' }
UnitPopupButtons.CHAT_KICK_ES = { channelName= 'world_es' }
UnitPopupButtons.CHAT_KICK_FR = { channelName= 'world_fr' }
UnitPopupButtons.CHAT_KICK_RU = { channelName= 'world_ru' }
UnitPopupButtons.CHAT_KICK_DE = { channelName= 'world_de' }
	
ChatMod.AutoChannel= 'world_en'
local function GetPopupButtonText(channelName)
	return ChatMod.Messages.ButtonTextPrefix .. (channelName or '...?')
end


--[[ Change the moderated channel:
/run  ChatMod.AutoChannel= 'world_es'

Debug watch the last popup menu / kick button:
/dump ChatModMenu
/dump ChatModButton
--]]

--[[ To change the undersignee:
/run  ChatMod.Messages.signee= ChatMod.Messages.Blingtron5000_spell
/run  ChatMod.Messages.signee= ChatMod.Messages.Jeeves_spell
--]]
ChatMod.Messages= {
	ButtonTextPrefix= 'Kick from ',
	
	Message_url=   "We kindly inform You about your temporary removal from %s channel, as a reminder to read the world channel rules found on the forum: http://us.forum.firestorm-servers.com/index.php?/topic/7744-world-channel-rules/",
	Message_long=  "We kindly inform You about your temporary removal from %s channel, as a reminder to read the world channel rules found on the forum.",
	Message_short= "We kindly inform You about your temporary removal from %s channel.",
	
	Message_thank= "Thank you for improving the atmosphere! ",

	ChatRobo_spell= "Kind regards from the savage, yet generous |cff66bbff|Hspell:161414|h[Chat-Rob-O'Tron]|h|r",
	ChatRobo_item=  "Kind regards from the savage, yet generous |cffa335ee|Hitem:111821::::::::110:::::|h[Chat-Rob-O'Tron]|h|r",
	Blingtron5000_spell= "Kind regards from the savage, yet generous |cff66bbff|Hspell:161414|h[Blingtron 5000]|h|r",
	Blingtron5000_item=  "Kind regards from the savage, yet generous |cffa335ee|Hitem:111821::::::::110:::::|h[Blingtron 5000]|h|r",
	Jeeves_spell= "Kind regards from your gentleman robot butler |cff66bbff|Hspell:67826|h[Jeeves]|h|r",
	Jeeves_item=  "Kind regards from your gentleman robot butler |cffa335ee|Hitem:49040::::::::110:::::|h[Jeeves]|h|r",
	ChatRobo= "Chat-Rob-O'Tron",
	-- wowhead spell color: cffffd000, item color: cffa335ee, ingame spell: cff71d5ff, advanture: cff66bbff
}
ChatMod.Messages.message1= ChatMod.Messages.Message_url
ChatMod.Messages.message2= ChatMod.Messages.Message_thank		-- ends with " "
ChatMod.Messages.signee= ChatMod.Messages.ChatRobo_spell


local function CHAT_KICK_Func(button)
	-- in CHAT_ROSTER (chat frame) dropdown the channelName is known
	-- local menuName= UIDROPDOWNMENU_INIT_MENU.which
	local action= button.value		-- 'CHAT_KICK_AUTO'  or  'CHAT_KICK_EN', etc.
	local channelName= button.channelName
	--local channelName= UIDROPDOWNMENU_INIT_MENU.channelName  or  template.channelName  or  ChatMod.AutoChannel  or  ''
	local playerName= UIDROPDOWNMENU_INIT_MENU.name
	if  not channelName  then  print('ChatMod error: channelName == nil') ; return  end
	if  not playerName   then  print('ChatMod error: playerName == nil')  ; return  end
	
	ChannelKick(channelName, playerName)
	
	--[[
	This message informing the player will enable him/her to whisper you and ask for a reason.
	If your time and patience allows, respond with a link to the rules on the forum, and the section they violated.
	Please respond kindly, or do not respond at all. A little kindness goes a long way.
	--]]
	ChatMod.Messages.message2= ChatMod.Messages.message2 or ""
	ChatMod.Messages.signee= ChatMod.Messages.signee or ""
	local message= ChatMod.Messages.message1:format(channelName)
	local message2= nil
	if  250 > strlen(message) + strlen(ChatMod.Messages.message2) + strlen(ChatMod.Messages.signee)  then
		-- fits in one message (bit less than the 255 max)
		message= message .." ".. ChatMod.Messages.message2 .. ChatMod.Messages.signee
	else
		message2= ChatMod.Messages.message2 .. ChatMod.Messages.signee
	end
  SendChatMessage(message, 'WHISPER', nil, playerName)
  if  message2  then  SendChatMessage(message2, 'WHISPER', nil, playerName)  end
end




-- Insert the button names into menu after another button, or at the end.
-- Run once to modify the popup templates
local function ChatMod_AddPopupButtons(menu, afterButton, ...)
	-- list button names starting with 3rd parameter
	local buttonNames= {...}
	-- or pass one array of the names as the 3rd parameter
	if  type(buttonNames[1]) == 'table'  then  buttonNames= buttonNames[1]  end
	if  not buttonNames  or  #buttonNames == 0  then
		print('ChatMod error: buttonNames empty')
		return
	end
	
	local insertAt= #menu + 1
	if  afterButton  then
		for  i= 1,#menu  do  if  menu[i] == afterButton  then
			-- insert after this
			insertAt= i + 1
			break
		end end
	end
	-- if button is there already, do nothing
	if  insertAt  and  menu[insertAt] == ChatMod.PopupButtons[1]  then  return  end
	insertAt= insertAt  or  #menu + 1
	
	for  i,name  in  ipairs(buttonNames)  do
		table.insert(menu, insertAt, name)
		insertAt= insertAt + 1
	end
end



local function ChatMod_PatchButtons()
	-- Chat Channels (CHAT_ROSTER) will only show one button for the selected channel
	-- Remember the last channel selected in Chat Channels window (CHAT_ROSTER popup)
	ChatMod.AutoChannel= UIDROPDOWNMENU_INIT_MENU.channelName  or  ChatMod.AutoChannel
  for  i = 1,UIDROPDOWNMENU_MAXBUTTONS  do
    local button= _G["DropDownList" .. UIDROPDOWNMENU_MENU_LEVEL .. "Button" .. i];
		if  not button  then  break  end
		
		local template= ChatMod.PopupButtons[button.value]
    if  template  then
			_G.ChatModButton= button		-- for debugging only
			button.func= CHAT_KICK_Func
			button.channelName=  template.channelName  or  ChatMod.AutoChannel  or  ''
			
			if  button.channelName ~= template.channelName  then
				-- The original UnitPopup_ShowMenu() already did button:SetText(template.text)
				-- If channelName is overridden or dynamic, then update button text to reflect it.
				button:SetText(GetPopupButtonText(button.channelName))
			end
		end
	end
end

-- Patch the popup buttons to call the click handler CHAT_KICK_Func.
-- This solution from Prat addon hooks UnitPopup_ShowMenu to add the button.
local function ChatMod_OnShowMenu(dropdownMenu, which, unit, name, userData, ...)
	--print('UnitPopup_ShowMenu')
	_G.ChatModMenu= { dropdownMenu, which, unit, name, userData, ... }		-- for debugging only
	ChatMod_PatchButtons()
end

-- This is an older solution to patching the popup buttons by hooking ToggleDropDownMenu.
-- Hooking UnitPopup_ShowMenu above is a better choice, this one remains only for experimentation.
local function ChatMod_SetupMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
	print('ToggleDropDownMenu')
	if  dropDownFrame  and  level  then
		-- Just a wrapper for the new code.
		ChatMod_PatchButtons()
	else
		print('|cff66bbffChatMod NOT updating: no dropDownFrame or level|r')
	end
end



-- Load/hook. Run only once.
local ChatMod_Loaded= false
local function ChatMod_OnLoad()
	if  ChatMod_Loaded  then  return  end
	--hooksecurefunc('ToggleDropDownMenu', ChatMod_SetupMenu)
	hooksecurefunc('UnitPopup_ShowMenu', ChatMod_OnShowMenu)
	ChatMod_Loaded= true
	
	for  _,name  in  ipairs(ChatMod.PopupButtons)  do
		local template= UnitPopupButtons[name]
		if  not template  then
			template= {}
			UnitPopupButtons[name]= template
		end
		ChatMod.PopupButtons[name]= template
		template.dist= template.dist or 0		-- necessary default
		template.text= GetPopupButtonText(template.channelName)
	end
	
	ChatMod_AddPopupButtons(UnitPopupMenus.CHAT_ROSTER,		'OTHER_SUBSECTION_TITLE', 'CHAT_KICK_AUTO')
	ChatMod_AddPopupButtons(UnitPopupMenus.FRIEND,				'OTHER_SUBSECTION_TITLE', ChatMod.PopupButtons)
	ChatMod_AddPopupButtons(UnitPopupMenus.PLAYER,				'OTHER_SUBSECTION_TITLE', ChatMod.PopupButtons)
	--ChatMod_AddPopupButtons(UnitPopupMenus.PARTY,				'OTHER_SUBSECTION_TITLE', ChatMod.PopupButtons)
	--ChatMod_AddPopupButtons(UnitPopupMenus.RAID_PLAYER,	'OTHER_SUBSECTION_TITLE', ChatMod.PopupButtons)
end



ChatMod_OnLoad()

