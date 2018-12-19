--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local MainWindowController = AS2.Controller.MainWindowController
local UIOperations = AS2.Controller.UIOperations

function MainWindowController:Create(window)
	assert(window)
	self = self:Derive()

	self.mainWindow = window
	
	-- Create the button set list controller, and use it as the data source for the "include buttons" frame as well.
	self.buttonSetListController = AS2.Controller.ButtonSetListController:Create(self.mainWindow.buttonSetList)
	AS2.includeButtonsFrame:SetDelegate(self.buttonSetListController)

	AS2:AddCallback(self.buttonSetListController, "SelectedItemChanged", self.OnSelectedButtonSetChanged, self)
	AS2:AddCallback(self.buttonSetListController, "EditSet", self.OnEditSet, self)

	self.mainWindow.glyphSetsButton.controller = self
	self.mainWindow.glyphSetsButton:SetScript("OnClick", self.OnClick_GlyphSetsButton)

	self.mainWindow.talentSetsButton.controller = self
	self.mainWindow.talentSetsButton:SetScript("OnClick", self.OnClick_TalentSetsButton)

	self.mainWindow.globalKeysetsButton.controller = self
	self.mainWindow.globalKeysetsButton:SetScript("OnClick", self.OnClick_GlobalKeysetsButton)

	AS2:AddCallback(AS2, "TutorialsChanged", self.TryActivateTutorials, self)
	AS2:SetTutorialInfo("TUTORIAL_WELCOME", self, window, window, 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_FIRST_BUTTON_SET", self, window, window.buttonSetList, 0, 0, window.buttonSetList, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2)
	AS2:SetTutorialInfo("TUTORIAL_CLICK_GLYPH_SETS_BUTTON", self, window, window.glyphSetsButton, 0, 0, window.glyphSetsButton, "RIGHT", 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_TALENT_SETS", self, window, window.talentSetsButton, 0, 0, window.talentSetsButton, "RIGHT", 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_KEYBINDING_SETS", self, window, window.globalKeysetsButton, 0, 0, window.globalKeysetsButton, "RIGHT", 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_END", self, window, window, 0, 0)

	local oldOnShow = self.mainWindow:GetScript("OnShow")
	self.mainWindow:SetScript("OnShow", function(mainWindow)
		oldOnShow()
		self:TryActivateTutorials()
	end)

	return self
end

function MainWindowController:OnSelectedButtonSetChanged(sender, buttonSet)
	if buttonSet then
		-- Uncheck the other buttons
		self.mainWindow.glyphSetsButton:SetChecked(false)
		self.mainWindow.talentSetsButton:SetChecked(false)
		self.mainWindow.globalKeysetsButton:SetChecked(false)

		-- Create and display the secondary frame
		if not self.mainWindow.buttonSetFrame then
			local newFrame = AS2.View.ButtonSetFrame:Create("ActionSwap2_ButtonSetFrame", self.mainWindow)
			self.mainWindow.buttonSetFrame = newFrame
			self.mainWindow.buttonSetFrameController = AS2.Controller.ButtonSetFrameController:Create(newFrame)
			AS2:AddCallback(self.mainWindow.buttonSetFrameController, "EditSet", self.OnEditSet, self)
		end
		self.mainWindow.buttonSetFrame:SetContext(buttonSet)
		self.mainWindow:ActivateSecondaryFrame(self.mainWindow.buttonSetFrame)
	else
		self.mainWindow:DeactivateSecondaryFrame(self.mainWindow.buttonSetFrame)
	end
end

function MainWindowController.OnClick_GlyphSetsButton(button)
	PlaySound("igCharacterInfoTab")
	local self = button.controller

	-- Deselect everything else
	self.buttonSetListController:SetSelectedItem(nil)
	self.mainWindow.glyphSetsButton:SetChecked(true)
	self.mainWindow.talentSetsButton:SetChecked(false)
	self.mainWindow.globalKeysetsButton:SetChecked(false)

	-- Create and display the secondary frame
	if not self.mainWindow.glyphSetsFrame then
		local newFrame = AS2.View.GlyphSetsFrame:Create("ActionSwap2_GlyphSetsFrame", self.mainWindow)
		self.mainWindow.glyphSetsFrame = newFrame
		self.mainWindow.glyphSetsFrameController = AS2.Controller.GlyphSetsFrameController:Create(newFrame)
		AS2:AddCallback(self.mainWindow.glyphSetsFrameController, "EditSet", self.OnEditSet, self)
	end
	self.mainWindow:ActivateSecondaryFrame(self.mainWindow.glyphSetsFrame)

	AS2:CompleteTutorial("TUTORIAL_CLICK_GLYPH_SETS_BUTTON")
end

function MainWindowController.OnClick_TalentSetsButton(button)
	PlaySound("igCharacterInfoTab")
	local self = button.controller

	-- Deselect everything else
	self.buttonSetListController:SetSelectedItem(nil)
	self.mainWindow.glyphSetsButton:SetChecked(false)
	self.mainWindow.talentSetsButton:SetChecked(true)
	self.mainWindow.globalKeysetsButton:SetChecked(false)

	-- Create and display the secondary frame
	if not self.mainWindow.talentSetsFrame then
		local newFrame = AS2.View.TalentSetsFrame:Create("ActionSwap2_TalentSetsFrame", self.mainWindow)
		self.mainWindow.talentSetsFrame = newFrame
		self.mainWindow.talentSetsFrameController = AS2.Controller.TalentSetsFrameController:Create(newFrame)
		AS2:AddCallback(self.mainWindow.talentSetsFrameController, "EditSet", self.OnEditSet, self)
	end
	self.mainWindow:ActivateSecondaryFrame(self.mainWindow.talentSetsFrame)
end

function MainWindowController.OnClick_GlobalKeysetsButton(button)
	local self = button.controller

	-- Do not allow certain features unless character-specific keybindings are enabled.
	if not AS2.activeGameModel:IsCharSpecificBindings() then
		self.mainWindow.globalKeysetsButton:SetChecked(false)
		AS2:ShowDialog(AS2.Popups.CANNOT_USE_FEATURE_WITHOUT_CHARSPECIFIC)
		return
	end

	PlaySound("igCharacterInfoTab")

	-- Deselect everything else
	self.buttonSetListController:SetSelectedItem(nil)
	self.mainWindow.glyphSetsButton:SetChecked(false)
	self.mainWindow.talentSetsButton:SetChecked(false)
	self.mainWindow.globalKeysetsButton:SetChecked(true)

	-- Create and display the secondary frame
	if not self.mainWindow.globalKeysetsFrame then
		local newFrame = AS2.View.GlobalKeysetsFrame:Create("ActionSwap2_KeysetsFrame", self.mainWindow)
		self.mainWindow.globalKeysetsFrame = newFrame
		self.mainWindow.globalKeysetsFrameController = AS2.Controller.GlobalKeysetsFrameController:Create(newFrame)
		AS2:AddCallback(self.mainWindow.globalKeysetsFrameController, "EditSet", self.OnEditSet, self)
	end
	self.mainWindow:ActivateSecondaryFrame(self.mainWindow.globalKeysetsFrame)
end

-- Called when an edit operation is started on a set (to set the name and icon)
function MainWindowController:OnEditSet(setListController, set, onAcceptFn)
	setListController:SetSelectedItem(nil)

	-- Create an set editor (icon selector) frame and anchor it
	local setEditorDialog = AS2:CreateOrGetSetEditorDialog(self.mainWindow)
	local anchorWindow = self.mainWindow.activeSecondaryFrame or self.mainWindow
	setEditorDialog:ResetStateAndPosition(anchorWindow)
	assert(setListController.NEW_SET_TEXT)
	if set then
		setEditorDialog.headerText:SetText(setListController.EDIT_SET_TEXT)
	else
		setEditorDialog.headerText:SetText(setListController.NEW_SET_TEXT)
	end

	setEditorDialog:SetScript("OnOkayClicked", function()
		setEditorDialog:Hide()
		assert(setEditorDialog.icon and setEditorDialog.name)
		onAcceptFn(setListController, set, setEditorDialog.name, "Interface\\Icons\\" .. setEditorDialog.icon)
	end)

	-- If this is an edit operation, fill in any starting info
	if set then
		setEditorDialog.name = set:GetName()
		local icon = set:GetIcon()
		if icon then
			setEditorDialog.icon = gsub(strlower(icon), "interface\\icons\\", "")
		else
			setEditorDialog.icon = nil
		end
	end

	setEditorDialog:Show()
end

-- Checks whether any tutorials can be activated.
function MainWindowController:TryActivateTutorials()
	AS2:TryActivateTutorial("TUTORIAL_WELCOME")
	AS2:TryActivateTutorial("TUTORIAL_FIRST_BUTTON_SET")
	AS2:TryActivateTutorial("TUTORIAL_CLICK_GLYPH_SETS_BUTTON")
	AS2:TryActivateTutorial("TUTORIAL_TALENT_SETS")
	AS2:TryActivateTutorial("TUTORIAL_KEYBINDING_SETS")
	AS2:TryActivateTutorial("TUTORIAL_END")
end
