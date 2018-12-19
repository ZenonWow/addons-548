-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Mailing Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/tradeskillmaster_mailing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Mailing", "deDE")
if not L then return end

L[ [=[Automatically rechecks mail every 60 seconds when you have too much mail.

If you loot all mail with this enabled, it will wait and recheck then keep auto looting.]=] ] = [=[Briefkasten automatisch alle 60 Sekunden aktualisieren, wenn Ihr zuviel Post im Briefkasten habt.

Wenn Ihr alle Posts öffnet, während diese Option aktiviert ist, wird auf neue Post zum Öffnen gewartet.]=]
L["Auto Recheck Mail"] = "Briefkasten automatisch aktualisieren"
L["BE SURE TO SPELL THE NAME CORRECTLY!"] = "ACHTET DARAUF, DASS DER NAME RICHTIG GESCHRIEBEN IST!"
L["Buy: %s (%d) | %s | %s"] = "Kauf: %s (%d) | %s | %s" -- Needs review
L["Cannot finish auto looting, inventory is full or too many unique items."] = "Automatisches Plündern kann nicht beendet werden. Inventar ist voll oder zu viele \"einzigartige\" Gegenstände vorhanden."
L["Chat Message Options"] = "Optionen für Chat-Nachrichten"
L["Clear"] = "Leeren"
L["Clears the item box."] = "Leert das Eingabefeld."
L["Click this button to send all disenchantable greens in your bags to the specified character."] = "Klicke diesen Button um alle entzauberbaren grüne Gegenstände an den genannten Charakter zu schicken." -- Needs review
L["Click this button to send excess gold to the specified character."] = "Klicke diesen Button um überschüssiges Gold an den angegeben Charakter zu schicken." -- Needs review
L["Click this button to send off the item to the specified character."] = "Klicke diesen Button um den Gegenstand an den angegenen Charakter zu schicken." -- Needs review
L["COD Amount (per Item):"] = "Nachnahmegebühr (je Gegenstand):" -- Needs review
L["COD: %s | %s | %s | %s"] = "Nachnahme: %s | %s | %s | %s" -- Needs review
L["Collected COD of %s from %s for %s."] = "Nachnahmegebühr in Höhe von %s an %s für %s eingesammelt." -- Needs review
L["Collected expired auction of %s"] = "Abgelaufene Auktion von %s abgeholt." -- Needs review
L["Collected mail from %s with a subject of '%s'."] = "Post von %s mit Betreff '%s' abgeholt." -- Needs review
L["Collected purchase of %s (%d) for %s."] = "Einkauf von %s (%d) für %s abgeholt." -- Needs review
L["Collected sale of %s (%d) for %s."] = "Verkauf von %s (%d) für %s abgeholt." -- Needs review
L["Collected %s and %s from %s."] = "Hole %s und %s von %s ab." -- Needs review
L["Collected %s from %s."] = "%s von %s abgeholt." -- Needs review
L["Collect Gold"] = "Gold Einsammeln" -- Needs review
L["Could not loot item from mail because your bags are full."] = "Gegenstand konnte aus der Post nicht entnommen werden, weil Eure Taschen voll sind."
L["Could not send mail due to not having free bag space available to split a stack of items."] = "Kann keine Post verschicken, da kein freier Taschenplatz vorhanden ist um Gegenstandstapel aufzuteilen." -- Needs review
L["Display Total Money Received"] = "Zeige die Gesamtsumme des erhaltenen Goldes"
L["Drag (or place) the item that you want to send into this editbox."] = "Zieht (oder platziert) den Gegenstand, den Ihr verschicken wollt, in dieses Eingabefeld."
L["Enable Inbox Chat Messages"] = "Aktiviere Posteingangsmitteilungen"
L["Enable Sending Chat Messages"] = "Aktiviere Postausgangsmitteilungen"
L["Enter name of the character disenchantable greens should be sent to."] = "Tragt den Namen des Charakters ein, an den entzauberbare grüne Gegenstände geschickt werden sollen."
L["Enter the desired COD amount (per item) to send this item with. Setting this to '0c' will result in no COD being set."] = "Tragt die gewünschte Nachnahmegebühr (pro Gegenstand) ein, mit der Ihr den Gegenstand verschicken wollt. Bei einem Betrag von '0c' wird der Gegenstand ohne Nachnahmegebühr verschickt."
L["Enter the name of the player you want to send excess gold to."] = "Tragt den Charakternamen ein, an den überschüssiges Gold geschickt werden soll."
L["Enter the name of the player you want to send this item to."] = "Tragt den Charakternamen ein, an den der Gegenstand geschickt werden soll."
L["Error creating operation. Operation with name '%s' already exists."] = "Fehler beim Erstellen der Operation. Operation mit Namen '%s' existiert bereits." -- Needs review
L["Expired: %s | %s"] = "Abgelaufen: %s | %s" -- Needs review
L["General"] = "Allgemein" -- Needs review
L["General Settings"] = "Allgemeine Einstellungen" -- Needs review
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "Gebt der neuen Operation einen Namen. Ein beschreibender Name macht die Operation später leichter auffindbar."
L["If checked, a maxium quantity to send to the target can be set. Otherwise, Mailing will send as many as it can."] = "Wenn aktiviert, kann eine maximale Menge gesetzt werden, die an das Ziel gesendet werden soll. Ansonsten wird Mailing so viel wie möglich versenden."
L["If checked, information on mails collected by TSM_Mailing will be printed out to chat."] = "Wenn aktiviert, werden Informationen über Posts, die von TSM_Mailing eingesammelt werden, im Chat angezeigt."
L["If checked, information on mails sent by TSM_Mailing will be printed out to chat."] = "Wenn aktiviert, werden Informationen über Posts, die von TSM_Mailing gesendet werden, im Chat angezeigt."
L["If checked, the Mailing tab of the mailbox will be the default tab."] = "Wenn aktiviert, wird Mailing zum Standard-Tab im Briefkasten gemacht."
L["If checked, the 'Open All' button will leave any mail containing gold."] = "Wenn aktiviert, wird der Button 'Alle öffnen' keine Posts öffnen, die Gold enthalten."
L["If checked, the target's current inventory will be taken into account when determing how many to send. For example, if the max quantity is set to 10, and the target already has 3, Mailing will send at most 7 items."] = "Wenn aktiviert, wird das aktuelle Inventar des Ziels beim Bestimmen der zu sendenden Posts berücksichtigt. Zum Beispiel wird Mailing, wenn die Maximalmenge auf 10 gesetzt ist und das Ziel bereits 3 Einheiten hat, maximal 7 Einheiten versenden."
L["If checked, the target's guild bank will be included in their inventory for the 'Restock Target to Max Quantity' option."] = "Wenn aktiviert, wird die Gildenbank des Ziels berücksichtigt für die 'Fülle Ziel bis zur max. Menge auf' Option."
L["If checked, the total amount of gold received will be shown at the end of automatically collecting mail."] = "Wenn aktiviert, wird der gesamte erhaltene Goldbetrag angezeigt, nachdem alle Nachrichten automatisch eingesammelt wurden."
L["Inbox"] = "Eingang"
L["Include Guild Bank in Restock"] = "Gildenbank beim Auffüllen mit einbeziehen"
L["Item (Drag Into Box):"] = "Gegenstand (ins Feld ziehen):"
L["Keep Quantity"] = "Zu behaltende Menge" -- Needs review
L["Leave Gold with Open All"] = "Ignoriere Gold beim Öffnen aller Posts"
L["Limit (In Gold):"] = "Limit (in Gold):" -- Needs review
L["Mail Disenchantables:"] = "Entzauberbares Verschicken:" -- Needs review
L["Mailing all to %s."] = "Alles an %s geschickt." -- Needs review
L["Mailing operations contain settings for easy mailing of items to other characters."] = "Mailing-Operationen enthalten Einstellungen zum einfachen Versenden von Gegenständen an anderen Charakteren."
L["Mailing up to %d to %s."] = "Schicke maximal %d an %s." -- Needs review
L["Mailing will keep this number of items in the current player's bags and not mail them to the target."] = "Mailing wird diese Anzahl von Gegenständen in den Taschen des aktuellen Spielers behalten, ohne sie ans Ziel zu schicken."
L["Mail Selected Groups"] = "Ausgewählte Gruppen versenden" -- Needs review
L["Mail Send Delay"] = "Verzögerung beim Senden von Post"
L["Make Mailing Default Mail Tab"] = "Mache Mailing zum Standard-Briefkasten-Tab"
L["Maxium Quantity"] = "Maximale Anzahl:" -- Needs review
L["Max Quantity:"] = "Max. Anzahl:" -- Needs review
L["Multiple Items"] = "Mehrere Gegenstände" -- Needs review
L["New Operation"] = "Neue Operation" -- Needs review
L["Next inbox update in %d seconds."] = "Nächste Aktualisierung des Posteingangs in %d Sekunden." -- Needs review
L["No Item Specified"] = "Kein Gegenstand angegeben" -- Needs review
L["No Quantity Specified"] = "Keine Anzahl angegeben" -- Needs review
L["No Target Player"] = "Kein Zielcharakter" -- Needs review
L["No Target Specified"] = "Kein Ziel angegeben" -- Needs review
L["Not sending any gold as you have less than the specified limit."] = "Gold wird nicht gesendet, weil Ihr weniger als den angegebenen Betrag besitzt."
L["Not Target Specified"] = "Kein Ziel angegeben" -- Needs review
L["Open All"] = "Alle öffnen"
L["Operation Name"] = "Name der Operation" -- Needs review
L["Operations"] = "Operationen" -- Needs review
L["Operation Settings"] = "Operationseinstellungen" -- Needs review
L["Options"] = "Optionen"
L["Other"] = "Andere" -- Needs review
L["Quick Send"] = "Schnellsendung"
L["Relationships"] = "Beziehungen" -- Needs review
L["Reload UI"] = "UI neu laden" -- Needs review
L["Restart Delay (minutes)"] = "Neustart-Verzögerung (in Minuten)"
L["Restock Target to Max Quantity"] = "Fülle Ziel bis zur max. Menge auf"
L["Sale: %s (%d) | %s | %s"] = "Verkauf: %s (%d) | %s | %s" -- Needs review
L["Send Disenchantable Greens to %s"] = "Sende entzauberbare grüne Gegenstände an %s" -- Needs review
L["Send Excess Gold to Banker:"] = "Sende überschüssiges Gold an Banker:" -- Needs review
L["Send Excess Gold to %s"] = "Sende überschüssiges Gold an %s." -- Needs review
L["Sending..."] = "Sende..."
L["Send Items Individually"] = "Sende Gegenstände einzeln"
L["Sends each unique item in a seperate mail."] = "Sende jeden einzigartigen Gegenstand in einer separaten Post."
L["Send %sx%d to %s - No COD"] = "Sende %sx%d an %s - Keine Nachnahme" -- Needs review
L["Send %sx%d to %s - %s per Item COD"] = "Sende %sx%d an %s - %s Nachnahme je Gegenstand" -- Needs review
L["Sent all disenchantable greens to %s."] = "Verschicke alle entzauberbaren grünen Gegenstände an %s." -- Needs review
L["Sent %s to %s."] = "%s an %s verschickt." -- Needs review
L["Sent %s to %s with a COD of %s."] = "%s an %s mit Nachnahme von %s verschickt." -- Needs review
L["Set Max Quantity"] = "Setze maximale Menge"
L["Sets the maximum quantity of each unique item to send to the target at a time."] = "Setzt die maximale Menge jeden einzigartigen Gegenstandes, das an das Ziel gesendet werden soll."
L["Shift-Click to automatically re-send after the amount of time specified in the TSM_Mailing options."] = "Umschalt-Klick, um die Post automatisch erneut zu senden, wenn die angegebene Zeitmenge in den TSM_Mailing-Optionen abgelaufen ist." -- Needs review
L["Showing all %d mail."] = "Zeige alle %d Nachrichten." -- Needs review
L["Showing %d of %d mail."] = "Zeige %d von %d Nachrichten." -- Needs review
L["Skipping operation '%s' because there is no target."] = "Überspringe Operation '%s', weil es kein Ziel gibt."
L["%s to collect."] = "%s zum Einsammeln."
L["%s total gold collected!"] = "%s Gold insgesamt eingesammelt."
L["Target:"] = "Ziel:" -- Needs review
L["Target is Current Player"] = "Ziel ist aktueller Spieler"
L["Target Player"] = "Zielspieler"
L["Target Player:"] = "Zielspieler:"
L["The name of the player you want to mail items to."] = "Name des Spielers, an den Ihr Gegenstände schicken wollt."
L["This is maximum amount of gold you want to keep on the current player. Any amount over this limit will be send to the specified character."] = "Dies ist der maximale Goldbetrag den der aktuelle Charakter behalten soll. Alles Gold darüber wird an den angegebenen Charakter geschickt." -- Needs review
L["This is the maximum number of the specified item to send when you click the button below."] = "Dies ist die maximal zu sendende Anzahl des angegebenen Gegenstands, wenn Ihr den Button unten anklickt."
L["This slider controls how long the mail sending code waits between consecutive mails. If this is set too low, you will run into internal mailbox errors."] = "Dieser Regler kontrolliert, wie lange zwischen dem Versenden von aufeinanderfolgenden Posts gewartet werden soll. Wenn dieser Wert zu niedrig ist, können interne Briefkasten-Fehler auftreten."
L["This tab allows you to quickly send any quantity of an item to another character. You can also specify a COD to set on the mail (per item)."] = "Dieser Tab erlaubt es Euch, beliebige Mengen eines Gegenstandes an einen anderen Charakter zu senden. Ihr könnt auch eine Nachnahmegebühr (je Gegenstand) angeben."
L["TSM Groups"] = "TSM-Gruppen" -- Needs review
L["TSM_Mailing Excess Gold"] = "TSM_Mailing überschüssiges Gold" -- Needs review
L["When you shift-click a send mail button, after the initial send, it will check for new items to send at this interval."] = "Wenn Ihr einen Umschalt-Klick auf einen Senden-Button macht, wird nach dem ersten Senden nach neuen Gegenständen gesucht, die in diesem Intervall gesendet werden sollen." -- Needs review
