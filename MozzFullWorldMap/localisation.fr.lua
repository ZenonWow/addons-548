-- With thanks to Truc M. for the translation

if ( GetLocale() == "frFR" ) then

	MFWM.L["BINDING_HEADER_MFWM"]           = "MFWM"; 
	MFWM.L["BINDING_NAME_MOZZ_WM_CHECKBOX"] = "Afficher les zones inexplorées";
	MFWM.L["LOADED"]                        = "MFWM (Fan's Update) chargé";

	MFWM.L["ERRATA1"] = "Votre version de %s est peut-être obsolète...";
	MFWM.L["ERRATA2"] = "vous avez trouvé une erreur de conversion de données";
	MFWM.L["ERRATA3"] = "Si vous utilisez la version la plus récente de %s, merci de vous déconnecter et d'envoyer votre saved variables %s à %s";
	MFWM.L["ERRATA4"] = "ou postez votre fichier de saved variables dans le forum de support technique à %s. Sinon, mettez à jour votre version de %s";

	MFWM.L["OPTION_SHOW"]       = "Révèle les zones inexplorées sur la carte"
	MFWM.L["OPTION_DATA"]       = "Surligne les données en cache sur la carte"
	MFWM.L["OPTION_DUMP"]       = "Sauvergarde le cache de la carte courante dans les saved variables"
	MFWM.L["OPTION_DEBUG"]      = "Ecrit les données de debug dans les saved variables"
	MFWM.L["OPTION_LABEL"]      = "Labellise les panneaux de la carte pour du debug visuel"
	MFWM.L["OPTION_NORMAL"]     = "Montrer les zones inexplorées sans couleur"
	MFWM.L["OPTION_EMERALD"]    = "Montrer les zones inexplorées avec une couleur émeraude"
	MFWM.L["OPTION_CUSTOM"]     = "Utiliser une couleur personnalisée pour colorier les zones inexplorées"
	MFWM.L["OPTION_ALPHA"]      = "Règle l'opacité des zones inexplorées"
	MFWM.L["OPTION_RED"]        = "Règle la composante rouge (R) de la couleur"
	MFWM.L["OPTION_GREEN"]      = "Règle la composante verte (V) de la couleur"
	MFWM.L["OPTION_BLUE"]       = "Règle la composante bleue (B) de la couleur"
	MFWM.L["OPTION_HUE"]        = "Règle la teinte (H) de la couleur"
	MFWM.L["OPTION_SATURATION"] = "Règle la saturation (S) de la couleur"
	MFWM.L["OPTION_VALUE"]      = "Règle la valeur (V) de la couleur"

	MFWM.L["OPTION_MESSAGE"]    = "|cFFFF00FFMFWM|r a été créé initialement par Mozz, mis à jour "..
								  "par Shub, maintenu par Telic, puis entièrement réécrit et "..
								  "maintenu actuellement en vie par K. Scott Piel "..
								  "(|cFF00FFFFkscottpiel@nUIaddon.com|r). "..
								  "Quand il est activé, |cFFFF00FFMFWM|r révèle les zones inexplorées "..
								  "de la carte du mone qui sont normalement caché. Ces réglages "..
								  "vous permettent de personnaliser comment ces zones sont révélées."..
								  "\n\n"..
								  "Pour le support, pour remonter un bug ou soumettre un errata, aller sur "..
								  "|cFF00FFFFhttp://forums.nUIaddon.com|r. "..
								  "Si vous trouvez |cFFFF00FFMFWM|r utile, merci de nous aider "..
								  "en faisant un don à l'auteur sur "..
								  "|cFF00FFFFhttp://www.nUIaddon.com|r";	
end