--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local BackupFrameController = AS2.Controller.BackupFrameController
local BackupListController = AS2.Controller.BackupListController

function BackupFrameController:Create(frame)
	assert(frame)
	self = self:Derive()
	self.frame = frame

	self.backupListController = BackupListController:Create(frame.backupList)

	-- Certain messages need to pass from the list controller through to the backup frame's owner
	AS2:AddCallback(self.backupListController, "NewBackup", function(self, sender, ...) AS2:SendMessage(self, "NewBackup", self, ...) end, self)
	AS2:AddCallback(self.backupListController, "RestoreBackup", function(self, sender, ...) AS2:SendMessage(self, "RestoreBackup", self, ...) end, self)

	-- Listen for when the backup set we're displaying information for changes
	AS2:AddCallback(frame, "ContextChanged", self.OnContextChanged, self)

	AS2:RegisterMessage(self, "NewBackup")		-- (pass-through to owner)
	AS2:RegisterMessage(self, "RestoreBackup")	-- (pass-through to owner)

	AS2:AddCallback(AS2, "TutorialsChanged", self.TryActivateTutorials, self)
	AS2:SetTutorialInfo("TUTORIAL_CREATE_MANUAL_BACKUP", self, frame, frame.backupList, 0, 0, frame.backupList, "TOPLEFT", 0, -AS2.LIST_ITEM_HEIGHT / 2)

	assert(frame:GetScript("OnShow") == nil)
	frame:SetScript("OnShow", function()
		self:TryActivateTutorials()
	end)

	return self
end

-- Called when we need to display information about a different backup set
function BackupFrameController:OnContextChanged(_, backupList)
	self.backupListController:SetContext(backupList)
end

-- Checks whether any tutorials can be activated.
function BackupFrameController:TryActivateTutorials()
	AS2:TryActivateTutorial("TUTORIAL_CREATE_MANUAL_BACKUP")
end
