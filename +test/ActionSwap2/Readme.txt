========================================================================================
    ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, talents,
	glyphs, and keybindings.
    
    Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
      Email: darthyl@hotmail.com
    
    All Rights Reserved unless otherwise explicitly stated.
========================================================================================

ActionSwap 2 is an addon to help you effectively triple spec by swapping out sets of actions, talents, glyphs, and / or keybindings.

Specifically, ActionSwap 2 can help you:
1) Save an inactive spec (actions, talents, glyphs, and keybindings)
2) Backup and restore your action bars / talents / etc. to a previous state
3) Share a set of actions between primary / secondary spec (i.e. mount buttons)
4) Keep different keybindings for primary / secondary spec
5) Recover buttons that WoW has automatically removed from your action bars (sometimes)
6) Transfer your action bars / talents / etc. to / from a PTR character

ActionSwap 2 is based on an old command-based addon called ActionSwap, but has been redesigned from the ground up to become the ultimate GUI-enabled spec-swapper!

 == Getting started: ==
1) Install and enable ActionSwap 2.
2) Type "/as2" when in WoW.  An interactive tutorial will guide you through the basics!
3) Type "/tutorial reset" if you want to restart the tutorial.

 == To save your inactive specs: ==
1) Create a button set and select some slots to save.
2) Create a new action set / talent set / glyph set for each spec you want to save. (NOT a new button set - see screenshots for an example)
3) Whenever you re-specialize at your trainer, equip the action set / talent set / glyph set that corresponds to the spec you are switching to.

You will obviously still have to pay the fee for respeccing, but your action bars, talents, and glyphs should be extremely easy to restore!

 == To share a set of actions between primary / secondary spec: ==
1) Create a button set containing at least one action set (and remember to select some slots).
2) Equip the same action set under each spec (primary & secondary).
Any changes made under one spec will automatically transfer to the other.
This can be done with other set types as well.

 == To keep different keybindings for primary / secondary spec: ==
(Note: This can also be done using keybinding sets)
1) Create a button set containing two or more action sets (and remember to select some slots).
2) Equip a different action set under each spec.
3) Enable "Also Swap Keybindings" for the button set.
The keybindings associated with each set will now be applied automatically upon spec change.

 == To back up your action bars: ==
Automatic backups are created and deleted automatically, but you can create manual backups too:
1) Move the mouse over the action set you want to back up.
2) Click the "Show Backups" icon that appears.
3) Click "New Backup".

 == To restore your action bars from backup: ==
1) Move the mouse over the action set containing the buttons you want to restore.
2) Click the "Show Backups" icon that appears.
3) Click the backup you want to restore.

 == To transfer settings to / from a PTR character: ==
1) Copy ActionSwap2.lua from one character's SavedVariables directory to another.
2) When you login on the target character, ActionSwap2 will warn you that it is recording changes.  Instead of keeping these changes, restore each set from the latest backup (one will have been created automatically before recording).
Exporting / importing individual sets is not yet supported.

 == To equip sets using a macro: ==
Syntax: /as2 equip [set-type] <set-name> [, ...]

Example macro to equip 4 sets simultaneously:
/as2 equip talent set Fire
/as2 equip glyph set Fire
/as2 equip action set Fire
/as2 equip key set Fire

If two or more sets have the same name, you must specify the set type.

 == Quirks: ==
- You shouldn't use the keybinding swapping features of ActionSwap 2 unless you have per-character keybindings enabled.
- If you use a paged action bar, key swapping may not work as expected unless all pages are assigned to the same button set as the first page.
- If you accidentally mess up your action bars, remember that backups are created for each set daily! (at effectively zero performance cost)
- The addon doesn't care which slot a glyph is placed in - just that it is present.

 == Check out my other addons: ==
AdvancedIconSelector - http://www.curse.com/addons/wow/advancediconselector
  Adds search functionality to Blizzard's icon selector dialogs along with icon keyword data and a resizeable frame!
