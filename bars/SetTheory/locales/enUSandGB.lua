local L = LibStub("AceLocale-3.0"):NewLocale("SetTheory", "enUS", true)

if L then
	L["SetTheory Set"] = true
	L["Performs the actions of a SetTheory set"] = true

	L["Changes your active outfit"] = "Changes your active outfit"
	L["No Outfit"] = "No outfit by this name exists"
	L["Outfitter"] = "Outfitter"
	L["Outfit"] = "Outfit"
	L["Setting outfit"] = "You are now wearing outfit "
	L["Select which outfit you'd like to wear"] = "Select which outfit you'd like to wear"
	L["incomplete"] = "incomplete"
	L["banked"] = "banked"

	L["ItemRack"] = true
	L["Select which rack you'd like to wear"] = true
	L["Rack"] = true
	L["Changes your active rack"] = true
	L["Setting ItemRack rack to: "] = true
	L["No Rack"] = true
	
	L["Set Name"] = "Set Name"
	L["Select Set"] = "Select Set"
	L["Add Set"] = "Add Set"
	L["Sets"] = "Sets"
	L["Add a New Set"] = "Add a New Set"
	L["Global Sets"] = "Global Sets"
	L["You can also copy in a set from an external source (your other characters or from interface compilations)"] = "You can also copy in a set from an external source (your other characters or from interface compilations)"
	L["Global Set"] = "Global Set"
	L["Select a set you'd like to copy into your current character's set collection."] = "Select a set you'd like to copy into your current character's set collection."
	L["New name"] = "New name"
	L["Choose a new name for this set"] = "Choose a new name for this set"
	L["Copy Set"] = "Copy Set"
	L["Copies the selected set into your current character's set collection."] = "Copies the selected set into your current character's set collection."

	L['Your sets have been upgraded to a new database format. However, you should check your sets for errors, especially in Ace Profile actions. You can use "/settheory opts resetDB" to reset the database.'] = 'Your sets have been upgraded to a new database format. However, you should check your sets for errors, especially in Ace Profile actions. You can use "/settheory opts resetDB" to reset the database.'
	L["Reset Database"] = "Reset Database"
	L["Removes all of your defined sets and returns the options back to their default states."] = "Removes all of your defined sets and returns the options back to their default states."
	L["Are you sure you wish to reset your database?"] = "Are you sure you wish to reset your database?"


	L["Select a set"] = "Select a set"
	L["Publish set"] = "Publish set"
	L["This will make the set globally accessible. This is useful if you want to share a set with other characters on your account or if you intend to publish your interface for others to use."] = "This will make the set globally accessible. This is useful if you want to share a set with other characters on your account or if you intend to publish your interface for others to use."
	L["Remove Set"] = "Remove Set"
	L["SetTheoryDesc"] = "Use this dialog to define the name of a set, the set will be added to the list and you can then modify its properties"
	L["The name of the set"] = "The name of the set"
	L["Set Description"] = "A descriptive name for the set, e.g. 'Battlegrounds'"
	L["No Set"] = "No Set"
	L["Please choose a name for this set."] = "Please choose a name for this set."
	L["Please choose a unique name for this set"] = "Please choose a unique name for this set"
	L["Confirm remove set"] = "Are you sure you want to remove this set?"
	L["Selects this set"] = "Causes this set's actions to run"
	L["Select macro"] = "To select this set in a macro use the following command: "

	L["SetTheory Options"] = "SetTheory Options"
	L["Options"] = "Options"
	L["Print messages"] = "Print messages"
	L["Print out status messages when selecting a set."] = "Print out status messages when selecting a set."
	L["Show progress bar"] = "Show progress bar"
	L["Displays a progress bar when you switch to a new set."] = "Displays a progress bar when you switch to a new set."
	L["Hide spell changes"] = "Hide spell changes"
	L["Hide chat messages about lost or gained spells while processing a SetTheory set."] = "Hide chat messages about lost or gained spells while processing a SetTheory set."

	L["Respec prompt"] = "Respec prompt"
	L["Prompt to select a new set when you respec"] = "Prompt to select a new set when you respec"
	L["First Run"] = "First Run"
	L["SetTheory has been run for the first time. Would you like to activate a global set now?"] = "SetTheory has been run for the first time. Would you like to activate a global set now?"

	L["Keybind"] = "Keybind"
	L["Binds this set to a key"] = "Binds this set to a key"

	L["Adds and action"] = "Adds an action to this set which is activated when the set is selected"
	L["Add Action"] = "Add Action"
	L["Remove action"] = "Remove action"
	L["Removes this action from this set"] = "Removes this action from this set"
	L["Nothing to be done for action: "] = "Nothing to be done for action: "

	L["Available actions"] = "Available actions"
	L["Actions"] = "Actions"
	L["Possible actions"] = "Available actions"

	L["Left Click"] = "|cff8080ffClick|r to open SetTheory configuration"
	L["Right Click"] = "|cff8080ffRight click|r to select a different set"
	L["Shift-Right Click"] = "|cff8080ffShift-Right click|r to switch talent spec"
	L["Memory usage: "] = "Memory usage: "

	L["TrinketMenu"] = "TrinketMenu"
	L["Queueing profile X in slot Y"] = function(X, Y) return "Queueing profile "..X.." in "..Y.." slot" end
	L["Select which TrinketMenu queue you'd like to activate in which trinket slot"] = "Select which TrinketMenu queue you'd like to activate in which trinket slot. If you would like to change the queues of both trinket slots then you can create two TrinketMenu actions."
	L["Queue"] = "Queue"
	L["Changes the queue"] = "Changes the queue"
	L["Slot"] = "Slot"
	L["The slot you'd like to change"] = "The slot you'd like to change"
	L["Top"] = "Top"
	L["Bottom"] = "Bottom"
	L["13"] = "Top"
	L["14"] = "Bottom"

	L["ZOMGBuffs"] = "ZOMGBuffs"
	L["Select templates for different ZOMGBuffs modules"] = "Select templates for the different ZOMGBuffs modules"
	L["ZOMGSelfBuffs"] = "ZOMGSelfBuffs"
	L["Self buffs template"] = "Self buffs template"
	L["ZOMGBuffTehRaid"] = "ZOMGBuffTehRaid"
	L["ZOMGBlessings"] = "ZOMGBlessings"
	L["Raid buffs template"] = "Raid buffs template"
	L["Blessings template"] = "Blessings template"

	L["PowerAuras"] = "PowerAuras"
	L["Select which PowerAuras auras you would like to toggle on or off"] = "Select which PowerAuras auras you would like to toggle on or off, grey tick = no change, no tick = off and a tick = on.\nBecause of the way PowerAuras stores its auras these settings may become incorrect if you delete or move auras."
	L["Turned the following PowerAuras X: "] = function (X) return "Turned the following PowerAuras "..X..": " end

	L["Dual Spec"] = "Dual Spec"
	L["Primary"] = "Primary"
	L["Secondary"] = "Secondary"
	L["Select which spec you'd like to use"] = "Select which specialisation you would like to use"
	L["Spec"] = "Specialisation"
	L["Changes your active specialisation"] = "Changes your active specialisation"
	L["Setting X as your current talent group"] = function(X) return "Setting "..X.." as your current talent group" end

	L["Ace Profiles"] = "Ace Profiles"
	L["Select which addon's profile you'd like to use"] = "Select an addon whose profile you'd like to change."
	L["No Ace database here"] = "No Ace database here"

	L["Profile"] = "Profile"
	L["The profile you'd like to select"] = "The profile you'd like to select"
	L['Setting Ace profile for X to Y'] = function(X, Y) return 'Setting Ace profile for '..X..' to '..Y end
	L['Ace Addon'] = 'Ace Addon'
	L['Auto-detected Ace addon databases'] = 'Auto-detected Ace addon databases'

	L["Ace Toggle"] = "Ace Toggle"
	L["AceToggle"] = "AceToggle"
	L["Select which Ace addons you'd like to enable or disable"] = "Select which Ace addons you'd like to enable or disable"
	L["Equipment Manager"] = "Equipment Manager"
	L["Macro"] = "Macro"
	L["Local Macro"] = "Local Macro"
	L["Select a local macro to run"] = "Select a local macro to run"
	L["Global Macro"] = "Global Macro"
	L["Select a global macro to run"] = "Select a global macro to run"
	L["Turned the following Ace addons X"] = function(X) return "Turned the following Ace addons "..X end

	L['Talented'] = 'Talented'
	L["Select which Talented template you'd like to apply"] = "Select which Talented template you'd like to apply"
	L["Template"] = "Template"
	L["The talented template you'd like to apply"] = "The talented template you'd like to apply"
	L["Wait"] = "Wait"
	L["Use this action to create pauses in the action sequence. This is useful if your set's actions share multiple equipping items or you're equipping items and using the Dual Spec action."] = "Use this action to create pauses in the action sequence. This is useful if your set's actions share multiple equipping items or you're equipping items and using the Dual Spec action."
	L["Choose how long you'd like to wait for."] = "Choose how long you'd like to wait for."
	L["Pauses the action sequence for some seconds"] = "Pauses the action sequence for some seconds"
	L["Change action priority:"] = "Change action priority:"
	L["Move Up"] = "Move Up"
	L["+"] = "+"
	L["Move this action up in priority"] = "Move this action up in priority"
	L["Move Down"] = "Move Down"
	L["-"] = "-"
	L["Move this action down in priority"] = "Move this action down in priority"
	L["Processing actions"] = "Processing actions"
	L["Pausing the action sequence for X seconds"] = function(X) return "Pausing the action sequence for "..X.." seconds" end

	L["Dominos"] = "Dominos";
	L["The dominos profile you'd like to apply"] = "The dominos profile you'd like to apply";
	L["Select which Dominos profile you'd like to apply"] = "Select which Dominos profile you'd like to apply";

	L["TellMeWhen"] = "TellMeWhen"
	L["Select which TellMeWhen groups you'd like to enable or disable. Blank = disable, grey = no change, ticked = enable."] = "Select which TellMeWhen groups you'd like to enable or disable. Blank = disable, grey = no change, ticked = enable."
	L["Group X"] = function(X) return "Group ".. X end 
	L["Group "] = true;
	L["Enable or disable this TellMeWhen group."] = "Enable or disable this TellMeWhen group."
	L["Turned the following TellMeWhen groups on: "] = "Turned the following TellMeWhen groups on: "
	L["Turned the following TellMeWhen groups off: "] = "Turned the following TellMeWhen groups off: "

	L["XPerl"] = "XPerl"
	L["Loading XPerl layout: "] = "Loading XPerl layout: "
	L["Select which layout you'd like to use"] = "Select which layout you'd like to use"
	L["Layout"] = "Layout"
	L["Changes your active layout"] = "Changes your active layout"

	L["DoTimer"] = "DoTimer"
	L["Select which profile you'd like to use"] = "Select which profile you'd like to use"
	L["Changes your active profile"] = "Changes your active profile"
	L["Setting DoTimer profile to: "] = "Setting DoTimer profile to: "

	L["ACP"] = "ACP"
	L["Select which set of addons you'd like to use."] = "Select which set of addons you'd like to use."
	L["Set"] = "Set"
	L["Changes your addon set"] = "Changes your addon set"
	L["Reload"] = "Reload UI"
	L["Checking this will automatically reload your UI after selecting your addon set. It should only be checked if the ACP action is the last in the action sequence."] = "Checking this will automatically reload your UI after selecting your addon set. It should only be checked if the ACP action is the last in the action sequence."
	L["Load Type"] = true
	L["Changes how your addon set is loaded"] = true
	L["Replace current selection"] = true
	L["Add to current selection"] = true
	L["Remove from current selection"] = true

	L["Changes your action bar setup"] = true
	L["Setups"] = true
	L["Select which action bar setup you'd like to use."] = true
	L["Action Bar Saver"] = true
	L["ABS"] = true

	L["Lua"] = "Lua"
	L["Enter Lua code to be executed by this action."] = "Enter Lua code to be executed by this action."
	L["Any Lua code entered here will be executed by this action"] = "Any Lua code entered here will be executed by this action"
	L["Your Lua string executed sucessfully."] = "Your Lua string executed sucessfully."
	L["Encountered an error running your Lua string. Error: "] = ""

	L["Respec"] = "Respec"
	L["SetTheory has detected a respec. Would you like to apply a SetTheory set?"] = "SetTheory has detected a respec. Would you like to apply a SetTheory set?"
	L["Apply"] = "Apply"
	L["Cancel"] = "Cancel"

	L["Cancel Buff"] = "Cancel Buff"
	L["Select a current buff or type the name of a currently inactive buff you'd like to cancel"] = "Select a current buff or type the name of a currently inactive buff you'd like to cancel"
	L["Current buffs"] = "Current buffs"
	L["Select a currently active buff"] = "Select a currently active buff"
	L["Buff Name"] = "Buff Name"
	L["Type the name of the buff name."] = "Type the name of the buff name."
	L["Click the central button to remove "] = true

	L["secs"] = "secs"
	L["Done"] = "Done"

	L["KeyChange"] = "KeyChange"
	L["Key bind profile"] = "Key bind profile"
	L["Changes your active key bind profile"] = "Changes your active key bind profile"
	L["Select which key bind profile you'd like to apply."] = "Select which key bind profile you'd like to apply."

	L["Glyphs"] = "Glyphs"
	L["Select which glyphs you'd like to apply. You should select a glyph for each slot. This action requires you to press a button for each glyph you wish to apply and should go in an action sequence AFTER any Dual Spec swaps."] = "Select which glyphs you'd like to apply. You should select a glyph for each slot but they need not be in order, SetTheory will chose the best slots for your glyphs. This action requires you to press a button for each glyph you wish to apply and should go in an action sequence AFTER any Dual Spec swaps."
	L["Please press the buttons below to apply your glyphs."] = "Please press the buttons below to apply your glyphs."
	L["Majors"] = "Majors"
	L["Minors"] = "Minors"
	L["Primes"] = true
	L["Glyph of"] = "Glyph of"
	L["Glyph of "] = "Glyph of "
	L['Glyph1'] = "Top Major"
	L['Glyph2'] = "Bottom Minor"
	L['Glyph3'] = "Top Left Minor"
	L['Glyph4'] = "Bottom Right Major"
	L['Glyph5'] = "Top Right Minor"
	L['Glyph6'] = "Bottom Left Major"
	L['Click here to apply this glyph'] = 'Click here to apply this glyph'
	L['You cannot apply this glyph as you do not have one in your bags'] = 'You cannot apply this glyph as you do not have one in your bags'

	L['Possible triggers'] = "Possible triggers"
	L["Available triggers"] = "Available triggers"
	L["Add Trigger"] = "Add Trigger"
	L["Adds and trigger"] = "Adds and trigger"
	L["The spec to trigger on"] = "The spec to trigger on"
	L["Triggers"] = "Triggers"


	--Cataclysm
	L["Role"] = true;
	L["Select which role you'd like to fulfil."] = true;
	L["Changes your marked role in raids and groups."] = true;
	L["CharacterStats"] = true
	L["Choose which stat panes would would like to see and their order."] = true


end

