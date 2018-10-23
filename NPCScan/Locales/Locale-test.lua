--[[****************************************************************************
  * _NPCScan by Saiket                                                         *
  * Locales/Locale-enUS.lua - Localized string constants (en-US).              *
  ****************************************************************************]]


-- See http://wow.curseforge.com/addons/npcscan/localization/enUS/
local private = select( 2, ... )
private.L = setmetatable( {
	NPCs = {};
	-- Phrases localized by default UI
	FOUND_ZONE_UNKNOWN = UNKNOWN;
	SEARCH_LEVEL_TYPE_FORMAT = UNIT_TYPE_LEVEL_TEMPLATE; -- Level, Type
}, {
	__index = function ( self, Key )
		if ( Key ~= nil ) then
			rawset( self, Key, Key );
			return Key;
		end
	end;
} );

private.L["BLOCKFLIGHTSCAN"] = "Supresses Alerts while on a flight path."
private.L["BLOCKFLIGHTSCAN_DESC"] = "Suppresses Alerts while on a flight path.  Note: Mob will still be cached and will not get an alert until the cache is cleared."
private.L["BUTTON_FOUND"] = "NPC found!"
private.L["CACHED_FORMAT"] = "The following unit(s) are already cached: %s."
private.L["CACHED_LONG_FORMAT"] = "The following unit(s) are already cached.  Consider removing them using |cff808080“/npcscan”|r's menu or resetting them by clearing your cache: %s."
private.L["CACHED_PET_RESTING_FORMAT"] = "The following tamable pet(s) were cached while resting: %s."
private.L["CACHED_STABLED_FORMAT"] = "The following unit(s) cannot be searched for while tamed: %s."
private.L["CACHED_WORLD_FORMAT"] = "The following %2$s unit(s) are already cached: %1$s."
private.L["CACHELIST_ENTRY_FORMAT"] = "|cff808080“%s”|r"
private.L["CACHELIST_SEPARATOR"] = ", "
private.L["CMD_ADD"] = "ADD"
private.L["CMD_CACHE"] = "CACHE"
private.L["CMD_CACHE_EMPTY"] = "None of the mobs being searched for are cached."
private.L["CMD_HELP"] = "Commands are |cff808080“/npcscan add <NpcID> <Name>”|r, |cff808080“/npcscan remove <NpcID or Name>”|r, |cff808080“/npcscan cache”|r to list cached mobs, and simply |cff808080“/npcscan”|r for the options menu."
private.L["CMD_REMOVE"] = "REMOVE"
private.L["CMD_REMOVENOTFOUND_FORMAT"] = "NPC |cff808080“%s”|r not found."
private.L["CONFIG_ALERT"] = "Alert Options"
private.L["CONFIG_ALERT_PERSISTENT_TOAST"] = "Keep Toast Persistant."
private.L["CONFIG_ALERT_PERSISTENT_TOAST_DESC"] = "The toast will not automatically fade out after being displayed"
private.L["CONFIG_ALERT_SCREEN_EDGE_FLASH"] = "Show Red Screen Edge Flash"
private.L["CONFIG_ALERT_SCREEN_EDGE_FLASH_DESC"] = "Enables Red Screen Edge Flash when mob is found."
private.L["CONFIG_ALERT_SHOW_AS_TOAST"] = "Show As Toast."
private.L["CONFIG_ALERT_SHOW_AS_TOAST_DESC"] = "Show alerts in a Toast window, instead of in the chat log."
private.L["CONFIG_ALERT_SOUND"] = "Alert sound file"
private.L["CONFIG_ALERT_SOUND_CLASSIC"] = "Classic NPCScan"
private.L["CONFIG_ALERT_SOUND_CLASSIC_DESC"] = "Classic NPCScan Horn & Drums alert"
private.L["CONFIG_ALERT_SOUND_DEFAULT"] = "|cffffd200Default|r"
private.L["CONFIG_ALERT_SOUND_DESC"] = "Choose the alert sound to play when an NPC is found.  Additional sounds can be added through |cff808080“SharedMedia”|r addons."
private.L["CONFIG_ALERT_UNMUTE"] = "Unmute for alert sound"
private.L["CONFIG_ALERT_UNMUTE_DESC"] = "Enables game sound while the targetting button is shown so you can hear alerts even while muted."
private.L["CONFIG_CACHEWARNINGS"] = "Print cache reminders on login and world changes"
private.L["CONFIG_CACHEWARNINGS_DESC"] = "If an NPC is already cached when you log in or change worlds, this option prints a reminder of which cached mobs can't be searched for."
private.L["CONFIG_DESC"] = "These options let you configure the way _NPCScan alerts you when it finds rare NPCs."
private.L["CONFIG_PRINTTIME"] = "Print timestamps to chat frame"
private.L["CONFIG_PRINTTIME_DESC"] = "Adds the current time to all printed messages.  Useful for recording when NPCs were found."
private.L["CONFIG_TEST"] = "Test Found Alert"
private.L["CONFIG_TEST_DESC"] = "Simulates an |cff808080“NPC found”|r alert to let you know what to look out for."
private.L["CONFIG_TEST_HELP_FORMAT"] = "Click the target button or use the provided keybinding to target the found mob.  Hold |cffffffff<%s>|r and drag to move the target button.  Note that if an NPC is found while you're in combat, the button will only appear after you exit combat."
private.L["CONFIG_TEST_NAME"] = "You! (Test)"
private.L["CONFIG_TITLE"] = "|cffCCCC88NPCScan|r"
private.L["FOUND_FORMAT"] = "Found |cff808080“%s”|r!"
private.L["FOUND_TAMABLE_FORMAT"] = "Found |cff808080“%s”|r!  |cffff2020(Note: Tamable mob, may only be a pet.)|r"
private.L["FOUND_TAMABLE_WRONGZONE_FORMAT"] = "|cffff2020False alarm:|r Found tamable mob |cff808080“%s”|r in %s instead of %s (ID %d); Definitely a pet."
private.L["FOUND_UNIT_DEAD"] = "%s found but is dead."
private.L["FOUND_UNIT_TAXI"] = "%s found during flight path near %d, %d in %s."
private.L["MOUSEOVER_SCAN"] = "Show alerts for mobs you mouseover"
private.L["MOUSEOVER_SCAN_DESC"] = "Show alerts for mobs on mouseover, even if they are allready in the cache."
private.L["PRINT_FORMAT"] = "%s_|cffCCCC88NPCScan|r: %s"
private.L["RAREMOBS"] = "Rare Mobs"
private.L["SEARCH_ACHIEVEMENTADDFOUND"] = "Search for completed Achievement NPCs"
private.L["SEARCH_ACHIEVEMENTADDFOUND_DESC"] = "Continues searching for all achievement NPCs, even if you no longer need them."
private.L["SEARCH_ACHIEVEMENT_DISABLED"] = "Disabled"
private.L["SEARCH_ADD"] = "+"
private.L["SEARCH_ADD_DESC"] = "Add new NPC or save changes to existing one."
private.L["SEARCH_ADD_TAMABLE_FORMAT"] = "Note: |cff808080“%s”|r is tamable, so seeing it as a tamed hunter's pet will cause a false alarm."
private.L["SEARCH_CACHED"] = "Cached"
private.L["SEARCH_COMPLETED"] = "Done"
private.L["SEARCH_DESC"] = "This table allows you to add or remove NPCs and achievements to scan for."
private.L["SEARCH_ID"] = "NPC ID:"
private.L["SEARCH_ID_DESC"] = "The ID of the NPC to search for.  This value can be found on sites like Wowhead.com."
private.L["SEARCH_IGNORE"] = "Remove"
private.L["SEARCH_IGNORE_DESC"] = "Remove selected mob from list."
private.L["SEARCH_IGNORE_LIST"] = "Ignore List"
private.L["SEARCH_IGNORE_LIST_DESC"] = "List of Mobs that NPCScan will not track."
private.L["SEARCH_MAP"] = "Zone:"
private.L["SEARCH_NAME"] = "Name:"
private.L["SEARCH_NAME_DESC"] = "A label for the NPC.  It doesn't have to match the NPC's actual name."
private.L["SEARCH_NPCS"] = "Custom NPCs"
private.L["SEARCH_NPCS_DESC"] = "Add any NPC to track, even if it has no achievement."
private.L["SEARCH_RAREMOBS_DESC"] = "Default list of Rare Mobs."
private.L["SEARCH_REMOVE"] = "-"
private.L["SEARCH_TAMEBEAST_DECS"] = "Tameable Rare Beasts"
private.L["SEARCH_TITLE"] = "Search"
private.L["SEARCH_WORLD"] = "World:"
private.L["SEARCH_WORLD_DESC"] = "An optional world name to limit searching to.  Can be a continent name or |cffff7f3finstance name|r (case-sensitive)."
private.L["SEARCH_WORLD_FORMAT"] = "(%s)"
private.L["TAMEDBEASTS"] = "Tameable Beasts"
private.L["TIME_FORMAT"] = "|cff808080[%H:%M:%S]|r "
private.L["TOOLS_TITLE"] = "|cff808080Tools|r"
private.L["VIGNETTE_SCAN"] = "Show alerts for Vignette Mobs"
private.L["VIGNETTE_SCAN_DESC"] = "Show alerts for Vignette Mobs.  This is a Beta Feature:  There is currently no way to filter mobs, so it will always trigger even if mob not tracked or ignored."

private.L.NPCs["100"] = "Gruff Swiftbite"
private.L.NPCs["10077"] = "Deathmaw"
private.L.NPCs["10078"] = "Terrorspark"
private.L.NPCs["10080"] = "Sandarr Dunereaver"
private.L.NPCs["10081"] = "Dustwraith"
private.L.NPCs["10082"] = "Zerillis"
private.L.NPCs["10119"] = "Volchan"
private.L.NPCs["10196"] = "General Colbatann"
private.L.NPCs["10197"] = "Mezzir the Howler"
private.L.NPCs["10198"] = "Kashoch the Reaver"
private.L.NPCs["10199"] = "Grizzle Snowpaw"
private.L.NPCs["10200"] = "Rak'shiri"
private.L.NPCs["10202"] = "Azurous"
private.L.NPCs["10263"] = "Burning Felguard"
private.L.NPCs["10356"] = "Bayne"
private.L.NPCs["10357"] = "Ressan the Needler"
private.L.NPCs["10358"] = "Fellicent's Shade"
private.L.NPCs["10359"] = "Sri'skulk"
private.L.NPCs["10376"] = "Crystal Fang"
private.L.NPCs["10393"] = "Skul"
private.L.NPCs["10509"] = "Jed Runewatcher"
private.L.NPCs["10558"] = "Hearthsinger Forresten"
private.L.NPCs["10559"] = "Lady Vespia"
private.L.NPCs["1063"] = "Jade"
private.L.NPCs["10639"] = "Rorgish Jowl"
private.L.NPCs["10640"] = "Oakpaw"
private.L.NPCs["10641"] = "Branch Snapper"
private.L.NPCs["10642"] = "Eck'alom"
private.L.NPCs["10644"] = "Mist Howler"
private.L.NPCs["10647"] = "Prince Raze"
private.L.NPCs["10741"] = "Sian-Rotam"
private.L.NPCs["10809"] = "Stonespine"
private.L.NPCs["10817"] = "Duggan Wildhammer"
private.L.NPCs["10818"] = "Death Knight Soulbearer"
private.L.NPCs["10819"] = "Baron Bloodbane"
private.L.NPCs["10820"] = "Duke Ragereaver"
private.L.NPCs["10821"] = "Hed'mush the Rotting"
private.L.NPCs["10823"] = "Zul'Brin Warpbranch"
private.L.NPCs["10824"] = "Death-Hunter Hawkspear"
private.L.NPCs["10825"] = "Gish the Unmoving"
private.L.NPCs["10826"] = "Lord Darkscythe"
private.L.NPCs["10827"] = "Deathspeaker Selendre"
private.L.NPCs["10828"] = "Lynnia Abbendis"
private.L.NPCs["1106"] = "Lost One Cook"
private.L.NPCs["1112"] = "Leech Widow"
private.L.NPCs["1119"] = "Hammerspine"
private.L.NPCs["1130"] = "Bjarn"
private.L.NPCs["1132"] = "Timber"
private.L.NPCs["1137"] = "Edan the Howler"
private.L.NPCs["11383"] = "High Priestess Hai'watna"
private.L.NPCs["1140"] = "Razormaw Matriarch"
private.L.NPCs["11447"] = "Mushgog"
private.L.NPCs["11467"] = "Tsu'zee"
private.L.NPCs["11497"] = "The Razza"
private.L.NPCs["11498"] = "Skarr the Broken"
private.L.NPCs["11688"] = "Cursed Centaur"
private.L.NPCs["12037"] = "Ursol'lok"
private.L.NPCs["12237"] = "Meshlok the Harvester"
private.L.NPCs["12431"] = "Gorefang"
private.L.NPCs["12433"] = "Krethis the Shadowspinner"
private.L.NPCs["1260"] = "Great Father Arctikus"
private.L.NPCs["12902"] = "Lorgus Jett"
private.L.NPCs["13896"] = "Scalebeard"
private.L.NPCs["1398"] = "Boss Galgosh"
private.L.NPCs["1399"] = "Magosh"
private.L.NPCs["14221"] = "Gravis Slipknot"
private.L.NPCs["14222"] = "Araga"
private.L.NPCs["14223"] = "Cranky Benj"
private.L.NPCs["14224"] = "7:XT"
private.L.NPCs["14225"] = "Prince Kellen"
private.L.NPCs["14226"] = "Kaskk"
private.L.NPCs["14227"] = "Hissperak"
private.L.NPCs["14228"] = "Giggler"
private.L.NPCs["14229"] = "Accursed Slitherblade"
private.L.NPCs["14230"] = "Burgle Eye"
private.L.NPCs["14231"] = "Drogoth the Roamer"
private.L.NPCs["14232"] = "Dart"
private.L.NPCs["14233"] = "Ripscale"
private.L.NPCs["14234"] = "Hayoc"
private.L.NPCs["14235"] = "The Rot"
private.L.NPCs["14236"] = "Lord Angler"
private.L.NPCs["14237"] = "Oozeworm"
private.L.NPCs["1424"] = "Master Digger"
private.L.NPCs["1425"] = "Kubb"
private.L.NPCs["14266"] = "Shanda the Spinner"
private.L.NPCs["14267"] = "Emogg the Crusher"
private.L.NPCs["14268"] = "Lord Condar"
private.L.NPCs["14269"] = "Seeker Aqualon"
private.L.NPCs["14270"] = "Squiddic"
private.L.NPCs["14271"] = "Ribchaser"
private.L.NPCs["14272"] = "Snarlflare"
private.L.NPCs["14273"] = "Boulderheart"
private.L.NPCs["14275"] = "Tamra Stormpike"
private.L.NPCs["14276"] = "Scargil"
private.L.NPCs["14277"] = "Lady Zephris"
private.L.NPCs["14278"] = "Ro'Bark"
private.L.NPCs["14279"] = "Creepthess"
private.L.NPCs["14280"] = "Big Samras"
private.L.NPCs["14281"] = "Jimmy the Bleeder"
private.L.NPCs["14339"] = "Death Howl"
private.L.NPCs["14340"] = "Alshirr Banebreath"
private.L.NPCs["14342"] = "Ragepaw"
private.L.NPCs["14343"] = "Olm the Wise"
private.L.NPCs["14344"] = "Mongress"
private.L.NPCs["14345"] = "The Ongar"
private.L.NPCs["14424"] = "Mirelow"
private.L.NPCs["14425"] = "Gnawbone"
private.L.NPCs["14426"] = "Harb Foulmountain"
private.L.NPCs["14427"] = "Gibblesnik"
private.L.NPCs["14428"] = "Uruson"
private.L.NPCs["14429"] = "Grimmaw"
private.L.NPCs["14430"] = "Duskstalker"
private.L.NPCs["14431"] = "Fury Shelda"
private.L.NPCs["14432"] = "Threggil"
private.L.NPCs["14433"] = "Sludginn"
private.L.NPCs["14445"] = "Captain Wyrmak"
private.L.NPCs["14446"] = "Fingat"
private.L.NPCs["14447"] = "Gilmorian"
private.L.NPCs["14448"] = "Molt Thorn"
private.L.NPCs["14471"] = "Setis"
private.L.NPCs["14472"] = "Gretheer"
private.L.NPCs["14473"] = "Lapress"
private.L.NPCs["14474"] = "Zora"
private.L.NPCs["14475"] = "Rex Ashil"
private.L.NPCs["14476"] = "Krellack"
private.L.NPCs["14477"] = "Grubthor"
private.L.NPCs["14478"] = "Huricanian"
private.L.NPCs["14479"] = "Twilight Lord Everun"
private.L.NPCs["14487"] = "Gluggl"
private.L.NPCs["14488"] = "Roloch"
private.L.NPCs["14490"] = "Rippa"
private.L.NPCs["14491"] = "Kurmokk"
private.L.NPCs["14492"] = "Verifonix"
private.L.NPCs["1531"] = "Lost Soul"
private.L.NPCs["1533"] = "Tormented Spirit"
private.L.NPCs["1552"] = "Scale Belly"
private.L.NPCs["16179"] = "Hyakiss the Lurker"
private.L.NPCs["16180"] = "Shadikith the Glider"
private.L.NPCs["16181"] = "Rokad the Ravager"
private.L.NPCs["16184"] = "Nerubian Overseer"
private.L.NPCs["16854"] = "Eldinarcus"
private.L.NPCs["16855"] = "Tregla"
private.L.NPCs["17144"] = "Goretooth"
private.L.NPCs["18241"] = "Crusty"
private.L.NPCs["1837"] = "Scarlet Judge"
private.L.NPCs["1838"] = "Scarlet Interrogator"
private.L.NPCs["1839"] = "Scarlet High Clerist"
private.L.NPCs["1841"] = "Scarlet Executioner"
private.L.NPCs["1843"] = "Foreman Jerris"
private.L.NPCs["1844"] = "Foreman Marcrid"
private.L.NPCs["1847"] = "Foulmane"
private.L.NPCs["1848"] = "Lord Maldazzar"
private.L.NPCs["1849"] = "Dreadwhisper"
private.L.NPCs["1850"] = "Putridius"
private.L.NPCs["1851"] = "The Husk"
private.L.NPCs["18677"] = "Mekthorg the Wild"
private.L.NPCs["18678"] = "Fulgorge"
private.L.NPCs["18679"] = "Vorakem Doomspeaker"
private.L.NPCs["18680"] = "Marticar"
private.L.NPCs["18681"] = "Coilfang Emissary"
private.L.NPCs["18682"] = "Bog Lurker"
private.L.NPCs["18683"] = "Voidhunter Yar"
private.L.NPCs["18684"] = "Bro'Gaz the Clanless"
private.L.NPCs["18685"] = "Okrek"
private.L.NPCs["18686"] = "Doomsayer Jurim"
private.L.NPCs["18689"] = "Crippler"
private.L.NPCs["18690"] = "Morcrush"
private.L.NPCs["18692"] = "Hemathion"
private.L.NPCs["18693"] = "Speaker Mar'grom"
private.L.NPCs["18694"] = "Collidus the Warp-Watcher"
private.L.NPCs["18695"] = "Ambassador Jerrikar"
private.L.NPCs["18696"] = "Kraator"
private.L.NPCs["18697"] = "Chief Engineer Lorthander"
private.L.NPCs["18698"] = "Ever-Core the Punisher"
private.L.NPCs["1885"] = "Scarlet Smith"
private.L.NPCs["1910"] = "Muad"
private.L.NPCs["1911"] = "Deeb"
private.L.NPCs["1936"] = "Farmer Solliden"
private.L.NPCs["2090"] = "Ma'ruk Wyrmscale"
private.L.NPCs["20932"] = "Nuramoc"
private.L.NPCs["2108"] = "Garneg Charskull"
private.L.NPCs["2162"] = "Agal"
private.L.NPCs["2172"] = "Strider Clutchmother"
private.L.NPCs["21724"] = "Hawkbane"
private.L.NPCs["2175"] = "Shadowclaw"
private.L.NPCs["2184"] = "Lady Moongazer"
private.L.NPCs["2186"] = "Carnivous the Breaker"
private.L.NPCs["2191"] = "Licillin"
private.L.NPCs["2192"] = "Firecaller Radison"
private.L.NPCs["22060"] = "Fenissa the Assassin"
private.L.NPCs["22062"] = "Dr. Whitherlimb"
private.L.NPCs["2258"] = "Maggarrak"
private.L.NPCs["2452"] = "Skhowl"
private.L.NPCs["2453"] = "Lo'Grosh"
private.L.NPCs["2476"] = "Gosh-Haldir"
private.L.NPCs["2541"] = "Lord Sakrasis"
private.L.NPCs["2598"] = "Darbel Montrose"
private.L.NPCs["2600"] = "Singer"
private.L.NPCs["2601"] = "Foulbelly"
private.L.NPCs["2602"] = "Ruul Onestone"
private.L.NPCs["2603"] = "Kovork"
private.L.NPCs["2604"] = "Molok the Crusher"
private.L.NPCs["2605"] = "Zalas Witherbark"
private.L.NPCs["2606"] = "Nimar the Slayer"
private.L.NPCs["2609"] = "Geomancer Flintdagger"
private.L.NPCs["2744"] = "Shadowforge Commander"
private.L.NPCs["2749"] = "Barricade"
private.L.NPCs["2751"] = "War Golem"
private.L.NPCs["2752"] = "Rumbler"
private.L.NPCs["2753"] = "Barnabus"
private.L.NPCs["2754"] = "Anathemus"
private.L.NPCs["2779"] = "Prince Nazjak"
private.L.NPCs["2850"] = "Broken Tooth"
private.L.NPCs["2931"] = "Zaricotl"
private.L.NPCs["3058"] = "Arra'chea"
private.L.NPCs["3068"] = "Mazzranache"
private.L.NPCs["32357"] = "Old Crystalbark"
private.L.NPCs["32358"] = "Fumblub Gearwind"
private.L.NPCs["32361"] = "Icehorn"
private.L.NPCs["32377"] = "Perobas the Bloodthirster"
private.L.NPCs["32386"] = "Vigdis the War Maiden"
private.L.NPCs["32398"] = "King Ping"
private.L.NPCs["32400"] = "Tukemuth"
private.L.NPCs["32409"] = "Crazed Indu'le Survivor"
private.L.NPCs["32417"] = "Scarlet Highlord Daion"
private.L.NPCs["32422"] = "Grocklar"
private.L.NPCs["32429"] = "Seething Hate"
private.L.NPCs["32435"] = "Vern"
private.L.NPCs["32438"] = "Syreian the Bonecarver"
private.L.NPCs["32447"] = "Zul'drak Sentinel"
private.L.NPCs["32471"] = "Griegen"
private.L.NPCs["32475"] = "Terror Spinner"
private.L.NPCs["32481"] = "Aotona"
private.L.NPCs["32485"] = "King Krush"
private.L.NPCs["32487"] = "Putridus the Ancient"
private.L.NPCs["32491"] = "Time-Lost Proto-Drake"
private.L.NPCs["32495"] = "Hildana Deathstealer"
private.L.NPCs["32500"] = "Dirkee"
private.L.NPCs["32501"] = "High Thane Jorfus"
private.L.NPCs["32517"] = "Loque'nahak"
private.L.NPCs["3253"] = "Silithid Harvester"
private.L.NPCs["32630"] = "Vyragosa"
private.L.NPCs["3270"] = "Elder Mystic Razorsnout"
private.L.NPCs["3295"] = "Sludge Anomaly"
private.L.NPCs["33776"] = "Gondria"
private.L.NPCs["3398"] = "Gesharahan"
private.L.NPCs["3470"] = "Rathorian"
private.L.NPCs["35189"] = "Skoll"
private.L.NPCs["3535"] = "Blackmoss the Fetid"
private.L.NPCs["3581"] = "Sewer Beast"
private.L.NPCs["3652"] = "Trigore the Lasher"
private.L.NPCs["3672"] = "Boahn"
private.L.NPCs["3735"] = "Apothecary Falthis"
private.L.NPCs["3736"] = "Darkslayer Mordenthal"
private.L.NPCs["3773"] = "Akkrilus"
private.L.NPCs["3792"] = "Terrowulf Packlord"
private.L.NPCs["38453"] = "Arcturis"
private.L.NPCs["3872"] = "Deathsworn Captain"
private.L.NPCs["39183"] = "Scorpitar"
private.L.NPCs["39185"] = "Slaverjaw"
private.L.NPCs["39186"] = "Hellgazer"
private.L.NPCs["4066"] = "Nal'taszar"
private.L.NPCs["4132"] = "Krkk'kx"
private.L.NPCs["4339"] = "Brimgore"
private.L.NPCs["43488"] = "Mordei the Earthrender"
private.L.NPCs["43613"] = "Doomsayer Wiserunner"
private.L.NPCs["43720"] = "\"Pokey\" Thornmantle"
private.L.NPCs["4380"] = "Darkmist Widow"
private.L.NPCs["44224"] = "Two-Toes"
private.L.NPCs["44225"] = "Rufus Darkshot"
private.L.NPCs["44226"] = "Sarltooth"
private.L.NPCs["44227"] = "Gazz the Loch-Hunter"
private.L.NPCs["4425"] = "Blind Hunter"
private.L.NPCs["44714"] = "Fronkle the Disturbed"
private.L.NPCs["44722"] = "Twisted Reflection of Narain"
private.L.NPCs["44750"] = "Caliph Scorpidsting"
private.L.NPCs["44759"] = "Andre Firebeard"
private.L.NPCs["44761"] = "Aquementas the Unchained"
private.L.NPCs["44767"] = "Occulus the Corrupted"
private.L.NPCs["45257"] = "Mordak Nightbender"
private.L.NPCs["45258"] = "Cassia the Slitherqueen"
private.L.NPCs["45260"] = "Blackleaf"
private.L.NPCs["45262"] = "Narixxus the Doombringer"
private.L.NPCs["45369"] = "Morick Darkbrew"
private.L.NPCs["45380"] = "Ashtail"
private.L.NPCs["45384"] = "Sagepaw"
private.L.NPCs["45398"] = "Grizlak"
private.L.NPCs["45399"] = "Optimo"
private.L.NPCs["45401"] = "Whitefin"
private.L.NPCs["45402"] = "Nix"
private.L.NPCs["45404"] = "Geoshaper Maren"
private.L.NPCs["45739"] = "The Unknown Soldier"
private.L.NPCs["45740"] = "Watcher Eva"
private.L.NPCs["45771"] = "Marus"
private.L.NPCs["45785"] = "Carved One"
private.L.NPCs["45801"] = "Eliza"
private.L.NPCs["45811"] = "Marina DeSirrus"
private.L.NPCs["462"] = "Vultros"
private.L.NPCs["46981"] = "Nightlash"
private.L.NPCs["46992"] = "Berard the Moon-Crazed"
private.L.NPCs["47003"] = "Bolgaff"
private.L.NPCs["47008"] = "Fenwick Thatros"
private.L.NPCs["47009"] = "Aquarius the Unbound"
private.L.NPCs["47010"] = "Indigos"
private.L.NPCs["47012"] = "Effritus"
private.L.NPCs["47015"] = "Lost Son of Arugal"
private.L.NPCs["47023"] = "Thule Ravenclaw"
private.L.NPCs["471"] = "Mother Fang"
private.L.NPCs["472"] = "Fedfennel"
private.L.NPCs["47386"] = "Ainamiss the Hive Queen"
private.L.NPCs["47387"] = "Harakiss the Infestor"
private.L.NPCs["4842"] = "Earthcaller Halmgar"
private.L.NPCs["49822"] = "Jadefang"
private.L.NPCs["49913"] = "Lady La-La"
private.L.NPCs["50005"] = "Poseidus"
private.L.NPCs["50009"] = "Mobus"
private.L.NPCs["50050"] = "Shok'sharak"
private.L.NPCs["50051"] = "Ghostcrawler"
private.L.NPCs["50052"] = "Burgy Blackheart"
private.L.NPCs["50053"] = "Thartuk the Exile"
private.L.NPCs["50056"] = "Garr"
private.L.NPCs["50057"] = "Blazewing"
private.L.NPCs["50058"] = "Terrorpene"
private.L.NPCs["50059"] = "Golgarok"
private.L.NPCs["50060"] = "Terborus"
private.L.NPCs["50061"] = "Xariona"
private.L.NPCs["50062"] = "Aeonaxx"
private.L.NPCs["50063"] = "Akma'hat"
private.L.NPCs["50064"] = "Cyrus the Black"
private.L.NPCs["50065"] = "Armagedillo"
private.L.NPCs["50085"] = "Overlord Sunderfury"
private.L.NPCs["50086"] = "Tarvus the Vile"
private.L.NPCs["50089"] = "Julak-Doom"
private.L.NPCs["50138"] = "Karoma"
private.L.NPCs["50154"] = "Madexx - Brown"
private.L.NPCs["50159"] = "Sambas"
private.L.NPCs["50328"] = "Fangor"
private.L.NPCs["50329"] = "Rrakk"
private.L.NPCs["50330"] = "Kree"
private.L.NPCs["50331"] = "Go-Kan"
private.L.NPCs["50332"] = "Korda Torros"
private.L.NPCs["50333"] = "Lon the Bull"
private.L.NPCs["50334"] = "Dak the Breaker"
private.L.NPCs["50335"] = "Alitus"
private.L.NPCs["50336"] = "Yorik Sharpeye"
private.L.NPCs["50337"] = "Cackle"
private.L.NPCs["50338"] = "Kor'nas Nightsavage"
private.L.NPCs["50339"] = "Sulik'shor"
private.L.NPCs["50340"] = "Gaarn the Toxic"
private.L.NPCs["50341"] = "Borginn Darkfist"
private.L.NPCs["50342"] = "Heronis"
private.L.NPCs["50343"] = "Quall"
private.L.NPCs["50344"] = "Norlaxx"
private.L.NPCs["50345"] = "Alit"
private.L.NPCs["50346"] = "Ronak"
private.L.NPCs["50347"] = "Karr the Darkener"
private.L.NPCs["50348"] = "Norissis"
private.L.NPCs["50349"] = "Kang the Soul Thief"
private.L.NPCs["50350"] = "Morgrinn Crackfang"
private.L.NPCs["50351"] = "Jonn-Dar"
private.L.NPCs["50352"] = "Qu'nas"
private.L.NPCs["50353"] = "Manas"
private.L.NPCs["50354"] = "Havak"
private.L.NPCs["50355"] = "Kah'tir"
private.L.NPCs["50356"] = "Krol the Blade"
private.L.NPCs["50357"] = "Sunwing"
private.L.NPCs["50358"] = "Haywire Sunreaver Construct"
private.L.NPCs["50359"] = "Urgolax"
private.L.NPCs["50361"] = "Ornat"
private.L.NPCs["50362"] = "Blackbog the Fang"
private.L.NPCs["50363"] = "Krax'ik"
private.L.NPCs["50364"] = "Nal'lak the Ripper"
private.L.NPCs["50370"] = "Karapax"
private.L.NPCs["50388"] = "Torik-Ethis"
private.L.NPCs["50409"] = "Mysterious Camel Figurine"
private.L.NPCs["50410"] = "Mysterious Camel Figurine"
private.L.NPCs["506"] = "Sergeant Brashclaw"
private.L.NPCs["507"] = "Fenros"
private.L.NPCs["50724"] = "Spinecrawl"
private.L.NPCs["50725"] = "Azelisk"
private.L.NPCs["50726"] = "Kalixx"
private.L.NPCs["50727"] = "Strix the Barbed"
private.L.NPCs["50728"] = "Deathstrike"
private.L.NPCs["50730"] = "Venomspine"
private.L.NPCs["50731"] = "Needlefang"
private.L.NPCs["50733"] = "Ski'thik"
private.L.NPCs["50734"] = "Lith'ik the Stalker"
private.L.NPCs["50735"] = "Blinkeye the Rattler"
private.L.NPCs["50737"] = "Acroniss"
private.L.NPCs["50738"] = "Shimmerscale"
private.L.NPCs["50739"] = "Gar'lok"
private.L.NPCs["50741"] = "Kaxx"
private.L.NPCs["50742"] = "Qem"
private.L.NPCs["50743"] = "Manax"
private.L.NPCs["50744"] = "Qu'rik"
private.L.NPCs["50745"] = "Losaj"
private.L.NPCs["50746"] = "Bornix the Burrower"
private.L.NPCs["50747"] = "Tix"
private.L.NPCs["50748"] = "Nyaj"
private.L.NPCs["50749"] = "Kal'tik the Blight"
private.L.NPCs["50750"] = "Aethis"
private.L.NPCs["50752"] = "Tarantis"
private.L.NPCs["50759"] = "Iriss the Widow"
private.L.NPCs["50763"] = "Shadowstalker"
private.L.NPCs["50764"] = "Paraliss"
private.L.NPCs["50765"] = "Miasmiss"
private.L.NPCs["50766"] = "Sele'na"
private.L.NPCs["50768"] = "Cournith Waterstrider"
private.L.NPCs["50769"] = "Zai the Outcast"
private.L.NPCs["50770"] = "Zorn"
private.L.NPCs["50772"] = "Eshelon"
private.L.NPCs["50775"] = "Likk the Hunter"
private.L.NPCs["50776"] = "Nalash Verdantis"
private.L.NPCs["50777"] = "Needle"
private.L.NPCs["50778"] = "Ironweb"
private.L.NPCs["50779"] = "Sporeggon"
private.L.NPCs["50780"] = "Sahn Tidehunter"
private.L.NPCs["50782"] = "Sarnak"
private.L.NPCs["50783"] = "Salyin Warscout"
private.L.NPCs["50784"] = "Anith"
private.L.NPCs["50785"] = "Skyshadow"
private.L.NPCs["50786"] = "Sparkwing"
private.L.NPCs["50787"] = "Arness the Scale"
private.L.NPCs["50788"] = "Quetzl"
private.L.NPCs["50789"] = "Nessos the Oracle"
private.L.NPCs["50790"] = "Ionis"
private.L.NPCs["50791"] = "Siltriss the Sharpener"
private.L.NPCs["50792"] = "Chiaa"
private.L.NPCs["50797"] = "Yukiko"
private.L.NPCs["50803"] = "Bonechewer"
private.L.NPCs["50804"] = "Ripwing"
private.L.NPCs["50805"] = "Omnis Grinlok"
private.L.NPCs["50806"] = "Moldo One-Eye"
private.L.NPCs["50807"] = "Catal"
private.L.NPCs["50808"] = "Urobi the Walker"
private.L.NPCs["50809"] = "Heress"
private.L.NPCs["50810"] = "Favored of Isiset"
private.L.NPCs["50811"] = "Nasra Spothide"
private.L.NPCs["50812"] = "Arae"
private.L.NPCs["50813"] = "Fene-mal"
private.L.NPCs["50814"] = "Corpsefeeder"
private.L.NPCs["50815"] = "Skarr"
private.L.NPCs["50816"] = "Ruun Ghostpaw"
private.L.NPCs["50817"] = "Ahone the Wanderer"
private.L.NPCs["50818"] = "The Dark Prowler"
private.L.NPCs["50819"] = "Iceclaw"
private.L.NPCs["50820"] = "Yul Wildpaw"
private.L.NPCs["50821"] = "Ai-Li Skymirror"
private.L.NPCs["50822"] = "Ai-Ran the Shifting Cloud"
private.L.NPCs["50823"] = "Mister Ferocious"
private.L.NPCs["50825"] = "Feras"
private.L.NPCs["50828"] = "Bonobos"
private.L.NPCs["50830"] = "Spriggin"
private.L.NPCs["50831"] = "Scritch"
private.L.NPCs["50832"] = "The Yowler"
private.L.NPCs["50833"] = "Duskcoat"
private.L.NPCs["50836"] = "Ik-Ik the Nimble"
private.L.NPCs["50837"] = "Kash"
private.L.NPCs["50838"] = "Tabbs"
private.L.NPCs["50839"] = "Chromehound"
private.L.NPCs["50840"] = "Major Nanners"
private.L.NPCs["50842"] = "Magmagan"
private.L.NPCs["50843"] = "Portent"
private.L.NPCs["50846"] = "Slavermaw"
private.L.NPCs["50855"] = "Jaxx the Rabid"
private.L.NPCs["50856"] = "Snark"
private.L.NPCs["50858"] = "Dustwing"
private.L.NPCs["50864"] = "Thicket"
private.L.NPCs["50865"] = "Saurix"
private.L.NPCs["50874"] = "Tenok"
private.L.NPCs["50875"] = "Nychus"
private.L.NPCs["50876"] = "Avis"
private.L.NPCs["50882"] = "Chupacabros"
private.L.NPCs["50884"] = "Dustflight the Cowardly"
private.L.NPCs["50886"] = "Seawing"
private.L.NPCs["50891"] = "Boros"
private.L.NPCs["50892"] = "Cyn"
private.L.NPCs["50895"] = "Volux"
private.L.NPCs["50897"] = "Ffexk the Dunestalker"
private.L.NPCs["50901"] = "Teromak"
private.L.NPCs["50903"] = "Orlix the Swamplord"
private.L.NPCs["50905"] = "Cida"
private.L.NPCs["50906"] = "Mutilax"
private.L.NPCs["50908"] = "Nighthowl"
private.L.NPCs["50915"] = "Snort"
private.L.NPCs["50916"] = "Lamepaw the Whimperer"
private.L.NPCs["50922"] = "Warg"
private.L.NPCs["50925"] = "Grovepaw"
private.L.NPCs["50926"] = "Grizzled Ben"
private.L.NPCs["50929"] = "Little Bjorn"
private.L.NPCs["50930"] = "Hibernus the Sleeper"
private.L.NPCs["50931"] = "Mange"
private.L.NPCs["50937"] = "Hamhide"
private.L.NPCs["50940"] = "Swee"
private.L.NPCs["50942"] = "Snoot the Rooter"
private.L.NPCs["50945"] = "Scruff"
private.L.NPCs["50946"] = "Hogzilla"
private.L.NPCs["50947"] = "Varah"
private.L.NPCs["50948"] = "Crystalback"
private.L.NPCs["50949"] = "Finn's Gambit"
private.L.NPCs["50952"] = "Barnacle Jim"
private.L.NPCs["50955"] = "Carcinak"
private.L.NPCs["50957"] = "Hugeclaw"
private.L.NPCs["50959"] = "Karkin"
private.L.NPCs["50964"] = "Chops"
private.L.NPCs["50967"] = "Craw the Ravager"
private.L.NPCs["50986"] = "Goldenback"
private.L.NPCs["50993"] = "Gal'dorak"
private.L.NPCs["50995"] = "Bruiser"
private.L.NPCs["50997"] = "Bornak the Gorer"
private.L.NPCs["51000"] = "Blackshell the Impenetrable"
private.L.NPCs["51001"] = "Venomclaw"
private.L.NPCs["51002"] = "Scorpoxx"
private.L.NPCs["51004"] = "Toxx"
private.L.NPCs["51007"] = "Serkett"
private.L.NPCs["51008"] = "The Barbed Horror"
private.L.NPCs["51010"] = "Snips"
private.L.NPCs["51014"] = "Terrapis"
private.L.NPCs["51017"] = "Gezan"
private.L.NPCs["51018"] = "Zormus"
private.L.NPCs["51021"] = "Vorticus"
private.L.NPCs["51022"] = "Chordix"
private.L.NPCs["51025"] = "Dilennaa"
private.L.NPCs["51026"] = "Gnath"
private.L.NPCs["51027"] = "Spirocula"
private.L.NPCs["51028"] = "The Deep Tunneler"
private.L.NPCs["51029"] = "Parasitus"
private.L.NPCs["51031"] = "Tracker"
private.L.NPCs["51037"] = "Lost Gilnean Wardog"
private.L.NPCs["51040"] = "Snuffles"
private.L.NPCs["51042"] = "Bleakheart"
private.L.NPCs["51044"] = "Plague"
private.L.NPCs["51045"] = "Arcanus"
private.L.NPCs["51046"] = "Fidonis"
private.L.NPCs["51048"] = "Rexxus"
private.L.NPCs["51052"] = "Gib the Banana-Hoarder"
private.L.NPCs["51053"] = "Quirix"
private.L.NPCs["51057"] = "Weevil"
private.L.NPCs["51058"] = "Aphis"
private.L.NPCs["51059"] = "Blackhoof"
private.L.NPCs["51061"] = "Roth-Salam"
private.L.NPCs["51062"] = "Khep-Re"
private.L.NPCs["51063"] = "Phalanax"
private.L.NPCs["51066"] = "Crystalfang"
private.L.NPCs["51067"] = "Glint"
private.L.NPCs["51069"] = "Scintillex"
private.L.NPCs["51071"] = "Captain Florence"
private.L.NPCs["51076"] = "Lopex"
private.L.NPCs["51077"] = "Bushtail"
private.L.NPCs["51078"] = "Ferdinand"
private.L.NPCs["51079"] = "Captain Foulwind"
private.L.NPCs["51401"] = "Madexx - Red"
private.L.NPCs["51402"] = "Madexx - Green"
private.L.NPCs["51403"] = "Madexx - Black"
private.L.NPCs["51404"] = "Madexx - Blue"
private.L.NPCs["51658"] = "Mogh the Dead"
private.L.NPCs["51661"] = "Tsul'Kalu"
private.L.NPCs["51662"] = "Mahamba"
private.L.NPCs["51663"] = "Pogeyan"
private.L.NPCs["519"] = "Slark"
private.L.NPCs["520"] = "Brack"
private.L.NPCs["521"] = "Lupos"
private.L.NPCs["52146"] = "Chitter"
private.L.NPCs["534"] = "Nefaru"
private.L.NPCs["5343"] = "Lady Szallah"
private.L.NPCs["5345"] = "Diamond Head"
private.L.NPCs["5346"] = "Bloodroar the Stalker"
private.L.NPCs["5347"] = "Antilus the Soarer"
private.L.NPCs["5348"] = "Dreamwatcher Forktongue"
private.L.NPCs["5349"] = "Arash-ethis"
private.L.NPCs["5350"] = "Qirot"
private.L.NPCs["5352"] = "Old Grizzlegut"
private.L.NPCs["5354"] = "Gnarl Leafbrother"
private.L.NPCs["5356"] = "Snarler"
private.L.NPCs["54318"] = "Ankha"
private.L.NPCs["54319"] = "Magria"
private.L.NPCs["54320"] = "Ban'thalos"
private.L.NPCs["54321"] = "Solix"
private.L.NPCs["54322"] = "Deth'tilac"
private.L.NPCs["54323"] = "Kirix"
private.L.NPCs["54324"] = "Skitterflame"
private.L.NPCs["54338"] = "Anthriss"
private.L.NPCs["54533"] = "Prince Lakma"
private.L.NPCs["56081"] = "Optimistic Benj"
private.L.NPCs["572"] = "Leprithus"
private.L.NPCs["573"] = "Foe Reaper 4000"
private.L.NPCs["574"] = "Naraxis"
private.L.NPCs["5785"] = "Sister Hatelash"
private.L.NPCs["5786"] = "Snagglespear"
private.L.NPCs["5787"] = "Enforcer Emilgund"
private.L.NPCs["5807"] = "The Rake"
private.L.NPCs["5809"] = "Sergeant Curtis"
private.L.NPCs["5822"] = "Felweaver Scornn"
private.L.NPCs["5823"] = "Death Flayer"
private.L.NPCs["5824"] = "Captain Flat Tusk"
private.L.NPCs["5826"] = "Geolord Mottle"
private.L.NPCs["5828"] = "Humar the Pridelord"
private.L.NPCs["5829"] = "Snort the Heckler"
private.L.NPCs["5830"] = "Sister Rathtalon"
private.L.NPCs["5831"] = "Swiftmane"
private.L.NPCs["5832"] = "Thunderstomp"
private.L.NPCs["58336"] = "Darkmoon Rabbit"
private.L.NPCs["5834"] = "Azzere the Skyblade"
private.L.NPCs["5835"] = "Foreman Grills"
private.L.NPCs["5836"] = "Engineer Whirleygig"
private.L.NPCs["5837"] = "Stonearm"
private.L.NPCs["5838"] = "Brokespear"
private.L.NPCs["584"] = "Kazon"
private.L.NPCs["5841"] = "Rocklance"
private.L.NPCs["5842"] = "Takk the Leaper"
private.L.NPCs["5847"] = "Heggin Stonewhisker"
private.L.NPCs["58474"] = "Bloodtip"
private.L.NPCs["5848"] = "Malgin Barleybrew"
private.L.NPCs["5849"] = "Digger Flameforge"
private.L.NPCs["5851"] = "Captain Gerogg Hammertoe"
private.L.NPCs["5859"] = "Hagg Taurenbane"
private.L.NPCs["5863"] = "Geopriest Gukk'rok"
private.L.NPCs["5864"] = "Swinegart Spearhide"
private.L.NPCs["5865"] = "Dishu"
private.L.NPCs["58768"] = "Cracklefang"
private.L.NPCs["58769"] = "Vicejaw"
private.L.NPCs["58771"] = "Quid"
private.L.NPCs["58778"] = "Aetha"
private.L.NPCs["58817"] = "Spirit of Lao-Fe"
private.L.NPCs["58949"] = "Bai-Jin the Butcher"
private.L.NPCs["5912"] = "Deviate Faerie Dragon"
private.L.NPCs["5915"] = "Brother Ravenoak"
private.L.NPCs["5928"] = "Sorrow Wing"
private.L.NPCs["5930"] = "Sister Riven"
private.L.NPCs["5932"] = "Taskmaster Whipfang"
private.L.NPCs["5933"] = "Achellios the Banished"
private.L.NPCs["5935"] = "Ironeye the Invincible"
private.L.NPCs["59369"] = "Doctor Theolen Krastinov"
private.L.NPCs["5937"] = "Vile Sting"
private.L.NPCs["596"] = "Brainwashed Noble"
private.L.NPCs["599"] = "Marisa du'Paige"
private.L.NPCs["60491"] = "Sha of Anger"
private.L.NPCs["61"] = "Thuros Lightfingers"
private.L.NPCs["6118"] = "Varo'then's Ghost"
private.L.NPCs["616"] = "Chatter"
private.L.NPCs["62"] = "Gug Fatcandle"
private.L.NPCs["6228"] = "Dark Iron Ambassador"
private.L.NPCs["62346"] = "Galleon"
private.L.NPCs["62880"] = "Gochao the Ironfist"
private.L.NPCs["62881"] = "Gaohun the Soul-Severer"
private.L.NPCs["63101"] = "General Temuja"
private.L.NPCs["63240"] = "Shadowmaster Sydow"
private.L.NPCs["63509"] = "Wulon"
private.L.NPCs["63510"] = "Wulon"
private.L.NPCs["63691"] = "Huo-Shuang"
private.L.NPCs["63695"] = "Baolai the Immolator"
private.L.NPCs["63977"] = "Vyraxxis"
private.L.NPCs["63978"] = "Kri'chon"
private.L.NPCs["64004"] = "Ghostly Pandaren Fisherman"
private.L.NPCs["64191"] = "Ghostly Pandaren Craftsman"
private.L.NPCs["64403"] = "Alani"
private.L.NPCs["6581"] = "Ravasaur Matriarch"
private.L.NPCs["6582"] = "Clutchmother Zavas"
private.L.NPCs["6583"] = "Gruff"
private.L.NPCs["6584"] = "King Mosh"
private.L.NPCs["6585"] = "Uhk'loc"
private.L.NPCs["6648"] = "Antilos"
private.L.NPCs["6649"] = "Lady Sesspira"
private.L.NPCs["6650"] = "General Fangferror"
private.L.NPCs["6651"] = "Gatekeeper Rageroar"
private.L.NPCs["68317"] = "Mavis Harms"
private.L.NPCs["68318"] = "Dalan Nightbreaker"
private.L.NPCs["68319"] = "Disha Fearwarden"
private.L.NPCs["68320"] = "Ubunti the Shade"
private.L.NPCs["68321"] = "Kar Warmaker"
private.L.NPCs["68322"] = "Muerta"
private.L.NPCs["69099"] = "Nalak"
private.L.NPCs["69161"] = "Oondasta"
private.L.NPCs["69664"] = "Mumta"
private.L.NPCs["69768"] = "Zandalari Warscout"
private.L.NPCs["69769"] = "Zandalari Warbringer"
private.L.NPCs["69841"] = "Zandalari Warbringer"
private.L.NPCs["69842"] = "Zandalari Warbringer"
private.L.NPCs["69843"] = "Zao'cho"
private.L.NPCs["69996"] = "Ku'lai the Skyclaw"
private.L.NPCs["69997"] = "Progenitus"
private.L.NPCs["69998"] = "Goda"
private.L.NPCs["69999"] = "God-Hulk Ramuk"
private.L.NPCs["70000"] = "Al'tabim the All-Seeing"
private.L.NPCs["70001"] = "Backbreaker Uru"
private.L.NPCs["70002"] = "Lu-Ban"
private.L.NPCs["70003"] = "Molthor"
private.L.NPCs["70096"] = "War-God Dokah"
private.L.NPCs["70126"] = "Willy Wilder"
private.L.NPCs["7015"] = "Flagglemurk the Cruel"
private.L.NPCs["7016"] = "Lady Vespira"
private.L.NPCs["7017"] = "Lord Sinslayer"
private.L.NPCs["70238"] = "Unblinking Eye"
private.L.NPCs["70243"] = "Archritualist Kelada"
private.L.NPCs["70249"] = "Focused Eye"
private.L.NPCs["70276"] = "No'ku Stormsayer"
private.L.NPCs["70323"] = "Krakkanon"
private.L.NPCs["70430"] = "Rocky Horror"
private.L.NPCs["70440"] = "Monara"
private.L.NPCs["70530"] = "Ra'sha"
private.L.NPCs["7104"] = "Dessecus"
private.L.NPCs["7137"] = "Immolatus"
private.L.NPCs["71864"] = "Spelurk"
private.L.NPCs["71919"] = "Zhu-Gon the Sour"
private.L.NPCs["71992"] = "Moonfang"
private.L.NPCs["72045"] = "Chelon"
private.L.NPCs["72048"] = "Rattleskew"
private.L.NPCs["72049"] = "Cranegnasher"
private.L.NPCs["72193"] = "Karkanos"
private.L.NPCs["72245"] = "Zesqua"
private.L.NPCs["72769"] = "Spirit of Jadefire"
private.L.NPCs["72775"] = "Bufo"
private.L.NPCs["72808"] = "Tsavo'ka"
private.L.NPCs["72909"] = "Gu'chi the Swarmbringer"
private.L.NPCs["72970"] = "Golganarr"
private.L.NPCs["73157"] = "Rock Moss"
private.L.NPCs["73158"] = "Emerald Gander"
private.L.NPCs["73160"] = "Ironfur Steelhorn"
private.L.NPCs["73161"] = "Great Turtle Furyshell"
private.L.NPCs["73163"] = "Imperial Python"
private.L.NPCs["73166"] = "Monstrous Spineclaw"
private.L.NPCs["73167"] = "Huolon"
private.L.NPCs["73169"] = "Jakur of Ordon"
private.L.NPCs["73170"] = "Watcher Osu"
private.L.NPCs["73171"] = "Champion of the Black Flame"
private.L.NPCs["73172"] = "Flintlord Gairan"
private.L.NPCs["73173"] = "Urdur the Cauterizer"
private.L.NPCs["73174"] = "Archiereus of Flame"
private.L.NPCs["73175"] = "Cinderfall"
private.L.NPCs["73277"] = "Leafmender"
private.L.NPCs["73279"] = "Evermaw"
private.L.NPCs["73281"] = "Dread Ship Vazuvius"
private.L.NPCs["73282"] = "Garnia"
private.L.NPCs["73293"] = "Whizzig"
private.L.NPCs["73666"] = "Archiereus of Flame"
private.L.NPCs["73704"] = "Stinkbraid"
private.L.NPCs["73854"] = "Cranegnasher"
private.L.NPCs["763"] = "Lost One Chieftain"
private.L.NPCs["7846"] = "Teremus the Devourer"
private.L.NPCs["79"] = "Narg the Taskmaster"
private.L.NPCs["8199"] = "Warleader Krazzilak"
private.L.NPCs["8200"] = "Jin'Zallah the Sandbringer"
private.L.NPCs["8201"] = "Omgorn the Lost"
private.L.NPCs["8203"] = "Kregg Keelhaul"
private.L.NPCs["8204"] = "Soriid the Devourer"
private.L.NPCs["8205"] = "Haarka the Ravenous"
private.L.NPCs["8207"] = "Emberwing"
private.L.NPCs["8208"] = "Murderous Blisterpaw"
private.L.NPCs["8210"] = "Razortalon"
private.L.NPCs["8211"] = "Old Cliff Jumper"
private.L.NPCs["8212"] = "The Reak"
private.L.NPCs["8213"] = "Ironback"
private.L.NPCs["8214"] = "Jalinde Summerdrake"
private.L.NPCs["8215"] = "Grimungous"
private.L.NPCs["8216"] = "Retherokk the Berserker"
private.L.NPCs["8217"] = "Mith'rethis the Enchanter"
private.L.NPCs["8218"] = "Witherheart the Stalker"
private.L.NPCs["8219"] = "Zul'arek Hatefowler"
private.L.NPCs["8277"] = "Rekk'tilac"
private.L.NPCs["8278"] = "Smoldar"
private.L.NPCs["8279"] = "Faulty War Golem"
private.L.NPCs["8280"] = "Shleipnarr"
private.L.NPCs["8281"] = "Scald"
private.L.NPCs["8282"] = "Highlord Mastrogonde"
private.L.NPCs["8283"] = "Slave Master Blackheart"
private.L.NPCs["8296"] = "Mojo the Twisted"
private.L.NPCs["8297"] = "Magronos the Unyielding"
private.L.NPCs["8298"] = "Akubar the Seer"
private.L.NPCs["8299"] = "Spiteflayer"
private.L.NPCs["8300"] = "Ravage"
private.L.NPCs["8301"] = "Clack the Reaver"
private.L.NPCs["8302"] = "Deatheye"
private.L.NPCs["8303"] = "Grunter"
private.L.NPCs["8304"] = "Dreadscorn"
private.L.NPCs["8503"] = "Gibblewilt"
private.L.NPCs["8660"] = "The Evalcharr"
private.L.NPCs["8923"] = "Panzor the Invincible"
private.L.NPCs["8924"] = "The Behemoth"
private.L.NPCs["8976"] = "Hematos"
private.L.NPCs["8978"] = "Thauris Balgarr"
private.L.NPCs["8979"] = "Gruklash"
private.L.NPCs["8981"] = "Malfunctioning Reaver"
private.L.NPCs["9217"] = "Spirestone Lord Magus"
private.L.NPCs["9218"] = "Spirestone Battle Lord"
private.L.NPCs["9219"] = "Spirestone Butcher"
private.L.NPCs["947"] = "Rohh the Silent"
private.L.NPCs["9596"] = "Bannok Grimaxe"
private.L.NPCs["9602"] = "Hahk'Zor"
private.L.NPCs["9604"] = "Gorgon'och"
private.L.NPCs["9718"] = "Ghok Bashguud"
private.L.NPCs["9736"] = "Quartermaster Zigris"
private.L.NPCs["99"] = "Morgaine the Sly"




SLASH__NPCSCAN1 = "/npcscan";
SLASH__NPCSCAN2 = "/scan";

BINDING_HEADER__NPCSCAN = "_|cffCCCC88NPCScan|r";
_G[ "BINDING_NAME_CLICK _NPCScanButton:LeftButton" ] = [=[Target last found mob
|cff808080(Use when _NPCScan alerts you)|r]=];