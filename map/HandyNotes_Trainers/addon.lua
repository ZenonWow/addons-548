
---------------------------------------------------------
-- Addon declaration
HandyNotes_Trainers = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_Trainers","AceEvent-3.0")
local HT = HandyNotes_Trainers
local Astrolabe = DongleStub("Astrolabe-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_Trainers")


---------------------------------------------------------
-- Our db upvalue and db defaults
local CURRENT_DB_VERSION = 3   -- 2: added npcID; 3: Cata: added floors, index by npcID
local db
local defaults = {
	profile = {
		icon_scale = 1.0,
		icon_alpha = 1.0,
		worldmapfilter = { ["*"] = true },
		minimapfilter = { ["*"] = true },
	},
	factionrealm = {
		dbversion = 0,
		nodes = {
			["*"] = {},
		}
	},
	faction = {
		dbversion = 0,
		nodes = {
			["*"] = { }, 		-- mapname:mapfloor
		}
	},
}


---------------------------------------------------------
-- Localize some globals
local next = next
local select = select
local tonumber = tonumber
local string_find = string.find
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip
local HandyNotes = HandyNotes


---------------------------------------------------------
-- Constants
local iconpath = "Interface\\AddOns\\HandyNotes_Trainers\\Artwork\\"

local iconU = "Interface\\Minimap\\Tracking\\Profession"

local defkey = {}


local tsNameDB = {
-- Primary
		(GetSpellInfo(2259)),	--Alchemy
		(GetSpellInfo(3100)),	--Blacksmithing
		(GetSpellInfo(7411)),	--Enchanting
		(GetSpellInfo(4036)),	--Engineering
		(GetSpellInfo(25229)),	--Jewelcrafting
		(GetSpellInfo(2108)),	--Leatherworking
		(GetSpellInfo(3908)),	--Tailoring
		(GetSpellInfo(45357)),	--Inscription
-- Gathering:
		(GetSpellInfo(2575)),	--Mining
		(GetSpellInfo(8613)),	--Skinning
	--	(GetSpellInfo(2366)),	--Herb Gathering !!! != Herbalism
		(GetSpellInfo(9134)),	--Herbalism !!! Enchantment
	--	(GetSpellInfo(2656)),	--Smelting
-- Secondary:
		(GetArchaeologyInfo()), --Archaeology
		(GetSpellInfo(2550)),	--Cooking
		(GetSpellInfo(3273)),	--First Aid
		(GetSpellInfo(7620)),	--Fishing
}

local translatedTSDB = {
-- Primary professions
	[L["Alchemy"]]        = "Alchemy",
	[L["Blacksmithing"]]  = "Blacksmithing",
	[L["Enchanting"]]     = "Enchanting",
	[L["Engineering"]]    = "Engineering",
	[L["Inscription"]]    = "Inscription",
	[L["Jewelcrafting"]]  = "Jewelcrafting",
	[L["Leatherworking"]] = "Leatherworking",
	[L["Tailoring"]]      = "Tailoring",

	[L["Herbalism"]]      = "Herbalism",
	[L["Mining"]]         = "Mining",
	[L["Skinning"]]       = "Skinning",


-- Secondary professions
	[L["Archaeology"]]    = "Archaeology",
	[L["Cooking"]]        = "Cooking",
	[L["First Aid"]]      = "First Aid",
	[L["Fishing"]]        = "Fishing",
}

setmetatable(tsNameDB, {__index = function (t, k)
					local v = translatedTSDB[k]
					if (v == nil) then v = k end
					print("|cff6fafffHandyNotes_Trainers:|r Untranslated tradeskill name '" .. k .. "' = '" .. v .. "' found! Please report to the addon author.")
					rawset(t, k, v) -- cache the value for next retrievals
					return v
				end})




local iconDB = {

	-- Classes
	["DRUID"]   = iconpath .. "Druid",
	["HUNTER"]  = iconpath .. "Hunter",
	["MAGE"]    = iconpath .. "Mage",
	["PALADIN"] = iconpath .. "Paladin",
	["PRIEST"]  = iconpath .. "Priest",
	["ROGUE"]   = iconpath .. "Rogue",
	["SHAMAN"]  = iconpath .. "Shaman",
	["WARLOCK"] = iconpath .. "Warlock",
	["WARRIOR"] = iconpath .. "Warrior",
	["DEATHKNIGHT"]  = iconpath .. "Deathknight",

	-- Primary
	["Alchemy"]        = iconpath .. "Alchemy",
	["Blacksmithing"]  = iconpath .. "Blacksmithing",
	["Enchanting"]     = iconpath .. "Enchanting",
	["Engineering"]    = iconpath .. "Engineering",
	["Inscription"]    = iconpath .. "Inscription",
	["Jewelcrafting"]  = iconpath .. "Jewelcrafting",
	["Leatherworking"] = iconpath .. "Leatherworking",
	["Tailoring"]      = iconpath .. "Tailoring",

	["Herbalism"]      = iconpath .. "Herbalism",
	["Mining"]         = iconpath .. "Mining",
	["Skinning"]       = iconpath .. "Skinning",

	-- Secondary
	["Archaeology"]    = iconpath .. "Archaeology",
	["Cooking"]        = iconpath .. "Cooking",
	["First Aid"]      = iconpath .. "Firstaid",
	["Fishing"]        = iconpath .. "Fishing",

	-- Special
	["WeaponMaster"]  = iconpath .. "Weaponmaster", -- REMOVED in WoW 4.0.1
	["Riding"]        = iconpath .. "Riding",
	["ColdFlying"]    = iconpath .. "Riding", -- changed to generic Flying teaching all kinds of flying
	["Flying"]        = iconpath .. "Flying", -- teaches flying (generic (Outland), Cold Weather (Northrend), Licence (Cataclysm))

--	["General"]       = iconpath .. "Misc", -- for generic trainers in starting zones TODO...

	["Portal"]  = iconpath .. "Portal",   -- Mage Portals

	["Pet"]     = iconpath .. "Pet",      -- Hunter Pets - TODO: is this needed in WoTLK?
	["Demon"]   = iconpath .. "Demon",    -- Warlock Demons - used for Demon renames

	-- UNUSED
	["Poison"]  = iconpath .. "Poison",   -- never used

	-- Default
	[defkey]    = iconpath .. "Misc", -- for any trainers without icon definition

}
setmetatable(iconDB, {__index = function (t, k)
					local v = nil
					if translatedTSDB[k] then
						v = rawget(t, translatedTSDB[k])
					end
					v = v or t[defkey]
					rawset(t, k, v) -- cache the value for next retrievals
					return v
				end})

local trainerGuilds = {
	[L["Weapon Master"]] = "WeaponMaster",
	[L["Portal Trainer"]] = "Portal",
	[L["Riding Trainer"]] = "Riding",
	[L["Mechanostrider Pilot"]] = "Riding",
	[L["Cold Weather Flying Trainer"]] = "ColdFlying",
}

local trainerGuildsFemale = {
	[L["Weapon Master - Female"]] = "WeaponMaster",
	[L["Portal Trainer - Female"]] = "Portal",
	[L["Riding Trainer - Female"]] = "Riding",
	[L["Mechanostrider Pilot - Female"]] = "Riding",
	[L["Cold Weather Flying Trainer - Female"]] = "ColdFlying",
}

local gossipGuilds = {
	-- General trainers
	[L["Weapon Master"]] = "WeaponMaster",
	[L["Portal Trainer"]] = "Portal",
	[L["Pet Trainer"]] = "Pet",
	[L["Riding Trainer"]] = "Riding",
	[L["Mechanostrider Pilot"]] = "Riding",
	[L["Cold Weather Flying Trainer"]] = "ColdFlying",

	-- Class trainers
	[L["Paladin Trainer"]] = "PALADIN",
	[L["Mage Trainer"]] = "MAGE",
	[L["Druid Trainer"]] = "DRUID",
	[L["Hunter Trainer"]] = "HUNTER",
	[L["Priest Trainer"]] = "PRIEST",
	[L["Rogue Trainer"]] = "ROGUE",
	[L["Shaman Trainer"]] = "SHAMAN",
	[L["Warlock Trainer"]] = "WARLOCK",
	[L["Warrior Trainer"]] = "WARRIOR",
	[L["Deathknight Trainer"]] = "DEATHKNIGHT",

	-- TODO: Specialized trainers
--	[L["Goblin Engineering Trainer"]] = "Engineering",
}

local gossipGuildsFemale = {
	-- General trainers
	[L["Weapon Master - Female"]] = "WeaponMaster",
	[L["Portal Trainer - Female"]] = "Portal",
	[L["Pet Trainer - Female"]] = "Pet",
	[L["Riding Trainer - Female"]] = "Riding",
	[L["Mechanostrider Pilot - Female"]] = "Riding",
	[L["Cold Weather Flying Trainer - Female"]] = "ColdFlying",

	-- Class trainers
	[L["Paladin Trainer - Female"]] = "PALADIN",
	[L["Mage Trainer - Female"]] = "MAGE",
	[L["Druid Trainer - Female"]] = "DRUID",
	[L["Hunter Trainer - Female"]] = "HUNTER",
	[L["Priest Trainer - Female"]] = "PRIEST",
	[L["Rogue Trainer - Female"]] = "ROGUE",
	[L["Shaman Trainer - Female"]] = "SHAMAN",
	[L["Warlock Trainer - Female"]] = "WARLOCK",
	[L["Warrior Trainer - Female"]] = "WARRIOR",
	[L["Deathknight Trainer - Female"]] = "DEATHKNIGHT",

	-- TODO: Specialized trainers
--	[L["Goblin Engineering Trainer - Female"]] = "Engineering",
}

local coordsCache = {}  -- ["zone"] = { [coord] = "npcdata", },
--HandyNotes_Trainers.cache = coordsCache --for debugging

---------------------------------------------------------
-- Plugin Handlers to HandyNotes

local HTHandler = {}

local function deletePin(button, mapFloorId, vNpcid)
	local coord = strsplit(":", db.faction.nodes[mapFloorId][vNpcid])
	coord = tonumber(coord)

	db.faction.nodes[mapFloorId][vNpcid] = nil
	coordsCache[mapFloorId][coord] = nil

	HT:SendMessage("HandyNotes_NotifyUpdate", "Trainers")
end
--[[
local function createWaypoint(button, mapFile, coord)
	local c, z = HandyNotes:GetCZ(mapFile)
	local x, y = HandyNotes:getXY(coord)
	local vType, vName, vGuild = strsplit(":", db.factionrealm.nodes[mapFile][coord])
	if TomTom then
		TomTom:AddZWaypoint(c, z, x*100, y*100, vName)
	elseif Cartographer_Waypoints then
		Cartographer_Waypoints:AddWaypoint(NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, vName))
	end
end
]]

local clickedTrainersNpcId, clickedTrainersZoneFloorId
local info = {}
local function generateMenu(button, level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		-- Create the title of the menu
		--info.isTitle      = 1
		--info.text         = L["HandyNotes - Trainers"]
		--info.notCheckable = 1
		--UIDropDownMenu_AddButton(info, level)

		local coord, vType, vName, vGuild = strsplit(":", db.faction.nodes[clickedTrainersZoneFloorId][clickedTrainersNpcId])
		local lGuild = ""
		if (vGuild ~= nil) and (vGuild ~= "") then
			lGuild = " <" .. vGuild .. ">"
		end

		info.disabled = false
		info.isTitle = true
		info.notCheckable = 1
		info.text = vName .. lGuild
		info.icon = iconDB[vType]
		UIDropDownMenu_AddButton(info, level)

--[[
--disabled until TomTom doesn't require Continent,Zone to index zones or someone finds translation function I don't have to implement
		if TomTom or Cartographer_Waypoints then
			-- Waypoint menu item
			info.disabled     = nil
			info.isTitle      = nil
			info.notCheckable = nil
			info.text = L["Create waypoint"]
			info.icon = nil
			info.func = createWaypoint
			info.arg1 = clickedTrainersZoneFloorId
			info.arg2 = clickedTrainersNpcId
			UIDropDownMenu_AddButton(info, level);
		end
]]

		-- Delete menu item
		info.disabled     = nil
		info.isTitle      = nil
		info.notCheckable = nil
		info.text = L["Delete trainer"]
		info.icon = nil
		info.func = deletePin
		info.arg1 = clickedTrainersZoneFloorId
		info.arg2 = clickedTrainersNpcId
		UIDropDownMenu_AddButton(info, level);

		-- Close menu item
		info.text         = L["Close"]
		info.icon         = nil
		info.func         = function() CloseDropDownMenus() end
		info.arg1         = nil
		info.arg2         = nil
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level);
	end
end
local HT_Dropdown = CreateFrame("Frame", "HandyNotes_TrainersDropdownMenu")
HT_Dropdown.displayMode = "MENU"
HT_Dropdown.initialize = generateMenu

function HTHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and not down then
		local floor = GetCurrentMapDungeonLevel() --we try to quess the floor number, as handynotes doesn't send it to us :(
		local mapFloorId = mapFile .. ":" .. floor


		if coordsCache[mapFloorId] == nil or coordsCache[mapFloorId][coord] == nil then 
			print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Internal cache error - create")
			return
		end

		local vNpcid = coordsCache[mapFloorId][coord]
		if db.faction.nodes[mapFloorId][vNpcid] == nil then
			print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Internal cache error - delete")
			return
		end

		clickedTrainersZoneFloorId = mapFloorId
		clickedTrainersNpcId = vNpcid
		
		ToggleDropDownMenu(1, nil, HT_Dropdown, self, 0, 0)
	end
end

function HTHandler:OnEnter(mapFile, coord)
	local floor = GetCurrentMapDungeonLevel() --we try to quess the floor number, as handynotes doesn't send it to us :(
	local mapFloorId = mapFile .. ":" .. floor

	if coordsCache[mapFloorId] == nil or coordsCache[mapFloorId][coord] == nil then 
		print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Internal cache error - create")
		return
	end

	local vNpcid = coordsCache[mapFloorId][coord]
	if db.faction.nodes[mapFloorId][vNpcid] == nil then
		print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Internal cache error - delete")
		return
	end

	local coord, vType, vName, vGuild = strsplit(":", db.faction.nodes[mapFloorId][vNpcid])


	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

	tooltip:AddLine("|cffe0e0e0"..vName.."|r")
	if (vGuild ~= "") then tooltip:AddLine(vGuild) end
--	if (vType ~= "") then tooltip:AddLine("|cffe0e0e0"..vType.."|r") end
--	tooltip:AddLine(L["Trainer"])
	tooltip:Show()
end

function HTHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

do
	local prevkey = nil

	-- This is a custom iterator we use to iterate over every node in a given zone
--[[	local function iter(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			if value then
				local vType, vName, vGuild = strsplit(":", value)
				local icon = iconDB[vType]
				return state, nil, icon, db.profile.icon_scale, db.profile.icon_alpha
			end
			state, value = next(t, state)
		end
		return nil, nil, nil, nil
	end
]]
	local function worlditer(t, prevcoord)
		if not t then return nil end

		--local state, value = next(t, prestate)

		local value
		prevkey, value = next(t, prevkey)

		while prevkey do
			if value then
				local vCoord, vType, vName, vGuild = strsplit(":", value)
				if db.profile.worldmapfilter[vType] then
					local icon = iconDB[vType]
					vCoord = tonumber(vCoord)
					if vCoord then
						return vCoord, nil, icon, db.profile.icon_scale, db.profile.icon_alpha, nil
					end
				end
			end
			prevkey, value = next(t, prevkey)
		end
		return nil, nil, nil, nil, nil, nil
	end
	local function miniiter(t, prevcoord)
		if not t then return nil end

		local value
		prevkey, value = next(t, prevkey)

		while prevkey do
			if value then
				local vCoord, vType, vName, vGuild = strsplit(":", value)
				if db.profile.minimapfilter[vType] then
					local icon = iconDB[vType]
					vCoord = tonumber(vCoord)
					if vCoord then
						return vCoord, nil, icon, db.profile.icon_scale, db.profile.icon_alpha, nil
					end
				end
			end
			prevkey, value = next(t, prevkey)
		end
		return nil, nil, nil, nil, nil, nil
	end

	local function cacheCreate(nodes, mapFloorId)
		--if (coordsCache[mapFile] == nil) then coordsCache[mapFile] = {} end
		--if coordsCache[mapFile][dungeonLevel] ~= nil then return end --not empty = already filled in for this map
		if coordsCache[mapFloorId] ~= nil then return end --not empty = already filled in for this map

		local cacheTab = {}
		coordsCache[mapFloorId] = cacheTab

		for k, v in pairs(nodes) do
			local coord = strsplit(":", v)
			coord = tonumber(coord)
			if coord then cacheTab[coord] = k end
		end
	end

	function HTHandler:GetNodes(mapFile, minimap, dungeonLevel)
		local mapFloorId = mapFile .. ":" .. dungeonLevel
		cacheCreate(db.faction.nodes[mapFloorId], mapFloorId)
		prevkey = nil
		if minimap then
			--print("|cff6fafffHandyNotes_Trainers:|r Sending nodes for minimap: "..mapFloorId.."...")
			return miniiter, db.faction.nodes[mapFloorId], nil
		else
			--print("|cff6fafffHandyNotes_Trainers:|r Sending nodes for worldmap: "..mapFloorId.."...")
			return worlditer, db.faction.nodes[mapFloorId], nil
		end
	end
end


---------------------------------------------------------
-- Options table

local options = {
	type = "group",
	name = "Trainers",
	desc = "Trainers",
	get = function(info) return db.profile[info.arg] end,
	set = function(info, v)
		db.profile[info.arg] = v
		HT:SendMessage("HandyNotes_NotifyUpdate", "Trainers")
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the Trainers icons."],
			type = "description",
			order = 0,
		},
		icon_scale = {
			type = "range",
			name = L["Icon Scale"],
			desc = L["The scale of the icons"],
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale",
			order = 10,
		},
		icon_alpha = {
			type = "range",
			name = L["Icon Alpha"],
			desc = L["The alpha transparency of the icons"],
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha",
			order = 20,
		},
	},
}


---------------------------------------------------------
-- NPC info tracking - TT handling

local tt = CreateFrame("GameTooltip")
tt:SetOwner(UIParent, "ANCHOR_NONE")
tt.left = {}
tt.right = {}

for i = 1, 30 do
	tt.left[i] = tt:CreateFontString()
	tt.left[i]:SetFontObject(GameFontNormal)
	tt.right[i] = tt:CreateFontString()
	tt.right[i]:SetFontObject(GameFontNormal)
	tt:AddFontStrings(tt.left[i], tt.right[i])
end


local LEVEL_start = "^" .. (type(LEVEL) == "string" and LEVEL or "Level")
local function FigureNPCGuild(unit)
	tt:ClearLines()
	tt:SetUnit(unit)
	if not tt:IsOwned(UIParent) then
		tt:SetOwner(UIParent, "ANCHOR_NONE")
	end
	local left_2 = tt.left[2]:GetText()
	if not left_2 or left_2:find(LEVEL_start) then
		return ""
	end
	return left_2
end

---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HT:OnInitialize()
	-- Set up our database
	db = LibStub("AceDB-3.0"):New("HandyNotes_TrainersDB", defaults)
	self.db = db

	if db.faction.dbversion > CURRENT_DB_VERSION then
		print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Unknown database version. Please update to newer version.")
		print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Addon has been disabled to protect your database.")
		self:Disable()
		return
	end

	if db.faction.dbversion ~= CURRENT_DB_VERSION then
		if db.faction.dbversion == 0 then
			-- addon was just installed
			db.faction.dbversion = CURRENT_DB_VERSION
		end

		if db.faction.dbversion < 3 then
			-- shouldn't happen
			db.faction.dbversion = 3 --first faction version
		end
	end

	if (db.factionrealm.dbversion > 0) and (db.factionrealm.dbversion < 3) then --move data from factionrealm to faction

		print("|cff6fafffHandyNotes_Trainers:|r Upgrading databse...")
			
		local oldnodes = db.factionrealm.nodes
		local newnodes = db.faction.nodes
		for mapname, mapdata in pairs(oldnodes) do
			local mapId = HandyNotes:GetMapFiletoMapID(mapname)
			local floorcount = Astrolabe:GetNumFloors(mapId)
			if floorcount == 0 then
				--print("|cff6fafffHandyNotes_Trainers:|r Upgrading " .. mapname .. "...")
				local newmap = newnodes[mapname .. ":0"]
				for coord, vData in pairs(mapdata) do
					local vType, vName, vGuild, vNpcid = strsplit(":", vData)
					vNpcid = tonumber(vNpcid)
					if vNpcid and (vNpcid < 150000) then -- remove NPCs without npcid or wrong npcids (current max ~ 50,000)
						local vInfo1 = coord .. ":" .. vType .. ":" .. vName .. ":" .. vGuild
						newmap[vNpcid] = vInfo1
					end
				end
			else
				if floorcount == nil then
					print("|cff6fafffHandyNotes_Trainers:|r Skipped " .. mapname .. "... - removed map")
				else
					print("|cff6fafffHandyNotes_Trainers:|r Skipped " .. mapname .. "... - cannot upgrade map with multiple floors")
				end
			end
		end
		db.factionrealm.nodes = {} -- remove old data
		db.factionrealm.dbversion = 3 -- converted to Cata data version
		print("|cff6fafffHandyNotes_Trainers:|r Upgrade done.")
		
	end

	-- Initialize our database with HandyNotes
	HandyNotes:RegisterPluginDB("Trainers", HTHandler, options)
end

function HT:OnEnable()
	self:RegisterEvent("TRAINER_SHOW")
	self:RegisterEvent("GOSSIP_SHOW")
end

do
	local filters = {"available", "unavailable", "used"}
	local filtersrestore = {}

	-- this table is for fixing Blizzard's IsTradeskillTrainer() failure for some tradeskill trainers :(
	local TradeskillTrainers = { 
		[19186] = true, --Kylene <Barmaid> http://www.wowhead.com/?npc=19186
	}

function HT:TRAINER_SHOW()
	local vName = UnitName("npc")
	local vGuild = FigureNPCGuild("npc")
	local vType = nil

	local vGuid = UnitGUID("npc")
	local vNpcid = tonumber(vGuid:sub(-12, -9), 16)

	if IsTradeskillTrainer() or TradeskillTrainers[vNpcid] then

		for i,f in ipairs(filters) do
			if GetTrainerServiceTypeFilter(f) ~= 1 then
				SetTrainerServiceTypeFilter(f, 1)
				filtersrestore[f] = true
			else
				filtersrestore[f] = nil
			end
		end

		vType = GetTrainerServiceSkillLine(1)

		for f,v in pairs(filtersrestore) do
			if v then
				SetTrainerServiceTypeFilter(f, 0)
			end
		end

	elseif trainerGuilds[vGuild] then
		vType = trainerGuilds[vGuild]
	elseif trainerGuildsFemale[vGuild] then
		vType = trainerGuildsFemale[vGuild]
	else
		vType = select(2, UnitClass("player"))
	end

	if vType then self:AddTrainerNote(vNpcid, vName, vGuild, vType) end

end --function HT:TRAINER_SHOW()
end --do

function HT:GOSSIP_SHOW()
	local vName = UnitName("npc")
	local vGuild = FigureNPCGuild("npc")
	local vType = nil

	local vGuid = UnitGUID("npc")
	local vNpcid = tonumber(vGuid:sub(-12, -9), 16)

	if gossipGuilds[vGuild] then
		vType = gossipGuilds[vGuild]
	elseif gossipGuildsFemale[vGuild] then
		vType = gossipGuildsFemale[vGuild]
	end

	if vType then self:AddTrainerNote(vNpcid, vName, vGuild, vType) end
end


local thres = 5 -- in yards
function HT:AddTrainerNote(vNpcid, vName, vGuild, vType)

	local mapID, floor, x, y = Astrolabe:GetCurrentPlayerPosition()
	if not vName or not mapID then
		return
	end

	local coord = HandyNotes:getCoord(x, y)
	local mapFile = HandyNotes:GetMapIDtoMapFile(mapID)

	--print("|cff6fafffHandyNotes_Trainers:|r Adding... MapID:"..mapID.." MapFile:"..(mapFile or ""))
	if mapFile then

		local mapFloorId = mapFile .. ":" .. floor

		if coordsCache[mapFloorId] == nil then coordsCache[mapFloorId] = {} end

		if db.faction.nodes[mapFloorId][vNpcid] ~= nil then  -- If Already exists
			local vInfo = db.faction.nodes[mapFloorId][vNpcid]
			local ocoord = strsplit(":", vInfo)
			ocoord = tonumber(ocoord)
			if ocoord then
				local cx, cy = HandyNotes:getXY(ocoord)
				local dist = Astrolabe:ComputeDistance(mapID, floor, x, y, mapID, floor, cx, cy)
				if dist <= thres then 
					--return  -- update not required, bail out
					coord = ocoord -- do not move trainer
				else
					if coordsCache[mapFloorId][ocoord] == vNpcid then
						coordsCache[mapFloorId][ocoord] = nil  -- when trainer is moved, old entry is removed
					end
				end
			else
				--create new one - old coords was not a number
			end
		end

		local vInfo3 = coord .. ":" .. vType .. ":" .. vName .. ":" .. vGuild

		db.faction.nodes[mapFloorId][vNpcid] = vInfo3

		coordsCache[mapFloorId][coord] = vNpcid

		self:SendMessage("HandyNotes_NotifyUpdate", "Trainers")
	end
end
