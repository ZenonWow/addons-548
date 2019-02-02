
-- ====================================== --
-- Shared Functions for Broker_Everything --
-- ====================================== --
local addon, ns = ...
local upper,format,type = upper,format,type
local GetPlayerMapPosition,GetRealZoneText,GetSubZoneText = GetPlayerMapPosition,GetRealZoneText,GetSubZoneText
local GetZonePVPInfo,GetBindLocation = GetZonePVPInfo,GetBindLocation
local L = ns.L
local _
ns.tocversion  = select(4, GetBuildInfo())
-- ns.build = tonumber(gsub(({GetBuildInfo()})[1],"[|.]","")..({GetBuildInfo()})[2])

ns.LDB = LibStub("LibDataBroker-1.1")
ns.LQT = LibStub("LibQTip-1.0")
ns.LDBI = LibStub("LibDBIcon-1.0")
ns.LSO = LibStub("LibSimpleOptions-1.0-be_mod")
ns.LSM = LibStub("LibSharedMedia-3.0")

ns.LT = LibStub("LibTime-1.0")
ns.LC = LibStub("LibColors-1.0")

-- broker_everything colors
ns.LC.colorset({
	["ltyellow"]	= "fff569",
	["dkyellow"]	= "ffcc00",
	["ltorange"]	= "ff9d6a",
	["dkorange"]	= "905d0a",
	["dkred"]		= "c41f3b",
	["ltred"]		= "ff8080",
	["dkred"]		= "800000",
	["violet"]		= "f000f0",
	["ltviolet"]	= "f060f0",
	["dkviolet"]	= "800080",
	["ltblue"]		= "69ccf0",
	["dkblue"]		= "000088",
	["ltcyan"]		= "80ffff",
	["dkcyan"]		= "008080",
	["ltgreen"]		= "80ff80",
	["dkgreen"]		= "00aa00",

	["dkgray"]		= "404040",
	["ltgray"]		= "b0b0b0",

	["gold"]		= "ffd700",
	["silver"]		= "eeeeef",
	["copper"]		= "f0a55f",

	["unknown"]		= "ee0000",
})


-- ---------------------------------- --
-- misc shared data                   --
-- ~Hizuro                            --
-- ---------------------------------- --
ns.realm = GetRealmName();
ns.media = "Interface\\AddOns\\"..addon.."\\media\\";


-- ----------------------------------- --
-- player and twinks dependent data    --
-- ~Hizuro                             --
-- ----------------------------------- --
ns.player = {}
ns.player.name = UnitName("player")
_, ns.player.class = UnitClass("player")
ns.player.faction,ns.player.factionL  = UnitFactionGroup("player")
L[ns.player.faction] = ns.player.factionL
ns.player.female = UnitSex("player")==3
ns.player.classLocale = ns.player.female and _G.LOCALIZED_CLASS_NAMES_FEMALE[ns.player.class] or _G.LOCALIZED_CLASS_NAMES_MALE[ns.player.class]
ns.LC.colorset("suffix",ns.LC.colorset[ns.player.class:lower()]) -- 

be_twink_db = {}
do
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent",function(self,event,...)
		if event=="ADDON_LOADED" then
			be_twink_db[ns.realm.." - "..ns.player.name] = ns.player
			f:UnregisterEvent(event)
		end
	end)
	f:RegisterEvent("ADDON_LOADED")
end
ns.twink = function(name,realm)
	if realm == nil then realm = ns.realm end
	if realm ~= false then
		local key = realm.." - "..name
		return (be_twink_db[key]~=nil and be_twink_db[key]) or false
	else
		local twinks = {}
		for i,v in pairs(be_twink_db) do
			
		end
	end
end


-- ----------------------------------- --
-- SetCVar hook
-- Thanks at blizzard for blacklisting some cvars on combat...
-- ~Hizuro
-- ----------------------------------- --
do
	local blacklist = {alwaysShowActionBars = true, bloatnameplates = true, bloatTest = true, bloatthreat = true, consolidateBuffs = true, fullSizeFocusFrame = true, maxAlgoplates = true, nameplateMotion = true, nameplateOverlapH = true, nameplateOverlapV = true, nameplateShowEnemies = true, nameplateShowEnemyGuardians = true, nameplateShowEnemyPets = true, nameplateShowEnemyTotems = true, nameplateShowFriendlyGuardians = true, nameplateShowFriendlyPets = true, nameplateShowFriendlyTotems = true, nameplateShowFriends = true, repositionfrequency = true, showArenaEnemyFrames = true, showArenaEnemyPets = true, showPartyPets = true, showTargetOfTarget = true, targetOfTargetMode = true, uiScale = true, useCompactPartyFrames = true, useUiScale = true}
	ns.SetCVar = function(...)
		local cvar = ...
		if ns.tocversion >= 50408 and InCombatLockdown() and blacklist[cvar]==true then
			-- Since v5.4.8
			local msg
			-- usefull blacklisted cvars..
			if cvar=="uiScale" or cvar=="useUiScale" then
				msg = "Changing UI scaling while combat nether an good idea."
			else
			-- useless blacklisted cvars...
				msg = "Sorry, CVar "..cvar.." are no longer changeable while combat. Thanks @ Blizzard."
			end
			print("|cffff8800"..addon..": "..msg.."|r")
		else
			SetCVar(...)
		end
	end
end


-- ----------------------------------- --
-- Helpful function for extra tooltips --
-- ----------------------------------- --

function ns.defaultOnEnter(module, display)
	if  ns.tooltipChkOnShowModifier()  then  return  end
	local tooltip, reused = ns.LQT:Acquire(module.name)
	ns.attachTooltip(module, tooltip)
	module.onqtip(tooltip, reused)
	ns.createTooltip(display, tooltip, module.mouseOverTooltip)
end

function ns.defaultOnLeave(module, display)
	ns.hideTooltip(module.tooltip, module.name, not module.mouseOverTooltip)
	-- if  not module.mouseOverTooltip  then  module.tooltip = nil  end
end


function ns.defaultOnTooltipShow(module, tooltip)
	module.ontooltip(tooltip)
	ns.attachTooltip(module, tooltip)
end


function ns.attachTooltip(module, tooltip)
	-- Release (and detach) previous tooltip.
	if  module.tooltip  and  module.tooltip ~= tooltip  then
		if  module.tooltip.Release  then
			ns.LQT:Release(module.tooltip)
			-- module.tooltip:Release()
		else
			module.tooltip:Hide()
		end
	end

	-- Detach acquired tooltip, no release.
	--[[
	local prevOnHide = tooltip:GetScript('OnHide')
	if  prevOnHide  then  prevOnHide(tooltip)  end
	--]]
	tooltip:Hide()
	if  tooltip:GetScript('OnHide')  then  print("BE.attachTooltip('"..module.name.."', '"..(tooltip.key or tooltip:GetName() or "?").."'): OnHide script is expected to unregister itself.")  end

	module.tooltip = tooltip

	tooltip:SetScript('OnHide', function (tooltip)
		-- print("modules['"..module.name.."'].tooltip:OnHide()")
		tooltip:SetScript('OnHide', nil)
		if  module.tooltip == tooltip  then  module.tooltip = nil  end
	end)
end


ns.GetTipAnchor = function(frame, menu)
	local x, y = frame:GetCenter()
	if (not x) or (not y) then return "TOPLEFT", "BOTTOMLEFT"; end

	local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

	local X = (hhalf=="LEFT") and -3 or 3
	local Y = (vhalf=="BOTTOM") and -3 or 3

	return vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf, X,Y
end

local function SmartAnchorTo(self,frame)
	if not frame then
		error("Invalid frame provided.", 2)
	end
	self:ClearAllPoints()
	self:SetClampedToScreen(true)
	self:SetPoint(ns.GetTipAnchor(frame))
end

ns.tooltipScaling = function(tooltip)
	if Broker_EverythingDB.tooltipScale == true then
		tooltip:SetScale(tonumber(GetCVar("uiScale")))
	end
end


local function hideOnClick(tooltip)
	-- First click disables tooltip.stayOpen
	if  tooltip.stayOpen  then
		tooltip.stayOpen = nil
		tooltip:SetAutoHideDelay(0.001, tooltip.owner)
		return false
	end
	ns.hideTooltip(tooltip, nil, true)
end

function ns.setStayOpen(tooltip, closeAfterClick, closeDelay)
	-- closeAfterClick -> disable stayOpen if clicked
	-- closeDelay == nil -> open forever, until closed explicitly
	tooltip.stayOpen = true
	if closeAfterClick then  tooltip:SetScript("OnMouseUp", hideOnClick)  end
	tooltip:SetAutoHideDelay(closeDelay, tooltip.owner)
end

ns.hideTooltip = function(tooltip, checkTooltipKey, immediately)
	if not tooltip then  return  end

	-- Custom tooltip? To hide it pass checkTooltipKey == nil.
	if checkTooltipKey and tooltip.key ~= checkTooltipKey then  return  end
	-- Sticky tooltip can be closed only forcefully.
	if  tooltip.stayOpen  and  not immediately  then  return  end

	local allowMouseOverModifier = Broker_EverythingDB.ttModifierKey2;
	local allowMouseOver =  not immediately  or  tooltip.slider  and  tooltip.slider:IsShown()
	if  allowMouseOver  and  ns.tooltipChkOnShowModifier(allowMouseOverModifier)  then  allowMouseOver = false  end

	if allowMouseOver and tooltip:IsMouseOver() then
		-- tooltip:SetScript("OnLeave", hideOnLeave)
		if  not tooltip.autoHideTimerFrame  then  tooltip:SetAutoHideDelay(0.001, tooltip.owner)  end
		return
	end

	do
		do
			local f = allowMouseOver and GetMouseFocus()
			-- if (f) and (not f:IsForbidden()) and (not f:IsProtected() and InCombatLockdown()) and (type(f.key)=="string") and (type(checkTooltipKey)=="string") and (f.key==checkTooltipKey) then
			if (f) and (not f:IsForbidden()) and (not f:IsProtected() and InCombatLockdown()) and  (f.key==checkTooltipKey) then
				-- (Unprotected) frame under the mouse focus (in combat) that is the tooltip, but the tooltip under the mouse already made this function return.
				print("I think this never happens. f.key='"..f.key.."'")
				return; -- why that? tooltip can't be closed in combat with securebuttons as child elements. results in addon_action_blocked... 
			end
		end

		if type(tooltip.secureButtons)=="table" then
			for i,v in ipairs(tooltip.secureButtons)do
				ns.secureButton2Hide(v)
			end
			ns.secureButton(false);
		end
		tooltip.stayOpen = nil
		-- tooltip:SetScript("OnUpdate",nil)
		-- tooltip:SetScript("OnLeave",nil)
		tooltip:SetScript("OnMouseUp",nil)
		ns.LQT:Release(tooltip)
		return true
	end
end

ns.createTooltip = function(owner, tooltip, allowMouseOverTooltip)
	if Broker_EverythingDB.tooltipScale then
		tooltip:SetScale(tonumber(GetCVar("uiScale")))
	end
	tooltip.owner = owner
	if owner then  SmartAnchorTo(tooltip, owner)  end
	if allowMouseOverTooltip then
		tooltip:SetAutoHideDelay(0.001, owner)
		tooltip:SetScript("OnMouseUp", hideOnClick)
	end
	tooltip:UpdateScrolling(WorldFrame:GetHeight() * Broker_EverythingDB.maxTooltipHeight)
	tooltip:Show()
end

ns.RegisterMouseWheel = function(self, scriptFunc)
	self:EnableMouseWheel(1) 
	self:SetScript("OnMouseWheel", scriptFunc)
end

ns.tooltipModifierText = {
	NONE       = L["Default (no modifier)"],
	SHIFT      = L["Shift"],      
	LEFTSHIFT  = L["Left shift"], 
	RIGHTSHIFT = L["Right shift"],
	ALT        = L["Alt"],        
	LEFTALT    = L["Left alt"],   
	RIGHTALT   = L["Right alt"],  
	CTRL       = L["Ctrl"],       
	LEFTCTRL   = L["Left ctrl"],  
	RIGHTCTRL  = L["Right ctrl"], 
}
ns.tooltipModifierFunc = {
	NONE       = false,
	-- NONE       = function()  return true  end,
	SHIFT      = IsShiftKeyDown,
	LEFTSHIFT  = IsLeftShiftKeyDown,
	RIGHTSHIFT = IsRightShiftKeyDown,
	ALT        = IsAltKeyDown,
	LEFTALT    = IsLeftAltKeyDown,
	RIGHTALT   = IsRightAltKeyDown,
	CTRL       = IsControlKeyDown,
	LEFTCTRL   = IsLeftControlKeyDown,
	RIGHTCTRL  = IsRightControlKeyDown,
}

ns.tooltipChkOnShowModifier = function (modifier)
	local modifier = modifier or Broker_EverythingDB.ttModifierKey1
	local modDownFunc = ns.tooltipModifierFunc[modifier]
	-- Set, but not pressed? That's a nogo.
	return IsKeyDown and not IsKeyDown()
end


-- -------------------------- --
-- nice little print function --
-- ~Hizuro                    --
-- -------------------------- --
ns.print = function (...)
	local colors,t = {"red","green","ltblue","yellow","orange","violet"},{}
	for i,v in ipairs({addon..":",...}) do
		if type(v)=="string" and v:match("||c") then
			tinsert(t,v)
		else
			tinsert(t,ns.LC.color(colors[i] or "white",v))
		end
	end
	print(unpack(t))
end
ns.Print = ns.print

ns.print_r = function(title,obj)
	assert(type(title)=="string","argument 1# must be a string ("..type(title).." given).")
	assert(type(obj)=="table","argument 2# must be a table ("..type(obj).." given)")
	for k,v in pairs(obj) do
		if type(v) ~= "string" and type(v)~="number" then v = "<"..type(v)..">" end
		ns.print(title,k,"=",v)
	end
end
ns.print_t = ns.print_r


-- -------------------------------------------------- --
-- Icon provider and framework to support             --
-- use of external iconset                            --
-- -------------------------------------------------- --
do
	local iconset = nil
	local objs = {}
	ns.I = setmetatable({},{
		__index = function(t,k)
			local v = {iconfile="interface\\icons\\inv_misc_questionmark",coords={0.05,0.95,0.05,0.95}}
			rawset(t, k, v)
			return v
		end,
		__call = function(t,a)
			if a==true then
				if Broker_EverythingDB.iconset~="NONE" then
					iconset = ns.LSM:Fetch((addon.."_Iconsets"):lower(),Broker_EverythingDB.iconset) or iconset
				end
				return
			end
			assert(type(a)=="string","argument #1 must be a string, got "..type(a))
			return (type(iconset)=="table" and iconset[a]) or t[a]
		end
	})
	ns.updateIcons = function()
		for i,v in pairs(ns.modules) do
			local obj = v.obj
			if obj~=nil then 
				local d = ns.I(i .. (v.icon_suffix or ""))
				obj.iconCoords = d.coords or {0,1,0,1}
				obj.icon = d.iconfile
			end
		end
	end
	
	-- -------------------------- --
	-- icon colouring function    --
	-- ~Hizuro                    --
	-- -------------------------- --
	ns.updateIconColor = function(module)
		local f = function(obj)
			if obj==nil then return false end
			obj.iconR,obj.iconG,obj.iconB,obj.iconA = unpack(Broker_EverythingDB.iconcolor or ns.LC.color("white","colortable"))
			return true
		end
		if module == true then
			for n,module in pairs(ns.modules) do f(module.obj) end
		else
			f(module.obj)
		end
	end
end


-- -------------------------------------------------- --
-- Function to Sort a table by the keys               --
-- Sort function fom http://www.lua.org/pil/19.3.html --
-- -------------------------------------------------- --
-- Import from LibSimpleOptions
ns.pairsByKeys = ns.LSO.pairsByKeys
--[==[
ns.pairsByKeys = ns.LSO.pairsByKeys  or  function(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		local key = a[i]
		return key, t[key]
		--[=[ t[nil] == nil always and safely
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
		--]=]
	end
	return iter
end
--]==]

--[=[
ns.reversePairsByKeys = function(t,f)
	local a = {}
	for n in ipairs(t) do
		table.insert(a,n)
	end
	table.sort(a, f)
	local i = #a
	local iter = function()
		i = i - 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end
--]=]

-- ---------------------------------------- --
-- Function to append an element to a table --
-- and optional limit his max entries       --
-- ~Hizuro                                  --
-- ---------------------------------------- --
ns.insertAppend = function(old_table,elem,max_entries)
	local new = {elem}
	for _, e in pairs(old_table) do
		new[#new] = e
		if max_entries ~= nil and #new == max_entries then return new end
	end
	return new
end


-- -------------------------------------------------------------- --
-- Function to split a string                                     --
-- http://stackoverflow.com/questions/1426954/split-string-in-lua --
-- Because mucking around with strings makes my head hurt.        --
-- -------------------------------------------------------------- --
ns.splitText = function(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	local i = 1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = strtrim(str) .. sep
		i=i+1
	end
	return table.concat(t, "|n")
end

ns.splitTextToHalf = function(inputstr, sep)
	local t = {}
	local i = 1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] =strtrim(str) .. " "
		i=i+1
	end
	local h,a,b = ceil(i/2),"",""
	for i, v in pairs(t) do
		if i < h then a = a .. v else b = b .. v end
	end
	return a.."|n"..b
end

ns.split = function(iStr,splitBy,opts)
	-- escapes sollten temporär ersetzt werden...
	if splitBy=="length" then
		assert(type(opts.length)=="number","opts.length must be a number, "..type(opts.length).."given.")
	elseif splitBy=="half" then
	elseif splitBy=="sepcount" then
		assert(type(opts.count)=="number","opts.count must be a number, "..type(opts.count).."given.")
	elseif splitBy=="sep" then
		
	end
end

ns.getBorderPositions = function(f)
	local us = UIParent:GetEffectiveScale()
	local uw,uh = UIParent:GetWidth(), UIParent:GetHeight()
	local fx,fy = f:GetCenter()
	local fw,fh = f:GetWidth()/2, f:GetHeight()/2
	-- LEFT, RIGHT, TOP, BOTTOM
	return fx-fw, uw-(fx+fw), uh-(fy+fh),fy-fh
end

ns.strLimit = function(str,limit)
	if strlen(str)>limit then str = strsub(str,1,limit).."..." end
	return str
end


-- -------------------------------------------------------------- --
-- module independent bag scan width interval                     --
-- ~Hizuro                                                        --
-- -------------------------------------------------------------- --
do
	ns.bagScan = {items={},last=time(),interval=60,active=false,resets={},updates={}}

	ns.bagScan.RegisterId = function(modName,itemId,foundFunc,resetFunc,updateFunc)
		assert(type(modName)=="string" and ns.modules[modName],"argument #1 (modName) must be a string, got "..type(modName))
		assert(type(itemId)=="number","argument #2 (itemId) must be a number, got "..type(itemId))
		assert(type(foundFunc)=="function","argument #3 (foundFunc) must be a function, got "..type(foundFunc))
		assert(type(resetFunc)=="function","argument #4 (resetFunc) must be a function, got "..type(resetFunc))
		assert(type(updateFunc)=="function","argument #5 (updateFunc) must be a function, got "..type(updateFunc))

		if ns.bagScan.items[itemId]==nil then
			ns.bagScan.items[itemId] = {}
		end
		ns.bagScan.items[itemId][modName] = foundFunc
		ns.bagScan.resets[modName] = resetFunc
		ns.bagScan.updates[modName] = updateFunc
		ns.bagScan.active = true
	end

	ns.bagScan.Update = function(now)
		-- prevent full usage of the function if no item/module registered.
		if ns.bagScan.active~=true then return end

		-- limit bagscan to a fix timeout. see ns.bagScan.interval
		if now~=true then
			if (time()-ns.bagScan.last)<ns.bagScan.interval then return end
			ns.bagScan.last = time()
		end

		-- reset tables in the registered modules
		for i,v in pairs(ns.bagScan.resets) do
			if type(v)=="function" then v() end
		end

		-- scan the bag and execute the foundFunc for all matching items
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				local item_id = GetContainerItemID(bag,slot)
				if ns.bagScan.items[item_id]~=nil then
					for i,v in pairs(ns.bagScan.items[item_id]) do v(item_id,bag,slot) end
				end
			end
		end

		-- trigger all updateFunc from all registered modules - mostly to update the broker button text
		for i,v in pairs(ns.bagScan.updates) do
			if type(v)=="function" then v() end
		end
	end
end


-- ----------------------------------------
-- secure button as transparent overlay
-- http://wowpedia.org/SecureActionButtonTemplate
-- be careful...
-- ~Hizuro
-- 
-- @param self UI_ELEMENT 
-- @param obj  TABLE
--		obj = {
--			{
--				typeName  STRING  | see "Modified attributes"
--				typeValue STRING  | see "Action types" "Type"-column
--				attrName  STRING  | see "Action types" "Used attributes"-column
--				attrValue ~mixed~ | see "Action types" "Behavior"-column. 
--				                  | Note: if typeValue is click then attrValue must
--										  be a ui element with :Click() function like
--										  buttons. thats a good way to open frames
--										  like spellbook without risk tainting it by
--										  an addon.
--			},
--			{ ... }
--		}
-- ----------------------------------------
-- [=[
do
	local sbf = nil -- change to array
	ns.secureButton = function(self,obj)
		if self==nil or  InCombatLockdown() then return end

		if sbf~=nil and self==false then
			sbf:SetParent(UIParent)
			sbf:ClearAllPoints()
			sbf:Hide()
			return 
		end

		if type(obj)~="table" then
			return
		end

		sbf = sbf or CreateFrame("Button",addon.."_SecureButton",UIParent,"SecureActionButtonTemplate")
		sbf:SetParent(self)
		sbf:SetPoint("CENTER")
		sbf:SetWidth(self:GetWidth())
		sbf:SetHeight(self:GetHeight())
		sbf:SetHighlightTexture([[interface\friendsframe\ui-friendsframe-highlightbar-blue]],true)

		for i,v in pairs(obj) do
			if type(v.typeName)=="string" and type(v.typeValue)=="string" then
				sbf:SetAttribute(v.typeName,v.typeValue)
			end
			if type(v.attrName)=="string" and v.attrValue~=nil then
				sbf:SetAttribute(v.attrName,v.attrValue)
			end
		end

		sbf:Show()
	end

	local sb = {}
	local sbFrame = CreateFrame("frame")
	ns.secureButton2 = function(self,obj,name)
		if type(obj)~="table" then return end
		local sbf = nil

		if sb[name]==nil then
			--sb[name] = CreateFrame("Button",nil,self,"BE_SecureWrapper")
			sb[name] = CreateFrame("Frame","BE_SF_"..name,sbFrame,"BE_SecureFrame")
		end

		sb[name]:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
		sb[name]:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)

		for i,v in pairs(obj) do
			if type(v.typeName)=="string" and type(v.typeValue)=="string" then
				sb[name].button:SetAttribute(v.typeName,v.typeValue)
			end
			if type(v.attrName)=="string" and v.attrValue~=nil then
				sb[name].button:SetAttribute(v.attrName,v.attrValue)
			end
		end

		sb[name]:Show()
	end
	ns.secureButton2Hide = function(name)
		if sb[name]~=nil and sb[name]:IsShown() then
			sb[name]:ClearAllPoints()
			sb[name]:Hide()
		end
	end
end
--]=]


-- --------------------- --
-- scanTooltip functions --
-- --------------------- --
do
	local scanTooltip = CreateFrame("GameTooltip",addon.."_ScanTooltip",UIParent,"GameTooltipTemplate")
	scanTooltip:SetScale(0.0001)
	scanTooltip:Hide()

	-- ------------------------------------------- --
	-- GetItemData                                 --
	-- a 2in1 function to fetch item informations  --
	-- for use in other addons                     --
	-- ~Hizuro                                     --
	-- ------------------------------------------- --
	function ns.GetItemData(id,bag,slot)
		assert(type(id)=="number","argument #1 (id) must be a number, got "..type(id))
		local data = {}
		data.itemName, data.itemLink, data.itemRarity, data.itemLevel, data.itemMinLevel, data.itemType, data.itemSubType, data.itemStackCount, data.itemEquipLoc, data.itemTexture, data.itemSellPrice = GetItemInfo(id)
		if bag~=nil and slot~=nil then
			assert(type(bag)=="number","argument #2 (bag) must be a number, got "..type(bag))
			assert(type(slot)=="number","argument #3 (slot) must be a number, got "..type(slot))
			data.startTime, data.duration, data.isEnabled = GetContainerItemCooldown(bag,slot)
			scanTooltip:Show()
			scanTooltip:SetOwner(UIParent,"LEFT",0,0)
			scanTooltip:SetBagItem(bag,slot)
			local reg = {scanTooltip:GetRegions()}
			local line = 1
			for k,v in pairs(reg) do
				if v~=nil and v:GetObjectType()=="FontString" and v:GetText()~=nil then
					data["tooltipLine"..line] = v:GetText()
					line = line + 1
				end
			end
			scanTooltip:ClearLines()
			scanTooltip:Hide()
		end
		return data
	end

	-- --------------------------------------- --
	-- GetRealFaction2PlayerStanding           --
	-- return standingID of a faction          --
	-- if faction unknown or argument nil then --
	-- returns this function the standingID 4  --
	-- --------------------------------------- --
	function ns.GetFaction2PlayerStanding(faction) -- FactionID or FactionName
		local collapsed, standing = {},4
		if faction~=nil then
			for i=GetNumFactions(), 1, -1 do -- 1. round: expand all collapsed headers
				local name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, _, _, _ = GetFactionInfo(i)
				if isHeader and isCollapsed then
					collaped[name] = true
					ExpandFactionHeader(i)
				end
			end
			for i=1, GetNumFactions() do -- 2. round: search faction and note his standing
				local name, _, standingID, _, _, _, _, _, _, _, _, _, _, factionID, _, _ = GetFactionInfo(i)
				if faction==name or faction==factionID then
					standing = standingID
				end
			end
			for i=GetNumFactions(), 1, -1 do -- 3. round: collapsed all by this function expanded headers. 
				local name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, _, _, _ = GetFactionInfo(i)
				if isHeader and collapsed[name] then
					CollapseFactionHeader(i)
				end
			end
		end
		return standing
	end

	-- ----------------
	-- UnitFaction
	-- ----------------
	function ns.UnitFaction(unit)
		scanTooltip:SetUnit(unit)
		scanTooltip:Show()
		local reg,_next,faction = {scanTooltip:GetRegions()},false,nil
		scanTooltip:Hide()
		for i,v in ipairs(reg) do
			if v:GetObjectType()=="FontString" then
				v = v:GetText() or ""
				if _next==false and v:match("^"..TOOLTIP_UNIT_LEVEL) then
					_next = true
				elseif _next==true then
					faction = v
					_next = nil
				end
			end
		end
		return faction, ns.GetFaction2PlayerStanding(faction)
	end
end

-- ----------------
-- tooltip graph (unstable)
-- ~Hizuro
-- ----------------
do
	local modData = {}
	ns.tooltipGraph = function(modName, maxValues, maxHeight, noScale)
		local s, barWidth, barSpace = UIParent:GetEffectiveScale(), 1, 1
		if noScale==true then s = 1 end

		local fN = ("%s_%s_ttGraph"):format(addon,modName)
		local f = f or _G[fN] or CreateFrame("frame",fN)
		if f.bars==nil then
			do
				f.bars = {}
				local n = f
				for i=1, maxValues do
					f.bars[i] = CreateFrame("frame",nil,f)
					f.bars[i]:SetWidth(barWidth * s)
					f.bars[i]:SetBackdrop({bgFile=[[Interface\Buttons\WHITE8X8]], Tile=false})
					if type(Broker_EverythingDB[modName].barColor)=="table" then
						f.bars[i]:SetBackdropColor(Broker_EverythingDB[modName].barColor)
					end
					f.bars[i]:SetPoint("BOTTOMLEFT", n, f==n and "BOTTOMLEFT" or "BOTTOMRIGHT", f==n and 0 or barSpace * s, 0)
					n=f.bars[i]
				end
			end
		end

		f:SetHeight(maxHeight)
		f:SetWidth(#modData[modName] * (barWidth+barSpace))

		local minV,maxV = 9999,0
		for i, v in ipairs(modData[modName]) do
			if v<minV then minV = v end --min value
			if v>maxV then maxV = v end --max value
		end

		local v
		for i=maxValues, 1, -1 do
			if modData[modName][i]==nil then
				v = 1
			else
				v = (modData[modName][i] - minV) / ((maxV - minV) / maxHeight)
			end
			f.bars[maxValues - i + 1]:SetHeight(ceil(v) * s)
		end

		return f
	end
	ns.tooltipGraphAddValue = function(modName,value,maxValues)
		local t = {}
		if modData[modName]==nil then modData[modName] = {} end
		table.insert(t,tonumber(value))
		for i,v in ipairs(modData[modName]) do
			if (#t < maxValues) then
				table.insert(t,v)
			end
		end
		modData[modName] = t
	end
end

-- ----------------------------------------------------- --
-- goldColor function to display amount of gold          --
-- in colored strings or with coin textures depending on --
-- a per module and a addon wide toggle.                 --
-- ~Hizuro                                               --
-- ----------------------------------------------------- --
function ns.GetCoinColorOrTextureString(modName,amount,sep)
	if Broker_EverythingDB[modName].goldColor==true or Broker_EverythingDB.goldColor==true then
		if (not sep) then sep = "." end
		local gold, silver, copper, t, i = floor(amount / 10000), mod(floor(amount / 100), 100), mod(floor(amount), 100), {}, 1
		if gold>0 then t[i]=ns.LC.color("gold",gold) silver=("%02d"):format(silver) i=i+1 end
		if tonumber(silver)>0 or silver=="00" then t[i]=ns.LC.color("silver",silver) copper=("%02d"):format(copper) i=i+1 end
		t[i] = ns.LC.color("copper",copper)
		return table.concat(t,sep)
	else
		return GetCoinTextureString(amount)
	end
end


-- ----------------------------------------------------- --
-- screen capture mode - string replacement function     --
-- ~Hizuro                                               --
-- ----------------------------------------------------- --
ns.scm = function(str,all)
	if type(str)=="string" and strlen(str)>0 and Broker_EverythingDB.scm==true then
		if all then
			return strrep("*",(strlen(str)))
		else
			return strsub(str,1,1)..strrep("*",(strlen(str)-1))
		end
	else
		return str
	end
end


-- ----------------------------------------------------- --
-- Get[Game|Local|UTC|Country|Played]Time functions      --
-- ~Hizuro                                               --
-- ----------------------------------------------------- --
do
	local d = {frame=CreateFrame("frame"),sync=false,m=false}
	d.frame.elapsed, d.frame.interval = 0, 0.5
	function ns.GetGameTime(syncIt)
		local h, m, s, n = GetGameTime()

		if s~=nil then -- surprise. blizzard provide server time with seconds? [maybe in future ^^]
			d.frame:SetScript("OnUpdate",nil)
			ns.GetGameTime = GetGameTime
			return h, m, s
		end

		if d.m==false then
			d.m=m
		end

		if syncIt==true and d.m~=m then
			d.frame.interval=1
			d.sync=time()
			d.m=m
		end

		return h, m, ("%02d"):format(d.sync~=false and time()-d.sync or 0)
	end

	d.frame:SetScript("OnUpdate",function(self,elapsed) if self.elapsed>=self.interval then self.elapsed=0; ns.GetGameTime(true) end self.elapsed = self.elapsed + elapsed; end)


	function ns.GetLocalTime()
		return date("%H"), date("%M"), date("%S")
	end

	function ns.GetUTCTime()
		return date("!%H"), date("!%M"), date("!%S")
	end

--[[
	function ns.GetCountryTime(country)
		local cdata
		if type(country)=="string" and ns.countriesBy.name[country]~=nil then
			cdata = ns.countries[ns.countriesBy.name[country] ]
		elseif type(country)=="number" and ns.countries[country]~=nil then
			cdata = ns.countries[country];
		end
		assert(type(cdata)=="table", "usage: ns.GetCountryTime(<country name or countryId>");
		
	end
]]
end

do
	local d = CreateFrame("frame")
	d:SetScript("OnEvent",function(self,event,...) self.total, self.level = ...; self.stamp = time() end)
	d:RegisterEvent("TIME_PLAYED_MSG")
	function ns.GetPlayedTime()
		local session = time()-d.stamp
		return d.total + session, d.level + session, session -- rise up played time without use of RequestTimePlayed()
	end
end


-- ------------------------ --
-- Hide blizzard elements   --
-- ~Hizuro                  --
-- ------------------------ --
do
	local hidden = CreateFrame("Frame",addon.."_FrameHider")
	hidden.origParent = {}
	hidden:Hide()

	--[[
	ns.hideFrame = function(frameName)
		local pName = _G[frameName]:GetParent():GetName()
		if pName==nil then
			return false
		end
		hidden.origParent[frameName] = pName
		_G[frameName]:SetParent(hidden)
	end
	--]]

	ns.hideFrame = function(frameName, hide)
		local frame = _G[frameName]
		local orig = hidden.origParent[frame]
		if  hide  and  not orig  then
			local parent = frame:GetParent()
			assert(parent, "Broker_Everything: ns.hideFrame("..frameName..") does not support frames without parent.")
			hidden.origParent[frame] = parent
			frame:SetParent(hidden)
		elseif  not hide  and  orig  then
			frame:SetParent(orig)
			hidden.origParent[frame] = nil
		end
	end

	ns.unhideFrame = function(frameName)  return ns.hideFrame(frameName, false)  end
end

-- ---------------- --
-- EasyMenu wrapper --
-- ~Hizuro          --
-- ---------------- --

do
	ns.EasyMenu = {};
	local UIDropDownMenuDelegate = CreateFrame("FRAME");
	local UIDROPDOWNMENU_MENU_LEVEL;
	local UIDROPDOWNMENU_MENU_VALUE;
	local UIDROPDOWNMENU_OPEN_MENU;
	local self = ns.EasyMenu;
	self.menu = {};

	local cvarTypeFunc = {
		bool = function(...)
		end,
		slider = function(...)
		end,
		number = function(...)
		end,
		str = function(...)
		end
	};
	local beOptTypeFunc = {
		bool = function(...)
		end,
		slider = function(...)
		end,
		number = function(...)
		end,
		str = function(...)
		end
	};

	self.InitializeMenu = function()
		if (not self.frame) then
			self.frame = CreateFrame("Frame", addon.."EasyMenu", UIParent, "UIDropDownMenuTemplate");
		end
		wipe(self.menu);
	end

	self.addEntry = function(D,P)
		local entry= {};

		if (D.separator) then
			entry = {
				text = "",
				dist = 0,
				isTitle = true,
				notCheckable = true,
				isNotRadio = true,
				isUninteractable = true,
				iconOnly = true,
				icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
				tCoordLeft = 0,
				tCoordRight = 1,
				tCoordTop = 0,
				tCoordBottom = 1,
				tSizeX = 0,
				tFitDropDownSizeX = true,
				tSizeY = 8
			};
			entry.iconInfo = entry; -- looks like stupid... thats blizzard.
		else
			entry.isTitle      = D.title     or false;
			entry.hasArrow     = D.arrow     or false;
			entry.disabled     = D.disabled  or false;
			entry.notClickable = not not D.noclick;
			entry.isNotRadio   = not D.radio;

			if (D.checked~=nil) then
				entry.checked      = D.checked;
				entry.keepShownOnClick = 1;
			else
				entry.notCheckable = true;
			end

			entry.text = D.label or "";

			if (D.colorName) then
				entry.colorCode = "|c"..ns.LC.color(D.colorName);
			elseif (D.colorCode) then
				entry.colorCode = entry.colorCode;
			end

			if (D.icon) then
				entry.text = entry.text .. "    ";
				entry.icon = D.icon;
				entry.tCoordLeft, entry.tCoordRight = 0.05,0.95;
				entry.tCoordTop, entry.tCoordBottom = 0.05,0.95;
			end

			if (D.type=="cvar") then
				if (type(D.cvarType)=="string") and (cvarTypeFunc[D.cvarType]) then
					entry.func = function(_self)
						cvarTypeFunc[D.cvarType](_self,D);
					end
				end
			elseif (D.type=="be_option") then
				if (type(D.beOptType)=="string") and (beOptTypeFunc[D.beOptType]) then
					entry.func = function(_self)
						beOptTypeFunc[D.beOptType](_self,D);
					end
				end
			elseif (D.func) then
				entry.arg1 = D.arg1;
				entry.arg2 = D.arg2;
				entry.func = function(...)
					D.func(...)
					if (P) then
						if (_G["DropDownList1"]) then _G["DropDownList1"]:Hide(); end
					end
				end;
			elseif (not D.title) and (not D.disabled) and (not D.arrow) and (not D.checked) then
				entry.disabled = true;
			end
		end

		if (P) and (type(P)=="table") then
			if (not P.menuList) then P.menuList = {}; end
			tinsert(P.menuList, entry);
			return P.menuList[#P.menuList];
		else
			tinsert(self.menu, entry);
			return self.menu[#self.menu];
		end
		return false;
	end

	self.ShowMenu = function(parent, parentX, parentY)
		local anchor, x, y, displayMode = "cursor", nil, nil, "MENU"

		if (parent) then
			anchor = parent;
			x = parentX or 0;
			y = parentY or 0;
		end

		self.addEntry({separator=true});
		self.addEntry({label=CANCEL, func=function() self.frame:Hide(); end});

		UIDropDownMenu_Initialize(self.frame, EasyMenu_Initialize, displayMode, nil, self.menu);
		ToggleDropDownMenu(1, nil, self.frame, anchor, x, y, self.menu, nil, nil);
	end

	self.HideMenu = function()
		if  self.frame  and self.frame:IsShown()  then
			ToggleDropDownMenu(1, nil, self.frame)
			return true
		end
	end
end

