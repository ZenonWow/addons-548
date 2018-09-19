﻿Minimalist = LibStub("AceAddon-3.0"):NewAddon("Minimalist", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0", "AceTimer-3.0")

local db = nil
local mod = Minimalist

local questtags, tags = {}, {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "!", Heroic = "H", Repeatable = "?"}
local TRIVIAL, NORMAL = "|cff%02x%02x%02x[%d%s%s]|r "..TRIVIAL_QUEST_DISPLAY, "|cff%02x%02x%02x[%d%s%s]|r ".. NORMAL_QUEST_DISPLAY

local auto_options = {
	type = "group",
	desc = "Automations",
	args = {
		IGNOREDUELS = {
			name = "Auto-Ignore Duels",
			type = "toggle",
			desc = "Auto-Ignore Duel Requests.",
			get = function() return db.IGNOREDUELS end,
			set = function(i, switch)
				db.IGNOREDUELS = switch
				if switch then
					mod:RegisterEvent("DUEL_REQUESTED")
				else
					mod:UnregisterEvent("DUEL_REQUESTED")
				end
			end
		},
		AUTOSELL = {
			name = "Auto-Sell grey Items",
			type = "toggle",
			desc = "Sell Grey (junk) Items in your Bags automatically.",
			get = function() return db.AUTOSELL end,
			set = function(i, switch)
				db.AUTOSELL = switch
				if switch then
					mod:RegisterEvent("MERCHANT_SHOW")
					mod.Merchant_Show = true 
				else
					if db.AUTOSELL or db.AUTOREPAIR then return end
					mod:UnregisterEvent("MERCHANT_SHOW")
					mod.Merchant_Show = false
				end
			end
		},
		AUTOREZ = {
			name = "Auto-Resurrect",
			type = "toggle",
			desc = "Accept Resurrections automatically.",
			get = function() return db.AUTOREZ end,
			set = function(i, switch)
				db.AUTOREZ = switch
				if switch then
					mod:RegisterEvent("RESURRECT_REQUEST")
				else
					mod:UnregisterEvent("RESURRECT_REQUEST")
				end
			end
		},
		GOSSIPSKIP = {
			name = "Skip useless Gossips",
			type = "toggle",
			desc = "Skip Flightmaster, Banker, and Battlemaster Gossip.",
			get = function() return db.GOSSIPSKIP end,
			set = function(i, switch)
				db.GOSSIPSKIP = switch
				if switch then
					if not mod.Gossip_Show then
						mod:RegisterEvent("GOSSIP_SHOW")
						mod.Gossip_Show = true
					end
				else
					if not db.GOSSIPSKIP and not db.QUESTLEVEL then
						mod:UnregisterEvent("GOSSIP_SHOW")
						mod.Gossip_Show = false
					end
				end
			end
		},
		AUTOREPAIR = {
			name = "Auto-repair",
			type = "toggle",
			desc = "Repair all Equipment and Inventory automatically.",
			get = function() return db.AUTOREPAIR end,
			set = function(i, switch)
				db.AUTOREPAIR = switch
				if switch then
					mod:RegisterEvent("MERCHANT_SHOW")
					mod.Merchant_Show = true 
				else
					if db.AUTOSELL or db.AUTOREPAIR then return end
					mod:UnregisterEvent("MERCHANT_SHOW")
					mod.Merchant_Show = false
				end
			end
		}
	}
}
	
local ui_options = {
	type = "group",
	desc = "Interface",
	args = {	
		REPUTATION = {
			name = "Better Reputation",
			type = "toggle",
			desc = "Display Reputation Amounts numerically and detailed Information in the Chat Frame.",
			get = function() return db.REPUTATION end,
			set = function(i, switch)
				db.REPUTATION = switch
				if switch then
					mod:MinRepOn()
				else
					mod:MinRepOff()
				end
			end
		}, 
		GRYPH = {
			name = "Disable Gryphons",
			type = "toggle",
			desc = "Toggle Display of Gryphons on Main Toolbar.",
			get = function() return db.GRYPH end,
			set = function(i, switch)
				db.GRYPH = switch
				if switch then
					MainMenuBarLeftEndCap:Hide()
					MainMenuBarRightEndCap:Hide()
				else
					MainMenuBarLeftEndCap:Show()
					MainMenuBarRightEndCap:Show()
				end
			end
		}, 
		QUESTLEVEL = {
			name = "Display Quest Levels",
			type = "toggle",
			desc = "Display numeric Quest Level in Quest Frame, Quest completion Frame, and NPC Quest Dialog.",
			get = function() return db.QUESTLEVEL end,
			set = function(i, switch)
				db.QUESTLEVEL = switch
				if switch then
					mod:SecureHook('QuestLog_Update')
					--mod:SecureHook('WatchFrame_Update')
					mod:RegisterEvent("QUEST_GREETING")
					if not mod.Gossip_Show then
						mod:RegisterEvent("GOSSIP_SHOW")
						mod.Gossip_Show = true
					end
				else
					mod:Unhook('QuestLog_Update')
					--mod:Unhook('WatchFrame_Update')
					mod:UnregisterEvent("QUEST_GREETING")
					if not db.GOSSIPSKIP and not db.QUESTLEVEL then
						mod:UnregisterEvent("GOSSIP_SHOW")
						mod.Gossip_Show = false
					end
				end
			end
		},
		QUESTACCEPT = {
			name = "Quest Automation",
			type = "toggle",
			desc = "Automatically accept and turn-in Quests.",
			get = function() return db.QUESTACCEPT end,
			set = function(i, switch)
				db.QUESTACCEPT = switch
				if switch then
					ORIG_ERR_QUEST_ACCEPTED_S = ERR_QUEST_ACCEPTED_S
					mod:SecureHook('AcceptQuest')
					mod:RegisterEvent("QUEST_DETAIL")
					mod:RegisterEvent("QUEST_ACCEPT_CONFIRM")
					mod:RegisterEvent("QUEST_PROGRESS")
					mod:RegisterEvent("QUEST_COMPLETE")
				else
					mod:Unhook('AcceptQuest')
					mod:UnregisterEvent("QUEST_DETAIL")
					mod:UnregisterEvent("QUEST_ACCEPT_CONFIRM")
					mod:UnregisterEvent("QUEST_PROGRESS")
					mod:UnregisterEvent("QUEST_COMPLETE")
				end
			end
		}
	}
}

local chat_options = {
	type = "group",
	desc = "Chat",
	args = {	
		CHATNOFADE = {
			name = "Disable Chat Fading",
			type = "toggle",
			desc = "Disable Chat Frames Fading Chat after Inactivity.",
			get = function() return db.CHATNOFADE end,
			set = function(i, switch)
				db.CHATNOFADE = switch
				if switch then
					mod:ChatNoFadeOn()
				else
					mod:ChatNoFadeOff()
				end
			end
		},
		CHATARROWS = {
			name = "Fix Arrow Keys",
			type = "toggle",
			desc = "Make Arrow Keys move the Cursor in the Input Box.",
			get = function() return db.CHATARROWS end,
			set = function(i, switch)
				db.CHATARROWS = switch
				if switch then
					mod:ChatArrowsOn()
				else
					mod:ChatArrowsOff()
				end
			end
		}, 
		CHATBUTTONS = {
			name = "Hide Buttons",
			type = "toggle",
			desc = "Hide the Chat Frame Buttons.",
			get = function() return db.CHATBUTTONS end,
			set = function(i, switch)
				db.CHATBUTTONS = switch
				if switch then
					mod:ChatButtonsOff()
				else
					mod:ChatButtonsOn()
				end
			end
		}, 
		CHATEDIT = {
			name = "Move Input Box",
			type = "toggle",
			desc = "Move the Input Box to the Top of the Chat Frame.",
			get = function() return db.CHATEDIT end,
			set = function(i, switch)
				db.CHATEDIT = switch
				if switch then
					mod:ChatMoveEditBox()
				else
					mod:ChatRestoreEditBox()
				end
			end
		},
		CHATCLEAN = {
			name = "Reduce Chat Clutter",
			type = "toggle",
			desc = "Shorten Channel Names to reduce Chat Window Clutter.",
			get = function() return db.CHATCLEAN end,
			set = function(i, switch)
				db.CHATCLEAN = switch
				if switch then
					mod:ChatParseOn() 
				else
					mod:ChatParseOff()
				end
			end
		}
	}		
}

local minimap_options = {
	type = "group",
	desc = "Minimap",
	args = {	
		MAPHIDE = {
			name = "Hide Clutter",
			type = "toggle",
			desc = "Hide Minimap Clock, Scroll Buttons, and Location Frame.",
			get = function() return db.MAPHIDE end,
			set = function(i, switch)
				db.MAPHIDE = switch
				if switch then
					mod:MinMapHide()
				else
					mod:MinMapShow()
				end
			end
		},
		MAPLOC = {
			name = "Map X,Y Coords",
			type = "toggle",
			desc = "Adds Numeric X,Y Coordinates below the Minimap.",
			get = function() return db.MAPLOC end,
			set = function(i, switch)
				db.MAPLOC = switch
				if switch then
					mod:MapLocOn()
				else
					mod:MapLocOff()
				end
			end
		},
		MAPSCROLL = {
			name = "MouseWheel Zoom",
			type = "toggle",
			desc = "Enables MouseWheel zooming of the Minimap.",
			get = function() return db.MAPSCROLL end,
			set = function(i, switch)
				db.MAPSCROLL = switch
				if switch then
					mod:MapScrollOn()
				else
					mod:MapScrollOff()
				end
			end
		},
		MAPHIDEWORLDMAPBTN = {
			name = "World Map Button",
			type = "toggle",
			desc = "Hide the World Map button on the Minimap.",
			get = function() return db.MAPHIDEWORLDMAPBTN end,
			set = function(i, switch)
				db.MAPHIDEWORLDMAPBTN = switch
				if switch then
					MiniMapWorldMapButton:Hide()
				else
					MiniMapWorldMapButton:Show()
				end
			end
		},
		MAPHIDETRACKINGBTN = {
			name = "Tracking Button",
			type = "toggle",
			desc = "Hide the Tracking button on the Minimap.",
			get = function() return db.MAPHIDETRACKINGBTN end,
			set = function(i, switch)
				db.MAPHIDETRACKINGBTN = switch
				if switch then
					MiniMapTracking:Hide()
				else
					MiniMapTracking:Show()
				end
			end
		},
		MAPHIDEBORDER = {
			name = "Minimap Border",
			type = "toggle",
			desc = "Hide the Minimap border.",
			get = function() return db.MAPHIDEBORDER end,
			set = function(i, switch)
				db.MAPHIDEBORDER = switch
				if switch then
					MinimapBorder:Hide()
				else
					MinimapBorder:Show()
				end
			end
		}
	}
}

local combat_options = {
	type = "group",
	desc = "Combat & Loot",
	args = {	
		AUTOLOOT = {
			name = "Better Auto Loot",
			type = "toggle",
			desc = "Automatically loot all Items and confirm BoP and Disenchant Notification. It does not roll on Items while in a group or raid. This overrides the standard UI Auto Loot setting.",
			get = function() return db.AUTOLOOT end,
			set = function(i, switch)
				db.AUTOLOOT = switch
				if switch then
					mod:RegisterEvent("LOOT_OPENED")
					mod:RegisterEvent("CONFIRM_LOOT_ROLL")
					mod:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
				else
					mod:UnregisterEvent("LOOT_OPENED")
					mod:UnregisterEvent("CONFIRM_LOOT_ROLL")
					mod:UnregisterEvent("CONFIRM_DISENCHANT_ROLL")
				end
			end
		},
		AUTOPLATES = {
			name = "Enemy Nameplates",
			type = "toggle",
			desc = "Show Enemy Nameplates on entering Combat, hide on leaving Combat.",
			get = function() return db.AUTOPLATES end,
			set = function(i, switch)
				db.AUTOPLATES = switch
				if switch then
					mod:RegisterEvent("PLAYER_REGEN_DISABLED")
					mod:RegisterEvent("PLAYER_REGEN_ENABLED")
				else
					mod:UnregisterEvent("PLAYER_REGEN_DISABLED")
					mod:UnregisterEvent("PLAYER_REGEN_ENABLED")
				end
			end
		},
		BLOATPLATES = {
			name = "Bloat Plates",
			type = "toggle",
			desc = "Makes nameplates larger depending on threat percentage.",
			get = function() return db.BLOATPLATES end,
			set = function(i, switch)
				db.BLOATPLATES = switch
				if switch then
					SetCVar("bloatNamePlates", 1);
				else
					SetCVar("bloatNamePlates", 0);
				end
			end
		},
		BLOATTHREAT = {
			name = "Bloat Threat",
			type = "toggle",
			desc = "Makes nameplates resize depending on threat gain/loss. Only active when a mob has multiple units on its threat table.",
			get = function() return db.BLOATTHREAT end,
			set = function(i, switch)
				db.BLOATTHREAT = switch
				if switch then
					SetCVar("bloatThreat", 1);
				else
					SetCVar("bloatThreat", 0);
				end
			end
		},
		SPREADPLATES = {
			name = "Spread Plates",
			type = "toggle",
			desc = "Makes them overlap like they used to before WoW 4.x.",
			get = function() return db.SPREADPLATES end,
			set = function(i, switch)
				db.SPREADPLATES = switch
				if switch then
					SetCVar("spreadNamePlates", 0);
				else
					SetCVar("spreadNamePlates", 1);
				end
			end
		},
	}
}

local defaults = {
	profile = {
		IGNOREDUELS = false,
		AUTOREPAIR = false,
		AUTOSELL = false,
		AUTOREZ = false,
		GOSSIPSKIP = false,
		REPUTATION = true,
		GRYPH = true,
		QUESTLEVEL = true,
		QUESTACCEPT = false,
		CHATNOFADE = false,
		CHATARROWS = false,
		CHATBUTTONS = false,
		CHATEDIT = false,
		CHATCLEAN = false,
		MAPHIDE = false,
		MAPLOC = false,
		MAPSCROLL = false,
		MAPHIDEWORLDMAPBTN = false,
		MAPHIDETRACKINGBTN = false,
		MAPHIDEBORDER = false,
		AUTOPLATES = false,
		BLOATPLATES = false,
		BLOATTHREAT = false,
		SPREADPLATES = false,
		AUTOLOOT = false,
	}
}

local function profsetup()
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Minimalist.db)
	return profiles
end

function Minimalist:OnInitialize()
	self.Merchant_Show = false
	self.Gossip_Show = false
	self.abacus = LibStub("LibAbacus-3.0")

	self.ACR = LibStub("AceConfigRegistry-3.0")
	self.ACD = LibStub("AceConfigDialog-3.0")

	--# Initialize DB
	self.db = LibStub("AceDB-3.0"):New("MinimalistDB", defaults)
	db = self.db.profile

	--# Register our options
	self.ACR:RegisterOptionsTable("Minimalist", profsetup)
	self.ACR:RegisterOptionsTable("Minimalist Automation",auto_options)
	self.ACR:RegisterOptionsTable("Minimalist Chat",chat_options)
	self.ACR:RegisterOptionsTable("Minimalist Combat",combat_options)
	self.ACR:RegisterOptionsTable("Minimalist Interface",ui_options)
	self.ACR:RegisterOptionsTable("Minimalist Minimap",minimap_options)
	self.ACD:AddToBlizOptions("Minimalist")
	self.ACD:AddToBlizOptions("Minimalist Automation", "Automation", "Minimalist")
	self.ACD:AddToBlizOptions("Minimalist Chat", "Chat", "Minimalist")
	self.ACD:AddToBlizOptions("Minimalist Combat", "Combat & Loot", "Minimalist")
	self.ACD:AddToBlizOptions("Minimalist Interface", "Interface", "Minimalist")
	self.ACD:AddToBlizOptions("Minimalist Minimap", "Minimap", "Minimalist")

	--# Initialize Chat
	for i = 1, NUM_CHAT_WINDOWS do
		--Allow resizing chatframes to whatever size you wish!
		local cf = _G[format("%s%d", "ChatFrame", i)]
		cf:SetMinResize(0,0)
		cf:SetMaxResize(0,0)

		--Allow the chat frame to move to the end of the screen
		cf:SetClampRectInsets(0,0,0,0)

		--Clamp the toast frame to screen to prevent it cutting out
		BNToastFrame:SetClampedToScreen(true)
	end

	--# Slash Commands
	--# /min or /minimlalist: Open Options Panel
	SlashCmdList["MINIMALIST"] = function() InterfaceOptionsFrame_OpenToCategory("Minimalist") end
	SLASH_MINIMALIST1 = "/minimalist"
	SLASH_MINIMALIST2 = "/min"

	--# /rl: Reload UI
	SlashCmdList["RELOADUI"] = function() ReloadUI() end
	SLASH_RELOADUI1 = "/rl"

	--# /rg: Restart GFX Subsystem
	SlashCmdList["RESTARTGX"] = function() RestartGx() end
end

function Minimalist:OnEnable()
	self.Minimap = CreateFrame("Frame", "Minimalist_Map", Minimap)
	self.Minimap:SetAllPoints(Minimap)
	self.Minimap:SetFrameStrata("LOW")
	self.Minimap.loc = self.Minimap:CreateFontString(nil, 'OVERLAY')
	self.Minimap.loc:SetWidth(60)
	self.Minimap.loc:SetHeight(16)
	self.Minimap.loc:SetPoint('CENTER', self.Minimap, 'BOTTOM', 0, -12)
	self.Minimap.loc:SetJustifyH('CENTER')
	self.Minimap.loc:SetFontObject(GameFontNormal)

	for varname, val in pairs(auto_options.args) do

		--Special handling to convert AUTOREPAIR setting from old numeric value to boolean (<2 = false, >=2 = true)
		if varname == "AUTOREPAIR" then
			if type(db[varname]) == "boolean" then
				--self:Print("AUTOREPAIR setting OK")
			else
				if db[varname] <  2 then
					db[varname] = false
					self:Print("Converting AUTOREPAIR setting to 'disabled'")
				else
					db[varname] = true
					self:Print("Converting AUTOREPAIR setting to 'enabled'")
				end
			end
		end

		if db[varname] then auto_options.args[varname].set(false, db[varname]) end
	
	end
	for varname, val in pairs(chat_options.args) do
		if db[varname] then chat_options.args[varname].set(false, db[varname]) end
	end
	for varname, val in pairs(ui_options.args) do
		if db[varname] then ui_options.args[varname].set(false, db[varname]) end
	end
	for varname, val in pairs(minimap_options.args) do
		if db[varname] then minimap_options.args[varname].set(false, db[varname]) end
	end
	for varname, val in pairs(combat_options.args) do
		if db[varname] then combat_options.args[varname].set(false, db[varname]) end
	end
end

function Minimalist:AcceptQuest()
	--ERR_QUEST_ACCEPTED_S = "|cFF33FF99Minimalist:|cFFFFFFFF Accepted:           |Hquest:"..quest_link..":"..UnitLevel("player").."|h[%s]|h|r"
	ERR_QUEST_ACCEPTED_S = ORIG_ERR_QUEST_ACCEPTED_S
end

function Minimalist:QUEST_DETAIL()
	if not IsShiftKeyDown() then
		quest_link = GetQuestID()
		if not QuestGetAutoAccept() then
			AcceptQuest()
		else
			quest_link = GetAutoQuestPopUp(GetNumAutoQuestPopUps())
			CloseQuest()
		end
	end
end

function Minimalist:QUEST_ACCEPT_CONFIRM()
	if not IsShiftKeyDown() then
		ERR_QUEST_ACCEPTED_S = "|cFF33FF99Minimalist:|cFFFFFFFF Accepted:         %s (Escort)"
		ConfirmAcceptQuest()
		StaticPopup_Hide("QUEST_ACCEPT_CONFIRM")
	end
end

function Minimalist:QUEST_PROGRESS()
	if not IsShiftKeyDown() then
		if IsQuestCompletable() then
			CompleteQuest()
		end
	end
end

function Minimalist:QUEST_COMPLETE()
	if not IsShiftKeyDown() then
		if GetNumQuestChoices() < 2 then
			GetQuestReward(GetNumQuestChoices())
		end
	end
end

function Minimalist:LOOT_OPENED()
	if not IsShiftKeyDown() then
		intCount = GetNumLootItems()
		if intCount == 0 then
			CloseLoot()
		else
			for slot = 1, intCount do
				LootSlot(slot)
				ConfirmLootSlot(slot)
			end
		end
	end
end

function Minimalist:CONFIRM_LOOT_ROLL(_, id, roll)
	if not IsShiftKeyDown() then
		ConfirmLootRoll(id, roll)
		StaticPopup_Hide("CONFIRM_LOOT_ROLL")
	end
end

function Minimalist:CONFIRM_DISENCHANT_ROLL(_, id, roll)
	if not IsShiftKeyDown() then
		ConfirmLootRoll(id, roll)
		StaticPopup_Hide("CONFIRM_LOOT_ROLL")
	end
end

local ChatScroll = function(self, direction)
	if (direction > 0) then
		if (IsShiftKeyDown()) then
			self:ScrollToTop()
		elseif (IsControlKeyDown()) then
			self:PageUp()
		else
			self:ScrollUp()
		end
	elseif (direction < 0) then
		if (IsShiftKeyDown()) then
			self:ScrollToBottom()
		elseif (IsControlKeyDown()) then
			self:PageDown()
		else
			self:ScrollDown()
		end
	end
end

if GetCVar("chatMouseScroll") == "1" then FloatingChatFrame_OnMouseScroll = ChatScroll end

function Minimalist:MERCHANT_SHOW()
	if not IsShiftKeyDown() then
		if db.AUTOSELL then self:MinSellJunk() end
		if CanMerchantRepair() and db.AUTOREPAIR then self:RepairHandler() end
	end
end

function Minimalist:GOSSIP_SHOW()
	if db.QUESTLEVEL then self:GossipQuestLevelShow() end
	if not IsShiftKeyDown() then
		if db.GOSSIPSKIP then self:SkipGossip() end
	end
end

function Minimalist:SkipGossip()
	local bwl = "The orb's markings match the brand on your hand."
	local mc = "You see large cavernous tunnels"
	local t = GetGossipText()
	if (t == bwl or (strsub(t,1,31) == mc)) then
		SelectGossipOption(1)
		return
	end
	local list = {GetGossipOptions()}
	for i = 2,getn(list),2 do
		if(list[i]=="taxi" or list[i]=="battlemaster" or list[i]=="banker") then SelectGossipOption(i/2) return end
	end
end

local function GetTaggedTitle(i)
	-- helper function for Quest Level display
	local name, level, tag, group, header, _, complete, daily = GetQuestLogTitle(i)
	if header or not name then return end
	if not group or group == 0 then group = nil end
	return string.format("[%s%s%s%s] %s", level, tag and tags[tag] or "", daily and tags.Daily or "",group or "", name), tag, daily, complete
end

function Minimalist:QuestLog_Update()
	-- Add Quest Level to the Questlog
	for i,butt in pairs(QuestLogScrollFrame.buttons) do
		local qi = butt:GetID()
		local title, tag, daily, complete = GetTaggedTitle(qi)
		if title then butt:SetText("  "..title) end
		if (tag or daily) and not complete then butt.tag:SetText("") end
		QuestLogTitleButton_Resize(butt)
	end
end

function Minimalist:WatchFrame_Update()
	-- Add Quest Level to the Quest Watch Frame
	local questWatchMaxWidth, watchTextIndex = 0, 1
	for i=1,GetNumQuestWatches() do
		local qi = GetQuestIndexForWatch(i)
		if qi then
			local numObjectives = GetNumQuestLeaderBoards(qi)
			if numObjectives > 0 then
				for bi,butt in pairs(WATCHFRAME_QUESTLINES) do
					if butt.text:GetText() == GetQuestLogTitle(qi) then butt.text:SetText(GetTaggedTitle(qi)) end
				end
			end
		end
	end
end

local function helper(isActive, ...)
	-- helper function for Quest Level in Gossip
	local num = select('#', ...)
	if num == 0 then return end
	local skip = isActive and 4 or 5
	for j=1,num,skip do
		local title, level, isTrivial, daily, repeatable = select(j, ...)
		if isActive then daily, repeatable = nil end
		if title and level and level ~= -1 then
			local color = GetQuestDifficultyColor(level)
			_G["GossipTitleButton"..i]:SetFormattedText(isActive and isTrivial and TRIVIAL or NORMAL, color.r*255, color.g*255, color.b*255, level, repeatable and tags.Repeatable or "", daily and tags.Daily or "", title)
		end
		i = i + 1
	end
	i = i + 1
end

function Minimalist:GossipQuestLevelShow()
	i = 1
	helper(false, GetGossipAvailableQuests()) -- name, level, trivial, daily, repeatable
	helper(true, GetGossipActiveQuests()) -- name, level, trivial, complete
end

function Minimalist:QUEST_GREETING()
	local nact,navl = GetNumActiveQuests(), GetNumAvailableQuests()
	local title,level,button
	local o,GetTitle,GetLevel = 0,GetActiveTitle,GetActiveLevel
	for i = 1,nact+navl do
		if(i==nact+1) then
			o,GetTitle,GetLevel = nact,GetAvailableTitle,GetAvailableLevel
		end
		title,level = GetTitle(i-o), GetLevel(i-o)
		if level > 0 then
			button = getglobal("QuestTitleButton"..i)
			button:SetText(format('[%d] %s',level,title))
		end
	end
end

function Minimalist:RepairHandler()
	local equipcost = GetRepairAllCost()
	local funds = GetMoney()

	if (funds < equipcost) and (db.AUTOREPAIR) then
		self:Print("Insufficient Funds to Repair")
	end
	
	if (equipcost > 0) and (db.AUTOREPAIR) then
		RepairAllItems() 
		self:Print("Total repair Costs: "..self.abacus:FormatMoneyExtended(equipcost))
	end
end

function Minimalist:MinSellJunk()
	local bag, slot
	for bag = 0, 4 do
		if GetContainerNumSlots(bag) > 0 then
			for slot = 1, GetContainerNumSlots(bag) do
				local _, _, _, quality = GetContainerItemInfo(bag, slot)
				if (quality == 0 or quality == -1) then
					if (self:ProcessLink(GetContainerItemLink(bag, slot))) then
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end
end

function Minimalist:ProcessLink(link)
	for color, name in string.gmatch(link, "(|c%x+)|Hitem:.+|h%[(.-)%]|h|r") do
	if color == ITEM_QUALITY_COLORS[0].hex then
		return true
	end
		return false
	end
end

function Minimalist:MinRepOn()
	self:PLAYER_ENTERING_WORLD()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_FACTION")
	ReputationFrame_Update()
end

function Minimalist:MinRepOff()
	ReputationWatchBar.cvarLocked = nil
	ReputationWatchBar.textLocked = nil
	ReputationWatchStatusBarText:Hide()
	self:UnregisterEvent("UPDATE_FACTION")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Minimalist:PLAYER_ENTERING_WORLD()
	ReputationWatchBar.cvarLocked = 1
	ReputationWatchBar.textLocked = 1
	ReputationWatchStatusBarText:Show()
end

local MinReps = { }
function Minimalist:UPDATE_FACTION()
	self:PLAYER_ENTERING_WORLD()
	for factionIndex=1, GetNumFactions(), 1 do
		local name, _, standingID, bottomValue, topValue, earnedValue, _, _, isHeader = GetFactionInfo(factionIndex)
		if (not isHeader) and MinReps[name] then
			local difference = earnedValue - MinReps[name].Value
			if (difference > 0 and standingID ~= 8) then
				self:Print(format("%d faction needed until %s with %s.",topValue-earnedValue,getglobal("FACTION_STANDING_LABEL"..standingID+1),name))
			elseif (difference < 0 and standingID ~= 1) then
				difference=abs(difference)
				self:Print(format("%d faction left until %s with %s.",earnedValue-bottomValue,getglobal("FACTION_STANDING_LABEL"..standingID-1),name))
			end
			MinReps[name].Value = earnedValue
		else
			MinReps[name] = { }
			MinReps[name].Value = earnedValue
		end
	end
end

function Minimalist:RESURRECT_REQUEST()
	if not IsShiftKeyDown() then
		if (arg1 == "Chained Spirit") then return end
		if (GetCorpseRecoveryDelay() ~= 0) then return end
		HideUIPanel(StaticPopup1)
		AcceptResurrect()
	end
end

function Minimalist:DUEL_REQUESTED()
	if not IsShiftKeyDown() then
		HideUIPanel(StaticPopup1)
		CancelDuel()
	end
end

function Minimalist:MapLocOn()
	self.Minimap:Show()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:ScheduleRepeatingTimer("UpdateLoc", 0.5)
end

function Minimalist:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
end

function Minimalist:MapLocOff()
	self.Minimap.loc:SetText('')
	self:CancelAllTimers()
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	if not db.MAPSCROLL then self.Minimap:Hide() end
end

function Minimalist:UpdateLoc()
	local x, y = GetPlayerMapPosition("player")
	self.Minimap.loc:SetText(string.format('%s,%s', floor(x*100) or '', floor(y*100) or ''))
end

function Minimalist:MapScrollOn()
	self.Minimap:Show()
	self.Minimap:SetScript("OnMouseWheel", function(i, switch) 
		if not db.MAPSCROLL then return end
		if switch > 0 then Minimap_ZoomIn()
		elseif switch < 0 then Minimap_ZoomOut() end
	end)
	self.Minimap:EnableMouseWheel(true)
end

function Minimalist:MapScrollOff()
	if not db.MAPLOC then self.Minimap:Hide() end
end

function Minimalist:MinMapHide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	GameTimeFrame:Hide()
	MinimapZoneTextButton:Hide()
	MinimapBorderTop:Hide()
end

function Minimalist:MinMapShow()
	MinimapZoomIn:Show()
	MinimapZoomOut:Show()
	GameTimeFrame:Show()
	MinimapZoneTextButton:Show()
	MinimapBorderTop:Show()
end

function Minimalist:ChatNoFadeOn()
	for i = 1, NUM_CHAT_WINDOWS do
		getglobal('ChatFrame'..i):SetFading(false)
	end
end

function Minimalist:ChatNoFadeOff(switch)
	for i = 1, NUM_CHAT_WINDOWS do
		getglobal('ChatFrame'..i):SetFading(true)
	end
end

function Minimalist:ChatButtonsOn()
	if (ChatFrameMenuButton:IsVisible()) then return end
	local showFunc = function(frame) frame:Show() end

	ChatFrameMenuButton:SetScript("OnShow", showFunc)
	ChatFrameMenuButton:Show()
	FriendsMicroButton:SetScript("OnShow", showFunc)
	FriendsMicroButton:Show()

	for i = 1, NUM_CHAT_WINDOWS do
		local bf = _G[format("%s%d%s", "ChatFrame", i, "ButtonFrame")]
		bf:SetScript("OnShow", showFunc)
		bf:Show()
	end
end

function Minimalist:ChatButtonsOff()
	if (not ChatFrameMenuButton:IsVisible()) then return end
	local hideFunc = function(frame) frame:Hide() end

	ChatFrameMenuButton:SetScript("OnShow", hideFunc)
	ChatFrameMenuButton:Hide()
	FriendsMicroButton:SetScript("OnShow", hideFunc)
	FriendsMicroButton:Hide()

	for i = 1, NUM_CHAT_WINDOWS do
		local bf = _G[format("%s%d%s", "ChatFrame", i, "ButtonFrame")]
		bf:SetScript("OnShow", hideFunc)
		bf:Hide()
	end
end

function Minimalist:OnShow()
	this:Hide()
end

function Minimalist:ChatMoveEditBox()
	for i = 1, NUM_CHAT_WINDOWS do
		local eb =  _G[format("%s%d%s", "ChatFrame", i, "EditBox")]
		local cf = _G[format("%s%d", "ChatFrame", i)]
		eb:ClearAllPoints()
		eb:SetPoint("BOTTOMLEFT",  cf, "TOPLEFT",  -5, -5)
		eb:SetPoint("BOTTOMRIGHT", cf, "TOPRIGHT", 0, -5)
	end
end

function Minimalist:ChatRestoreEditBox()
	for i = 1, NUM_CHAT_WINDOWS do
		local eb =  _G[format("%s%d%s", "ChatFrame", i, "EditBox")]
		local cf = _G[format("%s%d", "ChatFrame", i)]
		eb:ClearAllPoints()
		eb:SetPoint("TOPLEFT",  cf, "BOTTOMLEFT",  -5, 0)
		eb:SetPoint("TOPRIGHT", cf, "BOTTOMRIGHT", 5, 0)
	end
end

function Minimalist:ChatArrowsOn()
	for i = 1, NUM_CHAT_WINDOWS do
		--Allow arrow keys editing in the edit box
		local eb =  _G[format("%s%d%s", "ChatFrame", i, "EditBox")]
		eb:SetAltArrowKeyMode(false)
	end
end

function Minimalist:ChatArrowsOff()
	for i = 1, NUM_CHAT_WINDOWS do
		--Allow arrow keys editing in the edit box
		local eb =  _G[format("%s%d%s", "ChatFrame", i, "EditBox")]
		eb:SetAltArrowKeyMode(false)
	end
end

function Minimalist:ChatParseOn()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = getglobal("ChatFrame"..i)
		if not self:IsHooked(cf, "AddMessage") then self:RawHook(cf, "AddMessage", true) end
	end
end

function Minimalist:ChatParseOff()
	if not db.CHATCLEAN and not db.CHATTIME then
		for i = 1, NUM_CHAT_WINDOWS do self:Unhook(getglobal('ChatFrame'..i), "AddMessage") end
	end
end

function Minimalist:AddMessage(cf, msg, ...)
	if db.CHATCLEAN and cf == ChatFrame1 then
		msg = string.gsub(msg, '%[(%d)%. LookingForGroup%]', '[Lfg]')
		msg = string.gsub(msg, '%[(%d)%. General%]', '[Gen]')
		msg = string.gsub(msg, '%[(%d)%. Trade%]', '[Tra]')
		msg = string.gsub(msg, '%[(%d)%. WorldDefense%]', '[WD]')
		msg = string.gsub(msg, '%[(%d)%. LocalDefense%]', '[LD]')
		msg = string.gsub(msg, '%[(%d)%. GuildRecruitment%]', '[GR]')
		msg = string.gsub(msg, '%[Guild%]', '[G]')
		msg = string.gsub(msg, '%[Officer%]', '[O]')
		msg = string.gsub(msg, '%[Battleground%]', '[BG]')
		msg = string.gsub(msg, '%[Battleground Leader%]', '[BG]')
		msg = string.gsub(msg, '%[Party%]', '[P]')
		msg = string.gsub(msg, '%[Dungeon Guide%]', '[P]')
		msg = string.gsub(msg, '%[Raid%]', '[R]')
		msg = string.gsub(msg, '%[Raid Leader%]', '[R]')
		msg = string.gsub(msg, '%[Raid Warning%]', '[!]')
	end
	self.hooks[cf]["AddMessage"](cf, msg, ...)
end

function Minimalist:PLAYER_REGEN_DISABLED()
	SetCVar("nameplateShowEnemies", 1);
end

function Minimalist:PLAYER_REGEN_ENABLED()
	SetCVar("nameplateShowEnemies", 0);
end

