--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local L = PhanxChat.L

local BNET_CLIENT_TEXT = {
	-- ["App"] = "Battle.net Desktop App",
	[BNET_CLIENT_D3]   = "Diablo III",
	[BNET_CLIENT_WTCG] = "Hearthstone",
	[BNET_CLIENT_SC2]  = "StarCraft II",
	[BNET_CLIENT_WOW]  = "World of Warcraft",
}

------------------------------------------------------------------------

local playerRealm = GetRealmName()

local classTokens = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do classTokens[v] = k end
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do classTokens[v] = k end

local bnetNames = setmetatable({}, { __index = function(bnetNames, presenceID)
	local _, presenceName, battleTag, isBTagFriend, charName, charID, client, online, _, _, _, _, _, isRIDFriend = BNGetFriendInfoByID(presenceID)
	-- print(presenceID, presenceName, isRIDFriend, battleTag, isBTagFriend, online, client, charID, charName)

	local realmName, classColor
	if online and charID and client == BNET_CLIENT_WOW and PhanxChat.db.ShowClassColors then
		-- print("Online in WoW")
		local _, _, _, realm, _, _, _, class = BNGetToonInfo(charID)
		realmName = realm and realm ~= "" and realm ~= playerRealm and gsub(realm, "%s", "")

		local token = classTokens[class]
		classColor = token and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[token]
	end

	if PhanxChatDB.ReplaceRealNames then
		presenceName = realmName and format("%s-%s", charName, realmName) or charName
	elseif isRIDFriend and PhanxChatDB.ShortenRealNames == "FIRSTNAME" then
		-- This works because the game ignores extra placeholders:
		presenceName = gsub(presenceName, "|Kf", "|Kg")
		-- print("Using first name:", presenceName)
	elseif PhanxChatDB.ShortenRealNames == "BATTLETAG" then
		presenceName = strsplit("#", battleTag, 2)
		-- print("Using BattleTag:", presenceName)
	else
		-- Fall back to full name
		-- print("Using full name:", presenceName)
	end

	if classColor then
		presenceName = format("|cff%02x%02x%02x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, presenceName)
	end

	bnetNames[presenceID] = presenceName
	return presenceName
end })

function PhanxChat:ClearBNetNameCache()
	-- print("ClearBNetNameCache")
	wipe(bnetNames)
	-- print("Done.")
end

PhanxChat.BN_CONNECTED = PhanxChat.ClearBNetNameCache
PhanxChat.BN_FRIEND_ACCOUNT_ONLINE = PhanxChat.ClearBNetNameCache
PhanxChat.BN_FRIEND_TOON_ONLINE = PhanxChat.ClearBNetNameCache
PhanxChat.PLAYER_ENTERING_WORLD = PhanxChat.ClearBNetNameCache

PhanxChat.bnetNames = bnetNames

------------------------------------------------------------------------

function PhanxChat:SetReplaceRealNames(v)
	-- print("PhanxChat: SetReplaceRealNames", v)
	if type(v) == "boolean" then
		self.db.ReplaceRealNames = v
	elseif type(v) == "string" then
		self.db.ShortenRealNames = v
	end

	self:ClearBNetNameCache()
	if self.db.ReplaceRealNames or self.db.ShortenRealNames then
		self:RegisterEvent("BN_CONNECTED")
		self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
		self:RegisterEvent("BN_FRIEND_TOON_ONLINE")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	else
		self:UnregisterEvent("BN_CONNECTED")
		self:UnregisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
		self:UnregisterEvent("BN_FRIEND_TOON_ONLINE")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetReplaceRealNames)

------------------------------------------------------------------------

local BN_WHO_LIST_FORMAT = gsub(WHO_LIST_FORMAT, "|Hplayer:", "|H")
local BN_WHO_LIST_GUILD_FORMAT = gsub(WHO_LIST_GUILD_FORMAT, "|Hplayer:", "|H")
local BN_WHO_LIST_REALM_FORMAT = BN_WHO_LIST_FORMAT .. " (%s)"
local BN_WHO_LIST_GUILD_REALM_FORMAT = BN_WHO_LIST_GUILD_FORMAT .. " (%s)"

local dialogs = {
	"ADD_FRIEND",
	"ADD_GUILDMEMBER",
	"ADD_IGNORE",
	"ADD_MUTE",
	"ADD_RAIDMEMBER",
	"ADD_TEAMMEMBER",
	"CHANNEL_INVITE",
}

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(frame, link, text, button)
	if strsub(link, 1, 8) == "BNplayer" then
		local linkID = tonumber(strmatch(link, "|Kf(%d+)"))
		if not linkID or not IsModifiedClick("CHATLINK") or ChatEdit_GetActiveWindow() or HelpFrameOpenTicketEditBox:IsVisible() then
			return
		end
		for _, dialog in ipairs(dialogs) do
			if StaticPopup_Visible(dialog) then
				return
			end
		end
		for i = 1, BNGetNumFriends() do
			local pID, presenceName, battleTag, isBTagFriend, charName, charID, client, online, _, _, _, _, note, isRIDFriend = BNGetFriendInfo(i)
			if pID == linkID then
				local color = ChatTypeInfo.SYSTEM
				if charID then
					local hasFocus, charName, _, realmName, _, faction, race, class, guild, zoneName, level, gameText = BNGetToonInfo(charID)
					if client ~= BNET_CLIENT_WOW then
						gameText = BNET_CLIENT_TEXT[client]
						if gameText then
							return DEFAULT_CHAT_FRAME:AddMessage(format(L.WhoStatus_PlayingOtherGame, presenceName, gameText),
								color.r, color.g, color.b)
						else
							return DEFAULT_CHAT_FRAME:AddMessage(format(L.WhoStatus_Battlenet, presenceName),
								color.r, color.g, color.b)
						end
					elseif realm == GetRealmName() then -- #TODO: Check in the future if Blizz fixes zone being nil
						if guild and guild ~= "" then
							return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_GUILD_FORMAT,
								link, charName, level, race, class, guild, zoneName or ""), "  ", " "),
								color.r, color.g, color.b)
						else
							return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_FORMAT,
								link, charName, level, race, class, zoneName or ""), "  ", " "),
								color.r, color.g, color.b)
						end
					elseif guild and guild ~= "" then
						return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_GUILD_REALM_FORMAT,
							link, charName, level, race, class, guild, zoneName or "", realmName), "  ", " "),
							color.r, color.g, color.b)
					else
						return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_REALM_FORMAT,
							link, charName, level, race, class, zoneName or "", realmName), "  ", " "),
							color.r, color.g, color.b)
					end
				else
					return DEFAULT_CHAT_FRAME:AddMessage(format(L.WhoStatus_Offline,
						presenceName),
						color.r, color.g, color.b)
				end
			end
		end
	end
end)