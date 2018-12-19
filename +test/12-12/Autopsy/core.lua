-- Most of the comments to the code (and the "well written" part of it :-) are by Phanx, whom I thanks for the helps and patience in explaining. 

local ADDON = ...
local UPDATEPERIOD, elapsed = 0.5, 0

-- set some default values
AUTOPSY_ENABLE = AUTOPSY_ENABLE or 1
AUTOPSY_OUTCHN = AUTOPSY_OUTCHN or 1
AUTOPSY_OUTNAM = AUTOPSY_OUTNAM or { "SELF", "GROUP", "GUILD", "OFFICER"}

local prgname = "|cffffd200autopsy|r"
local string_format = string.format
local timeStamp, event, sourceGUID, sourceName, destGUID, destName, prefixParam1, prefixParam2, suffixParam1, suffixParam2
local autopsy_msg, autopsy_msg_solo, autopsy_chn -- output vars

local function color(destName)
	if not UnitExists(destName) then return string_format("\124cffff0000%s\124r", destName) end
	local _, class = UnitClass(destName)
	local color = _G["RAID_CLASS_COLORS"][class]
	return string_format("\124cff%02x%02x%02x%s\124r", color.r*255, color.g*255, color.b*255, destName)
end

local function linkname(destName)

	return string_format("\124Hplayer:%s:1:WHISPER:%s\124h[%s]\124h", destName, destName, color(destName) )

end

local function Autopsy_OUTPUT(event, sourceName, destName, prefixParam1, prefixParam2, suffixParam1, suffixParam2)

	if (event == "SWING_DAMAGE") then		
		autopsy_msg = string_format("autopsy: %s killed %s with %s Melee overkill %s", sourceName, destName, prefixParam1, prefixParam2)	
		autopsy_msg_solo = string_format("\124cffffd200autopsy\124r: %s killed %s with %s Melee overkill %s", linkname(sourceName), linkname(destName), prefixParam1, prefixParam2)
	else 
		autopsy_msg = string_format("autopsy: %s killed %s with %s damage of %s overkill %s", sourceName, destName, suffixParam1, GetSpellLink(prefixParam1), suffixParam2)
		autopsy_msg_solo = string_format("\124cffffd200autopsy\124r: %s killed %s with %s damage of %s overkill %s", linkname(sourceName), linkname(destName), suffixParam1, GetSpellLink(prefixParam1), suffixParam2)
	end

	autopsy_chn = AUTOPSY_OUTNAM[AUTOPSY_OUTCHN]
	
	-- find the right GROUP, thanks to Dridzt code in the posts: http://www.wowinterface.com/forums/showthread.php?t=48320
	if AUTOPSY_OUTCHN == 2 then
		
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		  autopsy_chn = "INSTANCE_CHAT"
		elseif IsInRaid() then
		  autopsy_chn = "RAID"
		elseif IsInGroup() then
		  autopsy_chn = "PARTY"
		else
		  autopsy_chn = "SELF"
		end
	end
	
	if 	AUTOPSY_OUTCHN == "1" or autopsy_chn == "SELF" then 
		print(autopsy_msg_solo)	
	else 
		SendChatMessage(autopsy_msg, autopsy_chn)
	end 	
	
end

-- Frame to register the global vars at the ADDON_LOADED event.	
local frame_al = CreateFrame("FRAME", ADDON.."_al")
frame_al:RegisterEvent("ADDON_LOADED")	
frame_al:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "Autopsy" then	
		
		if AUTOPSY_ENABLE == 1 then 
			print(string_format("%s: enabled on [|cffff0000%s|r] channel", prgname, AUTOPSY_OUTNAM[AUTOPSY_OUTCHN]))
		else 
			print(string_format("%s: disabled. Type /%s enable to start", prgname, prgname))
		end
		
		self:UnregisterEvent("ADDON_LOADED")		
	end	
end)

-- Frame to parse CLEU	
local frame_cleu = CreateFrame("FRAME", ADDON.."_cleu")
frame_cleu:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame_cleu:RegisterEvent("PLAYER_ENTERING_WORLD")
frame_cleu:SetScript("OnEvent", function(self, event, ...)
	
	if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then	
		
		if AUTOPSY_ENABLE == 0 then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		return
	end

	timeStamp, event, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, prefixParam1, prefixParam2, _, suffixParam1, suffixParam2 = ...	
	
    -- proceed with CLEU handling
	if not playerGUID then playerGUID = UnitGUID("player") end
	
	if destGUID == playerGUID or (destName and UnitClass(destName)) then

		-- prevent the case the sourceName is nil (sometimes it is happened)
		sourceName = sourceName or "Someone"
		
		if event == "SWING_DAMAGE" then
			if prefixParam2 > 0 then Autopsy_OUTPUT(event, sourceName, destName, prefixParam1, prefixParam2, suffixParam1, suffixParam2) end
		elseif event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
			if suffixParam2 > 0 then Autopsy_OUTPUT(event, sourceName, destName, prefixParam1, prefixParam2, suffixParam1, suffixParam2) end
		end
	end
end)

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("Autopsy", {
	type = "data source",
	OnClick = function(self, button)
            if (button == "LeftButton") then
				if (AUTOPSY_OUTCHN == 4) then 					
					AUTOPSY_OUTCHN = 1
				else
					AUTOPSY_OUTCHN = AUTOPSY_OUTCHN +1
				end	
            elseif ( button == "RightButton" ) then				
				if (AUTOPSY_ENABLE == 0) then  
					AUTOPSY_ENABLE = 1
					print(string_format("%s: |cff228B22enabled|r on [|cffff0000%s|r] channel ", prgname, AUTOPSY_OUTNAM[AUTOPSY_OUTCHN])) 
					frame_cleu:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				else 
					AUTOPSY_ENABLE = 0
					print(string_format("%s: monitor is disabled",prgname))
					frame_cleu:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				end					
            end
	end,
})


function dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	dataobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

function dataobj:OnTooltipShow()
	GameTooltip:AddLine(prgname)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("L-Click: toogle channel")
	GameTooltip:AddLine("R-Click: enable/disable")
end

function dataobj:OnLeave()
	GameTooltip:Hide()
end

local frame_autopsy = CreateFrame("Frame", ADDON.."_LDB")
frame_autopsy:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATEPERIOD then return end
	elapsed = 0
	if (AUTOPSY_ENABLE == 1) then 
			dataobj.icon = "Interface\\Icons\\INV_Misc_Organ_07"
	else
			dataobj.icon = "Interface\\Icons\\INV_Misc_Organ_08"
	end
	dataobj.text = AUTOPSY_OUTNAM[AUTOPSY_OUTCHN]
end
)


-- Configuration Panel -------------------------------------------------------------------------------------

local options = CreateFrame("Frame", ADDON.."Options", InterfaceOptionsFramePanelContainer)
options.name = GetAddOnMetadata(ADDON, "Title") or ADDON
InterfaceOptions_AddCategory(options)

local title = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(options.name)
options.title = title

local subtext = options:CreateFontString("$parentSubText", "ARTWORK", "GameFontHighlightSmall")
subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtext:SetPoint("RIGHT", -32, 0)
subtext:SetHeight(32)
subtext:SetJustifyH("LEFT")
subtext:SetJustifyV("TOP")
subtext:SetText(GetAddOnMetadata(ADDON, "Notes"))
options.subtext = subtext

local enable = CreateFrame("CheckButton", "$parentEnable", options, "InterfaceOptionsCheckButtonTemplate")
enable:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", -2, -8)
enable.Text:SetText(ENABLE)
enable.tooltipText = "Enable monitoring"
enable:SetChecked(AUTOPSY_ENABLE);
enable:SetScript("OnClick", function(self)
	
	if enable:GetChecked() then 
		AUTOPSY_ENABLE = 1
		print(string_format("%s: |cff228B22enabled|r on [|cffff0000%s|r] channel ", prgname, AUTOPSY_OUTNAM[AUTOPSY_OUTCHN])) 
		frame_cleu:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else 
		AUTOPSY_ENABLE = 0
		print(string_format("%s: monitor is disabled",prgname))
		frame_cleu:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end	
	
end)

local outchan = CreateFrame("Slider", "$parentOutChan", options, "OptionsSliderTemplate")
outchan:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 6, -30)
outchan:SetWidth(250)
outchan:SetMinMaxValues(1, 4)
-- why the global AUTOPSY_OUTCHN is always 1 !! :-)
-- and why the slider isn't set correctly 
-- if I don't use the below instruction ?
outchan:SetValue(1)
outchan.low = _G[outchan:GetName().."Low"]
outchan.low:SetPoint("TOPLEFT", outchan, "BOTTOMLEFT", 0, 0)
outchan.low:SetText('SELF')
outchan.high = _G[outchan:GetName().."High"]
outchan.high:SetPoint("TOPRIGHT", outchan, "BOTTOMRIGHT", 0, 0)
outchan.high:SetText('OFFICER')
outchan.text = _G[outchan:GetName().."Text"]
outchan.text:SetText("Output chat")
outchan.tooltipText = "Output chat"
outchan.value = outchan:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
outchan.value:SetPoint("TOP", outchan, "BOTTOM", 0, 0)
outchan.value:SetText(AUTOPSY_OUTNAM[AUTOPSY_OUTCHN])
outchan:SetScript("OnValueChanged", function(self, value)
	AUTOPSY_OUTCHN = floor(value + 0.5)
	self:SetValue(AUTOPSY_OUTCHN)
	self.value:SetText(AUTOPSY_OUTNAM[AUTOPSY_OUTCHN])
end)


local sampletext = options:CreateFontString("$parentSampleText", "ARTWORK", "GameFontHighlightSmall")
sampletext:SetPoint("TOPLEFT", outchan, "BOTTOMLEFT", 0, -50)
sampletext:SetText('Examples of reports:')

local testspell = CreateFrame("button", "$parentTestSpell", options, "UIPanelButtonTemplate")
testspell:SetHeight(25)
testspell:SetWidth(120)
testspell:SetPoint("TOPLEFT", outchan, "BOTTOMLEFT", 0, -70)
testspell:SetText("Spell")
testspell:SetScript("OnClick", 
	function()
		event = "SPELL_DAMAGE"
		sourceName = "Brown Marmot"
		destName = UnitName("player") 
		suffixParam1 = math.random(50000,100000)
		suffixParam2 = math.random(50000)
		prefixParam1 = "30455"  -- ice lance
		Autopsy_OUTPUT(event, sourceName, destName, prefixParam1, nil, suffixParam1, suffixParam2)
	end) 


local testmelee = CreateFrame("button", "$parentTestMelee", options, "UIPanelButtonTemplate")
testmelee:SetHeight(25)
testmelee:SetWidth(120)
testmelee:SetPoint("TOPLEFT", outchan, "BOTTOMLEFT", 130, -70)
testmelee:SetText("Melee")
testmelee:SetScript("OnClick", 
	function()
		event = "SWING_DAMAGE"
		sourceName = "Brown Marmot"
		destName = UnitName("player") 
		prefixParam1 = math.random(50000,100000)
		prefixParam2 = math.random(50000)
		Autopsy_OUTPUT(event, sourceName, destName, prefixParam1, prefixParam2, nil, nil)
	end) 
		

function options.refresh()
	enable:SetChecked(AUTOPSY_ENABLE)
	outchan:SetValue(AUTOPSY_OUTCHN)
	outchan.value:SetText(AUTOPSY_OUTNAM[AUTOPSY_OUTCHN])
end

if LibStub and LibStub("LibAboutPanel", true) then
	options.about = LibStub("LibAboutPanel").new(options.name, ADDON)
end


-- CMD Parse --------------------------------------------------------------------------------------------

SLASH_AUTOPSY1 = "/autopsy";
SlashCmdList["AUTOPSY"] = function() 
	InterfaceOptionsFrame_OpenToCategory(options)
end