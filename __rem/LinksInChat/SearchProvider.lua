--####################################################################################
--####################################################################################
--SearchProvider
--####################################################################################
--Dependencies: none

local SearchProvider = {};
SearchProvider.__index		= SearchProvider;
LinksInChat_SearchProvider	= SearchProvider; --Global declaration


--Local variables that cache stuff so we dont have to recreate large objects
local cache_GameLocale		= GetLocale();	--Localization to the current game-client language
local cache_Provider		= nil;			--Table with provider data
local cache_Provider_Locale	= "";			--String. Language code for provider data


--Declaration of Provider dataset
local CONST_Provider_Sorted = {[1]="bing", [2]="google", [3]="yahoo", [4]="wowdb", [5]="wowhead", [6]="eu.battle.net", [7]="us.battle.net", [8]="asia.battle.net", [9]="buffed.de", [10]="judgehype" }; --Array with provider key's in a 'sorted' order

local CONST_Provider = {
	["google"] = { --Google --(this key must be uniqe and is what we save as 'provider' in settings)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "Google (simple)",					--Title in dropdown menu
			["Simple"]		= "https://www.google.com/search?q=",	--Simple search HTTPS link
			["Advanced"]	= ""									--Empty string or comma separated list with hyperlinks supported
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "Google (einfach)",
			["Simple"]		= "https://www.google.de/search?q=",
			["Advanced"]	= ""
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "Google (simple)",
			["Simple"]		= "https://www.google.es/search?q=",
			["Advanced"]	= ""
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "Google (simple)",
			["Simple"]		= "https://www.google.com.mx/search?q=",
			["Advanced"]	= ""
		},
		["frFR"] = { --French (France)
			["Title"]		= "Google (simple)",
			["Simple"]		= "https://www.google.fr/search?q=",
			["Advanced"]	= ""
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "Google (semplice)",
			["Simple"]		= "https://www.google.it/search?q=",
			["Advanced"]	= ""
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "Google (단순한)",
			["Simple"]		= "https://www.google.co.kr/search?q=",
			["Advanced"]	= ""
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "Google (simple)",
			["Simple"]		= "https://www.google.br/search?q=",
			["Advanced"]	= ""
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "Google (простой)",
			["Simple"]		= "https://www.google.ru/search?q=",
			["Advanced"]	= ""
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "Google (简单)",
			["Simple"]		= "https://www.google.com.hk/search?q=",
			["Advanced"]	= ""
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "Google (簡單)",
			["Simple"]		= "https://www.google.com.tw/search?q=",
			["Advanced"]	= ""
		}
	},--google

	["bing"] = { --Bing (simple, all languages)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "Bing (simple)",					--Title in dropdown menu
			["Simple"]		= "https://www.bing.com/search?q=",	--Simple search HTTPS link
			["Advanced"]	= ""								--Empty string or comma separated list with hyperlinks supported
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "Bing (einfach)",
			["Simple"]		= "https://www.bing.com/search?cc=de&q=",
			["Advanced"]	= ""
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "Bing (simple)",
			["Simple"]		= "https://www.bing.com/search?cc=es&q=",
			["Advanced"]	= ""
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "Bing (simple)",
			["Simple"]		= "https://www.bing.com/search?cc=mx&q=",
			["Advanced"]	= ""
		},
		["frFR"] = { --French (France)
			["Title"]		= "Bing (simple)",
			["Simple"]		= "https://www.bing.com/search?cc=fr&q=",
			["Advanced"]	= ""
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "Bing (semplice)",
			["Simple"]		= "https://www.bing.com/search?cc=it&q=",
			["Advanced"]	= ""
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "Bing (단순한)",
			["Simple"]		= "https://www.bing.com/search?cc=kr&q=",
			["Advanced"]	= ""
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "Bing (simple)",
			["Simple"]		= "https://www.bing.com/search?cc=br&q=",
			["Advanced"]	= ""
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "Bing (простой)",
			["Simple"]		= "https://www.bing.com/search?cc=ru&q=",
			["Advanced"]	= ""
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "Bing (简单)",
			["Simple"]		= "https://www.bing.com/search?cc=cn&q=",
			["Advanced"]	= ""
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "Bing (簡單)",
			["Simple"]		= "https://www.bing.com/search?cc=tw&q=",
			["Advanced"]	= ""
		}
	},--bing

	["yahoo"] = { --Yahoo (simple, all languages)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "Yahoo (simple)",						--Title in dropdown menu
			["Simple"]		= "https://search.yahoo.com/search?p=",	--Simple search HTTPS link
			["Advanced"]	= ""									--Empty string or comma separated list with hyperlinks supported
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "Yahoo (einfach)",
			["Simple"]		= "https://de.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "Yahoo (simple)",
			["Simple"]		= "https://es.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "Yahoo (simple)",
			["Simple"]		= "https://mx.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["frFR"] = { --French (France)
			["Title"]		= "Yahoo (simple)",
			["Simple"]		= "https://fr.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "Yahoo (semplice)",
			["Simple"]		= "https://it.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "Yahoo (단순한)",
			["Simple"]		= "https://kr.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "Yahoo (simple)",
			["Simple"]		= "https://br.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "Yahoo (простой)",
			["Simple"]		= "https://ru.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "Yahoo (简单)",
			["Simple"]		= "https://hk.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "Yahoo (簡單)",
			["Simple"]		= "https://tw.search.yahoo.com/search?p=",
			["Advanced"]	= ""
		}
	},--yahoo

	["wowhead"] = { --Wowhead (english, german, spanish/mexico, french, italian, portugese, russian)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "Wowhead (simple & advanced)",			--Title in dropdown menu
			["Simple"]		= "https://www.wowhead.com/?search=",		--Simple search HTTPS link
			["Advanced"]	= "item,spell,achievement,currency,quest",	--Empty string or comma separated list with hyperlinks supported
			["Advanced-item"]			= "https://www.wowhead.com/item=",
			["Advanced-spell"]			= "https://www.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://www.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://www.wowhead.com/currency=",
			["Advanced-quest"]			= "https://www.wowhead.com/quest="
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "Wowhead (einfach & fortgeschritten)",
			["Simple"]		= "https://de.wowhead.com/?search=",
			["Advanced"]	= "item,spell,achievement,currency,quest",
			["Advanced-item"]			= "https://de.wowhead.com/item=",
			["Advanced-spell"]			= "https://de.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://de.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://de.wowhead.com/currency=",
			["Advanced-quest"]			= "https://de.wowhead.com/quest="
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "Wowhead (simple & avanzado)",
			["Simple"]		= "https://es.wowhead.com/?search=",
			["Advanced"]	= "item,spell,achievement,currency,quest",
			["Advanced-item"]			= "https://es.wowhead.com/item=",
			["Advanced-spell"]			= "https://es.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://es.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://es.wowhead.com/currency=",
			["Advanced-quest"]			= "https://es.wowhead.com/quest="
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "Wowhead (simple & avanzado)",
			["Simple"]		= "https://es.wowhead.com/?search=",
			["Advanced"]	= "item,spell,achievement,currency,quest",
			["Advanced-item"]			= "https://es.wowhead.com/item=",
			["Advanced-spell"]			= "https://es.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://es.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://es.wowhead.com/currency=",
			["Advanced-quest"]			= "https://es.wowhead.com/quest="
		},
		["frFR"] = { --French (France)
			["Title"]		= "Wowhead (simple & avancé)",
			["Simple"]		= "https://fr.wowhead.com/?search=",
			["Advanced"]	= "item,spell,achievement,currency,quest",
			["Advanced-item"]			= "https://fr.wowhead.com/item=",
			["Advanced-spell"]			= "https://fr.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://fr.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://fr.wowhead.com/currency=",
			["Advanced-quest"]			= "https://fr.wowhead.com/quest="
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "Wowhead (semplice e avanzato)",
			["Simple"]		= "https://it.wowhead.com/?search=",
			["Advanced"]	= "item,spell,achievement,currency,quest",
			["Advanced-item"]			= "https://it.wowhead.com/item=",
			["Advanced-spell"]			= "https://it.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://it.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://it.wowhead.com/currency=",
			["Advanced-quest"]			= "https://it.wowhead.com/quest="
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "Wowhead (심플 & 고급)",
			--Not supported
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "Wowhead (simples & avançado)",
			["Simple"]		= "https://pt.wowhead.com/?search=",
			["Advanced"]	= "item,spell,achievement,currency,quest",
			["Advanced-item"]			= "https://pt.wowhead.com/item=",
			["Advanced-spell"]			= "https://pt.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://pt.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://pt.wowhead.com/currency=",
			["Advanced-quest"]			= "https://pt.wowhead.com/quest="
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "Wowhead (простой & продвинутый)",
			["Simple"]		= "https://ru.wowhead.com/?search=",
			["Advanced"]	= "item,spell,achievement,currency,quest",
			["Advanced-item"]			= "https://ru.wowhead.com/item=",
			["Advanced-spell"]			= "https://ru.wowhead.com/spell=",
			["Advanced-achievement"]	= "https://ru.wowhead.com/achievement=",
			["Advanced-currency"]		= "https://ru.wowhead.com/currency=",
			["Advanced-quest"]			= "https://ru.wowhead.com/quest="
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "Wowhead (简单 & 先进)";
			--Not supported
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "Wowhead (簡單 & 先進)";
			--Not supported
		}
	},--wowhead

	["wowdb"] = { --WowDB (english)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "WowDB.com (simple & advanced)",			--Title in dropdown menu
			["Simple"]		= "https://www.wowdb.com/search?search=",	--Simple search HTTPS link
			["Advanced"]	= "item,spell,achievement,currency,quest",	--Empty string or comma separated list with hyperlinks supported
			["Advanced-item"]			= "https://www.wowdb.com/items/",
			["Advanced-spell"]			= "https://www.wowdb.com/spells/",
			["Advanced-achievement"]	= "https://www.wowdb.com/achievements/",
			["Advanced-currency"]		= "https://www.wowdb.com/currencies/",
			["Advanced-quest"]			= "https://www.wowdb.com/quests/"
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "WowDB.com (einfach & fortgeschritten)",
			--Not supported
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "WowDB.com (simple & avanzado)",
			--Not supported
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "WowDB.com (simple & avanzado)",
			--Not supported
		},
		["frFR"] = { --French (France)
			["Title"]		= "WowDB.com (simple & avancé)",
			--Not supported
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "WowDB.com (semplice e avanzato)",
			--Not supported
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "WowDB.com (심플 & 고급)",
			--Not supported
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "WowDB.com (simples & avançado)",
			--Not supported
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "WowDB.com (простой & продвинутый)",
			--Not supported
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "WowDB.com (简单 & 先进)";
			--Not supported
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "WowDB.com (簡單 & 先進)";
			--Not supported
		}
	},--wowdb

	["eu.battle.net"] = { --eu.battle.net (english, german, spanish, french, italian, russian, portugese)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "eu.battle.net (simple)",					--Title in dropdown menu
			["Simple"]		= "https://eu.battle.net/wow/en/search?q=",	--Simple search HTTPS link
			["Advanced"]	= "item",									--Empty string or comma separated list with hyperlinks supported
			["Advanced-item"] = "https://eu.battle.net/wow/en/item/"
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "eu.battle.net (einfach)",
			["Simple"]		= "https://eu.battle.net/wow/de-de/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://eu.battle.net/wow/de-de/item/"
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "eu.battle.net (simple)",
			["Simple"]		= "https://eu.battle.net/wow/es-es/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://eu.battle.net/wow/es-es/item/"
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "eu.battle.net (simple)",
			--Not supported
		},
		["frFR"] = { --French (France)
			["Title"]		= "eu.battle.net (simple)",
			["Simple"]		= "https://eu.battle.net/wow/fr-fr/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://eu.battle.net/wow/fr-fr/item/"
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "eu.battle.net (semplice)",
			["Simple"]		= "https://eu.battle.net/wow/it-it/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://eu.battle.net/wow/it-it/item/"
		},
		["koKR"] = { --Korean (Korea)
			--Not supported
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "eu.battle.net (simples)",
			["Simple"]		= "https://eu.battle.net/wow/pt-pt/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://eu.battle.net/wow/pt-pt/item/"
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "eu.battle.net (простой)",
			["Simple"]		= "https://eu.battle.net/wow/ru-ru/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://eu.battle.net/wow/ru-ru/item/"
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			--Not supported
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			--Not supported
		}
	},--eu.battle.net

	["us.battle.net"] = { --us.battle.net (us, mexico, brazil)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "us.battle.net (simple)",						--Title in dropdown menu
			["Simple"]		= "https://us.battle.net/wow/en-us/search?q=",	--Simple search HTTPS link
			["Advanced"]	= "item",										--Empty string or comma separated list with hyperlinks supported
			["Advanced-item"] = "https://us.battle.net/wow/en-us/item/"
		},--enUS
		["deDE"] = { --German (Germany)
			--Not supported
		},
		["esES"] = { --Spanish (Spain)
			--Not supported
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "us.battle.net (simple)",
			["Simple"]		= "https://us.battle.net/wow/es-mx/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://us.battle.net/wow/es-mx/item/"
		},
		["frFR"] = { --French (France)
			--Not supported
		},
		["itIT"] = { --Italian (Italy)
			--Not supported
		},
		["koKR"] = { --Korean (Korea)
			--Not supported
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "us.battle.net (simples)",
			["Simple"]		= "https://us.battle.net/wow/pt-br/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://us.battle.net/wow/pt-br/item/"
		},
		["ruRU"] = { --Russian (Russia)
			--Not supported
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			--Not supported
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			--Not supported
		}
	},--us.battle.net

	["asia.battle.net"] = { --kr.battle.net  (some HTTP, southeast asia, korean, china, taiwan)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "battle.net - Southeast Asia (simple)",		--Title in dropdown menu
			["Simple"]		= "https://sea.battle.net/wow/en-us/search?q=",	--Simple search HTTPS link
			["Advanced"]	= "item",										--Empty string or comma separated list with hyperlinks supported
			["Advanced-item"] = "https://sea.battle.net/wow/en-us/item/"
		},--enUS
		["deDE"] = { --German (Germany)
			--Not supported
		},
		["esES"] = { --Spanish (Spain)
			--Not supported
		},
		["esMX"] = { --Spanish (Mexico)
			--Not supported
		},
		["frFR"] = { --French (France)
			--Not supported
		},
		["itIT"] = { --Italian (Italy)
			--Not supported
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "kr.battle.net (심플)",
			["Simple"]		= "https://kr.battle.net/wow/ko-kr/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://kr.battle.net/wow/ko-kr/item/"
		},
		["ptBR"] = { --Portuguese (Brazil)
			--Not supported
		},
		["ruRU"] = { --Russian (Russia)
			--Not supported
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "battlenet.com.cn (简单)";
			["Simple"]		= "http://battlenet.com.cn/wow/zh-cn/search?q=", --only HTTP
			["Advanced"]	= "item",
			["Advanced-item"] = "http://battlenet.com.cn/wow/zh-cn/item/"
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "tw.battle.net (簡單)";
			["Simple"]		= "https://tw.battle.net/wow/zh-tw/search?q=",
			["Advanced"]	= "item",
			["Advanced-item"] = "https://tw.battle.net/wow/zh-tw/item/"
		}
	},--asia.battle.net

	["buffed.de"] = { --Buffed.de (only HTTP, english, german, russian)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "Buffed.de (simple & advanced)",		--Title in dropdown menu
			["Simple"]		= "http://wowdata.getbuffed.com/?f=",	--Simple search HTTPS link
			["Advanced"]	= "item,spell,achievement,quest",		--Empty string or comma separated list with hyperlinks supported
			["Advanced-item"]			= "http://wowdata.getbuffed.com/?i=",
			["Advanced-spell"]			= "http://wowdata.getbuffed.com/?s=",
			["Advanced-achievement"]	= "http://wowdata.getbuffed.com/?a=",
			["Advanced-quest"]			= "http://wowdata.getbuffed.com/?q="
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "Buffed.de (einfach & fortgeschritten)",
			["Simple"]		= "http://wowdata.buffed.de/?f=",
			["Advanced"]	= "item,spell,achievement,quest",
			["Advanced-item"]			= "http://wowdata.buffed.de/?i=",
			["Advanced-spell"]			= "http://wowdata.buffed.de/?s=",
			["Advanced-achievement"]	= "http://wowdata.buffed.de/?a=",
			["Advanced-quest"]			= "http://wowdata.buffed.de/?q="
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "Buffed.de (simple & avanzado)"
			--Not supported
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "Buffed.de (simple & avanzado)"
			--Not supported
		},
		["frFR"] = { --French (France)
			["Title"]		= "Buffed.de (simple & avancé)"
			--Not supported
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "Buffed.de (semplice e avanzato)"
			--Not supported
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "Buffed.de (심플 & 고급)"
			--Not supported
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "Buffed.de (simples & avançado)"
			--Not supported
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "Buffed.de (простой & продвинутый)",
			["Simple"]		= "http://wowdata.buffed.ru/?f=",
			["Advanced"]	= "item,spell,achievement,quest",
			["Advanced-item"]			= "http://wowdata.buffed.ru/?i=",
			["Advanced-spell"]			= "http://wowdata.buffed.ru/?s=",
			["Advanced-achievement"]	= "http://wowdata.buffed.ru/?a=",
			["Advanced-quest"]			= "http://wowdata.buffed.ru/?q="
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "Buffed.de (简单 & 先进)"
			--Not supported
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "Buffed.de (簡單 & 先進)"
			--Not supported
		}
	},--buffed.de

	["judgehype"] = { --Judgehype (only HTTP, french)
		["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
			["Title"]		= "JudgeHype (simple & advanced)",						--Title in dropdown menu
			["Simple"]		= "http://worldofwarcraft.judgehype.com/db-resultat/",	--Simple search HTTPS link
			["Advanced"]	= "item,spell,achievement,quest",						--Empty string or comma separated list with hyperlinks supported
			["Advanced-item"]			= "http://worldofwarcraft.judgehype.com/objet/",
			["Advanced-spell"]			= "http://worldofwarcraft.judgehype.com/spell/",
			["Advanced-achievement"]	= "http://worldofwarcraft.judgehype.com/hautfait/",
			["Advanced-quest"]			= "http://worldofwarcraft.judgehype.com/quete/"
		},--enUS
		["deDE"] = { --German (Germany)
			["Title"]		= "JudgeHype (einfach & fortgeschritten)"
			--Not supported
		},
		["esES"] = { --Spanish (Spain)
			["Title"]		= "JudgeHype (simple & avanzado)"
			--Not supported
		},
		["esMX"] = { --Spanish (Mexico)
			["Title"]		= "JudgeHype (simple & avanzado)"
			--Not supported
		},
		["frFR"] = { --French (France)
			["Title"]		= "JudgeHype (simple & avancé)",
			["Simple"]		= "http://worldofwarcraft.judgehype.com/db-resultat/",
			["Advanced"]	= "item,spell,achievement,quest",
			["Advanced-item"]			= "http://worldofwarcraft.judgehype.com/objet/",
			["Advanced-spell"]			= "http://worldofwarcraft.judgehype.com/spell/",
			["Advanced-achievement"]	= "http://worldofwarcraft.judgehype.com/hautfait/",
			["Advanced-quest"]			= "http://worldofwarcraft.judgehype.com/quete/"
		},
		["itIT"] = { --Italian (Italy)
			["Title"]		= "JudgeHype (semplice e avanzato)"
			--Not supported
		},
		["koKR"] = { --Korean (Korea)
			["Title"]		= "JudgeHype (심플 & 고급)"
			--Not supported
		},
		["ptBR"] = { --Portuguese (Brazil)
			["Title"]		= "JudgeHype (simples & avançado)"
			--Not supported
		},
		["ruRU"] = { --Russian (Russia)
			["Title"]		= "JudgeHype (простой & продвинутый)"
			--Not supported
		},
		["zhCN"] = { --Chinese (Simplified, PRC)
			["Title"]		= "JudgeHype (简单 & 先进)"
			--Not supported
		},
		["zhTW"] = { --Chinese (Traditional, Taiwan)
			["Title"]		= "JudgeHype (簡單 & 先進)"
			--Not supported
		}
	}--judgehype

}--CONST_Provider


--####################################################################################
--####################################################################################
--Public
--####################################################################################


--Initalizes the provider table structure that we will use later
function SearchProvider:InitializeProvider(booEnglish)
	if (booEnglish ~= true) then booEnglish = false; end --Boolean

	local L = cache_GameLocale; --Localization to the current game-client language
	if (L == "enGB") then L = "enUS"; end
	if (booEnglish) then L = "enUS"; end --Always use english search providers.
	if (cache_Provider ~= nil and cache_Provider_Locale == L) then return cache_Provider; end --If the table is cached from earlier call then return that
	local res = {};
	for providerKey,locale in pairs(CONST_Provider) do --key = "provider uniqe name", value = table with localized provider data
		providerKey = strlower(providerKey);
		res[providerKey] = {};

		for k,v in pairs(locale.enUS) do
			if not locale[L][k] or locale[L][k] == false then
				res[providerKey][k] = locale.enUS[k]; --We use the default enUS localization strings if nothing else is defined
			else
				res[providerKey][k] = locale[L][k];
			end--if
		end--for locale.enUS
	end--for CONST_Provider

	cache_Provider = res; --Store for later
	cache_Provider_Locale = L;
	return cache_Provider;
end


--Returns true/false if a provider exists at all
function SearchProvider:ProviderExists(strProvider)
	if (strProvider == nil) then return false; end
	strProvider = strlower(tostring(strProvider));

	if (CONST_Provider[strProvider] ~= nil) then return true; end
	return false;
end


--Returns nil or the data for a given search provider ("all" == return all providers).
function SearchProvider:GetProvider(strProvider)
	if (cache_Provider == nil) then error("Search provider table not initalized"); end

	if (strProvider == nil) then return false; end
	strProvider = strlower(tostring(strProvider));
	if (strProvider == "all") then return cache_Provider, CONST_Provider_Sorted; end
	return cache_Provider[strProvider];
end


--####################################################################################
--####################################################################################