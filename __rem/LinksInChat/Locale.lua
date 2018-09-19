--####################################################################################
--####################################################################################
--Locale
--####################################################################################
--Dependencies: none

local Localization = {
	["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
		["Translator info"] = "", --Blank for enUS
		--## Title: Links in Chat
		--## Notes: Shows a popup window when clicking web-links in chat.
		--Copy frame
		["CopyFrame Title"] = "Links in Chat",
		["CopyFrame Info1"] = "Press ".. (IsMacClient() and "Cmd-C" or "Ctrl-C") .. " to copy the link.",
		["CopyFrame Info2"] = "Press ESC to close window.",
		--Settings frame
		["Settings Title"] = "Links in Chat "..GetAddOnMetadata("LinksInChat", "Version").." ",
		["Settings Info1"] = "Clicking on web-links (http:// or www.) will open a window to copy the link to your clipboard.\nMumble, Teamspeak, Ventrilo, Skype, e-mail and BattleTags are also supported.\nShift-clicking a web link will copy it into chat.",
		["Settings Info2"] = "You can also Alt-click hyperlinks (items, spells, etc) in chat to make web-links for them.",
		["Provider Info1"] = "Not all search-providers can do advanced-search, and not all hyperlink-types are supported. \nIn those cases simple-search will be used.",
		["Button Web link color"] = "Web link color...",
		["Check Ignore hyperlinks"] = "Ignore hyperlinks (items, spells, achievement, etc).",
		["Check Simple search"] = "Always simple-search (search for hyperlinks only by name and not by spell-Id etc).",
		["Check Use HTTPS"] = "Use HTTPS (recommended) instead of HTTP with search providers.",
		["Check Always English"] = "Always English search providers (changes with game-client language otherwise).",
		["Label Search provider"] = "Search provider for hyperlinks",
		--Auto hide dropdown values
		["Label Hide window after"] = "Hide window after...",
		["Dropdown Options Autohide"] = {
			["none"] = "Don't hide",
			["3sec"] = "3 seconds",
			["5sec"] = "5 seconds",
			["7sec"] = "7 seconds",
			["10sec"] = "10 seconds"
		}
	},--enUS
	["deDE"] = { --German (Germany)
		["Translator info"] = "'Übersetzt' mit Google translate :-/", --Last updated: 2014-05-15
		--## Title-deDE: Links im Chat
		--## Notes-deDE: Zeigt ein popup-fenster, wenn sie auf die links im chat klicken.
		--Copy frame
		--["CopyFrame Title"] = "Links in Chat",
		["CopyFrame Info1"] = "Drücken ".. (IsMacClient() and "Cmd-C" or "Ctrl-C") .. " den link zu kopieren.",
		["CopyFrame Info2"] = "Drücken ESC um das fenster zu schließen.",
		--Settings frame
		--["Settings Title"] = "Links in Chat "..GetAddOnMetadata("LinksInChat", "Version").." ",
		["Settings Info1"] = "Klick auf web-links (http:// oder www.) öffnet sich ein fenster, um den link in die zwischenablage \nkopieren. Mumble, Teamspeak, Ventrilo, Skype, e-mail und BattleTags werden \nebenfalls unterstützt. \nShift-klick ein web link wird es in den chat kopieren.",
		["Settings Info2"] = "Sie können auch Alt-klick hyperlinks (artikel, zauber, etc) im chat, um für sie zu machen web-links.",
		["Provider Info1"] = "Nicht alle suchanbieter können fortgeschritten-suche zu tun, und nicht alle hyperlink-typen \nwerden unterstützt. In diesen fällen einfach suche verwendet.",
		["Button Web link color"] = "Web link farbe...",
		["Check Ignore hyperlinks"] = "Ignorieren hyperlinks (artikel, zauber, erfolge, etc).",
		["Check Simple search"] = "Immer einfach-suche (suche für hyperlinks nur mit name und nicht durch zauber-Id etc).",
		["Check Use HTTPS"] = "Verwenden HTTPS (empfohlen) statt HTTP mit suchanbieter.",
		["Check Always English"] = "Immer Englisch suchanbieter (änderungen mit spiel-client sprache sonst).",
		["Label Search provider"] = "Suche anbieter für hyperlinks",
		--Auto hide dropdown values
		["Label Hide window after"] = "Fenster ausblenden nach...",
		["Dropdown Options Autohide"] = {
			["none"] = "Nicht verstecken",
			["3sec"] = "3 sekunden",
			["5sec"] = "5 sekunden",
			["7sec"] = "7 sekunden",
			["10sec"] = "10 sekunden"
		}
	},--deDE
	["esES"] = { --Spanish (Spain)
		["Translator info"] = "Spanish (spain) translation: Looking for volunteers."
	},--esES
	["esMX"] = { --Spanish (Mexico)
		["Translator info"] = "Spanish (mexico) translation: Looking for volunteers."
	},--esMX
	["frFR"] = { --French (France)
		["Translator info"] = "Traduction Française: Lassai sur Chants éternels.", --Last updated: 2014-05-15
		--## Title-frFR: Liens dans le tchat
		--## Notes-frFR: Fais apparaitre une fenetre quand l'utilisateur clique sur un lien.
		--Copy frame
		--["CopyFrame Title"] = "Liens dans la fenetre de discussion",
		["CopyFrame Info1"] = "Utilisez ".. (IsMacClient() and "Cmd-C" or "Ctrl-C") .. " pour copier le lien.",
		["CopyFrame Info2"] = "Appuyez ESC pour fermer la fenetre.",
		--Settings frame
		--["Settings Title"] = "Lien dans la fenetre de discussion "..GetAddOnMetadata("LinksInChat", "Version").." ",
		["Settings Info1"] = "En cliquant sur un lien web (http:// ou www.) vous accederez a une fenetre ou vous pourrez le \ncopier dans votre presse-papier. Mumble, Teamspeak, Ventrilo, Skype, e-mail et BattleTags \nsont aussi supportes.\nShift-cliquer un lien web le copie dans la fenetre de discussion.",
		["Settings Info2"] = "Vous pouvez egalement utiliser Alt-clique sur un lien de jeu (sorts, objets...) \ndans la fenetre de dialogue pour en faire un lien web.",
		["Provider Info1"] = "Certains sites supportent les recherches basees sur l'id d'un objet du jeu (sort, equippement, hf, ...). \nDans le cas contraire, une recherche basee sur le nom de l'objet est utilisee.",
		["Button Web link color"] = "Couleur des liens",
		["Check Ignore hyperlinks"] = "Ignorer les liens bases sur l'ID des objets (equippement, sort, hf, etc).",
		["Check Simple search"] = "Utiliser le nom des objets et non leur id pour les recherches.",
		["Check Use HTTPS"] = "Utiliser HTTPS (recommende) au lieu de HTTP.",
		["Check Always English"] = "Rechercher en anglais (ou dans la langue du client WOW).",
		["Label Search provider"] = "Recherche fournisseur", --Rechercher les objets par leur ID
		--Auto hide dropdown values
		["Label Hide window after"] = "Cache la fenetre apres...",
		["Dropdown Options Autohide"] = {
			["none"] = "Jamais",
			["3sec"] = "3 secondes",
			["5sec"] = "5 secondes",
			["7sec"] = "7 secondes",
			["10sec"] = "10 secondes"
		}
	},--frFR
	["itIT"] = { --Italian (Italy)
		["Translator info"] = "Traduzione in Italiano: Cassiopea a Doomhammer.", --Last updated: 2014-05-15
		--## Title-itIT: Collegamento in chat
		--## Notes-itIT: Mostra una finestra popup quando si clicca un collegamento nella chat.
		--Copy frame
		--["CopyFrame Title"] = "Collegamento in chat",
		["CopyFrame Info1"] = "Premere ".. (IsMacClient() and "Cmd-C" or "Ctrl-C") .. " per copiare il collegamento.",
		["CopyFrame Info2"] = "Premere ESC per chiudere la finestra.",
		--Settings frame
		--["Settings Title"] = "Collegamento in chat "..GetAddOnMetadata("LinksInChat", "Version").." ",
		["Settings Info1"] = "Cliccare su un collegamento web (http:// or www.) aprirà una finestra per copiare il collegamento \nnei tuoi appunti. Mumble, Teamspeak, Ventrilo, Skype, e-mail e BattleTags sono supportati.\nShift-clicking un collegamento web lo copierà nella chat.",
		["Settings Info2"] = "Facendo Alt-click su un collegamento ipertestuale (items, spells, etc) \nin chat puoi creare un collegamento web.",
		["Provider Info1"] = "Non tutti i motori di ricerca posssono fare una ricerca avanzata, e non tutti i collegamenti \nipertestuali sono supportati. In questi casi verrà utilizzata una ricerca standard.",
		["Button Web link color"] = "Colori dei link...",
		["Check Ignore hyperlinks"] = "Ignora collegamenti ipertestuali (items, spells, achievement, etc).",
		["Check Simple search"] = "Utilizzare i nomi degli oggetti e non il loro id per la ricerca.",
		["Check Use HTTPS"] = "Usa HTTPS (recomandato) al posto di HTTP con i motori di ricerca.",
		["Check Always English"] = "Motori di ricerca in Inglese (o nella lingua del cliente di WOW).",
		["Label Search provider"] = "Provider di ricerca",
		--Auto hide dropdown values
		["Label Hide window after"] = "Nascondi la finestra dopo...",
		["Dropdown Options Autohide"] = {
			["none"] = "Non nascondere",
			["3sec"] = "3 secondi",
			["5sec"] = "5 secondi",
			["7sec"] = "7 secondi",
			["10sec"] = "10 secondi"
		}
	},--itIT
	["koKR"] = { --Korean (Korea)
		["Translator info"] = "Korean translation: Looking for volunteers."
	},--koKR
	["ptBR"] = { --Portuguese (Brazil)
		["Translator info"] = "Portugese translation: Looking for volunteers."
	},--ptBR
	["ruRU"] = { --Russian (Russia)
		["Translator info"] = "Russian translation: Looking for volunteers."
	},--ruRU
	["zhCN"] = { --Chinese (Simplified, PRC)
		["Translator info"] = "Chinese (prc) translation: Looking for volunteers."
	},--zhCN
	["zhTW"] = { --Chinese (Traditional, Taiwan)
		["Translator info"] = "Chinese (taiwan) translation: Looking for volunteers."
	}--zhTW
}--Localization


------------------------------------------------------------------------------------------
local currentLocale = {};
local L = GetLocale(); --Localization to the current game-client language
if (L == "enGB") then L = "enUS"; end
do
	for k,v in pairs(Localization.enUS) do
		if not Localization[L][k] or Localization[L][k] == false then
			currentLocale[k] = Localization.enUS[k]; --We use the default enUS localization strings if nothing else is defined
		else
			currentLocale[k] = Localization[L][k];
		end
	end
end
Localization = nil; --cleanup

--Global Declaration
LinksInChat_Locale = currentLocale; --Global declaration

--####################################################################################
--####################################################################################