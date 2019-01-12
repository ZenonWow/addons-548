-- Addon private namespace
local ADDON_NAME, ns = ...
-- Addon global namespace
local BagSync = BagSync
-- Localization
local L = BAGSYNC_L
local ADDON_LABEL = "BagSync"

BINDING_HEADER_BAGSYNC = ADDON_LABEL
BINDING_NAME_BAGSYNCTOGGLESEARCH = L["Toggle Search"]
BINDING_NAME_BAGSYNCTOGGLETOKENS = L["Toggle Tokens"]
BINDING_NAME_BAGSYNCTOGGLEPROFILES = L["Toggle Profiles"]
BINDING_NAME_BAGSYNCTOGGLECRAFTS = L["Toggle Professions"]
BINDING_NAME_BAGSYNCTOGGLEBLACKLIST = L["Toggle Blacklist"]

SLASH_BAGSYNC1 = "/bagsync"
SLASH_BAGSYNC2 = "/bgs"



------------------------------
--    LibDataBroker-1.1	    --
------------------------------

BagSync.dataobj = _G.LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_LABEL, {
	type = "launcher",
	--icon = "Interface\\Icons\\INV_Misc_Bag_12",
	icon = "Interface\\AddOns\\BagSync\\media\\icon",
	label = ADDON_LABEL,
		
	OnClick = function(self, button)
		if button == 'LeftButton' and BagSync_SearchFrame then
			if BagSync_SearchFrame:IsVisible() then
				BagSync_SearchFrame:Hide()
			else
				BagSync_SearchFrame:Show()
			end
		elseif button == 'RightButton' and BagSync_TokensFrame then
			if bgsMinimapDD then
				ToggleDropDownMenu(1, nil, bgsMinimapDD, 'cursor', 0, 0)
			end
		end
	end,

	OnTooltipShow = function(self)
		self:AddLine(ADDON_LABEL)
		self:AddLine(L["Left Click = Search Window"])
		self:AddLine(L["Right Click = BagSync Menu"])
	end
})



------------------------------
--    Slash command /bgs    --
------------------------------

function BagSync.SlashCmd(msg)

	local a,b,c=strfind(msg, "(%S+)"); --contiguous string of non-space characters
	
	if a then
		if c and c:lower() == L["search"] then
			if BagSync_SearchFrame:IsVisible() then
				BagSync_SearchFrame:Hide()
			else
				BagSync_SearchFrame:Show()
			end
			return true
		elseif c and c:lower() == L["gold"] then
			self:ShowMoneyTooltip()
			return true
		elseif c and c:lower() == L["tokens"] then
			if BagSync_TokensFrame:IsVisible() then
				BagSync_TokensFrame:Hide()
			else
				BagSync_TokensFrame:Show()
			end
			return true
		elseif c and c:lower() == L["profiles"] then
			if BagSync_ProfilesFrame:IsVisible() then
				BagSync_ProfilesFrame:Hide()
			else
				BagSync_ProfilesFrame:Show()
			end
			return true
		elseif c and c:lower() == L["professions"] then
			if BagSync_CraftsFrame:IsVisible() then
				BagSync_CraftsFrame:Hide()
			else
				BagSync_CraftsFrame:Show()
			end
			return true
		elseif c and c:lower() == L["blacklist"] then
			if BagSync_BlackListFrame:IsVisible() then
				BagSync_BlackListFrame:Hide()
			else
				BagSync_BlackListFrame:Show()
			end
			return true
		elseif c and c:lower() == L["fixdb"] then
			self:FixDB_Data()
			return true
		elseif c and c:lower() == L["config"] then
			InterfaceOptionsFrame_OpenToCategory("BagSync")
			return true
		elseif c and c:lower() ~= "" then
			--do an item search
			if BagSync_SearchFrame then
				if not BagSync_SearchFrame:IsVisible() then BagSync_SearchFrame:Show() end
				BagSync_SearchFrame.SEARCHBTN:SetText(msg)
				BagSync_SearchFrame:initSearch()
			end
			return true
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage("BAGSYNC")
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs [itemname] - Does a quick search for an item"])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs search - Opens the search window"])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs gold - Displays a tooltip with the amount of gold on each character."])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs tokens - Opens the tokens/currency window."])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs profiles - Opens the profiles window."])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs professions - Opens the professions window."])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs blacklist - Opens the blacklist window."])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs fixdb - Runs the database fix (FixDB) on BagSync."])
	DEFAULT_CHAT_FRAME:AddMessage(L["/bgs config - Opens the BagSync Config Window"] )
end


SlashCmdList["BAGSYNC"] = BagSync.SlashCmd


