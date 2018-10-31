

Hooks= Hooks or {}


-- Based on FrameXML/ItemRef.lua
function Hooks.SetItemRef(link, text, button, chatFrame)
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
--[[
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
--]]
end

-- TODO: ToggleTalentTab(tab) caused tainting of Spell Book, not this
hooksecurefunc('SetItemRef', Hooks.SetItemRef)

