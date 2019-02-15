local M, F, L, D = unpack(stAddonManager) --Import: Modules, Functions/Utilities, Locales, Data
local AM = stAddonManager
local isSearching = false

function AM:LoadMainWindow()
	if GameMenuFrame:IsShown() then HideUIPanel(GameMenuFrame) end
	if not self.Loaded then
		self:CreateMainWindow()
	else 
		ToggleFrame(self)
	end
end

function AM:CreateMainWindow()
	self:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
	self:SetFrameStrata('HIGH')
	F.SetTemplate(self, 'Transparent')

	--Hide the extra panels when hiding the main one
	self:SetScript('OnHide', function()
		if self.ProfileWindow and self.ProfileWindow:IsShown() then
			self.ProfileWindow:Hide()
		end
		-- if self.ConfigWindow and self.ConfigWindow:IsShown() then
		-- 	self.ConfigWindow:Hide()
		-- end
	end)

	self:SetClampedToScreen(true)
	self:SetMovable(true)
	self:EnableMouse(true)
	self:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	self:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

	--Title frame
	local title = CreateFrame("Frame", D.name .. '_TitleBar', self)
	title:SetPoint('TOPLEFT')
	title:SetPoint('TOPRIGHT')
	title:SetHeight(20)
	title.text = F.CreateFontString(title)
	title.text:SetPoint('CENTER')
	title.text:SetText('stAddonManager')
	self.title = title

	--Close button
	self.close = F.CreateButton(title:GetName()..'_CloseButton', title, 16, 16, {'TOPRIGHT', -2, -2}, 'x', function() self:Hide() end)
	F.SetTemplate(self.close, 'N')
	self.close:SetScript('OnEnter', function(self) self.text:SetTextColor(unpack(D.Saved.Colors.hover)) end)
	self.close:SetScript('OnLeave', function(self) self.text:SetTextColor(1, 1, 1) end)

	--Profiles button
	self.profiles = F.CreateButton(D.name .. 'ProfilesButton', self, 70, D.ButtonHeight, {'TOPRIGHT', title, 'BOTTOMRIGHT', -10, -5}, 'Profiles', function(self) AM:LoadProfileWindow() end)
	self.reload = F.CreateButton(self:GetName()..'ReloadButton', self, 70, D.ButtonHeight, {'RIGHT', self.profiles, 'LEFT', -5, 0}, 'Reload', ReloadUI)

	--Search Bar
	local search = F.CreateEditBox(D.name .. '_SearchBar', self, 1, D.ButtonHeight)
	search:SetPoint('TOPLEFT', self.title, 'BOTTOMLEFT', 10, -5)
	search:SetPoint('BOTTOMRIGHT', self.reload, 'BOTTOMLEFT', -5, 0)
	search:SetText("Search")
	search:SetScript("OnEnterPressed", function(self)
		if strlen(strtrim(self:GetText())) == 0 then
			self:UpdateAddonList()
			self:SetText("Search")
		end
	end)
	search:HookScript('OnEscapePressed', function(self) AM:UpdateAddonList(); self:SetText("Search") end)
	search:HookScript("OnTextChanged", function(self, userInput) D.scrollOffset = 0; AM:UpdateSearchQuery(self, userInput) end)
	self.search = search
	self.search.addons = {} -- used to hold addons that fit the search query

	--Frame used to display addons list
	local addons = CreateFrame("Frame", nil, self)
	addons:SetHeight(D.Saved.AddonsPerPage*(D.Saved.CheckButtonHeight+5) + 15)
	addons:SetPoint('TOPLEFT', self.search, 'BOTTOMLEFT', 0, -5)
	addons:SetPoint('TOPRIGHT', self.profiles, 'BOTTOMRIGHT', 0, -5)
	F.SetTemplate(addons)
	addons.buttons = {}

	--Allow the ability to scroll through addons
	-- Much cleaner both code wise and visually than
	-- an actual scroll bar
	addons:EnableMouseWheel(true)
	addons:SetScript('OnMouseWheel', function(self, delta)
		local numAddons = isSearching and #AM.search.addons or GetNumAddOns() 

		--If shift ke is pressed, scroll to the top or bottom
		if IsShiftKeyDown() then
			if delta == 1 then
				D.scrollOffset = max(0, D.scrollOffset - D.Saved.AddonsPerPage)
			elseif delta == -1 then
				D.scrollOffset = min(GetNumAddOns()-D.Saved.AddonsPerPage, D.scrollOffset + D.Saved.AddonsPerPage)
			end
		else
			if delta == 1 and D.scrollOffset > 0 then
				D.scrollOffset = D.scrollOffset - 1
			elseif delta == -1 then
				if D.scrollOffset < numAddons - D.Saved.AddonsPerPage then
					D.scrollOffset = D.scrollOffset + 1
				end
			end
		end

		if isSearching then
			AM:UpdateSearchQuery(AM.search, true) -- emulate userInput
		else
			AM:UpdateAddonList()
		end
	end)
	self.addons = addons

	-- self.config = F.CreateButton(self:GetName()..'_ConfigButton', title, 88, D.ButtonHeight, {'TOPRIGHT', addons, 'BOTTOMRIGHT', 0, -5}, 'Config', function() self:LoadConfigWindow() end)
	-- self.reload = F.CreateButton(self:GetName()..'ReloadButton', self, 87, D.ButtonHeight, {'TOPLEFT', addons, 'BOTTOMLEFT', 0, -5}, 'Reload', ReloadUI)
	
	-- self:UpdateConfig()

	tinsert(UISpecialFrames, self:GetName())

	AM:UpdateAddonList()
	AM:UpdateMainWindow()

	self.Loaded = true
end

function AM:UpdateMainWindow()
	self:SetHeight(self.title:GetHeight() + self.addons:GetHeight() + D.ButtonHeight + 20)
	self:SetWidth(300)
end

function AM:UpdateAddonList()
	--Loop through however many buttons there should be
	for i = 1, D.Saved.AddonsPerPage do
		local addonIndex = D.scrollOffset + i --adjust the scroll offset to get the right addon
		local button = self.addons.buttons[i] 	 --localize the button

		if not button then
			local name = format('%sPage%d', self:GetName(), i)
			local point = i == 1 and {"TOPLEFT", self.addons, "TOPLEFT", 10, -10} or {"TOP", self.addons.buttons[i-1], "BOTTOM", 0, -5}
			local btn = F.CreateCheckBox(name, self.addons, D.Saved.CheckButtonWidth, D.Saved.CheckButtonHeight, point, function(self)
				if not GetAddOnInfo(self.addonName) then return end
				
				local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(self.addonName)
				
				if enabled then
					DisableAddOn(name)
				else
					EnableAddOn(name)
				end
				self:UpdateAddonList()
			end)

			btn.text:ClearAllPoints()
			btn.text:SetPoint("LEFT", btn, "RIGHT", 10, 0)
			btn.text:SetPoint("TOP", btn, "TOP")
			btn.text:SetPoint("BOTTOM", btn, "BOTTOM")
			btn.text:SetPoint("RIGHT", self.addons, "RIGHT", -10, 0)
			btn.text:SetJustifyH("LEFT")

			self.addons.buttons[i] = btn
			button = self.addons.buttons[i]
		end
		--Check if an addon actually exists to place on this button (and hide the button if there isn't an addon to show)
		if addonIndex <= GetNumAddOns() then
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)
			local authors, versions = GetAddOnMetadata(addonIndex, "Author"), GetAddOnMetadata(addonIndex, "Version")
			local requireddeps, optionaldeps = GetAddOnDependencies(addonIndex), GetAddOnOptionalDependencies(addonIndex)
			button.text:SetText(title)
			button:Show()
			button:SetChecked(enabled)
			button:SetScript('OnEnter', function()
				GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', -5, self:GetHeight())
				GameTooltip:ClearLines()
				GameTooltip:AddLine(title)
				if versions then				
					GameTooltip:AddLine("|cFFFFFFFFVersion:|r "..versions)
				end
				if authors then
					GameTooltip:AddLine("|cFF3E8AC6Author(s):|r "..authors)
				end
				if notes then
					GameTooltip:AddLine("|cFFFFFFFF"..notes.."|r")
				end
				if requireddeps then
					GameTooltip:AddDoubleLine('|cFFAD2424Required Dependencies|r', requireddeps)
				end
				if optionaldeps then
					GameTooltip:AddDoubleLine('|cFF3AB73AOptional Dependencies|r', optionaldeps)
				end
				GameTooltip:Show()
			end)
			button:HookScript('OnLeave', function() GameTooltip:Hide() end)
			button:SetScript("OnClick", function()
				if enabled then
					DisableAddOn(name)
				else
					EnableAddOn(name)
				end
				self:UpdateAddonList()
			end)
		else
			button:Hide()
		end
	end

	for i=D.Saved.AddonsPerPage+1, #self.addons.buttons do
		self.addons.buttons[i]:Hide()
	end

	self.addons:SetHeight(D.Saved.AddonsPerPage*(D.Saved.CheckButtonHeight+5) + 15)
end

function AM:UpdateSearchQuery(search, userInput)
	local query = strlower(strtrim(search:GetText()))

	--Revert to regular addon list if:
	-- 1) Query text was not input by a user (e.g. text was changed by search:SetText())
	-- 2) The query text contains nothing but spaces
	if (not userInput) or (strlen(query) == 0) then
		self:UpdateAddonList()
		isSearching = false; -- make sure scroll bar is using the correct update function
		return;
	end

	isSearching = true

	search.addons = {}
	--store all addons that match the query in here
	for i = 1, GetNumAddOns() do
		local name, title = GetAddOnInfo(i)
		name = strlower(name)
		title = strlower(title)

		if strfind(name, query) or strfind(title, query) then
			tinsert(search.addons, i)
		end
	end


	--Loop through however many buttons there should be
	for i = 1, D.Saved.AddonsPerPage do
		local addonIndex = search.addons[D.scrollOffset + i] --adjust the scroll offset to get the right addon
		local button = self.addons.buttons[i] 	 --localize the button

		--Check if an addon actually exists to place on this button (and hide the button if there isn't an addon to show)
		if addonIndex and addonIndex <= GetNumAddOns() then
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)
			button.text:SetText(title)
			button:Show()

			button:SetChecked(enabled)
			button:SetScript("OnClick", function()
				if enabled then
					DisableAddOn(name)
				else
					EnableAddOn(name)
				end
				self:UpdateSearchQuery(search, userInput)
			end)
		else
			button:Hide()
		end
	end
end