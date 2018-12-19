
---------------------------------------------------------
-- Addon declaration
HandyNotes_Vendors = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_Vendors","AceEvent-3.0")
local HV = HandyNotes_Vendors
local Astrolabe = DongleStub("Astrolabe-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_Vendors")


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
			["*"] = { }, 		-- mapname:mapfloor
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
--local iconN = "Interface\\Minimap\\Tracking\\Food"
--local iconN = "Interface\\Minimap\\Tracking\\Banker"
--local iconR = "Interface\\Minimap\\Tracking\\Repair"
--local iconI = "Interface\\Minimap\\Tracking\\Innkeeper"

local VENDOR_GENERIC = "N"
local VENDOR_REPAIR = "R"
local VENDOR_INNKEEPER = "I"
local VENDOR_REAGENTS = "S"
local VENDOR_POISONS = "P"
local VENDOR_FOOD = "F"


local defkey = {}
local iconDB = {
	[VENDOR_GENERIC] = "Interface\\Minimap\\Tracking\\Food",
	[VENDOR_REPAIR] = "Interface\\Minimap\\Tracking\\Repair",
	[VENDOR_INNKEEPER] = "Interface\\Minimap\\Tracking\\Innkeeper",
	[VENDOR_REAGENTS] = "Interface\\Minimap\\Tracking\\Reagents",
	[VENDOR_POISONS] = "Interface\\Minimap\\Tracking\\Poisons",
	[VENDOR_FOOD] = "Interface\\Minimap\\Tracking\\Food",

	-- Default
	[defkey] = "Interface\\Minimap\\Tracking\\Banker", -- for DB errors??
		}

setmetatable(iconDB, {__index = function (t, k)
					local v = t[defkey]
					rawset(t, k, v) -- cache the value for next retrievals
					return v
				end})

local IgnoredVendors = {
	-- Traveler's Tundra Mammoth (Alliance mount): http://www.wowdb.com/npc.aspx?id=32633, http://www.wowdb.com/item.aspx?id=44235
	[32638] = true, -- "Hakmud of Argus <Traveling Trader>" http://www.wowdb.com/npc.aspx?id=32638
	[32639] = true, -- "Gnimo <Adventurous Tinker>" http://www.wowdb.com/npc.aspx?id=32639
	
	-- Traveler's Tundra Mammoth (Horde mount): http://www.wowdb.com/npc.aspx?id=32640, http://www.wowdb.com/item.aspx?id=44234
	[32641] = true, -- "Drix Blackwrench <The Fixer>" http://www.wowdb.com/npc.aspx?id=32641
	[32642] = true, -- "Mojodishu <Traveling Trader>" http://www.wowdb.com/npc.aspx?id=32642

	-- Argent Squire (Alliance companion from Argent Tournament): http://www.wowhead.com/npc=33238, http://www.wowhead.com/item=44998
	[33238] = true, 
	-- Argent Gruntling (Horde companion from Argent Tournament): http://www.wowhead.com/npc=33239, http://www.wowhead.com/item=45022
	[33239] = true,

	-- Jeeves (Engineering companion): http://www.wowhead.com/npc=35642, http://www.wowhead.com/item=49040
	[35642] = true,

	-- Alliance Guild Page (Guild companion from "Horde Slayer"): http://www.wowhead.com/npc=49586, http://www.wowhead.com/item=65361
	[49586] = true,
	-- Alliance Guild Herald (Guild companion from "Profit Sharing"): http://www.wowhead.com/npc=49587, http://www.wowhead.com/item=65363
	[49587] = true,

	-- Horde Guild Page (Guild companion from "Horde Slayer"): http://www.wowhead.com/npc=49588, http://www.wowhead.com/item=65362
	[49588] = true,
	-- Horde Guild Herald (Guild companion from "Profit Sharing"): http://www.wowhead.com/npc=49590, http://www.wowhead.com/item=65364
	[49590] = true,
	}


-- because HandyNotes uses coords as their primary index for everything we have to translate it back to npcID

local coordsCache = {}  -- ["zone"] = { [coord] = "npcdata", },
--HandyNotes_Vendors.cache = coordsCache --for debugging


---------------------------------------------------------
-- Plugin Handlers to HandyNotes

local HVHandler = {}

local function deletePin(button, mapFloorId, vNpcid)
	local coord = strsplit(":", db.faction.nodes[mapFloorId][vNpcid])
	coord = tonumber(coord)

	db.faction.nodes[mapFloorId][vNpcid] = nil
	coordsCache[mapFloorId][coord] = nil

	HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
end
--[[
local function createWaypoint(button, mapFloorId, vNpcid)

	local mapFile, mapFloor = strsplit(":", mapFloorId)
	local coord, vType, vName, vGuild = strsplit(":", db.faction.nodes[mapFloorId][vNpcid])
	coord = tonumber(coord)

	--local c, z = HandyNotes:GetCZ(mapFile)
	local x, y = HandyNotes:getXY(coord)

	local lGuild = ""
	if (vGuild ~= nil) and (vGuild ~= "") then
		lGuild = " <" .. vGuild .. ">"
	end

	if TomTom then
		TomTom:AddZWaypoint(c, z, x*100, y*100, vName .. lGuild)
	end
end
]]

local clickedVendorsNpcId, clickedVendorsZoneFloorId
local info = {}
local function generateMenu(button, level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		-- Create the title of the menu
		--info.isTitle      = 1
		--info.text         = L["HandyNotes - Vendors"]
		--info.notCheckable = 1
		--UIDropDownMenu_AddButton(info, level)


		local coord, vType, vName, vGuild = strsplit(":", db.faction.nodes[clickedVendorsZoneFloorId][clickedVendorsNpcId])
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
			info.arg1 = clickedVendorsZoneFloorId
			info.arg2 = clickedVendorsNpcId
			UIDropDownMenu_AddButton(info, level);
		end
]]

		-- Delete menu item
		info.disabled     = nil
		info.isTitle      = nil
		info.notCheckable = nil
		info.text = L["Delete vendor"]
		info.icon = nil
		info.func = deletePin
		info.arg1 = clickedVendorsZoneFloorId
		info.arg2 = clickedVendorsNpcId
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
local HV_Dropdown = CreateFrame("Frame", "HandyNotes_VendorsDropdownMenu")
HV_Dropdown.displayMode = "MENU"
HV_Dropdown.initialize = generateMenu

function HVHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and not down then
		local floor = GetCurrentMapDungeonLevel() --we try to quess the floor number, as handynotes doesn't send it to us :(
		local mapFloorId = mapFile .. ":" .. floor


		if coordsCache[mapFloorId] == nil or coordsCache[mapFloorId][coord] == nil then 
			print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Internal cache error - create")
			return
		end

		local vNpcid = coordsCache[mapFloorId][coord]
		if db.faction.nodes[mapFloorId][vNpcid] == nil then
			print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Internal cache error - delete")
			return
		end

		clickedVendorsZoneFloorId = mapFloorId
		clickedVendorsNpcId = vNpcid
		
		ToggleDropDownMenu(1, nil, HV_Dropdown, self, 0, 0)
	end
end

function HVHandler:OnEnter(mapFile, coord)
	local floor = GetCurrentMapDungeonLevel() --we try to quess the floor number, as handynotes doesn't send it to us :(
	local mapFloorId = mapFile .. ":" .. floor

	if coordsCache[mapFloorId] == nil or coordsCache[mapFloorId][coord] == nil then 
		print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Internal cache error - create")
		return
	end

	local vNpcid = coordsCache[mapFloorId][coord]
	if db.faction.nodes[mapFloorId][vNpcid] == nil then
		print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Internal cache error - delete")
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
--	tooltip:AddLine(L["Vendor"])
	tooltip:Show()
end

function HVHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

do
	local prevkey = nil

	-- This is a custom iterator we use to iterate over every node in a given zone
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

	function HVHandler:GetNodes(mapFile, minimap, dungeonLevel)
		local mapFloorId = mapFile .. ":" .. dungeonLevel
		cacheCreate(db.faction.nodes[mapFloorId], mapFloorId)
		prevkey = nil
		if minimap then
			--print("|cff6fafffHandyNotes_Vendors:|r Sending nodes for minimap: "..mapFloorId.."...")
			return miniiter, db.faction.nodes[mapFloorId], nil
		else
			--print("|cff6fafffHandyNotes_Vendors:|r Sending nodes for worldmap: "..mapFloorId.."...")
			return worlditer, db.faction.nodes[mapFloorId], nil
		end
	end
end


local function GetVFilters()
	local vnds = {
	[VENDOR_GENERIC] = L["TYPE_Vendor"],
	[VENDOR_REPAIR] = L["TYPE_Repair"],
	[VENDOR_INNKEEPER] = L["TYPE_Innkeeper"],
		}

	local res = {}
	for id, text in pairs(vnds) do
		res[id] = "|T"..iconDB[id]..":18|t "..text
	end
	return res
end

---------------------------------------------------------
-- Options table

local options = {
	type = "group",
	name = "Vendors",
	desc = "Vendors",
	get = function(info) return db.profile[info.arg] end,
	set = function(info, v)
		db.profile[info.arg] = v
		HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the Vendors icons."],
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
		worldmapfilters = {
			type = "multiselect",
			name = L["World Map Filter"],
			desc = nil,
			order = 30,
			width = "full",
			get = function(info, k) return db.profile.worldmapfilter[k] end,
			set = function(info, k, v)
				db.profile.worldmapfilter[k] = v
				HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
			end,
			values = GetVFilters(),
		},
		minimapfilters = {
			type = "multiselect",
			name = L["Minimap Filter"],
			desc = nil,
			order = 40,
			width = "full",
			get = function(info, k) return db.profile.minimapfilter[k] end,
			set = function(info, k, v)
				db.profile.minimapfilter[k] = v
				HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
			end,
			values = GetVFilters(),
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

function HV:OnInitialize()
	-- Set up our database
	db = LibStub("AceDB-3.0"):New("HandyNotes_VendorsDB", defaults)
	self.db = db

	if db.faction.dbversion > CURRENT_DB_VERSION then
		print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Unknown database version. Please update to newer version.")
		print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Addon has been disabled to protect your database.")
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

		print("|cff6fafffHandyNotes_Vendors:|r Upgrading databse...")
			
		local oldnodes = db.factionrealm.nodes
		local newnodes = db.faction.nodes
		for mapname, mapdata in pairs(oldnodes) do
			local mapId = HandyNotes:GetMapFiletoMapID(mapname)
			local floorcount = Astrolabe:GetNumFloors(mapId)
			if floorcount == 0 then
				--print("|cff6fafffHandyNotes_Vendors:|r Upgrading " .. mapname .. "...")
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
					print("|cff6fafffHandyNotes_Vendors:|r Skipped " .. mapname .. "... - removed map")
				else
					print("|cff6fafffHandyNotes_Vendors:|r Skipped " .. mapname .. "... - cannot upgrade map with multiple floors")
				end
			end
		end
		db.factionrealm.nodes = {} -- remove old data
		db.factionrealm.dbversion = 3 -- converted to Cata data version
		print("|cff6fafffHandyNotes_Vendors:|r Upgrade done.")
		
	end

	-- Initialize our database with HandyNotes
	HandyNotes:RegisterPluginDB("Vendors", HVHandler, options)
end

function HV:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("GOSSIP_SHOW")     -- for better tracking of Innkeepers
	self:RegisterEvent("CONFIRM_BINDER")  -- for better tracking of Innkeepers
end


local innkeepers = {}  -- table to store Innkeepers' npcids to not overwrite their icons

function HV:MERCHANT_SHOW()
	local vName = UnitName("npc")
	local canRepair = CanMerchantRepair()
	local vGuild = FigureNPCGuild("npc")

	local vGuid = UnitGUID("npc")
	local vNpcid = tonumber(vGuid:sub(-12, -9), 16)

	if innkeepers[vNpcid] then
		return  -- is already added as Innkeeper
	end

	local vType = canRepair and VENDOR_REPAIR or VENDOR_GENERIC

	self:AddVendorNote(vNpcid, vName, vGuild, vType)
end

-- This is helper function for working with variable number of return values from GetGossipOptions()
local function IsBinder(...)
	for i=2, select("#", ...), 2 do      -- just iterate over even items as these contain the type name
		if select(i, ...) == "binder" then
			return true -- found, no need to continue
		end
	end
	return false
end

-- This is tail recursion version of helper function for working with variable number of return values from GetGossipOptions()
local function IsBinderTail(x, t, ...)
	if not x then return false end
	--return t == "binder" or IsBinderTail(...)
	if t == "binder" then return true end
	return IsBinderTail(...)
end

function HV:GOSSIP_SHOW()
	if IsBinder(GetGossipOptions()) then
		local vName = UnitName("npc")
		local vGuild = FigureNPCGuild("npc")

		local vGuid = UnitGUID("npc")
		local vNpcid = tonumber(vGuid:sub(-12, -9), 16)

		innkeepers[vNpcid] = true

		self:AddVendorNote(vNpcid, vName, vGuild, VENDOR_INNKEEPER)
	end
end

function HV:CONFIRM_BINDER()
	local vName = UnitName("npc")
	local vGuild = FigureNPCGuild("npc")

	local vGuid = UnitGUID("npc")
	if not vGuid then
		return   -- weird, we didn't get Innkeeper's GUID?
	end
	local vNpcid = tonumber(vGuid:sub(-12, -9), 16)

	if innkeepers[vNpcid] then
		return  -- is already added as Innkeeper
	end

	self:AddVendorNote(vNpcid, vName, vGuild, VENDOR_INNKEEPER)
end

local thres = 5 -- in yards
function HV:AddVendorNote(vNpcid, vName, vGuild, vType)

	if IgnoredVendors[vNpcid] then
		return -- this vendor is ignored
	end

	local mapID, floor, x, y = Astrolabe:GetCurrentPlayerPosition()
	if not vName or not mapID then
		return
	end

	local coord = HandyNotes:getCoord(x, y)
	local mapFile = HandyNotes:GetMapIDtoMapFile(mapID)

	--print("|cff6fafffHandyNotes_Vendors:|r Adding... MapID:"..mapID.." MapFile:"..(mapFile or ""))
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
					coord = ocoord -- do not move vendor
				else
					if coordsCache[mapFloorId][ocoord] == vNpcid then
						coordsCache[mapFloorId][ocoord] = nil  -- when vendor is moved, old entry is removed
					end
				end
			else
				--create new one - old coords was not a number
			end
		end

		local vInfo3 = coord .. ":" .. vType .. ":" .. vName .. ":" .. vGuild

		db.faction.nodes[mapFloorId][vNpcid] = vInfo3

		coordsCache[mapFloorId][coord] = vNpcid

		self:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
	end
end
