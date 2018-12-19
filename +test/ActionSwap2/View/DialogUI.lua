--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local DialogUI = AS2.View.DialogUI
local Widgets = AS2.View.Widgets

local shownDialogs = { }

-- Creates a new dialog based on the given template, using the given format parameters.
function DialogUI:CreateDialog(template, ...)
	local dialog = CreateFrame("Frame", nil, UIParent)
	dialog:SetFrameStrata("DIALOG")
	Widgets:PositionAboveFrameLevel(dialog, 10)	-- (position above preview windows)
	dialog:SetToplevel(true)
	dialog:EnableKeyboard(true)
	dialog:EnableMouse(true)	-- (not click-through)
	dialog.template = template

	-- Set the background of the dialog
	dialog:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 32,
		tileSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }
	})

	-- When the dialog is hidden (close button or otherwise), call the appropriate method on the template.
	dialog:SetScript("OnHide", function()
		if dialog.result == "ACCEPT" then
			if template.onAccept then template.onAccept(dialog) end
		else
			if template.onCancel then template.onCancel(dialog) end
		end
	end)

	-- Detect escape / enter (when no edit box is present)
	dialog:SetScript("OnKeyDown", function(_, key)
		if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then	-- Escape key
			if template.hideOnEscape then dialog:Hide() end
		elseif GetBindingFromClick(key) == "SCREENSHOT" then
			RunBinding("SCREENSHOT")
			return
		elseif key == "ENTER" then
			dialog.acceptButton:Click("LeftButton", true)
		end
	end)

	-- Create the alert icon
	if template.showAlert then
		dialog.alertIcon = dialog:CreateTexture()
		dialog.alertIcon:SetDrawLayer("ARTWORK", 0)
		dialog.alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT)
		dialog.alertIcon:SetSize(36, 36)
		dialog.alertIcon:SetPoint("LEFT", 24, 0)
	end

	-- Create the close button
	dialog.closeButton = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
	dialog.closeButton:SetPoint("TOPRIGHT", 0, 0)

	-- Create the "accept" button
	dialog.acceptButton = CreateFrame("Button", nil, dialog, "StaticPopupButtonTemplate")
	dialog.acceptButton:SetText(template.acceptText or L["Okay"])
	dialog.acceptButton:SetScript("OnClick", function() dialog.result = "ACCEPT"; dialog:Hide() end)

	-- Create the "cancel" button
	if template.cancelText then
		dialog.cancelButton = CreateFrame("Button", nil, dialog, "StaticPopupButtonTemplate")
		dialog.cancelButton:SetText(template.cancelText)
		dialog.cancelButton:SetScript("OnClick", function() dialog.result = "CANCEL"; dialog:Hide() end)
	end

	-- Create the text element
	dialog.text = dialog:CreateFontString()
	dialog.text:SetFontObject("GameFontHighlight")
	dialog.text:SetFormattedText(template.format, ...)
	dialog.text:SetWidth(290)

	-- Create the edit box
	if template.hasEditBox then
		dialog.editBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
		dialog.editBox:SetFontObject("ChatFontNormal")
		dialog.editBox:SetAutoFocus(true)
		dialog.editBox:SetSize(130, 32)
		if template.maxLetters then dialog.editBox:SetMaxLetters(template.maxLetters) end

		dialog.editBox:SetScript("OnEscapePressed", function() if template.hideOnEscape then dialog:Hide() end end)
		dialog.editBox:SetScript("OnEnterPressed", function() dialog.acceptButton:Click("LeftButton", true) end)
		dialog.editBox:SetScript("OnEditFocusLost", nil)
		dialog.editBox:SetScript("OnEditFocusGained", nil)
	end

	-- Position everything in the dialog
	if dialog.cancelButton then
		dialog.acceptButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -6, 16)
		dialog.cancelButton:SetPoint("LEFT", dialog.acceptButton, "RIGHT", 13, 0)
	else
		dialog.acceptButton:SetPoint("BOTTOM", 0, 16);
	end
	dialog.text:SetPoint("TOP", 0, -16)
	if dialog.editBox then dialog.editBox:SetPoint("BOTTOM", 0, 45) end

	local width = (template.showAlert or dialog.cancelButton) and 420 or 320
	local height = 32 + dialog.text:GetHeight() + 8 + dialog.acceptButton:GetHeight()
	if dialog.editBox then
		height = height + 8 + dialog.editBox:GetHeight()
	end
	dialog:SetSize(width, height)

	return dialog
end

-- Removes any hidden dialogs from the list
function DialogUI:private_RemoveHidden()
	for i = #shownDialogs, 1, -1 do
		if not shownDialogs[i]:IsShown() then
			tremove(shownDialogs, i)
		end
	end
end

-- Shows the specified dialog at an appropriate location on the screen
function DialogUI:ShowDialog(dialog)

	-- Hide all other dialogs if this one is marked as exclusive
	if dialog.template.isExclusive then
		self:HideAllDialogs()
	end

	-- Collapse the list
	self:private_RemoveHidden()

	-- Position the new dialog and add it to the list
	local lastFrame = shownDialogs[#shownDialogs]
	if lastFrame then
		dialog:SetPoint("TOP", lastFrame, "BOTTOM")
	else
		dialog:SetPoint("TOP", UIParent, "TOP", 0, -135)
	end
	tinsert(shownDialogs, dialog)
	
	-- (edit box auto-focus doesn't appear to work properly unless this is here)
	if dialog.editBox then
		dialog.editBox:SetFocus()
	end
end

-- Hides all dialogs
function DialogUI:HideAllDialogs()
	for i = #shownDialogs, 1, -1 do		-- (go in reverse order so it doesn't matter if the list gets collapsed)
		shownDialogs[i]:Hide()
	end
end

-- Hides all shown dialogs
function DialogUI:HideDialogsWithTemplate(template)
	for i = #shownDialogs, 1, -1 do		-- (go in reverse order so it doesn't matter if the list gets collapsed)
		if shownDialogs[i].template == template then
			shownDialogs[i]:Hide()
		end
	end
end
