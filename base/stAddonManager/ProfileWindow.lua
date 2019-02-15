local M, F, L, D = unpack(stAddonManager) --Import: Modules, Functions/Utilities, Locales, Data
local AM = stAddonManager

--[[ "DELETE PROFILE" DIALOG ]]
StaticPopupDialogs['STADDONMANAGER_OVERWRITEPROFILE'] = {
	text = "There is already a profile named ??????, Do you want to overwrite it?",
	button1 = 'Overwrite',
	button2 = 'Cancel',
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	OnAccept = function(self) end,
	preferredIndex = 3,
}

--[[ "NEW PROFILE" DIALOG ]]
StaticPopupDialogs['STADDONMANAGER_NEWPROFILE'] = {
	text = "Enter a name for your new Addon Profile:",
	button1 = 'Create',
	button2 = 'Cancel',
	timeout = 0,
	hasEditBox = true,
	whileDead = true,
	hideOnEscape = true,
	OnAccept = function(self) AM:NewAddonProfile(self.editBox:GetText()) end,
	preferredIndex = 3,
}

function AM:LoadProfileWindow()
	if not self.ProfileWindow then
		self:CreateProfileWindow()
	else 
		ToggleFrame(self.ProfileWindow)
	end
	if self.ProfileWindow:IsShown() then
		self.profiles.text:SetTextColor(unpack(D.Saved.Colors.hover))
	else
		self.profiles.text:SetTextColor(1, 1, 1)
	end
end

function AM:CreateProfileWindow()
	local PW = CreateFrame('Frame', self:GetName()..'_ProfileWindow', self)
	PW:SetPoint('TOPLEFT', self.profiles, 'TOPRIGHT', 9, 0)
	PW:SetSize(180, 50)
	F.SetTemplate(PW, 'Transparent')
	PW:SetFrameLevel(self:GetFrameLevel()-1)

	----------------------------------------------------
	-- PULLOUT MENU ------------------------------------
	----------------------------------------------------
	local pullout = CreateFrame('Frame', PW:GetName()..'_PulloutMenu', PW)
	pullout:SetWidth(PW:GetWidth() - D.ButtonHeight - 25)
	pullout:SetHeight(D.ButtonHeight*6 + 25)
	F.SetTemplate(pullout)
	pullout:Hide()
	
	pullout.name = F.CreateFontString(pullout)
	pullout.name:SetHeight(D.ButtonHeight)
	pullout.name:SetWidth(pullout:GetWidth()-10)
	pullout.name:SetPoint('TOP', pullout, 0, 0)
	pullout.name:SetText('Profile Name')

	--[[ "SET TO" BUTTON ]]
	local set = F.CreateButton(PW:GetName()..'_SetToButton', pullout)
	set:SetSize(pullout:GetWidth()-10, D.ButtonHeight)
	set:SetPoint('TOP', pullout.name, 'BOTTOM', 0, 0)
	set.text:SetText('SetTo')
	set:SetScript('OnClick', function(self, btn)
		local profileName = self:GetParent():GetParent().text:GetText()
		for i=1, GetNumAddOns() do DisableAddOn(i) end
		for _,addonName in pairs(D.GlobalProfiles[profileName]) do
			EnableAddOn(addonName)
		end
		AM:UpdateAddonList()
		pullout:Hide()
	end)
	F.AddTooltip(set, function(self) GameTooltip:AddLine('Disable all current addons and enable all addons saved to this profile') end)
	pullout.setTo = set

	--[[ "ADD TO" BUTTON ]]
	pullout.addTo = F.CreateButton(PW:GetName()..'_SetToButton', pullout, pullout:GetWidth()-10, D.ButtonHeight, {'TOP', pullout.setTo, 'BOTTOM', 0, -5}, 'Add To', function(self, btn)
		local profileName = self:GetParent():GetParent().text:GetText()
		for _,addonName in pairs(D.GlobalProfiles[profileName]) do
			EnableAddOn(addonName)
		end
		AM:UpdateAddonList()
		pullout:Hide()
	end)

	--[[ "REMOVE FROM" BUTTON ]]
	pullout.removeFrom = F.CreateButton(PW:GetName()..'_RemoveButton', pullout, pullout:GetWidth()-10, D.ButtonHeight, {'TOP', pullout.addTo, 'BOTTOM', 0, -5}, 'Remove Addons', function(self, btn)
		local profileName = self:GetParent():GetParent().text:GetText()
		for _,addonName in pairs(D.GlobalProfiles[profileName]) do
			DisableAddOn(addonName)
		end
		EnableAddOn(addon) --Make sure this addon stays enabled
		AM:UpdateAddonList()
		pullout:Hide()
	end)

	--[[ "DELETE PROFILE" DIALOG ]]
	StaticPopupDialogs['STADDONMANAGER_DELETECONFIRMATION'] = {
		text = "Are you sure you want to delete ???????",
		button1 = 'Delete',
		button2 = 'Cancel',
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnAccept = function(self, data, data2) end,
		preferredIndex = 3,
	}

	--[[ "DELETE PROFILE" BUTTON ]]
	pullout.deleteProfile = F.CreateButton(PW:GetName().."_DeleteProfileButton", pullout, pullout:GetWidth()-10, D.ButtonHeight, {'TOP', pullout.removeFrom, 'BOTTOM', 0, -5}, 'Delete Profile', function(self, btn)
		local profileName = self:GetParent():GetParent().text:GetText()
		local dialog = StaticPopupDialogs['STADDONMANAGER_DELETECONFIRMATION']

		--Modify static popup information to specific button
		dialog.text = format("Are you sure you want to delete %s?", profileName)
		dialog.OnAccept = function(self, data, data2)
			D.GlobalProfiles[profileName] = nil
			AM:UpdateProfiles()
		end
		StaticPopup_Show('STADDONMANAGER_DELETECONFIRMATION')
	end)

	pullout.updateprofile = F.CreateButton(PW:GetName().."_UpdateProfileButton", pullout, pullout:GetWidth()-10, D.ButtonHeight, {'TOP', pullout.deleteProfile, 'BOTTOM', 0, -5}, 'Update Profile', function(self, btn)
		AM:NewAddonProfile(self:GetParent():GetParent().text:GetText(), true)
	end)

	--[[ ANCHOR FUNCTION - Used to change which button the pullout is set to ]]
	pullout.AnchorToButton = function(self, button)
		self.name:SetText(button.text:GetText() or '')
		self:SetParent(button)
		self:SetFrameLevel(10)
		self:SetPoint('TOPLEFT', button, 'TOPRIGHT', 5, 0)
		self:Show()
	end

	PW.pullout = pullout


	----------------------------------------------------
	-- TOP MENU BUTTONS --------------------------------
	----------------------------------------------------
	local enableall = F.CreateButton(PW:GetName()..'_EnableAll', PW)
	enableall:SetWidth(PW:GetWidth()-20)
	enableall:SetHeight(D.ButtonHeight)
	enableall:SetPoint('TOP', PW, 'TOP', 0, -10)
	enableall.text:SetText('Enable All')
	enableall:SetScript('OnMouseDown', function(self) for i=1, GetNumAddOns() do EnableAddOn(i) end; AM:UpdateAddonList() end)
	PW.EnableAll = enableall

	local disableall = F.CreateButton(PW:GetName()..'_DisableAll', PW)
	disableall:SetWidth(PW:GetWidth()-20)
	disableall:SetHeight(D.ButtonHeight)
	disableall:SetPoint('TOP', enableall, 'BOTTOM', 0, -5)
	disableall.text:SetText('Disable All')
	disableall:SetScript('OnMouseDown', function(self)
		for i=1, GetNumAddOns() do
			if not (GetAddOnInfo(i) == addon) then
				DisableAddOn(i)
			end
		end
		AM:UpdateAddonList()
	end)
	PW.DisableAll = disableall

	local newButton = F.CreateButton(PW:GetName()..'_NewProfileButton', PW, PW:GetWidth()-20, D.ButtonHeight, {'TOP', PW.DisableAll, 'BOTTOM', 0, -5}, 'New Profile', function() StaticPopup_Show('STADDONMANAGER_NEWPROFILE') end)
	PW.newButton = newButton

	PW.buttons = {} --Store only buttons in here

	self.ProfileWindow = PW

	AM:UpdateProfiles()
end

function AM:NewAddonProfile(name, overwrite)
	if D.GlobalProfiles[name] and (not overwrite) then 
		local dialog = StaticPopupDialogs['STADDONMANAGER_OVERWRITEPROFILE']
		dialog.text = 'There is already a profile named ' .. name .. '. Do you want to overwrite it?'
		dialog.OnAccept = function(self) AM:NewAddonProfile(name, true) end
		StaticPopup_Show('STADDONMANAGER_OVERWRITEPROFILE')	
	return end

	local addonList = {}
	for i = 1, GetNumAddOns() do
		local addonName, _,_, isEnabled = GetAddOnInfo(i)
		if isEnabled then
			tinsert(addonList, addonName)
		end
	end
	D.GlobalProfiles[name] = addonList

	self.ProfileWindow.pullout:Hide()
	self:UpdateProfiles()
end

function AM:UpdateProfiles()
	local PM = self.ProfileWindow

	local profiles = {}
	local buttons = PM.buttons
	local pullout = PM.pullout

	for name,_ in pairs(D.GlobalProfiles) do
		tinsert(profiles, name)
	end
	sort(profiles)

	for i = 1, #profiles do
		if not buttons[i] then
			local name = format('%s_button%d', PM:GetName(), i)
			local button = F.CreateButton(name, PM, D.ButtonHeight, D.ButtonHeight, nil, profiles[i], function(self) 
				if (pullout:GetParent() == self and pullout:IsShown()) then 
					pullout:Hide() 
				else 
					pullout:AnchorToButton(self) 
				end
			end)
			button.text:ClearAllPoints()
			button.text:SetPoint("LEFT", button, "RIGHT", 10, 0)
			button.text:SetPoint("RIGHT", PM, "RIGHT", -10, 0)
			button.text:SetJustifyH("LEFT")

			if i == 1 then
				pullout:AnchorToButton(button)
				pullout:Hide()
				button:SetPoint("TOPLEFT", PM.newButton, "BOTTOMLEFT", 0, -5)
			else
				button:SetPoint("TOP", PM.buttons[i-1], "BOTTOM", 0, -5)
			end
			button.arrow = F.CreateFontString(button)
			button.arrow:SetPoint('CENTER')
			button.arrow:SetText('>')

			PM.buttons[i] = button
		end

		buttons[i]:Show()
		buttons[i].text:SetText(profiles[i])
	end

	--Hide all buttons that arne't being used - These buttons only appear after profile deletion, and do not re-appear upon reloading the UI
	if #profiles < #buttons then
		for i=#profiles+1, #buttons do
			buttons[i]:Hide()
		end
	end

	-- Make sure this is hidden so that it's not accidentally shown on the wrong profile
	if PM.pullout:IsShown() then
		PM.pullout:Hide()
	end

	PM:SetHeight((#profiles+3)*(D.ButtonHeight+5) + 15)
end
