https://www.wowace.com/projects/ouf_freebgrid
--
Party/Raid unit frames using the oUF framework.

Units Supported:
-- party
-- raid
-- maintanks
-- pets and vehicles

Features:
-- Class corner indicators
-- Raid (de)buffs icons with priority
-- Class dispel icons
-- Aggro highlighting
-- Mouseover highlight
-- Out of range arrow
-- Range alpha
-- Heal Predication bar and/or text
-- Alt Power text
-- Health text - percent, deficit or actual
-- Vertical and horizontal layouts
-- Mana bars
-- Target and Focus border
-- AFK / DC timer
-- SharedMedia support
-- oRA3 tank support

FAQs
/freeb will unlock the frames
/freeb <something> will open the interface panel.

oUF is included in this addon but it is only accessible to Freebgrid.

Q: How do I create new indicators?
A: Edit tags.lua (some lua skills required). I've added at least one indicator to every healing class, so you can use those as an example(always open to suggestions).  Then add the tag name to your class table at the bottom of the tags.lua.

Q: How do I add raid (de)buffs?
A: Use the aura_list.lua file to add spell names or GetSpellInfo(spellid) to the aura table and set a priority number >= 1(Higher numbers show over lower).

Most of the general setting can be done in the interface panel and usually requires a ReloadUI when your done.

