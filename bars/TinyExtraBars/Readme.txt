Yet another action bars addon. It is not replacement to standard action bars.


Changes:

1.16
fixed right click to set button from FlyoutButton Custom
minimap button's strata raised

1.15
"Renewing Mist" added to spells
"Ctrl+MiddleClick" to show/hide bars

1.11
using Shift now optional

1.10
separated configure dropdwon menu for Container and current Tab
alpha settings left per Container only
ClickThrough now separate for each Container

1.06
MacroText functionality moved to separate lib to provide same in FlyoutButton Custom

1.05
alpha slider for buttons added

1.04
optional global ClickThrough mode

1.03
fixed error on "configure" button click (caused by mass rename)

1.02
taint caused by glow functions finally fixed

1.01
keybind fixes

1.00
keybinds now set by button position, so for example button with position 1x1 will have same keybind in all frame tabs
reassign your keybinds if necessary

0.63
buttons can be dragged with Shift pressed

0.62
more restrictions to prevent dragging button while in combat or not in settings mode

0.60
fixed bars popup for not SettingsMode

0.59
toc changed for v5.3

0.58
yet another fix to Macrotext

0.57
Glow for macrotext spells

0.56
Minimap Button Frame compatible

0.55
slash commands "/teb" or "/tinyextrabars" to show/hide tools window

0.54
changes to reflect bag updates when tracking item's amounts

0.53
item's icons can be used in macrotext (drag and drop item)
buttons using items through id instead of names

0.52
more macrotext customizations: spell to represent macrotext can be dragged from spellbook, custom icon can be set
button's tooltip to configure macrotext was changed from "Configure" to "Macrotext"

0.51
if macrotext field is empty will be used tooltip for spell from "Icon by spell name"
macrotext and macro: spellcharges, IsUsable, SpellEffect

0.50
taint fixes
settings for LastEffect etc are now global
full range color option, search for "out of range color" in Button.lua to play with colors

0.46
tabs text's anchors fixed

0.45
battlepets

0.44
Tabs above frames
cooldowns with charges

0.43
toc changed for v5.1.0

0.42
fixes to LastEffect

0.41
macrotext spell name used to show icon also applied to calculate range and cooldown
escape sequences (see http://www.wowwiki.com/UI_escape_sequences) can be used in macrotext tooltips

0.40
now possible to create macrotext based buttons by using small wheel button to enter each button settings in "Settings Mode"

0.35
added "Presets" to copy bars between characters
LastEffect changes similar to changes in original "LastEffect"

0.33
tonumber for FindSpellId

0.32
preventing buttons movable while in combat
option to hide button's borders

0.31
optimized: looking for generic spells

0.30
fixes and changes
most of spell logic through generic names (fixed amount of charges, checked and usable)
LastEffect changes:
added several procs and auras for: mage, priest, dk, hunter, paladin
counter resets on next cast only

0.26
added (experimental):
last damage/heal as text (see "LastEffect mode" checkbox in settings)

0.25
text cleanup after equipment sets and count
fixed: macro buttons

0.24
fixes for non spell/item buttons

0.23
flash added
custom alpha on mouseleave

0.22
minimap size normalized

0.21
option to show/hide during PetBattle (default "hide")

0.20
fixes, fixes, fixes

0.19
fixed error on new tab

0.18
fixed bug on removing one only tab from newly created container
button to print current stance
message "will be loaded on leaving combat" if entering world in combat and unable to create buttons (due to late load of battlepet stuff)
keybind mode + support
Masque/Button Facade support

0.15
Added frame strata option
Done custom visibility option
Tab title edit option