--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- StaticPopups.lua - This file contains definitions for the various popup dialogs used throughout the addon.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local L = LibStub("AceLocale-3.0"):GetLocale("ActionSwap2", true)

AS2.Popups = { }

-- Template for all information dialog boxes
local infoBase = AS2.ObjBase:MixInto({
	width = 380,
	acceptText = L["Okay"],
	hideOnEscape = true,
	isExclusive = true,
	showAlert = true
})

-- Template for all yes / no dialog boxes
local queryBase = infoBase:Derive()
queryBase.acceptText = L["Yes"]
queryBase.cancelText = L["No"]

-- Template for all dialog boxes with an edit box
local editBase = queryBase:Derive()
editBase.hasEditBox = true
editBase.acceptText = L["Okay"]
editBase.cancelText = L["Cancel"]
editBase.showAlert = false

local popup

-- Delete set confirmation dialog
popup = queryBase:Derive()
popup.format = L["POPUP_DELETE_SET"]
popup.onAccept = function(self) self.owner:private_DeleteSetPopup_OnAccept(self) end
AS2.Popups["DELETE_SET"] = popup

-- Delete backup confirmation dialog
popup = queryBase:Derive()
popup.format = L["POPUP_DELETE_BACKUP"]
popup.onAccept = function(self) self.owner:private_DeleteBackupPopup_OnAccept(self) end
AS2.Popups["DELETE_BACKUP"] = popup

-- Edit backup name dialog
popup = editBase:Derive()
popup.format = L["POPUP_EDIT_BACKUP"]
popup.maxLetters = 16
popup.onAccept = function(self) self.owner:private_EditBackupPopup_OnAccept(self) end
AS2.Popups["EDIT_BACKUP"] = popup

-- Restore set confirmation dialog
popup = queryBase:Derive()
popup.format = L["POPUP_RESTORE_SET"]
popup.onAccept = function(self) self.owner:private_RestoreSetPopup_OnAccept(self) end
AS2.Popups["RESTORE_SET"] = popup

-- Overwrite set confirmation dialog
popup = queryBase:Derive()
popup.format = L["POPUP_SAVE_SET"]
popup.onAccept = function(self) self.owner:private_SaveSetPopup_OnAccept(self) end
AS2.Popups["SAVE_SET"] = popup

-- Discrepencies detected dialog
popup = infoBase:Derive()
popup.isExclusive = false
popup.format = L["POPUP_DISCREPENCIES"]
AS2.Popups["DISCREPENCIES"] = popup

-- Removals detected dialog
popup = queryBase:Derive()
popup.isExclusive = false
popup.format = L["POPUP_REMOVALS"]
popup.onAccept = function(self) self.owner:private_RemovalsPopup_OnAccept(self) end
AS2.Popups["REMOVALS"] = popup

-- Minimum revision dialog
popup = infoBase:Derive()
popup.isExclusive = false
popup.format = L["POPUP_MINIMUM_VERSION"]
AS2.Popups["MINIMUM_VERSION"] = popup

-- Soft backup limit warning dialog
popup = infoBase:Derive()
popup.format = L["POPUP_BACKUP_LIMIT_SOFT"]
AS2.Popups["BACKUP_LIMIT_SOFT"] = popup

-- Hard backup limit warning dialog
popup = infoBase:Derive()
popup.format = L["POPUP_BACKUP_LIMIT_HARD"]
AS2.Popups["BACKUP_LIMIT_HARD"] = popup

-- Equip confirmation dialog (no set equipped)
popup = queryBase:Derive()
popup.format = L["POPUP_EQUIP_WARNING"]
popup.onAccept = function(self) self.owner:private_EquipWarningPopup_OnAccept(self) end
AS2.Popups["EQUIP_WARNING"] = popup

-- Equip confirmation dialog (spell not found)
popup = queryBase:Derive()
popup.format = L["POPUP_EQUIP_WARNING_SPELL_NOT_FOUND"]
popup.onAccept = function(self) self.owner:private_EquipWarningSpellNotFoundPopup_OnAccept(self) end
AS2.Popups["EQUIP_WARNING_SPELL_NOT_FOUND"] = popup

-- Disinclude keybindings warning
popup = queryBase:Derive()
popup.format = L["POPUP_DISINCLUDE_WARNING"]
popup.onAccept = function(self) self.owner:private_DisincludeWarningPopup_OnAccept(self) end
AS2.Popups["DISINCLUDE_WARNING"] = popup

-- Select all confirmation
popup = queryBase:Derive()
popup.format = L["POPUP_SELECTALL_CONFIRM"]
popup.onAccept = function(self) self.owner:private_SelectAllConfirmPopup_OnAccept(self) end
AS2.Popups["SELECTALL_CONFIRM"] = popup

-- Select none confirmation
popup = queryBase:Derive()
popup.format = L["POPUP_SELECTNONE_CONFIRM"]
popup.onAccept = function(self) self.owner:private_SelectNoneConfirmPopup_OnAccept(self) end
AS2.Popups["SELECTNONE_CONFIRM"] = popup

-- Hide tutorials confirmation
popup = queryBase:Derive()
popup.format = L["POPUP_HIDE_TUTORIALS"]
popup.onAccept = function(self) self.owner:private_HideTutorialsPopup_OnAccept(self) end
popup.onCancel = function(self) self.owner:private_HideTutorialsPopup_OnCancel(self) end
AS2.Popups["HIDE_TUTORIALS"] = popup

-- Warning about character specific keybindings when trying to enable a feature
popup = infoBase:Derive()
popup.format = L["POPUP_CANNOT_USE_FEATURE_WITHOUT_CHARSPECIFIC"]
AS2.Popups["CANNOT_USE_FEATURE_WITHOUT_CHARSPECIFIC"] = popup

-- Warning about glyphs being reset (occurs when upgrading from Cataclysm data (revision 7-) to Mists of Pandaria (revision 8+))
popup = infoBase:Derive()
popup.isExclusive = false
popup.format = L["POPUP_GLYPH_SETS_RESET"]
AS2.Popups["GLYPH_SETS_RESET"] = popup

-- Warning when sets are unequipped
popup = infoBase:Derive()
popup.isExclusive = false
popup.format = L["POPUP_UNEQUIPPED_SETS"]
AS2.Popups["UNEQUIPPED_SETS"] = popup

-- Warning when sets are unequipped
popup = infoBase:Derive()
popup.isExclusive = false
popup.format = L["POPUP_ALL_SETS_UNEQUIPPED"]
AS2.Popups["ALL_SETS_UNEQUIPPED"] = popup
