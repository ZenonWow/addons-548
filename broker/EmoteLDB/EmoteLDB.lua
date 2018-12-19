-- EmoteLDB by Cilraaz/Allisu of Rexxar-US

-- Basic addon info
local addonName, addon = ...

EmoteLDB = LibStub("AceAddon-3.0"):NewAddon("EmoteLDB")

-- Initialize localization
local L = nil
local AL = LibStub:GetLibrary("AceLocale-3.0", true)
if AL then
	if type(addon.LoadTranslations) == "function" then
		addon:LoadTranslations(AL)
		addon.LoadTranslations = nil
	end
	L = AL:GetLocale(addonName)
	AL = nil
else
	L = setmetatable({}, {__index = function(t,k) t[k] = k return k end })
end
addon.L = L

-- Set up environment variables
local _G = getfenv(0)

local string = _G.string
local pairs = _G.pairs
local gsub = string.gsub

local emoteVer = "50400-1.0"

-- Debug setting
addon.debug = false

-- Declare Libs
--local addon = EmoteLDB
local self = EmoteLDB
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local QTC = LibStub('LibQTip-1.0')
local icon = LibStub("LibDBIcon-1.0")

-- Frame
local QTC = LibStub('LibQTip-1.0')
local tooltip
local options
local frame = CreateFrame("Frame")
local EmoteLDBObj

local menuLevel = 1
local info = nil
local key = nil
local infoArray = {}
local keyArray = {}

-- DB Defaults
local defaults = {
	profile = {
		showSlashCommand = true,
		hideDetails = true
	},
	global = {
		LibDBIcon = { hide = false }
	}
}

-- Local Functions
function EmoteLDB:GetOnDemandText(v,hasTarget)
	local color
	local flag = nil
	local returnCode
	local emoteText

	if (hasTarget) then emoteText = v.target else emoteText = v.none end
	
	if (EL_Types[v["types"][1]] and EL_Types[v["types"][1]]=="Custom") then
		emoteText = UnitName("player").." "..emoteText
	end

	if (EL_React[v.react] == "") then -- None
		color = "fffefefe"
	elseif (EL_React[v.react] == "A") then -- Animated, Purple
		color = "ffa335ee"
		flag = L["A"]
	elseif (EL_React[v.react] == "V") then -- Voice, Orange
		color = "ffff8000"
		flag = L["V"]
	elseif (EL_React[v.react] == "AV") then -- Both, Green
		color = "ff1eff00"
		flag = L["AV"]
	else -- Shouldn't happen, Grey
		color = "ff9d9d9d"
	end

	returnCode = "|c" .. color .. emoteText .. FONT_COLOR_CODE_CLOSE
	if (flag) then returnCode = returnCode.." ["..flag.."]" end
	return returnCode
end

function HandleModClick(_, k)
	if (k) then
		if (EL_Types[EL_Emotes[k]["types"][1]] and EL_Types[EL_Emotes[k]["types"][1]]=="Custom") then -- Custom emote
			local emoteText
			local hasTarget = UnitName("target")
			local genderCode = UnitSex("player")
			local genderHe = nil
			local genderHis = nil
			local genderhe = nil
			local genderhis = nil
			if (genderCode == 2) then -- male
				genderHe = L["He"]
				genderHis = L["His"]
				genderhe = L["he"]
				genderhis = L["his"]
			else -- female (we hope)
				genderHe = L["She"]
				genderHis = L["Her"]
				genderhe = L["she"]
				genderhis = L["her"]
			end

			if (hasTarget) then
				emoteText = EL_Emotes[k].target
				emoteText = gsub(emoteText,"<Target>",hasTarget)
			else
				emoteText = EL_Emotes[k].none
			end
			
			emoteText = gsub(emoteText,"<He>",genderHe)
			emoteText = gsub(emoteText,"<His>",genderHis)
			emoteText = gsub(emoteText,"<he>",genderhe)
			emoteText = gsub(emoteText,"<his>",genderhis)

			EmoteLDBObj.text = "/"..k
			SendChatMessage(emoteText,"EMOTE")
			HideTooltip()
		else
			emoteToken = string.upper(k)
			if (emoteToken == "LAVISH") then
				emoteToken = "PRAISE";
			end
			if (emoteToken == "EXCITED") then
				emoteToken = "TALKEX";
			end
			if (emoteToken == "DOOM") then
				emoteToken = "THREATEN";
			end
			if (emoteToken == "SILLY") then
				emoteToken = "JOKE";
			end
			if (emoteToken == "LAY") then
				emoteToken = "LAYDOWN";
			end
			if (emoteToken == "REAR") then
				emoteToken = "SHAKE";
			end
			if (emoteToken == "BELCH") then
				emoteToken = "BURP";
			end
			if (emoteToken == "SMELL") then
				emoteToken = "STINK";
			end
			if (emoteToken == "GOODBYE") then
				emoteToken = "BYE";
			end
			if (emoteToken == "FOLLOWME") then
				emoteToken = "FOLLOW";
			end
			if (emoteToken == "ATTACKTARGET") then
				emoteToken = "ATTACKMYTARGET";
			end
			if (emoteToken == "CONGRATS") then
				emoteToken = "CONGRATULATE";
			end
			if (emoteToken == "PUZZLED") then
				emoteToken = "PUZZLE";
			end
			if (emoteToken == "QUESTION") then
				emoteToken = "TALKQ";
			end
			EmoteLDBObj.text = "/"..k
			DoEmote(emoteToken);
			HideTooltip()
		end
	end
end

-- Handler Function
function HandlerFunc(_, name, button, ...)
	debugPrint("name = " .. name)
	if name == "showSlash" then
		self.db.profile.showSlashCommand = not self.db.profile.showSlashCommand
	elseif name == "miniToggle" then
		debugPrint(format("before hide = %s", self.db.global.LibDBIcon.hide and "true" or "false"))
		self.db.global.LibDBIcon.hide = not self.db.global.LibDBIcon.hide
		debugPrint(format("after hide = %s", self.db.global.LibDBIcon.hide and "true" or "false"))
		if self.db.global.LibDBIcon.hide then
			icon:Hide("EmoteLDB")
		else
			icon:Show("EmoteLDB")
		end
	else
		local hasTarget = UnitName("target")
		local genderCode = UnitSex("player")
		local genderHe = nil
		local genderHis = nil
		local genderhe = nil
		local genderhis = nil
		if (genderCode == 2) then -- male
			genderHe = "He"
			genderHis = "His"
			genderhe = "he"
			genderhis = "his"
		else -- female (we hope)
			genderHe = "She"
			genderHis = "Her"
			genderhe = "she"
			genderhis = "her"
		end
		
		local i = 1

		for k, v in pairs(EL_Emotes) do
			for k2, v2 in pairs(v.types) do
				if (name == v2) then
					info = nil
					if (hasTarget) then
						info = EmoteLDB:GetOnDemandText(v,true)
						info = gsub(info,"<Target>",hasTarget)
					else
						info = EmoteLDB:GetOnDemandText(v,false)
					end

					info = gsub(info,"<He>",genderHe)
					info = gsub(info,"<His>",genderHis)
					info = gsub(info,"<he>",genderhe)
					info = gsub(info,"<his>",genderhis)

					for k3, v3 in pairs(v.custom) do
						if (v3 == 1) then
							slshCmd = L["Custom:  "]
						else
							slshCmd = "/"..k..":  "
						end
					end
			
					if (self.db.profile.showSlashCommand) then
						infoArray[i] = slshCmd..info
						keyArray[i] = k
					else
						infoArray[i] = info
						keyArray[i] = k
					end
					i = i + 1
				end
			end
		end
		menuLevel = 2
	end
	EmoteLDB:ShowTooltip(keyArray,infoArray,menuLevel)
end

-- Startup
EmoteLDBObj = ldb:NewDataObject("EmoteLDB", {
		type = "data source",
		icon = "Interface\\Icons\\Spell_Shadow_Charm",
		label = "EmoteLDB",
		text = L["Last Emote Used"],
	})
	
function EmoteLDB:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("EmoteLDBDB", defaults)
	icon:Register("EmoteLDB", EmoteLDBObj, self.db.global.LibDBIcon) -- Minimap
	if self.db.global.LibDBIcon.hide then
		icon:Hide("EmoteLDB")
	end
end

-- Tooltip
function HideTooltip()
	if not tooltip then return end
	if MouseIsOver(tooltip) then return end
	tooltip:SetScript("OnLeave", nil)
	QTC:Release(tooltip)
	tooltip = nil
	self.tooltip = nil
	info = nil
	infoArray = {}
	key = nil
	keyArray = {}
	menuLevel = 1
end

function EmoteLDBObj.OnEnter(self)
	tooltip = QTC:Acquire("EmoteLDBTooltip", 2, "LEFT", "LEFT", "LEFT")
	tooltip:SmartAnchorTo(self)
	tooltip:SetAutoHideDelay(0.1, self)
	EmoteLDB:ShowTooltip(key,info,menuLevel)
end

function EmoteLDBObj.OnLeave(self)
	HideTooltip()
end

function EmoteLDBObj.OnClick(self, button)
	emoteToUse = gsub(EmoteLDBObj.text, "/", "")
	if button == "LeftButton" then
		if EmoteLDBObj.text == L["Last Emote Used"] then return end
		HandleModClick(_, emoteToUse)
	else
		debugPrint(button.." clicked")
	end
end

function EmoteLDB:ShowTooltip(key, info, menuLevel)
	tooltip:Clear()
	tooltip:SetScale(1)
	
	local headerFont = CreateFont("EmoteLDBHeaderFont")
	EmoteLDBHeaderFont:CopyFontObject(GameTooltipHeaderText)
	EmoteLDBHeaderFont:SetFont(EmoteLDBHeaderFont:GetFont(), 15)

	-- Display Header in tooltip
	local y = tooltip:AddLine()
	tooltip:SetCell(y, 1, "EmoteLDB", EmoteLDBHeaderFont, "CENTER", 2)
	tooltip:AddLine(" ")

	if (menuLevel < 2) then
		-- Display initial menu
		for k, v in pairs(EL_Types) do
			local elType = k
			local label = v
		
			local y = tooltip:AddLine()
			tooltip:SetCell(y, 1, v, "CENTER", 2)
			tooltip:SetCellScript(y, 1, "OnMouseDown", HandlerFunc, k)
		end
		
		-- Count total emotes if debugging
		if (addon.debug) then
			local emoteCount = 0
			for k, v in pairs(EL_Emotes) do
				if ( v.custom[0] == "0" ) then
					emoteCount = emoteCount + 1
				end
			end
		end
		
		-- Display toggle option for slash commands
		tooltip:AddLine(" ")
		local y = tooltip:AddLine()
		tooltip:SetCell(y, 1, L["Toggle the display of slash commands."], "CENTER", 2)
		tooltip:SetCellScript(y, 1, "OnMouseDown", HandlerFunc, "showSlash")
		local y = tooltip:AddLine()
		tooltip:SetCell(y, 1, L["Currently: "], "RIGHT")
		tooltip:SetCell(y, 2, format("%s", self.db.profile.showSlashCommand and "|c0000FF00Shown" or "|c00FF0000Hidden"), "LEFT")
		tooltip:AddLine(" ")
		local y = tooltip:AddLine()
		tooltip:SetCell(y, 1, L["Toggle the display of the minimap button"], "CENTER", 2)
		tooltip:SetCellScript(y, 1, "OnMouseDown", HandlerFunc, "miniToggle")
		local y = tooltip:AddLine()
		tooltip:SetCell(y, 1, L["Currently: "], "RIGHT")
		tooltip:SetCell(y, 2, format("%s", self.db.global.LibDBIcon.hide and "|c00FF0000Hidden" or "|c0000FF00Shown"), "LEFT")
		tooltip:AddLine(" ")
		local y = tooltip:AddLine()
		tooltip:SetCell(y, 1, L["EmoteLDB version: "], "RIGHT")
		tooltip:SetCell(y, 2, format("%s", "|c00FF00FF" .. emoteVer), "LEFT")
		if (addon.debug) then
			tooltip:AddLine(" ")
			local y = tooltip:AddLine()
			tooltip:SetCell(y, 1, "Total Emotes: ", "RIGHT")
			tooltip:SetCell(y, 2, format("%d", emoteCount), "LEFT")
		end
		
	elseif (menuLevel == 2) and (info) and (key) then
		local infoCount = #info
		for i=1,infoCount do
			local y = tooltip:AddLine()
			tooltip:SetCell(y, 1, info[i], "CENTER")
			tooltip:SetCellScript(y, 1, "OnMouseDown", HandleModClick, key[i])
		end
		if (infoCount < 21) then
			-- Add filler lines
			local fillerLines = 21 - infoCount
			for i=1,fillerLines do
				tooltip:AddLine(" ")
			end
		end
	else
		HideTooltip()
		return
	end

	tooltip:Show()
end

function debugPrint(text)
	if (addon.debug) then
		DEFAULT_CHAT_FRAME:AddMessage(text)
	end
end