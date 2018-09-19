
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Guild" -- L["Guild"]
local ldbName = name
local ttName = name.."TT"
local tt, tt_parent = nil
local tt2 = nil
local ttColumns = 5
local ttColumns_preInit = ttColumns
local guildUpdateFreq = 300
local displayProfessions = false
local displayOfficerNotes = false
local off, on = gsub(ERR_FRIEND_OFFLINE_S,"%%s",""), gsub(ERR_FRIEND_ONLINE_SS,"%|Hplayer:%%s%|h%[%%s%]%|h","")

local menu = {
	{name="showMOTD",			locale="Show guild motd"},
	{name="showXP",				locale="Show guild xp"},
	{name="showRep",			locale="Show guild reputation"},
	{name="showLvlXPbroker",	locale="Show guild level and xp (percent) in broker", event=true},
	{name="showMobileChatter",	locale="Show modile chatter"},
	{name="showRealmname",		locale="Show realm name"},
	{name="showProfessions",	locale="Show professions"},
	{name="showApplicants",		locale="Show applicants", event=true}
}

if ns.build>=60000000 then
	menu = {
		{name="showMOTD",			locale="Show Guild MotD"},
		--{name="showXP",			locale="Show Guild XP/Rep"},
		{name="showRep",			locale="Show Guild Reputation"},
		--{name="showLvlXPbroker",	locale="Show Guild Level and XP (percent) in broker", event=true},
		{name="showMobileChatter",	locale="Show modile chatter"},
		{name="showRealmname",		locale="Show realm name"},
		{name="showProfessions",	locale="Show professions"},
		{name="showApplicants",		locale="Show applicants", event=true}
	}
end

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile=GetItemIcon(5976),coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
ns.modules[name] = {
	desc = L["Broker to show guild information. Guild members currently online, MOTD, guild xp etc."],
	events = {
		"PLAYER_LOGIN",
		"GUILD_ROSTER_UPDATE",
		"PLAYER_ENTERING_WORLD",
		"GUILD_XP_UPDATE",
		"CHAT_MSG_SYSTEM",
		"LF_GUILD_RECRUITS_UPDATED"
	},
	updateinterval = 30,
	config_defaults = {
		showXP = true,
		showRep = true,
		showLvlXPbroker = false,
		showMOTD = true,
		showMobileChatter = true,
		splitTables = false,
		showRealmname = true,
		showProfessions = true,
		showApplicants = true
	},
	config_allowed = {
	},
	config = 	{
		height = 102,
		elements = {
			{
				type = "check",
				name = "showRep",
				label = L["Show guild reputation"],
				desc = L["Enable/Disable the display of Guild Reputation in the Guild data broker tooltip."]
			},
			{
				type = "check",
				name = "showMobileChatter",
				label = L["Show modile chatter"],
				desc = L["Show mobile chatter in tooltip"]
			},
			{
				type = "check",
				name = "showRealmname",
				label = L["Show realm name"],
				desc = L[""]
			},

			{ type="next_row" },

			{
				type = "check",
				name = "showMOTD",
				label = L["Show Guild MotD"],
				desc = L["Show Guild Message of the Day in tooltip"]
			},
			{
				type = "check",
				name = "splitTables",
				label = L["Separate mobile chatter"],
				desc = L["Display mobile chatter with own table in tooltip"]
			},
			{
				type = "check",
				name = "showProfessions",
				label = L["Show professions"],
				desc = L["Show member professions in tooltip"],
				event = true
			},

			{ type="next_row" },

			{
				type = "check",
				name = "showApplicants",
				label = L["Show applicants"],
				desc = L["Show applicants in broker and tooltip"],
				event = true
			},
			{
				type = "check",
				name = "showXP",
				label = L["Show Guild XP"],
				desc = L["Enable/Disable the display of Guild XP in the Guild data broker tooltip."],
				disabled = (ns.build>=60000000)
			},
			{
				type = "check",
				name = "showLvlXPbroker",
				label = L["Show guild lvl&xp in broker"],
				desc = L["Display guild level and xp (percent) in broker button"],
				event = true,
				disabled = (ns.build>=60000000)
			},
		}
	}
}


--------------------------
-- some local functions --
--------------------------
local function makeMenu(self)
	if (tt) and (tt:IsShown()) then ns.hideTooltip(tt,ttName,true); end
	--[[
	tt2 = ns.LQT:Acquire(name.."TT2", 1, "LEFT")
	ns.createTooltip(_self,tt2)
	tt2:SetScript('OnLeave', ns.hideTooltip)
	tt2:Clear()

	tt2:AddHeader(C("dkyellow",L["Option menu"]))
	tt2:AddSeparator()
	for i,v in ipairs(menu) do
		local val = Broker_EverythingDB[name][v.name]
		local l,c = tt2:AddLine(C(val and "green" or "red",L[v.locale]))
		tt2:SetLineScript(l,"OnMouseUp",function(self)
			Broker_EverythingDB[name][v.name] = not val makeMenu(_self)
			if v.event then ns.modules[name].onevent(_self,"BE_DUMMY_EVENT") end
		end)
	end
	--]]
	ns.EasyMenu.InitializeMenu();

	ns.EasyMenu.addEntry({ label = L["Options"], title = true });

	ns.EasyMenu.addEntry({ separator = true });

	for i,v in ipairs(menu) do
		ns.EasyMenu.addEntry({
			label = L[v.locale],
			checked = function() return Broker_EverythingDB[name][v.name]; end,
			func  = function()
				Broker_EverythingDB[name][v.name] = not Broker_EverythingDB[name][v.name];
				if (v.event) then ns.modules[name].onevent(_self,"BE_DUMMY_EVENT") end
			end,
			disabled = (false)
		});
	end

	ns.EasyMenu.ShowMenu(self);
end

local function GetGuildChallengesState()
	local numChallenges = GetNumGuildChallenges();
	local names = {"dungeons","szenarios","challenge mode dungeons","raids","rated battlegrounds"}
	local xp_overlimit = {120000,0,0,0,0,0}
	local result = {}
	for i = 1, numChallenges do
		local index, current, max, xp = GetGuildChallengeInfo(i);
		result[index] = {L[names[index]],max-current,xp,xp_overlimit[index]}
	end
	return result
end

local function guildTooltip()
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...
	tt:Clear()

	if not IsInGuild() then
		tt:AddHeader(L[name])
		tt:AddSeparator()
		tt:AddLine(L["No Guild"])
		return
	end
	-- XP & Reputation

	local currentXP, nextLevelXP, dailyXP, maxDailyXP, unitWeeklyXP, unitTotalXP, maxXP, line, column, factionStandingtext, guildName, guildLevel, gMOTD
	
	if not (ns.build>=60000000) then
		currentXP, nextLevelXP, dailyXP, maxDailyXP, unitWeeklyXP, unitTotalXP = UnitGetGuildXP("player");
		maxXP = currentXP + nextLevelXP
	end

	local guildName, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID)

	guildName = GetGuildInfo("player")
	guildLevel = GetGuildLevel~=nil and GetGuildLevel()
	gMOTD = GetGuildRosterMOTD()

	line, column = tt:AddHeader()
	if ns.build>=60000000 then
		tt:SetCell(line,1,C("dkyellow",L[name]) .. "  " .. C("green",ns.scm(guildName)),nil,nil,ttColumns)
	else
		tt:SetCell(line,1,C("dkyellow",L[name]) .. "  " .. C("green",("%s / Lvl: %d / XP: %.2f%%"):format(ns.scm(guildName) or "?",guildLevel or "?",(currentXP / (maxXP / 100) ))),nil,nil,ttColumns)
	end
	tt:AddSeparator(4,0,0,0,0)


	if Broker_EverythingDB[name].showMOTD then
		if gMOTD:len() > 100 then
			gMOTD = ns.splitTextToHalf(gMOTD," ")
		end

		line, column = tt:AddLine()
		tt:SetCell(line, 1, C("ltblue",L["MotD:"]), nil, nil, 1)
		tt:SetCell(line, 2, C("ltgreen",ns.scm(gMOTD,true)), nil, nil, ttColumns-1)
	end

	if not (ns.build>=60000000) and Broker_EverythingDB[name].showXP then
		line, column = tt:AddLine()
		tt:SetCell(line, 1, ("%s: "):format(C("ltblue",L["XP"])))

		if guildLevel<25 then
			tt:SetCell(line, 2, ("%s/%s (%s)"):format(currentXP, maxXP,nextLevelXP),nil, nil, ttColumns - 1)
		else
			tt:SetCell(line, 2, ("%s/%s"):format(currentXP, maxXP),nil, nil, ttColumns - 1)
		end
	end

	if Broker_EverythingDB[name].showRep then
		line, column = tt:AddLine()
		tt:SetCell(line, 1, ("%s: "):format(C("ltblue",L["Rep"])))
		tt:SetCell(line, 2, ("%s: (%d/%d)"):format(factionStandingtext, barValue-barMin, barMax-barMin), nil, nil, ttColumns - 1)
	end


	if Broker_EverythingDB[name].showMOTD or Broker_EverythingDB[name].showXP then
		tt:AddSeparator(4,0,0,0,0)
	end

	-- applicants
	local numApplicants = GetNumGuildApplicants()
	if Broker_EverythingDB[name].showApplicants and numApplicants>0 then
		
		line,column = tt:AddLine()
		tt:SetCell(line,1,C("orange",L["Level"]))
		tt:SetCell(line,2,C("orange",L["Applicant"]))
		tt:SetCell(line,3,C("orange",L["Roles"]))
		tt:SetCell(line,4,C("orange",L["Expired"]))
		tt:SetCell(line,5,C("orange",L["Comment"]))
		tt:AddSeparator()

		guildApplicants = {}
		for index=1, numApplicants do
			local aName, level, class, bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, comment, timeSince, timeLeft = GetGuildApplicantInfo(index)
			local roles = {}
			if bTank then table.insert(roles,L["Tank"]) end
			if bHealer then table.insert(roles,L["Healer"]) end
			if bDamage then table.insert(roles,L["Damage"]) end
			line,column=tt:AddLine() 
			tt:SetCell(line,1,level)
			tt:SetCell(line,2,C(class,aName))
			tt:SetCell(line,3,table.concat(roles,", "))
			tt:SetCell(line,4,date("%Y-%m-%d",time()+timeLeft))
			tt:SetCell(line,5,(strlen(comment)>0 and ns.strLimit(comment,60) or L["No Text"]),nil,nil,ttColumns-4)
			tt:SetLineScript(line,"OnMouseUp",function()
				if IsInGuild() then
					if not GuildFrame then GuildFrame_LoadUI() end
					ShowUIPanel(GuildFrame)
					GuildFrameTab5:Click()
					GuildInfoFrameTab3:Click()
					SetGuildApplicantSelection(index)
				end
			end)
		end

		tt:AddSeparator(4,0,0,0,0)
	end

	-- roster title
	line, column = tt:AddLine()
	local cell = 1
	tt:SetCell(line, cell, C("ltyellow",L["Level"]), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
	tt:SetCell(line, cell, C("ltyellow",L["Character"]), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
	tt:SetCell(line, cell, C("ltyellow",L["Zone"]), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
	tt:SetCell(line, cell, C("ltyellow",L["Notes"]), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1

	if displayOfficerNotes then 
		tt:SetCell(line, cell, C("ltyellow",L["Officer notes"]), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
	end

	tt:SetCell(line, cell, C("ltyellow",L["Rank"]), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1

	if Broker_EverythingDB[name].showProfessions then
		tt:SetCell(line, cell, C("ltyellow",L["Professions"]), nil, nil, 2, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
	end

	tt:AddSeparator()

	-- 1. run... collect skill names and icons
	local y = GetNumGuildTradeSkill()
	skillIcons,skillNames,collapsed = {},{},{}
	for i=1, y do
		local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerDisplayName, playerFullName, class, online, zone, skill, classFileName, isMobile, isAway = GetGuildTradeSkillInfo(i)
		if headerName  then
			collapsed[skillID] = isCollapsed
			skillIcons[skillID] = iconTexture
			skillNames[skillID] = headerName
		end
	end

	-- 2. run... expand collapsed skill
	for i,v in pairs(collapsed) do if v then ExpandGuildTradeSkillHeader(i) end end

	-- 3. run... collect member skills
	local y = GetNumGuildTradeSkill()
	local skillMembers,skillMembersStr = {},{}
	for i=1, y do
		local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerDisplayName, playerFullName, class, online, zone, skill, classFileName, isMobile, isAway = GetGuildTradeSkillInfo(i)
		if online then
			if playerDisplayName then
				if skillMembers[playerDisplayName]==nil then skillMembers[playerDisplayName]={} end
				table.insert(skillMembers[playerDisplayName],{icon=skillIcons[skillID],count=skill,id=skillID,full=playerFullName})
				skillMembersStr[playerDisplayName] = (skillMembersStr[playerDisplayName]~=nil and skillMembersStr[playerDisplayName]..", " or "").."|T"..skillIcons[skillID]..":0|t "..skill
			end
		end
	end

	-- 4. run... collapse prev. expanded skills
	for i,v in pairs(collapsed) do if v then CollapseGuildTradeSkillHeader(i) end end

	local y = GetNumGuildMembers(true)  -- GetNumGuildMembers(true)
	local iArmory,Armory = 0,{}
	for i = 1, y do
		local rc = "white"
		local n, r, ri, l, c, z, no, ono, o, s, ec, a, ar, im = GetGuildRosterInfo(i)
		if o then
			local charname,realm = strsplit("-",n)
			if ns.player.name == charname then rc = "gray" end
			if s==1 then
				s = C("gold","[AFK] ")
			elseif s==2 then
				s = C("ltred","[DND] ")
			else
				s = ""
			end
			if Broker_EverythingDB[name].showRealmname then
				s = s..C(ec,ns.scm(charname)).." - "..C("dkyellow",ns.scm(realm))
			else
				s = s..C(ec,ns.scm(charname))
			end

			local cell = 1
			line, column = tt:AddLine()
			tt:SetCell(line, cell, l, nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
			tt:SetCell(line, cell, s, nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
			tt:SetCell(line, cell,  z or "", nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
			tt:SetCell(line, cell, ns.scm(no,true) or "", nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1

			if displayOfficerNotes then
				tt:SetCell(line, cell, ns.scm(ono,true) or "" , nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
			end

			tt:SetCell(line, cell, C(rc,ns.scm(r,true)), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1

			if Broker_EverythingDB[name].showProfessions then
				if skillMembers[charname]~=nil then
					for k,v in pairs(skillMembers[charname]) do
						tt:SetCell(line, cell, "|T"..v.icon..":0|t "..v.count, nil, nil, 1, ns.LQT.LabelProvider, 0, 10)
						tt:SetCellScript(line, cell, "OnMouseUp", function(self, button)
							--if IsShiftKeyDown() then
								-- ViewGuildRecipes(v.id)
							--else
								GetGuildMemberRecipes(v.full,v.id)
							--end
						end)
						cell = cell + 1
					end
				else
					tt:SetCell(line, cell, "", nil,nil,2, ns.LQT.LabelProvider, 0, 10) cell=cell+2
				end
			end

			tt:SetLineScript(line, "OnMouseUp", function(self) if IsAltKeyDown() then InviteUnit(n) else SetItemRef("player:"..n, "|Hplayer:"..n.."|h["..n.."|h", "LeftButton") end end, n)
		elseif im then
			iArmory = iArmory + 1
			Armory[iArmory] = {GetGuildRosterInfo(i)}
		end
	end

	if Broker_EverythingDB[name].showMobileChatter == true and iArmory > 0 then
		if Broker_EverythingDB[name].splitTables == true then
			tt:AddLine(" ")
			line,column = tt:AddLine()
			tt:SetCell(line, 1, C("ltyellow",L["MobileChat"]), nil, nil, ttColumns)
			tt:AddSeparator()
		end

		for i,v in pairs(Armory) do
			local rc = "white"
			local n, r, ri, l, c, z, no, ono, o, s, ec, a, ar, im = unpack(v)
			if im then
				local charname,realm = strsplit("-",n)
				if ns.player.name == charname then rc = "gray" end
				if s==1 then
					s = C("gold","[AFK] ")
				elseif s==2 then 
					s = C("ltred","[DND] ")
				else 
					s = ""
				end
				if Broker_EverythingDB[name].showRealmname then
					s = s..C(ec,charname).." - "..C("dkyellow",realm)
				else
					s = s..C(ec,charname)
				end

				local cell = 1
				line, column = tt:AddLine()
				tt:SetCell(line, cell, l, nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
				tt:SetCell(line, cell, s, nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
				tt:SetCell(line, cell, C("ltblue",L["MobileChat"]), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
				tt:SetCell(line, cell, no or "", nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1

				if displayOfficerNotes then
					tt:SetCell(line, cell, ono or "" , nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
				end

				tt:SetCell(line, cell, C(rc,r), nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1

				if Broker_EverythingDB[name].showProfessions then
					tt:SetCell(line, cell, skillMembersStr[charname] or "-", nil, nil, 1, ns.LQT.LabelProvider, 0, 10) cell = cell + 1
				end

				tt:SetLineScript(line, "OnMouseUp", function(self) if IsAltKeyDown() then InviteUnit(n) else SetItemRef("player:"..n, "|Hplayer:"..n.."|h["..n.."|h", "LeftButton") end end, n)
				tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
				tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
			end
		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(4,0,0,0,0)

		line, column = tt:AddLine()
		tt:SetCell(line, 1,
			(numApplicants>0 and C("orange",L["Click"]).." || "..C("green","Open guild applications").."|n" or "")..
			C("ltblue",L["Click"]).." || "..C("green",L["Whisper with a member"])
			.." - "..
			C("ltblue",L["Alt+Click"]).." || "..C("green",L["Invite a member"])
			, nil, nil, ttColumns)

		line, column = tt:AddLine()
		tt:SetCell(line,1,
			C("copper",L["Left-click"]).." || "..C("green",L["Open guild roster"])
			.." - "..
			C("copper",L["Right-click"]).." || "..C("green",L["Open little option menu"])
			, nil, nil, ttColumns)
	end

	tt:AddSeparator(1,0,0,0,0)
	tt:UpdateScrolling(WorldFrame:GetHeight() * Broker_EverythingDB.maxTooltipHeight)
end

local function CheckWhoIs(...)
	local msg = ...
end

------------------------------------
-- module (BE internal) functions --
------------------------------------
ns.modules[name].init = function(obj)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
end

ns.modules[name].onevent = function(self,event,msg)
	local dataobj = (self) and self.obj or ns.LDB:GetDataObjectByName(ldbName)
	if not IsInGuild() then
		dataobj.text = L["No Guild"]
		return
	end

	if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
		ns.modules[name].onupdate()
	end

	if event == "GUILD_ROSTER_UPDATE" or event == "GUILD_XP_UPDATE" or event == "LF_GUILD_RECRUITS_UPDATED" or event=="BE_DUMMY_EVENT" or (event == "CHAT_MSG_SYSTEM" and (msg:match(off) or msg:match(on))) then
		local totalGuildMembers, membersOnline = GetNumGuildMembers()
		local numApplicants = Broker_EverythingDB[name].showApplicants and GetNumGuildApplicants() or 0

		local currentXP, nextLevelXP, dailyXP, maxDailyXP, unitWeeklyXP, unitTotalXP, maxXP, guildLevel

		if not (ns.build>=60000000) then
			currentXP, nextLevelXP, dailyXP, maxDailyXP, unitWeeklyXP, unitTotalXP = UnitGetGuildXP("player");
			maxXP = currentXP + nextLevelXP
			guildLevel = GetGuildLevel()
		end

		local txt = ""

		if numApplicants>0 then
			txt = txt .. C("orange",numApplicants) .. "/"
		end

		txt = txt .. C("green",membersOnline) .. "/" .. C("green",totalGuildMembers)

		if not (ns.build>=60000000) and Broker_EverythingDB[name].showLvlXPbroker and guildLevel<25 then
			txt = txt .. " " .. C("green",GetGuildLevel()) .. "/" .. C("green",("%.2f%%"):format( currentXP/(maxXP/100) ))
		end
		dataobj.text =  txt
	end

	if event == "CHAT_MSG_SYSTEM" then
		--local msg = ...
		--if msg:match(ERR_FRIEND_ONLINE_SS) then
			-- ?
		--elseif msg:match(ERR_FRIEND_OFFLINE_S) then
			-- ?
		--end
	end

	if tt~=nil and tt.key~=nil and tt.key==name.."TT" and tt:IsShown() then
		guildTooltip()
	end
end

ns.modules[name].onupdate = function(self)
	if IsInGuild() then 
		RequestGuildApplicantsList()
		GuildRoster()
		if not (ns.build>=60000000) then
			QueryGuildXP()
		end
		CheckWhoIs()
	end
end

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

--[[ ns.modules[name].optionspanel = function(panel) end ]]


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
ns.modules[name].onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	displayOfficerNotes = CanViewOfficerNote()
	ttColumns = ttColumns_preInit
	if displayOfficerNotes then ttColumns = ttColumns + 1 end
	if Broker_EverythingDB[name].showProfessions then ttColumns = ttColumns + 2 end

	tt = ns.LQT:Acquire(ttName, ttColumns,"LEFT", "LEFT", "CENTER", "LEFT", "LEFT", "LEFT", "LEFT")
	ns.createTooltip(self,tt)

	guildTooltip(self)
end

ns.modules[name].onleave = function(self)
	if (tt) then ns.hideTooltip(tt,ttName,false,true); end
end

ns.modules[name].onclick = function(self,button)
	if button == "RightButton" then 
		makeMenu(self)
	elseif GUILockDown == nil then 
		securecall("ToggleGuildFrame")
	elseif GUILockDown == 1 then 
		return 
	end
end

--[[ ns.modules[name].ondblclick = function(self,button) end ]]

