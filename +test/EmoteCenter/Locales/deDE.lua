--save this file in UTF-8 for special chars

local L = LibStub("AceLocale-3.0"):NewLocale( "EmoteCenter", "deDE" )

if not L then return end


-- <- Translate these strings ->
	-- Random addon strings
L["Last Emote Used"] = "Zuletzt benutztes Emote"
L["Reset the options to default."] = true
L["Toggle the display of slash commands."] = "Umschalten der Anzeige von Slash Befehlen."
L["Show slash commands."] = true
L["Toggle the display of A&V flags."] = true
L["Show A&V flags."] = true
L["Currently:"] = "zur Zeit:"
L["Toggle the display of the minimap button."] = "Umschalten der Anzeige des Minimap Button"
L["Show minimap button."] = true
L["Shown"] = true
L["Hidden"] = true

-- Favorites
L["Favorites"] = true
L["Shift-Click on an emote to add to or remove from favorites."] = true
L[" removed from favorites."] = true
L[" added to favorites."] = true


-- Emote Data Types
L["Friendly"] = "Freundlich"
L["Hostile"] = "Feindlich"
L["Happy"] = "Glücklich"
L["Neutral"] = true
L["Unhappy"] = "Unglücklich"
L["Custom"] = "Eigene"
L["Taunts"] = "Sticheleien"
L["Affection"] = "Zuneigung"
L["Greetings"] = "Grüsse"
L["Combat"] = "Kampf"
L["Self-Deprecating"] = "Selbsterniedrigung"
L["Reactions"] = "Reaktionen"
L["Other"] = "Sonstige"
L["Actions"] = "Aktionen"
L["Vocals"] = "Stimmen"
L["New"] = "Neu"

-- Genders
L["He"] = "Er"
L["His"] = "Sein"
L["he"] = "er"
L["his"] = "sein"
L["She"] = "Sie"
L["Her"] = "Ihr"
L["she"] = "sie"
L["her"] = "ihr"

-- Reactions
L["A"] = true -- "A"ction shortened
L["V"] = true -- "V"ocal shortened
L["AV"] = true -- "A"ction/"V"ocal shortened

-- Actual addon texts

-- First (emote name only) is text produced
-- when there is no target.  Second (_target)
-- is what's produced when there is a target

-- The following tags:
-- <Target>, <He>, <he>, <She>, <she>
-- <His>, <his>, <Her>, <her>
-- MUST, MUST, MUST remain as is to work
-- They are localized above

-- Custom emotes
L["BIO"]="braucht eine Auszeit."	   ;   	L["BIO_TARGET"]="erklärt <Target> das <he> eine Auszeit braucht."
L["BLADEINTRO"]="will allen <his> Schwert vorstellen."	   ;   	L["BLADEINTRO_TARGET"]="will <Target> <his> Schwert vorstellen."
L["ESCAPE"]="hüstelt nervös und sucht einen Fluchtweg"	   ;   	L["ESCAPE_TARGET"]="hüstelt nervös <Target> an und sucht einen Fluchtweg."

-- <- the translations under here are generated by the game ->

L["ABSENT"]="Ihr blickt abwesend in die Ferne."	   ;   	L["ABSENT_TARGET"]="Ihr blickt <Target> abwesend an."
L["AGREE"]="Ihr stimmt zu."	   ;   	L["AGREE_TARGET"]="Ihr stimmt <Target> zu."
L["AMAZE"]="Ihr wundert Euch!"	   ;   	L["AMAZE_TARGET"]="Ihr wundert Euch über <Target>!"
L["ANGRY"]="Ihr erhebt erbost Eure Faust."	   ;   	L["ANGRY_TARGET"]="Ihr erhebt erbost Eure Faust gegen <Target>."
L["APOLOGIZE"]="Ihr entschuldigt Euch bei allen. Tut mir leid!"	   ;   	L["APOLOGIZE_TARGET"]="Ihr entschuldigt Euch bei <Target>. Tut mir leid!"
L["APPLAUD"]="Ihr applaudiert. Bravo!"	   ;   	L["APPLAUD_TARGET"]="Ihr applaudiert <Target>. Bravo!"
L["ATTACKMYTARGET"]="Ihr sagt allen, dass sie etwas angreifen sollen."	   ;   	L["ATTACKMYTARGET_TARGET"]="Ihr sagt allen, dass sie <Target> angreifen sollen."
L["AWE"]="Ihr seht Euch von Ehrfurcht erfüllt um."	   ;   	L["AWE_TARGET"]="Ihr starrt <Target> ehrfürchtig an."
L["BACKPACK"]="Ihr wühlt Euch durch Eure Taschen."	   ;   	L["BACKPACK_TARGET"]="Ihr wühlt Euch durch Eure Taschen."
L["BADFEELING"]="Ihr ahnt Schlimmes..."	   ;   	L["BADFEELING_TARGET"]="Ihr habt ein schlechtes Gefühl bei <Target>."
L["BARK"]="Ihr bellt! Wuff, wuff!"	   ;   	L["BARK_TARGET"]="Ihr bellt <Target> an."
L["BASHFUL"]="Ihr seid schüchtern."	   ;   	L["BASHFUL_TARGET"]="Ihr seid so schüchtern... zu schüchtern, um die Aufmerksamkeit von <Target> zu erregen."
L["BECKON"]="Ihr winkt alle zu Euch herüber."	   ;   	L["BECKON_TARGET"]="Ihr winkt <Target> herüber."
L["BEG"]="Ihr fleht alle um Euch herum an. Wie erbärmlich!"	   ;   	L["BEG_TARGET"]="Ihr fleht <Target> an. Wie erbärmlich!"
L["BITE"]="Ihr seht Euch um, ob es jemanden zum Beißen gibt."	   ;   	L["BITE_TARGET"]="Ihr beißt <Target>. Autsch!"
L["BLAME"]="Ihr gebt Euch selbst die Schuld."	   ;   	L["BLAME_TARGET"]="Ihr gebt <Target> an allem die Schuld."
L["BLANK"]="Ihr starrt ausdruckslos ins Leere."	   ;   	L["BLANK_TARGET"]="Ihr starrt <Target> ausdruckslos an."
L["BLEED"]="Blut quillt aus Euren Wunden."	   ;   	L["BLEED_TARGET"]="Blut quillt aus Euren Wunden."
L["BLINK"]="Ihr zwinkert mit den Augen."	   ;   	L["BLINK_TARGET"]="Ihr zwinkert <Target> zu."
L["BLUSH"]="Ihr errötet."	   ;   	L["BLUSH_TARGET"]="Ihr seht <Target> an und errötet."
L["BOGGLE"]="Ihr schaut angesichts der Situation ungläubig drein."	   ;   	L["BOGGLE_TARGET"]="Ihr seht <Target> ungläubig an."
L["BONK"]="Ihr haut Euch selbst kräftig auf den Schädel. Ätsch!"	   ;   	L["BONK_TARGET"]="Ihr haut <Target> kräftig auf den Schädel. Ätsch!"
L["BORED"]="Ihr sterbt fast vor Langeweile. Das Leben ist ja sooo hart!"	   ;   	L["BORED_TARGET"]="Ihr seid schrecklich gelangweilt von <Target>."
L["BOUNCE"]="Ihr hüpft auf und ab."	   ;   	L["BOUNCE_TARGET"]="Ihr hüpft vor <Target> auf und ab."
L["BOW"]="Ihr verbeugt Euch huldvoll."	   ;   	L["BOW_TARGET"]="Ihr verbeugt Euch vor <Target>."
L["BRANDISH"]="Ihr schwenkt bedrohlich Eure Waffe."	   ;   	L["BRANDISH_TARGET"]="Ihr richtet bedrohlich Eure Waffe auf <Target>."
L["BRB"]="Ihr teilt allen mit, dass Ihr gleich zurück seid."	   ;   	L["BRB_TARGET"]="Ihr teilt <Target> mit, dass Ihr gleich zurück seid."
L["BREATH"]="Ihr atmet tief durch."	   ;   	L["BREATH_TARGET"]="Ihr ratet <Target> tief durchzuatmen."
L["BURP"]="Euch entfährt ein lauter Rülpser."	   ;   	L["BURP_TARGET"]="Ihr rülpst <Target> geradewegs ins Gesicht."
L["BYE"]="Ihr winkt allen zum Abschied. Lebt wohl!"	   ;   	L["BYE_TARGET"]="Ihr winkt <Target> zum Abschied. Lebt wohl!"
L["CACKLE"]="Ihr kichert angesichts der Situation wie irre."	   ;   	L["CACKLE_TARGET"]="Ihr kichert <Target> angesichts der Situation wie irre an."
L["CALM"]="Ihr bleibt ruhig."	   ;   	L["CALM_TARGET"]="Ihr versucht, <Target> zu beruhigen."
L["CHALLENGE"]="Ihr fordert alle heraus. Na los, zeigt's mir!"	   ;   	L["CHALLENGE_TARGET"]="Ihr fordert <Target> zu einem Duell heraus."
L["CHARGE"]="Ihr greift an."	   ;   	L["CHARGE_TARGET"]="Ihr greift an."
L["CHARM"]="Ihr lasst Euren Charme spielen."	   ;   	L["CHARM_TARGET"]="Ihr findet <Target> charmant."
L["CHEER"]="Ihr jubelt!"	   ;   	L["CHEER_TARGET"]="Ihr bejubelt <Target>."
L["CHICKEN"]="Ihr flattert mit den Armen und stolziert herum. Koooooomm, putt, putt, putt, putt!"	   ;   	L["CHICKEN_TARGET"]="Ihr flattert mit den Armen und stolziert um <Target> herum. Koooooomm, putt, putt, putt, putt!"
L["CHUCKLE"]="Ihr brecht in herzhaftes freundliches Gekicher aus."	   ;   	L["CHUCKLE_TARGET"]="Ihr kichert <Target> freundlich an."
L["CHUG"]="Ihr nehmt einen gewaltigen Schluck von Eurem Getränk."	   ;   	L["CHUG_TARGET"]="Ihr feuert <Target> an, einen zu exen. SAUF! SAUF! SAUF!"
L["CLAP"]="Ihr klatscht aufgeregt in die Hände."	   ;   	L["CLAP_TARGET"]="Ihr klatscht aufgeregt für <Target> in die Hände."
L["COLD"]="Ihr teilt allen mit, dass Euch kalt ist."	   ;   	L["COLD_TARGET"]="Ihr teilt <Target> mit, dass Euch kalt ist."
L["COMFORT"]="Ihr müsst getröstet werden."	   ;   	L["COMFORT_TARGET"]="Ihr tröstet <Target>."
L["COMMEND"]="Ihr lobt alle für ihre gute Arbeit."	   ;   	L["COMMEND_TARGET"]="Ihr lobt <Target> für die gute Arbeit."
L["CONFUSED"]="Ihr seid total verwirrt."	   ;   	L["CONFUSED_TARGET"]="Ihr seht <Target> verwirrt an."
L["CONGRATULATE"]="Ihr gratuliert allen um Euch herum."	   ;   	L["CONGRATULATE_TARGET"]="Ihr gratuliert <Target>."
L["COUGH"]="Ihr brecht in lautes Husten aus."	   ;   	L["COUGH_TARGET"]="Ihr hustet <Target> an."
L["COVEREARS"]="Ihr haltet Euch die Ohren zu."	   ;   	L["COVEREARS_TARGET"]="Ihr haltet <Target> die Ohren zu."
L["COWER"]="Ihr krümmt Euch verängstigt zusammen."	   ;   	L["COWER_TARGET"]="Ihr krümmt Euch beim Anblick von <Target> verängstigt zusammen."
L["CRACK"]="Ihr lasst Eure Knöchel knacken."	   ;   	L["CRACK_TARGET"]="Ihr lasst Eure Knöchel knacken und starrt dabei <Target> an."
L["CRINGE"]="Ihr erschauert vor lauter Furcht."	   ;   	L["CRINGE_TARGET"]="Ihr zuckt ängstlich vor <Target> zusammen."
L["CROSSARMS"]="Ihr verschränkt die Arme."	   ;   	L["CROSSARMS_TARGET"]="Ihr verschränkt die Arme. <Target>... Hmph!"
L["CRY"]="Ihr heult."	   ;   	L["CRY_TARGET"]="Ihr heult Euch an der Schulter von <Target> aus."
L["CUDDLE"]="Ihr müsst umarmt werden."	   ;   	L["CUDDLE_TARGET"]="Ihr kuschelt Euch an <Target>."
L["CURIOUS"]="Ihr bringt Eure Neugier allen gegenüber zum Ausdruck."	   ;   	L["CURIOUS_TARGET"]="Ihr wüsstet zu gern, was <Target> vorhat."
L["CURTSEY"]="Ihr macht einen Knicks."	   ;   	L["CURTSEY_TARGET"]="Ihr macht einen Knicks vor <Target>."
L["DANCE"]="Ihr fangt spontan zu tanzen an."	   ;   	L["DANCE_TARGET"]="Ihr tanzt mit <Target>."
L["DING"]="Ihr habt eine neue Stufe erreicht. DING!"	   ;   	L["DING_TARGET"]="Ihr gratuliert <Target> zur neuen Stufe. DING!"
L["DISAGREE"]="Ihr seid anderer Meinung."	   ;   	L["DISAGREE_TARGET"]="Ihr seid anderer Meinung als <Target>."
L["DOUBT"]="Ihr zweifelt daran, dass die Situation gut für Euch ausgehen wird."	   ;   	L["DOUBT_TARGET"]="Ihr zweifelt an <Target>."
L["DRINK"]="Ihr erhebt das Glas zum Gruß, bevor Ihr es leert. Prost!"	   ;   	L["DRINK_TARGET"]="Ihr erhebt Euer Glas auf <Target>. Prost!"
L["DROOL"]="Ein Sabberfaden läuft Euch aus dem Mund."	   ;   	L["DROOL_TARGET"]="Ihr seht <Target> an und fangt an zu sabbern."
L["DUCK"]="Ihr duckt Euch zum Schutz."	   ;   	L["DUCK_TARGET"]="Ihr duckt Euch hinter <Target>."
L["EAT"]="Ihr fangt an zu essen."	   ;   	L["EAT_TARGET"]="Ihr fangt vor <Target> zu essen an."
L["EMBARRASS"]="Ihr werdet rot vor Scham."	   ;   	L["EMBARRASS_TARGET"]="Ihr schämt Euch für <Target>."
L["ENCOURAGE"]="Ihr sprecht allen Mut zu."	   ;   	L["ENCOURAGE_TARGET"]="Ihr sprecht <Target> Mut zu."
L["ENEMY"]="Ihr warnt alle, dass Feinde in der Nähe sind."	   ;   	L["ENEMY_TARGET"]="Ihr warnt <Target>, dass Feinde in der Nähe sind."
L["EYE"]="Ihr schielt."	   ;   	L["EYE_TARGET"]="Ihr mustert <Target> von oben bis unten."
L["EYEBROW"]="Ihr hebt fragend eine Augenbraue."	   ;   	L["EYEBROW_TARGET"]="Ihr betrachtet <Target> mit hochgezogener Augenbraue."
L["FAINT"]="Ihr fallt in Ohnmacht."	   ;   	L["FAINT_TARGET"]="Ihr fallt beim Anblick von <Target> in Ohnmacht."
L["FART"]="Ihr lasst einen lauten Furz entweichen. Igitt, was stinkt hier nur so?"	   ;   	L["FART_TARGET"]="Ihr stellt Euch neben <Target> und lasst einen lauten Furz entweichen."
L["FIDGET"]="Ihr zappelt herum."	   ;   	L["FIDGET_TARGET"]="Ihr zappelt beim Warten auf <Target> nervös herum."
L["FLEE"]="Ihr ruft, dass alle fliehen sollen!"	   ;   	L["FLEE_TARGET"]="Ihr ruft <Target> zu, schnell zu fliehen!"
L["FLEX"]="Ihr lasst Eure Muskeln spielen. Oh, echt stark!"	   ;   	L["FLEX_TARGET"]="Ihr lasst <Target> gegenüber Eure Muskeln spielen. Oh, echt stark!"
L["FLIRT"]="Ihr flirtet."	   ;   	L["FLIRT_TARGET"]="Ihr flirtet mit <Target>."
L["FLOP"]="Ihr wälzt Euch hilflos herum."	   ;   	L["FLOP_TARGET"]="Ihr wälzt Euch hilflos um <Target> herum."
L["FOLLOW"]="Ihr gebt allen ein Zeichen zu folgen."	   ;   	L["FOLLOW_TARGET"]="Ihr gebt <Target> ein Zeichen zu folgen."
L["FROWN"]="Ihr runzelt die Stirn."	   ;   	L["FROWN_TARGET"]="Ihr seid enttäuscht und zeigt es <Target> durch ein Stirnrunzeln."
L["GASP"]="Ihr schnappt nach Luft."	   ;   	L["GASP_TARGET"]="Ihr keucht <Target> an."
L["GAZE"]="Ihr blickt in die Ferne."	   ;   	L["GAZE_TARGET"]="Ihr seht <Target> sehnsüchtig an."
L["GIGGLE"]="Ihr kichert."	   ;   	L["GIGGLE_TARGET"]="Ihr kichert <Target> an."
L["GLARE"]="Ihr schaut wütend drein."	   ;   	L["GLARE_TARGET"]="Ihr starrt <Target> wütend an."
L["GLOAT"]="Ihr erfreut Euch hämisch am Unglück aller."	   ;   	L["GLOAT_TARGET"]="Ihr freut Euch hämisch am Unglück von <Target>."
L["GLOWER"]="Ihr verbreitet eine düstere Stimmung."	   ;   	L["GLOWER_TARGET"]="Ihr seht <Target> übellaunig an."
L["GO"]="Ihr bittet alle, zu gehen."	   ;   	L["GO_TARGET"]="Ihr bittet <Target>, zu gehen."
L["GOING"]="Ihr müsst gehen."	   ;   	L["GOING_TARGET"]="Ihr teilt <Target> mit, dass Ihr gehen müsst."
L["GOLFCLAP"]="Ihr klatscht halbherzig, offensichtlich unbeeindruckt."	   ;   	L["GOLFCLAP_TARGET"]="Ihr klatscht für <Target>, offensichtlich unbeeindruckt."
L["GREET"]="Ihr begrüßt alle herzlich."	   ;   	L["GREET_TARGET"]="Ihr begrüßt <Target> herzlich."
L["GRIN"]="Ihr grinst böse."	   ;   	L["GRIN_TARGET"]="Ihr grinst <Target> böse an."
L["GROAN"]="Ihr fangt an zu stöhnen."	   ;   	L["GROAN_TARGET"]="Ihr seht <Target> an und stöhnt."
L["GROVEL"]="Ihr kriecht vor lauter Unterwürfigkeit auf dem Boden."	   ;   	L["GROVEL_TARGET"]="Ihr kriecht vor <Target> wie ein unterwürfiger Diener."
L["GROWL"]="Ihr knurrt bedrohlich."	   ;   	L["GROWL_TARGET"]="Ihr knurrt <Target> bedrohlich an."
L["GUFFAW"]="Ihr brecht in schallendes Gelächter aus."	   ;   	L["GUFFAW_TARGET"]="Ihr werft nur einen Blick auf <Target> und brecht in schallendes Gelächter aus."
L["HAIL"]="Ihr grüßt alle um Euch herum."	   ;   	L["HAIL_TARGET"]="Ihr grüßt <Target>."
L["HAPPY"]="Ihr seid von Glück erfüllt!"	   ;   	L["HAPPY_TARGET"]="Ihr seid sehr glücklich mit <Target>!"
L["HEADACHE"]="Ihr bekommt Kopfschmerzen."	   ;   	L["HEADACHE_TARGET"]="Ihr bekommt Kopfschmerzen von dem Theater, das <Target> veranstaltet."
L["HEALME"]="Ihr ruft nach Heilung!"	   ;   	L["HEALME_TARGET"]="Ihr ruft nach Heilung!"
L["HELLO"]="Ihr begrüßt alle mit einem herzlichen Hallo!"	   ;   	L["HELLO_TARGET"]="Ihr begrüßt <Target> mit einem herzlichen Hallo!"
L["HELPME"]="Ihr ruft um Hilfe!"	   ;   	L["HELPME_TARGET"]="Ihr ruft um Hilfe!"
L["HICCUP"]="Ihr habt einen mächtigen Schluckauf."	   ;   	L["HICCUP_TARGET"]="Ihr habt einen mächtigen Schluckauf."
L["HISS"]="Ihr faucht alle an."	   ;   	L["HISS_TARGET"]="Ihr faucht <Target> an."
L["HOLDHAND"]="Ihr wünscht Euch, jemand würde Eure Hand halten."	   ;   	L["HOLDHAND_TARGET"]="Ihr haltet die Hand von <Target>."
L["HUG"]="Ihr müsst in den Arm genommen werden!"	   ;   	L["HUG_TARGET"]="Ihr umarmt <Target>."
L["HUNGRY"]="Ihr habt Hunger!"	   ;   	L["HUNGRY_TARGET"]="Ihr habt Hunger. Vielleicht hat <Target> ja etwas zu essen..."
L["HURRY"]="Ihr versucht, Euch zu beeilen."	   ;   	L["HURRY_TARGET"]="Ihr drängt <Target> zur Eile."
L["IDEA"]="Ihr habt eine Idee!"	   ;   	L["IDEA_TARGET"]="Ihr habt eine Idee!"
L["INCOMING"]="Ihr warnt alle vor sich nähernden Feinden!"	   ;   	L["INCOMING_TARGET"]="Ihr zeigt auf <Target> - Feind nähert sich!"
L["INSULT"]="Ihr findet, dass alle um Euch herum Ausgeburten von mutterlosen Ogern sind."	   ;   	L["INSULT_TARGET"]="Ihr findet, <Target> sei die Ausgeburt eines mutterlosen Ogers."
L["INTRODUCE"]="Ihr stellt Euch allen vor."	   ;   	L["INTRODUCE_TARGET"]="Ihr stellt Euch <Target> vor."
L["JEALOUS"]="Ihr seid eifersüchtig auf alle."	   ;   	L["JEALOUS_TARGET"]="Ihr seid eifersüchtig auf <Target>."
L["JK"]="Ihr habt nur Spaß gemacht!"	   ;   	L["JK_TARGET"]="Ihr zeigt <Target>, dass Ihr nur Spaß gemacht habt!"
L["JOKE"]="Ihr erzählt einen Witz."	   ;   	L["JOKE_TARGET"]="Ihr erzählt <Target> einen Witz."
L["KISS"]="Ihr haucht einen Kuss in die Luft."	   ;   	L["KISS_TARGET"]="Ihr haucht <Target> einen Kuss zu."
L["KNEEL"]="Ihr kniet nieder."	   ;   	L["KNEEL_TARGET"]="Ihr kniet vor <Target>."
L["LAUGH"]="Ihr lacht."	   ;   	L["LAUGH_TARGET"]="Ihr lacht über <Target>."
L["LAYDOWN"]="Ihr legt Euch nieder."	   ;   	L["LAYDOWN_TARGET"]="Ihr legt Euch vor <Target> nieder."
L["LICK"]="Ihr leckt Eure Lippen."	   ;   	L["LICK_TARGET"]="Ihr leckt <Target>."
L["LISTEN"]="Ihr hört zu!"	   ;   	L["LISTEN_TARGET"]="Ihr hört <Target> aufmerksam zu."
L["LOOK"]="Ihr seht Euch um."	   ;   	L["LOOK_TARGET"]="Ihr seht <Target> an."
L["LOST"]="Ihr habt Euch total verirrt."	   ;   	L["LOST_TARGET"]="Ihr lasst <Target> wissen, dass Ihr Euch total verirrt habt."
L["LOVE"]="Ihr spürt die Liebe."	   ;   	L["LOVE_TARGET"]="Ihr liebt <Target>."
L["LUCK"]="Ihr wünscht allen viel Erfolg."	   ;   	L["LUCK_TARGET"]="Ihr wünscht <Target> alles Gute."
L["MAP"]="Ihr faltet die Karte auf."	   ;   	L["MAP_TARGET"]="Ihr faltet die Karte auf."
L["MASSAGE"]="Ihr braucht eine Massage!"	   ;   	L["MASSAGE_TARGET"]="Ihr massiert die Schultern von <Target>."
L["MERCY"]="Ihr fleht um Gnade."	   ;   	L["MERCY_TARGET"]="Ihr fleht <Target> um Gnade an."
L["MOAN"]="Ihr stöhnt vielsagend."	   ;   	L["MOAN_TARGET"]="Ihr stöhnt <Target> vielsagend an."
L["MOCK"]="Ihr macht Euch über das Leben und alles, wofür es steht, lustig."	   ;   	L["MOCK_TARGET"]="Ihr macht Euch über die Dummheit von <Target> lustig."
L["MOO"]="Muuuuh!"	   ;   	L["MOO_TARGET"]="<Target> wird von Euch angemuht. Muuuuh!"
L["MOON"]="Ihr lasst die Hose runter und zeigt allen das blanke Hinterteil."	   ;   	L["MOON_TARGET"]="Ihr lasst die Hose runter und zeigt <Target> das blanke Hinterteil."
L["MOURN"]="In stillem Nachdenken versunken betrauert Ihr die Toten."	   ;   	L["MOURN_TARGET"]="In stillem Nachdenken versunken betrauert Ihr den Tod von <Target>."
L["MUTTER"]="Ihr murmelt verärgert vor Euch hin. Hmmmph!"	   ;   	L["MUTTER_TARGET"]="Ihr murmelt über <Target> verärgert vor Euch hin. Hmmmph!"
L["NERVOUS"]="Ihr seht Euch nervös um."	   ;   	L["NERVOUS_TARGET"]="Ihr seht <Target> nervös an."
L["NO"]="Ihr sagt deutlich: NEIN."	   ;   	L["NO_TARGET"]="Ihr sagt NEIN zu <Target>. Auf keinen Fall."
L["NOD"]="Ihr nickt."	   ;   	L["NOD_TARGET"]="Ihr nickt <Target> zu."
L["NOSEPICK"]="Ihr vertreibt Euch die Zeit mit ausgiebigem Nasepopeln."	   ;   	L["NOSEPICK_TARGET"]="Ihr popelt in der Nase und zeigt <Target> Eure Ausbeute."
L["OBJECT"]="Ihr erhebt EINSPRUCH!"	   ;   	L["OBJECT_TARGET"]="Ihr widersprecht <Target>."
L["OFFER"]="Ihr möchtet ein Angebot machen."	   ;   	L["OFFER_TARGET"]="Ihr versucht, <Target> ein unwiderstehliches Angebot zu machen."
L["OOM"]="Ihr verkündet, dass Ihr wenig Mana habt!"	   ;   	L["OOM_TARGET"]="Ihr verkündet, dass Ihr wenig Mana habt!"
L["OPENFIRE"]="Ihr gebt den Befehl, das Feuer zu eröffnen."	   ;   	L["OPENFIRE_TARGET"]="Ihr gebt den Befehl, das Feuer zu eröffnen."
L["PANIC"]="Ihr rennt voller Panik in der Gegend herum."	   ;   	L["PANIC_TARGET"]="Ihr werft einen Blick auf <Target> und brecht in Panik aus."
L["PAT"]="Ihr braucht eine Aufmunterung."	   ;   	L["PAT_TARGET"]="Ihr gebt <Target> einen freundschaftlichen Klaps."
L["PEER"]="Ihr blickt forschend in der Gegend herum."	   ;   	L["PEER_TARGET"]="Ihr starrt <Target> forschend an."
L["PET"]="Ihr braucht Streicheleinheiten."	   ;   	L["PET_TARGET"]="Ihr streichelt <Target>."
L["PINCH"]="Ihr kneift Euch."	   ;   	L["PINCH_TARGET"]="Ihr kneift <Target>."
L["PITY"]="Ihr habt Mitleid mit allen um Euch herum."	   ;   	L["PITY_TARGET"]="Ihr blickt mitleidig auf <Target> herab."
L["PLEAD"]="Ihr fallt auf die Knie und fleht verzweifelt."	   ;   	L["PLEAD_TARGET"]="Ihr fleht <Target> an."
L["POINT"]="Ihr zeigt dort drüben hin."	   ;   	L["POINT_TARGET"]="Ihr zeigt auf <Target>."
L["POKE"]="Ihr knufft Euch in den Bauch und kichert."	   ;   	L["POKE_TARGET"]="<Target> wird von Euch geknufft. He!"
L["PONDER"]="Ihr denkt über die Situation nach."	   ;   	L["PONDER_TARGET"]="Ihr macht Euch Gedanken über das Tun von <Target>."
L["POUNCE"]="Ihr springt aus dem Schatten."	   ;   	L["POUNCE_TARGET"]="Ihr springt auf <Target>."
L["POUT"]="Ihr schmollt alle an."	   ;   	L["POUT_TARGET"]="Ihr schmollt <Target> an."
L["PRAISE"]="Ihr preist das Licht."	   ;   	L["PRAISE_TARGET"]="Ihr überschüttet <Target> mit Lob."
L["PRAY"]="Ihr betet zu den Göttern."	   ;   	L["PRAY_TARGET"]="Ihr sprecht ein Gebet für <Target>."
L["PROMISE"]=""	   ;   	L["PROMISE_TARGET"]="Ihr macht <Target> ein Versprechen."
L["PROUD"]="Ihr seid stolz auf Euch."	   ;   	L["PROUD_TARGET"]="Ihr seid stolz auf <Target>."
L["PULSE"]="Ihr prüft Euren Puls."	   ;   	L["PULSE_TARGET"]="Ihr prüft den Puls von <Target>. Oh nein!"
L["PUNCH"]="Ihr schlagt Euch selbst."	   ;   	L["PUNCH_TARGET"]="Ihr boxt <Target> gegen die Schulter."
L["PURR"]="Ihr schnurrt wie ein Kätzchen."	   ;   	L["PURR_TARGET"]="Ihr schnurrt <Target> an."
L["PUZZLE"]="Ihr seid verwirrt. Was ist denn hier nur los?"	   ;   	L["PUZZLE_TARGET"]="<Target> verwirrt Euch."
L["RAISE"]="Ihr streckt Eure Hand in die Luft."	   ;   	L["RAISE_TARGET"]="Ihr seht <Target> an und hebt Eure Hand."
L["RASP"]="Ihr macht eine unflätige Geste."	   ;   	L["RASP_TARGET"]="Ihr zeigt <Target> eine unflätige Geste."
L["READY"]="Ihr teilt allen mit, dass Ihr bereit seid!"	   ;   	L["READY_TARGET"]="Ihr teilt <Target> mit, dass Ihr bereit seid!"
L["REGRET"]="Ihr seid von Reue erfüllt."	   ;   	L["REGRET_TARGET"]="Ihr glaubt, dass <Target> das noch bereuen wird."
L["REVENGE"]="Ihr schwört, dass Ihr Eure Rache haben werdet."	   ;   	L["REVENGE_TARGET"]="Ihr schwört <Target> Rache."
L["ROAR"]="Ihr brüllt wie ein wildes Tier. Wie furchterregend!"	   ;   	L["ROAR_TARGET"]="Ihr brüllt <Target> wie ein wildes Tier an. Wie furchterregend!"
L["ROFL"]="Ihr wälzt Euch vor Lachen auf dem Boden."	   ;   	L["ROFL_TARGET"]="Ihr lacht über <Target> und wälzt Euch dabei vor Vergnügen auf dem Boden."
L["ROLLEYES"]="Ihr rollt mit den Augen."	   ;   	L["ROLLEYES_TARGET"]="Ihr rollt wegen <Target> mit den Augen."
L["RUDE"]="Ihr macht eine unflätige Geste."	   ;   	L["RUDE_TARGET"]="Ihr zeigt <Target> eine unflätige Geste."
L["RUFFLE"]="Ihr rauft Euch die Haare."	   ;   	L["RUFFLE_TARGET"]="Ihr wuschelt <Target> durchs Haar."
L["SAD"]="Ihr lasst den Kopf hängen."	   ;   	L["SAD_TARGET"]="Ihr lasst den Kopf hängen."
L["SALUTE"]="Ihr steht stramm und grüßt."	   ;   	L["SALUTE_TARGET"]="Ihr grüßt <Target> voller Respekt."
L["SCARED"]="Ihr habt Angst!"	   ;   	L["SCARED_TARGET"]="Ihr habt Angst vor <Target>."
L["SCOFF"]="Ihr spöttelt."	   ;   	L["SCOFF_TARGET"]="Ihr verhöhnt <Target>."
L["SCOLD"]="Ihr ärgert Euch über Euch selbst."	   ;   	L["SCOLD_TARGET"]="Ihr fahrt <Target> an."
L["SCOWL"]="Ihr starrt finster vor Euch hin."	   ;   	L["SCOWL_TARGET"]="Ihr blickt <Target> finster an."
L["SCRATCH"]="Ihr kratzt Euch. Ah, das ist besser!"	   ;   	L["SCRATCH_TARGET"]="Ihr kratzt <Target>. Wie unerwartet!"
L["SEARCH"]="Ihr sucht nach etwas."	   ;   	L["SEARCH_TARGET"]="Ihr durchsucht <Target> nach etwas."
L["SEXY"]="Ihr seid einfach zu sexy."	   ;   	L["SEXY_TARGET"]="Ihr denkt, dass <Target> total sexy ist."
L["SHAKE"]="Ihr wackelt mit Eurem Hintern."	   ;   	L["SHAKE_TARGET"]="Ihr zeigt <Target> Euren Hintern."
L["SHAKEFIST"]="Ihr schüttelt Eure Faust."	   ;   	L["SHAKEFIST_TARGET"]="Ihr schüttelt die Faust gen <Target>."
L["SHIFTY"]="Ihr beäugt argwöhnisch die Gegend."	   ;   	L["SHIFTY_TARGET"]="Ihr späht gerissen zu <Target> hinüber."
L["SHIMMY"]="Ihr tänzelt vor den Massen herum."	   ;   	L["SHIMMY_TARGET"]="Ihr tänzelt vor <Target> herum."
L["SHIVER"]="Ihr fröstelt bis ins Mark. Eiskalt!"	   ;   	L["SHIVER_TARGET"]="Euch fröstelt neben <Target>. Eiskalt!"
L["SHOO"]="Ihr verscheucht die nervige Pest."	   ;   	L["SHOO_TARGET"]="Ihr scheucht <Target> weg. Hinfort, nervige Pest!"
L["SHOUT"]="Ihr schreit."	   ;   	L["SHOUT_TARGET"]="Ihr schreit <Target> an."
L["SHRUG"]="Ihr zuckt mit den Achseln. Wer weiß?"	   ;   	L["SHRUG_TARGET"]="Ihr zeigt <Target> ein Achselzucken. Wer weiß?"
L["SHUDDER"]="Ihr schaudert."	   ;   	L["SHUDDER_TARGET"]="Ihr erschaudert beim Anblick von <Target>."
L["SHY"]="Ihr lächelt schüchtern."	   ;   	L["SHY_TARGET"]="Ihr lächelt <Target> schüchtern an."
L["SIGH"]="Euch entfährt ein langer, tiefer Seufzer."	   ;   	L["SIGH_TARGET"]="Ihr seht <Target> mit einem Seufzen an."
L["SIGNAL"]="Ihr gebt das Signal."	   ;   	L["SIGNAL_TARGET"]="Ihr gebt <Target> das Zeichen."
L["SILENCE"]="Ihr mahnt alle zur Stille. Schhh!"	   ;   	L["SILENCE_TARGET"]="Ihr mahnt <Target> zur Stille. Schhh!"
L["SING"]="Ihr beginnt zu singen."	   ;   	L["SING_TARGET"]="Ihr beruhigt <Target> mit einem Lied."
L["SIT"]="<Lebhaftigkeit>"	   ;   	L["SIT_TARGET"]="<Lebhaftigkeit>"
L["SLAP"]="Ihr gebt Euch selbst eine Ohrfeige. Aua!"	   ;   	L["SLAP_TARGET"]="Ihr gebt <Target> eine Ohrfeige. Aua!"
L["SLEEP"]="Ihr schlaft ein. Zzzzzzz."	   ;   	L["SLEEP_TARGET"]="Ihr schlaft ein. Zzzzzzz."
L["SMACK"]="Ihr schlagt Euch die Stirn."	   ;   	L["SMACK_TARGET"]="Ihr verpasst <Target> einen Klaps auf den Hinterkopf."
L["SMILE"]="Ihr lächelt."	   ;   	L["SMILE_TARGET"]="Ihr lächelt <Target> an."
L["SMIRK"]="Ein verstohlenes Grinsen breitet sich auf Eurem Gesicht aus."	   ;   	L["SMIRK_TARGET"]="Ihr grinst <Target> verstohlen an."
L["SNAP"]="Ihr schnippt mit den Fingern."	   ;   	L["SNAP_TARGET"]="Ihr schnippt mit den Fingern nach <Target>."
L["SNARL"]="Ihr zeigt Eure Zähne und knurrt."	   ;   	L["SNARL_TARGET"]="Ihr zeigt Eure Zähne und knurrt <Target> an."
L["SNEAK"]="Ihr versucht, fort zu schleichen."	   ;   	L["SNEAK_TARGET"]="Ihr versucht, von <Target> fort zu schleichen."
L["SNEEZE"]="Ihr niest. Hatschi!"	   ;   	L["SNEEZE_TARGET"]="Ihr niest <Target> an. Hatschi!"
L["SNICKER"]="Ihr kichert leise belustigt in Euch hinein."	   ;   	L["SNICKER_TARGET"]="Ihr kichert <Target> belustigt an."
L["SNIFF"]="Ihr schnüffelt die Luft um Euch herum."	   ;   	L["SNIFF_TARGET"]="Ihr schnüffelt an <Target>."
L["SNORT"]="Ihr schnaubt."	   ;   	L["SNORT_TARGET"]="Ihr schnaubt verächtlich über <Target>."
L["SNUB"]="Ihr beleidigt alle niederen Peons um Euch herum."	   ;   	L["SNUB_TARGET"]="Ihr beleidigt <Target>."
L["SOOTHE"]="Ihr müsst besänftigt werden."	   ;   	L["SOOTHE_TARGET"]="Ihr besänftigt <Target>. Keine Panik... alles wird wieder gut..."
L["SPIT"]="Ihr spuckt auf den Boden."	   ;   	L["SPIT_TARGET"]="Ihr spuckt auf <Target>."
L["SQUEAL"]="Ihr quiekt wie ein Schwein."	   ;   	L["SQUEAL_TARGET"]="Ihr quiekt <Target> an."
L["STAND"]="<Lebhaftigkeit>"	   ;   	L["STAND_TARGET"]="<Lebhaftigkeit>"
L["STARE"]="Ihr starrt in die Ferne."	   ;   	L["STARE_TARGET"]="Ihr starrt <Target> an."
L["STINK"]="Ihr riecht die Luft um Euch herum. Igitt, hier stinkt jemand!"	   ;   	L["STINK_TARGET"]="Ihr riecht an <Target>. Igitt, hier stinkt jemand!"
L["SURPRISED"]="Ihr seid echt überrascht!"	   ;   	L["SURPRISED_TARGET"]="Ihr seid von den Taten von <Target> überrascht."
L["SURRENDER"]="Ihr ergebt Euch Euren Gegnern."	   ;   	L["SURRENDER_TARGET"]="Ihr ergebt Euch <Target>. Niederlagen tun weh..."
L["SUSPICIOUS"]="Ihr verengt misstrauisch die Augen."	   ;   	L["SUSPICIOUS_TARGET"]="Ihr seht <Target> misstrauisch an."
L["SWEAT"]="Ihr schwitzt."	   ;   	L["SWEAT_TARGET"]="Ihr kommt angesichts von <Target> ins Schwitzen."
L["TALK"]="Ihr sprecht mit Euch selbst, da wohl kein anderer interessiert ist."	   ;   	L["TALK_TARGET"]="Ihr wollt mit <Target> reden."
L["TALKEX"]="Ihr sprecht aufgeregt mit jedem."	   ;   	L["TALKEX_TARGET"]="Ihr sprecht aufgeregt mit <Target>."
L["TALKQ"]="Ihr wollt wissen, was der Sinn des Lebens ist."	   ;   	L["TALKQ_TARGET"]="Ihr befragt <Target>."
L["TAP"]="Ihr klopft mit dem Fuß. Jetzt aber Tempo!"	   ;   	L["TAP_TARGET"]="Ihr klopft mit dem Fuß auf den Boden, während Ihr auf <Target> wartet."
L["TAUNT"]="Ihr verspottet alle um Euch herum. Na los doch, Ihr Dummköpfe!"	   ;   	L["TAUNT_TARGET"]="Ihr macht <Target> gegenüber eine spöttische Geste. Na los doch!"
L["TEASE"]="Ihr zieht alle Leute so gern auf."	   ;   	L["TEASE_TARGET"]="Ihr zieht <Target> auf."
L["THANK"]="Ihr dankt allen um Euch herum."	   ;   	L["THANK_TARGET"]="Ihr dankt <Target>."
L["THINK"]="Ihr grübelt still vor Euch hin."	   ;   	L["THINK_TARGET"]="Ihr denkt über <Target> nach."
L["THIRSTY"]="Ihr seid ja so durstig. Hat jemand was zu trinken übrig?"	   ;   	L["THIRSTY_TARGET"]="Ihr teilt <Target> mit, dass Ihr durstig seid. Habt Ihr was zu trinken übrig?"
L["THREATEN"]="Ihr droht allen mit der ewigen Verdammnis."	   ;   	L["THREATEN_TARGET"]="Ihr droht <Target> mit der ewigen Verdammnis."
L["TICKLE"]="Ihr wollt gekitzelt werden. Ha ha ha!"	   ;   	L["TICKLE_TARGET"]="Ihr kitzelt <Target>. Ha ha ha!"
L["TIRED"]="Ihr teilt allen mit, dass Ihr müde seid."	   ;   	L["TIRED_TARGET"]="Ihr teilt <Target> mit, dass Ihr müde seid."
L["TRAIN"]="<Ihr macht Zuggeräusche 'Tschuu Tschuu Tschuu'!>"	   ;   	L["TRAIN_TARGET"]="<Ihr macht Zuggeräusche 'Tschuu Tschuu Tschuu'!>"
L["TRUCE"]="Ihr bietet einen Waffenstillstand an."	   ;   	L["TRUCE_TARGET"]="Ihr bietet <Target> einen Waffenstillstand an."
L["TWIDDLE"]="Ihr dreht Däumchen."	   ;   	L["TWIDDLE_TARGET"]="Ihr dreht Däumchen."
L["VETO"]="Ihr lehnt den gestellten Antrag ab."	   ;   	L["VETO_TARGET"]="Ihr lehnt den Antrag von <Target> ab."
L["VICTORY"]="Ihr sonnt Euch im Glanz des Sieges."	   ;   	L["VICTORY_TARGET"]="Ihr sonnt Euch mit <Target> im Glanz des Sieges."
L["VIOLIN"]="Ihr fangt an, der Welt kleinste Geige zu spielen."	   ;   	L["VIOLIN_TARGET"]="Ihr spielt der Welt kleinste Geige für <Target>."
L["WAIT"]="Ihr bittet alle zu warten."	   ;   	L["WAIT_TARGET"]="Ihr bittet <Target> zu warten."
L["WARN"]="Ihr warnt alle."	   ;   	L["WARN_TARGET"]="Ihr warnt <Target>."
L["WAVE"]="Ihr winkt."	   ;   	L["WAVE_TARGET"]="Ihr winkt <Target> zu."
L["WELCOME"]="Ihr begrüßt alle."	   ;   	L["WELCOME_TARGET"]="Ihr sagt: 'Willkommen, <Target>.'"
L["WHINE"]="Ihr heult herzzerreißend."	   ;   	L["WHINE_TARGET"]="Ihr heult <Target> herzzerreißend an."
L["WHISTLE"]="Ihr lasst ein lautes Pfeifen hören."	   ;   	L["WHISTLE_TARGET"]="Ihr pfeift <Target> zu."
L["WINK"]="Ihr zwinkert verschmitzt."	   ;   	L["WINK_TARGET"]="Ihr zwinkert <Target> verschmitzt zu."
L["WORK"]="Ihr beginnt mit der Arbeit."	   ;   	L["WORK_TARGET"]="Ihr arbeitet mit <Target>."
L["YAWN"]="Ihr gähnt müde."	   ;   	L["YAWN_TARGET"]="Ihr gähnt <Target> müde an."
L["YW"]="Ihr habt gern geholfen."	   ;   	L["YW_TARGET"]="Ihr habt <Target> gern geholfen."
