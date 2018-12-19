INSTRUCTIONS
--
Install the AddOn and enter your Keybindings settings, you will find "Combat Mode" listed there.
Map the toggle key to a key of your choice to enable Combat Mode.
Pressing the Combat Mode hotkey will TOGGLE on and off.
When toggled off, your mouse buttons are remapped to what they were originally.
You may also use the HOLD keybind to enable or disable combat mode quickly.
https://www.youtube.com/watch?v=X_IetKjlQdI

 
Features:
--
Handles Ground Targeting Skills (Releases cursor, returns after cast)
Handles Pet Casting / Move abilities (Releases cursor, returns after cast)
Mappable toggle and hold keys for Combat Mode
Mappable mouse clicks, shift and control clicks
Automatically releases the mouse cursor when specific frames are visible (Quest Text/Map/Bags etc) and returns to combat mode.   For example, you can open your bags, your mouse cursor is available and close them without having to re-enable Combat Mode.  This also works for questing.
Smart Targeting -- Mouse1 has two functions while in Combat Mode.  If you have a friendly NPC selected, you may click Mouse1 again to interact.  If you're not in range, you will be able to select another NPC with Mouse1.
Mouse1 and Mouse2 while in Combat mode have new functionality


DEFAULT CONTROLS in Combat Mode
--
Mouse1 SMART TARGETING*: Target Nearest Friend / Interact Target
Mouse2: (Hold) Target Scan Enemy
Control+Click: Target Nearest Friend
Shift+Click: Target Previous Friend


KEYBINDING MOUSE CLICKS
--
Simply type /cm or /combatmode or enter Interface Options -> Combat Mode


Features in Progress
--
Bugfixes
Smart Targeting Feature
Expand Smart Targeting to include other abilities than INTERACT
Smart Target Toggle (Disable Feature Option)
Improve detection of frames and interactions
Display user feedback when combat mode is toggled
Input instructions into combat mode bindings page


Added Compatibility With
--
Immersion
https://wow.curseforge.com/projects/immersion
BagNon
https://www.curseforge.com/wow/addons/bagnon
GW2-ui
https://www.curseforge.com/wow/addons/gw2-ui


ChangeLog
--
1.3.1 Found and fixed some edge cases where combat mode doesn't release cursor
1.3.0 Added additional keybinds
1.2.9 Quality of life update. (doesn't drop out when blocking frames are on screen)
1.2.8 Added ability to rebind or disable Smart Targeting feature
1.2.7 Rework of combatmode script, changed the way events are handled.
1.2.6 Hold to release bug should be fully resolved
1.2.5 Improved bug with Hold to Release which was introduced in 1.2.4, still happens on occasion
1.2.4 Fixed bug when dropping combat mode with pet ability enabled
1.2.3 Added support for Pet Move / Targeting abilities, releases cursor appropriately
1.2.2 Further debugging and restructuring
1.2.1 Bugfixes for Smart Targeting.  Jittery mouse issue resolved.
1.2.0 Added Smart Targeting to Mouse1 clicks while in combat mode, added Keybinds
1.1.0 Added Mouse Keybind support in Interface Options under "Combat Mode"
1.0.9 Updated Keybindings to fix issue with selecting friendly targets.  Fixed GW2-ui compatibility.
1.0.8 Updated Keybindings, added support for Transmogrification window
1.0.7 Added support for GW2-ui AddOn
1.0.6 Performance Enhanced for low CPU systems
1.0.5 Added HOLD keybind to activate or switch modes, Added support for BagNon AddOn
1.0.4 Fixed bindings issues
1.0.3 Improved efficiency, refactored to prepare for additional features
1.0.2 Fixed some typos
1.0.1 Added Immersion AddOn compatibility
1.0.0 Initial Release


References
--
Based on the seemingly abandoned  Mouse Look Lock:
https://wow.curseforge.com/projects/mouse-look-lock

Idea of dynamic Combat Mode (Mouselook) while move/strafe is pressed comes from  MouselookHandler:
https://wow.curseforge.com/projects/mouselookhandler
https://github.com/meribold/MouselookHandler

