--save this file in UTF-8 for special chars

local L = LibStub("AceLocale-3.0"):NewLocale( "EmoteCenter", "esES" )

if not L then return end

	
	-- Spanish translation courtesy of Kálathos, Minahonda-EU

-- <- Translate these strings ->
-- Random addon strings
L["Last Emote Used"] = "Ùltima emote"
L["Reset the options to default."] = true
L["Toggle the display of slash commands."] = true
L["Show slash commands."] = true
L["Toggle the display of A&V flags."] = true
L["Show A&V flags."] = true
L["Currently:"] = true
L["Toggle the display of the minimap button."] = true
L["Show minimap button."] = true
L["Shown"] = true
L["Hidden"] = true

-- Favorites
L["Favorites"] = true
L["Shift-Click on an emote to add to or remove from favorites."] = true
L[" removed from favorites."] = true
L[" added to favorites."] = true


-- Emote Data Types
L["Friendly"] = "Amistoso"
L["Hostile"] = "Hostil"
L["Happy"] = "Feliz"
L["Neutral"] = "Neutral"
L["Unhappy"] = "Infeliz"
L["Custom"] = "Personalizada"
L["Taunts"] = "Intimidar"
L["Affection"] = "Afecto"
L["Greetings"] = "Saludos"
L["Combat"] = "Combate"
L["Self-Deprecating"] = "Lamentarse"
L["Reactions"] = "Reacciones"
L["Other"] = "Otros"
L["Actions"] = "Acción"
L["Vocals"] = "Vocal"
L["New"] = "Nuevo"

-- Genders
L["He"] = true
L["His"] = true
L["he"] = true
L["his"] = true
L["She"] = true
L["Her"] = true
L["she"] = true
L["her"] = true

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
L["BIO"]=""	   ;   	L["BIO_TARGET"]=""
L["BLADEINTRO"]=""	   ;   	L["BLADEINTRO_TARGET"]=""
L["ESCAPE"]=""	   ;   	L["ESCAPE_TARGET"]=""

-- <- the translations under here are generated by the game ->

L["ABSENT"]="Estás como ausente."	   ;   	L["ABSENT_TARGET"]="Miras a <Target> distraídamente."
L["AGREE"]="Estás de acuerdo."	   ;   	L["AGREE_TARGET"]="Estás de acuerdo con <Target>."
L["AMAZE"]="Muestras tu asombro."	   ;   	L["AMAZE_TARGET"]="Muestras tu asombro ante <Target>."
L["ANGRY"]="Levantas el puño con furia."	   ;   	L["ANGRY_TARGET"]="Levantas el puño con furia ante <Target>."
L["APOLOGIZE"]="Pides disculpas a todos. ¡Perdón!"	   ;   	L["APOLOGIZE_TARGET"]="Pides disculpas a <Target>. ¡Perdón!"
L["APPLAUD"]="Aplaudes. ¡Viva!"	   ;   	L["APPLAUD_TARGET"]="Aplaudes a <Target>. ¡Viva!"
L["ATTACKMYTARGET"]="Pides a todos que ataquen contra algo."	   ;   	L["ATTACKMYTARGET_TARGET"]="Pides a todos que ataquen a <Target>."
L["AWE"]="Miras a tu alrededor con sobrecogimiento."	   ;   	L["AWE_TARGET"]="Miras fijamente a <Target> con sobrecogimiento."
L["BACKPACK"]="Rebuscas en tu mochila."	   ;   	L["BACKPACK_TARGET"]="Rebuscas en tu mochila."
L["BADFEELING"]="Tienes un mal presentimiento sobre esto..."	   ;   	L["BADFEELING_TARGET"]="Tienes un mal presentimiento sobre <Target>."
L["BARK"]="Ladras. ¡Guau! ¡Guau!"	   ;   	L["BARK_TARGET"]="Ladras a <Target>."
L["BASHFUL"]="Sientes timidez."	   ;   	L["BASHFUL_TARGET"]="Sientes mucha timidez… Tanta que no llamas la atención de <Target>."
L["BECKON"]="Haces señas a todos a tu alrededor."	   ;   	L["BECKON_TARGET"]="Haces señas a <Target>."
L["BEG"]="Ruegas a todos los presentes. Qué penoso."	   ;   	L["BEG_TARGET"]="Ruegas a <Target>. Qué penoso."
L["BITE"]="Miras a tu alrededor en busca de alguien para pegarle un mordisco."	   ;   	L["BITE_TARGET"]="Muerdes a <Target>. ¡Ay!"
L["BLAME"]="Te culpas de lo ocurrido."	   ;   	L["BLAME_TARGET"]="Le echas la culpa de todo a <Target>."
L["BLANK"]="Miras a tu alrededor sin entender nada."	   ;   	L["BLANK_TARGET"]="Miras a <Target> sin entender nada."
L["BLEED"]="Tus heridas chorrean sangre."	   ;   	L["BLEED_TARGET"]="Tus heridas chorrean sangre."
L["BLINK"]="Parpadeas."	   ;   	L["BLINK_TARGET"]="Parpadeas ante <Target>."
L["BLUSH"]="Te sonrojas."	   ;   	L["BLUSH_TARGET"]="Te sonrojas ante <Target>."
L["BOGGLE"]="Alucinas con la situación."	   ;   	L["BOGGLE_TARGET"]="Alucinas con <Target>."
L["BONK"]="Te das un coscorrón. ¡Ay!"	   ;   	L["BONK_TARGET"]="Le das un coscorrón a <Target>. ¡Ay!"
L["BORED"]="Sientes un profundo aburrimiento. ¡Qué monotonía!"	   ;   	L["BORED_TARGET"]="Te aburres muchísimo con <Target>."
L["BOUNCE"]="Saltas como un canguro."	   ;   	L["BOUNCE_TARGET"]="Saltas como un canguro frente a <Target>."
L["BOW"]="Te inclinas con gracia."	   ;   	L["BOW_TARGET"]="Te inclinas ante <Target>."
L["BRANDISH"]="Blandes tu arma violentamente."	   ;   	L["BRANDISH_TARGET"]="Blandes tu arma violentamente ante <Target>."
L["BRB"]="Indicas a todos que vuelves enseguida."	   ;   	L["BRB_TARGET"]="Informas a <Target> de que vuelves enseguida."
L["BREATH"]="Respiras hondo."	   ;   	L["BREATH_TARGET"]="Le dices a <Target> que respire hondo."
L["BURP"]="Eructas a lo bestia."	   ;   	L["BURP_TARGET"]="Eructas groseramente en la cara de <Target>."
L["BYE"]="Te despides de todos con la mano. ¡Hasta luego!"	   ;   	L["BYE_TARGET"]="Te despides con la mano de <Target>. ¡Hasta luego!"
L["CACKLE"]="Te pones a hablar del asunto sin parar."	   ;   	L["CACKLE_TARGET"]="Te pones a hablar sin parar con <Target>."
L["CALM"]="Conservas la calma."	   ;   	L["CALM_TARGET"]="Intentas calmar a <Target>."
L["CHALLENGE"]="Retas a todos a tu alrededor. ¡Venga, valientes!"	   ;   	L["CHALLENGE_TARGET"]="Retas a <Target> a un duelo."
L["CHARGE"]="Comienzas a cargar."	   ;   	L["CHARGE_TARGET"]="Comienzas a cargar."
L["CHARM"]="Accionas tu lado encantador."	   ;   	L["CHARM_TARGET"]="Crees que <Target> tiene mucho encanto."
L["CHEER"]="¡Hurra!"	   ;   	L["CHEER_TARGET"]="Das ánimos a <Target>."
L["CHICKEN"]="Das vueltas batiendo los brazos como si fuesen alas. La gallina turu..."	   ;   	L["CHICKEN_TARGET"]="Das vueltas alrededor de <Target> batiendo los brazos como si fuesen alas. La gallina turu..."
L["CHUCKLE"]="Sueltas una sonora carcajada."	   ;   	L["CHUCKLE_TARGET"]="Te ríes de <Target>."
L["CHUG"]="Le metes un buen trago a tu bebida."	   ;   	L["CHUG_TARGET"]="Animas a <Target> a que beba. ¡BEBE, BEBE, BEBE!"
L["CLAP"]="Aplaudes con emoción."	   ;   	L["CLAP_TARGET"]="Aplaudes con emoción a <Target>."
L["COLD"]="Dices a todos que tienes frío."	   ;   	L["COLD_TARGET"]="Le dices a <Target> que tienes frío."
L["COMFORT"]="Necesitas consuelo."	   ;   	L["COMFORT_TARGET"]="Consuelas a <Target>."
L["COMMEND"]="Elogias el buen trabajo de todos."	   ;   	L["COMMEND_TARGET"]="Elogias el buen trabajo de <Target>."
L["CONFUSED"]="Tu confusión es total."	   ;   	L["CONFUSED_TARGET"]="Observas a <Target> con confusión."
L["CONGRATULATE"]="Felicitas a todos a tu alrededor."	   ;   	L["CONGRATULATE_TARGET"]="Felicitas a <Target>."
L["COUGH"]="Toses violentamente."	   ;   	L["COUGH_TARGET"]="Toses en la cara a <Target>."
L["COVEREARS"]="Te tapas los oídos."	   ;   	L["COVEREARS_TARGET"]="Le tapas los oídos a <Target>."
L["COWER"]="Te encoges del miedo."	   ;   	L["COWER_TARGET"]="Te encoges del miedo al ver a <Target>."
L["CRACK"]="Te crujes los nudillos."	   ;   	L["CRACK_TARGET"]="Te crujes los nudillos mientras miras a <Target>."
L["CRINGE"]="Te achantas del miedo."	   ;   	L["CRINGE_TARGET"]="Te achantas del miedo ante <Target>."
L["CROSSARMS"]="Te cruzas de brazos."	   ;   	L["CROSSARMS_TARGET"]="Te cruzas de brazos ante <Target>. ¡Hum!"
L["CRY"]="Lloras."	   ;   	L["CRY_TARGET"]="Lloras en el hombro de <Target>."
L["CUDDLE"]="Necesitas que te mimen."	   ;   	L["CUDDLE_TARGET"]="Te acurrucas contra <Target>."
L["CURIOUS"]="Manifiestas tu curiosidad a todos."	   ;   	L["CURIOUS_TARGET"]="Sientes curiosidad por lo que está haciendo <Target>."
L["CURTSEY"]="Haces una reverencia."	   ;   	L["CURTSEY_TARGET"]="Haces una reverencia a <Target>."
L["DANCE"]="Te pones a bailar."	   ;   	L["DANCE_TARGET"]="Bailas con <Target>."
L["DING"]="Has subido de nivel. ¡DING!"	   ;   	L["DING_TARGET"]="Felicitas a <Target> por subir de nivel. ¡DING!"
L["DISAGREE"]="No estás de acuerdo."	   ;   	L["DISAGREE_TARGET"]="No estás de acuerdo con <Target>."
L["DOUBT"]="No estás de acuerdo."	   ;   	L["DOUBT_TARGET"]="Dudas de <Target>."
L["DRINK"]="Brindas antes de beber. ¡Salud!"	   ;   	L["DRINK_TARGET"]="Brindas por <Target>. ¡Salud!"
L["DROOL"]="Una gota de baba cae de tus labios."	   ;   	L["DROOL_TARGET"]="Miras a <Target> y babeas."
L["DUCK"]="Te agachas para cubrirte."	   ;   	L["DUCK_TARGET"]="Te agachas detrás de <Target>."
L["EAT"]="Te pones a comer."	   ;   	L["EAT_TARGET"]="Te pones a comer frente a <Target>."
L["EMBARRASS"]="Te sonrojas de la vergüenza."	   ;   	L["EMBARRASS_TARGET"]="<Target> te deja en vergüenza."
L["ENCOURAGE"]="Animas a todos a tu alrededor."	   ;   	L["ENCOURAGE_TARGET"]="Animas a <Target>."
L["ENEMY"]="Adviertes a todos de que el enemigo está cerca."	   ;   	L["ENEMY_TARGET"]="Adviertes a <Target> de que el enemigo está cerca."
L["EYE"]="Pones los ojos bizcos."	   ;   	L["EYE_TARGET"]="Observas a <Target> de arriba a abajo."
L["EYEBROW"]="Levantas inquisitivamente la ceja."	   ;   	L["EYEBROW_TARGET"]="Levantas inquisitivamente la ceja a <Target>."
L["FAINT"]="Te desmayas."	   ;   	L["FAINT_TARGET"]="Te desmayas ante la presencia de <Target>."
L["FART"]="Sueltas un pedo enorme. Puaj... ¡Qué peste!"	   ;   	L["FART_TARGET"]="Te acercas a <Target> y sueltas un pedo enorme."
L["FIDGET"]="Te inquietas."	   ;   	L["FIDGET_TARGET"]="Te impacientas esperando a <Target>."
L["FLEE"]="Gritas a todos que huyan."	   ;   	L["FLEE_TARGET"]="¡Gritas a <Target> que huya!"
L["FLEX"]="Sacas músculos. ¡Qué cachas!"	   ;   	L["FLEX_TARGET"]="Sacas músculos para <Target>. ¡Qué cachas estás!"
L["FLIRT"]="Flirteas."	   ;   	L["FLIRT_TARGET"]="Flirteas con <Target>."
L["FLOP"]="Te revuelves con aire desvalido."	   ;   	L["FLOP_TARGET"]="Te revuelves con aire desvalido alrededor de <Target>."
L["FOLLOW"]="Indicas a todos que no se separen."	   ;   	L["FOLLOW_TARGET"]="Indicas a <Target> que no se separe."
L["FROWN"]="Frunces el ceño."	   ;   	L["FROWN_TARGET"]="Frunces el ceño ante <Target> con profunda decepción."
L["GASP"]="Te asombras."	   ;   	L["GASP_TARGET"]="Te asombras de <Target>."
L["GAZE"]="Tu mirada se pierde en el infinito."	   ;   	L["GAZE_TARGET"]="Observas a <Target> con nostalgia."
L["GIGGLE"]="Sueltas una risilla."	   ;   	L["GIGGLE_TARGET"]="Sueltas una risilla a <Target>."
L["GLARE"]="Miras con furia."	   ;   	L["GLARE_TARGET"]="Miras con furia a <Target>."
L["GLOAT"]="Te regodeas en la mala suerte de todos."	   ;   	L["GLOAT_TARGET"]="Te regodeas en la mala suerte de <Target>."
L["GLOWER"]="Le frunces el ceño a todos a tu alrededor."	   ;   	L["GLOWER_TARGET"]="Le frunces el ceño a <Target>."
L["GO"]="Le dices a todo el mundo que se vaya."	   ;   	L["GO_TARGET"]="Le dices a <Target> que se vaya."
L["GOING"]="Tienes que irte."	   ;   	L["GOING_TARGET"]="Le dices a <Target> que tienes que irte."
L["GOLFCLAP"]="Aplaudes irónicamente y sin entusiasmo."	   ;   	L["GOLFCLAP_TARGET"]="Aplaudes a <Target> irónicamente y sin entusiasmo."
L["GREET"]="Saludas calurosamente a todos."	   ;   	L["GREET_TARGET"]="Saludas calurosamente a <Target>."
L["GRIN"]="Sonríes con malicia."	   ;   	L["GRIN_TARGET"]="Sonríes con malicia a <Target>."
L["GROAN"]="Te pones a protestar."	   ;   	L["GROAN_TARGET"]="Observas a <Target> y protestas."
L["GROVEL"]="Te arrastras por el suelo cual gusano sumiso."	   ;   	L["GROVEL_TARGET"]="Te postras ante <Target> cual vasallo sumiso."
L["GROWL"]="Sueltas un bramido amenazador."	   ;   	L["GROWL_TARGET"]="Le sueltas un bramido amenazador a <Target>."
L["GUFFAW"]="Sueltas una escandalosa carcajada."	   ;   	L["GUFFAW_TARGET"]="Miras a <Target> y sueltas una carcajada."
L["HAIL"]="Saludas a todos los presentes."	   ;   	L["HAIL_TARGET"]="Saludas a <Target>."
L["HAPPY"]="Estás que saltas de alegría."	   ;   	L["HAPPY_TARGET"]="Estás muy feliz con <Target>."
L["HEADACHE"]="Te está dando dolor de cabeza."	   ;   	L["HEADACHE_TARGET"]="Te están dando dolor de cabeza de las payasadas de <Target>."
L["HEALME"]="¡Pides una sanación a gritos!"	   ;   	L["HEALME_TARGET"]="¡Pides una sanación a gritos!"
L["HELLO"]="Dices hola cordialmente a todo el mundo."	   ;   	L["HELLO_TARGET"]="Dices hola cordialmente a <Target>."
L["HELPME"]="¡Pides ayuda a gritos!"	   ;   	L["HELPME_TARGET"]="¡Pides ayuda a gritos!"
L["HICCUP"]="Te entra un hipo enorme."	   ;   	L["HICCUP_TARGET"]="Te entra un hipo enorme."
L["HISS"]="Abucheas a todos a tu alrededor."	   ;   	L["HISS_TARGET"]="Abucheas a <Target>."
L["HOLDHAND"]="Te gustaría que alguien te cogiera de la mano."	   ;   	L["HOLDHAND_TARGET"]="Coges a <Target> de la mano."
L["HUG"]="¡Necesitas un abrazo!"	   ;   	L["HUG_TARGET"]="Abrazas a <Target>."
L["HUNGRY"]="¡Tienes hambre!"	   ;   	L["HUNGRY_TARGET"]="Tienes hambre. Quizás <Target> tenga algo de comer..."
L["HURRY"]="Intentas aligerar el paso."	   ;   	L["HURRY_TARGET"]="Le dices a <Target> que se dé prisa."
L["IDEA"]="¡Tienes una idea!"	   ;   	L["IDEA_TARGET"]="¡Tienes una idea!"
L["INCOMING"]="¡Adviertes a todo el mundo de que se aproxima el enemigo!"	   ;   	L["INCOMING_TARGET"]="¡Apuntas con el dedo a <Target> como enemigo próximo!"
L["INSULT"]="Piensas que todos a tu alrededor son unos hijos de ogra."	   ;   	L["INSULT_TARGET"]="Crees que <Target> es un hijo de ogra."
L["INTRODUCE"]="Te presentas a todos."	   ;   	L["INTRODUCE_TARGET"]="Te presentas a <Target>."
L["JEALOUS"]="Tienes celos de todos los que te rodean."	   ;   	L["JEALOUS_TARGET"]="Tienes celos de <Target>."
L["JK"]="¡Solo bromeabas!"	   ;   	L["JK_TARGET"]="Le dices a <Target> que solo bromeabas."
L["JOKE"]="Cuentas un chiste."	   ;   	L["JOKE_TARGET"]="Cuentas un chiste a <Target>."
L["KISS"]="Tiras un beso al aire."	   ;   	L["KISS_TARGET"]="Le tiras un beso a <Target>."
L["KNEEL"]="Te arrodillas."	   ;   	L["KNEEL_TARGET"]="Te arrodillas ante <Target>."
L["LAUGH"]="Te ríes."	   ;   	L["LAUGH_TARGET"]="Te ríes de <Target>."
L["LAYDOWN"]="Te tumbas."	   ;   	L["LAYDOWN_TARGET"]="Te tumbas ante <Target>."
L["LICK"]="Te lames los labios."	   ;   	L["LICK_TARGET"]="Lames a <Target>."
L["LISTEN"]="¡Estás escuchando!"	   ;   	L["LISTEN_TARGET"]="Escuchas atentamente a <Target>."
L["LOOK"]="Miras a tu alrededor."	   ;   	L["LOOK_TARGET"]="Miras a <Target>."
L["LOST"]="No tienes ni idea de dónde estás."	   ;   	L["LOST_TARGET"]="Le dices a <Target> que no tienes ni idea de dónde estás."
L["LOVE"]="Sientes el amor en el aire."	   ;   	L["LOVE_TARGET"]="Amas a <Target>."
L["LUCK"]="Le deseas buena suerte a todo el mundo."	   ;   	L["LUCK_TARGET"]="Le deseas a <Target> muchísima suerte."
L["MAP"]="Sacas tu mapa."	   ;   	L["MAP_TARGET"]="Sacas tu mapa."
L["MASSAGE"]="Necesitas que te den un masaje."	   ;   	L["MASSAGE_TARGET"]="Le das un masaje en los hombros a <Target>."
L["MERCY"]="Suplicas piedad."	   ;   	L["MERCY_TARGET"]="Suplicas piedad a <Target>."
L["MOAN"]="Gimes de forma provocativa."	   ;   	L["MOAN_TARGET"]="Gimes de forma provocativa a <Target>."
L["MOCK"]="Te burlas de la vida y de todo lo que conlleva."	   ;   	L["MOCK_TARGET"]="Te burlas de la insensatez de <Target>."
L["MOO"]="Muu."	   ;   	L["MOO_TARGET"]="Imitas a una vaca ante <Target>. Muu."
L["MOON"]="Te bajas los pantalones y le haces un calvo a todos."	   ;   	L["MOON_TARGET"]="Te bajas los pantalones y le haces un calvo a <Target>."
L["MOURN"]="En una calma contemplativa, lamentas la pérdida de los que ya no están."	   ;   	L["MOURN_TARGET"]="En una calma contemplativa, lamentas la muerte de <Target>."
L["MUTTER"]="Refunfuñas con enfado para ti. ¡Humm!"	   ;   	L["MUTTER_TARGET"]="Refunfuñas con enfado a <Target>. ¡Humm!"
L["NERVOUS"]="Miras a tu alrededor con nerviosismo."	   ;   	L["NERVOUS_TARGET"]="Miras a <Target> con nerviosismo."
L["NO"]="Dices claramente que NO."	   ;   	L["NO_TARGET"]="Dices a <Target> que NO. Ni por todo el oro del mundo."
L["NOD"]="Asientes."	   ;   	L["NOD_TARGET"]="Asientes ante <Target>."
L["NOSEPICK"]="Te entretienes hurgando en tu nariz, en busca del moco perdido."	   ;   	L["NOSEPICK_TARGET"]="Te sacas un moco y se lo muestras a <Target>."
L["OBJECT"]="¡TE OPONES!"	   ;   	L["OBJECT_TARGET"]="Te opones a <Target>."
L["OFFER"]="Quieres hacer una oferta."	   ;   	L["OFFER_TARGET"]="Haces a <Target> una oferta que no podrá rechazar."
L["OOM"]="Avisas de que tienes poco maná."	   ;   	L["OOM_TARGET"]="Avisas de que tienes poco maná."
L["OPENFIRE"]="Ordenas abrir fuego."	   ;   	L["OPENFIRE_TARGET"]="Ordenas abrir fuego."
L["PANIC"]="Te entra el pánico y corres frenéticamente."	   ;   	L["PANIC_TARGET"]="Echas un ojo a <Target> y sientes miedo."
L["PAT"]="Necesitas ánimos."	   ;   	L["PAT_TARGET"]="Das unas palmaditas suaves en la espalda a <Target>."
L["PEER"]="Observas a tu alrededor, como si buscases algo."	   ;   	L["PEER_TARGET"]="Observas a <Target>, como si buscases algo."
L["PET"]="Necesitas que alguien te acaricie."	   ;   	L["PET_TARGET"]="Acaricias a <Target>."
L["PINCH"]="Te pellizcas."	   ;   	L["PINCH_TARGET"]="Pellizcas a <Target>."
L["PITY"]="Sientes lástima por todos a tu alrededor."	   ;   	L["PITY_TARGET"]="Miras a <Target> con lástima."
L["PLEAD"]="Te arrodillas y suplicas con desesperación."	   ;   	L["PLEAD_TARGET"]="Suplicas a <Target>."
L["POINT"]="Señalas con el dedo... ¡por allá!"	   ;   	L["POINT_TARGET"]="Señalas a <Target>."
L["POKE"]="Te golpeas la barriga y te ríes."	   ;   	L["POKE_TARGET"]="Chinchas a <Target>. ¡Eh!"
L["PONDER"]="Reflexionas sobre la situación."	   ;   	L["PONDER_TARGET"]="Reflexionas sobre el comportamiento de <Target>."
L["POUNCE"]="Te abalanzas súbitamente desde las sombras."	   ;   	L["POUNCE_TARGET"]="Te abalanzas sobre <Target>."
L["POUT"]="Haces pucheritos a todos los que te rodean."	   ;   	L["POUT_TARGET"]="Le haces pucheritos a <Target>."
L["PRAISE"]="¡Alabada sea la Luz!"	   ;   	L["PRAISE_TARGET"]="Sientes admiración por <Target>."
L["PRAY"]="Rezas a los dioses."	   ;   	L["PRAY_TARGET"]="Rezas una oración por <Target>."
L["PROMISE"]=""	   ;   	L["PROMISE_TARGET"]="Le haces una promesa a <Target>."
L["PROUD"]="Te enorgulleces."	   ;   	L["PROUD_TARGET"]="Te enorgulleces de <Target>."
L["PULSE"]="Te tomas el pulso."	   ;   	L["PULSE_TARGET"]="Le tomas el pulso a <Target>. ¡Oh, no!"
L["PUNCH"]="Te das un golpe en el hombro."	   ;   	L["PUNCH_TARGET"]="Le das un golpe en el hombro a <Target>."
L["PURR"]="Ronroneas como un gatito."	   ;   	L["PURR_TARGET"]="Ronroneas a <Target>."
L["PUZZLE"]="Sientes desconcierto. ¿Qué pasa?"	   ;   	L["PUZZLE_TARGET"]="Sientes desconcierto ante <Target>."
L["RAISE"]="Levantas la mano."	   ;   	L["RAISE_TARGET"]="Miras a <Target> y levantas la mano."
L["RASP"]="Haces un gesto obsceno."	   ;   	L["RASP_TARGET"]="Haces un gesto obsceno a <Target>."
L["READY"]="Haces saber a todo el mundo que está todo listo."	   ;   	L["READY_TARGET"]="Haces saber a <Target> que está todo listo."
L["REGRET"]="Te arrepientes."	   ;   	L["REGRET_TARGET"]="Crees que <Target> se arrepentirá."
L["REVENGE"]="Juras vengarte."	   ;   	L["REVENGE_TARGET"]="Juras vengarte de <Target>."
L["ROAR"]="Ruges con energía. ¡Toda una fiera!"	   ;   	L["ROAR_TARGET"]="Ruges con energía ante <Target>. ¡Toda una fiera!"
L["ROFL"]="Te partes el culo de risa."	   ;   	L["ROFL_TARGET"]="Te partes el culo de risa de <Target>."
L["ROLLEYES"]="Pones cara de desesperación."	   ;   	L["ROLLEYES_TARGET"]="Miras a <Target> con cara de desesperación."
L["RUDE"]="Haces un gesto obsceno."	   ;   	L["RUDE_TARGET"]="Haces un gesto obsceno a <Target>."
L["RUFFLE"]="Te despeinas."	   ;   	L["RUFFLE_TARGET"]="Despeinas a <Target>."
L["SAD"]="Bajas la cabeza con exasperación."	   ;   	L["SAD_TARGET"]="Bajas la cabeza con exasperación."
L["SALUTE"]="Te pones en posición de firme y saludas."	   ;   	L["SALUTE_TARGET"]="Saludas a <Target> con respeto."
L["SCARED"]="Tienes miedo."	   ;   	L["SCARED_TARGET"]="Tienes miedo de <Target>."
L["SCOFF"]="Te burlas."	   ;   	L["SCOFF_TARGET"]="Te burlas de <Target>."
L["SCOLD"]="Te regañas."	   ;   	L["SCOLD_TARGET"]="Regañas a <Target>."
L["SCOWL"]="Miras con desagrado."	   ;   	L["SCOWL_TARGET"]="Miras a <Target> con desagrado."
L["SCRATCH"]="Te rascas la espalda. ¡Qué placer!"	   ;   	L["SCRATCH_TARGET"]="Arañas a <Target>. ¿Te crees un gato?"
L["SEARCH"]="Buscas algo."	   ;   	L["SEARCH_TARGET"]="Buscas a <Target> para algo."
L["SEXY"]="Estás demasiado sexy con esa túnica... Te duele la cara de ser tan sexy."	   ;   	L["SEXY_TARGET"]="Crees que <Target> es sexy."
L["SHAKE"]="Sacudes el trasero."	   ;   	L["SHAKE_TARGET"]="Sacudes el trasero frente a <Target>."
L["SHAKEFIST"]="Aprietas los puños con rabia contenida."	   ;   	L["SHAKEFIST_TARGET"]="Aprietas los puños con rabia contenida hacia <Target>."
L["SHIFTY"]="Diriges la mirada de un lado a otro de forma sospechosa."	   ;   	L["SHIFTY_TARGET"]="Le diriges a <Target> una mirada furtiva."
L["SHIMMY"]="Vibras ante las masas."	   ;   	L["SHIMMY_TARGET"]="Vibras ante <Target>."
L["SHIVER"]="Sientes escalofríos. ¡Espeluznante!"	   ;   	L["SHIVER_TARGET"]="Sientes escalofríos al lado de <Target>. ¡Espeluznante!"
L["SHOO"]="Ahuyentas a los bichos molestos."	   ;   	L["SHOO_TARGET"]="Espantas a <Target>. ¡Fuera, bicho!"
L["SHOUT"]="Gritas."	   ;   	L["SHOUT_TARGET"]="Gritas a <Target>."
L["SHRUG"]="Te encoges de hombros. Quién sabe."	   ;   	L["SHRUG_TARGET"]="Te encoges de hombros ante <Target>. Quién sabe."
L["SHUDDER"]="Te estremeces."	   ;   	L["SHUDDER_TARGET"]="Te estremeces al ver a <Target>."
L["SHY"]="Sonríes con timidez."	   ;   	L["SHY_TARGET"]="Sonríes con timidez a <Target>."
L["SIGH"]="Suspiras lenta y apaciblemente."	   ;   	L["SIGH_TARGET"]="Suspiras ante <Target>."
L["SIGNAL"]="Das la señal."	   ;   	L["SIGNAL_TARGET"]="Das la señal a <Target>."
L["SILENCE"]="Le dices a todo el mundo que se calle. ¡Shhh!"	   ;   	L["SILENCE_TARGET"]="Le dices a <Target> que se calle. ¡Shhh!"
L["SING"]="Te pones a cantar."	   ;   	L["SING_TARGET"]="Le cantas una serenata a <Target>."
L["SIT"]="<animación>"	   ;   	L["SIT_TARGET"]="<animación>"
L["SLAP"]="Te cruzas la cara. ¡Ay!"	   ;   	L["SLAP_TARGET"]="Le cruzas la cara a <Target>. ¡Ay!"
L["SLEEP"]="Caes en un sueño profundo. Zzz."	   ;   	L["SLEEP_TARGET"]="Caes en un sueño profundo. Zzz."
L["SMACK"]="Te golpeas la frente."	   ;   	L["SMACK_TARGET"]="Le das un mamporro en la cabeza a <Target>."
L["SMILE"]="Sonríes."	   ;   	L["SMILE_TARGET"]="Sonríes a <Target>."
L["SMIRK"]="Una sonrisa pícara se dibuja en tu rostro."	   ;   	L["SMIRK_TARGET"]="Sonríes a <Target> con picardía."
L["SNAP"]="Chascas los dedos."	   ;   	L["SNAP_TARGET"]="Le chascas los dedos a <Target>."
L["SNARL"]="Muestras los dientes y gruñes."	   ;   	L["SNARL_TARGET"]="Muestras los dientes y gruñes a <Target>."
L["SNEAK"]="Tratas de escabullirte."	   ;   	L["SNEAK_TARGET"]="Tratas de escabullirte de <Target>."
L["SNEEZE"]="Estornudas. ¡Achúu!"	   ;   	L["SNEEZE_TARGET"]="Le estornudas encima a <Target>. ¡Achúu!"
L["SNICKER"]="Vetas la moción."	   ;   	L["SNICKER_TARGET"]="Te mofas de <Target>."
L["SNIFF"]="Olfateas el aire a tu alrededor."	   ;   	L["SNIFF_TARGET"]="Olfateas a <Target>."
L["SNORT"]="Resoplas."	   ;   	L["SNORT_TARGET"]="Le resoplas con sorna a <Target>."
L["SNUB"]="Tratas con desdén a los humildes peones a tu alrededor."	   ;   	L["SNUB_TARGET"]="Tratas con desdén a <Target>."
L["SOOTHE"]="Necesitas que te tranquilicen."	   ;   	L["SOOTHE_TARGET"]="Intentas tranquilizar a <Target>. Vamos, vamos, todo saldrá bien."
L["SPIT"]="Sueltas un gapo."	   ;   	L["SPIT_TARGET"]="Escupes a <Target>."
L["SQUEAL"]="Gruñes como un cerdo."	   ;   	L["SQUEAL_TARGET"]="Gruñes como un cerdo a <Target>."
L["STAND"]="<animación>"	   ;   	L["STAND_TARGET"]="<animación>"
L["STARE"]="Observas el horizonte."	   ;   	L["STARE_TARGET"]="Le clavas la mirada a <Target>."
L["STINK"]="Hueles el aire a tu alrededor. ¡Uh! ¡Alguien apesta!"	   ;   	L["STINK_TARGET"]="Hueles a <Target>. ¡Uh! ¡Alguien apesta!"
L["SURPRISED"]="¡Qué sorpresa!"	   ;   	L["SURPRISED_TARGET"]="Te sorprendes por la forma de actuar de <Target>."
L["SURRENDER"]="Te rindes ante tus oponentes."	   ;   	L["SURRENDER_TARGET"]="Te rindes ante <Target>. Así es la agonía de la derrota."
L["SUSPICIOUS"]="Entrecierras los ojos con mirada de sospecha."	   ;   	L["SUSPICIOUS_TARGET"]="Sospechas de <Target>."
L["SWEAT"]="Estás sudando."	   ;   	L["SWEAT_TARGET"]="Te pones a sudar al ver a <Target>."
L["TALK"]="Hablas para ti, ya que nadie parece interesado en tu conversación."	   ;   	L["TALK_TARGET"]="Quieres solucionar tus problemas con <Target>."
L["TALKEX"]="Hablas como un loro con todos."	   ;   	L["TALKEX_TARGET"]="Hablas como un loro con <Target>."
L["TALKQ"]="Te preguntas sobre el sentido de la vida."	   ;   	L["TALKQ_TARGET"]="Interrogas a <Target>."
L["TAP"]="Esperas con impaciencia. ¡Date prisa!"	   ;   	L["TAP_TARGET"]="Esperas con impaciencia a <Target>."
L["TAUNT"]="Haces un gesto provocador a todos. ¡Tomad!"	   ;   	L["TAUNT_TARGET"]="Le haces un gesto provocador a <Target>. ¡Toma!"
L["TEASE"]="Te las das de guay."	   ;   	L["TEASE_TARGET"]="Chinchas a <Target>."
L["THANK"]="Das las gracias a todos a tu alrededor."	   ;   	L["THANK_TARGET"]="Das las gracias a <Target>."
L["THINK"]="Te pierdes entre tus pensamientos."	   ;   	L["THINK_TARGET"]="Piensas en <Target>."
L["THIRSTY"]="Te mueres de sed. ¿Alguien tiene algo de beber?"	   ;   	L["THIRSTY_TARGET"]="Haces saber a <Target> que tienes sed. ¿Tiene algo de beber?"
L["THREATEN"]="Amenazas a todos con la ira de los dioses."	   ;   	L["THREATEN_TARGET"]="Amenazas a <Target> con la ira de los dioses."
L["TICKLE"]="Quieres que te hagan cosquillas. Ji, ji."	   ;   	L["TICKLE_TARGET"]="Haces cosquillas a <Target>. Ji, ji, ji."
L["TIRED"]="Haces saber a todos que sientes cansancio."	   ;   	L["TIRED_TARGET"]="Haces saber a <Target> que sientes cansancio."
L["TRAIN"]="<animación>"	   ;   	L["TRAIN_TARGET"]="<animación>"
L["TRUCE"]="Propones una tregua."	   ;   	L["TRUCE_TARGET"]="Le propones una tregua a <Target>."
L["TWIDDLE"]="Tamborileas con los dedos."	   ;   	L["TWIDDLE_TARGET"]="Tamborileas con los dedos."
L["VETO"]="Vetas la moción."	   ;   	L["VETO_TARGET"]="Vetas la moción de <Target>."
L["VICTORY"]="Festejas la victoria."	   ;   	L["VICTORY_TARGET"]="Festejas la victoria con <Target>."
L["VIOLIN"]="Te pones a tocar el violín más pequeño del mundo."	   ;   	L["VIOLIN_TARGET"]="Tocas el violín más pequeño del mundo para <Target>."
L["WAIT"]="Pides a todos que esperen."	   ;   	L["WAIT_TARGET"]="Pides a <Target> que espere."
L["WARN"]="Adviertes a todo el mundo."	   ;   	L["WARN_TARGET"]="Adviertes a <Target>."
L["WAVE"]="Saludas con la mano."	   ;   	L["WAVE_TARGET"]="Saludas con la mano a <Target>."
L["WELCOME"]="Das la bienvenida a todos."	   ;   	L["WELCOME_TARGET"]="Das la bienvenida a <Target>."
L["WHINE"]="Lloras patéticamente."	   ;   	L["WHINE_TARGET"]="Lloras patéticamente ante <Target>."
L["WHISTLE"]="Pegas un fuerte silbido."	   ;   	L["WHISTLE_TARGET"]="Silbas a <Target>."
L["WINK"]="Guiñas un ojo con picardía."	   ;   	L["WINK_TARGET"]="Guiñas un ojo a <Target> con picardía."
L["WORK"]="Te pones manos a la obra."	   ;   	L["WORK_TARGET"]="Trabajas con <Target>."
L["YAWN"]="Bostezas con pereza."	   ;   	L["YAWN_TARGET"]="Bostezas con pereza en la cara de <Target>."
L["YW"]="Te alegras por haber ayudado."	   ;   	L["YW_TARGET"]="Te alegras por haber ayudado a <Target>."																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																													
