local _G, ADDON_NAME, _ADDON = _G, ...
_ADDON.LibStub = LibStub
_ADDON.LDB = LibStub("LibDataBroker-1.1")
_ADDON.LSM = LibStub("LibSharedMedia-3.0")
_ADDON.Jostle = LibStub("LibJostle-3.0", true)
_ADDON.ChocolateBar = LibStub("AceAddon-3.0"):NewAddon("ChocolateBar", "AceConsole-3.0", "AceEvent-3.0")
_ADDON.L = LibStub("AceLocale-3.0"):GetLocale("ChocolateBar")

local _G, pairs, ipairs, table, string, tostring = _G, pairs, ipairs, table, string, tostring
local select, strjoin, CreateFrame = select, strjoin, CreateFrame

local broker = _ADDON.LDB
local LSM = _ADDON.LSM
local ChocolateBar = _ADDON.ChocolateBar
local L = _ADDON.L

_ADDON.Bar = {}
_ADDON.ChocolatePiece = {}
ChocolateBar.Drag = {}

local Bar = _ADDON.Bar
local Chocolate = _ADDON.ChocolatePiece
-- local Drag = ChocolateBar.Drag

ChocolateBar.chocolateBars = {}
local chocolateBars = ChocolateBar.chocolateBars
ChocolateBar.chocolateObjects = {}
local chocolateObjects = ChocolateBar.chocolateObjects
local db --reference to ChocolateBar.db.profile

--------
-- utility functions
--------
function ChocolateBar.Debug(...)  print("ChocolateBar Debug:", ...)  end
local Debug = ChocolateBar.Debug
--[[
local function Debug(...)
	if ChocolateBar.db.char.debug then
	 	local s = "ChocolateBar Debug:"
		for i=1,select("#", ...) do
			local x = select(i, ...)
			s = strjoin(" ",s,tostring(x))
		end
		_G.DEFAULT_CHAT_FRAME:AddMessage(s)
	end
end

function ChocolateBar:Debug(...)
	Debug(self, ...)
end
--]]


function debugbars()
	for k,v in pairs(chocolateBars) do
		Debug(k,v)
	end
end


--------
-- drop points functions
--------
local function dropText(frame, choco)
		local name = choco.name
		db.objSettings[name].showText = not db.objSettings[name].showText
		ChocolateBar:AttributeChanged(nil, name, "updateSettings", db.objSettings[name].showText)
		choco.bar:ResetDrag(choco, name)
		frame:SetBackdropColor(0,0,0,1)
end

local function dropOptions(frame, choco)
		--[[
		local name = choco.name
		db.objSettings[name].align = "center"
		db.objSettings[name].stickcenter = true
		choco.bar:ResetDrag(choco, name)
		frame:SetBackdropColor(0,0,0,1)
		--]]
		local obj = choco.obj
		local name = obj.name
		local label = obj.label
		local cleanName
		if label then 
			cleanName = string.gsub(label, "\|c........", "")
		else
			cleanName = string.gsub(name, "\|c........", "")
		end
		cleanName = string.gsub(cleanName, "\|r", "")
		cleanName = string.gsub(cleanName, "[%c \127]", "")
		ChocolateBar:LoadOptions(cleanName)
		choco.bar:ResetDrag(choco, choco.name)
		frame:SetBackdropColor(0,0,0,1)
end

local function dropDisable(frame, choco)
		-- choco:Hide()
		ChocolateBar:DisableDataObject(choco.name, choco)
		frame:SetBackdropColor(0,0,0,1) 
end

local function createDropPoint(name, dropfunc, offx, text, texture)
	if not ChocolateBar.dropFrames then
		local dropFrames = CreateFrame("Frame", nil, _G.UIParent)
		dropFrames:SetWidth(400)
		dropFrames:SetHeight(100)
		ChocolateBar.dropFrames = dropFrames
	end
	local frame = CreateFrame("Frame", name, ChocolateBar.dropFrames)
	frame:SetWidth(100)
	frame:SetHeight(100)
	frame:SetFrameStrata("DIALOG")
	frame:SetPoint("TOPLEFT",offx,0)
	--ChocolateBar:Debug(UIParent:GetScale())
	--frame:SetPoint("CENTER",offx,250*UIParent:GetEffectiveScale() )
	
	frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
			tile = false, tileSize = 16, edgeSize = 16, 
			insets = { left = 4, right = 4, top = 4, bottom = 4 }});	
	frame:SetBackdropColor(0,0,0,1)
	
	local tex = frame:CreateTexture()
	tex:SetWidth(50)
	tex:SetHeight(50)
	tex:SetTexture(texture)
	tex:SetPoint("TOPLEFT",25,-35)

	frame.text = frame:CreateFontString(nil, nil, "GameFontHighlight")
	--frame.text:SetPoint("LEFT", frame, "LEFT", 0, 0)
	frame.text:SetPoint("CENTER",0, 30)
	frame.text:SetText(text)
	--frame:SetAlpha(0.5)
	
	frame:Hide()
	frame.Drop = dropfunc
	frame.GetFocus = function(frame, name) frame:SetBackdropColor(1,0,0,1) end
		
	frame.Drag = function(frame) end
	frame.LoseFocus = function(frame) frame:SetBackdropColor(0,0,0,1) end
	ChocolateBar.Drag:RegisterFrame(frame)
	return frame
end

function ChocolateBar:SetDropPoins(parent)
	local frame = ChocolateBar.dropFrames
	frame:ClearAllPoints()
	frame:SetClampedToScreen(true)
	local x,y = parent:GetCenter()
	local vhalf = (y > _G.UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"
	local yoff = (y > _G.UIParent:GetHeight() / 2) and -100 or 100
	local xoff = frame:GetWidth() / 2
	frame:SetPoint(vhalf.."LEFT",parent.bar,x-xoff,yoff)
	frame:Show()
end

--------
-- Ace3 callbacks
--------
function ChocolateBar:OnInitialize()
	local defaults = {
		profile = {
			combathidetip = false,
			combathidebar = false,
			combatdisbar = false,
			petBattleHideBars = true,
			combatopacity = 1,
			hideonleave = false,
			scale = 1,
			height = 21,
			iconSize = 0.75,
			moveFrames = true,
			adjustCenter = true,
			strata = "DIALOG",
			barRightClick = "OPTIONS",
			gap = 7,
			textOffset = 1,
			moreBar = "NewChocolate",
			moreBarDelay = 4,
			fontPath = " ",
			fontSize = 12,
			background = {
				textureName = "DarkBottom",
				texture = "Interface\\AddOns\\ChocolateBar\\pics\\DarkBottom",
				borderTexture = "Tooltip-Border",
				color = {r = 0.38, g = 0.36, b = 0.4, a = .94,},
				borderColor = {r = 0, g = 0, b = 0, a = 0,},
				tile = false,
				tileSize = 130,
				edgeSize = 8,
				barInset = 3,
			},
			textColor = nil,
			barSettings = {
				['*'] = {
					-- barName = "TopBar",
					align = "top",
					autohide = false,
					enabled = true,
					index = 10,
					width = 0,
					--fineX = 0,
					--fineY = 0,
				},
			},
			objSettings = {
				['*'] = {
					barName = nil,
					align = "left",
					enabled = true,
					showText = true,
					showIcon = true,
					index = 500,
					width = 0,
				},
			},
		},
		char = {
			debug = false,
		}
	}
	
	self.db = LibStub("AceDB-3.0"):New("ChocolateBarDB", defaults, "Default")
    self:RegisterChatCommand("chocolatebar", "ChatCommand")
	
	db = self.db.profile
	LSM:Register("statusbar", "Tooltip", "Interface\\Tooltips\\UI-Tooltip-Background")
	LSM:Register("statusbar", "Solid", "Interface\\Buttons\\WHITE8X8")
	LSM:Register("statusbar", "Gloss","Interface\\AddOns\\ChocolateBar\\pics\\Gloss")
	LSM:Register("statusbar", "DarkBottom","Interface\\AddOns\\ChocolateBar\\pics\\DarkBottom")
	LSM:Register("statusbar", "X-Perl","Interface\\AddOns\\ChocolateBar\\pics\\X-Perl")

	LSM:Register("background", "Titan","Interface\\AddOns\\ChocolateBar\\pics\\Titan")
	LSM:Register("background", "Tribal","Interface\\AddOns\\ChocolateBar\\pics\\Tribal")
	
	
	createDropPoint("ChocolateTextDrop", dropText, 0,L["Toggle Text"],"Interface/ICONS/INV_Inscription_Tradeskill01")
	--createDropPoint("ChocolateCenterDrop", dropOptions,150,L["Options"],"Interface/Icons/Spell_Holy_GreaterBlessingofSalvation") 
	createDropPoint("ChocolateCenterDrop", dropOptions,150,L["Options"],"Interface/Icons/INV_Gizmo_02") 
	createDropPoint("ChocolateDisableDrop", dropDisable, 300,L["Disable Plugin"], "Interface/ICONS/Spell_ChargeNEgative")
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED","OnEnterCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED","OnLeaveCombat")
	-- self:RegisterEvent("PLAYER_ENTERING_WORLD","OnEnterWorld")

	self:RegisterEvent("PET_BATTLE_OPENING_START","OnPetBattleOpen")
	self:RegisterEvent("PET_BATTLE_CLOSE","OnPetBattleOver")
	
	-- db = self.db.profile
	
	self:LoadBars()
	
	local optionPanel = CreateFrame( "Frame", "ChocolateBarPanel", _G.UIParent );
	optionPanel.name = "ChocolateBar";
	optionPanel:SetScript("OnShow", function()
		optionPanel:SetScript("OnShow", nil)  -- avoid recursion
		ChocolateBar:ToggleInterfaceOptions(true)
	end)
	--[[
	local button = CreateFrame("Button",nil,optionPanel, "UIPanelButtonTemplate")
	button:SetWidth(150)
	button:SetHeight(22)
	button:SetScript("OnClick", function()
		_G.HideUIPanel(_G.InterfaceOptionsFrame)
		_G.HideUIPanel(_G.GameMenuFrame)
		ChocolateBar:ChatCommand()
	end)
	button:SetText("Configure")
	button:SetPoint("TOPLEFT",20,-20)
	--]]
	_G.InterfaceOptions_AddCategory(optionPanel);
end

function ChocolateBar:OnEnable()
	self:LoadBars()

	for name, obj in broker:DataObjectIterator() do
		self:LibDataBroker_DataObjectCreated('OnEnable', name, obj, true) --force noupdate on chocolateBars
	end
	broker.RegisterCallback(self, "LibDataBroker_DataObjectCreated")

	self:UpdateBars() --update chocolateBars here
	self:UpdateChoclates("resizeFrame")

	--[[
	local moreChocolate = LibStub("LibDataBroker-1.1"):GetDataObjectByName("MoreChocolate")
	if moreChocolate then
		moreChocolate:SetBar(db)
	end
	--]]
end

function ChocolateBar:OnDisable()
	broker.UnregisterCallback(self, "LibDataBroker_DataObjectCreated")

	for name,choco in pairs(chocolateObjects) do
		self:UnregisterDataObject(name, choco, true)
	end
	
	self:UnloadBars()
	assert(not next(chocolateObjects))
end

--[[
--/run LibStub("AceAddon-3.0"):GetAddon("ChocolateBar"):UpdateChoclates("updateSettings")
function ChocolateBar:OnEnterWorld()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
--]]


function ChocolateBar:OnPetBattleOpen(...)
	Debug("OnPetBattleOpen", ...)
	self.InCombat = true
	if db.petBattleHideBars then
		for name,bar in pairs(chocolateBars) do
			bar.petHide = bar:IsShown()
			bar:Hide()
		end
	end
end

function ChocolateBar:OnPetBattleOver(...)
	Debug("OnPetBattleClose", ...)
	self.InCombat = false
	if db.petBattleHideBars then
		for name,bar in pairs(chocolateBars) do
			if bar.petHide then
				bar:Show()
				bar:UpdateJostle(db)
			end
		end
	end
	
end

function ChocolateBar:OnEnterCombat()
	self.InCombat = true
	local combatHideAllBars = db.combathidebar
	local combatOpacityAllBars = db.combatopacity
	for name,bar in pairs(chocolateBars) do
		local settings = bar.settings
		if combatHideAllBars or settings.hideBarInCombat then
			bar.tempHide = bar:IsShown()
			bar:Hide()
		elseif combatOpacityAllBars < 1 then
			bar.tempHide = bar:GetAlpha()
			bar:SetAlpha(db.combatopacity)
		end
	end
end

function ChocolateBar:OnLeaveCombat()
	self.InCombat = false
	local combatHideAllBars = db.combathidebar
	local combatOpacityAllBars = db.combatopacity
	for name,bar in pairs(chocolateBars) do
		local settings = bar.settings
		if combatHideAllBars or settings.hideBarInCombat then
			if bar.tempHide then
				bar:Show()
			end
		elseif combatOpacityAllBars < 1 then
			if bar.tempHide then
				bar:SetAlpha(1)
			end
		end
	end
end

--------
-- LDB callbacks
--------

function ChocolateBar:LibDataBroker_DataObjectCreated(event, name, obj, noupdate)
	local t = obj.type
	if t == "data source" or t == "launcher" then
		local enabled = db.objSettings[name].enabled
		if enabled then
			self:RegisterDataObject(name, obj, noupdate)
		elseif enabled == nil then
			self:EnableDataObject(name, obj, noupdate)
		else
			self:UnregisterDataObject(name, nil, noupdate)
		end
	else
		Debug("Unknown type", t, name)
	end
end


function ChocolateBar:LibDataBroker_DataObjectRemoved(event, name, obj, noupdate)
	self:UnregisterDataObject(name, nil, noupdate)
end


function ChocolateBar:EnableDataObject(name, obj, noupdate)
	obj = obj or broker:GetDataObjectByName(name)

	local t = obj.type
	if t ~= "data source" and t ~= "launcher" then
		Debug("Unknown type", t, name)
		return false
	end

	local settings = rawget(db.objSettings, name)

	-- First time?
	-- if  settings.enabled == nil  then
	if  not settings  then
		settings = db.objSettings[name]
		-- set default values depending on data source
		if t and t == "data source" then
			settings.align = "left"
			-- settings.showText = true
			if db.autodissource then
				settings.enabled = false
				return
			end
			if name == "ChocolateClock" or name == "Broker_uClock" then
				settings.align = "right"
				settings.index = -1
			end
		else
			settings.align = "right"
			-- settings.showText = false
			if db.autodislauncher then
				settings.enabled = false
				return
			end
		end
	end

	settings.enabled = true
	self:RegisterDataObject(name, obj, noupdate)
end

function ChocolateBar:RegisterDataObject(name, obj, noupdate)
	-- Save name to dataobj. The display shouldn't modify the model, but the name should be set by LibDataBroker, anyway.
	obj.name = name

	local barName = settings.barName
	local bar = chocolateBars[barName]    -- or chocolateBars[db.moreBar]
	if  not bar  and  not rawget(db.barSettings, barName)  then
		-- Put new and lost pieces on the NewChocolate bar. Create it if necessary.
		barName, bar = self:CreateBar(db.moreBar)
	end

	-- Disabled bar?
	if not bar then  return  end

	local choco = chocolateObjects[name]
	if choco then
		-- Reusing Chocolate from a different Bar.
		-- No need to refresh display attachment: it's the same frame on a different parent.
		-- _G.safecall(obj.DetachDisplay, obj, choco)
		bar:AddChocolatePiece(choco, name, noupdate)
		-- _G.safecall(obj.AttachDisplay, obj, choco)
	else
		choco = Chocolate:New(name, obj, settings, db)
		chocolateObjects[name] = choco
		bar:AddChocolatePiece(choco, name, noupdate)

		broker.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..name, "AttributeChanged")
		-- Call obj:AttachDisplay(choco) if set.
		_G.safecall(obj.AttachDisplay, obj, choco)
	end
end


function ChocolateBar:DisableDataObject(name, choco, noupdate)
	db.objSettings[name].enabled = false
	ChocolateBar:UnregisterDataObject(name, choco, noupdate)
end

function ChocolateBar:UnregisterDataObject(name, choco, noupdate)
	local choco = choco or chocolateObjects[name]
	if  not choco  then  return  end

	name = name or choco.name
	broker.UnregisterCallback(self,"LibDataBroker_AttributeChanged_"..name)

	local obj, bar = choco.obj, choco.bar
	-- Call obj:DetachDisplay(choco) if set.
	_G.safecall(obj.DetachDisplay, obj, choco)

	if bar then  bar:EatChocolatePiece(choco, noupdate)  end
	chocolateObjects[name] = nil
end



function ChocolateBar:AttributeChanged(event, name, key, value)
	--Debug("ChocolateBar:AttributeChanged ",name," key: ", key, value)
	local settings = db.objSettings[name]
	if not settings.enabled then 
		return 
	end
	local choco = chocolateObjects[name]
	choco:Update(choco, key, value, name)
end

-- disable autohide for all bars during drag and drop
function ChocolateBar:TempDisAutohide(value)
	for name,bar in pairs(chocolateBars) do
		if value then
			bar.tempHide = bar.autohide
			bar.autohide = false
			bar:ShowAll()
		else
			if bar.tempHide then
				bar.autohide = true
				bar:HideAll()
			end
		end
	end
end


function ChocolateBar:ToggleEditMode(editMode)
	if  editMode == nil  then  editMode = not db.editMode
	elseif  db.editMode == editMode  then  return  end

	db.editMode = editMode
	for barName,settings in pairs(db.barSettings) do
		if settings.enabled then
		elseif editMode then
			self:CreateBar(barName, settings)
		else
			self:DestroyBar(chocolateBars[barName])
		end
	end
	--[[
	local newPiecesBar = chocolateBars[db.moreBar]
	if  newPiecesBar  then
		newPiecesBar:SetShown(editMode)
		if  editMode  then
			UIFrameFadeIn(newPiecesBar, 4, self:GetAlpha(), 1)
		end
	end
	--]]
end


-- returns nil if the plugin is disabled 
function ChocolateBar:GetChocolate(name)
	return chocolateObjects[name]
end

function ChocolateBar:GetNewPiecesBar()
	return chocolateBars[db.moreBar]
end

function ChocolateBar:GetBar(name)
	return chocolateBars[name]
end

function ChocolateBar:GetBars()
	return chocolateBars
end

function ChocolateBar:SetBars(tab)
	chocolateBars = tab or {}
end

local function getFreeBarName()
	--local i = 1
	local used = false
	local name
	for i=1,100 do
		name = "ChocolateBar"..i
		--[[
		for k,v in pairs(chocolateBars) do
			if name == v:GetName() then
				used = true
			end
		end
		--]]
		if not chocolateBars[name] then
			return name
		end
		used = false
	end
	Debug("no free bar name found ")
end

function ChocolateBar:UpdateChoclates(key, val)
	for name,choco in pairs(chocolateObjects) do
		choco:Update(choco, key, val)
	end
end

--------
-- Bars Management
--------

local function IsBarEnabled(barName)
	local s = rawget(db.barSettings, barName)
	return  s and s.enabled  or  db.editMode
end

function ChocolateBar:LoadBars()
	-- if  next(chocolateBars)  then  return  end

	for barName, bar in pairs(chocolateBars) do
		if  not IsBarEnabled(barName)  then  self:DestroyBar(bar, true)  end
	end
	for barName, settings in pairs(db.barSettings) do
		if  IsBarEnabled(barName)  then  self:CreateBar(barName, settings, true)  end
	end
	-- No anchor update until done with all bars.
	self:AnchorBars()
end

function ChocolateBar:UnloadBars()
	for barName,bar in pairs(chocolateBars) do
		self:DestroyBar(bar, true)
	end
	assert(not next(chocolateBars))
end


function ChocolateBar:CreateBar(barName, settings, noupdate)
	local bar = chocolateBars[barName]
	settings = settings or db.barSettings[barName]
	if  bar  and  bar.settings == settings  then
		return barName, bar
	end

	if  not barName  then
		-- Find free barName.
		barName = getFreeBarName()
		settings.barName = barName
	end

	if  not bar  then
		bar = Bar:New(barName, db)
		chocolateBars[barName] = bar
	end

	-- if  bar.settings ~= settings  then
	bar:Init(settings, db)

	if  not noupdate  then  self:AnchorBars()  end
	return barName, bar
end

function ChocolateBar:DestroyBar(bar, noupdate)
	if not bar then  return  end
	bar:EatAll()
	chocolateBars[bar.barName] = nil
	if  not noupdate  then  self:AnchorBars()  end
end



function ChocolateBar:UpdateBars(updateindex)
	for k,v in pairs(chocolateBars) do
		v:UpdateBar(updateindex)
		v:UpdateAutoHide(db) 
	end
end

-- sort and anchor all bars
function ChocolateBar:AnchorBars()
	local temptop = {}
	local tempbottom = {}
	
	for k,v in pairs(chocolateBars) do
		local settings = v.settings
		local index = settings.index or 500
		if settings.align == "top" then
			table.insert(temptop,{v,index})
		elseif settings.align == "bottom" then
			table.insert(tempbottom,{v,index})
		else
			v:ClearAllPoints()
			if settings.barPoint and settings.barOffx and settings.barOffy then
				--Debug("ChocolateBar:AnchorBars() v:SetPoint",v:GetName(),settings.barPoint,settings.barOffx,settings.barOffy)
				v:SetPoint(settings.barPoint, "UIParent",settings.barOffx ,settings.barOffy)
				v:SetWidth(settings.width)
			else
				--Debug("ChocolateBar:AnchorBars() table.insert",v:GetName())
				settings.align = "top"
				table.insert(temptop,{v,index})
			end
		end
	end
	table.sort(temptop, function(a,b)return a[2] < b[2] end)
	table.sort(tempbottom, function(a,b)return a[2] < b[2] end)

	local yoff = 0
	local relative = nil
	for i, v in ipairs(temptop) do
		local bar = v[1]
		bar:ClearAllPoints()
		if(relative)then
			bar:SetPoint("TOPLEFT",relative,"BOTTOMLEFT", 0,-yoff)
			bar:SetPoint("RIGHT", relative ,"RIGHT",0, 0);
		else
			bar:SetPoint("TOPLEFT",-1,1);
			bar:SetPoint("RIGHT", "UIParent" ,"RIGHT",0, 0);
		end
		--if updateindex then
			bar.settings.index = i
		--end
		relative = bar
	end
	
	local relative = nil
	for i, v in ipairs(tempbottom) do
		local bar = v[1]
		bar:ClearAllPoints()
		if(relative)then
			bar:SetPoint("BOTTOMLEFT",relative,"TOPLEFT", 0,-yoff)
			bar:SetPoint("RIGHT", relative ,"RIGHT",0, 0);
		else
			bar:SetPoint("BOTTOMLEFT",-1,0);
			bar:SetPoint("RIGHT", "UIParent" ,"RIGHT",0, 0);
		end
		--if updateindex then
			bar.settings.index = i
		--end
		relative = bar
	end
end

--------
-- option functions
--------
function ChocolateBar:ChatCommand(input)
	local pluginName = nil
	if  ChocolateBar:LoadOptions()  then
		ChocolateBar:OpenOptions(chocolateBars, db, input, pluginName)
	end
end

function ChocolateBar:ToggleInterfaceOptions(show)
	if show == nil then  show = not InterfaceOptionsFrame:IsShown()  end

	self:ToggleEditMode(not show)
	if  not show  then
		HideUIPanel(InterfaceOptionsFrame)
	else
		ChocolateBar:LoadOptions()
		InterfaceOptionsFrame_OpenToCategory("ChocolateBar")
		InterfaceOptionsFrame_OpenToCategory("ChocolateBar")
	end
	return show
end

function ChocolateBar:LoadOptions(pluginName, input)
	local OPTIONS_NAME = "ChocolateBar_Options"
	if  _G.IsAddOnLoaded(OPTIONS_NAME)  then  return true, "Already loaded."  end
	
	local _, _, _, wasEnabled = GetAddOnInfo(OPTIONS_NAME)
	_G.EnableAddOn(OPTIONS_NAME)
	local loaded, reason = _G.LoadAddOn(OPTIONS_NAME)
	if  not wasEnabled  then  _G.DisableAddOn(OPTIONS_NAME)  end

	-- ChocolateBar:OpenOptions(chocolateBars, db, input, pluginName)
	if not loaded then
		print( L["Could not load "..OPTIONS_NAME..", make sure it's installed."], "  Error:", reason )
	end
	return loaded
end

function ChocolateBar:UpdateDB(data)
	db = data
end