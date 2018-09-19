--[[========================================================================================
      AdvancedIconSelector, a World of Warcraft icon selector replacement with search
      functionality.
      
      Copyright (c) 2011 - 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:
      
      The above copyright notice and this permission notice shall be included in
      all copies or substantial portions of the Software.
      
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.
    ========================================================================================]]

local AIS = AdvancedIconSelector
AIS.GuildBankPopup = { }
local GuildBankPopup = AIS.GuildBankPopup
local L = LibStub("AceLocale-3.0"):GetLocale("AdvancedIconSelector", true)

local replaced = false
local popup
local options

-- Replaces the standard Blizzard editor popup with one having advanced icon search controls.
function GuildBankPopup:ReplaceGuildBankPopup()
	if not replaced then
		replaced = true

		AIS:Debug("Replaced guild bank popup.")

		local customFrame = CreateFrame("Frame", nil, nil)
		customFrame:SetHeight(60)
	
		options = {
			width = 338,	-- (default width)
			height = 385,	-- (default height)
			customFrame = customFrame,
			headerText = L["Edit Bank Tab"],
			showDynamicText = false,
			sectionOrder = {
				"DynamicIcon",
				"ItemIcons",
				"MacroIcons"
			}
		}

		assert(_G["GuildBankPopupFrame"])
		popup = AIS:CreateIconSelectorWindow("GuildBankPopupFrame", nil, options)
		_G["GuildBankPopupFrame"] = popup

		popup.originalWidth = popup:GetWidth()
		popup.originalHeight = popup:GetHeight()

		popup.nameText = customFrame:CreateFontString()
		popup.nameText:SetFontObject("GameFontHighlightSmall")
		popup.nameText:SetText(GUILDBANK_POPUP_TEXT)
		popup.nameText:SetPoint("TOPLEFT", 0, 0)

		popup.chooseIconText = customFrame:CreateFontString()
		popup.chooseIconText:SetFontObject("GameFontHighlightSmall")
		popup.chooseIconText:SetText(MACRO_POPUP_CHOOSE_ICON)
		popup.chooseIconText:SetPoint("TOPLEFT", 0, -48)
	
		popup.editBox = CreateFrame("EditBox", "GuildBankPopupEditBox", customFrame, "InputBoxTemplate")
		popup.editBox:SetAutoFocus(true)
		popup.editBox:SetMaxLetters(15)
		popup.editBox:SetFontObject("ChatFontNormal")
		popup.editBox:SetSize(182, 20)
		popup.editBox:SetPoint("TOPLEFT", 5, -14)
		_G["GuildBankPopupEditBox"] = popup.editBox

		-- Hook the altered functions
		_G["GuildBankPopupFrame_Update"] = self.GuildBankPopupFrame_Update
		popup:SetScript("OnShow", self.GuildBankPopupFrame_OnShow)

		-- (altered version of Blizzard_GuildBankUI.xml:GuildBankPopupFrame:GuildBankPopupEditBox:OnEscapePressed)
		popup.editBox:SetScript("OnEscapePressed", GuildBankPopupFrame_CancelEdit)

		-- (altered version of Blizzard_GuildBankUI.xml:GuildBankPopupFrame:GuildBankPopupEditBox:OnEnterPressed)
		popup.editBox:SetScript("OnEnterPressed", function(self)
			if popup.okButton:IsEnabled() then
				popup.okButton:Click()
			end
			popup.editBox:ClearFocus()
		end)

		popup.iconsFrame:SetScript("BeforeShow", function(self)
			-- Clear the search parameter.
			popup:SetSearchParameter(nil, true)
		end)

		-- (no altering needed)
		popup:SetScript("OnHide", GuildBankPopupFrame_OnHide)
		popup:SetScript("OnOkayClicked", function(...) PlaySound("gsTitleOptionOK"); GuildBankPopupOkayButton_OnClick(...) end)
		popup:SetScript("OnCancelClicked", function(...) PlaySound("gsTitleOptionOK"); GuildBankPopupFrame_CancelEdit(...) end)

		-- (no equivalent function)
		popup.iconsFrame:SetScript("OnSelectedIconChanged", function(iconsFrame)
			popup.selectedIcon = popup.iconsFrame:GetSelectedIcon()
		end)
	end
end

-- (altered version of Blizzard_GuildBankUI.lua:GuildBankPopupFrame_OnShow)
function GuildBankPopup.GuildBankPopupFrame_OnShow(_)
	-- Size to match the paper doll frame by default.
	popup:ClearAllPoints()
	popup:SetPoint("TOPLEFT", _G["GuildBankFrame"], "TOPRIGHT", -4, -32)
	popup:SetPoint("RIGHT", _G["GuildBankFrame"], "RIGHT", -4 + popup.originalWidth, 0)
	popup:SetPoint("BOTTOM", _G["GuildBankFrame"], "TOP", 0, -32 - popup.originalHeight)
		
	GuildBankPopupFrame_OnShow(popup)
end

-- (altered version of Blizzard_GuildBankUI.lua:GuildBankPopupFrame_Update)
function GuildBankPopup.GuildBankPopupFrame_Update(tab)
	local tabName, tabTexture = GetGuildBankTabInfo(GetCurrentGuildBankTab())
	if tabTexture then
		-- (we don't need to disable the OK button while searching - if
		-- selectedIcon is nil, it GuildBankPopupOkayButton_OnClick defaults
		-- to the current texture)
		popup.iconsFrame:SetSelectionByName(gsub(strupper(tabTexture), "INTERFACE\\ICONS\\", ""))
	else
		popup.iconsFrame:SetSelectedIcon(nil)
	end

	-- The default UI doesn't update the edit box except in OnShow.  Do it
	-- here also, since another tab can be selected while the previous selector
	-- is still open.
	if (not tabName or tabName == "") then
		tabName = format(GUILDBANK_TAB_NUMBER, GetCurrentGuildBankTab())
	end
	popup.editBox:SetText(tabName)

	-- The frame shows up behind the guild bank frame by default and there appears
	-- to be no good approach to bring a frame to the front programmatically
	-- (toplevel only brings it to front when the user clicks), so force the
	-- framelevel as best we can.
	--
	-- Placing this code here instead of BeforeShow also allows the user to
	-- recover a dialog that was "lost" behind the unmoveable guild bank frame
	-- by re-clicking the tab.
	GuildBankPopup.PositionAboveFrame(GuildBankFrame, 15)
end

-- Positions the popup frame at least a certain distance above the given one.
-- (workaround for missing bring-to-front functionality)
function GuildBankPopup.PositionAboveFrame(frame, distance)
	if popup:GetFrameStrata() ~= frame:GetFrameStrata() then popup:SetFrameStrata(frame:GetFrameStrata()) end

	local attempts = 0
	while popup:GetFrameLevel() < frame:GetFrameLevel() + distance and attempts < 25 do
		popup:SetFrameLevel(frame:GetFrameLevel() + distance)
		attempts = attempts + 1
	end
	if attempts == 25 then
		AIS:Debug("WARNING: Failed to position above frame level", frameLevel)
	end
end