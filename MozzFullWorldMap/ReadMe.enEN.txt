General Description
------------------------

MozzFullWorldMap is simple: it adds a new checkbox in the upper left of the  world map named 'Show Unexplored Areas'. Checking it will do just that...  make the areas you have not explored yet on the map visible to you. This  AddOn also adds a "MozzFullWorldMap" section to the "Interface > AddOns"  interface options window (press 'Escape' and select the "AddOns" tab) you can use to set the MFWM options and colors (see notes below)

The default settings mean that unexplored areas appear with a blue/green tinge. I believe this setting is the most useful as it means that you can see all the details of the map, while still being able to identify which areas you have not yet explored. You can change the behavior of the AddOn via the Slash commands detailed below, and remove the blue tinge completely, leaving you with a standard view of each map as though you had already explored every area.

Key binding available for users of AlphaMap / Cartographer / MetaMap

NOTE : The key binding is disabled while the World Map is open - unless the  World Map has been modified by another AddOn such as AlphaMap)

MFWM is compatible with:

    WorldMapFrame
    AlphaMap
    MetaMap (you should disable MetaMapFWM if using this AddOn)
    Cartographer (you should disable Foglight if using this AddOn)
    nUI5
    This AddOn is built directly into nUI6 and does not (should not) need to be installed as a separate addon when using nUI6.

MFWM uses a hard-coded set of overlay data which duplicates data available in the client.  Since it also queries the client to find out which overlays have been discovered (should be 100%) it will detect discrepancies in the client data  and record any mismatched or not-present data in a saved Errata table. If you have errata saved, it will print a message at logon with instructions on how to submit your errata to the author so it can be added to the distribution, or you can add the errata to your own copy. You do not have to do either... MFWM will automatically merge your errata with its cached data so all of your  characters benefit from it without you having to take any action.

Original written by Mozz, updated by Shub, then Telic and then rewritten and currently kept alive by K. Scott Piel (spiel2001).

Technical Support
----------------------

If you area having a problem with MozzFullWorldMap, would like to make a  suggestion, would like to upload errata data, or report a bug, please visit http://forums.nUIaddon.com -- If you do not already have an account at  WoWInterface, you can create one for free. Note that WoWI will send you an  e-mail with a link in it that you have to click to confirm your email address  before you can start to post in the forum. If you don't see that message,  please check your spam folder.

Once you have an account at WoWInterface.com and you have verified your email address, you will find a topic specifically set up for support of MFWM at the http://forums.nUIaddon.com address. All feedback, suggestions, bug reports and errata submissions are always welcome. You will also find a large community of nUI and MFWM users in these forums who are always happy to help even when I am not available.

Please show your support of MFWM!
---------------------------------------------

If you find MozzFullWorldMap useful, and a benefit to your game, I sincerely hope you'll take a moment to visit http://www.nUIaddon.com and created an account there. You can keep up with updates to nUI, MozzFullWorldMap and Party Spotter via the free newsletter (which will never spam you and is never shared  with anyone). You can also make donations to the author via the site and subscribe for premium services such as direct updates via e-mail, a premium member's only download area to avoid patch day madness, and more. Your donations are truly appreciated and are the fuel that keeps the geek slaving away for you ~smile~

Slash Commands
--------------------

/mfwm    -- displays the MFWM option settings window

* * * * * * * * * * * * * * * * * * * * * * * *

Configuration options:

Using the '/mfwm' command will open the MozzFullWorldMap configuration screen. You can also open this screen by pressing 'Escape' in-game, then select the "Interface" menu option and click the "AddOns" tab. MozzFullWorldMap will  appear on the left side of the menu... click that to open the options screen.

The following map display configuration options are supported....

1)  "Reveal unexplored areas on the map"

    ---- enabled by default

    When checked, MFWM will show area on the map that your character has not yet explored. Normally the areas you have not explored are hidden. Turning this option off will make the map behave like the default Blizzard World Map does.

2)  "Highlight all cached data on the map"

    ---- disabled by default

    This option is used to help you see what data MFWM knows about the world map and what data you have as errata in your saved variables. When it is selected, MFWM will display every area it knows about in an emerald color and all of your errata in a red color. This is done regardless of what areas your character(s) have and haven't discovered and regardless of what colors and transparency you have chosen. This option is intended as a tool to help understand what's "different" between what MFWM thinks it knows about the world map and what you have "seen" while exploring the world.

These options are provided for MFWM updating and debugging support...
    
3)    "Save current map cache to saved variables"

    ---- disabled by default

    When this option is enabled, MFWM will save the current map data cache, including both the known map data and the errata you have collected, into [ World of Warcraft > WTF > {account} > Saved Variables > MozzFullWorldMap.lua ] for updating the [ Interface > AddOns > MozzFullWorldMap > MapData.lua ] data set. This is the data used by MFWM when you are in-game. You do *not* have to do this. It is only required for updating the MFWM map data when there is new world content or changes. Even then, players do not have to do this unless the "You have errata" message at login annoys them.    

4)    "Write debugging data to saved variables"

    ---- disabled by default

    This option should only be used by those familiar with programming and Lua as an aid to trying to figure out what MFWM is doing at runtime. When it has been enabled, MFWM will write text messages into the player's saved variables file in the MFWM_PlayerData.Debugging table. These messages will track the continents, zones, maps and overlays that MFWM is displaying along with colors and alphas as a debugging aid. The debugging table is cleared at the start of every login or reload and the data collected until logout or another reload saved to the MozzFullWorldMap.lua saved variables (nUI6.lua for nUI6 users). This can be a lot of data if you use the map a lot or open/close the map frequently. Generally, this option should always be turned off.    

5)    "Label the map panels for visual debugging"

    ---- disabled by default

    Like the previous option, this option is provided for those who are trying to sort out what MFWM is doing and why. It displays the name of the panel, the texture and the row/column of each overlay it draws as an aid in visually debugging what is being displayed where on the map. As with the debugging data option, this option should typically be turned off.

These are the map coloring options. Only one of these may be chosen at a time. Selecting any one of these three options will deselect the other two options and change the color settings...

6)    "Show unexplored areas without a tint"

    ---- not selected by default

    When this option is selected, the map is displayed using the normal map colors as though you have already explored the entire map regardless of whether or not you have discovered each zone in the map.    

7)    "Show unexplored areas in an emerald tint"

    ---- selected by default

    This is the default map coloring option and when selected displays the unexplored areas on the map in an emerald color. It still permits the user to see the detail in the unexplored areas of the map, but makes it clear which areas of the map have and have not been discovered.    

8)    "Use a custom color to tint unexplored areas"

    ---- not selected by default

    This option permits the player to choose their own color for displaying the unexplored areas of the map. When it is selected, the user can use the tint wheel and the red/green/blue sliders to choose a color to use. Note that when selecting the untinted or emerald tint options, any custom color the player may have chosen will be lost.    

There are four sliders in the configuration screen...

9)    "Set opacity for unexplored areas"

    ---- set to 100% opacity by default

    This slider adjusts the transparency of the unexplored areas of the map. Aside from being able to tint the unexplored areas with a color, you can also adjust how transparent it is. When the slider is fully to the right, the unexplored areas are fully opaque (displayed) and when it is fully to the left, they are fully transparent (invisible).    

10)    "Set the red value of the tint (R)"

    ---- set to 20% by default (emerald green)

    This slider is used to control the red component of the RGB coloring scheme for the tinting of unexplored areas. When fully to the right, the red component is set to its maximum value (red) and when fully to the left, the red component is set to 0 (black). This slider can only be modified when the "Use a custom color to tint unexplored areas" option has been selected. When the option to use no tint or and emerald tint is enabled, this bar displays the red component of the selected predefined tint.    

11)    "Set the green value of the tint (R)"

    ---- set to 60% by default (emerald green)

    This slider is used to control the green component of the RGB coloring scheme for the tinting of unexplored areas. When fully to the right, the green component is set to its maximum value (green) and when fully to the left, the green component is set to 0 (black). This slider can only be modified when the "Use a custom color to tint unexplored areas" option has been selected. When the option to use no tint or and emerald tint is enabled, this bar displays the green component of the selected predefined tint.    

12)    "Set the blue value of the tint (R)"

    ---- set to 100% by default (emerald green)

    This slider is used to control the blue component of the RGB coloring scheme for the tinting of unexplored areas. When fully to the right, the blue component is set to its maximum value (blue) and when fully to the left, the blue component is set to 0 (black). This slider can only be modified when the "Use a custom color to tint unexplored areas" option has been selected. When the option to use no tint or and emerald tint is enabled, this bar displays the blue component of the selected predefined tint.

13)    Color Wheel

    Aside from the sliders for red, green and blue, the MFWM configuration window also provides a color wheel which can be used to select a color by clicking inside the wheel and dragging the mouse around the wheel to change colors. As you move the mouse, the red, green and blue sliders will update to reflect the chosen color. Likewise, changing the value of the red, green and blue sliders will also change the location of the cursor in the color wheel, as will choosing the option to not use a tint or to use the emerald tint. The color wheel can only be changed when the "Use a custom color to tint unexplored areas" option is used.

* * * * * * * * * * * * * * * * * * * * * * * *

How to submit errata to the MozzFullWorldMap author:

If you find errors or missing data in the map (MFWM will print a message at  login telling you that you have map errata) and have time to help, please do the following:

First, check the download sites and make sure you have the most recent version of MFWM. The official distribution points for MFWM are (in order)

    http://www.nUIaddon.com
    http://www.WoWInterface.com
    http://www.curse.com
    http://wow.curseforge.com

Any other source of MFWM is *not* officially sanctioned (though permissible) and may or may not be correct or current.

If you have the most recent version of MFWM from one of those four sites, and you have map errata in your database, then you can do the following to lend a hand and submit your errata to the author so it may be included in future  releases...

Submit via e-mail...

    Exit the game
    Go to your [ World of Warcraft > WTF > {account} > Saved Variables ] folder
    E-mail the MozzFullWorldMap.lua file to kscottpiel@gmail.com
    (if you are using nUI6, send the nUI6.lua file instead of MozzFullWorldMap.lua)

Submit via the support forums...

    Exit the game
    Go to http://forums.nUIaddon.com and log in (create an account if you don't have one)
    Go to the MozzFullWorldMap support forum
    Create a new topic
    Click the paperclip icon in the message editor or scroll down to "Manage Attachments"
    Upload your [ World of Warcraft > WTF > {account} > Saved Variables > MozzFullWorldMap.lua ] file
    (if you are using nUI6, upload the nUI6.lua file instead of MozzFullWorldMap.lua)  

Note: The MozzFullWorldMap.lua file contains *NO* personal data. If you're using nUI6 and uploading the nUI6.lua file, that file does contain the names of the realms you play on, and the names of the characters in each realm, but it does not tie those names to your name, e-mail or account name and contains no other personal information.
     
* * * * * * * * * * * * * * * * * * * * * * * *

How to update your own data without an update:

The process of updating your cached data has been simplified in the MFWM 5.00.05.00  release. For all practical purposes, you just have to explore the world and the system will automatically collect the new information and merge it into your cache. The "errata" will be saved in your [ World of Warcraft > WTF > {account } > Saved Variables > MozzFullWorldMap.lua ] file (nUI6.lua for nUI6 users) and can be easily reviewed by viewing the file with any plain text editor... it will appear in the  MFWM_PlayerData.Errata table. This errata is automatically merged into the built-in map data at login and a message is printed to tell you that you have errata and how you can submit it to the author. Otherwise, you really don't have to do anything... once you've explored a "new" area on any of your characters, it will be properly  displayed for all of your other characters.

If you want to actually merge the errata into your known data, the easiest method is to use the '/mfwm' command to open your interface options panel and check the  "Save current map cache to saved variables" option, then click "Okay" and exit the game. Open your [ World of Warcraft > WTF > {account} > Saved Variables > WorldOfWarcraft.lua ] file with a plain text editor (nUI6.lua for nUI6 users). Locate the MFWM_PlayerData table and the MapData table in it. Copy all of the data from MFWM_PlayerData.MapData over top of the MFWM.MapData table in the [ Interface > AddOns > MozzFullWorldMap > MapData.lua ] file ( Interface > AddOns > nUI6 > Features > MozzFullWorldMap > MapData.lua for nUI6 users) then save and close the MapData.lua file. After you have copied that table, delete the data in the MFWM_PlayerData.Errata table in the MozzFullWorldMap.lua (nUI6.lua) saved variables file and save the file. Log back into the game and check the maps... they should be correct now. Once again, use the '/mfwm' option to open the options screen, turn off the "Save current map cache to saved variables" option and click "Okay" -- you are ready to resume play.