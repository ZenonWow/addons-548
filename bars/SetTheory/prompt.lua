local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

function SetTheory:PromptToActivateSet(title, description, sets, automaticCancel, associateSpec)
	if not self.promptFrame then
		local f = self:MakePromptFrame('SetTheoryPromptFrame', 400, 125)
		f:SetScript("OnHide", function() if not associateSpec then if not UIParent:IsShown() then UIParent:Show() end end end)

		f.setMenu = CreateFrame("Frame", "SetTheoryPromptSet", f, "UIDropDownMenuTemplate")
		f.setMenu:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 7, 13)
		--getglobal('SetTheoryPromptSetButton'):SetScript('OnClick', SetTheory.PromptSetMenu_OnClick)

		UIDropDownMenu_Initialize(f.setMenu, function() return SetTheory:PromptSetMenu_OnLoad(sets) end)
		UIDropDownMenu_SetWidth(f.setMenu, 140)

		f.apply = CreateFrame("Button", "", f, "OptionsButtonTemplate")
		f.apply:SetText(L['Apply'])
		f.apply:SetPoint("BOTTOMLEFT", f.setMenu, "BOTTOMRIGHT", -10, 7)
		f.apply:SetScript('OnClick', function() 
			if associateSpec then self:AssociateSpec(UIDropDownMenu_GetSelectedValue(f.setMenu)) 
			else self:CopySetByName(UIDropDownMenu_GetSelectedValue(f.setMenu), UIDropDownMenu_GetSelectedValue(f.setMenu)) end
			self:SetSetByName({['set']=UIDropDownMenu_GetSelectedValue(f.setMenu)})
			f:Hide()
		end)

		--f:SetScale(0.8)
		self.promptFrame = f
	end	

	local f = self.promptFrame

	if automaticCancel ~= 0 then 
		self.cancelPrompt = 10
		f.cancel:SetText(L['Cancel'] .. ': '..tostring(self.cancelPrompt))
		self.cancelPromptTimer = SetTheory:ScheduleRepeatingTimer("UpdateCancelPrompt", 1)
	end

	f.title:SetText("SetTheory "..title)
	f.subTitle:SetText(description)
	UIDropDownMenu_ClearAll(self.promptFrame.setMenu)

	local parent = UIParent
	if not associateSpec then 
		parent = nil
	end 
	self.promptFrame:SetParent(parent)

	self.promptFrame:Show()
end

function SetTheory:MakePromptFrame(name, width, height)
	local f = CreateFrame("Frame", name, UIParent)
	table.insert(UISpecialFrames, name)
	f:SetPoint("TOP", UIParent, "TOP", 0, -100)
	f:SetFrameStrata("DIALOG")
	f:SetHeight(height)
	f:SetWidth(width)
	f:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9 }
	})
	f:SetBackdropColor(0,0,0, 0.8)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetScript("OnMouseDown", function() f:StartMoving() end)
	f:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

	f.title = f:CreateFontString("SetTheoryPromptTitle", "HIGH")
	f.title:SetPoint("TOPLEFT", f, "TOPLEFT", 25, -20)
	f.title:SetFont("Fonts\\FRIZQT__.TTF",16)
	f.title:SetTextColor(1,0.8,0, 1)

	f.subTitle = f:CreateFontString("SetTheoryPromptSubTitle", "HIGH")
	f.subTitle:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -5)
	f.subTitle:SetFont("Fonts\\FRIZQT__.TTF",12)
	f.subTitle:SetWidth("350")
	f.subTitle:SetJustifyH("LEFT")

	f.cancel= CreateFrame("Button", "", f, "OptionsButtonTemplate")
	f.cancel:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 20)
	f.cancel:SetText(L["Cancel"])
	f.cancel:SetScript('OnClick', function() f:Hide() end)

	return f
end

function SetTheory:PromptToSetGlyphs(glyphs)
	if not self.glyphPrompt then
		local f = self:MakePromptFrame("SetTheoryGlyphPrompt", 360, 275)
		f.title:SetText("SetTheory "..L["Glyphs"])
		f.subTitle:SetText(L["Please press the buttons below to apply your glyphs."])
		f:SetScript('OnShow', function() 
			self:RegisterEvent('BAG_UPDATE', 'SetGlyphsAsAvailable')
		end)
		self:RegisterEvent('BAG_UPDATE', 'SetGlyphsAsAvailable')
		f:SetScript('OnHide', function()
			self:UnregisterEvent('BAG_UPDATE') 
		end)
		self.glyphPrompt = f
	end

	local f = self.glyphPrompt

	for i=1,GetNumGlyphSockets() do
		local ring = getglobal('SetTheoryApplyGlyphRing_'..i)
		if ring then ring:Hide() end
	end

	local GlyphXY = {
		{x=0, y=50},
		{x=0, y=-50},
		{x=-55, y=30},
		{x=55, y=-30},
		{x=55, y=30},
		{x=-55, y=-30},
	}

	for socket, coords in pairs(GlyphXY) do
		local frm = getglobal('SetTheoryApplyGlyphFrm'..tostring(socket)) or CreateFrame("Frame", 'SetTheoryApplyGlyphFrm'..tostring(socket), f)
		frm:SetHeight(60)
		frm:SetWidth(60)

		--[[frm:SetBackdrop({
			bgFile = "Interface\\AddOns\\SetTheory\\GlyphButton",
			insets = {left=0, right=0, top=0, bottom=0},
		})]]

		local ring = getglobal('SetTheoryApplyGlyphFrm'..tostring(socket)).ring or frm:CreateTexture(nil, "OVERLAY")
		ring:SetTexture('Interface\\AddOns\\SetTheory\\GlyphButton')
		ring:SetAllPoints(frm)
		frm:SetPoint("CENTER", f, "CENTER", coords.x, coords.y-10)
		frm:Show()
		if frm.btn then frm.btn:Hide() end
		frm.ring = ring
		frm.spell = nil
		frm.glyph = nil
	end

	local swaps = 0
	for t, type in pairs(glyphs) do
		for slot, glyph in pairs(type) do
			swaps = swaps + 1

			local g, spell = strsplit(':', glyph)
			local name, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(g)
			local spellName, _, spellIcon = GetSpellInfo(spell)
			if not spellIcon then spellIcon = itemTexture end
			
			local frm = getglobal('SetTheoryApplyGlyphFrm'..tostring(slot))

			local btn = getglobal('SetTheoryApplyGlyphFrm'..tostring(slot)).btn or CreateFrame("Button", _, frm, "SecureActionButtonTemplate")
			btn:SetHeight(35)
			btn:SetWidth(35)
			btn:SetPoint("CENTER", frm, "CENTER", 0, 0)
			btn:Show()

			btn:SetScript('OnEnter', function(this) 
				GameTooltip:SetOwner(this, "ANCHOR_NONE")
				GameTooltip:SetPoint("LEFT", this, "RIGHT")
				if not this.icon:IsDesaturated() then
					GameTooltip:AddLine(L['Click here to apply this glyph'], _, _, _, 1)
				else
					GameTooltip:AddLine(L['You cannot apply this glyph as you do not have one in your bags'])
				end
				GameTooltip:AddDoubleLine(name, L['Glyph'..tostring(slot)], _, _, _, 0.5, 0.5, 0.9)
				GameTooltip:Show()
			end)
			btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
				
			frm.glyph = g
			frm.spell = GetItemSpell(g)
			frm.btn = btn
			--btn:SetPoint("CENTER", frm, "CENTER", 0, 0)

			local icon = getglobal('SetTheoryApplyGlyphFrm'..tostring(slot)).btn.icon or btn:CreateTexture(nil, "BACKGROUND")
			SetPortraitToTexture(icon, spellIcon)
			--icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:SetAllPoints(btn)
			frm.btn.icon = icon
			
			btn:SetAttribute('type', 'macro')
			btn:SetAttribute('macrotext', "/use item:"..tostring(g).."\n/run PlaceGlyphInSocket("..slot.."); SetTheory:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', 'SetGlyphsAdded'); SetTheory:RegisterEvent('UNIT_SPELLCAST_FAILED', 'SetGlyphsAdded');")
			btn:Show()
		end
	end

	self:SetGlyphsAsAvailable()
	if swaps > 0 then f:Show() else f:Hide() end
end

function SetTheory:SetGlyphsAsAvailable(evt, bag)
	if bag and bag < 0 then return end
	for g=1,GetNumGlyphSockets() do
		local frm = getglobal('SetTheoryApplyGlyphFrm'..tostring(g))
		if frm then
			if frm.btn then SetDesaturation(frm.btn.icon, true) end
			SetDesaturation(frm.ring, true)
			for b=bag or 0,bag or NUM_BAG_SLOTS do
				for slot=1, GetContainerNumSlots(b) do
					local _, _, itemId = string.find(GetContainerItemLink(b,slot) or '',"item:(%d+)");
					if itemId and frm.glyph == itemId then
						if frm.btn then SetDesaturation(frm.btn.icon, false) end
						SetDesaturation(frm.ring, false)
					end
				end
			end
		end
	end
end

function SetTheory:SetGlyphsAdded(evt, unit, spell) 
	local hidden = 0
	for i=1,GetNumGlyphSockets() do
		local frm = getglobal('SetTheoryApplyGlyphFrm'..tostring(i))
		if not frm.btn or not frm.btn:IsShown() then hidden = hidden + 1 end
		if frm and frm.spell == spell and evt == "UNIT_SPELLCAST_SUCCEEDED" then
			frm.btn:Hide()
			hidden = hidden + 1
		end
	end
	self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	self:UnregisterEvent('UNIT_SPELLCAST_FAILED')

	if hidden == GetNumGlyphSockets() then self.glyphPrompt:Hide() end
end

function SetTheory:UpdateCancelPrompt()
	self.cancelPrompt = self.cancelPrompt - 1
	if self.cancelPrompt == -1 then
		self:CancelTimer(self.cancelPromptTimer, true)
		self.promptFrame:Hide()
		self.promptFrame.cancel:SetText(L['Cancel'])
	else
		self.promptFrame.cancel:SetText(L['Cancel']..': '..self.cancelPrompt)
	end
end




