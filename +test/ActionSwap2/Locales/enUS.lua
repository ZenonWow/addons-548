--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale("ActionSwap2", "enUS", true)
if not L then return end

local h = NORMAL_FONT_COLOR_CODE
local g = GREEN_FONT_COLOR_CODE
local r = FONT_COLOR_CODE_CLOSE

L["ADDON"] = "ActionSwap 2"				-- Addon name
L["LOAD_FAILED"] = "ActionSwap 2 has failed to load.  Please check for an updated version, or report any errors encountered."

-- Main window
L["Button sets:"] = true
L["Glyph sets"] = true
L["Talent sets"] = true
L["Keybinding sets"] = true
L["New Set"] = true

-- Mini button text
L["DELETE"] = "Delete"
L["EDIT"] = "Change Name/Icon"
L["EDIT_BACKUP"] = "Change Name"
L["OVERWRITE"] = "Overwrite (with current setup)"
L["MOVE_UP"] = "Move Up"
L["MOVE_DOWN"] = "Move Down"
L["VIEW_BACKUPS"] = "View Backups"

-- Set editor window
L["New Button Set"] = true
L["New Action Set"] = true
L["New Glyph Set"] = true
L["New Talent Set"] = true
L["New Keybinding Set"] = true
L["Edit Button Set"] = true
L["Edit Action Set"] = true
L["Edit Glyph Set"] = true
L["Edit Talent Set"] = true
L["Edit Keybinding Set"] = true
L["Enter Set Name:"] = true
L["Choose an Icon:"] = true
L["AIS_NOTE"] = "(If you'd like to replace the other icon pickers with this searchable one,\ndownload and install the addon named AdvancedIconSelector)"

-- Button set details frame
L["Select Buttons..."] = true
L["Stop Selecting"] = true
L["Also swap keybindings"] = true
L["Action sets:"] = true
L["Equip"] = true
L["ACTIONSET_AUTOSAVE_NOTE"] = "Any changes you make to\nyour action bars will be\nautomatically saved."
L["SELECT_UNUSED"] = "Select all unused"
L["DESELECT_ALL"] = "Deselect all"
L["INCLUDE_SLOT"] = "Click to include in button set"
L["EXCLUDE_SLOT"] = "Click to exclude from button set"
L["DISABLED_SLOT"] = "This button is already part of another button set"

-- Glyph sets frame
L["Glyph sets:"] = true
L["GLYPHSET_AUTOSAVE_NOTE"] = "Any changes you make\nto your glyphs will be\nautomatically saved."

-- Talent sets frame
L["Talent sets:"] = true
L["TALENTSET_AUTOSAVE_NOTE"] = "Any changes you make\nto your talents will be\nautomatically saved."

-- Glyph set activation frame
L["GLYPH_SET_ACTIVATION_INSTRUCTIONS"] = "To finish equipping the glyph set,\nopen the glyph pane and place each\nof the glyphs shown here."
L["TALENT_SET_ACTIVATION_INSTRUCTIONS"] = "To finish equipping the talent set, open the talent pane and\nplace each of the talents shown here."
L["Cancel this set change"] = true

-- Keybinding sets frame
L["KEYSET_DESCRIPTION"] = "Keybinding sets include\nany keys that aren't bound\nto an action set that has\nkeybindings enabled."
L["Keybinding sets:"] = true
L["KEYSET_AUTOSAVE_NOTE"] = "Any changes you make to\nyour keybindings will be\nautomatically saved."

-- Backups frame
L["New Backup"] = true
L["Backups:"] = true

-- Discrepencies warning dialog
L["[action set]"] = true
L["[keybinding set]"] = true
L["[glyph set]"] = true
L["[talent set]"] = true
L[" ("] = true
L[" changes)"] = true
L["unknown spell"] = true

-- Popup dialog text
L["Okay"] = true
L["Yes"] = true
L["No"] = true
L["Cancel"] = true
L["POPUP_DELETE_SET"] = "Are you sure you want to delete %s %s?"
L["POPUP_DELETE_BACKUP"] = "Are you sure you want to delete this backup?"
L["POPUP_EDIT_BACKUP"] = "Enter a name for this backup:"
L["POPUP_RESTORE_SET"] = "Are you sure you want to restore %s %s from the selected backup?"
L["POPUP_SAVE_SET"] = "Are you sure you want to overwrite %s %s with the current setup?"
L["button set"] = true
L["action set"] = true
L["action sets"] = true
L["glyph set"] = true
L["glyph sets"] = true
L["talent set"] = true
L["talent sets"] = true
L["keybinding set"] = true
L["POPUP_REMOVALS"] = "It would appear that some items have disappeared from your action bars since you were last in this spec with ActionSwap 2 enabled.  Would you like to restore them?"
L["POPUP_DISCREPENCIES"] = "It would appear that some things have changed since you were last in this spec with ActionSwap 2 enabled.  Your current setup has been recorded to:\n%s\n\nIf one or more of these sets is not supposed to be equipped, please restore it from the latest backup."
L["POPUP_MINIMUM_VERSION"] = "The saved data for ActionSwap 2 appears to have been written from a newer version that is not compatible with this one.  Please download an updated copy of ActionSwap 2."
L["POPUP_BACKUP_LIMIT_SOFT"] = "You are nearing the maximum number of manual backups.  Please consider removing some old ones.\n\n(this backup limit exists for performance reasons)"
L["POPUP_BACKUP_LIMIT_HARD"] = "Cannot create backup - you have reached the maximum number of manual backups!  Please remove some old ones to make room for more.\n\n(this backup limit exists for performance reasons)"
L["POPUP_EQUIP_WARNING"] = "You currently have no %s equipped.\n\nThis action will replace your current setup with the selected %s.  If you wanted to save your current setup to the set before equipping it, click the 'Overwrite' button instead.  Continue anyway?"
L["POPUP_EQUIP_WARNING_SPELL_NOT_FOUND"] = "The following spells do not exist in your current specialization and will be removed from the action set " .. g .. "%s" .. r .. " if you continue:\n\n" .. h .. "%s" .. r .. "\n\nContinue anyway?"
L["POPUP_DISINCLUDE_WARNING"] = "This will cause any per-action-set keybinding data to be deleted (for this button set only).  Continue?"
L["POPUP_SELECTALL_CONFIRM"] = "Add all unused action buttons to the button set?"
L["POPUP_SELECTNONE_CONFIRM"] = "Remove all action buttons from the button set?  This will clear any per-action-set keybinding data."
L["POPUP_HIDE_TUTORIALS"] = "Would you like to turn off the tutorial?\n\nYou can re-enable tutorials by typing\n" .. g .. "/as2 tutorial" .. r .. "."
L["POPUP_CANNOT_USE_FEATURE_WITHOUT_CHARSPECIFIC"] = "This feature of ActionSwap 2 can only be used if character-specific keybindings are enabled."
L["POPUP_GLYPH_SETS_RESET"] = "With the major changes made to WoW's glyph system in Mists of Pandaria, your ActionSwap 2 " .. g .. "glyph sets" .. r .. " had to be cleared.\n\nOn the bright side, now would be a great time to check out the new glyphs available to you, and set up some new glyph sets!\n\n" .. h .. "NOTE: All other set types remain intact." .. r
L["POPUP_UNEQUIPPED_SETS"] = "Note: Your ActionSwap 2 " .. g .. "%s" .. r .. " have been unequipped."
L["POPUP_ALL_SETS_UNEQUIPPED"] = "One or more of your ActionSwap 2 sets have been unequipped due to the Mists of Pandaria update."

-- Tutorial text
L["TUTORIAL_WELCOME_HEADER"] = "Welcome to ActionSwap 2!"
L["TUTORIAL_WELCOME"] = "This addon can help you swap out sets of action buttons, talents, glyphs, and even keybindings.\n\nThis interactive tutorial will help teach you the basics.\n\nIf you accidentally close the tutorial, you can reopen it by typing " .. h .. "/as2 tutorial" .. r .. ".  You can also start the tutorial over by typing " .. h .. "/as2 tutorial reset" .. r .. ".\n\nClick " .. h .. "Next" .. r .. " to continue."
L["TUTORIAL_FIRST_BUTTON_SET_HEADER"] = "Creating a Button Set"
L["TUTORIAL_FIRST_BUTTON_SET"] = "Let's get started by selecting a set of action buttons that will be swapped out, called a " .. h .. "button set" .. r .. ".\n\nCreate a new button set now by left-clicking the " .. h .. "New Set" .. r .. " button.  Then, " .. h .. "left-click" .. r .. " on the newly created button set to select it."
L["TUTORIAL_CLICK_SELECT_BUTTONS_HEADER"] = "Selecting Action Buttons"
L["TUTORIAL_CLICK_SELECT_BUTTONS"] = "Now, click the button labeled " .. h .. "Select Buttons..." .. r .. " to choose which action buttons will be included in the set."
L["TUTORIAL_PICK_BUTTONS_HEADER"] = "Selecting Action Buttons"
L["TUTORIAL_PICK_BUTTONS"] = "Each of your action buttons should now have a white overlay.\n\n" .. h .. "Left-clicking" .. r .. " each button will include or exclude it from the button set.\n\nYou can also use the " .. h .. "Select all unused" .. r .. " or " .. h .. "Deselect all" .. r .. " buttons to choose many buttons at once.\n\n" .. h .. "Select a few buttons now" .. r .. " and then click the button labeled " .. h .. "Stop Selecting" .. r .. "."
L["TUTORIAL_FIRST_ACTION_SET_HEADER"] = "Creating an Action Set"
L["TUTORIAL_FIRST_ACTION_SET"] = "Now, we will create an " .. h .. "action set" .. r .. " that will save the actions for the buttons you just selected.\n\nAn " .. h .. "action set" .. r .. " is a set of actions, as opposed to a " .. h .. "button set" .. r .. ", which is a set of buttons that those actions are placed into.\n\nNote that each slot can only be assigned to one button set at a time, but you can create as many action sets per button set that you want.\n\nCreate a new action set now by clicking the " .. h .. "New Set" .. r .. " button."
L["TUTORIAL_SECOND_ACTION_SET_HEADER"] = "Creating a Second Action Set"
L["TUTORIAL_SECOND_ACTION_SET"] = "Now, we will create another action set.\n\nThe actions saved in this new set will be completely distinct from those in the first set you created.\n\n" .. h .. "Left-click" .. r .. " on the " .. h .. "New Set" .. r .. " button to create a new action set now."
L["TUTORIAL_RETURN_FIRST_ACTION_SET_HEADER"] = "Re-equipping the Original Set"
L["TUTORIAL_RETURN_FIRST_ACTION_SET"] = "Changes to your action bars are " .. h .. "automatically saved" .. r .. " to the currently equipped action set, which is indicated by a check-mark.\n\nTry " .. h .. "removing a spell" .. r .. " from one of the action buttons you had previously selected, then " .. h .. "equip" .. r .. " the first action set you had made by " .. h .. "left-clicking" .. r .. " it in the list and then clicking the " .. h .. "Equip" .. r .. " button.\n\nYou should find that the original action is restored to its slot."
L["TUTORIAL_ACTION_SET_TIPS_HEADER"] = "Action Sets Are Equipped Per-Spec!"
L["TUTORIAL_ACTION_SET_TIPS"] = "Be aware that you can have a " .. h .. "different" .. r .. " action set equipped under each talent spec (primary / secondary).\n\nOr, you could equip the SAME action set under both specs, such that any changes made in one spec are " .. h .. "automatically applied to the other" .. r .. "!\n\nThis allows you to create a set of " .. h .. "spec-independent" .. r .. " action buttons that contain your professions, mounts, and any other actions you don't want to have moved when you switch specs.\n\nClick " .. h .. "Next" .. r .. " to continue."
L["TUTORIAL_ACTION_SET_TIPS_2_HEADER"] = "Button Sets vs. Action Sets"
L["TUTORIAL_ACTION_SET_TIPS_2"] = "Don't confuse action sets with button sets!  The typical setup is to have a " .. h .. "single button set" .. r .. ", containing several action sets - one for each spec.\n\nPersonally, I have two button sets - labeled " .. g .. "Main" .. r .. " and " .. g .. "Shared" .. r .. " - where the Main button set contains action sets named " .. g .. "Fire" .. r .. ", " .. g .. "Arcane" .. r .. ", and " .. g .. "Frost" .. r .. " (since my character is a mage).\n\nThe purpose of having multiple button sets is to be able to " .. h .. "equip multiple action sets in parallel" .. r .. ".  You probably won't need to create more than one, though, unless you want to share a set of actions across specs like I do."
L["TUTORIAL_VIEW_BACKUPS_HEADER"] = "Viewing Backups"
L["TUTORIAL_VIEW_BACKUPS"] = "ActionSwap 2 also keeps backups for each set you create, allowing you to revert your action bar to a previous state, should you wish to.\n\nHover the mouse over any action set, and then click the " .. h .. "View Backups" .. r .. " button that appears."
L["TUTORIAL_CREATE_MANUAL_BACKUP_HEADER"] = "Creating a Backup"
L["TUTORIAL_CREATE_MANUAL_BACKUP"] = "This frame displays all backups for the currently selected action set.  There are two types of backups:\n\n" .. h .. "Automatic backups" .. r .. " are created and deleted automatically over time.\n\n" .. h .. "Manual backups" .. r .. " are created manually and last forever or until you choose to delete them.\n\nClick the " .. h .. "New Backup" .. r .. " button now to create a new manual backup of this action set."
L["TUTORIAL_CLICK_GLYPH_SETS_BUTTON_HEADER"] = "Glyph Sets"
L["TUTORIAL_CLICK_GLYPH_SETS_BUTTON"] = "You can also use this addon to swap glyphs in much the same way as actions.\n\nClick the " .. h .. "Glyph sets" .. r .. " button to continue."
L["TUTORIAL_FIRST_GLYPH_SET_HEADER"] = "Creating a Glyph Set"
L["TUTORIAL_FIRST_GLYPH_SET"] = "Using the same technique you've already learned for action sets, " .. h .. "create a new glyph set" .. r .. "."
L["TUTORIAL_SECOND_GLYPH_SET_HEADER"] = "Creating a Second Glyph Set"
L["TUTORIAL_SECOND_GLYPH_SET"] = "Now, " .. h .. "create another glyph set" .. r .. "."
L["TUTORIAL_EQUIP_GLYPH_SET_HEADER"] = "Equipping Glyph Sets"
L["TUTORIAL_EQUIP_GLYPH_SET"] = "Now, " .. h .. "change one of your glyphs" .. r .. " (as you normally would - using the Glyphs tab of the talent pane), and then " .. h .. "re-equip" .. r .. " the first glyph set you created.\n\nThough the change to the original glyph won't be automatic (due to Blizzard restrictions), ActionSwap 2 will tell you exactly how to place your glyphs to match the set being equipped.\n\nTry it and see!\n\n(Note: When equipping glyph sets, ActionSwap 2 doesn't care where each glyph is placed, as long as it is present.)"
L["TUTORIAL_TALENT_SETS_HEADER"] = "Talent Swapping"
L["TUTORIAL_TALENT_SETS"] = "You can also use ActionSwap 2 to " .. h .. "swap sets of talents" .. r .. "!\n\n" .. h .. "Talent sets" .. r .. " work in almost exactly the same way as glyph sets.\n\nTry it out if you'd like, then click " .. h .. "Next" .. r .. " to continue."
L["TUTORIAL_KEYBINDING_SETS_HEADER"] = "Keybinding Swapping"
L["TUTORIAL_KEYBINDING_SETS"] = "You can also use ActionSwap 2 to swap your keybindings through one of two techniques.\n\nThe first is to check " .. h .. "'Also swap keybindings'" .. r .. " while a button set is selected.  Any keys associated with those action buttons will be swapped along with the action set.\n\nYou could also use " .. h .. "keybinding sets" .. r .. ", which save ALL keybindings, including those that aren't bound to action buttons (like your movement keys).\n\nBest of all, either one of these approaches can be used to " .. h .. "bind keys differently for each spec" .. r .. "!\n\nChoose whichever approach best suits you, or mix and match!  Keybinding sets won't include keys that are bound to an action set.\n\nClick " .. h .. "Next" .. r .. " to continue."
L["TUTORIAL_END_HEADER"] = "The End"
L["TUTORIAL_END"] = "This concludes the ActionSwap 2 tutorial!  I hope you've gained a basic understanding of the addon and have developed some ideas about what it can do for you!\n\nEnjoy!\n\n\n\nClick " .. h .. "Finish" .. r .. " to complete the tutorial series."
L["Next"] = true
L["Close"] = true
L["Finish"] = true
L["Tutorial"] = true

-- Chat command text
L["CHAT_COMMAND_1"] = "as2"
L["CHAT_COMMAND_2"] = "actionswap2"
L["COMMAND_SHOW"] = "show"
L["COMMAND_EQUIP"] = "equip"
L["COMMAND_EQUIP_PREFIX_ACTION_SET"] = "action set "
L["COMMAND_EQUIP_PREFIX_GLYPH_SET"] = "glyph set "
L["COMMAND_EQUIP_PREFIX_TALENT_SET"] = "talent set "
L["COMMAND_EQUIP_PREFIX_KEY_SET_1"] = "keybinding set "
L["COMMAND_EQUIP_PREFIX_KEY_SET_2"] = "key set "
L["COMMAND_TUTORIAL"] = "tutorial"
L["COMMAND_RESET"] = "reset"
L["SYNTAX"] = "Syntax:\n/as2 - opens the main window\n/as2 equip set1[, ...] - equips sets by name"
L["SYNTAX_EQUIP"] = "Syntax: /as2 equip set1[, set2[, ...]]"
L["SYNTAX_TUTORIAL"] = "Syntax: /as2 tutorial [reset]"
L["MORE_THAN_ONE"] = "More than one set has the name \"%s\""
L["LESS_THAN_ONE"] = "Can't find a set with the name \"%s\""

-- Error messages
L["ERROR_NO_LAIS"] = "ActionSwap 2 requires LibAdvancedIconSelector-1.0 to be installed and enabled!"
L["ERROR_OLD_LAIS"] = "You are using an old, incompatible version of LibAdvancedIconSelector-1.0 - please update it!"
L["APPLY_FAILED"] = "Apply failed.  Trying again..."
L["APPLY_FAILED_IN_COMBAT"] = "Apply failed (in combat).  Trying again..."

-- Several simple abbreviations, for when LibKeyBound-1.0 isn't available.
L["NUMPAD-S"] = "NUMPAD"
L["NUMPAD-T"] = "N-"
L["CTRL-S"] = "CTRL%-"
L["CTRL-T"] = "C-"
L["ALT-S"] = "ALT%-"
L["ALT-T"] = "A-"
L["SHIFT-S"] = "SHIFT%-"
L["SHIFT-T"] = "S-"
