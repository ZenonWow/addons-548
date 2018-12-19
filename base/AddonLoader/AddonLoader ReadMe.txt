http://www.wowpedia.org/AddonLoader
--
AddonLoader is a load manager, which can be used by addons to load them conditionally. For example an addon that only manages a Hunter's pets does not ever need to be loaded on a non-Hunter. AddonLoader allows the developer to specify certain load conditions for their addons, allowing them to be intelligently loaded on demand.

Contents
1	Download
2	Usage (as a player)
3	Usage (as a developer)
3.1	Enabling AddonLoader
3.2	Special Fields
3.3	Load Conditions
Download
AddonLoader can be downloaded at the following locations:

Curse.com
WowInterface.com
Usage (as a player)
Simply having AddonLoader present should cover your needs. There are some options that can be accessed through /addonloader for overriding an addon's load condition.

 Never disable AddonLoader in the addon list - it will make all AddonLoader-aware addons stop loading. If you no longer want AddonLoader, you need to delete it.
Usage (as a developer)
AddonLoader allows you to specify certain conditions under which your addon will be loaded. It also enables you to run blocks of code without ever having your addon loaded, all by parsing the metadata in your table of contents file. Conditions are completely self-contained and do not interact with one another. Currently there is no way to (for example) specify by using simple metadata that your addon should only load for a certain class that is also over a certain level. You could accomplish this using an execute block instead.

Enabling AddonLoader
## LoadManagers: AddonLoader
This line in your TOC file tags your addon as LoadOnDemand, and assigns responsibility for loading it to AddonLoader. Warning - if AddonLoader is disabled in the addons panel, your addons will not load at all. If you don't wish to use AddonLoader, you must delete it's folder from the Addons folder.

Special Fields
## X-LoadOn-Events: UNIT_SPELLCAST_START, UNIT_MANA
## X-LoadOn-UNIT_SPELLCAST_START: if select(4,...) == 'player' then AddonLoader:LoadAddOn('MyAddOn') end 
## X-LoadOn-UNIT_MANA: if select(4,...) == 'player' then AddonLoader:LoadAddOn('MyAddOn') end 
Specify events to register for. You must specify event reaction code for each event.

## X-LoadOn-Hooks: GameTooltip_SetDefaultAnchor, ChatFrame_OnEvent
Specify functions that are to be securely hooked. Other than that, works like Events above.

## X-LoadOn-Execute: ChatFrame1:AddMessage('MyAddOn is present, but not yet loaded')
This code will execute on login regardless of if the addon is loaded or not. Use this if you need to specify complicated loading circumstances like function hooks. Note that toc fields are limited to about 1000 characters, if you must go over that amount, use X-LoadOn-Execute2 etc. Multiples get concatenated together and executed as one.

## X-LoadOn-Slash: /myaddon, /myadd
This specifies a slash command to register when your addon is not loaded. When the command is used by the player, your addon will be loaded, then the typed command will be issued again, so that options can be accessed if your addon's load condition hasn't yet fired.

AddonLoader will register three things for each slash command given:

SLASH_MYADDON1
SlashCmdList["MYADDON"]
hash_SlashCmdList["/myaddon"]
...
SLASH_MYADD1
SlashCmdList["MYADD"]
hash_SlashCmdList["/myadd"]
When your addon loads you should make sure to nil these out before you load your slash commands, otherwise you can run into problems with your slash commands not being used. (If AddonLoader happens to be the agency loading your addon (through a slash command or any other trigger), then it will nil these out for you before loading.)

## X-LoadOn-LDB-Launcher: Interface\AddOns\myAddon\icon
## X-LoadOn-LDB-Launcher: Interface\AddOns\myAddon\icon myAddonLauncher
This works similar to the slash loader, except with LDB launchers. AddonLoader will create an LDB launcher for your addon and set its OnClick action to load your addon, then call the new OnClick handler your addon creates. This also means your addon must handle the LDB dataobj carefully, to ensure it is declared correctly for users with and without AddonLoader installed.

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("myAddonLauncher") or ldb:NewDataObject("myAddonLauncher", {type = "launcher", icon = "Interface\\AddOns\\myAddon\\icon"})
dataobj.OnClick = function(self, button) dosomethingonclick(button) end
The second arg is optional, if not present your addon's name will be used for the dataobject name. Also note that texture paths in the TOC use "\" while paths declared in lua must use an escaped "\\"

## X-LoadOn-InterfaceOptions: My Addon
AddonLoader will add a category to the interface options -> Addons tab. Upon clicking the category your addon will be loaded and the category will be refreshed. The addon loading is responsible for adding a category with the same name registered in the X-LoadOn-InterfaceOptions field.

 -- In case the addon is loaded from another condition, always call the remove interface options
 if AddonLoader and AddonLoader.RemoveInterfaceOptions then
    AddonLoader:RemoveInterfaceOptions("My Addon")
 end
 -- now create our own contents
 local frame = CreateFrame("Frame", nil, UIParent)
 frame:Hide()
 frame.name = "My Addon"
 -- fill the frame with options
 InterfaceOptions_AddCategory(frame)
Load Conditions
## X-LoadOn-<tag>: <value(s)>
Tag	Value(s)	Description
Always	true	Load the addon unconditionally, use this to allow users to specify override behavior.
Always	delayed	Load the addon unconditionally, after the player has entered the world. Addons flagged delayed will get loaded sequentially on a timer, thereby reducing initial load time. Will NOT load addons during combat due to 5.2 CPU usage restrictions.
AuctionHouse	true	Load the addon when you go to the auction house.
Arena	true	Load the addon when you zone in to an arena.
Bank	true	Load the addon when you open your bank.
Battleground	true	Load the addon when you zone in to a battleground
Class	Priest, Paladin, Druid	Load the addon if the player is one of the specified classes. Note: only use English class names, comma-separated
Combat	true	Load the addon when you enter combat.
Crafting	true	Load the addon when the enchanting or tradeskilling frames are opened.
Group	true	Load the addon when you join a party or raid.
Guild	true	Load the addon if you are guilded.
Instance	true	Load the addon when you enter any PvE instance.
Level	35	Load the addon if the player is exactly level 35.
Level	25-	Load the addon if the player is under or at level 25.
Level	56-60	Load the addon if the player is between 56 and 60 (inclusive)
Level	65+	Load the addon if the player is at or above level 65.
Mailbox	true	Load the addon when you open the mailbox.
Merchant	true	Load the addon when you're at a merchant.
NotResting	true	Load the addon when you aren't resting.
PvPFlagged	true	Load the addon when you are PvP flagged.
Raid	true	Load the addon when you join a raid.
Resting	true	Load the addon when you're resting.
Zone	Duskwood, Stranglethorn Vale	Load the addon when the player is in one of the specified zones. Use English zone names only, comma-separated


