local ADDON_NAME, private = ...

TillerTracker = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local LibQTip = LibStub("LibQTip-1.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local AceConfig = LibStub("AceConfig-3.0")

local _

local defaults = {
	global = {
		sort_field = "NAME",
		sort_dir = "ASC",
		minimap_icon = {
			hide = false
		},
		plan_ahead = 1
	}
}

local options = {
	name = L["Tiller Tracker"],
	type = "group",
	args = {
		minimap_icon = {
			order = 1,
			type = "toggle",
			name = L["Show minimap icon"],
			desc = L["Shows or hides the minimap icon"],
			get = function()
				return not private.db.global.minimap_icon.hide
			end,
			set = function(info, value)
				private.db.global.minimap_icon.hide = not value
				TillerTracker:UpdateMinimapConfig()
			end,
		},	
		plan_ahead = {
			order = 2,
			type = "range",
			min = 1,
			max = 30,
			step = 1,
			name = L["Plan ahead"],
			desc = L["Number of days worth of quests to plan ahead for"],
			get = function()
				return private.db.global.plan_ahead
			end,
			set = function(info, value)
				TillerTracker:SetPlanAhead(value)
			end,
		}
	}
}

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_NAME,
{
	type 	= "data source",
	icon	= "Interface\\Icons\\Inv_Misc_Shovel_01",
	label	= L["Tiller Tracker"],
	text	= L["Tiller Tracker"],
	OnClick = function(clickedframe, button)
		if not private.loaded then
			return
		end

		if button == "LeftButton" then
			if IsControlKeyDown() then
				if _G.Skillet then
					
					-- Open the cooking window if it isn't already
					if not TillerTracker:IsSkilletOpenToCooking() then
						CastSpellByName(GetSpellInfo(2550))
					end
					
					-- Wait for Skillet to come up
					TillerTracker:ScheduleTimer("CheckSkillet", 0.25)
										
					return
				elseif _G.ATSW_AddJob then

					-- Open the cooking window if it isn't already
					if not TillerTracker:IsATSWOpenToCooking() then
						CastSpellByName(GetSpellInfo(2550))
					end

					-- Wait for ATSW to come up
					TillerTracker:ScheduleTimer("CheckATSW", 0.25)

					return
				end
			end

			if (private.pinned) then
				private.tooltip:SetAutoHideDelay(0.25, self)

				private.pinned = false
			else	
				private.tooltip:SetAutoHideDelay()

				private.pinned = true
			end
		elseif button == "RightButton" then
			private.need_index = private.need_index + 1	
					
			TillerTracker:UpdateText()
		end
	end,
})

function TillerTracker:IsSkilletOpenToCooking()
	-- If no frame then it isn't open
	if _G.Skillet.tradeSkillFrame == nil then
		return false
	end

	-- If the frame isn't visible then it isn't open	
	if not _G.Skillet.tradeSkillFrame:IsVisible() then
		return false
	end

	-- If the current trade isn't cooking then it isn't open	
	if _G.Skillet.currentTrade ~= 2550 then
		return false
	end

	-- Must be open	
	return true
end

function TillerTracker:CheckSkillet()

	-- Check to see if Skillet is open to cooking yet
	if not TillerTracker:IsSkilletOpenToCooking() then

		-- Not yet - check again later
		TillerTracker:ScheduleTimer("CheckSkillet", 0.25)

		return	
	end

	-- Clear the current queue
	_G.Skillet:ClearQueue()

	-- Add all the recipes to the queue
	for _, quest_info in pairs(private.quest_table) do
		if (quest_info["CAN_CRAFT_COUNT"] > 0) then
			_G.Skillet:QueueAppendCommand(Skillet:QueueCommandIterate(quest_info["RECIPE_ID"], quest_info["CAN_CRAFT_COUNT"]))
		end
	end
end

function TillerTracker:IsATSWOpenToCooking()
	-- If no frame then it isn't open
	if _G.ATSWFrame == nil then
		return false
	end

	-- If the frame isn't visible then it isn't open	
	if not _G.ATSWFrame:IsVisible() then
		return false
	end

	-- If the current trade isn't cooking then it isn't open	
	if _G.atsw_selectedskill ~= "Cooking" then
		return false
	end

	-- Must be open	
	return true
end

function TillerTracker:CheckATSW()

	-- Check to see if ATSW is open to cooking yet
	if not TillerTracker:IsATSWOpenToCooking() then

		-- Not yet - check again later
		TillerTracker:ScheduleTimer("CheckATSW", 0.25)

		return	
	end

	-- Clear the current queue
	_G.ATSW_DeleteQueue()

	-- Add all the recipes to the queue
	for _, quest_info in pairs(private.quest_table) do
		if (quest_info["CAN_CRAFT_COUNT"] > 0) then
			_G.ATSW_AddJob(GetSpellInfo(quest_info["RECIPE_ID"]), quest_info["CAN_CRAFT_COUNT"])
		end
	end
end

function TillerTracker:OnInitialize()
	private.pinned = false
	private.need_index = 1
	private.loaded = false
	private.item_wait_table = {}
	private.item_wait_count = 0
	
	-- Get rid of settings from before AceDB
	if TillerTrackerDB then
		TillerTrackerDB["SORT_FIELD"] = nil
		TillerTrackerDB["SORT_DIR"] = nil
	end
	
	-- Create the database with defaults
	private.db = LibStub("AceDB-3.0"):New("TillerTrackerDB", defaults)
	
	-- Register options
	AceConfig:RegisterOptionsTable(ADDON_NAME, options, { "/tillertracker" })	
	
	-- Add to the options frame
	private.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, L["Tiller Tracker"])
	
	-- Register a chat command
	self:RegisterChatCommand(L["tillertracker"], "ChatCommand")

	-- Register the minimap icon
	LibDBIcon:Register(ADDON_NAME, LDB, private.db.global.minimap_icon)
end

function TillerTracker:OnEnable()
	-- Disable if the player is less than 90
	if (UnitLevel("player") < 90) then
		LDB.text = L["Disabled until level 90"]

		-- Register to get player level events
		self:RegisterEvent("PLAYER_LEVEL_UP")
	
		return
	end

	if (TillerTracker:AllReputationsDone()) then
		LDB.text = L["Best Friends with everyone"]

		return
	end

	-- Do the real enable
	TillerTracker:OnEnableCore()
end

function TillerTracker:PLAYER_LEVEL_UP(event, newLevel)
	if (tonumber(newLevel) >= 90) then
		-- Do the real enable
		TillerTracker:OnEnableCore()

		-- Done with player level events
		self:UnregisterEvent("PLAYER_LEVEL_UP")
	end
end

function TillerTracker:OnEnableCore()
	-- Show loading text
	TillerTracker:Print(L["Loading..."])
	LDB.text = L["Loading..."]
	
	-- Register to get item info events for now
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED")

	-- Attempt to load the cache
	TillerTracker:LoadCache()

	-- If everything is cached we're good to go
	if (private.item_wait_count == 0) then
		TillerTracker:OnLoaded(self)
	end
end

function TillerTracker:LoadCache()
	-- Loop over each quest in the data	
	for _, quest_info in pairs(private.QUESTS) do 

		-- Get the item ID of the food
		local food_id = quest_info["FOOD_ID"]				

		-- Try to get the info for the food
		local food_name = GetItemInfo(food_id)
		
		-- If the information wasn't available add it to the list of waiting items
		if (food_name == nil) then
			private.item_wait_table[food_id] = true
			private.item_wait_count = private.item_wait_count + 1
		end
		
		-- Loop over the mats required to cook the food for the quest
		for _, mat_data in pairs(quest_info["MATS"]) do 
		
			-- Get the item ID of the mat
			local mat_id = mat_data["ITEM_ID"]				

			-- Try to get the info for the mat
			local mat_name = GetItemInfo(mat_id)

			-- If the information wasn't available add it to the list of waiting items
			if (mat_name == nil) then
				if (private.item_wait_table[mat_id] == nil) then
					private.item_wait_table[mat_id] = true
					private.item_wait_count = private.item_wait_count + 1
				end
			end
		end
	end
end

function TillerTracker:GET_ITEM_INFO_RECEIVED()
	for id, _ in pairs(private.item_wait_table) do
		if GetItemInfo(id) then
			private.item_wait_table[id] = nil
			
			private.item_wait_count = private.item_wait_count - 1
		end
	end
	
	-- If everything is cached we're good to go
	if (private.item_wait_count == 0) then
		TillerTracker:OnLoaded(self)
	end
end

function TillerTracker:OnLoaded(self)
	-- Show loaded text
	TillerTracker:Print(L["Loaded"])
	LDB.text = L["Loaded"]
		
	-- Done with item info events
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")

	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("BAG_UPDATE")
	
	TillerTracker:UpdateData()
	TillerTracker:UpdateText()
	
	private.loaded = true	
end

local function Entry_OnMouseUp(frame, info, button)
	if button == "LeftButton" then
		if not _G.TomTom then
			return
		end	
	
		local location = info["LOCATION"]
	
		_G.TomTom:AddMFWaypoint(807, nil, location[1] / 100, location[2] / 100, { title = info["NAME"] })
	end
end

local function SetSort(cell, sort)
	if private.db.global.sort_field == sort then
		if (private.db.global.sort_dir == "ASC") then
			private.db.global.sort_dir = "DESC"
		else
			private.db.global.sort_dir = "ASC"
		end
	else
		private.db.global.sort_field = sort
		private.db.global.sort_dir = "ASC"
	end

	TillerTracker:UpdateData()
	TillerTracker:UpdateTooltip()
end

function TillerTracker:ReputationDone(reputationId)
	-- Get the reputation information
	local _, friendRep = GetFriendshipReputation(reputationId)

	-- Done if over exalted
	return (friendRep > 42000)
end

function TillerTracker:AllReputationsDone()
	for quest_id, quest_info in pairs(private.QUESTS) do 	
		if not (TillerTracker:ReputationDone(quest_info["REP_ID"])) then
			return false
		end
	end

	return true
end

function TillerTracker:UpdateData()
	-- Get information on all quests completed
	local questsCompleted = GetQuestsCompleted()

	-- Create a table to store our current inventory of required mats	
	local inv_table = {}
	
	-- Create a table to store all needs
	private.need_table = {}
	private.need_count = 0
	
	-- Loop over each quest in the data	
	for _, quest_info in pairs(private.QUESTS) do 
		
		-- Loop over the mats required to cook the food for the quest
		for _, mat_data in pairs(quest_info["MATS"]) do 
		
			-- Get the item ID of the mat
			local mat_id = mat_data["ITEM_ID"]				
			
			-- Figure out how many we have
			local have_count = GetItemCount(mat_id, true, false) 

			-- Add the count to the inventory table (in case of multiples this will just replace what is there)			
			inv_table[mat_id] = have_count
		end		
	end

	-- Create a table to hold the information to display for each quest
	private.quest_table = {}
	private.quest_count = 0

	-- Loop over each quest in the data
	for quest_id, quest_info in pairs(private.QUESTS) do 
		
		-- Only show quests where not at max rep
		if not (TillerTracker:ReputationDone(quest_info["REP_ID"])) then
		
			-- Get the ID of the food required for this quest
			local food_id = quest_info["FOOD_ID"]

			-- Get the name of the food for display
			local food_name = GetItemInfo(food_id)

			-- Get how many of the food we have in our bags
			local food_count = GetItemCount(food_id, true, false)

			-- Get the number of items required
			local required_count = 5 * private.db.global.plan_ahead

			-- Color the food count based on whether there is enough in the bags or not
			local food_count_display = (food_count >= required_count) and "|cFF00FF00" .. food_count .. "|r" or "|cFFFFFF00" .. food_count .. "|r"

			-- Initialize need and status strings
			local need = ""
			local need_count = 0
			local quest_status = ""
			local can_craft = 0

			if (questsCompleted[quest_id]) then
				-- Quest has already been completed today
				quest_status = L["|cFF00FF00Complete|r"]
			else
				-- Quest still needs to be done
				quest_status = L["|cFFFF0000Not Complete|r"]
			end

			-- Figure out how many of the food we need to get to what we need
			need_count = (food_count < required_count) and required_count - food_count or 0

			-- If some food is still needed then display what mats are required
			if (need_count > 0) then
			
				-- Initialize to a high number
				can_craft = 999999

				-- Loop over all mats for this food
				for _, mat_data in pairs(quest_info["MATS"]) do 

					-- Get the mat ID 
					local mat_id = mat_data["ITEM_ID"]
					
					-- Figure out how many we can make with this mat
					local mat_can_craft = math.floor(inv_table[mat_id] / mat_data["COUNT"])
					
					-- The smaller value (current or the mat) is what we can create (max of need count)
					can_craft = math.min(can_craft, mat_can_craft, need_count)

					-- Figure out how many of this mat we need
					local mat_count = (mat_data["COUNT"] * need_count) - inv_table[mat_id]

					-- Deduct the mats used to make the item from the inventory table
					inv_table[mat_id] = inv_table[mat_id] - (mat_data["COUNT"] * need_count)

					-- If the stock of the item went below 0 then reset it to 0
					if (inv_table[mat_id] < 0) then 
						inv_table[mat_id] = 0 
					end				

					-- See if we need mats
					if (mat_count > 0) then

						-- Get the name of the mat					
						local mat_name = GetItemInfo(mat_id)

						-- Set the mat need string to the count needed and the name
						local mat_need = mat_count .. " " .. mat_name

						if private.need_table[mat_id] == nil then
							private.need_table[mat_id] = mat_count
							private.need_count = private.need_count + 1
						else
							private.need_table[mat_id] = private.need_table[mat_id] + mat_count
						end

						-- Add this mat to the list for this quest
						if (need == "") then
							need = mat_need
						else
							need = need .. ", " .. mat_need
						end
					end
				end
			end

			-- Insert everything we figured out into the quest table
			table.insert(private.quest_table,
								{
								NAME = quest_info["NAME"],
								NAME_DISPLAY = "|cffeda55f" .. quest_info["NAME"] .. "|r",
								FOOD = food_name,
								FOOD_DISPLAY = food_name,
								AMOUNT = food_count,
								AMOUNT_DISPLAY = food_count_display,
								STATUS = quest_status,
								LOCATION = quest_info["LOCATION"],
								NEED = need,
								NEED_COUNT = need_count,
								RECIPE_ID = quest_info["RECIPE_ID"],
								CAN_CRAFT_COUNT = can_craft
								})
			
			private.quest_count = private.quest_count + 1
		end
	end

	-- Sort the quest table using the sort field and direction from the settings	
	table.sort(private.quest_table, private.SORT_FUNCTIONS[private.db.global.sort_field .. "_" .. private.db.global.sort_dir])
end

function TillerTracker:UpdateTooltip()
	if LibQTip:IsAcquired(ADDON_NAME) then
		private.tooltip:Clear()
	else
		private.tooltip = LibQTip:Acquire(ADDON_NAME, 5)
		
		private.tooltip:SetBackdropColor(0, 0, 0, 1)

		private.tooltip:SmartAnchorTo(private.LDB_ANCHOR)
		private.tooltip:SetAutoHideDelay(0.25, private.LDB_ANCHOR)
	end
	
	-- If there are no quests show just the status line
	if (private.quest_count == 0) then
		line = private.tooltip:AddHeader()
		private.tooltip:SetCell(line, 1, L["Best Friends with everyone"], "LEFT", private.tooltip:GetColumnCount())			
	
		return
	end
	
	-- Add the header line and set the cell text and scripts
	local line = private.tooltip:AddHeader()
	
	private.tooltip:SetCell(line, 1, L["Quest"])
	private.tooltip:SetCellScript(line, 1, "OnMouseUp", SetSort, "NAME")
	
	private.tooltip:SetCell(line, 2, L["Food"])
	private.tooltip:SetCellScript(line, 2, "OnMouseUp", SetSort, "FOOD")
	
	private.tooltip:SetCell(line, 3, L["Have"])
	private.tooltip:SetCellScript(line, 3, "OnMouseUp", SetSort, "AMOUNT")
	
	private.tooltip:SetCell(line, 4, L["Status"])
	private.tooltip:SetCellScript(line, 4, "OnMouseUp", SetSort, "STATUS")
	
	private.tooltip:SetCell(line, 5, L["Need"])
	private.tooltip:SetCellScript(line, 5, "OnMouseUp", SetSort, "NEED")

	private.tooltip:AddSeparator()
	
	-- Loop over all quests in the sorted table
	for _, quest in pairs(private.quest_table) do
	
		-- Add the line with info about the current quest
		line = private.tooltip:AddLine(quest["NAME_DISPLAY"], quest["FOOD_DISPLAY"], quest["AMOUNT_DISPLAY"], quest["STATUS"], quest["NEED"])

		-- If TomTom is installed then set the line script
		if _G.TomTom then	
			private.tooltip:SetLineScript(line, "OnMouseUp", Entry_OnMouseUp, { NAME = quest["NAME"], LOCATION = quest["LOCATION"] })
		end
	end				

	-- Add the normal usage hints
	private.tooltip:AddLine(" ")
	
	line = private.tooltip:AddLine()
	private.tooltip:SetCell(line, 1, L["|cFFFFFF00Click|r the main button to toggle whether the tooltip stays open"], "LEFT", private.tooltip:GetColumnCount())
	
	line = private.tooltip:AddLine()
	private.tooltip:SetCell(line, 1, L["|cFFFFFF00Right Click|r the main button to cycle through which ingredient to track"], "LEFT", private.tooltip:GetColumnCount())

	-- If TomTom is installed then add a hint to the end
	if _G.TomTom then		
		line = private.tooltip:AddLine()
		private.tooltip:SetCell(line, 1, L["|cFFFFFF00Click|r a quest in the tooltip to set a TomTom waypoint at the farmer's home"], "LEFT", private.tooltip:GetColumnCount())
	end
	
	-- Add the Skillet hint if installed
	if _G.Skillet then
		line = private.tooltip:AddLine()
		private.tooltip:SetCell(line, 1, L["|cFFFFFF00Ctrl-Click|r the main button to queue craftable foods in Skillet"], "LEFT", private.tooltip:GetColumnCount())		
	elseif _G.ATSW_AddJob then
		line = private.tooltip:AddLine()
		private.tooltip:SetCell(line, 1, L["|cFFFFFF00Ctrl-Click|r the main button to queue craftable foods in Advanced Trade Skill Window"], "LEFT", private.tooltip:GetColumnCount())			
	end
end

function TillerTracker:UpdateText()
	local need_index = 1
	
	if (private.need_index > private.need_count) then
		private.need_index = 1
	end
	
	if (private.need_count == 0) then
		LDB.text = L["Done"]
		return
	end

	-- Loop over the need table
	for need_id, need_count in pairs(private.need_table) do
		if need_index == private.need_index then
			LDB.text = L["Gather:"] .. " " .. need_count .. " " .. GetItemInfo(need_id)
			
			return
		end
		
		need_index = need_index + 1
	end
end

function LDB.OnEnter(self)
	if not private.loaded then
		return
	end

	private.LDB_ANCHOR = self
	TillerTracker:UpdateTooltip()
	
	private.tooltip:Show()
end

function TillerTracker:QUEST_LOG_UPDATE()
	TillerTracker:UpdateData()
	TillerTracker:UpdateText()
	
	if not private.LDB_ANCHOR then
		return
	end
	
	TillerTracker:UpdateTooltip()
end

function TillerTracker:BAG_UPDATE()
	TillerTracker:UpdateData()
	TillerTracker:UpdateText()

	if not private.LDB_ANCHOR then
		return
	end

	TillerTracker:UpdateTooltip()
end

function TillerTracker:UpdateMinimapConfig()
	if private.db.global.minimap_icon.hide then
		LibDBIcon:Hide(ADDON_NAME)
	else
		LibDBIcon:Show(ADDON_NAME)
	end				
end

function TillerTracker:ChatCommand(input)

	local command, arg1 = self:GetArgs(input, 2)

	if (command == nil) then
		command = ""
	end

	command = command:lower()

	if command == L["config"]:lower() then
		InterfaceOptionsFrame_OpenToCategory(private.optionsFrame)
	elseif command == L["minimap"]:lower() then
		private.db.global.minimap_icon.hide = not private.db.global.minimap_icon.hide
		TillerTracker:UpdateMinimapConfig()
	elseif command == L["plan"]:lower() then
		if (arg1 == nil or arg1 == "") then
			TillerTracker:Print(L["Current value:"] .. " " .. private.db.global.plan_ahead)
		else
			local value = tonumber(arg1)

			if (value == nil or value < 1 or value > 30) then
				TillerTracker:Print(L["Value must be a number between 1 and 30"])
				return
			end

			TillerTracker:SetPlanAhead(value)

			TillerTracker:Print(L["New value:"] .. " " .. private.db.global.plan_ahead)
		end
	else
		TillerTracker:Print(L["Available commands:"])
		TillerTracker:Print("|cFF00C0FF" .. L["config"] .. "|r - " .. L["Show configuration"])
		TillerTracker:Print("|cFF00C0FF" .. L["minimap"] .. "|r - " .. L["Toggles the minimap icon"])
		TillerTracker:Print("|cFF00C0FF" .. L["plan"] .. "|r - " .. L["Sets the number of days worth of quests to plan ahead for"])
	end
end

function TillerTracker:SetPlanAhead(value)
	private.db.global.plan_ahead = value

	TillerTracker:UpdateData()
	TillerTracker:UpdateText()
	
	if not private.LDB_ANCHOR then
		return
	end
	
	TillerTracker:UpdateTooltip()	
end