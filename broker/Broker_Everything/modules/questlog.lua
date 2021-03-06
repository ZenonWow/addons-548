
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "QuestLog" -- L["Quest Log"]
L[name] = QUEST_LOG
local tt = nil
local ttColumns = 3
local quests,sum,url
local urls = {
	WoWHead = function(id)
		local lang = {deDE="de",esES="es",esMX="es",frFR="fr",ptBR="pt"}
		return ("http://%s.wowhead.com/quest=%d"):format(lang[GetLocale()] or "www",id)
	end,
	Buffed = function(id)
		local url = {deDE="http://wowdata.buffed.de/?q=%d",ruRU="http://wowdata.buffed.ru/?q=%d"}
		return (url[GetLocale()] or "http://wowdata.getbuffed.com/?q=%d"):format(id)
	end,
	WoWDB = function(id)
		return ("http://www.wowdb.com/quests/%d"):format(id)
	end
	-- 
}

StaticPopupDialogs["BE_URL_DIALOG"] = {
	text = "URL",
	button2 = CLOSE,
	timeout = 0,
	whileDead = 1,
	hasEditBox = 1,
	hideOnEscape = 1,
	maxLetters = 1024,
	editBoxWidth = 250,
	OnShow = function(f)
		local e,b = _G[f:GetName().."EditBox"],_G[f:GetName().."Button2"]
		if e then e:SetText(url) e:SetFocus() e:HighlightText(0) end
		if b then b:ClearAllPoints() b:SetWidth(100) b:SetPoint("CENTER",e,"CENTER",0,-30) end
	end,
	EditBoxOnEscapePressed = function(f)
		f:GetParent():Hide()
	end
}
-- StaticPopup_Show("BE_URL_DIALOG")


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\TARGETINGFRAME\\PortraitQuestBadge",coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show count of quests in your questlog and quest titles in tooltip."],
	events = {
		"PLAYER_ENTERING_WORLD",
		"QUEST_LOG_UPDATE",
	},
	updateinterval = 1, -- 10
	config_defaults = {
		showQuestIds = true,
		showQuestItems = true,
		questIdUrl = "WoWHead",
	},
	config_allowed = nil,
	config = {
		height = 59,
		elements = {
			{
				type = "check",
				name = "showQuestIds",
				label = L["Show quest id's"],
				desc = L["Show quest id's in tooltip."]
			},
			--[[
			{
				type = "check",
				name = "showQuestItems",
				label = L["Show quest items"],
				desc = L["Show quest items in tooltip."],
				disabled = true
			},
			 ]]
			{
				type = "dropdown",
				name = "questIdUrl",
				label = L["Fav. website"],
				desc = L["Choose your favorite website for further informations to a quest."],
				event = true,
				default = "WoWHead",
				values = {
					WoWHead = "WoWHead",
					WoWDB = "WoWDB (english only)",
					Buffed = "Buffed"
				}
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
local function updateBroker()
	local fail, active, complete = #quests["fail"], #quests["active"], #quests["complete"]
	--local sum = fail + active + complete
	module.obj.text = (fail>0 and C("red",fail).."/" or "")..(complete>0 and C("ltblue",complete).."/" or "")..sum.."/"..MAX_QUESTS

	module.onqtip(module.tooltip)
end

function module.onqtip(tt)
	if not tt then  return  end

	ttColumns =  module.modDB.showQuestIds  and 4  or 3
	tt:SetColumnLayout(ttColumns,"LEFT","LEFT","RIGHT","RIGHT")

	local function addLine(obj)
		local l,c = tt:AddLine()
		local cell, color = 1,"red"

		if (obj.color) then
			color = ns.LC.colorTable2HexCode(obj.color)
		end

		tt:SetCell(l,cell,C(color,obj.levelStr)) cell=cell+1
		tt:SetCell(l,cell,C(color,obj.title)) cell=cell+1
		if obj.nolink~=true then
			tt:SetLineScript(l,"OnMouseUp",function(self)
				SelectQuestLogEntry(obj.index)
				ToggleFrame(QuestLogFrame)
				if not QuestLogFrame:IsShown() then
					ToggleFrame(QuestLogFrame)
				end
			end)
		end
		if Broker_EverythingDB[name].showQuestIds then
			tt:SetCell(l,cell,obj.questId)
			if obj.questId~=L["QuestId"] then
				tt:SetCellScript(l,cell,"OnMouseUp",function(self,button)
					url = urls[Broker_EverythingDB[name].questIdUrl](obj.questId)
					StaticPopup_Show("BE_URL_DIALOG")
				end)
			end
			cell=cell+1
		end

		if obj.share and IsInGroup() then
			tt:SetCell(l,cell,L["share"])
			tt:SetCellScript(l,cell,"OnMouseUp",function(self,button)
				SelectQuestLogEntry(obj.index)
				QuestLogPushQuest()
			end)
			cell=cell+1
		end
	end
	local l,c

	tt:Clear()
	l,c = tt:AddLine()
	tt:SetCell(l,1,C("dkyellow",name),tt:GetHeaderFont(),nil,ttColumns)

	if #quests["fail"]~=0 then
		tt:AddSeparator(4,0,0,0,0)
		addLine({levelStr=C("red",L["Level"]),title=C("red",L["Failed quests"]),questId=C("red",L["QuestId"]),share=false,nolink=true})
		tt:AddSeparator()
		for i,v in ipairs(quests["fail"]) do
			addLine(v)
		end
	end

	if #quests["active"]~=0 then
		tt:AddSeparator(4,0,0,0,0)
		addLine({levelStr=C("ltyellow",L["Level"]),title=C("ltyellow",L["Active quests"]),questId=C("ltyellow",L["QuestId"]),share=false,nolink=true})
		tt:AddSeparator()
		for i,v in ipairs(quests["active"]) do
			addLine(v)
		end
	end

	if #quests["complete"]~=0 then
		tt:AddSeparator(4,0,0,0,0)
		addLine({levelStr=C("ltblue",L["Level"]),title=C("ltblue",L["Completed quests"]),questId=C("ltblue",L["QuestId"]),share=false,nolink=true})
		tt:AddSeparator()
		for i,v in ipairs(quests["complete"]) do
			addLine(v)
		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(4,0,0,0,0)
		local l,c = tt:AddLine()
		tt:SetCell(l,1,C("ltblue",L["Click"]).." || "..C("green",L["Open QuestLog and select quest"]),nil,nil,ttColumns)
	end
end

------------------------------------
-- module (BE internal) functions --
------------------------------------

module.onevent = function(self,event,msg)
	if event == "PLAYER_ENTERING_WORLD" or event == "QUEST_LOG_UPDATE" then
		local shortTags = {[ELITE]="+",[LFG_TYPE_DUNGEON]="d",[PVP]="p",[RAID]="r",[GROUP]="g",[PLAYER_DIFFICULTY2]="++"}
		local numEntries, numQuests = GetNumQuestLogEntries()
		quests = {["fail"]={},["complete"]={},["active"]={}}
		sum = numQuests

		if ns.tocversion < 60000 then
			for index=1, numEntries do
				local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(index)
				if not isHeader then
					local diff = GetQuestDifficultyColor(level)
					local s = (isComplete==-1 and "fail") or (isComplete==1 and "complete") or "active"
					table.insert(quests[s],{
						level = level,
						levelStr = level.." "..(shortTags[questTag] or "")..(questTag==GROUP and suggestedGroup>0 and suggestedGroup or "")..(isDaily~=nil and "*" or ""),
						title = questTitle,
						share = GetQuestLogPushable(index),
						questId = questID,
						index = index,
						color = diff
					})
				end
			end
		else
			for index=1, numEntries do
				local questTitle, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(index);
				local questTag=""
				if not isHeader then
					local diff = GetQuestDifficultyColor(level)
					local s = (isComplete==-1 and "fail") or (isComplete==1 and "complete") or "active"
					table.insert(quests[s],{
						level = level,
						levelStr = level.." "..(shortTags[questTag] or "")..(suggestedGroup>0 and suggestedGroup or "")..(isDaily==true and "*" or ""),
						title = questTitle,
						share = GetQuestLogPushable(index),
						questId = questID,
						index = index,
						color = diff
					})
				end
			end
		end
		updateBroker()
	end
end

-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------


-- final module registration --
-------------------------------
ns.modules[name] = module

