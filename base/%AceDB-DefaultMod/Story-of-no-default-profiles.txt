Researched the forums for the reason of not defaulting to Default profile.
--
At the start of Jan 2007 AceDB-2.0 has been upgraded to be location independent.
This changed the profile keys from  `[charactername] of [servername]`  to  `[charactername] - [servername]`.
As there was no automatic migration of profile keys, the loaded profiles reverted to the Default.
Settings were still there, people needed to change the loaded profile, but they did not find it and had to remake their settings.
There was a major backlash and AceDB-3.0 now defaults to character profile, not by its own fault.
Oddly enough using character-specific profiles would not have prevented the loss of settings,
as a new character profile would be created after the profile key changed.
The fix would have been a instant patch to migrate the profile keys.
People instead blamed the result and dropped Default profiles.




https://www.wowace.com/projects/ace3/issues/293
- AceDB - Expanded profile control
- addon: OrderHallCommander

https://authors.curseforge.com/search?search=default+profile
For a discussion on how to implement this and why it is not the default behaviour (after AceDB-2.0 worked like this):
https://authors.curseforge.com/forums/world-of-warcraft/addon-chat/frameworks/ace3/209666-acedb-and-default-profiles-picking-a-bone?page=2
https://authors.curseforge.com/forums/world-of-warcraft/addon-chat/frameworks/ace3/209442-on-profiles-and-defaults
https://authors.curseforge.com/forums/world-of-warcraft/addon-chat/addon-help/211916-use-default-profile-instead-of-a-new-character

Different issue with AceDB-2 when used profile reverted back from char-specific to default. Can this be the reason for AceDB-3's non-defaulting?
https://authors.curseforge.com/forums/world-of-warcraft/official-addon-threads/general-addons/216915-profile-saved-variable-issues-after-recent-acedb?page=2

https://authors.curseforge.com/forums/world-of-warcraft/official-addon-threads/general-addons/216915-profile-saved-variable-issues-after-recent-acedb?comment=15ű
--
#15 Jan 6, 2007
deluXE
AceDB-2.0 has been upgraded to be location independent. It's not a bug, it's a feature. ;)
Yeah, I was checking the change log and they changed the way Ace2 stores the various profiles. You just need to fix a few things and everything will be fine. Hopefully...


https://authors.curseforge.com/forums/world-of-warcraft/official-addon-threads/general-addons/216915-profile-saved-variable-issues-after-recent-acedb?comment=25
--
25 Jan 6, 2007
dlr554
Looks like the profiles were changed. In SCT, my profiles used to be [charactername] of [servername], now it's [charactername] - [servername].



https://authors.curseforge.com/forums/world-of-warcraft/addon-chat/frameworks/ace3/209458-standard-options-for-profile-management?comment=9
--
Feb 13, 2008
Mikk
http://jira.wowace.com/browse/ACE-140



https://authors.curseforge.com/forums/world-of-warcraft/addon-chat/frameworks/ace3/209458-standard-options-for-profile-management?comment=19
--
19 Apr 8, 2008
Bam
Imo "Default" should be the default profile and addons that have a good reason to use character specific profiles should have to specify this themselves.
I agree, but it has already been voted down: http://jira.wowace.com/browse/ACE-114




https://authors.curseforge.com/forums/world-of-warcraft/addon-chat/frameworks/ace3/209523-acedb-switch-profiles-when-user-changes-spec?comment=37
--
37 Jun 3, 2009
Phanx
Posts: 8,503
The problem with all of the comments to the effect that "any author who isn't a moron can easily implement this himself" is that many authors simply won't do it, either because they don't want to put in the five minutes it would take to do it, or because they don't personally need it for their class or spec and don't think anyone else should need it either.

For one example, Auracle is a customizable debuff monitor. My restoration shaman has absolutely no use for debuff monitoring, while for my elemental secondary spec, I do like to track my own Flame Shock. Auracle does not offer any way to use separate profiles per spec, so I have to remember to manually open the configuration, navigate to the profile sub-panel, and switch to the other profile each time I switch specs. Frequently, I forget to do this, and end up with a huge unwanted "OMG FLAME SHOCK IS MISSING!!1" icon in the middle of my screen while healing, or realize halfway through Malygos when my Lava Burst fails to crit that I let my Flame Shock fall off because my Flame Shock tracker wasn't up. The author of Auracle has stated several times, in response to user requests, that he has no plans to add spec-based profile switching. Why? I have no idea. But if spec support were in AceDB, this wouldn't be a problem. He wouldn't have to want to add it, or spend time adding it. It would just be there.

Other addons that I can think of off the top of my head where I would love to have spec-based profile switching include:
Grid - I can't even dispel the same things between specs
BigWigs - while healing I don't need to see most alerts for most bosses, but I do need to see them while DPSing
Omen - I don't need to worry about threat while healing
RatingBuster - I care about different stats for different specs

The problem with "add it to Reflux!" is that not everyone has or wants Reflux. It's pretty silly to ask hundreds of thousands of users to go download an extra addon to get the same functionality that's present in the default UI, when it could be added to the majority of popular addons simply by adding a few lines of code to commonly used libraries.

This isn't a "rights of authors vs. demands of users" argument either. As an author, if I were in charge of AceDB/AceDBOptions, I would see no problem with adding support for dual specs. As a user, I am annoyed on a daily basis by dozen addons that are too stupid to notice when I switch specs. In my view, there is no "vs." because my conclusion from both viewpoints is the same.

As for the "not all addons support switching profiles without reloading the UI", I'm not even sure how you can call that an argument. That's a problem with those addons; there is absolutely nothing that cannot be changed without a UI reload. If changing profiles requires changing something that can't be done in combat, then if the user switches profiles while in combat, the addon should queue the switch until combat ends. If an addon isn't doing that (historically, PitBull has been a major offender in this category), I would call that a bug in that addon and a failing on the part of its author(s), not an argument against adding a useful feature to AceDB.

And finally, to rebut the argument that "most addons don't need spec switching", that's true, but most addons don't need profiles at all, yet almost all addons that use an Ace3 library support profiles. Some even force profiles on the user by defaulting to character-specific profiles, and a few of those don't even allow the user to switch away from character-specific profiles. If you're the author of an addon that uses AceDB and defaults to character-specific profiles, you have almost certainly have zero room to argue against adding spec awareness to AceDB. :p



https://authors.curseforge.com/forums/world-of-warcraft/addon-chat/frameworks/ace3/209523-acedb-switch-profiles-when-user-changes-spec?comment=57
--
57 Jun 8, 2009
Adirelle
Ok, so I polished it at bit more, removed the Ace2 support ("let old things die"), renamed it to something more pragmatic but less poetic and finally published it on wowace : LibDualSpec-1.0 (still waiting for approval at the time of this post).




