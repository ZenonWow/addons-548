local addonName, private = ...
local Flags,Functions,Cooldowns,Active = {},{},{},{}
private.flags, private.functions, private.cooldowns, private.active = Flags,Functions,Cooldowns,Active
local bgTex, topTex, bottomTex

local f = CreateFrame("Frame")
f.OnEvent = function(self,event,...)
	return self[event] and self[event](...)
end
f:SetScript("OnEvent",f.OnEvent)
f:RegisterEvent("ADDON_LOADED")

f.ADDON_LOADED = function(...)
	if (...) == addonName then
		if not (LoseControlFixDB) then
			local alert = GetCVarBool("lossOfControl")
			local actionbars = alert
			LoseControlFixDB = {["alert"] = alert,["actionbars"] = actionbars}
		end
		Functions.ApplyOptions()
		bgTex = LossOfControlFrame.blackBg:GetTexture()
		topTex = LossOfControlFrame.RedLineTop:GetTexture()
		bottomTex = LossOfControlFrame.RedLineBottom:GetTexture()
		InterfaceOptionsCombatPanel:HookScript("OnShow",Functions.AddToBlizzOptions)
	end
end
f.PLAYER_REGEN_ENABLED = function(...)
	f:UnregisterEvent("PLAYER_REGEN_ENABLED")
	Functions[Flags.defer]()
	Flags.defer = nil
end

local OutputSelect = function(info)
	if not (info and info.arg1) then LoseControlFixDB.out = nil end
	LoseControlFixDB.out = info.arg1
	local whereText = Functions.OutputLabel()
	f.outButton:SetText("Announce: "..whereText)
end
local LCF_Output_DD = CreateFrame("Frame", "LCF_Output_Dropdown")
local outTable = {
	{
		text = _G.NONE,
		notCheckable = 1,
		arg1 = nil,
		func = OutputSelect
	},
	{
		text = "Auto",
		notCheckable = 1,
		arg1 = "AUTO",
		func = OutputSelect
	},
	{
		text = "Instance Chat",
		notCheckable = 1,
		arg1 = "INSTANCE_CHAT",
		func = OutputSelect
	},
	{
		text = "Raid",
		notCheckable = 1,
		arg1 = "RAID",
		func = OutputSelect
	},
	{
		text = "Party",
		notCheckable = 1,
		arg1 = "PARTY",
		func = OutputSelect
	},
	{
		text = "Say",
		notCheckable = 1,
		arg1 = "SAY",
		func = OutputSelect
	},
	{
		text = "Self",
		notCheckable = 1,
		arg1 = "SELF",
		func = OutputSelect
	}
}
local DISPLAY_TYPE_NONE,DISPLAY_TYPE_ALERT,DISPLAY_TYPE_FULL,ACTIVE_INDEX = 0,1,2,1
local TEXT_OVERRIDE = {
	[33786] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
	[113506] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
}
local MSG_FORMAT = "<%s from %s for %.1f sec"
Functions.Out = function(...)
	if not LoseControlFixDB.out then return end
	local messg
	local frame, animate, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = ...
	if not (locType) then
		locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(ACTIVE_INDEX)
	end
	if (text and displayType ~= DISPLAY_TYPE_NONE) then
		text = TEXT_OVERRIDE[spellID] or text
		if ( locType == "SCHOOL_INTERRUPT" ) then
			if(lockoutSchool and lockoutSchool ~= 0) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, GetSchoolString(lockoutSchool))
			end
		end
		messg = string.format(MSG_FORMAT, text, (spellID and GetSpellLink(spellID) or ""), (timeRemaining or 0))
	end
	if not (messg) then return end
		
	if LoseControlFixDB.out == "SELF" then
		DEFAULT_CHAT_FRAME:AddMessage(messg)
		return
	end
	local channel
	if LoseControlFixDB.out == "AUTO" then
		if IsInRaid() then
			if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant() then
				channel = "RAID_WARNING"
			else
				channel = "RAID"
			end
		elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			channel = "INSTANCE_CHAT"
		elseif IsInGroup() then
			channel = "PARTY"
		else
			channel = "SAY"
		end
		SendChatMessage(messg,channel)
		return
	end
	SendChatMessage(messg,LoseControlFixDB.out)
end

Functions.OutputLabel = function()
	local label = ""
	if not LoseControlFixDB.out then return _G.NONE end
	if LoseControlFixDB.out == "INSTANCE_CHAT" then return "Instance Chat" end
	label = LoseControlFixDB.out:gsub("^(%a)(.+)", function(s1,s2) return s1:upper()..s2:lower() end)
	return label
end

Functions.ApplyOptions = function()
	LossOfControlFrame:SetMovable(true)
	LossOfControlFrame:UnregisterAllEvents()
	if not Flags.hooked then
		hooksecurefunc("LossOfControlFrame_SetUpDisplay", Functions.Out)
		Flags.hooked = true
	end
	local cvarOn = GetCVarBool("lossOfControl")
	if LoseControlFixDB.point then
		LossOfControlFrame:SetClampedToScreen(true)
		LossOfControlFrame:SetPoint(LoseControlFixDB.point,LoseControlFixDB.x,LoseControlFixDB.y)
	end
	if LoseControlFixDB.scale then
		LossOfControlFrame:SetScale(LoseControlFixDB.scale)
	end
	if LoseControlFixDB.noBG then
		LossOfControlFrame.blackBg:SetTexture(nil)
	end
	if LoseControlFixDB.noGlow then
		LossOfControlFrame.RedLineTop:SetTexture(nil)
		LossOfControlFrame.RedLineBottom:SetTexture(nil)
	end
	if LoseControlFixDB.actionbars then
		SetCVar("lossOfControl","1")
	else
		SetCVar("lossOfControl","0")
	end
	if LoseControlFixDB.alert then
		LossOfControlFrame:RegisterEvent("LOSS_OF_CONTROL_UPDATE")
		LossOfControlFrame:RegisterEvent("LOSS_OF_CONTROL_ADDED")
	else
		LossOfControlFrame:UnregisterEvent("LOSS_OF_CONTROL_UPDATE")
		LossOfControlFrame:UnregisterEvent("LOSS_OF_CONTROL_ADDED")
	end
end

Functions.AddToBlizzOptions = function()
	if Flags.optionsdone then return end
	if InCombatLockdown() then
		Flags.defer = "AddToBlizzOptions"
		f:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	
	InterfaceOptionsCombatPanelLossOfControl:HookScript("OnClick",
		function(self,button) 
			if self:GetChecked() then
				LoseControlFixDB.alert = true
			else
				LoseControlFixDB.alert = nil
			end
			Functions.ApplyOptions()
		end
	)
	InterfaceOptionsFrameOkay:HookScript("OnClick",Functions.ApplyOptions)
	
	local redBar = CreateFrame("CheckButton", "LoseControlRedBarCheck", InterfaceOptionsCombatPanel, "InterfaceOptionsCheckButtonTemplate")
	redBar:SetPoint("TOP", InterfaceOptionsCombatPanelLossOfControl)
	redBar:SetPoint("LEFT", InterfaceOptionsCombatPanelAutoSelfCast)
	redBar.Text:SetText("Loss of Control on Actionbars")
	redBar.tooltip = "Show the Loss of Control Cooldown on your Actionbars"
	redBar:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, 1) end)
	redBar:SetScript("OnLeave", GameTooltip_Hide)
	redBar:SetChecked(GetCVarBool("lossOfControl"))
	redBar:SetScript("OnClick", 
		function(self,button)
			if self:GetChecked() then
				LoseControlFixDB.actionbars = true
			else
				LoseControlFixDB.actionbars = nil
			end
			Functions.ApplyOptions()
		end
	)
	
	local bgCheck = CreateFrame("CheckButton", "LoseControlFixBgCheck", InterfaceOptionsCombatPanel, "InterfaceOptionsCheckButtonTemplate")
	bgCheck:SetPoint("LEFT", redBar)
	bgCheck:SetPoint("TOP", redBar, "BOTTOM", 0, -10)
	bgCheck.Text:SetText("Hide the background")
	bgCheck.tooltip = "Hide the Screen Alert background"
	bgCheck:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, 1) end)
	bgCheck:SetScript("OnLeave", GameTooltip_Hide)
	bgCheck:SetChecked(LoseControlFixDB.noBG)
	bgCheck:SetScript("OnClick", 
		function(self,button)
			if self:GetChecked() then
				LoseControlFixDB.noBG = true
			else
				LoseControlFixDB.noBG = nil
				LossOfControlFrame.blackBg:SetTexture(bgTex)
			end
			Functions.ApplyOptions()
		end
	)
	
	local glowCheck = CreateFrame("CheckButton", "LoseControlFixGlowCheck", InterfaceOptionsCombatPanel, "InterfaceOptionsCheckButtonTemplate")
	glowCheck:SetPoint("LEFT", bgCheck)
	glowCheck:SetPoint("TOP", bgCheck, "BOTTOM", 0, -10)
	glowCheck.Text:SetText("Hide the Glow")
	glowCheck.tooltip = "Hide the Screen Alert glow"
	glowCheck:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, 1) end)
	glowCheck:SetScript("OnLeave", GameTooltip_Hide)
	glowCheck:SetChecked(LoseControlFixDB.noGlow)
	glowCheck:SetScript("OnClick", 
		function(self,button)
			if self:GetChecked() then
				LoseControlFixDB.noGlow = true
			else
				LoseControlFixDB.noGlow = nil
				LossOfControlFrame.RedLineTop:SetTexture(topTex)
				LossOfControlFrame.RedLineBottom:SetTexture(bottomTex)
			end
			Functions.ApplyOptions()
		end
	)
	
	local scaleSlider = CreateFrame("Slider", "LoseControlFixScaleSlider", InterfaceOptionsCombatPanel, "OptionsSliderTemplate")
	scaleSlider:SetPoint("LEFT", glowCheck)
	scaleSlider:SetPoint("TOP", glowCheck, "BOTTOM", 0, -10)
	scaleSlider.text = _G["LoseControlFixScaleSliderText"]
	scaleSlider.low = _G["LoseControlFixScaleSliderLow"]
	scaleSlider.high = _G["LoseControlFixScaleSliderHigh"]
	scaleSlider.tooltipText = "Drag to set Screen Alert scale."
	scaleSlider:SetWidth(120)
	scaleSlider:SetMinMaxValues(0.5,1.5)
	local scale = LoseControlFixDB.scale or 1.0
	scaleSlider:SetValue(scale)
	scaleSlider:SetValueStep(0.05)
	scaleSlider.text:SetText(string.format("Alert Scale: %d%%", scale*100))
	scaleSlider.low:SetText("0.5")
	scaleSlider.high:SetText("1.5")
	scaleSlider:SetScript("OnValueChanged", 
		function(self, value)
			LoseControlFixDB.scale = value
			scaleSlider.text:SetText(string.format("Alert Scale: %d%%", LoseControlFixDB.scale*100))
			Functions.ApplyOptions()
		end
	)
	
	local unlockButton = CreateFrame("Button", "LoseControlFixUnlockButton", InterfaceOptionsCombatPanel, "UIPanelButtonTemplate")
	local movable = LossOfControlFrame.move
	unlockButton:SetText(movable and "Lock" or "Unlock")
	unlockButton:SetSize(90,22)
	unlockButton:SetPoint("LEFT", scaleSlider)
	unlockButton:SetPoint("TOP", scaleSlider, "BOTTOM", 0, -15)
	unlockButton.tooltipText = "Use to unlock Screen Alert for dragging.\nDrag and press Lock to save new position."
	unlockButton:SetScript("OnClick",
		function(self, button)
			if not LossOfControlFrame.move then
				LossOfControlFrame:EnableMouse(true)
				LossOfControlFrame:RegisterForDrag("LeftButton")
				LossOfControlFrame:SetScript("OnDragStart",LossOfControlFrame.StartMoving)
				LossOfControlFrame:SetScript("OnDragStop",LossOfControlFrame.StopMovingOrSizing)
				LossOfControlFrame:SetScript("OnUpdate",nil)
				LossOfControlFrame:Show()
				LossOfControlFrame.move = true
				self:SetText("Lock")
			else
				local point,_,_,x,y = LossOfControlFrame:GetPoint(1)
				LoseControlFixDB.point,LoseControlFixDB.x,LoseControlFixDB.y = point,x,y
				LossOfControlFrame:EnableMouse(false)
				LossOfControlFrame:RegisterForDrag(nil)
				LossOfControlFrame:SetScript("OnDragStart",nil)
				LossOfControlFrame:SetScript("OnDragStop",nil)
				LossOfControlFrame:SetScript("OnUpdate",LossOfControlFrame_OnUpdate)
				LossOfControlFrame.move = nil
				self:SetText("Unlock")
			end
			Functions.ApplyOptions()
		end
	)
	
	local announceButton = CreateFrame("Button", "LoseControlFixAnnounceButton", InterfaceOptionsCombatPanel, "UIPanelButtonTemplate")
	local whereText = Functions.OutputLabel()
	announceButton:SetText("Announce: "..whereText)
	announceButton:SetSize(180,22)
	announceButton:SetPoint("LEFT", unlockButton)
	announceButton:SetPoint("TOP", unlockButton, "BOTTOM", 0, -15)
	announceButton.tooltipText = "Select where to announce.\n\'None\': Disable announcements, \n\'Self\': Local chatframe only."
	announceButton:SetScript("OnClick",
		function(self, button)
			EasyMenu(outTable,LCF_Output_DD,self,0,0,nil)
		end
	)
	f.outButton = announceButton
	Functions.ApplyOptions()
	Flags.optionsdone = true
	if Flags.defer == "AddToBlizzOptions" then Flags.defer = nil end
end
-- Debug
-- _G[addonName] = private