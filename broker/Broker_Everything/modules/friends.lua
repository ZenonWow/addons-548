
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Friends" -- L["Friends"]
local ldbName = name
local tt, tt2
local ttName,ttName2=name.."TT",name.."TT2"
local totalOnline = 0
local totalFriends = 0
local friends = {}
local characters = {}
local unknownGameError = false
local DSw, DSh =  0,  0
local ULx, ULy =  0,  0
local LLx, LLy = 32, 32
local URx, URy =  9, 23
local LRx, LRy =  9, 23
local gameIconPos = setmetatable({},{ __index = function(t,k) return format("%s:%s:%s:%s:%s:%s:%s:%s:%s:%s",DSw,DSh,ULx,ULy,LLx,LLy,URx,URy,LRx,LRy) end})
local gameShortcut = setmetatable({ [BNET_CLIENT_WTCG] = "HS", [BNET_CLIENT_SC2] = "Sc2"},{ __index = function(t, k) return k end })
local _BNet_GetClientTexture = BNet_GetClientTexture
friendsDB = {}
graphicsSetsDB = {}

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\friends"}


---------------------------------------
-- module variables for registration --
---------------------------------------
ns.modules[name] = {
	desc = L["Broker to show you which friends are online."],
	events = {
		"BATTLETAG_INVITE_SHOW",
		"BN_BLOCK_LIST_UPDATED",
		"BN_CONNECTED",
		"BN_CUSTOM_MESSAGE_CHANGED",
		"BN_CUSTOM_MESSAGE_LOADED",
		"BN_DISCONNECTED",
		"BN_FRIEND_ACCOUNT_OFFLINE",
		"BN_FRIEND_ACCOUNT_ONLINE",
		"BN_FRIEND_INFO_CHANGED",
		"BN_FRIEND_INVITE_ADDED",
		"BN_FRIEND_INVITE_REMOVED",
		"BN_INFO_CHANGED",
		"BN_SELF_ONLINE",
		"FRIENDLIST_UPDATE",
		"GROUP_ROSTER_UPDATE",
		"IGNORELIST_UPDATE",
		"PLAYER_ENTERING_WORLD",
		"PLAYER_FLAGS_CHANGED",
		"PLAYER_LOGIN"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		splitFriends = true,
		splitFriendsTT = true,
		disableGameIcons = false,
		showGuild = false
	},
	config_allowed = {
	},
	config = {
		height = 52,
		elements = {
			{
				type = "check",
				name = "disableGameIcons",
				label = L["Disable game icons"],
				desc = L["Disable displaying game icons and use game shortcut instead of"]
			},
			{
				type = "check",
				name = "splitFriends",
				label = L["Split friends|non Broker"],
				desc = L["Split Characters and BattleNet-Friends on Broker Button"],
				event = true
			},
			{
				type = "check",
				name = "splitFriendsTT",
				label = L["Split friends|nin Tooltip"],
				desc = L["Split Characters and BattleNet-Friends in Tooltip"],
				event = true
			},
			{ type="next_row" },
			{
				type  = "check",
				name  = "showGuild",
				label = L["Show guild name"],
				desc  = L["Display guild name in tooltip (BattleNet friends only)"],
				disabled = true
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
local function BNet_GetClientTexture(game)
	if Broker_EverythingDB[name].disableGameIcons then
		return gameShortcut[game]
	else
		local icon = _BNet_GetClientTexture(game)
		return format("|T%s:%s|t",icon,gameIconPos[game])
	end
end

local _status = function(afk,dnd)
	return (afk==true and C("gold","[AFK]")) or (dnd==true and C("ltred","[DND]")) or ""
end

local function grabFriends(self)
	local server = GetRealmName()
	local englishFaction, localizedFaction = UnitFactionGroup("player")


	-- all chars on your realm that you have added to friendlist
	local numChars, charsOnline = GetNumFriends()
	characters = wipe(characters)
	if numChars > 0 then
		for i = 1, numChars do
			local charName, level, class, area, connected, status, note = GetFriendInfo(i)
			--
			if charName ~= nil and (connected==true or connected==1) then -- connected since wow6 a boolean. befor wow6 a number
				characters[charName] = {
					name    = _status((status=="AFK"),(status=="DND"))..C(strupper(class),ns.scm(charName)),
					game    = BNet_GetClientTexture(BNET_CLIENT_WOW),
					faction = localizedFaction or englishFaction,
					realm   = server,
					zone    = area,
					level   = level,
					notes   = ns.scm(note or "")
				}
			end
		end
	end

	-- all friends from battlenet
	local numFriends, friendsOnline = BNGetNumFriends()
	local ClientColors = {App="6699cc",D3="ffdddd",HS="bb7766"}
	friends = wipe(friends)
	if friendsOnline > 0 then
		for i = 1, numFriends do
			local numToons = BNGetNumFriendToons(i)
			local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, game, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime, canSoR = BNGetFriendInfo(i)
			local _, _, _, realmName, realmID, faction, race, class, _, area, level, gameText = BNGetToonInfo(presenceID)

			if isOnline == true then
				for I=1, numToons do
					local hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime, canSoR, toonID = BNGetFriendToonInfo(i, I);
					if (numToons>1 and client~="App") or numToons==1 then
						if toonName == nil or (not toonName) then toonName = presenceName end 

						local n, c = "", 0
						repeat
							c = c + 1
							n = toonName .. c
						until not friends[n]

						friends[n] = {
							name         = _status(isAFK,isDND)..C(class,ns.scm(toonName)),
							game         = BNet_GetClientTexture(client),
							faction      = L[faction],
							realm        = realmName,
							zone         = zoneName~="" and zoneName or gameText,
							level        = level,
							guild        = guild,
							bcDate       = date("%Y-%m-%d %H:%M:%S",broadcastTime),
							bcText       = ns.scm(broadcastText,true),
							notes        = ns.scm(noteText or "",true),
							realID       = ns.scm(isBattleTagPresence and battleTag or presenceName),
							presenceName = presenceName,
							presenceID   = presenceID,
							battleTag    = battleTag,
							toonID       = toonID,
							boolWoW      = (client=="WoW")
						}
					end
				end
			end
		end
	end
end

local function _tt2(self,data)
	if self~=false then
		local blue = C("ltblue","colortable");
		GameTooltip:SetOwner(self,"ANCHOR_NONE");
		if (select(1,self:GetCenter()) > (select(1,UIParent:GetWidth()) / 2)) then
			GameTooltip:SetPoint("RIGHT",tt,"LEFT",-2,0)
		else
			GameTooltip:SetPoint("LEFT",tt,"RIGHT",2,0)
		end
		GameTooltip:ClearLines();
		GameTooltip:AddLine(data.realID,blue[1],blue[2],blue[3])
		GameTooltip:AddLine(data.bcDate,.7,.7,.7);
		GameTooltip:AddLine(data.bcText,1,1,1,true);
		GameTooltip:Show();
		--[[
		tt2 = ns.LQT:Acquire(name.."TT2", 1, "LEFT")
		ns.createTooltip(self, tt2)

		tt2:ClearAllPoints()
		tt2:SetPoint("TOP",self,"BOTTOM",0,-5)
		tt2:SetPoint("LEFT",tt,"LEFT",6,0)
		tt2:SetFrameLevel(tt:GetFrameLevel()+3)

		tt2:Clear()

		tt2:AddLine(C("ltblue",data.bcDate))
		tt2:AddSeparator(1,1,1,1,1)
		tt2:AddLine(C("white",data.bcText))
		]]
	else
		GameTooltip:Hide();
	--elseif (tt2) then
		
		--	ns.hideTooltip(tt2)
		--end
		--else
	end
end

------------------------------------
-- module (BE internal) functions --
------------------------------------
ns.modules[name].init = function(self)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
end

ns.modules[name].onevent = function(self,event,msg)
	local dataobj = self.obj or ns.LDB:GetDataObjectByName(ldbName) 
	local numBNFriends, numOnlineBNFriends = BNGetNumFriends()
	local numFriends, friendsOnline = GetNumFriends()
	grabFriends()

	totalOnline = numOnlineBNFriends + friendsOnline
	totalFriends = numBNFriends + numFriends

	if Broker_EverythingDB[name].splitFriends then
		dataobj.text = format("%s/%s "..C("ltblue","%s/%s"),friendsOnline, numFriends, numOnlineBNFriends, numBNFriends)
	else
		dataobj.text = totalOnline .. "/" .. totalFriends
	end

	if tt~=nil and tt.key~=nil and tt.key==name.."TT" and tt:IsShown() then
		ns.modules[name].ontooltip(tt)
	end
end

--[[ ns.modules[name].onupdate = function(self) end ]]

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

ns.modules[name].ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...

	grabFriends()
	local myguild = ""
	local line, column
	local columns = 8
	local split = Broker_EverythingDB[name].splitFriendsTT
	tt:Clear()
	tt:AddHeader(C("dkyellow",L[name]))

	if IsInGuild() then
		myguild = GetGuildInfo("player")
	end

	local _, _, _, broadcastText = BNGetInfo()
	if broadcastText~=nil and broadcastText~="" then
		tt:AddSeparator(4,0,0,0,0)
		line,column = tt:AddLine()
		tt:SetCell(line,1,C("dkyellow",L["My current broadcast message"]),nil,nil,columns)
		tt:AddSeparator()
		line,column = tt:AddLine()
		tt:SetCell(line,1,C("white",ns.scm(broadcastText,true)),nil,nil,columns)
	end

	if totalOnline == 0 then
		tt:AddSeparator(4,0,0,0,0)
		tt:AddLine(L["No friends online."])
		if Broker_EverythingDB.showHints then
			line, column = tt:AddLine()
			tt:SetCell(line, 1, C("copper",L["Left-click"]).." "..C("green",L["Open friends roster"]), nil, nil, columns)
		end
		return
	end

	-- RealId	Status Character	Level	Zone	Game	Realm	Notes
	tt:AddSeparator(4,0,0,0,0)
	tt:AddLine(
		(split==true and C("ltblue",  L["BattleNet"])) or C("ltyellow",L["Real ID"].."/"..L["BattleTag"]), -- 1
		C("ltyellow",L["Level"]),		-- 2
		C("ltyellow",L["Character"]),	-- 3
		C("ltyellow",L["Game"]),		-- 4
		C("ltyellow",L["Zone"]),		-- 5
		C("ltyellow",L["Realm"]),		-- 6
		C("ltyellow",L["Faction"]),		-- 7
		C("ltyellow",L["Notes"])		-- 8
	)
	tt:AddSeparator()

	for k,v in ns.pairsByKeys(friends) do
		if v.boolWoW then
			--[[
			if v.guild then
				local guildcolor = "white"
				if myguild~="" and v.guild==myguild then
					guildcolor = "green"
				end
				v.guild = C(guildcolor,v.guild)
			end
			]]
			line, column = tt:AddLine(
				C("ltblue",v.realID) .. (v.bcText~="" and "|Tinterface\\chatframe\\ui-chatinput-focusicon:0|t" or ""), -- 1
				C("white",v.level),			-- 2
				v.name,						-- 3
				C("white",v.game),			-- 4
				C("white",v.zone),			-- 5
				C("white",v.realm),			-- 6
				C("white",v.faction),		-- 7
				C("white",v.notes or " ")	-- 8
			)
		else
			line,column = tt:AddLine()
			tt:SetCell(line,1,C("ltblue",v.realID) .. (v.bcText~="" and "|Tinterface\\chatframe\\ui-chatinput-focusicon:0|t" or ""))
			tt:SetCell(line,2,C("white",v.level))
			tt:SetCell(line,3,v.name)
			tt:SetCell(line,4,C("white",v.game))
			tt:SetCell(line,5,C("white",v.zone),nil,nil,3) -- 5 6 7
			tt:SetCell(line,8,C("white",v.notes or " "))
		end
		tt:SetLineScript(line, "OnMouseUp", function(self) if IsAltKeyDown() then BNInviteFriend(v.toonID) else ChatFrame_SendSmartTell(v.presenceName) end end, n)
		tt:SetLineScript(line, "OnEnter", function(self)
			tt:SetLineColor(line, 1,192/255, 90/255, 0.3)
			if v.bcText~="" then
				_tt2(self,v)
			end
		end)
		tt:SetLineScript(line, "OnLeave", function(self)
			tt:SetLineColor(line, 0,0,0,0)
			_tt2(false)
		end)
	end

	if split then
		tt:AddSeparator(4,0,0,0,0)
		tt:AddLine(
			C("yellow",  L["Characters"]),	-- 1
			C("ltyellow",L["Level"]),		-- 2
			C("ltyellow",L["Character"]),	-- 3
			C("ltyellow",L["Game"]),		-- 4
			C("ltyellow",L["Zone"]),		-- 5
			C("ltyellow",L["Realm"]),		-- 6
			C("ltyellow",L["Faction"]),		-- 7
			C("ltyellow",L["Notes"])		-- 8
		)
		tt:AddSeparator()
	end

	for k,v in ns.pairsByKeys(characters) do
		if friends[k]==nil then
			line, column = tt:AddLine(
				" ",
				C("white",v.level),
				v.name,
				C("white",v.game),
				C("white",v.zone),
				C("white",v.realm),
				C("white",v.faction),
				C("white",v.notes or " ")
			)
			tt:SetLineScript(line, "OnMouseUp", function(self) if IsAltKeyDown() then InviteUnit(k) else ChatFrame_SendTell(k) end end, n)
			tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
			tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		line, column = tt:AddLine()
		tt:SetCell(line, 1, 
			C("ltblue",L["Click"]).." || "..C("green",L["Whisper with a friend"])
			.." - "..
			C("ltblue",L["Alt+Click"]).." || "..C("green",L["Invite a friend"])
			.."|n"..
			C("copper",L["Click"]).." || "..C("green",L["Open friends roster"]),
			nil, nil, columns)
	end

	line, column = nil, nil
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
ns.modules[name].onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 8 , "LEFT","CENTER", "LEFT", --[["LEFT",]] "CENTER", "LEFT", "LEFT", "LEFT", "LEFT" --[[, "LEFT"]] )
	ns.modules[name].ontooltip(tt)
	ns.createTooltip(self,tt)
end

ns.modules[name].onleave = function(self)
	if (tt) then ns.hideTooltip(tt,ttName,false,true); end
end

ns.modules[name].onclick = function(self,button)
	securecall("ToggleFriendsFrame",1)
end

--[[ ns.modules[name].ondblclick = function(self,button) end ]]
