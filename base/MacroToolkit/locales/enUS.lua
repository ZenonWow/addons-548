local L = LibStub("AceLocale-3.0"):NewLocale("MacroToolkit", "enUS", true)
local _G = _G

if not L then return end

L["datetime format"] = "%b %d %H:%M:%S"
L["Last backup"] = true
L["Invalid command"] = true
L["Command removed"] = true
L["Required parameter missing"] = true
L["did you mean"] = true
L["Invalid condition"] = true
L["Invalid target"] = true
L["Argument not optional"] = true
L["Invalid argument"] = true
L["Arguments must be numeric"] = true
L["Arguments must not be numeric"] = true
L["Arguments must be alphanumeric"] = true
L["Not a macro command"] = true
L["Unmatched"] = true
L["Shorten"] = true
L["Macro shortened by %d characters"] = true
L["Macro shortened by %d character"] = true
L["Profiles"] = true
L["Override built in macro UI"] = true
L["Use syntax highlighting"] = true
L["Syntax Highlighting"] = true
L["Display errors"] = true
L["Text"] = true
L["Emotes"] = true
L["Scripts"] = true
L["Commands"] = true
L["Targets"] = true
L["Conditions"] = true
L["Author"] = true
L["Clear UI errors"] = true
L["Random non-combat pet"] = true
L["Enable sound effects"] = true
L["Disable sound effects"] = true
L["Set raid target"] = true
L["Exit vehicle"] = true
L["Print map coordinates"] = true
L["Toggle cloak"] = true
L["Toggle helm"] = true
L["Eject passenger"] = true
L["Insert special"] = true
L["Not enough space. Command requires %d characters (%d available)"] = true
L["Unknown parameter causes error"] = true
L["Unknown parameter"] = true
L["Raid marker"] = true
L["Insert slot"] = true
L["Backup"] = true
L["Delete Backup"] = true
L["Delete all macros"] = true
L["Manage Backups"] = true
L["Restore"] = true
L["Restore Backup"] = true
L["Are you sure? This operation cannot be undone."] = true
L["Sell grey items"] = true
L["Destroy grey items"] = true
L["No food buff"] = true
L["Well Fed"] = true
L["Food"] = true
L["No flask"] = true
L["Flask"] = true
L["Distilled"] = true
L["Report to"] = true
L["Enter a name for this backup"] = true
L["Macro Toolkit slash commands"] = true
L["Replace scripts with slash command"] = true
L["Replace known scripts with Macro Toolkit slash commands"] = true
L["Custom slash command"] = true
L["Enter script"] = true
L["Save failed"] = true
L["Script saved"] = true
L["Enter the name of the slash command"] = true
L["Command already defined elsewhere"] = true
L["Show custom commands"] = true
L["Custom Commands"] = true
L["Arguments can be accessed using the variables arg1 to arg4"] = true
L["Extend"] = true
L["Unextend"] = true
L["%d of %d characters used"] = true
L["Your macro will be truncated to 255 characters. Are you sure?"] = true
L["Toolkit"] = true
L["Enable UI errors"] = true
L["Disable UI errors"] = true
L["Question mark icon"] = true
L["Ability icons"] = true
L["Achievement icons"] = true
L["Inventory icons"] = true
L["Item icons"] = true
L["Miscellaneous icons"] = true
L["Spell icons"] = true
L["Icons"] = true
L["Control which icons are available to pick for macros"] = true
L["Share with"] = true
L["specific Macro Toolkit user"] = true
L["multiple Macro Toolkit users"] = true
L["chat channel"] = true
L["%s is trying to send you a macro. Accept?"] = true
L["Macro added"] = true
L["You have no more room for macros!"] = true
L["Press the key you wish to bind, or press 'Remove' to unbind the current macro"] = true
L["Buttons"] = true
L["Only display the following buttons"] = true
L["Full width macro editor"] = true
L["Display faction emblem"] = true
L["Display drake"] = true
L["The following must be unchecked in order to use the macro editor in full width mode"] = true
L["The following must be unchecked in order to display the faction emblem"] = true
L["The following must be unchecked in order to display the drake"] = true
L["The macro editor height can be increased by dragging the bottom of Macro Toolkit's frame downwards"] = true
L["Fonts"] = true
L["Editor font"] = true
L["Errors font"] = true
L["Macro name font"] = true
L["Macro label font"] = true
L["Size"] = true
L["Respond to the escape key"] = true
L["Key bind only"] = true
L["Extra macros that cannot be used on action bars"] = true
L["Copy an extended macro from another character"] = true
L["Copy Macro"] = true
L["Macro slots available"] = true
L["Macro copied"] = true
L["Make all character specific macros available to all characters"] = true
L["This may impact performance and loading time on low end machines"] = true
L["You will need to log into each of your characters with Macro Toolkit enabled to update Macro Toolkit's copy of that character's macros"] = true
L["This will remove Macro Toolkit's copy of all your character specific Macros. The macros themselves will not be affected."] = true

--conditions
L["Condition Builder"] = true
L["Additional conditions"] = true

--targets
L["target"] = true
L["targettarget"] = "target of target"
L["player"] = true
L["playertargettarget"] = "target of player's target"
L["pet"] = true
L["pettarget"] = "target of pet"
L["pettargettarget"] = "target of pet's target"
L["focus"] = true
L["focustarget"] = "target of focus"
L["focustargettarget"] = "target of focus' target"
L["mouseover"] = true
L["mouseovertarget"] = "target of mouseover"
L["npc"] = true
L["none"] = true
L["other"] = true
L["Enter target"] = true
L["Status of target"] = true
L["targetlasttarget"] = "Target last target"

--conditions
L["bar"] = "action bar"
L["bonusbar"] = "bonus bar"
L["btn"] = "mouse button"
L["channeling"] = true
L["nochanneling"] = "not channeling"
L["combat"] = "in combat"
L["nocombat"] = "not in combat"
L["cursor"] = true
L["dead"] = true
L["nodead"] = "alive"
L["exists"] = true
L["noexists"] = "does not exist"
L["extrabar"] = "extra bar"
L["flyable"] = true
L["noflyable"] = "not flyable"
L["flying"] = true
L["noflying"] = "not flying"
L["form"] = "form/stance"
L["group"] = true
L["harm"] = "hostile"
L["help"] = "friendly"
L["indoors"] = true
L["mod"] = "modifier key"
L["nomod"] = "no modifier key"
L["mounted"] = true
L["nomounted"] = "not mounted"
L["none"] = true
L["outdoors"] = true
L["overridebar"] = "override bar"
L["party"] = "in your party"
L["pet"] = true
L["nopet"] = "no pet"
L["petbattle"] = "pet battle"
L["possessbar"] = "possess bar"
L["raid"] = "in your raid group"
L["spec"] = true
L["stealth"] = "stealthed"
L["nostealth"] = "not stealthed"
L["swimming"] = "swimming"
L["noswimming"] = "not swimming"
L["unithasvehicleui"] = "target has a vehicle UI"
L["vehicleui"] = "player has a vehicle UI"
L["novehicleui"] = "player has no vehicle UI"
L["worn"] = "equipped"

--parameters
L["ctrl"] = true
L["alt"] = true
L["shift"] = true
L["LeftButton"] = "left mouse button"
L["MiddleButton"] = "middle mouse button"
L["RightButton"] = "right mouse button"
L["Button4"] = "mouse button 4"
L["Button5"] = "mouse button 5"