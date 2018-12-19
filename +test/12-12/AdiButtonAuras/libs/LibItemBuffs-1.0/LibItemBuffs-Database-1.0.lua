--[[
LibItemBuffs-1.0 - buff-to-item database.
(c) 2013-2014 Adirelle (adirelle@gmail.com)

This file is part of LibItemBuffs-1.0.

LibItemBuffs-1.0 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibItemBuffs-1.0 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibItemBuffs-1.0.  If not, see <http://www.gnu.org/licenses/>.
--]]

local version
local trinkets = {}
local consumables = {
	-- Special case: Alchemist's Flask
	[79638] = 75525,
	[79639] = 75525,
	[79640] = 75525,
}

local enchantments = {
	-- MoP enchantments

	-- Weapon (we assign it to the main hand weapon though it could come from the off-hand)
	[109085] = INVSLOT_MAINHAND, -- Engineering: Lord Blastington's Scope of Doom
	[118334] = INVSLOT_MAINHAND, -- Enchanting: Dancing Steel (agility)
	[118335] = INVSLOT_MAINHAND, -- Enchanting: Dancing Steel (strength)
	[104993] = INVSLOT_MAINHAND, -- Enchanting: Jade Spirit
	[116660] = INVSLOT_MAINHAND, -- Enchanting: River's Song -- NEED CONFIRMATION
	[116631] = INVSLOT_MAINHAND, -- Enchanting: Colossus
	[104423] = INVSLOT_MAINHAND, -- Enchanting: Windsong (haste)
	[104510] = INVSLOT_MAINHAND, -- Enchanting: Windsong (mastery)
	[104509] = INVSLOT_MAINHAND, -- Enchanting: Windsong (critical strike)

	-- Glove
	[108788] = INVSLOT_HAND, -- Engineering: Phase Fingers -- NEED CONFIRMATION
	[ 96228] = INVSLOT_HAND, -- Engineering: Synapse Springs, Mark II (agility)
	[ 96229] = INVSLOT_HAND, -- Engineering: Synapse Springs, Mark II (strength)
	[ 96230] = INVSLOT_HAND, -- Engineering: Synapse Springs, Mark II (intellect)

	-- Belt
	[131459] = INVSLOT_WAIST, -- Engineering: Watergliding Jets

	-- Cloak
	[126389] = INVSLOT_BACK, -- Engineering: Goblin Glider -- NEED CONFIRMATION
	[125488] = INVSLOT_BACK, -- Tailoring: Darkglow Embroidery, rank 3 -- NEED CONFIRMATION
	[125487] = INVSLOT_BACK, -- Tailoring: Lightweave Embroidery, rank 3
	[125489] = INVSLOT_BACK, -- Tailoring: Swordguard  Embroidery, rank 3 -- NEED CONFIRMATION

	-- Legendary meta gems
	[137593] = INVSLOT_HEAD, -- Indomitable Primal Diamond
	[137288] = INVSLOT_HEAD, -- Courageous Primal Diamond
	[137596] = INVSLOT_HEAD, -- Capacitive Primal Diamond
	[137590] = INVSLOT_HEAD, -- Sinister Primal Diamond
}

-- Anything below this line is generated with the extractor. Editing it is useless.
--== CUT HERE ==--
version = 20140903175145
-- Trinkets
trinkets[   835] =   1404 -- Tidal Charm
trinkets[  1139] =   5079 -- Cold Eye (Cold Basilisk Eye)
trinkets[  4079] =   4397 -- Cloaking (Gnomish Cloaking Device)
trinkets[ 10342] =   1490 -- Guardian Effect (Guardian Talisman)
trinkets[ 10368] =  11302 -- Uther's Light Effect (Uther's Strength)
trinkets[ 12438] =  18951 -- Slow Fall (Evonice's Landin' Pilla)
trinkets[ 12733] =  10418 -- Mithril Insignia (Glimmering Mithril Insignia)
trinkets[ 12766] =  10455 -- Poison Cloud (Chained Essence of Eranikus)
trinkets[ 13183] =  10727 -- Goblin Dragon Gun
trinkets[ 13237] =  10577 -- Goblin Mortar
trinkets[ 13278] =  10645 -- Gnomish Death Ray
trinkets[ 13744] =   2802 -- Blazing Emblem
trinkets[ 14530] =   2820 -- Speed (Nifty Stopwatch)
trinkets[ 15595] =  11810 -- Force of Will
trinkets[ 15601] =  11815 -- Hand of Justice
trinkets[ 15604] =  11819 -- Second Wind
trinkets[ 15646] =  11832 -- Burst of Knowledge
trinkets[ 16739] =   1973 -- Orb of Deception
trinkets[ 17275] =  13164 -- Heart of the Scale
trinkets[ 17330] =  13213 -- Poison (Smolderweb's Eye)
trinkets[ 18400] =  13379 -- Piccolo of the Flaming Fire
trinkets[ 18946] =  14557 -- The Lion Horn of Stormwind
trinkets[ 20587] =  15873 -- Ragged John's Neverending Cup
trinkets[ 21956] =  17759 -- Physical Protection (Mark of Resolution)
trinkets[ 21970] =  17774 -- Mark of the Chosen
trinkets[ 23097] =  18638 -- Fire Reflector (Hyper-Radiant Flame Reflector)
trinkets[ 23131] =  18634 -- Frost Reflector (Gyrofreeze Ice Reflector)
trinkets[ 23132] =  18639 -- Shadow Reflector (Ultra-Flash Shadow Reflector)
trinkets[ 23271] =  18820 -- Ephemeral Power (Talisman of Ephemeral Power)
trinkets[ 23506] =  19024 -- Aura of Protection (Arena Grand Master)
trinkets[ 23684] =  19288 -- Aura of the Blue Dragon (Darkmoon Card: Blue Dragon)
trinkets[ 23720] =  19337 -- Blessing of the Black Book (The Black Book)
trinkets[ 23721] =  19336 -- Arcane Infused (Arcane Infused Gem)
trinkets[ 23723] =  19339 -- Mind Quickening (Mind Quickening Gem)
trinkets[ 23724] =  19340 -- Metamorphosis Rune (Rune of Metamorphosis)
trinkets[ 23725] =  19341 -- Gift of Life (Lifegiving Gem)
trinkets[ 23726] =  19342 -- Venomous Totem
trinkets[ 23733] =  19343 -- Blinding Light (Scrolls of Blinding Light)
trinkets[ 23734] =  19344 -- Nature Aligned (Natural Alignment Crystal)
trinkets[ 23780] =  19345 -- Aegis of Preservation
trinkets[ 23991] = { -- Damage Absorb
	 20071, -- Talisman of Arathor
	 20072, -- Defiler's Talisman
}
trinkets[ 24268] =  19930 -- Mar'li's Brain Boost (Mar'li's Eye)
trinkets[ 24347] =  19979 -- Master Angler (Hook of the Master Angler)
trinkets[ 24352] =  19991 -- Devilsaur Fury (Devilsaur Eye)
trinkets[ 24354] =  19990 -- Prayer Beads Blessing (Blessed Prayer Beads)
trinkets[ 24389] =  20036 -- Chaos Fire (Fire Ruby)
trinkets[ 24427] =  20130 -- Diamond Flask
trinkets[ 24498] =  19952 -- Brilliant Light (Gri'lek's Charm of Valor)
trinkets[ 24499] =  19956 -- Energized Shield (Wushoolay's Charm of Spirits)
trinkets[ 24531] =  19953 -- Refocus (Renataki's Charm of Beasts)
trinkets[ 24542] =  19955 -- Nimble Healing Touch (Wushoolay's Charm of Nature)
trinkets[ 24543] =  19957 -- Massive Destruction (Hazza'rah's Charm of Destruction)
trinkets[ 24544] =  19959 -- Arcane Potency (Hazza'rah's Charm of Magic)
trinkets[ 24546] =  19958 -- Rapid Healing (Hazza'rah's Charm of Healing)
trinkets[ 24610] =  19947 -- Pagle's Broken Reel (Nat Pagle's Broken Reel)
trinkets[ 24865] =  20512 -- Sanctified Orb
trinkets[ 24998] =  20636 -- Healing of the Ages (Hibernation Crystal)
trinkets[ 25746] = { -- Damage Absorb
	 21115, -- Defiler's Talisman
	 21117, -- Talisman of Arathor
}
trinkets[ 25747] = { -- Damage Absorb
	 21116, -- Defiler's Talisman
	 21118, -- Talisman of Arathor
}
trinkets[ 25750] = { -- Damage Absorb
	 65286, -- Ancient Seed Casing
	 21119, -- Talisman of Arathor
	 21120, -- Defiler's Talisman
}
trinkets[ 25891] =  21180 -- Earthstrike
trinkets[ 26166] =  21473 -- Obsidian Insight (Eye of Moam)
trinkets[ 26168] =  21488 -- Chitinous Spikes (Fetish of Chitinous Spikes)
trinkets[ 26400] =  21647 -- Arcane Shroud (Fetish of the Sand Reaver)
trinkets[ 26467] =  21625 -- Persistent Shield (Scarab Brooch)
trinkets[ 26480] =  21670 -- Badge of the Swarmguard
trinkets[ 26551] =  21748 -- Jade Owl (Figurine - Jade Owl)
trinkets[ 26571] =  21756 -- Golden Hare (Figurine - Golden Hare)
trinkets[ 26576] =  21758 -- Black Pearl Panther (Figurine - Black Pearl Panther)
trinkets[ 26581] =  21760 -- Truesilver Crab (Figurine - Truesilver Crab)
trinkets[ 26593] =  21763 -- Truesilver Boar (Figurine - Truesilver Boar)
trinkets[ 26599] =  21769 -- Ruby Serpent (Figurine - Ruby Serpent)
trinkets[ 26600] =  21777 -- Emerald Owl (Figurine - Emerald Owl)
trinkets[ 26609] =  21784 -- Black Diamond Crab (Figurine - Black Diamond Crab)
trinkets[ 26614] =  21789 -- Dark Iron Scorpid (Figurine - Dark Iron Scorpid)
trinkets[ 27675] =  22268 -- Chromatic Infusion (Draconic Infused Emblem)
trinkets[ 28200] =  22678 -- Ascendance (Talisman of Ascendance)
trinkets[ 28777] =  23041 -- Slayer's Crest
trinkets[ 28778] =  23042 -- Loatheb's Reflection
trinkets[ 28779] =  23046 -- Essence of Sapphiron (The Restrained Essence of Sapphiron)
trinkets[ 28780] =  23047 -- The Eye of the Dead (Eye of the Dead)
trinkets[ 28862] =  23001 -- The Eye of Diminution (Eye of Diminution)
trinkets[ 28866] =  22954 -- Kiss of the Spider
trinkets[ 29506] =  23558 -- The Burrower's Shell
trinkets[ 29601] =  28727 -- Enlightenment (Pendant of the Violet Eye)
trinkets[ 29602] =  23570 -- Jom Gabbar
trinkets[ 31038] =  24124 -- Felsteel Boar (Figurine - Felsteel Boar)
trinkets[ 31039] =  24125 -- Dawnstone Crab (Figurine - Dawnstone Crab)
trinkets[ 31040] =  24126 -- Living Ruby Serpent (Figurine - Living Ruby Serpent)
trinkets[ 31045] =  24127 -- Talasite Owl (Figurine - Talasite Owl)
trinkets[ 31047] =  24128 -- Nightseye Panther (Figurine - Nightseye Panther)
trinkets[ 31771] =  24376 -- Shell of Deterrence (Runed Fungalcap)
trinkets[ 31794] =  24390 -- Focused Mind (Auslese's Light Channeler)
trinkets[ 32355] = { -- Focused Power
	 25619, -- Glowing Crystal Insignia
	 25620, -- Ancient Crystal Talisman
}
trinkets[ 32362] = { -- Burning Hatred
	 25628, -- Ogre Mauler's Badge
	 25633, -- Uniting Charm
}
trinkets[ 32367] =  25634 -- Power of Prayer (Oshu'gun Relic)
trinkets[ 32600] =  25787 -- Avoidance (Charm of Alacrity)
trinkets[ 33012] =  26055 -- Consume Essence (Oculus of the Hidden Eye)
trinkets[ 33014] =  27416 -- Consume Life (Fetish of the Fallen)
trinkets[ 33089] =  27529 -- Vigilance of the Colossus (Figurine of the Colossus)
trinkets[ 33370] =  28190 -- Spell Haste (Scarab of the Infinite Cycle)
trinkets[ 33400] =  27828 -- Accelerated Mending (Warp-Scarab Brooch)
trinkets[ 33479] =  27891 -- Adamantine Shell (Adamantine Figurine)
trinkets[ 33523] = { -- Mark of Vindication
	 27926, -- Mark of Vindication
	 27927, -- Mark of Vindication
}
trinkets[ 33649] =  28034 -- Rage of the Unraveller (Hourglass of the Unraveller)
trinkets[ 33662] =  28040 -- Arcane Energy (Vengeance of the Illidari)
trinkets[ 33667] =  28041 -- Ferocity (Bladefist's Breadth)
trinkets[ 33668] =  28042 -- Tenacity (Regal Protectorate)
trinkets[ 33758] =  28109 -- Essence Infused Mushroom
trinkets[ 33807] =  28288 -- Abacus of Violent Odds
trinkets[ 34000] =  28223 -- The Arcanist's Stone (Arcanist's Stone)
trinkets[ 34106] =  28121 -- Unyielding Courage (Icon of Unyielding Courage)
trinkets[ 34210] =  28370 -- Endless Blessings (Bangle of Endless Blessings)
trinkets[ 34321] =  28418 -- Call of the Nexus (Shiffar's Nexus-Horn)
trinkets[ 34519] =  28528 -- Time's Favor (Moroes' Lucky Pocket Watch)
trinkets[ 34747] =  28789 -- Recurring Power (Eye of Magtheridon)
trinkets[ 34775] =  28830 -- Dragonspine Flurry (Dragonspine Trophy)
trinkets[ 35163] =  29370 -- Blessing of the Silver Crescent (Icon of the Silver Crescent)
trinkets[ 35165] =  29376 -- Essence of the Martyr
trinkets[ 35166] =  29383 -- Lust for Battle (Bloodlust Brooch)
trinkets[ 35337] = { -- Spell Power
	 29132, -- Scryer's Bloodgem
	 29179, -- Xi'ri's Gift
}
trinkets[ 35733] =  29776 -- Ancient Power (Core of Ar'kelos)
trinkets[ 36347] =  30293 -- Healing Power (Heavenly Inspiration)
trinkets[ 36372] =  30300 -- Phalanx (Dabiri's Enigma)
trinkets[ 36432] =  30340 -- Spell Power (Starkiller's Bauble)
trinkets[ 37174] =  30450 -- Perceived Weakness (Warp-Spring Coil)
trinkets[ 37198] =  30447 -- Blessing of Righteousness (Tome of Fiery Redemption)
trinkets[ 37243] =  30663 -- Revitalize (Fathom-Brooch of the Tidewalker)
trinkets[ 37508] =  30448 -- Shot Power (Talon of Al'ar)
trinkets[ 37656] =  32496 -- Wisdom (Memento of Tyrande)
trinkets[ 38324] =  30619 -- Regeneration (Fel Reaver's Piston)
trinkets[ 38325] =  30620 -- Regeneration (Spyglass of the Hidden Fleet)
trinkets[ 38332] =  28590 -- Blessing of Life (Ribbon of Sacrifice)
trinkets[ 38346] =  28370 -- Meditation (Bangle of Endless Blessings)
trinkets[ 38348] =  30626 -- Unstable Currents (Sextant of Unstable Currents)
trinkets[ 38351] =  30629 -- Displacement (Scarab of Displacement)
trinkets[ 39200] =  25937 -- Heroism (Terokkar Tablet of Precision)
trinkets[ 39201] =  25936 -- Spell Power (Terokkar Tablet of Vim)
trinkets[ 39228] =  27770 -- Argussian Compass
trinkets[ 39439] =  31856 -- Aura of the Crusader (Darkmoon Card: Crusade)
trinkets[ 39443] =  31857 -- Aura of Wrath (Darkmoon Card: Wrath)
trinkets[ 40396] =  32483 -- Fel Infusion (The Skull of Gul'dan)
trinkets[ 40402] =  30665 -- Deep Meditation (Earring of Soulful Meditation)
trinkets[ 40459] =  32485 -- Fire Blood (Ashtongue Talisman of Valor)
trinkets[ 40464] =  32501 -- Protector's Vigor (Shadowmoon Insignia)
trinkets[ 40477] =  32505 -- Forceful Strike (Madness of the Betrayer)
trinkets[ 40480] =  32493 -- Power of the Ashtongue (Ashtongue Talisman of Shadows)
trinkets[ 40483] =  32488 -- Insight of the Ashtongue (Ashtongue Talisman of Insight)
trinkets[ 40487] =  32487 -- Deadly Aim (Ashtongue Talisman of Swiftness)
trinkets[ 40538] =  32534 -- Tenacity (Brooch of the Immortal King)
trinkets[ 40724] =  32654 -- Valor (Crystalforged Trinket)
trinkets[ 40729] =  32658 -- Heightened Reflexes (Badge of Tenacity)
trinkets[ 41261] =  32770 -- Combat Valor (Skyguard Silver Cross)
trinkets[ 41263] =  32771 -- Combat Gallantry (Airman's Ribbon of Gallantry)
trinkets[ 41301] =  32782 -- Time-Lost Figurine
trinkets[ 42084] =  30627 -- Fury of the Crashing Waves (Tsunami Talisman)
trinkets[ 43710] =  33828 -- Diabolic Remedy (Tome of Diabolic Remedy)
trinkets[ 43712] =  33829 -- Mojo Madness (Hex Shrunken Head)
trinkets[ 43713] =  33830 -- Hardened Skin (Ancient Aqir Artifact)
trinkets[ 43716] =  33831 -- Call of the Berserker (Berserker's Call)
trinkets[ 44055] = { -- Tremendous Fortitude
	 33832, -- Battlemaster's Determination
	 34049, -- Battlemaster's Audacity
	 34050, -- Battlemaster's Perseverance
	 34162, -- Battlemaster's Depravity
	 34163, -- Battlemaster's Cruelty
	 34576, -- Battlemaster's Cruelty
	 34577, -- Battlemaster's Depravity
	 34578, -- Battlemaster's Determination
	 34579, -- Battlemaster's Audacity
	 34580, -- Battlemaster's Perseverance
	 35326, -- Battlemaster's Alacrity
	 35327, -- Battlemaster's Alacrity
}
trinkets[ 45040] =  34427 -- Battle Trance (Blackened Naaru Sliver)
trinkets[ 45042] =  34429 -- Power Circle (Shifting Naaru Sliver)
trinkets[ 45049] =  34428 -- Tenacity (Steely Naaru Sliver)
trinkets[ 45052] =  34430 -- Evocation (Glimmering Naaru Sliver)
trinkets[ 45053] =  34472 -- Disdain (Shard of Contempt)
trinkets[ 45062] =  34471 -- Holy Energy (Vial of the Sunwell)
trinkets[ 46567] =  23836 -- Rocket Launch (Goblin Rocket Launcher)
trinkets[ 46780] =  35693 -- Empyrean Tortoise (Figurine - Empyrean Tortoise)
trinkets[ 46783] =  35700 -- Crimson Serpent (Figurine - Crimson Serpent)
trinkets[ 46784] =  35702 -- Shadowsong Panther (Figurine - Shadowsong Panther)
trinkets[ 46785] =  35703 -- Seaspray Albatross (Figurine - Seaspray Albatross)
trinkets[ 47215] =  35935 -- Runic Infusion (Infused Coldstone Rune)
trinkets[ 47217] =  35937 -- Foaming Rage (Braxley's Backyard Moonshine)
trinkets[ 47806] =  36871 -- Towering Rage (Fury of the Encroaching Storm)
trinkets[ 47807] =  36872 -- Healing Focus (Mender of the Oncoming Dawn)
trinkets[ 47816] = { -- Spell Power
	 36874, -- Horn of the Herald
	 38257, -- Strike of the Seas
}
trinkets[ 48332] =  37254 -- Going Ape! (Super Simian Sphere)
trinkets[ 48846] = { -- Runic Infusion
	 37555, -- Warsong's Wrath
	 38213, -- Harbinger's Wrath
}
trinkets[ 48847] =  37556 -- Precise Strikes (Talisman of the Tundra)
trinkets[ 48848] =  37557 -- Feral Fury (Warsong's Fervor)
trinkets[ 48855] =  37558 -- Healing Purity (Tidal Boon)
trinkets[ 48865] =  37560 -- Perfumed Grace (Vial of Renewal)
trinkets[ 48868] =  37562 -- Skycaller's Swiftness (Fury of the Crimson Drake)
trinkets[ 48875] = { -- Spell Power
	 38760, -- Mendicant's Charm
	 38762, -- Insignia of Bloody Fire
}
trinkets[ 49623] =  37835 -- Effervescence (Je'Tze's Bell)
trinkets[ 50261] =  38258 -- Nimble Fingers (Sailor's Knotted Charm)
trinkets[ 50263] =  38259 -- Quickness of the Sailor (First Mate's Pocketwatch)
trinkets[ 50708] =  19992 -- Primal Instinct (Devilsaur Tooth)
trinkets[ 51348] =  38359 -- Venture Company Beatdown! (Goblin Repetition Reducer)
trinkets[ 51952] =  38289 -- Dark Iron Luck (Coren's Lucky Coin)
trinkets[ 51953] =  38290 -- Dark Iron Pipeweed (Dark Iron Smoking Pipe)
trinkets[ 51954] =  38288 -- Hopped Up (Direbrew Hops)
trinkets[ 51955] =  38287 -- Dire Drunkard (Empty Mug of Direbrew)
trinkets[ 51978] =  38080 -- Jormungar Slime (Automated Weapon Coater)
trinkets[ 51985] =  38070 -- Far-Seeing Eyes (Foresight's Anticipation)
trinkets[ 51987] =  38081 -- Arcane Infusion (Scarab of Isanoth)
trinkets[ 52419] =  38674 -- Deflection (Soul Harvester's Charm)
trinkets[ 52424] =  38675 -- Retaliation (Signet of the Dark Brotherhood)
trinkets[ 54092] =  40354 -- Monster Slayer's Kit
trinkets[ 54329] =  40601 -- Argent Dawn Banner
trinkets[ 54418] =  40593 -- Argent Tome Bunny Spawn (Argent Tome)
trinkets[ 54696] =  38212 -- Wracking Pains (Death Knight's Anguish)
trinkets[ 54739] =  37559 -- Star of Light (Serrah's Star)
trinkets[ 54839] =  38071 -- Purified Spirit (Valonforth's Remembrance)
trinkets[ 55018] =  40767 -- Sonic Awareness (Sonic Booster)
trinkets[ 55019] =  40865 -- Sonic Shield (Noise Machine)
trinkets[ 55039] =  41121 -- Gnomish Lightning Generator
trinkets[ 55915] = { -- Tremendous Fortitude
	 42128, -- Battlemaster's Hostility
	 42129, -- Battlemaster's Accuracy
	 42130, -- Battlemaster's Avidity
	 42131, -- Battlemaster's Conviction
	 42132, -- Battlemaster's Bravery
}
trinkets[ 56121] =  42341 -- Ruby Hare (Figurine - Ruby Hare)
trinkets[ 56184] =  42395 -- Twilight Serpent (Figurine - Twilight Serpent)
trinkets[ 56186] =  42413 -- Sapphire Owl (Figurine - Sapphire Owl)
trinkets[ 56188] =  42418 -- Emerald Boar (Figurine - Emerald Boar)
trinkets[ 57350] =  42988 -- Illusionary Barrier (Darkmoon Card: Illusion)
trinkets[ 58157] =  30446 -- Solarian's Grace (Solarian's Sapphire)
trinkets[ 58904] =  43573 -- Tears of Anguish (Tears of Bitter Anguish)
trinkets[ 59657] = { -- Argent Valor
	 44013, -- Cannoneer's Fuselighter
	 44015, -- Cannoneer's Morale
}
trinkets[ 59658] =  44014 -- Argent Heroism (Fezzik's Pocketwatch)
trinkets[ 59757] =  44063 -- Figurine - Monarch Crab
trinkets[ 59789] = { -- Oracle Ablutions
	 44074, -- Oracle Talisman of Ablution
	 44870, -- Oracle Talisman of Ablution
}
trinkets[ 59821] =  44073 -- Frenzyheart Fury (Frenzyheart Insignia of Fury)
trinkets[ 60054] =  40683 -- Valor Medal of the First War
trinkets[ 60062] = { -- Essence of Life
	 40685, -- The Egg of Mortal Essence
	 49078, -- Ancient Pickled Egg
}
trinkets[ 60064] =  44912 -- Now is the time! (Flow of Knowledge)
trinkets[ 60065] =  44914 -- Reflection of Torment (Anvil of Titans)
trinkets[ 60180] = { -- Resolute
	 39292, -- Repelling Charge
	 37638, -- Offering of Sacrifice
}
trinkets[ 60196] =  42989 -- Berserker! (Darkmoon Card: Berserker!)
trinkets[ 60214] =  36993 -- Seal of the Pantheon
trinkets[ 60215] =  37872 -- Lavanthor's Talisman
trinkets[ 60218] =  37220 -- Essence of Gossamer
trinkets[ 60258] =  40372 -- Rune of Repulsion
trinkets[ 60286] =  40257 -- Defender's Code
trinkets[ 60299] =  37723 -- Incisor Fragment
trinkets[ 60302] =  37390 -- Meteorite Whetstone
trinkets[ 60305] =  37166 -- Heart of a Dragon (Sphere of Red Dragon's Blood)
trinkets[ 60314] =  40431 -- Fury of the Five Flights
trinkets[ 60319] =  40531 -- Mark of Norgannon
trinkets[ 60437] =  40256 -- Grim Toll
trinkets[ 60439] =  39257 -- Loatheb's Shadow
trinkets[ 60471] =  36972 -- Tome of Arcane Phenomena
trinkets[ 60479] =  37660 -- Forge Ember
trinkets[ 60480] =  37873 -- Mark of the War Prisoner
trinkets[ 60486] =  40432 -- Illustration of the Dragon Soul
trinkets[ 60492] =  39229 -- Embrace of the Spider
trinkets[ 60494] =  40255 -- Dying Curse
trinkets[ 60517] =  37734 -- Talisman of Troll Divinity
trinkets[ 60520] =  37657 -- Spark of Life
trinkets[ 60521] =  37844 -- Winged Talisman
trinkets[ 60525] =  40430 -- Majestic Dragon Figurine
trinkets[ 60527] =  39388 -- Essence Flow (Spirit-World Glass)
trinkets[ 60530] =  40258 -- Forethought Talisman
trinkets[ 60538] =  40382 -- Soul of the Dead
trinkets[ 61426] =  38763 -- Infinite Spirit (Futuresight Rune)
trinkets[ 61427] =  38764 -- Infinite Speed (Rune of Finite Variation)
trinkets[ 61428] =  38765 -- Infinite Power (Rune of Infinite Power)
trinkets[ 61617] =  43837 -- Warm Glow (Softly Glowing Orb)
trinkets[ 61619] =  43838 -- Tentacles (Chuchu's Tiny Box of Horrors)
trinkets[ 61620] =  43836 -- Bleeding Heart (Thorny Rose Brooch)
trinkets[ 61671] =  43829 -- Crusader's Glory (Crusader's Locket)
trinkets[ 61778] =  38761 -- Scything Talons (Talon of Hatred)
trinkets[ 62088] =  39811 -- Infiltrator's Guile (Badge of the Infiltrator)
trinkets[ 63250] = { -- Jouster's Fury
	 45131, -- Jouster's Fury
	 45219, -- Jouster's Fury
}
trinkets[ 64524] =  46086 -- Platinum Disks of Battle
trinkets[ 64525] =  46087 -- Platinum Disks of Sorcery
trinkets[ 64527] =  46088 -- Platinum Disks of Swiftness
trinkets[ 64707] =  45466 -- Scale of Fates
trinkets[ 64712] =  45148 -- Living Flame
trinkets[ 64713] =  45518 -- Flame of the Heavens (Flare of the Heavens)
trinkets[ 64739] =  45535 -- Show of Faith
trinkets[ 64741] =  45490 -- Pandora's Plea
trinkets[ 64763] =  45158 -- Heart of Iron
trinkets[ 64765] =  45507 -- The General's Heart
trinkets[ 64772] =  45609 -- Comet's Trail
trinkets[ 64790] =  45522 -- Blood of the Old God
trinkets[ 64800] =  45263 -- Wrathstone
trinkets[ 64999] =  46051 -- Meteoric Inspiration (Meteorite Crystal)
trinkets[ 65003] =  45929 -- Memories of Love (Sif's Remembrance)
trinkets[ 65004] =  45866 -- Alacrity of the Elements (Elemental Focus Stone)
trinkets[ 65006] =  45308 -- Eye of the Broodmother
trinkets[ 65008] =  45292 -- Energy Siphon
trinkets[ 65011] =  45313 -- Furnace Stone
trinkets[ 65012] =  46021 -- Royal Seal of King Llane
trinkets[ 65014] =  45286 -- Pyrite Infusion (Pyrite Infuser)
trinkets[ 65019] =  45931 -- Mjolnir Runestone
trinkets[ 65024] =  46038 -- Implosion (Dark Matter)
trinkets[ 67596] = { -- Tremendous Fortitude
	 42133, -- Battlemaster's Fury
	 42134, -- Battlemaster's Precision
	 42135, -- Battlemaster's Vivacity
	 42136, -- Battlemaster's Rage
	 42137, -- Battlemaster's Ruination
}
trinkets[ 67631] =  47216 -- Aegis (The Black Heart)
trinkets[ 67669] =  47213 -- Elusive Power (Abyssal Rune)
trinkets[ 67671] =  47214 -- Fury (Banner of Victory)
trinkets[ 67683] =  48722 -- Celerity (Shard of the Crystal Heart)
trinkets[ 67684] =  48724 -- Hospitality (Talisman of Resurgence)
trinkets[ 67694] =  47735 -- Defensive Tactics (Glyph of Indomitability)
trinkets[ 67695] =  47734 -- Rage (Mark of Supremacy)
trinkets[ 67696] = { -- Energized
	 47041, -- Solace of the Defeated
	 47271, -- Solace of the Fallen
}
trinkets[ 67699] = { -- Fortitude
	 47080, -- Satrina's Impeding Scarab
	 47290, -- Juggernaut's Vitality
}
trinkets[ 67726] = { -- Escalating Power
	 47728, -- Binding Light
	 47880, -- Binding Stone
}
trinkets[ 67728] = { -- Hardening Armor
	 47727, -- Fervor of the Frostborn
	 47882, -- Eitrigg's Oath
}
trinkets[ 67738] = { -- Rising Fury
	 47725, -- Victor's Call
	 47881, -- Vengeance of the Forsaken
}
trinkets[ 67740] = { -- Escalating Power
	 47947, -- Binding Light
	 48019, -- Binding Stone
}
trinkets[ 67742] = { -- Hardening Armor
	 47949, -- Fervor of the Frostborn
	 48021, -- Eitrigg's Oath
}
trinkets[ 67747] = { -- Rising Fury
	 47948, -- Victor's Call
	 48020, -- Vengeance of the Forsaken
}
trinkets[ 67750] = { -- Energized
	 47059, -- Solace of the Defeated
	 47432, -- Solace of the Fallen
}
trinkets[ 67753] = { -- Fortitude
	 47088, -- Satrina's Impeding Scarab
	 47451, -- Juggernaut's Vitality
}
trinkets[ 68443] =  49080 -- Drunken Evasiveness (Brawler's Souvenir)
trinkets[ 71396] =  50355 -- Rage of the Fallen (Herkuml War Token)
trinkets[ 71401] =  50342 -- Icy Rage (Whispering Fanged Skull)
trinkets[ 71403] =  50198 -- Fatal Flaws (Needle-Encrusted Scorpion)
trinkets[ 71541] =  50343 -- Icy Rage (Whispering Fanged Skull)
trinkets[ 71568] =  50260 -- Urgency (Ephemeral Snowflake)
trinkets[ 71569] =  50235 -- Increased Fortitude (Ick's Rotting Thumb)
trinkets[ 71570] =  50340 -- Cultivated Power (Muradin's Spyglass)
trinkets[ 71572] =  50345 -- Cultivated Power (Muradin's Spyglass)
trinkets[ 71575] =  50341 -- Invigorated (Unidentifiable Organ)
trinkets[ 71577] =  50344 -- Invigorated (Unidentifiable Organ)
trinkets[ 71579] =  50357 -- Elusive Power (Maghia's Misguided Quill)
trinkets[ 71584] =  50358 -- Revitalized (Purified Lunar Dust)
trinkets[ 71586] =  50356 -- Hardened Skin (Corroded Skeleton Key)
trinkets[ 71601] =  50353 -- Surge of Power (Dislodged Foreign Object)
trinkets[ 71605] =  50360 -- Siphoned Power (Phylactery of the Nameless Lich)
trinkets[ 71633] =  50352 -- Thick Skin (Corpse Tongue Coin)
trinkets[ 71635] =  50361 -- Aegis of Dalaran (Sindragosa's Flawless Fang)
trinkets[ 71636] =  50365 -- Siphoned Power (Phylactery of the Nameless Lich)
trinkets[ 71638] =  50364 -- Aegis of Dalaran (Sindragosa's Flawless Fang)
trinkets[ 71639] =  50349 -- Thick Skin (Corpse Tongue Coin)
trinkets[ 71644] =  50348 -- Surge of Power (Dislodged Foreign Object)
trinkets[ 73522] =  52351 -- King of Boars (Figurine - King of Boars)
trinkets[ 73549] =  52199 -- Demon Panther (Figurine - Demon Panther)
trinkets[ 73550] =  52352 -- Earthen Guardian (Figurine - Earthen Guardian)
trinkets[ 73551] =  52353 -- Jeweled Serpent (Figurine - Jeweled Serpent)
trinkets[ 73552] =  52354 -- Dream Owl (Figurine - Dream Owl)
trinkets[ 75456] =  54590 -- Piercing Twilight (Sharpened Twilight Scale)
trinkets[ 75458] =  54569 -- Piercing Twilight (Sharpened Twilight Scale)
trinkets[ 75466] =  54572 -- Twilight Flames (Charred Twilight Scale)
trinkets[ 75473] =  54588 -- Twilight Flames (Charred Twilight Scale)
trinkets[ 75477] =  54571 -- Scaly Nimbleness (Petrified Twilight Scale)
trinkets[ 75480] =  54591 -- Scaly Nimbleness (Petrified Twilight Scale)
trinkets[ 75490] =  54573 -- Eyes of Twilight (Glowing Twilight Scale)
trinkets[ 75495] =  54589 -- Eyes of Twilight (Glowing Twilight Scale)
trinkets[ 78830] =  56847 -- Projectile Vomit (Chelsea's Nightmare)
trinkets[ 84212] =  23040 -- Glyph of Deflection
trinkets[ 84213] =  29387 -- Gnome Ingenuity (Gnomeregan Auto-Dodger 600)
trinkets[ 84343] =  60856 -- Relationship Ray (Metro-Gnome Relationship Ray (NYI))
trinkets[ 84960] = { -- Tremendous Fortitude
	 61026, -- Vicious Gladiator's Emblem of Cruelty
	 61030, -- Vicious Gladiator's Emblem of Proficiency
	 61031, -- Vicious Gladiator's Emblem of Meditation
	 61032, -- Vicious Gladiator's Emblem of Tenacity
}
trinkets[ 84966] =  61034 -- Call of Victory (Vicious Gladiator's Badge of Victory)
trinkets[ 84968] =  61035 -- Call of Dominance (Vicious Gladiator's Badge of Dominance)
trinkets[ 84969] =  61033 -- Call of Conquest (Vicious Gladiator's Badge of Conquest)
trinkets[ 85022] =  61047 -- Surge of Conquest (Vicious Gladiator's Insignia of Conquest)
trinkets[ 85027] =  61045 -- Surge of Dominance (Vicious Gladiator's Insignia of Dominance)
trinkets[ 85032] =  61046 -- Surge of Victory (Vicious Gladiator's Insignia of Victory)
trinkets[ 89091] =  62047 -- Volcanic Destruction (Darkmoon Card: Volcano)
trinkets[ 89181] =  62048 -- Mighty Earthquake (Darkmoon Card: Earthquake)
trinkets[ 89182] =  62050 -- Giant Wave (Darkmoon Card: Tsunami)
trinkets[ 90842] =  57346 -- Mindfletcher (Mindfletcher Talisman)
trinkets[ 90847] = { -- Prismatic
	 59661, -- Pelagic Prism
	 59664, -- Pelagic Prism
}
trinkets[ 90854] = { -- Visionary
	 59630, -- Severed Visionary Tentacle
	 59633, -- Severed Visionary Tentacle
}
trinkets[ 90885] =  55787 -- Witching Hour (Witching Hourglass)
trinkets[ 90887] =  56320 -- Witching Hour (Witching Hourglass)
trinkets[ 90889] =  61429 -- Fury of the Earthen (Insignia of the Earthen Lord)
trinkets[ 90895] =  61411 -- Kiss of Death (Stonemother's Kiss)
trinkets[ 90896] =  55810 -- Tendrils of Darkness (Tendrils of Burrowing Dark)
trinkets[ 90898] =  56339 -- Tendrils of Darkness (Tendrils of Burrowing Dark)
trinkets[ 90900] =  63842 -- Focus (World-Queller Focus)
trinkets[ 90953] =  56138 -- Dead Winds (Gale of Shadows)
trinkets[ 90985] =  56462 -- Dead Winds (Gale of Shadows)
trinkets[ 90989] =  55889 -- Hymn of Power (Anhuur's Hymnal)
trinkets[ 90992] =  56407 -- Hymn of Power (Anhuur's Hymnal)
trinkets[ 90996] =  55879 -- Crescendo of Suffering (Sorrowsong)
trinkets[ 91002] =  56400 -- Crescendo of Suffering (Sorrowsong)
trinkets[ 91007] =  59326 -- Dire Magic (Bell of Enraging Resonance)
trinkets[ 91019] =  58183 -- Soul Power (Soul Casket)
trinkets[ 91024] =  59519 -- Revelation (Theralion's Mirror)
trinkets[ 91027] =  59514 -- Heart's Revelation (Heart of Ignacious)
trinkets[ 91041] =  59514 -- Heart's Judgment (Heart of Ignacious)
trinkets[ 91047] = { -- Battle Magic
	 62465, -- Stump of Time
	 62470, -- Stump of Time
}
trinkets[ 91075] =  63839 -- Vengeful Wisp (Harmlight Token)
trinkets[ 91135] =  55256 -- Leviathan (Sea Star)
trinkets[ 91136] =  56290 -- Leviathan (Sea Star)
trinkets[ 91138] =  55819 -- Cleansing Tears (Tear of Blood)
trinkets[ 91139] =  56351 -- Cleansing Tears (Tear of Blood)
trinkets[ 91141] =  55854 -- Anthem (Rainsong)
trinkets[ 91143] =  56377 -- Anthem (Rainsong)
trinkets[ 91147] =  55995 -- Blessing of Isiset (Blood of Isiset)
trinkets[ 91149] =  56414 -- Blessing of Isiset (Blood of Isiset)
trinkets[ 91155] =  58184 -- Expansive Soul (Core of Ripeness)
trinkets[ 91173] =  60233 -- Celerity (Shard of Woe)
trinkets[ 91184] =  59500 -- Grounded Soul (Fall of Mortality)
trinkets[ 91192] = { -- Pattern of Light
	 62467, -- Mandala of Stirring Patterns
	 62472, -- Mandala of Stirring Patterns
}
trinkets[ 91296] =  56136 -- Egg Shell (Corrupted Egg Shell)
trinkets[ 91308] =  56463 -- Egg Shell (Corrupted Egg Shell)
trinkets[ 91320] =  59354 -- Inner Eye (Jar of Ancient Remedies)
trinkets[ 91322] =  59354 -- Blind Spot (Jar of Ancient Remedies)
trinkets[ 91336] =  57316 -- Heavy Lifting (Egg-Lift Talisman)
trinkets[ 91338] =  59792 -- Dietary Enhancement (Petrified Spider Crab)
trinkets[ 91340] =  56285 -- Typhoon (Might of the Ocean)
trinkets[ 91341] =  66994 -- Typhoon (Soul's Anguish)
trinkets[ 91344] = { -- Battle!
	 59685, -- Kvaldir Battle Standard
	 59689, -- Kvaldir Battle Standard
}
trinkets[ 91345] =  61448 -- Favored (Oremantle's Favor)
trinkets[ 91351] =  55814 -- Polarization (Magnetite Mirror)
trinkets[ 91352] =  56345 -- Polarization (Magnetite Mirror)
trinkets[ 91355] = { -- Fatality
	 63838, -- Shrine-Cleansing Purifier
	 63841, -- Tank-Commander Insignia
}
trinkets[ 91363] =  55868 -- Heartened (Heart of Solace)
trinkets[ 91364] =  56393 -- Heartened (Heart of Solace)
trinkets[ 91368] =  56431 -- Eye of Doom (Right Eye of Rajh)
trinkets[ 91370] =  56100 -- Eye of Doom (Right Eye of Rajh)
trinkets[ 91374] =  56458 -- Battle Prowess (Mark of Khardros)
trinkets[ 91376] =  56132 -- Battle Prowess (Mark of Khardros)
trinkets[ 91810] =  58180 -- Slayer (License to Slay)
trinkets[ 91816] =  59224 -- Rageheart (Heart of Rage)
trinkets[ 91821] =  59506 -- Race Against Death (Crushing Weight)
trinkets[ 91828] = { -- Thrill of Victory
	 62464, -- Impatience of Youth
	 62469, -- Impatience of Youth
}
trinkets[ 91832] =  59461 -- Raw Fury (Fury of Angerforge)
trinkets[ 91836] =  59461 -- Forged Fury (Fury of Angerforge)
trinkets[ 92043] =  57325 -- Invigorated (Bileberry Smelling Salts)
trinkets[ 92045] = { -- Power of Focus
	 59707, -- Wavespeaker's Focus
	 59710, -- Wavespeaker's Focus
}
trinkets[ 92052] =  66969 -- Herald of Doom (Heart of the Vile)
trinkets[ 92055] =  61462 -- Gear Detected! (Gear Detector)
trinkets[ 92069] =  55795 -- Final Key (Key to the Endless Chamber)
trinkets[ 92071] = { -- Nimble
	 63840, -- Juju of Nimbleness
	 63843, -- Blood-Soaked Ale Mug
}
trinkets[ 92085] =  55874 -- Grace (Tia's Grace)
trinkets[ 92087] =  56295 -- Herald of Doom (Grace of the Herald)
trinkets[ 92089] =  56394 -- Grace (Tia's Grace)
trinkets[ 92091] =  56328 -- Final Key (Key to the Endless Chamber)
trinkets[ 92094] =  56427 -- Eye of Vengeance (Left Eye of Rajh)
trinkets[ 92096] =  56102 -- Eye of Vengeance (Left Eye of Rajh)
trinkets[ 92098] =  56115 -- Speed of Thought (Skardyn's Grace)
trinkets[ 92099] =  56440 -- Speed of Thought (Skardyn's Grace)
trinkets[ 92104] =  58181 -- River of Death (Fluid Death)
trinkets[ 92108] =  59520 -- Heedless Carnage (Unheeded Warning)
trinkets[ 92123] = { -- Enigma
	 62463, -- Unsolvable Riddle
	 62468, -- Unsolvable Riddle
}
trinkets[ 92124] =  59441 -- Nefarious Plot (Prestor's Talisman of Machination)
trinkets[ 92126] =  59473 -- Twisted (Essence of the Cyclone)
trinkets[ 92162] =  59617 -- Mentally Prepared (Mentalist's Protective Bottle)
trinkets[ 92166] =  65804 -- Hardened Shell (Talisman of Sinister Order)
trinkets[ 92172] =  61433 -- Great Fortitude (Insignia of Diplomacy)
trinkets[ 92174] =  56280 -- Hardened Shell (Porcelain Crab)
trinkets[ 92179] =  55816 -- Lead Plating (Leaden Despair)
trinkets[ 92184] =  56347 -- Lead Plating (Leaden Despair)
trinkets[ 92186] =  55845 -- Amazing Fortitude (Heart of Thunder)
trinkets[ 92187] =  56370 -- Amazing Fortitude (Heart of Thunder)
trinkets[ 92188] = { -- Master Tactician
	 63742, -- Za'brox's Lucky Tooth
	 63745, -- Za'brox's Lucky Tooth
}
trinkets[ 92199] =  55881 -- Blademaster (Impetuous Query)
trinkets[ 92200] =  56406 -- Blademaster (Impetuous Query)
trinkets[ 92205] =  56449 -- Duelist (Throngus's Finger)
trinkets[ 92208] =  56121 -- Duelist (Throngus's Finger)
trinkets[ 92213] =  59515 -- Memory of Invincibility (Vial of Stolen Memories)
trinkets[ 92216] =  64763 -- Surge of Conquest (Bloodthirsty Gladiator's Insignia of Victory)
trinkets[ 92218] =  64762 -- Surge of Dominance (Bloodthirsty Gladiator's Insignia of Dominance)
trinkets[ 92220] =  64761 -- Surge of Conquest (Bloodthirsty Gladiator's Insignia of Conquest)
trinkets[ 92222] = { -- Image of Immortality
	 62466, -- Mirror of Broken Images
	 62471, -- Mirror of Broken Images
}
trinkets[ 92223] = { -- Tremendous Fortitude
	 64740, -- Bloodthirsty Gladiator's Emblem of Cruelty
	 64741, -- Bloodthirsty Gladiator's Emblem of Meditation
	 64742, -- Bloodthirsty Gladiator's Emblem of Tenacity
}
trinkets[ 92224] =  64689 -- Call of Victory (Bloodthirsty Gladiator's Badge of Victory)
trinkets[ 92225] =  64688 -- Call of Dominance (Bloodthirsty Gladiator's Badge of Dominance)
trinkets[ 92226] =  64687 -- Call of Conquest (Bloodthirsty Gladiator's Badge of Conquest)
trinkets[ 92233] =  58182 -- Tectonic Shift (Bedrock Talisman)
trinkets[ 92235] =  59332 -- Turn of the Worm (Symbiotic Worm)
trinkets[ 92318] =  65053 -- Dire Magic (Bell of Enraging Resonance)
trinkets[ 92320] =  65105 -- Revelation (Theralion's Mirror)
trinkets[ 92325] =  65110 -- Heart's Revelation (Heart of Ignacious)
trinkets[ 92328] =  65110 -- Heart's Judgment (Heart of Ignacious)
trinkets[ 92329] =  65029 -- Inner Eye (Jar of Ancient Remedies)
trinkets[ 92331] =  65029 -- Blind Spot (Jar of Ancient Remedies)
trinkets[ 92332] =  65124 -- Grounded Soul (Fall of Mortality)
trinkets[ 92342] =  65118 -- Race Against Death (Crushing Weight)
trinkets[ 92345] =  65072 -- Rageheart (Heart of Rage)
trinkets[ 92349] =  65026 -- Nefarious Plot (Prestor's Talisman of Machination)
trinkets[ 92351] =  65140 -- Twisted (Essence of the Cyclone)
trinkets[ 92355] =  65048 -- Turn of the Worm (Symbiotic Worm)
trinkets[ 92357] =  65109 -- Memory of Invincibility (Vial of Stolen Memories)
trinkets[ 93248] = { -- Horn of the Traitor
	 63632, -- Horn of the Traitor
	 63633, -- Horn of the Traitor
}
trinkets[ 93740] =  65931 -- Poison Cloud (Essence of Eranikus' Shade)
trinkets[ 93791] =  63241 -- Pilla (Very Soft Pillow)
trinkets[ 95227] =  63192 -- Tosselwrench's Shrinker
trinkets[ 95870] =  66879 -- Lightning in a Bottle (Bottled Lightning)
trinkets[ 95872] =  67101 -- Undying Flames (Unquenchable Flame)
trinkets[ 95874] =  67037 -- Searing Words (Binding Promise)
trinkets[ 95875] =  67118 -- Heartsparked (Electrospark Heartstarter)
trinkets[ 95877] =  67152 -- La-La's Song (Lady La-La's Singing Shell)
trinkets[ 95879] =  62978 -- Devourer's Stomach
trinkets[ 95880] =  62966 -- Emissary's Watch
trinkets[ 95881] =  62984 -- Omarion's Gift
trinkets[ 95882] =  62995 -- Underlord's Mandible
trinkets[ 96908] =  68926 -- Victory (Jaws of Defeat)
trinkets[ 96911] =  68927 -- Devour (The Hungerer)
trinkets[ 96923] = { -- Titanic Power
	 69113, -- Apparatus of Khaz'goroth
	 68972, -- Apparatus of Khaz'goroth
}
trinkets[ 96945] =  68981 -- Loom of Fate (Spidersilk Spindle)
trinkets[ 96962] =  68982 -- Soul Fragment (Necromantic Focus)
trinkets[ 96980] =  68995 -- Accelerated (Vessel of Acceleration)
trinkets[ 96988] =  68996 -- Stay of Execution
trinkets[ 97007] =  68998 -- Mark of the Firelord (Rune of Zeth)
trinkets[ 97008] =  69000 -- Fiery Quintessence
trinkets[ 97009] =  69001 -- Ancient Petrified Seed
trinkets[ 97010] =  69002 -- Essence of the Eternal Flame
trinkets[ 97121] =  69111 -- Victory (Jaws of Defeat)
trinkets[ 97125] =  69112 -- Devour (The Hungerer)
trinkets[ 97129] =  69138 -- Loom of Fate (Spidersilk Spindle)
trinkets[ 97131] =  69139 -- Soul Fragment (Necromantic Focus)
trinkets[ 97142] =  69167 -- Accelerated (Vessel of Acceleration)
trinkets[ 99711] =  70517 -- Call of Conquest (Vicious Gladiator's Badge of Conquest)
trinkets[ 99712] =  70518 -- Call of Dominance (Vicious Gladiator's Badge of Dominance)
trinkets[ 99713] =  70519 -- Call of Victory (Vicious Gladiator's Badge of Victory)
trinkets[ 99714] = { -- Tremendous Fortitude
	 70563, -- Vicious Gladiator's Emblem of Cruelty
	 70564, -- Vicious Gladiator's Emblem of Meditation
	 70565, -- Vicious Gladiator's Emblem of Tenacity
}
trinkets[ 99717] =  70577 -- Surge of Conquest (Vicious Gladiator's Insignia of Conquest)
trinkets[ 99719] =  70578 -- Surge of Dominance (Vicious Gladiator's Insignia of Dominance)
trinkets[ 99721] =  70579 -- Surge of Victory (Vicious Gladiator's Insignia of Victory)
trinkets[ 99737] = { -- Tremendous Fortitude
	 70396, -- Ruthless Gladiator's Emblem of Cruelty
	 70397, -- Ruthless Gladiator's Emblem of Meditation
	 70398, -- Ruthless Gladiator's Emblem of Tenacity
}
trinkets[ 99739] =  70399 -- Call of Conquest (Ruthless Gladiator's Badge of Conquest)
trinkets[ 99740] =  70400 -- Call of Victory (Ruthless Gladiator's Badge of Victory)
trinkets[ 99741] =  70401 -- Call of Dominance (Ruthless Gladiator's Badge of Dominance)
trinkets[ 99742] =  70402 -- Surge of Dominance (Ruthless Gladiator's Insignia of Dominance)
trinkets[ 99746] =  70403 -- Surge of Victory (Ruthless Gladiator's Insignia of Victory)
trinkets[ 99748] =  70404 -- Surge of Conquest (Ruthless Gladiator's Insignia of Conquest)
trinkets[ 99915] =  70141 -- Caber Toss (Dwyer's Caber)
trinkets[100322] =  70141 -- Pumped Up (Dwyer's Caber)
trinkets[100612] =  70142 -- Summon Moonwell (Moonwell Chalice)
trinkets[101287] =  71335 -- Reflection of Torment (Coren's Chilled Chromium Coaster)
trinkets[101289] =  71336 -- Essence of Life (Petrified Pickled Egg)
trinkets[101291] =  71337 -- Now is the time! (Mithril Stopwatch)
trinkets[101293] =  71338 -- Drunken Evasiveness (Brawler's Trophy)
trinkets[101492] =  70143 -- Summon Splashing Waters (Moonwell Phial)
trinkets[101515] =  70144 -- Charged Blows (Ricket's Magnetic Fireball)
trinkets[102432] =  72455 -- Surge of Victory (Ruthless Gladiator's Insignia of Victory)
trinkets[102434] =  72450 -- Call of Victory (Ruthless Gladiator's Badge of Victory)
trinkets[102435] =  72449 -- Surge of Dominance (Ruthless Gladiator's Insignia of Dominance)
trinkets[102437] =  72448 -- Call of Dominance (Ruthless Gladiator's Badge of Dominance)
trinkets[102438] = { -- Tremendous Fortitude
	 72359, -- Ruthless Gladiator's Emblem of Cruelty
	 72360, -- Ruthless Gladiator's Emblem of Tenacity
	 72361, -- Ruthless Gladiator's Emblem of Meditation
}
trinkets[102439] =  72309 -- Surge of Conquest (Ruthless Gladiator's Insignia of Conquest)
trinkets[102441] =  72304 -- Call of Conquest (Ruthless Gladiator's Badge of Conquest)
trinkets[102659] =  72897 -- Arrow of Time
trinkets[102660] =  72901 -- Rosary of Light
trinkets[102662] =  72898 -- Foul Gift (Foul Gift of the Demon Lord)
trinkets[102664] =  72899 -- Varo'then's Brooch
trinkets[102667] =  72900 -- Veil of Lies
trinkets[102740] = { -- Strength of Courage
	 73062, -- Zealous Idol of Battle
	 73155, -- Ebonsoul Idol of Battle
	 73165, -- Valiant Idol of Battle
}
trinkets[102741] = { -- Avoidance of the Snake
	 73060, -- Zealous Defender's Idol
	 73157, -- Ebonsoul Defender's Idol
	 73167, -- Valiant Defender's Idol
	 88636, -- Monastic Defender's Idol
}
trinkets[102742] = { -- Mastery of Nimbleness
	 73042, -- Zealous Defender's Stone
	 73061, -- Zealous Stone of Battle
	 73067, -- Wildsoul Stone of Rage
	 73121, -- Shadowstalking Stone of Rage
	 73135, -- Stormbinder Stone of Rage
	 73150, -- Beastsoul Stone of Rage
	 73154, -- Ebonsoul Stone of Battle
	 73160, -- Ebonsoul Defender's Stone
	 73164, -- Valiant Stone of Battle
	 73170, -- Valiant Defender's Stone
	 88634, -- Monastic Defender's Stone
	 88639, -- Monastic Stone of Rage
}
trinkets[102744] = { -- Haste of the Mongoose
	 73065, -- Wildsoul Stone of Destruction
	 73101, -- Magesoul Stone of Destruction
	 73106, -- Dreadsoul Stone of Destruction
	 73116, -- Seraphic Stone of Destruction
	 73140, -- Stormbinder Stone of Destruction
}
trinkets[102746] = { -- Spirit of Wisdom
	 73063, -- Zealous Idol of Wisdom
	 73114, -- Seraphic Idol of Wisdom
	 73129, -- Wildsoul Idol of Wisdom
	 73142, -- Stormbinder Idol of Wisdom
	 88647, -- Monastic Idol of Wisdom
}
trinkets[102747] = { -- Agility of the Tiger
	 73068, -- Wildsoul Idol of Rage
	 73124, -- Shadowstalking Idol of Rage
	 73132, -- Stormbinder Idol of Rage
	 73147, -- Beastsoul Idol of Rage
	 88642, -- Monastic Idol of Rage
}
trinkets[102748] = { -- Intellect of the Sage
	 73066, -- Wildsoul Idol of Destruction
	 73104, -- Magesoul Idol of Destruction
	 73109, -- Dreadsoul Idol of Destruction
	 73119, -- Seraphic Idol of Destruction
	 73137, -- Stormbinder Idol of Destruction
}
trinkets[105132] =  73648 -- Call of Conquest (Cataclysmic Gladiator's Badge of Conquest)
trinkets[105133] =  73496 -- Call of Victory (Cataclysmic Gladiator's Badge of Victory)
trinkets[105134] =  73498 -- Call of Dominance (Cataclysmic Gladiator's Badge of Dominance)
trinkets[105135] =  73643 -- Surge of Conquest (Cataclysmic Gladiator's Insignia of Conquest)
trinkets[105137] =  73497 -- Surge of Dominance (Cataclysmic Gladiator's Insignia of Dominance)
trinkets[105139] =  73491 -- Surge of Victory (Cataclysmic Gladiator's Insignia of Victory)
trinkets[105144] = { -- Tremendous Fortitude
	 73591, -- Cataclysmic Gladiator's Emblem of Meditation
	 73592, -- Cataclysmic Gladiator's Emblem of Tenacity
	 73593, -- Cataclysmic Gladiator's Emblem of Cruelty
}
trinkets[107947] =  77113 -- Agile (Kiroptyric Sigil)
trinkets[107948] = { -- Ultimate Power
	 77114, -- Bottled Wishes
	 77115, -- Reflection of the Light
}
trinkets[107949] =  77116 -- Titanic Strength (Rotting Skull)
trinkets[107951] =  77117 -- Elusive (Fire of the Deep)
trinkets[107960] =  77197 -- Combat Trance (Wrath of Unchaining)
trinkets[107962] =  77199 -- Expansive Mind (Heart of Unliving)
trinkets[107966] =  77200 -- Titanic Strength (Eye of Unmaking)
trinkets[107968] =  77201 -- Preternatural Evasion (Resolve of Undying)
trinkets[107970] =  77198 -- Combat Mind (Will of Unbinding)
trinkets[107982] =  77204 -- Velocity (Seal of the Seven Signs)
trinkets[107986] =  77206 -- Master Tactician (Soulshifter Vortex)
trinkets[107988] =  77205 -- Find Weakness (Creche of the Final Dragon)
trinkets[109709] =  77973 -- Velocity (Starcatcher Compass)
trinkets[109711] =  77993 -- Velocity (Starcatcher Compass)
trinkets[109717] =  77974 -- Combat Trance (Wrath of Unchaining)
trinkets[109719] =  77994 -- Combat Trance (Wrath of Unchaining)
trinkets[109742] =  77972 -- Find Weakness (Creche of the Final Dragon)
trinkets[109744] =  77992 -- Find Weakness (Creche of the Final Dragon)
trinkets[109748] =  77977 -- Titanic Strength (Eye of Unmaking)
trinkets[109750] =  77997 -- Titanic Strength (Eye of Unmaking)
trinkets[109774] =  77970 -- Master Tactician (Soulshifter Vortex)
trinkets[109776] =  77990 -- Master Tactician (Soulshifter Vortex)
trinkets[109780] =  77978 -- Preternatural Evasion (Resolve of Undying)
trinkets[109782] =  77998 -- Preternatural Evasion (Resolve of Undying)
trinkets[109787] =  77971 -- Velocity (Insignia of the Corrupted Mind)
trinkets[109789] =  77991 -- Velocity (Insignia of the Corrupted Mind)
trinkets[109793] =  77975 -- Combat Mind (Will of Unbinding)
trinkets[109795] =  77995 -- Combat Mind (Will of Unbinding)
trinkets[109802] =  77969 -- Velocity (Seal of the Seven Signs)
trinkets[109804] =  77989 -- Velocity (Seal of the Seven Signs)
trinkets[109811] =  77976 -- Expansive Mind (Heart of Unliving)
trinkets[109813] =  77996 -- Expansive Mind (Heart of Unliving)
trinkets[109908] =  72898 -- Foul Gift (Foul Gift of the Demon Lord)
trinkets[109993] =  74035 -- Master Pit Fighter
trinkets[109994] =  74034 -- Pit Fighter
trinkets[110008] =  72901 -- Rosary of Light
trinkets[117642] =  80773 -- Singing Cricket Medallion
trinkets[117643] =  80774 -- Grove Viper Medallion
trinkets[117644] =  80775 -- Coral Adder Medallion
trinkets[117645] =  80776 -- Flamelager Medallion
trinkets[117646] =  80777 -- Amberfly Idol
trinkets[117647] =  80778 -- Silkbead Emblem (Silkbead Idol)
trinkets[117648] =  80779 -- Mirror Strider Emblem
trinkets[117649] =  80780 -- Greenpaw Idol
trinkets[117650] =  80781 -- Shoots of Life
trinkets[117651] =  80782 -- Misty Jade Idol
trinkets[118611] =  81532 -- Silkspawn Carving
trinkets[118613] =  81534 -- Carp Hunter Feather
trinkets[118614] =  81535 -- Glade Pincher Feather
trinkets[118615] =  81536 -- Jungle Huntress Idol
trinkets[118750] =  81661 -- Faded Forest Medallion
trinkets[118751] =  81662 -- Faded Forest Emblem
trinkets[118752] =  81663 -- Faded Forest Medal
trinkets[118753] =  81664 -- Faded Forest Insignia
trinkets[118754] =  81665 -- Faded Forest Badge
trinkets[118871] =  81834 -- Silkspawn Wing
trinkets[118872] =  81835 -- Plainshawk Feather
trinkets[118873] =  81836 -- Lucky "Rabbit's" Foot
trinkets[118874] =  81837 -- Viseclaw Carapace
trinkets[118875] =  81838 -- Tawnyhide Antler
trinkets[120171] =  82574 -- Coin of Blessings
trinkets[120172] =  82575 -- Coin of Serendipity
trinkets[120173] =  82576 -- Coin of Luck
trinkets[120174] =  82577 -- Coin of Good Fortune
trinkets[120175] =  82578 -- Luckydo Coin
trinkets[120176] =  82579 -- Lorewalker's Mark
trinkets[120177] =  82580 -- Lorewalker's Emblem
trinkets[120178] =  82581 -- Lorewalker's Sigil
trinkets[120179] =  82582 -- Lorewalker's Medallion
trinkets[120180] =  82583 -- Lorewalker's Insignia
trinkets[120254] =  82696 -- Mountainscaler Mark
trinkets[120255] =  82697 -- Mountainscaler Medal
trinkets[120256] =  82698 -- Mountainscaler Emblem
trinkets[120257] =  82699 -- Mountainscaler Insignia
trinkets[120258] =  82700 -- Mountainscaler Badge
trinkets[122266] =  83245 -- Wasteland Relic
trinkets[122267] =  83246 -- Wasteland Sigil
trinkets[122268] =  83247 -- Wasteland Emblem
trinkets[122269] =  83248 -- Wasteland Insignia
trinkets[122270] =  83249 -- Wasteland Badge
trinkets[122309] =  83731 -- Mark of the Catacombs
trinkets[122310] =  83732 -- Sigil of the Catacombs
trinkets[122311] =  83733 -- Emblem of the Catacombs
trinkets[122312] =  83734 -- Medallion of the Catacombs
trinkets[122313] =  83735 -- Symbol of the Catacombs
trinkets[122314] =  83736 -- Sigil of Compassion
trinkets[122315] =  83737 -- Sigil of Fidelity
trinkets[122316] =  83738 -- Sigil of Grace
trinkets[122317] =  83739 -- Sigil of Patience
trinkets[122318] =  83740 -- Sigil of Devotion
trinkets[122687] =  84071 -- Charm of Ten Songs
trinkets[122688] =  84072 -- Braid of Ten Songs
trinkets[122689] =  84073 -- Knot of Ten Songs
trinkets[122691] =  84075 -- Relic of Kypari Zar
trinkets[122692] =  84076 -- Sigil of Kypari Zar
trinkets[122693] =  84077 -- Emblem of Kypari Zar
trinkets[122694] =  84078 -- Insignia of Kypari Zar
trinkets[122695] =  84079 -- Badge of Kypari Zar
trinkets[126236] = { -- Slippery
	 81243, -- Iron Protector Talisman
	 85181, -- Iron Protector Talisman
}
trinkets[126260] =  81181 -- Heart of Fire
trinkets[126266] =  81133 -- Enlightenment (Empty Fruit Barrel)
trinkets[126270] = { -- Vial of Ichorous Blood
	 81264, -- Vial of Ichorous Blood
	100963, -- Vial of Ichorous Blood
}
trinkets[126476] =  81192 -- Predation (Vision of the Predator)
trinkets[126478] = { -- Flashfreeze
	 81263, -- Flashfrozen Resin Globule
	100951, -- Flashfrozen Resin Globule
}
trinkets[126483] =  81125 -- Windswept Pages
trinkets[126484] = { -- Flashing Steel
	 81265, -- Flashing Steel Talisman
	 88294, -- Flashing Steel Talisman
}
trinkets[126489] = { -- Relentlessness
	 81267, -- Searing Words
	 88355, -- Searing Words
}
trinkets[126513] =  81138 -- Poised to Strike (Carbonic Carbuncle)
trinkets[126519] = { -- Lessons of the Darkmaster
	 81268, -- Lessons of the Darkmaster
	 88358, -- Lessons of the Darkmaster
}
trinkets[126533] = { -- Elusive
	 87063, -- Vial of Dragon's Blood
	 86131, -- Vial of Dragon's Blood
	 86790, -- Vial of Dragon's Blood
}
trinkets[126554] = { -- Agile
	 87057, -- Bottle of Infinite Stars
	 86132, -- Bottle of Infinite Stars
	 86791, -- Bottle of Infinite Stars
}
trinkets[126577] = { -- Inner Brilliance
	 87065, -- Light of the Cosmos
	 86133, -- Light of the Cosmos
	 86792, -- Light of the Cosmos
}
trinkets[126582] = { -- Unwavering Might
	 87072, -- Lei Shen's Final Orders
	 86144, -- Lei Shen's Final Orders
	 86802, -- Lei Shen's Final Orders
}
trinkets[126588] = { -- Arcane Secrets
	 87075, -- Qin-xi's Polarizing Seal
	 86147, -- Qin-xi's Polarizing Seal
	 86805, -- Qin-xi's Polarizing Seal
}
trinkets[126597] = { -- Jade Warlord Figurine
	 86046, -- Jade Warlord Figurine
	 89079, -- Lao-Chin's Liquid Courage
	 86775, -- Jade Warlord Figurine
}
trinkets[126599] = { -- Velocity
	 86042, -- Jade Charioteer Figurine
	 86043, -- Jade Bandit Figurine
	 89082, -- Hawkmaster's Talon
	 86771, -- Jade Charioteer Figurine
	 86772, -- Jade Bandit Figurine
}
trinkets[126605] = { -- Blossom
	 86044, -- Jade Magistrate Figurine
	 89081, -- Blossom of Pure Snow
	 86773, -- Jade Magistrate Figurine
}
trinkets[126606] = { -- Scroll of Revered Ancestors
	 86045, -- Jade Courtesan Figurine
	 89080, -- Scroll of Revered Ancestors
	 86774, -- Jade Courtesan Figurine
}
trinkets[126640] = { -- Radiance
	 87163, -- Spirits of the Sun
	 86327, -- Spirits of the Sun
	 86885, -- Spirits of the Sun
}
trinkets[126646] = { -- Untouchable
	 87160, -- Stuff of Nightmares
	 86323, -- Stuff of Nightmares
	 86881, -- Stuff of Nightmares
}
trinkets[126649] = { -- Unrelenting Attacks
	 87167, -- Terror in the Mists
	 86332, -- Terror in the Mists
	 86890, -- Terror in the Mists
}
trinkets[126657] = { -- Alacrity
	 87172, -- Darkmist Vortex
	 86336, -- Darkmist Vortex
	 86894, -- Darkmist Vortex
}
trinkets[126659] = { -- Quickened Tongues
	 87175, -- Essence of Terror
	 86388, -- Essence of Terror
	 86907, -- Essence of Terror
}
trinkets[126679] = { -- Call of Victory
	100500, -- Grievous Gladiator's Badge of Victory
	100579, -- Grievous Gladiator's Badge of Victory
	 91410, -- Tyrannical Gladiator's Badge of Victory
	 94349, -- Tyrannical Gladiator's Badge of Victory
	 99943, -- Tyrannical Gladiator's Badge of Victory
	100019, -- Tyrannical Gladiator's Badge of Victory
	 84942, -- Malevolent Gladiator's Badge of Victory
	 91763, -- Malevolent Gladiator's Badge of Victory
	 84490, -- Dreadful Gladiator's Badge of Victory
}
trinkets[126683] = { -- Call of Dominance
	100490, -- Grievous Gladiator's Badge of Dominance
	100576, -- Grievous Gladiator's Badge of Dominance
	 91400, -- Tyrannical Gladiator's Badge of Dominance
	 94346, -- Tyrannical Gladiator's Badge of Dominance
	 99937, -- Tyrannical Gladiator's Badge of Dominance
	100016, -- Tyrannical Gladiator's Badge of Dominance
	 84940, -- Malevolent Gladiator's Badge of Dominance
	 91753, -- Malevolent Gladiator's Badge of Dominance
	 84488, -- Dreadful Gladiator's Badge of Dominance
}
trinkets[126690] = { -- Call of Conquest
	100195, -- Grievous Gladiator's Badge of Conquest
	100603, -- Grievous Gladiator's Badge of Conquest
	 91099, -- Tyrannical Gladiator's Badge of Conquest
	 94373, -- Tyrannical Gladiator's Badge of Conquest
	 99772, -- Tyrannical Gladiator's Badge of Conquest
	100043, -- Tyrannical Gladiator's Badge of Conquest
	 84934, -- Malevolent Gladiator's Badge of Conquest
	 91452, -- Malevolent Gladiator's Badge of Conquest
	 84344, -- Dreadful Gladiator's Badge of Conquest
}
trinkets[126697] = { -- Tremendous Fortitude
	 96793, -- Fortitude of the Zandalari
	 96421, -- Fortitude of the Zandalari
	 96049, -- Fortitude of the Zandalari
	 94516, -- Fortitude of the Zandalari
	100305, -- Grievous Gladiator's Emblem of Cruelty
	100306, -- Grievous Gladiator's Emblem of Tenacity
	100307, -- Grievous Gladiator's Emblem of Meditation
	100559, -- Grievous Gladiator's Emblem of Meditation
	100626, -- Grievous Gladiator's Emblem of Cruelty
	100652, -- Grievous Gladiator's Emblem of Tenacity
	 95677, -- Fortitude of the Zandalari
	 91209, -- Tyrannical Gladiator's Emblem of Cruelty
	 91210, -- Tyrannical Gladiator's Emblem of Tenacity
	 91211, -- Tyrannical Gladiator's Emblem of Meditation
	 94329, -- Tyrannical Gladiator's Emblem of Meditation
	 94396, -- Tyrannical Gladiator's Emblem of Cruelty
	 94422, -- Tyrannical Gladiator's Emblem of Tenacity
	 99838, -- Tyrannical Gladiator's Emblem of Cruelty
	 99839, -- Tyrannical Gladiator's Emblem of Tenacity
	 99840, -- Tyrannical Gladiator's Emblem of Meditation
	 99990, -- Tyrannical Gladiator's Emblem of Meditation
	100066, -- Tyrannical Gladiator's Emblem of Cruelty
	100092, -- Tyrannical Gladiator's Emblem of Tenacity
	 84936, -- Malevolent Gladiator's Emblem of Cruelty
	 84938, -- Malevolent Gladiator's Emblem of Tenacity
	 84939, -- Malevolent Gladiator's Emblem of Meditation
	 91562, -- Malevolent Gladiator's Emblem of Cruelty
	 91563, -- Malevolent Gladiator's Emblem of Tenacity
	 91564, -- Malevolent Gladiator's Emblem of Meditation
	 84399, -- Dreadful Gladiator's Emblem of Cruelty
	 84400, -- Dreadful Gladiator's Emblem of Tenacity
	 84401, -- Dreadful Gladiator's Emblem of Meditation
}
trinkets[126700] = { -- Surge of Victory
	100505, -- Grievous Gladiator's Insignia of Victory
	100645, -- Grievous Gladiator's Insignia of Victory
	 91415, -- Tyrannical Gladiator's Insignia of Victory
	 94415, -- Tyrannical Gladiator's Insignia of Victory
	 99948, -- Tyrannical Gladiator's Insignia of Victory
	100085, -- Tyrannical Gladiator's Insignia of Victory
	 84937, -- Malevolent Gladiator's Insignia of Victory
	 91768, -- Malevolent Gladiator's Insignia of Victory
	 84495, -- Dreadful Gladiator's Insignia of Victory
}
trinkets[126705] = { -- Surge of Dominance
	100491, -- Grievous Gladiator's Insignia of Dominance
	100712, -- Grievous Gladiator's Insignia of Dominance
	 91401, -- Tyrannical Gladiator's Insignia of Dominance
	 94482, -- Tyrannical Gladiator's Insignia of Dominance
	 99938, -- Tyrannical Gladiator's Insignia of Dominance
	100152, -- Tyrannical Gladiator's Insignia of Dominance
	 84941, -- Malevolent Gladiator's Insignia of Dominance
	 91754, -- Malevolent Gladiator's Insignia of Dominance
	 84489, -- Dreadful Gladiator's Insignia of Dominance
}
trinkets[126707] = { -- Surge of Conquest
	100200, -- Grievous Gladiator's Insignia of Conquest
	100586, -- Grievous Gladiator's Insignia of Conquest
	 91104, -- Tyrannical Gladiator's Insignia of Conquest
	 94356, -- Tyrannical Gladiator's Insignia of Conquest
	 99777, -- Tyrannical Gladiator's Insignia of Conquest
	100026, -- Tyrannical Gladiator's Insignia of Conquest
	 84935, -- Malevolent Gladiator's Insignia of Conquest
	 91457, -- Malevolent Gladiator's Insignia of Conquest
	 84349, -- Dreadful Gladiator's Insignia of Conquest
}
trinkets[127549] =  87500 -- Munificence (Brooch of Munificent Deeds)
trinkets[127569] =  87499 -- Gleaming (Grakl's Gleaming Talisman)
trinkets[127572] =  87497 -- Karma (Core of Decency)
trinkets[127575] =  87495 -- Perfection (Gerp's Perfect Arrow)
trinkets[127577] =  87496 -- Final Word (Daelo's Final Words)
trinkets[127915] =  87573 -- Essence of Life (Thousand-Year Pickled Egg)
trinkets[127923] =  87572 -- Now is the time! (Mithril Wristwatch)
trinkets[127928] =  87574 -- Reflection of Torment (Coren's Cold Chromium Coaster)
trinkets[127967] =  87571 -- Drunken Evasiveness (Brawler's Statue)
trinkets[128386] =  88585 -- Mantid Poison (Dislodged Stinger)
trinkets[128519] =  88371 -- Watermelon Bomb
trinkets[128521] =  88376 -- Painted Turnip (Orange Painted Turnip)
trinkets[128984] =  79328 -- Blessing of the Celestials (Relic of Xuen)
trinkets[128985] =  79331 -- Blessing of the Celestials (Relic of Yu'lon)
trinkets[128986] =  79327 -- Blessing of the Celestials (Relic of Xuen)
trinkets[128987] =  79330 -- Blessing of the Celestials (Relic of Chi-Ji)
trinkets[128988] =  79329 -- Protection of the Celestials (Relic of Niuzao)
trinkets[129812] =  89083 -- Hunger (Iron Belly Wok)
trinkets[134944] =  92782 -- Footman's Resolve (Steadfast Footman's Medallion)
trinkets[134945] =  92784 -- SI:7 Training (SI:7 Operative's Manual)
trinkets[134953] =  92783 -- Grunt's Tenacity (Mark of the Hardened Grunt)
trinkets[134954] =  92785 -- Kor'kron Elite (Kor'kron Book of Hurting)
trinkets[136082] = { -- Static Charge
	 93254, -- Static-Caster's Medallion
	 93259, -- Shock-Charger Medallion
}
trinkets[136083] =  93255 -- Needle and Thread (Cutstitcher Medallion)
trinkets[136084] = { -- Sense for Weakness
	 93256, -- Skullrender Medallion
	 93261, -- Helmbreaker Medallion
}
trinkets[136085] = { -- Vapor Lock
	 93257, -- Medallion of Mystifying Vapors
	 93262, -- Vaporshield Medallion
}
trinkets[136086] = { -- Archer's Grace
	 93253, -- Woundripper Medallion
	 93258, -- Arrowflight Medallion
}
trinkets[136087] =  93260 -- Heartwarmer (Heartwarmer Medallion)
trinkets[136088] = { -- Deadeye
	 93341, -- Dominator's Deadeye Badge
	 93346, -- Deadeye Badge of the Shieldwall
}
trinkets[136089] = { -- Arcane Sight
	 93342, -- Dominator's Arcane Badge
	 93347, -- Arcane Badge of the Shieldwall
}
trinkets[136090] = { -- Mender's Charm
	 93343, -- Dominator's Mending Badge
	 93348, -- Mending Badge of the Shieldwall
}
trinkets[136091] = { -- Knightly Valor
	 93344, -- Dominator's Knightly Badge
	 93349, -- Knightly Badge of the Shieldwall
}
trinkets[136092] = { -- Superior Durability
	 93345, -- Dominator's Durable Badge
	 93350, -- Durable Badge of the Shieldwall
}
trinkets[137211] =  93900 -- Tremendous Fortitude (Inherited Mark of Tyranny)
trinkets[138699] =  94511 -- Superluminal (Vicious Talisman of the Shado-Pan Assault)
trinkets[138702] =  94508 -- Surge of Strength (Brutal Talisman of the Shado-Pan Assault)
trinkets[138703] =  94510 -- Acceleration (Volatile Talisman of the Shado-Pan Assault)
trinkets[138728] =  94507 -- Change of Tactics (Steadfast Talisman of the Shado-Pan Assault)
trinkets[138756] = { -- Blades of Renataki
	 96741, -- Renataki's Soul Charm
	 96369, -- Renataki's Soul Charm
	 95997, -- Renataki's Soul Charm
	 94512, -- Renataki's Soul Charm
	 95625, -- Renataki's Soul Charm
}
trinkets[138759] = { -- Feathers of Fury
	 96842, -- Fabled Feather of Ji-Kun
	 96470, -- Fabled Feather of Ji-Kun
	 96098, -- Fabled Feather of Ji-Kun
	 94515, -- Fabled Feather of Ji-Kun
	 95726, -- Fabled Feather of Ji-Kun
}
trinkets[138786] = { -- Wushoolay's Lightning
	 96785, -- Wushoolay's Final Choice
	 96413, -- Wushoolay's Final Choice
	 96041, -- Wushoolay's Final Choice
	 94513, -- Wushoolay's Final Choice
	 95669, -- Wushoolay's Final Choice
}
trinkets[138856] = { -- Cloudburst
	 96757, -- Horridon's Last Gasp
	 96385, -- Horridon's Last Gasp
	 96013, -- Horridon's Last Gasp
	 94514, -- Horridon's Last Gasp
	 95641, -- Horridon's Last Gasp
}
trinkets[138864] = { -- Blood of Power
	 96895, -- Delicate Vial of the Sanguinaire
	 96523, -- Delicate Vial of the Sanguinaire
	 96151, -- Delicate Vial of the Sanguinaire
	 94518, -- Delicate Vial of the Sanguinaire
	 95779, -- Delicate Vial of the Sanguinaire
}
trinkets[138870] = { -- Rampage
	 96873, -- Primordius' Talisman of Rage
	 96501, -- Primordius' Talisman of Rage
	 96129, -- Primordius' Talisman of Rage
	 94519, -- Primordius' Talisman of Rage
	 95757, -- Primordius' Talisman of Rage
}
trinkets[138895] = { -- Frenzy
	 96864, -- Talisman of Bloodlust
	 96492, -- Talisman of Bloodlust
	 96120, -- Talisman of Bloodlust
	 94522, -- Talisman of Bloodlust
	 95748, -- Talisman of Bloodlust
}
trinkets[138898] = { -- Breath of Many Minds
	 96827, -- Breath of the Hydra
	 96455, -- Breath of the Hydra
	 96083, -- Breath of the Hydra
	 94521, -- Breath of the Hydra
	 95711, -- Breath of the Hydra
}
trinkets[138925] = { -- Zandalari Warding
	 96879, -- Stolen Relic of Zuldazar
	 96507, -- Stolen Relic of Zuldazar
	 96135, -- Stolen Relic of Zuldazar
	 94525, -- Stolen Relic of Zuldazar
	 95763, -- Stolen Relic of Zuldazar
}
trinkets[138938] = { -- Juju Madness
	 96781, -- Bad Juju
	 96409, -- Bad Juju
	 96037, -- Bad Juju
	 94523, -- Bad Juju
	 95665, -- Bad Juju
}
trinkets[138963] = { -- Perfect Aim
	 96930, -- Unerring Vision of Lei Shen
	 96558, -- Unerring Vision of Lei Shen
	 96186, -- Unerring Vision of Lei Shen
	 94524, -- Unerring Vision of Lei Shen
	 95814, -- Unerring Vision of Lei Shen
}
trinkets[138967] = { -- Blessing of Zuldazar
	 96879, -- Stolen Relic of Zuldazar
	 96507, -- Stolen Relic of Zuldazar
	 96135, -- Stolen Relic of Zuldazar
	 94525, -- Stolen Relic of Zuldazar
	 95763, -- Stolen Relic of Zuldazar
}
trinkets[138979] = { -- Soul Barrier
	 96927, -- Soul Barrier
	 96555, -- Soul Barrier
	 96183, -- Soul Barrier
	 94528, -- Soul Barrier
	 95811, -- Soul Barrier
}
trinkets[139133] = { -- Mastermind
	 96888, -- Cha-Ye's Essence of Brilliance
	 96516, -- Cha-Ye's Essence of Brilliance
	 96144, -- Cha-Ye's Essence of Brilliance
	 94531, -- Cha-Ye's Essence of Brilliance
	 95772, -- Cha-Ye's Essence of Brilliance
}
trinkets[139170] = { -- Eye of Brutality
	 96915, -- Gaze of the Twins
	 96543, -- Gaze of the Twins
	 96171, -- Gaze of the Twins
	 94529, -- Gaze of the Twins
	 95799, -- Gaze of the Twins
}
trinkets[140380] = { -- Shield of Hydra Sputum
	 96828, -- Inscribed Bag of Hydra-Spawn
	 96456, -- Inscribed Bag of Hydra-Spawn
	 96084, -- Inscribed Bag of Hydra-Spawn
	 94520, -- Inscribed Bag of Hydra-Spawn
	 95712, -- Inscribed Bag of Hydra-Spawn
}
trinkets[144073] =  31615 -- Arcane Energy (Ancient Draenei Arcane Relic)
trinkets[144074] =  31617 -- Ferocity (Ancient Draenei War Talisman)
trinkets[144108] =  38073 -- Arcane Energy (Will of the Red Dragonflight)
trinkets[144129] = { -- Tremendous Fortitude
	 41587, -- Battlemaster's Celerity
	 41588, -- Battlemaster's Aggression
	 41589, -- Battlemaster's Resolve
	 41590, -- Battlemaster's Courage
}
trinkets[144130] =  39821 -- Spell Power (Spiritist's Focus)
trinkets[144201] =  55266 -- Herald of Doom (Grace of the Herald)
trinkets[144203] =  55237 -- Hardened Shell (Porcelain Crab)
trinkets[144205] =  55251 -- Typhoon (Might of the Ocean)
trinkets[146046] = { -- Expanded Mind
	105422, -- Purified Bindings of Immerseus
	104426, -- Purified Bindings of Immerseus
	105173, -- Purified Bindings of Immerseus
	102293, -- Purified Bindings of Immerseus
	104675, -- Purified Bindings of Immerseus
	104924, -- Purified Bindings of Immerseus
}
trinkets[146184] = { -- Wrath of the Darkspear
	105648, -- Black Blood of Y'Shaarj
	104652, -- Black Blood of Y'Shaarj
	105399, -- Black Blood of Y'Shaarj
	102310, -- Black Blood of Y'Shaarj
	104901, -- Black Blood of Y'Shaarj
	105150, -- Black Blood of Y'Shaarj
}
trinkets[146218] = { -- Yu'lon's Bite
	103987, -- Yu'lon's Bite
	103687, -- Yu'lon's Bite
}
trinkets[146245] = { -- Outrage
	105491, -- Evil Eye of Galakras
	104495, -- Evil Eye of Galakras
	105242, -- Evil Eye of Galakras
	102298, -- Evil Eye of Galakras
	104744, -- Evil Eye of Galakras
	104993, -- Evil Eye of Galakras
}
trinkets[146250] = { -- Determination
	105609, -- Thok's Tail Tip
	104613, -- Thok's Tail Tip
	105360, -- Thok's Tail Tip
	102305, -- Thok's Tail Tip
	104862, -- Thok's Tail Tip
	105111, -- Thok's Tail Tip
}
trinkets[146285] = { -- Cruelty
	105632, -- Skeer's Bloodsoaked Talisman
	104636, -- Skeer's Bloodsoaked Talisman
	105383, -- Skeer's Bloodsoaked Talisman
	102308, -- Skeer's Bloodsoaked Talisman
	104885, -- Skeer's Bloodsoaked Talisman
	105134, -- Skeer's Bloodsoaked Talisman
}
trinkets[146296] = { -- Celestial Celerity
	103989, -- Alacrity of Xuen
	103689, -- Alacrity of Xuen
}
trinkets[146308] = { -- Dextrous
	105472, -- Assurance of Consequence
	104476, -- Assurance of Consequence
	105223, -- Assurance of Consequence
	102292, -- Assurance of Consequence
	104725, -- Assurance of Consequence
	104974, -- Assurance of Consequence
}
trinkets[146310] = { -- Restless Agility
	105612, -- Ticking Ebon Detonator
	104616, -- Ticking Ebon Detonator
	105363, -- Ticking Ebon Detonator
	102311, -- Ticking Ebon Detonator
	104865, -- Ticking Ebon Detonator
	105114, -- Ticking Ebon Detonator
}
trinkets[146312] = { -- Celestial Master
	103986, -- Discipline of Xuen
	103686, -- Discipline of Xuen
}
trinkets[146314] = { -- Titanic Restoration
	105474, -- Prismatic Prison of Pride
	104478, -- Prismatic Prison of Pride
	105225, -- Prismatic Prison of Pride
	102299, -- Prismatic Prison of Pride
	104727, -- Prismatic Prison of Pride
	104976, -- Prismatic Prison of Pride
}
trinkets[146317] = { -- Restless Spirit
	105615, -- Dysmorphic Samophlange of Discontinuity
	104619, -- Dysmorphic Samophlange of Discontinuity
	105366, -- Dysmorphic Samophlange of Discontinuity
	102309, -- Dysmorphic Samophlange of Discontinuity
	104868, -- Dysmorphic Samophlange of Discontinuity
	105117, -- Dysmorphic Samophlange of Discontinuity
}
trinkets[146323] = { -- Inward Contemplation
	103988, -- Contemplation of Chi-Ji
	103688, -- Contemplation of Chi-Ji
}
trinkets[146343] = { -- Avoidance
	105438, -- Rook's Unlucky Talisman
	104442, -- Rook's Unlucky Talisman
	105189, -- Rook's Unlucky Talisman
	102296, -- Rook's Unlucky Talisman
	104691, -- Rook's Unlucky Talisman
	104940, -- Rook's Unlucky Talisman
}
trinkets[146344] = { -- Defensive Maneuvers
	103990, -- Resolve of Niuzao
	103690, -- Resolve of Niuzao
}
trinkets[146395] = { -- Tactician
	105645, -- Curse of Hubris
	104649, -- Curse of Hubris
	105396, -- Curse of Hubris
	102307, -- Curse of Hubris
	104898, -- Curse of Hubris
	105147, -- Curse of Hubris
}
trinkets[148388] = 103639 -- White Ash (Pouch of White Ash)
trinkets[148447] = 103678 -- Winds of Time (Time-Lost Artifact)
trinkets[148896] = { -- Ferocity
	105580, -- Sigil of Rampage
	104584, -- Sigil of Rampage
	105331, -- Sigil of Rampage
	102302, -- Sigil of Rampage
	104833, -- Sigil of Rampage
	105082, -- Sigil of Rampage
}
trinkets[148897] = { -- Extravagant Visions
	105572, -- Frenzied Crystal of Rage
	104576, -- Frenzied Crystal of Rage
	105323, -- Frenzied Crystal of Rage
	102303, -- Frenzied Crystal of Rage
	104825, -- Frenzied Crystal of Rage
	105074, -- Frenzied Crystal of Rage
}
trinkets[148899] = { -- Tenacious
	105459, -- Fusion-Fire Core
	104463, -- Fusion-Fire Core
	105210, -- Fusion-Fire Core
	102295, -- Fusion-Fire Core
	104712, -- Fusion-Fire Core
	104961, -- Fusion-Fire Core
}
trinkets[148903] = { -- Vicious
	105527, -- Haromm's Talisman
	104531, -- Haromm's Talisman
	105278, -- Haromm's Talisman
	102301, -- Haromm's Talisman
	104780, -- Haromm's Talisman
	105029, -- Haromm's Talisman
}
trinkets[148906] = { -- Toxic Power
	105540, -- Kardris' Toxic Totem
	104544, -- Kardris' Toxic Totem
	105291, -- Kardris' Toxic Totem
	102300, -- Kardris' Toxic Totem
	104793, -- Kardris' Toxic Totem
	105042, -- Kardris' Toxic Totem
}
trinkets[148908] = { -- Mark of Salvation
	105549, -- Nazgrim's Burnished Insignia
	104553, -- Nazgrim's Burnished Insignia
	105300, -- Nazgrim's Burnished Insignia
	102294, -- Nazgrim's Burnished Insignia
	104802, -- Nazgrim's Burnished Insignia
	105051, -- Nazgrim's Burnished Insignia
}
trinkets[148911] = { -- Soothing Power
	105607, -- Thok's Acid-Grooved Tooth
	104611, -- Thok's Acid-Grooved Tooth
	105358, -- Thok's Acid-Grooved Tooth
	102304, -- Thok's Acid-Grooved Tooth
	104860, -- Thok's Acid-Grooved Tooth
	105109, -- Thok's Acid-Grooved Tooth
}
-- Consumables
consumables[   673] =   5997 -- Minor Defense (Elixir of Minor Defense)
consumables[   833] =   1401 -- Green Tea (Riverpaw Tea Leaf)
consumables[  1090] =   2091 -- Sleep (Magic Dust)
consumables[  2367] =   2454 -- Lion's Strength (Elixir of Lion's Strength)
consumables[  2374] =   2457 -- Minor Agility (Elixir of Minor Agility)
consumables[  2378] =   2458 -- Minor Fortitude (Elixir of Minor Fortitude)
consumables[  2379] = { -- Speed
	  2459, -- Swiftness Potion
	 54213, -- Molotov Cocktail
}
consumables[  2380] =   3384 -- Resistance (Minor Magic Resistance Potion)
consumables[  2823] = { -- Deadly Poison
	 43232, -- Deadly Poison
	 22053, -- Deadly Poison
}
consumables[  3160] =   3390 -- Lesser Agility (Elixir of Lesser Agility)
consumables[  3164] =   3391 -- Ogre's Strength (Elixir of Ogre's Strength)
consumables[  3166] =   3383 -- Wisdom (Elixir of Wisdom)
consumables[  3169] =   3387 -- Invulnerability (Limited Invulnerability Potion)
consumables[  3219] =   3382 -- Weak Troll's Blood (Weak Troll's Blood Elixir)
consumables[  3220] =   3389 -- Defense (Elixir of Defense)
consumables[  3222] =   3388 -- Strong Troll's Blood Elixir
consumables[  3223] =   3826 -- Major Troll's Blood Elixir
consumables[  3593] =   3825 -- Elixir of Fortitude
consumables[  3680] =   3823 -- Lesser Invisibility (Lesser Invisibility Potion)
consumables[  4941] =   4623 -- Stoneshield (Lesser Stoneshield Potion)
consumables[  5665] =   5206 -- Fury of the Bogling (Bogling Root)
consumables[  6114] =   5342 -- Raptor Punch
consumables[  6196] =  83795 -- Far Sight (Scrying Roguestone)
consumables[  6262] =   5512 -- Healthstone
consumables[  6405] =  66888 -- Furbolg Form (Stave of Fur and Claw)
consumables[  6512] =   3828 -- Detect Lesser Invisibility (Elixir of Detect Lesser Invisibility)
consumables[  6615] =   5634 -- Free Action (Free Action Potion)
consumables[  6724] =   5816 -- Light of Elune
consumables[  7178] =   5996 -- Water Breathing (Elixir of Water Breathing)
consumables[  7233] =   6049 -- Fire Protection (Fire Protection Potion)
consumables[  7239] =   6050 -- Frost Protection (Frost Protection Potion)
consumables[  7242] =   6048 -- Shadow Protection (Shadow Protection Potion)
consumables[  7245] =   6051 -- Holy Protection (Holy Protection Potion)
consumables[  7254] =   6052 -- Nature Protection (Nature Protection Potion)
consumables[  7840] =   6372 -- Swim Speed (Swim Speed Potion)
consumables[  7844] =   6373 -- Fire Power (Elixir of Firepower)
consumables[  8063] =   6522 -- Deviate Fish
consumables[  8091] =   3013 -- Armor (Scroll of Protection)
consumables[  8094] =   1478 -- Armor (Scroll of Protection II)
consumables[  8095] =   4421 -- Armor (Scroll of Protection III)
consumables[  8096] =    955 -- Intellect (Scroll of Intellect)
consumables[  8097] =   2290 -- Intellect (Scroll of Intellect II)
consumables[  8098] =   4419 -- Intellect (Scroll of Intellect III)
consumables[  8099] =   1180 -- Stamina (Scroll of Stamina)
consumables[  8100] =   1711 -- Stamina (Scroll of Stamina II)
consumables[  8101] =   4422 -- Stamina (Scroll of Stamina III)
consumables[  8112] =   1181 -- Spirit (Scroll of Spirit)
consumables[  8113] =   1712 -- Spirit (Scroll of Spirit II)
consumables[  8114] =   4424 -- Spirit (Scroll of Spirit III)
consumables[  8115] =   3012 -- Agility (Scroll of Agility)
consumables[  8116] =   1477 -- Agility (Scroll of Agility II)
consumables[  8117] =   4425 -- Agility (Scroll of Agility III)
consumables[  8118] =    954 -- Strength (Scroll of Strength)
consumables[  8119] =   2289 -- Strength (Scroll of Strength II)
consumables[  8120] =   4426 -- Strength (Scroll of Strength III)
consumables[  8212] =   6662 -- Giant Growth (Elixir of Giant Growth)
consumables[  8213] =   6657 -- Cooked Deviate Fish (Savory Deviate Delight)
consumables[  8679] =  43230 -- Wound Poison (Instant Poison)
consumables[ 10667] =   8410 -- Rage of Ages (R.O.I.D.S.)
consumables[ 10668] =   8411 -- Spirit of Boar (Lung Juice Cocktail)
consumables[ 10669] =   8412 -- Strike of the Scorpok (Ground Scorpok Assay)
consumables[ 10692] =   8423 -- Infallible Mind (Cerebral Cortex Compound)
consumables[ 10693] =   8424 -- Spiritual Domination (Gizzard Gum)
consumables[ 11007] = { -- Weak Alcohol
	 83095, -- Lagrave Stout
	 82343, -- Lordaeron Lambic
	 81407, -- Four Wind Soju
	 44616, -- Glass of Dalaran White
	 44570, -- Glass of Eversong Wine
	 40035, -- Northrend Honey Mead
	 98157, -- Big Blossom Brew
	 61982, -- Fizzy Fruit Wine
	  2686, -- Thunder Ale
	  2723, -- Bottle of Dalaran Noir
	  2894, -- Rhapsody Malt
	 19222, -- Cheap Beer
	 17196, -- Holiday Spirits
}
consumables[ 11008] = { -- Standard Alcohol
	 44618, -- Glass of Aged Dalaran Red
	 44619, -- Glass of Peaked Dalaran Red
	 40036, -- Snowplum Brandy
	 17403, -- Steamwheedle Fizzy Spirits
	 11846, -- Wizbang's Special Brew
	 44571, -- Bottle of Silvermoon Port
	 44575, -- Flask of Bitter Cactus Cider
	 62908, -- Hair of the Dog
	 61984, -- Potent Pineapple Punch
	 61983, -- Imported E.K. Ale
	  2596, -- Skin of Dwarven Stout
	  2593, -- Flask of Stormwind Tawny
	 44617, -- Glass of Dalaran Red
	 63292, -- Disgusting Rotgut
	 63293, -- Blackheart Grog
	 63296, -- Embalming Fluid
	 63299, -- Sunkissed Wine
	 63291, -- Blood Red Ale
	 63275, -- Gilnean Fortified Brandy
	 57543, -- Stormhammer Stout
	  3703, -- Southshore Stout
	 18287, -- Evermurky
}
consumables[ 11009] = { -- Strong Alcohol
	 88531, -- Lao Chin's Last Mug
	 81415, -- Pandaren Plum Wine
	 83094, -- Foote Tripel
	 82344, -- Hearthglen Ambrosia
	 89683, -- Hozen Cuervo
	 32667, -- Bash Ale
	 17402, -- Greatfather's Winter Ale
	 64639, -- Silversnap Ice
	 61986, -- Tol Barad Coconut Rum
	 44574, -- Skin of Mulgore Firewater
	  2595, -- Jug of Badlands Bourbon
	 38432, -- Plugger's Blackrock Ale
	 40042, -- Caraway Burnwine
	 44573, -- Cup of Frog Venom Brew
	 61985, -- Banana Cocktail
	  2594, -- Flagon of Dwarven Mead
	  4600, -- Cherry Grog
	 43696, -- Half Empty Bottle of Prison Moonshine
	 28284, -- Don Carlos Tequila
	 29112, -- Cenarion Spirits
	 38350, -- Winterfin "Depth Charge"
	 43695, -- Half Full Bottle of Prison Moonshine
	 93208, -- Darkmoon P.I.E.
	 62790, -- Darkbrew Lager
	 62674, -- Highland Spirits
	  4595, -- Junglevine Wine
	 18288, -- Molasses Firewater
	  9260, -- Volatile Rum
	  9360, -- Cuergo's Gold
}
consumables[ 11319] =   8827 -- Water Walking (Elixir of Water Walking)
consumables[ 11328] =   8949 -- Agility (Elixir of Agility)
consumables[ 11334] =   9187 -- Greater Agility (Elixir of Greater Agility)
consumables[ 11348] =  13445 -- Greater Armor (Elixir of Superior Defense)
consumables[ 11349] =   8951 -- Armor (Elixir of Greater Defense)
consumables[ 11350] =   8956 -- Fire Shield (Oil of Immolation)
consumables[ 11359] =   9030 -- Restoration (Restorative Potion)
consumables[ 11364] =   9036 -- Resistance (Magic Resistance Potion)
consumables[ 11371] =   9088 -- Gift of Arthas
consumables[ 11389] =   9154 -- Detect Undead (Elixir of Detect Undead)
consumables[ 11390] =   9155 -- Arcane Elixir
consumables[ 11392] =   9172 -- Invisibility (Invisibility Potion)
consumables[ 11396] =   9179 -- Greater Intellect (Elixir of Greater Intellect)
consumables[ 11403] =   9197 -- Dream Vision (Elixir of Dream Vision)
consumables[ 11405] =   9206 -- Elixir of the Giants (Elixir of Giants)
consumables[ 11406] =   9224 -- Elixir of Demonslaying
consumables[ 11407] =   9233 -- Detect Demon (Elixir of Detect Demon)
consumables[ 11474] =   9264 -- Shadow Power (Elixir of Shadow Power)
consumables[ 11629] = { -- Potent Alcohol
	 12003, -- Dark Dwarven Lager
	 23848, -- Nethergarde Bitter
	 44716, -- Mysterious Fermented Liquid
	 61384, -- Doublerum
	 19221, -- Darkmoon Special Reserve
	  9361, -- Cuergo's Gold with Worm
}
consumables[ 12174] =  10309 -- Agility (Scroll of Agility IV)
consumables[ 12175] =  10305 -- Armor (Scroll of Protection IV)
consumables[ 12176] =  10308 -- Intellect (Scroll of Intellect IV)
consumables[ 12177] =  10306 -- Spirit (Scroll of Spirit IV)
consumables[ 12178] =  10307 -- Stamina (Scroll of Stamina IV)
consumables[ 12179] =  10310 -- Strength (Scroll of Strength IV)
consumables[ 12608] =  10592 -- Catseye Elixir
consumables[ 15822] =  12190 -- Dreamless Sleep (Dreamless Sleep Potion)
consumables[ 15852] =  12217 -- Dragonbreath Chili
consumables[ 17038] =  12820 -- Winterfall Firewater
consumables[ 17528] =  13442 -- Mighty Rage (Mighty Rage Potion)
consumables[ 17535] =  13447 -- Elixir of the Sages
consumables[ 17537] =  13453 -- Elixir of Brute Force
consumables[ 17538] =  13452 -- Elixir of the Mongoose
consumables[ 17539] =  13454 -- Greater Arcane Elixir
consumables[ 17540] =  13455 -- Greater Stoneshield (Greater Stoneshield Potion)
consumables[ 17543] =  13457 -- Fire Protection (Greater Fire Protection Potion)
consumables[ 17544] =  13456 -- Frost Protection (Greater Frost Protection Potion)
consumables[ 17545] =  13460 -- Holy Protection (Greater Holy Protection Potion)
consumables[ 17546] =  13458 -- Nature Protection (Greater Nature Protection Potion)
consumables[ 17548] =  13459 -- Shadow Protection (Greater Shadow Protection Potion)
consumables[ 17549] =  13461 -- Arcane Protection (Greater Arcane Protection Potion)
consumables[ 17624] =  13506 -- Petrification (Potion of Petrification)
consumables[ 17626] =  13510 -- Flask of the Titans
consumables[ 17627] =  13511 -- Distilled Wisdom (Flask of Distilled Wisdom)
consumables[ 17628] =  13512 -- Supreme Power (Flask of Supreme Power)
consumables[ 17629] =  13513 -- Chromatic Resistance (Flask of Chromatic Resistance)
consumables[ 18071] =  13724 -- Enriched Manna Biscuit
consumables[ 18124] =  13810 -- Blessed Sunfruit
consumables[ 21149] =  17198 -- Egg Nog (Winter Veil Egg Nog)
consumables[ 21920] =  17708 -- Frost Power (Elixir of Frost Power)
consumables[ 21955] =  17747 -- Razorlash Root
consumables[ 22807] = { -- Greater Water Breathing
	 25539, -- Potion of Water Breathing
	 18294, -- Elixir of Greater Water Breathing
}
consumables[ 23692] =  19301 -- Alterac Manna Biscuit
consumables[ 24360] =  20002 -- Greater Dreamless Sleep (Greater Dreamless Sleep Potion)
consumables[ 24361] =  20004 -- Mighty Troll's Blood Elixir
consumables[ 24363] =  20007 -- Mageblood Elixir
consumables[ 24364] =  20008 -- Living Free Action (Living Action Potion)
consumables[ 24382] =  20079 -- Spirit of Zanza
consumables[ 24383] =  20081 -- Swiftness of Zanza
consumables[ 24417] =  20080 -- Sheen of Zanza
consumables[ 25037] =  20709 -- Rumsey Rum Light
consumables[ 25690] =  21072 -- Brain Food (Smoked Sagefish)
consumables[ 25691] =  21217 -- Brain Food (Sagefish Delight)
consumables[ 25722] =  21114 -- Rumsey Rum Dark
consumables[ 25851] =  21171 -- Lightheaded (Filled Festive Mug)
consumables[ 25990] =  21215 -- Graccu's Mince Meat Fruitcake
consumables[ 26030] =  11950 -- Windblossom Berries
consumables[ 26276] =  21546 -- Greater Firepower (Elixir of Greater Firepower)
consumables[ 26389] =  21721 -- Moonglow Alcohol (Moonglow)
consumables[ 27571] =  22218 -- Cascade of Roses (Handful of Rose Petals)
consumables[ 28489] =  22823 -- Camouflage (Elixir of Camouflage)
consumables[ 28490] =  22824 -- Major Strength (Elixir of Major Strength)
consumables[ 28491] =  22825 -- Healing Power (Elixir of Healing Power)
consumables[ 28492] =  22826 -- Sneaking (Sneaking Potion)
consumables[ 28493] =  22827 -- Major Frost Power (Elixir of Major Frost Power)
consumables[ 28494] =  22828 -- Insane Strength Potion
consumables[ 28496] =  22830 -- Greater Stealth Detection (Elixir of the Searching Eye)
consumables[ 28497] =  39666 -- Mighty Agility (Elixir of Mighty Agility)
consumables[ 28501] =  22833 -- Major Firepower (Elixir of Major Firepower)
consumables[ 28502] =  22834 -- Major Armor (Elixir of Major Defense)
consumables[ 28503] =  22835 -- Major Shadow Power (Elixir of Major Shadow Power)
consumables[ 28504] =  22836 -- Major Dreamless Sleep (Major Dreamless Sleep Potion)
consumables[ 28506] =  22837 -- Potion of Heroes (Heroic Potion)
consumables[ 28507] =  22838 -- Haste (Haste Potion)
consumables[ 28508] =  22839 -- Destruction (Destruction Potion)
consumables[ 28509] =  22840 -- Greater Mana Regeneration (Elixir of Major Mageblood)
consumables[ 28511] = { -- Fire Protection
	 32846, -- Major Fire Protection Potion
	 22841, -- Major Fire Protection Potion
}
consumables[ 28512] = { -- Frost Protection
	 32847, -- Major Frost Protection Potion
	 22842, -- Major Frost Protection Potion
}
consumables[ 28513] = { -- Nature Protection
	 32844, -- Major Nature Protection Potion
	 22844, -- Major Nature Protection Potion
}
consumables[ 28515] =  22849 -- Ironshield (Ironshield Potion)
consumables[ 28518] =  22851 -- Flask of Fortification
consumables[ 28519] =  22853 -- Flask of Mighty Restoration
consumables[ 28520] =  22854 -- Flask of Relentless Assault
consumables[ 28521] =  22861 -- Flask of Blinding Light
consumables[ 28536] = { -- Arcane Protection
	 32840, -- Major Arcane Protection Potion
	 22845, -- Major Arcane Protection Potion
}
consumables[ 28537] = { -- Shadow Protection
	 32845, -- Major Shadow Protection Potion
	 22846, -- Major Shadow Protection Potion
}
consumables[ 28538] =  22847 -- Holy Protection (Major Holy Protection Potion)
consumables[ 28540] =  22866 -- Flask of Pure Death
consumables[ 29271] =  23334 -- Power Surge (Cracked Power Core)
consumables[ 29308] =  23381 -- Power Surge (Chipped Power Core)
consumables[ 29348] =  23444 -- Goldenmist Special Brew
consumables[ 30167] =  49704 -- Red Ogre Costume (Carved Ogre Idol)
consumables[ 30550] =  23862 -- Redemption of the Fallen
consumables[ 30557] =  23865 -- Wrath of the Titans
consumables[ 30562] =  23857 -- Legacy of the Mountain King
consumables[ 30567] =  23864 -- Torment of the Worgen
consumables[ 31367] =  24268 -- Netherweave Net
consumables[ 32304] =  25548 -- Tallstalk Mushroom
consumables[ 32305] =  25550 -- Toadstool Toxin (Redcap Toadstool)
consumables[ 33077] =  27498 -- Agility (Scroll of Agility V)
consumables[ 33078] =  27499 -- Intellect (Scroll of Intellect V)
consumables[ 33079] =  27500 -- Armor (Scroll of Protection V)
consumables[ 33080] =  27501 -- Spirit (Scroll of Spirit V)
consumables[ 33081] =  27502 -- Stamina (Scroll of Stamina V)
consumables[ 33082] =  27503 -- Strength (Scroll of Strength V)
consumables[ 33720] =  28102 -- Onslaught Elixir
consumables[ 33721] =  40070 -- Spellpower Elixir
consumables[ 33726] =  28104 -- Elixir of Mastery
consumables[ 33772] =  28112 -- Underspore Pod
consumables[ 35474] =  29532 -- Drums of Panic
consumables[ 35475] =  29528 -- Drums of War
consumables[ 35476] =  29529 -- Drums of Battle
consumables[ 35477] =  29530 -- Drums of Speed
consumables[ 35478] =  29531 -- Drums of Restoration
consumables[ 38908] =  31676 -- Fel Regeneration Potion
consumables[ 38929] =  31677 -- Fel Mana (Fel Mana Potion)
consumables[ 38954] =  31679 -- Fel Strength Elixir
consumables[ 39625] =  32062 -- Elixir of Major Fortitude
consumables[ 39626] =  32063 -- Earthen Elixir
consumables[ 39627] =  32067 -- Elixir of Draenic Wisdom
consumables[ 39628] =  32068 -- Elixir of Ironskin
consumables[ 40567] =  32599 -- Unstable Flask of the Bandit
consumables[ 40568] =  32596 -- Unstable Flask of the Elder
consumables[ 40572] =  32598 -- Unstable Flask of the Beast
consumables[ 40573] =  32600 -- Unstable Flask of the Physician
consumables[ 40575] =  32597 -- Unstable Flask of the Soldier
consumables[ 40576] =  32601 -- Unstable Flask of the Sorcerer
consumables[ 41031] =  32722 -- Enriched Terocone Juice
consumables[ 41608] =  32901 -- Relentless Assault of Shattrath (Shattrath Flask of Relentless Assault)
consumables[ 41609] =  32898 -- Fortification of Shattrath (Shattrath Flask of Fortification)
consumables[ 41610] =  32899 -- Mighty Restoration of Shattrath (Shattrath Flask of Mighty Restoration)
consumables[ 41611] =  32900 -- Supreme Power of Shattrath (Shattrath Flask of Supreme Power)
consumables[ 42667] =  33176 -- Flying Broom
consumables[ 42735] =  33208 -- Chromatic Wonder (Flask of Chromatic Wonder)
consumables[ 43194] =  33457 -- Agility (Scroll of Agility VI)
consumables[ 43195] =  33458 -- Intellect (Scroll of Intellect VI)
consumables[ 43196] =  33459 -- Armor (Scroll of Protection VI)
consumables[ 43197] =  33460 -- Spirit (Scroll of Spirit VI)
consumables[ 43198] =  33461 -- Stamina (Scroll of Stamina VI)
consumables[ 43199] =  33462 -- Strength (Scroll of Strength VI)
consumables[ 43730] =  33866 -- Electrified (Stormchops)
consumables[ 43771] =  43005 -- Pet Treat (Spiced Mammoth Treats)
consumables[ 43816] =  33930 -- Charm of the Bloodletter (Amani Charm of the Bloodletter)
consumables[ 43818] =  33931 -- Charm of Mighty Mojo (Amani Charm of Mighty Mojo)
consumables[ 43820] =  33932 -- Charm of the Witch Doctor (Amani Charm of the Witch Doctor)
consumables[ 43822] =  33933 -- Charm of the Raging Defender (Amani Charm of the Raging Defender)
consumables[ 44467] =  34130 -- Recovery Diver's Potion
consumables[ 44755] =  34191 -- Snowflakes (Handful of Snowflakes)
consumables[ 45373] =  34537 -- Bloodberry (Bloodberry Elixir)
consumables[ 45694] =  34832 -- Captain Rumsey's Lager
consumables[ 46837] =  35716 -- Pure Death of Shattrath (Shattrath Flask of Pure Death)
consumables[ 46839] =  35717 -- Blinding Light of Shattrath (Shattrath Flask of Blinding Light)
consumables[ 46927] =  35720 -- Strong Alcohol (Lord of Frost's Private Label)
consumables[ 47430] =  36770 -- Undigestible (Zort's Protective Elixir)
consumables[ 47977] =  37011 -- Magic Broom
consumables[ 48099] =  37091 -- Intellect (Scroll of Intellect VII)
consumables[ 48100] =  37092 -- Intellect (Scroll of Intellect VIII)
consumables[ 48101] =  37093 -- Stamina (Scroll of Stamina VII)
consumables[ 48102] =  37094 -- Stamina (Scroll of Stamina VIII)
consumables[ 48103] =  37097 -- Spirit (Scroll of Spirit VII)
consumables[ 48104] =  37098 -- Spirit (Scroll of Spirit VIII)
consumables[ 48719] =  37449 -- Water Breathing (Breath of Murloc)
consumables[ 49512] =   1399 -- Fireball (Magic Candle)
consumables[ 50809] =  38351 -- Murliver Oil
consumables[ 50986] =  38466 -- Sulfuron Slammer
consumables[ 53746] =  40068 -- Wrath Elixir
consumables[ 53747] =  40072 -- Elixir of Spirit
consumables[ 53748] =  40073 -- Mighty Strength (Elixir of Mighty Strength)
consumables[ 53749] =  40076 -- Guru's Elixir
consumables[ 53751] =  40078 -- Elixir of Mighty Fortitude
consumables[ 53752] =  40079 -- Lesser Flask of Toughness
consumables[ 53753] =  40081 -- Nightmare Slumber (Potion of Nightmares)
consumables[ 53755] =  46376 -- Flask of the Frost Wyrm
consumables[ 53758] =  46379 -- Flask of Stoneblood
consumables[ 53760] =  46377 -- Flask of Endless Rage
consumables[ 53762] =  40093 -- Indestructible (Indestructible Potion)
consumables[ 53763] =  40097 -- Protection (Elixir of Protection)
consumables[ 53764] =  40109 -- Mighty Mana Regeneration (Elixir of Mighty Mageblood)
consumables[ 53908] =  40211 -- Speed (Potion of Speed)
consumables[ 53909] =  40212 -- Wild Magic (Potion of Wild Magic)
consumables[ 53910] =  40213 -- Arcane Protection (Mighty Arcane Protection Potion)
consumables[ 53911] =  40214 -- Fire Protection (Mighty Fire Protection Potion)
consumables[ 53913] =  40215 -- Frost Protection (Mighty Frost Protection Potion)
consumables[ 53914] =  40216 -- Nature Protection (Mighty Nature Protection Potion)
consumables[ 53915] =  40217 -- Shadow Protection (Mighty Shadow Protection Potion)
consumables[ 54212] =  46378 -- Flask of Pure Mojo
consumables[ 54452] =  28103 -- Adept's Elixir
consumables[ 54494] =  22831 -- Major Agility (Elixir of Major Agility)
consumables[ 54497] =   1177 -- Lesser Armor (Oil of Olaf)
consumables[ 55346] =  41367 -- Dark Jade Beam (Dark Jade Focusing Lens)
consumables[ 55536] =  41509 -- Frostweave Net
consumables[ 56190] =  42420 -- Shadow Crystal Focusing Lens
consumables[ 56191] =  42421 -- Shadow Jade Focusing Lens
consumables[ 57388] =  43004 -- Critter Bite (Critter Bites)
consumables[ 58448] =  43465 -- Strength (Scroll of Strength VII)
consumables[ 58449] =  43466 -- Strength (Scroll of Strength VIII)
consumables[ 58450] =  43463 -- Agility (Scroll of Agility VII)
consumables[ 58451] =  43464 -- Agility (Scroll of Agility VIII)
consumables[ 58452] =  43467 -- Armor (Scroll of Protection VII)
consumables[ 58496] =  43488 -- Sad (Last Week's Mammoth)
consumables[ 58499] =  43490 -- Happy (Tasty Cupcake)
consumables[ 58500] =  43491 -- Angry (Bad Clams)
consumables[ 58502] =  43492 -- Scared (Haunted Herring)
consumables[ 59640] =  44012 -- Underbelly Elixir
consumables[ 60106] =  44114 -- Old Spices
consumables[ 60122] =  44228 -- Baby Spice
consumables[ 60340] =  44325 -- Accuracy (Elixir of Accuracy)
consumables[ 60341] =  44327 -- Deadly Strikes (Elixir of Deadly Strikes)
consumables[ 60343] =  44328 -- Mighty Defense (Elixir of Mighty Defense)
consumables[ 60344] =  44329 -- Expertise (Elixir of Expertise)
consumables[ 60346] =  44331 -- Lightning Speed (Elixir of Lightning Speed)
consumables[ 60347] =  44332 -- Mighty Thoughts (Elixir of Mighty Thoughts)
consumables[ 62061] =  21213 -- Festive Holiday Mount (Preserved Holly)
consumables[ 62062] =  37816 -- Brewfestive Holiday Mount (Preserved Brewfest Hops)
consumables[ 62380] =  44939 -- Lesser Flask of Resistance
consumables[ 63729] =  45621 -- Minor Accuracy (Elixir of Minor Accuracy)
consumables[ 65247] =  33874 -- Really Well Fed (Kibler's Bits)
consumables[ 65451] =  46709 -- Using MiniZep Controller (MiniZep Controller)
consumables[ 68417] = { -- Wrapping Paper - Dummy Spell
	  5048, -- Blue Ribboned Wrapping Paper
	 17303, -- Blue Ribboned Wrapping Paper
	 17304, -- Green Ribboned Wrapping Paper
	 17307, -- Purple Ribboned Wrapping Paper
	  5042, -- Red Ribboned Wrapping Paper
}
consumables[ 69377] =  49632 -- Fortitude (Runescroll of Fortitude)
consumables[ 73320] =  52201 -- Frostborn Illusion (Muradin's Favor)
consumables[ 73619] =  52490 -- Stardust
consumables[ 75148] =  54442 -- Embersilk Net
consumables[ 78164] =  49634 -- Drums of the Wild
consumables[ 78993] =  57194 -- Concentration (Potion of Concentration)
consumables[ 79468] =  58084 -- Ghost Elixir
consumables[ 79469] =  58085 -- Flask of Steelskin
consumables[ 79470] =  58086 -- Flask of the Draconic Mind
consumables[ 79471] =  58087 -- Flask of the Winds
consumables[ 79472] =  58088 -- Flask of Titanic Strength
consumables[ 79474] =  58089 -- Elixir of the Naga
consumables[ 79475] =  58090 -- Earthen Armor (Earthen Potion)
consumables[ 79476] =  58091 -- Volcanic Power (Volcanic Potion)
consumables[ 79477] =  58092 -- Elixir of the Cobra
consumables[ 79480] =  58093 -- Elixir of Deep Earth
consumables[ 79481] =  58094 -- Impossible Accuracy (Elixir of Impossible Accuracy)
consumables[ 79625] =  58142 -- Deathblood Venom
consumables[ 79632] =  58144 -- Mighty Speed (Elixir of Mighty Speed)
consumables[ 79633] =  58145 -- Tol'vir Agility (Potion of the Tol'vir)
consumables[ 79634] =  58146 -- Golem's Strength (Golemblood Potion)
consumables[ 79635] =  58148 -- Elixir of the Master
consumables[ 80263] =  58488 -- Potion of Treasure Finding
consumables[ 80532] =  44330 -- Armor Piercing (Elixir of Armor Piercing)
consumables[ 80760] =  58933 -- Westfall Mud Pie
consumables[ 85624] =  61381 -- Yance's Special Burger (Yance's Special Burger Patty)
consumables[ 86507] =  62251 -- Fortitude (Runescroll of Fortitude II)
consumables[ 87648] =  62675 -- Starfire Espresso
consumables[ 87649] =  62680 -- Satisfied (Chocolate Cookie)
consumables[ 89342] =  63307 -- Spirit (Scroll of Spirit IX)
consumables[ 89343] =  63303 -- Agility (Scroll of Agility IX)
consumables[ 89344] =  63308 -- Armor (Scroll of Protection IX)
consumables[ 89345] =  63306 -- Stamina (Scroll of Stamina IX)
consumables[ 89346] =  63304 -- Strength (Scroll of Strength IX)
consumables[ 89347] =  63305 -- Intellect (Scroll of Intellect IX)
consumables[ 91722] =  64640 -- Puffer Breath (Infectis Puffer Sashimi)
consumables[ 91754] =  64481 -- Receive the Blessing of the Old God (Blessing of the Old God)
consumables[ 91760] =  64646 -- Endure the Transformation (Bones of Transformation)
consumables[ 91771] =  64651 -- Wisp Form (Wisp Amulet)
consumables[ 92146] =  64881 -- Scarab Storm (Pendant of the Scarab Storm)
consumables[ 94160] =  67438 -- Flask of Flowing Water
consumables[ 96312] =  68806 -- Kalytha's Haunted Locket
consumables[ 97020] =  69027 -- Eat Cone of Cold (Cone of Cold)
consumables[ 97602] =  69233 -- Eat Cone of Cold (Cone of Cold)
consumables[102362] =  72159 -- Red Ogre Mage Costume (Magical Ogre Idol)
consumables[102365] =  72161 -- Spurious Sarcophagus
consumables[105681] =  76075 -- Mantid Elixir
consumables[105682] =  76076 -- Mad Hozen Elixir
consumables[105683] =  76077 -- Elixir of Weaponry
consumables[105684] =  76078 -- Elixir of the Rapids
consumables[105685] =  76079 -- Elixir of Peace
consumables[105686] =  76080 -- Elixir of Perfection
consumables[105687] =  76081 -- Elixir of Mirrors
consumables[105688] =  76083 -- Monk's Elixir
consumables[105689] =  76084 -- Flask of Spring Blossoms
consumables[105691] =  76085 -- Flask of the Warm Sun
consumables[105693] =  76086 -- Flask of Falling Leaves
consumables[105694] =  76087 -- Flask of the Earth
consumables[105696] =  76088 -- Flask of Winter's Bite
consumables[105697] =  76089 -- Virmen's Bite
consumables[105698] =  76090 -- Potion of the Mountains
consumables[105699] =  76091 -- Greater Potion of Luck
consumables[105701] =  76092 -- Potion of Focus
consumables[105702] =  76093 -- Potion of the Jade Serpent
consumables[105706] =  76095 -- Potion of Mogu Power
consumables[105707] =  76096 -- Darkwater Potion
consumables[109933] =  78883 -- Darkmoon Firewater
consumables[111922] =  79257 -- Fortitude (Runescroll of Fortitude III)
consumables[113095] =  79769 -- Demon Hunter's Aspect
consumables[115037] =  80313 -- Ling-Ting's Herbal Journey (Ling-Ting's Favorite Tea)
consumables[125167] =  85973 -- Ancient Pandaren Fishing Charm
consumables[125686] =  86432 -- Banana Infused Rum
consumables[125879] =  86508 -- Fresh Bread
consumables[126144] =  87264 -- Four Senses Brew
consumables[126294] =  86607 -- Goblin Dragon Gun, Mark II
consumables[127145] =  87528 -- Honorary Brewmaster Keg
consumables[127207] =  86568 -- Memory of Mr. Smite (Mr. Smite's Brass Compass)
consumables[127230] =  86569 -- Visions of Insanity (Crystal of Insanity)
consumables[127249] =  86573 -- Flesh to Stone (Shard of Archstone)
consumables[127261] = { -- Stonebinding
	 86571, -- Kang's Bindstone
	104262, -- Odd Polished Stone
}
consumables[127266] =  86577 -- Amber Prison (Rod of Ambershaping)
consumables[127269] =  86578 -- Everlasting Frenzy (Eternal Warrior's Sigil)
consumables[127285] =  86582 -- Shimmering Water (Aqua Jewel)
consumables[127292] =  86581 -- Watersight (Farwater Conch)
consumables[127318] =  86590 -- Gentle Breeze (Essence of the Breeze)
consumables[127322] =  86592 -- Offering of Peace (Hozen Peace Pipe)
consumables[127323] =  86593 -- Beach Bum (Hozen Beach Ball)
consumables[127770] =  88382 -- Keenbean Kafa Boost (Keenbean Kafa)
consumables[127771] =  88381 -- Silversage Incense
consumables[127803] =  88377 -- Turnip Paint Gun (Turnip Paint "Gun")
consumables[127843] =  88379 -- Grummlecake
consumables[127882] =  88388 -- Squirmy Delight
consumables[128018] =  88385 -- Searing Gaze of the Dook (Hozen Idol)
consumables[128081] =  88384 -- The Burlap Blessing (Burlap Ritual Bag)
consumables[128275] =  88589 -- Cremate (Cremating Torch)
consumables[128290] =  88492 -- Wicked Wikket
consumables[128307] =  88530 -- Bubbling Beverage
consumables[128308] =  88529 -- Sparkling Water
consumables[128327] =  88587 -- Throw Iron Belly Spirits (Iron Belly Spirits)
consumables[128328] =  88580 -- Ken-Ken's Mask
consumables[128797] =  88802 -- Summon Foxicopter (Foxicopter Controller)
consumables[129023] =  88566 -- Surgical Alterations (Krastinov's Bag of Horrors)
consumables[129498] =  89230 -- Restorative Amber
consumables[129836] =  86586 -- Panflute Melody (Panflute of Pandaria)
consumables[129861] =  86575 -- Ancient Ritual (Chalice of Secrets)
consumables[129864] =  86583 -- Salyin Distraction (Salyin Battle Banner)
consumables[130121] =  89373 -- Scotty's Lucky Coin
consumables[130678] =  89682 -- Unruly Behemoth (Oddly-Shaped Horn)
consumables[130730] =  89697 -- Kafa-Crazed Goat (Bag of Kafa Beans)
consumables[130895] =  89770 -- Rampaging Yak (Tuft of Yak Fur)
consumables[131493] =  90067 -- B.F.F. (B. F. F. Necklace)
consumables[131510] = { -- Uncontrolled Banish
	 90078, -- Cracked Talisman
	104320, -- Cursed Talisman
}
consumables[134870] =  22848 -- Empowerment (Elixir of Empowerment)
consumables[134873] =  58143 -- Prismatic Elixir
consumables[134986] = { -- Potion of Brawler's Might
	 98063, -- Bottomless Potion of Brawler's Might
	 92941, -- Potion of Brawler's Might
}
consumables[134987] = { -- Potion of Brawler's Cunning
	 92942, -- Potion of Brawler's Cunning
	 98062, -- Bottomless Potion of Brawler's Cunning
}
consumables[134989] = { -- Potion of Brawler's Deftness
	 92943, -- Potion of Brawler's Deftness
	 98061, -- Bottomless Potion of Brawler's Deftness
}
consumables[135376] =  93158 -- Bottled (Expired Blackout Brew)
consumables[135855] =  93351 -- Potion of Luck
consumables[136583] =  93730 -- Darkmoon Top Hat
consumables[139490] = { -- Frost Rune Trap
	 95055, -- Frost Rune Trap
	 97156, -- Frost Rune Trap
}
consumables[139492] = { -- Potion of Light Steps
	 97157, -- Potion of Light Steps
	 95054, -- Potion of Light Steps
}
consumables[142325] =  98132 -- Shado-Pan Geyser Gun
consumables[142372] =  98136 -- Control Jerry (Gastropod Shell)
consumables[146555] = 102351 -- Drums of Rage
consumables[146939] = 103557 -- Enduring Elixir of Wisdom
consumables[147055] = 103641 -- Singing Crystal
consumables[147226] = 103642 -- Book of the Ages
consumables[147412] = 104111 -- Elixir of Wandering Spirits
consumables[147476] = 103643 -- Dew of Eternal Morning
consumables[147643] = 104038 -- Cursed Swabby Helmet
consumables[148361] = 103683 -- Mask of Anger
consumables[148365] = 103681 -- Mask of Doubt
consumables[148366] = 103679 -- Mask of Fear
consumables[148367] = 103680 -- Mask of Hatred
consumables[148368] = 103682 -- Mask of Violence
consumables[148385] = 102467 -- Censer of Eternal Agony
consumables[148429] = 102463 -- Fire-Watcher's Oath
consumables[148528] = 104293 -- Scuttler's Shell
consumables[148529] = 104294 -- Rime of the Time-Lost Mariner
consumables[148538] = 104302 -- Blackflame Daggers
consumables[148565] = 104316 -- Spectral Grog
consumables[148577] = 104318 -- Using Flyer Controller (Crashin' Thrashin' Flyer Controller)
consumables[148623] = 104328 -- Cauterizing Core
consumables[148626] = 104329 -- Furious Ashhide Mushan (Ash-Covered Horn)
consumables[148773] = 104346 -- Golden Glider

LibStub('LibItemBuffs-1.0'):__UpgradeDatabase(version, trinkets, consumables, enchantments)
