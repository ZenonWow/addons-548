local folder, core = ...
local L = LibStub("AceLocale-3.0"):NewLocale(folder, "deDE")
if not L then return end
L["Add Spell Description"] = "Zauber-Beschreibung hinzufügen"
L["Add buffs above NPCs"] = "Stärkungszauber über NPCs anzeigen"
L["Add buffs above friendly plates"] = "Stärkungszauber über freundlichen Einheiten anzeigen"
L["Add buffs above hostile plates"] = "Stärkungszauber über feindlichen Einheiten anzeigen"
L["Add buffs above neutral plates"] = "Stärkungszauber über neutralen Einheiten anzeigen"
L["Add buffs above players"] = "Stärkungszauber über Spielern anzeigen"
L["Add spell"] = "Zauber hinzufügen"
L[ [=[Add spell descriptions to the specific spell's list.
Disabling this will lower memory usage and login time.]=] ] = [=[Zauber-Beschreibungen zu der Liste Spezieller Zauber hinzufügen.
Deaktivieren, um Speicherbelastung und Einlog-Zeit zu verringern.]=]
L["Add spell to list."] = "Zauber zur Liste hinzufügen"
L["Added: "] = "Hinzugefügt:"
L["All"] = "Alle"
L["Always"] = "Immer"
L["Always show spell, only show your spell, never show spell"] = "Zauber immer anzeigen, nur Deine Zauber anzeigen, Zauber nie anzeigen"
L["Bar"] = "Leiste"
L["Bar Anchor Point"] = "Leisten-Ankerpunkt"
L["Bar Growth"] = "Leistenwachstum"
L["Bar X Offset"] = "Leiste X Versetzung"
L["Bar Y Offset"] = "Leiste Y Versetzung"
L["Bars"] = "Leisten"
L["Blink Timeleft"] = "Übrige Zeit, ab der ein Zauber blinkt"
L["Blink spell if below x% timeleft, (only if it's below 60 seconds)"] = "Zauber blinken lassen, wenn übrige Zeit unter x% liegt, (nur unter 60 Sekunden)"
L["Bottom"] = "Unten"
L["Bottom Left"] = "Unten links"
L["Bottom Right"] = "Unten rechts"
L["Center"] = "Mitte"
L["Cooldown Size"] = "Cooldown-Größe"
L["Cooldown Text Size"] = "Cooldown-Textgröße"
L["Core"] = "Kern" -- Needs review
L["Default Spells"] = "Standard Zauber"
L["Display a question mark above plates we don't know spells for. Target or mouseover those plates."] = "Fragezeichen über Plaketten anzeigen, bei denen die Zauber nicht bekannt sind. Diese Plaketten anwählen oder mit der Maus darüber fahren."
L["Down"] = "Nach unten"
L["Enable"] = "Aktivieren"
L["Enables / Disables the addon"] = "Aktiviert/Deaktiviert das Addon"
L[ [=[For each spell on someone, multiply it by the number of icons per bar.
This option won't be saved at logout.]=] ] = [=[Jeden Zauber auf jemanden mit der Anzahl an Symbolen pro Leiste vervielfachen.
Diese Option wird beim Ausloggen nicht gespeichert.]=]
L["Friendly"] = "Freundlich"
L["Hostile"] = "Feindlich"
L["Icon Size"] = "Symbolgröße"
L["Icons per bar"] = "Symbole pro Leiste"
L["Input a spell name. (case sensitive)"] = "Einen Zaubernamen eingeben. (Groß- und Kleinschreibung wird berücksichtigt)"
L[ [=[Input a spell name. (case sensitive)
Or spellID]=] ] = [=[Einen Zauber-Namen eingeben. (Groß- und Kleinschreibung wird berücksichtigt)
Oder Zauber-ID]=]
L["Larger self spells"] = "Größere eigene Zauber"
L["Left"] = "Links"
L["Left to right offset."] = "Versetzung rechts nach links."
L["Make your spells 20% bigger then other's."] = "Deine Zauber um 20% größer darstellen als die der anderen."
L["Max bars"] = "Max. Leisten"
L["Max number of bars to show."] = "Maximale Anzahl an Leisten die angezeigt werden sollen."
L["Mine Only"] = "Nur meine"
L["Mine only"] = "Nur meine"
L["NPC"] = "NPC"
L["NPC combat only"] = "NPC nur im Kampf"
L["Neutral"] = "Neutral"
L["Never"] = "Nie"
L["None"] = "Keine"
L["Number of icons to display per bar."] = "Anzahl an Symbolen die pro Leiste angezeigt werden sollen."
L["Only show spells above nameplates that are in combat."] = "Zauber nur über Namensplaketten anzeigen, die sich im Kampf befinden."
L["Other"] = "Sonstige"
L["Plate Anchor Point"] = "Plaketten-Ankerpunkt"
L["Player combat only"] = "Spieler nur im Kampf"
L["Players"] = "Spieler"
L[ [=[Point of the buff frame that gets anchored to the nameplate.
default = Bottom]=] ] = [=[Stelle der Stärkungszauber-Anzeige, die an der Namensplakette verankert wird.
Standard = Unten]=]
L[ [=[Point of the nameplate our buff frame gets anchored to.
default = Top]=] ] = [=[Stelle der Namensplakette, an der die Stärkungszauber-Anzeige verankert wird.
Standard = Oben]=]
L["Profiles"] = "Profile"
L["Reaction"] = "Reaktion"
L[ [=[Remember player GUID's so target/mouseover isn't needed every time nameplate appears.
Keep this enabled]=] ] = [=[Spieler GUID's behalten, sodass anwählen/mit der Maus darüber fahren nicht jedesmal benötigt wird, wenn die Namensplakette erscheint.
Lass dies aktiviert]=]
L["Remove Spell"] = "Zauber entfernen"
L["Remove spell from list"] = "Zauber von der Liste entfernen"
L["Right"] = "Rechts"
L["Row Anchor Point"] = "Reihen-Ankerpunkt"
L["Row Growth"] = "Reihenwachstum"
L["Row X Offset"] = "Reihen X Versetzung"
L["Row Y Offset"] = "Reihen Y Versetzung"
L["Rows"] = "Reihen"
L["Save player GUID"] = "Spieler GUID speichern"
L["Save player GUID's"] = "Speichere Spieler GUID's"
L["Show"] = "Anzeigen"
L["Show Aura"] = "Aura anzeigen"
L["Show Buffs"] = "Stärkungszauber anzeigen"
L["Show Debuffs"] = "Schwächungszauber anzeigen"
L["Show Totems"] = "Totems anzeigen"
L["Show a clock overlay over spell textures showing the time remaining."] = "Eine Uhr über Zauber-Texturen einblenden, die die verbleibende Zeit anzeigt"
L["Show auras above nameplate. This sometimes causes duplicate buffs."] = "Auren über Namensplakette anzeigen. Dies kann doppelte Buffs verursachen."
L["Show bar background"] = "Leistenhintergrund anzeigen"
L["Show buffs above nameplate."] = "Stärkungszauber über Namensplaketten anzeigen."
L["Show by default"] = "Standardmäßig anzeigen"
L["Show cooldown"] = "Cooldown anzeigen"
L["Show cooldown overlay"] = "Cooldown-Einblendung anzeigen"
L["Show cooldown text under the spell icon."] = "Zeige die Abklingzeit als Text unter dem Zaubersymbol."
L["Show debuffs above nameplate."] = "Schwächungszauber über Namensplaketten anzeigen."
L["Show question mark"] = "Fragezeichen anzeigen"
L["Show spell icons on totems"] = "Zeige Zaubersymbole bei Totems"
L["Show the area where spell icons will be. This is to help you configure the bars."] = "Bereich anzeigen, in dem Zauber-Symbole sich befinden werden. Dies soll dir helfen, die Leisten zu konfigurieren."
L["Shrink Bar"] = "Leiste verkleinern"
L["Shrink the bar horizontally when spells frames are hidden."] = "Die Leiste horizontal verkleinern, wenn Zauber-Anzeigen versteckt sind."
L["Size of the icons."] = "Größe der Symbole."
L["Specific"] = "Spezifisch"
L["Specific Spells"] = "Spezielle Zauber"
L["Spell name"] = "Zaubername"
L["Spells"] = "Zauber"
L["Spells not in the Specific Spells list will use these options."] = "Zauber, die sich nicht in der Liste für Spezielle Zauber befinden, werden diese Optionen verwenden."
L["Stack Size"] = "Stapelgröße"
L["Stack Text Size"] = "Stapel-Textgröße"
L["Test Mode"] = "Testmodus"
L["Text size"] = "Textgröße"
L["This overlay tends to disappear when the frame's moving."] = "Diese Einblendung verschwindet manchmal, wenn die Einheit sich bewegt."
L["Top"] = "Oben"
L["Top Left"] = "Oben links"
L["Top Right"] = "Oben rechts"
L["Type"] = "Typ"
L["Unknown spell info"] = "Unbekannte Zauberinfo"
L["Up"] = "Nach oben"
L["Up to down offset."] = "Versetzung oben nach unten"
L["Watch Combatlog"] = "Kampflog beobachten"
L[ [=[Watch combatlog for people gaining/losing spells.
Disable this if you're having performance issues.]=] ] = [=[Kampflog darauf untersuchen, ob jemand Zauber bekommt/verliert.
Deaktivieren, um Performance zu verbessern.]=]
L["Which way do the bars grow, up or down."] = "In welche Richtung die Leisten anwachsen sollen, nach oben oder unten."
L["Who"] = "Wer"
L["about"] = "Über"
L["author"] = "Autor"
L["bitcoinAddress"] = "Bitcoin Adresse"
L["clickCopy"] = "Klicken und STRG+C halten, zum Kopieren"
L["donate"] = "Spenden"
L["email"] = "E-Mail"
L["enableDesc"] = "AddOn aktivieren/deaktivieren."
L["license"] = "Lizenz"
L["notes"] = "Notiz"
L["openOptionsFrameDesc"] = "Klicken, um die Optionen zu öffnen."
L["openOptionsFrameName"] = "Optionen öffnen"
L["sizes: 9, 10, 12, 13, 14, 16, 20"] = "Größen: 9, 10, 12, 13, 14, 16, 20"
L["spells to show by default"] = "Zauber die standardmäßig angezeigt werden"
L["title"] = "Titel"
L["version"] = "Version"
L["website"] = "Webseite"