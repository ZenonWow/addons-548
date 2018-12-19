--save this file in UTF-8 for special chars

	local debug = nil
--[===[@debug@
	debug = true
--@end-debug@]===]
	local L = LibStub("AceLocale-3.0"):NewLocale("EmoteCenter", "enUS", true, debug)
	

-- <- Translate these strings ->
-- Random addon strings
L["Last Emote Used"] = true
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
L["Friendly"] = true
L["Hostile"] = true
L["Happy"] = true
L["Neutral"] = true
L["Unhappy"] = true
L["Custom"] = true
L["Taunts"] = true
L["Affection"] = true
L["Greetings"] = true
L["Combat"] = true
L["Self-Deprecating"] = true
L["Reactions"] = true
L["Other"] = true
L["Actions"] = true
L["Vocals"] = true
L["New"] = true

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
L["BIO"]="needs to take a bio break."	   ;   	L["BIO_TARGET"]="tells <Target> that <he> needs a bio break."
L["BLADEINTRO"]="wants to introduce <his> blade to someone."	   ;   	L["BLADEINTRO_TARGET"]="wants to introduce <Target> to <his> blade."
L["ESCAPE"]="coughs nervously and looks for an escape."	   ;   	L["ESCAPE_TARGET"]="coughs nervously at <Target> and looks for an escape."

-- <- the translations under here are generated by the game ->

L["ABSENT"]="You look absent-minded."	   ;   	L["ABSENT_TARGET"]="You look at <Target> absently."
L["AGREE"]="You agree."	   ;   	L["AGREE_TARGET"]="You agree with <Target>."
L["AMAZE"]="You are amazed!"	   ;   	L["AMAZE_TARGET"]="You are amazed by <Target>!"
L["ANGRY"]="You raise your fist in anger."	   ;   	L["ANGRY_TARGET"]="You raise your fist in anger at <Target>."
L["APOLOGIZE"]="You apologize to everyone.  Sorry!"	   ;   	L["APOLOGIZE_TARGET"]="You apologize to <Target>.  Sorry!"
L["APPLAUD"]="You applaud.  Bravo!"	   ;   	L["APPLAUD_TARGET"]="You applaud at <Target>.  Bravo!"
L["ATTACKMYTARGET"]="You tell everyone to attack something."	   ;   	L["ATTACKMYTARGET_TARGET"]="You tell everyone to attack <Target>."
L["AWE"]="You look around in awe."	   ;   	L["AWE_TARGET"]="You stare at <Target> in awe."
L["BACKPACK"]="You dig through your backpack."	   ;   	L["BACKPACK_TARGET"]="You dig through your backpack."
L["BADFEELING"]="You have a bad feeling about this..."	   ;   	L["BADFEELING_TARGET"]="You have a bad feeling about <Target>."
L["BARK"]="You bark. Woof woof!"	   ;   	L["BARK_TARGET"]="You bark at <Target>."
L["BASHFUL"]="You are bashful."	   ;   	L["BASHFUL_TARGET"]="You are so bashful...too bashful to get <Target>'s attention."
L["BECKON"]="You beckon everyone over to you."	   ;   	L["BECKON_TARGET"]="You beckon <Target> over."
L["BEG"]="You beg everyone around you. How pathetic."	   ;   	L["BEG_TARGET"]="You beg <Target>.  How pathetic."
L["BITE"]="You look around for someone to bite."	   ;   	L["BITE_TARGET"]="You bite <Target>.  Ouch!"
L["BLAME"]="You blame yourself for what happened."	   ;   	L["BLAME_TARGET"]="You blame <Target> for everything."
L["BLANK"]="You stare blankly at your surroundings."	   ;   	L["BLANK_TARGET"]="You stare blankly at <Target>."
L["BLEED"]="Blood oozes from your wounds."	   ;   	L["BLEED_TARGET"]="Blood oozes from your wounds."
L["BLINK"]="You blink your eyes."	   ;   	L["BLINK_TARGET"]="You blink at <Target>."
L["BLUSH"]="You blush."	   ;   	L["BLUSH_TARGET"]="You blush at <Target>."
L["BOGGLE"]="You boggle at the situation."	   ;   	L["BOGGLE_TARGET"]="You boggle at <Target>."
L["BONK"]="You bonk yourself on the noggin.  Doh!"	   ;   	L["BONK_TARGET"]="You bonk <Target> on the noggin.  Doh!"
L["BORED"]="You are overcome with boredom.  Oh the drudgery!"	   ;   	L["BORED_TARGET"]="You are terribly bored with <Target>."
L["BOUNCE"]="You bounce up and down."	   ;   	L["BOUNCE_TARGET"]="You bounce up and down in front of <Target>."
L["BOW"]="You bow down graciously."	   ;   	L["BOW_TARGET"]="You bow before <Target>."
L["BRANDISH"]="You brandish your weapon fiercely."	   ;   	L["BRANDISH_TARGET"]="You brandish your weapon fiercely at <Target>."
L["BRB"]="You let everyone know you'll be right back."	   ;   	L["BRB_TARGET"]="You let <Target> know you'll be right back."
L["BREATH"]="You take a deep breath."	   ;   	L["BREATH_TARGET"]="You tell <Target> to take a deep breath."
L["BURP"]="You let out a loud belch."	   ;   	L["BURP_TARGET"]="You burp rudely in <Target>'s face."
L["BYE"]="You wave goodbye to everyone.  Farewell!"	   ;   	L["BYE_TARGET"]="You wave goodbye to <Target>.  Farewell!"
L["CACKLE"]="You cackle maniacally at the situation."	   ;   	L["CACKLE_TARGET"]="You cackle maniacally at <Target>."
L["CALM"]="You remain calm."	   ;   	L["CALM_TARGET"]="You try to calm <Target> down."
L["CHALLENGE"]="You put out a challenge to everyone. Bring it on!"	   ;   	L["CHALLENGE_TARGET"]="You challenge <Target> to a duel."
L["CHARGE"]="You start to charge."	   ;   	L["CHARGE_TARGET"]="You start to charge."
L["CHARM"]="You put on the charm."	   ;   	L["CHARM_TARGET"]="You think <Target> is charming."
L["CHEER"]="You cheer!"	   ;   	L["CHEER_TARGET"]="You cheer at <Target>."
L["CHICKEN"]="With arms flapping, you strut around.  Cluck, Cluck, Chicken!"	   ;   	L["CHICKEN_TARGET"]="With arms flapping, you strut around <Target>.  Cluck, Cluck, Chicken!"
L["CHUCKLE"]="You let out a hearty chuckle."	   ;   	L["CHUCKLE_TARGET"]="You chuckle at <Target>."
L["CHUG"]="You take a mighty quaff of your beverage."	   ;   	L["CHUG_TARGET"]="You encourage <Target> to chug. CHUG! CHUG! CHUG!"
L["CLAP"]="You clap excitedly."	   ;   	L["CLAP_TARGET"]="You clap excitedly for <Target>."
L["COLD"]="You let everyone know that you are cold."	   ;   	L["COLD_TARGET"]="You let <Target> know that you are cold."
L["COMFORT"]="You need to be comforted."	   ;   	L["COMFORT_TARGET"]="You comfort <Target>."
L["COMMEND"]="You commend everyone on a job well done."	   ;   	L["COMMEND_TARGET"]="You commend <Target> on a job well done."
L["CONFUSED"]="You are hopelessly confused."	   ;   	L["CONFUSED_TARGET"]="You look at <Target> with a confused look."
L["CONGRATULATE"]="You congratulate everyone around you."	   ;   	L["CONGRATULATE_TARGET"]="You congratulate <Target>."
L["COUGH"]="You let out a hacking cough."	   ;   	L["COUGH_TARGET"]="You cough at <Target>."
L["COVEREARS"]="You cover your ears."	   ;   	L["COVEREARS_TARGET"]="You cover <Target>'s ears."
L["COWER"]="You cower in fear."	   ;   	L["COWER_TARGET"]="You cower in fear at the sight of <Target>."
L["CRACK"]="You crack your knuckles."	   ;   	L["CRACK_TARGET"]="You crack your knuckles while staring at <Target>."
L["CRINGE"]="You cringe in fear."	   ;   	L["CRINGE_TARGET"]="You cringe away from <Target>."
L["CROSSARMS"]="You cross your arms."	   ;   	L["CROSSARMS_TARGET"]="You cross your arms at <Target>. Hmph!"
L["CRY"]="You cry."	   ;   	L["CRY_TARGET"]="You cry on <Target>'s shoulder."
L["CUDDLE"]="You need to be cuddled."	   ;   	L["CUDDLE_TARGET"]="You cuddle up against <Target>."
L["CURIOUS"]="You express your curiosity to those around you."	   ;   	L["CURIOUS_TARGET"]="You are curious what <Target> is up to."
L["CURTSEY"]="You curtsey."	   ;   	L["CURTSEY_TARGET"]="You curtsey before <Target>."
L["DANCE"]="You burst into dance."	   ;   	L["DANCE_TARGET"]="You dance with <Target>."
L["DING"]="You reached a new level. DING!"	   ;   	L["DING_TARGET"]="You congratulate <Target> on a new level. DING!"
L["DISAGREE"]="You disagree."	   ;   	L["DISAGREE_TARGET"]="You disagree with <Target>."
L["DOUBT"]="You doubt the situation will end in your favor."	   ;   	L["DOUBT_TARGET"]="You doubt <Target>."
L["DRINK"]="You raise a drink in the air before chugging it down.  Cheers!"	   ;   	L["DRINK_TARGET"]="You raise a drink to <Target>.  Cheers!"
L["DROOL"]="A tendril of drool runs down your lip."	   ;   	L["DROOL_TARGET"]="You look at <Target> and begin to drool."
L["DUCK"]="You duck for cover."	   ;   	L["DUCK_TARGET"]="You duck behind <Target>."
L["EAT"]="You begin to eat."	   ;   	L["EAT_TARGET"]="You begin to eat in front of <Target>."
L["EMBARRASS"]="You flush with embarrassment."	   ;   	L["EMBARRASS_TARGET"]="You are embarrassed by <Target>."
L["ENCOURAGE"]="You encourage everyone around you."	   ;   	L["ENCOURAGE_TARGET"]="You encourage <Target>."
L["ENEMY"]="You warn everyone that an enemy is near."	   ;   	L["ENEMY_TARGET"]="You warn <Target> that an enemy is near."
L["EYE"]="You cross your eyes."	   ;   	L["EYE_TARGET"]="You eye <Target> up and down."
L["EYEBROW"]="You raise your eyebrow inquisitively."	   ;   	L["EYEBROW_TARGET"]="You raise your eyebrow inquisitively at <Target>."
L["FAINT"]="You faint."	   ;   	L["FAINT_TARGET"]="You faint at the sight of <Target>."
L["FART"]="You fart loudly.  Whew...what stinks?"	   ;   	L["FART_TARGET"]="You brush up against <Target> and fart loudly."
L["FIDGET"]="You fidget."	   ;   	L["FIDGET_TARGET"]="You fidget impatiently while waiting for <Target>."
L["FLEE"]="You yell for everyone to flee!"	   ;   	L["FLEE_TARGET"]="You yell for <Target> to flee!"
L["FLEX"]="You flex your muscles.  Oooooh so strong!"	   ;   	L["FLEX_TARGET"]="You flex at <Target>.  Oooooh so strong!"
L["FLIRT"]="You flirt."	   ;   	L["FLIRT_TARGET"]="You flirt with <Target>."
L["FLOP"]="You flop about helplessly."	   ;   	L["FLOP_TARGET"]="You flop about helplessly around <Target>."
L["FOLLOW"]="You motion for everyone to follow."	   ;   	L["FOLLOW_TARGET"]="You motion for <Target> to follow."
L["FROWN"]="You frown."	   ;   	L["FROWN_TARGET"]="You frown with disappointment at <Target>."
L["GASP"]="You gasp."	   ;   	L["GASP_TARGET"]="You gasp at <Target>."
L["GAZE"]="You gaze off into the distance."	   ;   	L["GAZE_TARGET"]="You gaze longingly at <Target>."
L["GIGGLE"]="You giggle."	   ;   	L["GIGGLE_TARGET"]="You giggle at <Target>."
L["GLARE"]="You glare angrily."	   ;   	L["GLARE_TARGET"]="You glare angrily at <Target>."
L["GLOAT"]="You gloat over everyone's misfortune."	   ;   	L["GLOAT_TARGET"]="You gloat over <Target>'s misfortune."
L["GLOWER"]="You glower at averyone around you."	   ;   	L["GLOWER_TARGET"]="You glower at <Target>."
L["GO"]="You tell everyone to go."	   ;   	L["GO_TARGET"]="You tell <Target> to go."
L["GOING"]="You must be going."	   ;   	L["GOING_TARGET"]="You tell <Target> that you must be going."
L["GOLFCLAP"]="You clap half-heartedly, clearly unimpressed."	   ;   	L["GOLFCLAP_TARGET"]="You clap for <Target>, clearly unimpressed."
L["GREET"]="You greet everyone warmly."	   ;   	L["GREET_TARGET"]="You greet <Target> warmly."
L["GRIN"]="You grin wickedly."	   ;   	L["GRIN_TARGET"]="You grin wickedly at <Target>."
L["GROAN"]="You begin to groan."	   ;   	L["GROAN_TARGET"]="You look at <Target> and groan."
L["GROVEL"]="You grovel on the ground, wallowing in subservience."	   ;   	L["GROVEL_TARGET"]="You grovel before <Target> like a subservient peon."
L["GROWL"]="You growl menacingly."	   ;   	L["GROWL_TARGET"]="You growl menacingly at <Target>."
L["GUFFAW"]="You let out a boisterous guffaw!"	   ;   	L["GUFFAW_TARGET"]="You take one look at <Target> and let out a guffaw!"
L["HAIL"]="You hail those around you."	   ;   	L["HAIL_TARGET"]="You hail <Target>."
L["HAPPY"]="You are filled with happiness!"	   ;   	L["HAPPY_TARGET"]="You are very happy with <Target>!"
L["HEADACHE"]="You are getting a headache."	   ;   	L["HEADACHE_TARGET"]="You are getting a headache from <Target>'s antics."
L["HEALME"]="You call out for healing!"	   ;   	L["HEALME_TARGET"]="You call out for healing!"
L["HELLO"]="You greet everyone with a hearty hello!"	   ;   	L["HELLO_TARGET"]="You greet <Target> with a hearty hello!"
L["HELPME"]="You cry out for help!"	   ;   	L["HELPME_TARGET"]="You cry out for help!"
L["HICCUP"]="You hiccup loudly."	   ;   	L["HICCUP_TARGET"]="You hiccup loudly."
L["HISS"]="You hiss at everyone around you."	   ;   	L["HISS_TARGET"]="You hiss at <Target>."
L["HOLDHAND"]="You wish someone would hold your hand."	   ;   	L["HOLDHAND_TARGET"]="You hold <Target>'s hand."
L["HUG"]="You need a hug!"	   ;   	L["HUG_TARGET"]="You hug <Target>."
L["HUNGRY"]="You are hungry!"	   ;   	L["HUNGRY_TARGET"]="You are hungry.  Maybe <Target> has some food..."
L["HURRY"]="You try to pick up the pace."	   ;   	L["HURRY_TARGET"]="You tell <Target> to hurry up."
L["IDEA"]="You have an idea!"	   ;   	L["IDEA_TARGET"]="You have an idea!"
L["INCOMING"]="You warn everyone of incoming enemies!"	   ;   	L["INCOMING_TARGET"]="You point out <Target> as an incoming enemy!"
L["INSULT"]="You think everyone around you is a son of a motherless ogre."	   ;   	L["INSULT_TARGET"]="You think <Target> is the son of a motherless ogre."
L["INTRODUCE"]="You introduce yourself to everyone."	   ;   	L["INTRODUCE_TARGET"]="You introduce yourself to <Target>."
L["JEALOUS"]="You are jealous of everyone around you."	   ;   	L["JEALOUS_TARGET"]="You are jealous of <Target>."
L["JK"]="You were just kidding!"	   ;   	L["JK_TARGET"]="You let <Target> know that you were just kidding!"
L["JOKE"]="You tell a joke."	   ;   	L["JOKE_TARGET"]="You tell <Target> a joke."
L["KISS"]="You blow a kiss into the wind."	   ;   	L["KISS_TARGET"]="You blow a kiss to <Target>."
L["KNEEL"]="You kneel down."	   ;   	L["KNEEL_TARGET"]="You kneel before <Target>."
L["LAUGH"]="You laugh."	   ;   	L["LAUGH_TARGET"]="You laugh at <Target>."
L["LAYDOWN"]="You lie down."	   ;   	L["LAYDOWN_TARGET"]="You lie down before <Target>."
L["LICK"]="You lick your lips."	   ;   	L["LICK_TARGET"]="You lick <Target>."
L["LISTEN"]="You are listening!"	   ;   	L["LISTEN_TARGET"]="You listen intently to <Target>."
L["LOOK"]="You look around."	   ;   	L["LOOK_TARGET"]="You look at <Target>."
L["LOST"]="You are hopelessly lost."	   ;   	L["LOST_TARGET"]="You want <Target> to know that you are hopelessly lost."
L["LOVE"]="You feel the love."	   ;   	L["LOVE_TARGET"]="You love <Target>."
L["LUCK"]="You wish everyone good luck."	   ;   	L["LUCK_TARGET"]="You wish <Target> the best of luck."
L["MAP"]="You pull out your map."	   ;   	L["MAP_TARGET"]="You pull out your map."
L["MASSAGE"]="You need a massage!"	   ;   	L["MASSAGE_TARGET"]="You massage <Target>'s shoulders."
L["MERCY"]="You plead for mercy."	   ;   	L["MERCY_TARGET"]="You plead with <Target> for mercy."
L["MOAN"]="You moan suggestively."	   ;   	L["MOAN_TARGET"]="You moan suggestively at <Target>."
L["MOCK"]="You mock life and all it stands for."	   ;   	L["MOCK_TARGET"]="You mock the foolishness of <Target>."
L["MOO"]="Mooooooooooo."	   ;   	L["MOO_TARGET"]="You moo at <Target>. Mooooooooooo."
L["MOON"]="You drop your trousers and moon everyone."	   ;   	L["MOON_TARGET"]="You drop your trousers and moon <Target>."
L["MOURN"]="In quiet contemplation, you mourn the loss of the dead."	   ;   	L["MOURN_TARGET"]="In quiet contemplation, you mourn the death of <Target>."
L["MUTTER"]="You mutter angrily to yourself. Hmmmph!"	   ;   	L["MUTTER_TARGET"]="You mutter angrily at <Target>. Hmmmph!"
L["NERVOUS"]="You look around nervously."	   ;   	L["NERVOUS_TARGET"]="You look at <Target> nervously."
L["NO"]="You clearly state, NO."	   ;   	L["NO_TARGET"]="You tell <Target> NO.  Not going to happen."
L["NOD"]="You nod."	   ;   	L["NOD_TARGET"]="You tell <Target> NO.  Not going to happen."
L["NOSEPICK"]="With a finger deep in one nostril, you pass the time."	   ;   	L["NOSEPICK_TARGET"]="You pick your nose and show it to <Target>."
L["OBJECT"]="You OBJECT!"	   ;   	L["OBJECT_TARGET"]="You object to <Target>."
L["OFFER"]="You want to make an offer."	   ;   	L["OFFER_TARGET"]="You attempt to make <Target> an offer they can't refuse."
L["OOM"]="You announce that you have low mana!"	   ;   	L["OOM_TARGET"]="You announce that you have low mana!"
L["OPENFIRE"]="You give the order to open fire."	   ;   	L["OPENFIRE_TARGET"]="You give the order to open fire."
L["PANIC"]="You run around in a frenzied state of panic."	   ;   	L["PANIC_TARGET"]="You take one look at <Target> and panic."
L["PAT"]="You need a pat."	   ;   	L["PAT_TARGET"]="You gently pat <Target>."
L["PEER"]="You peer around, searchingly."	   ;   	L["PEER_TARGET"]="You peer at <Target> searchingly."
L["PET"]="You need to be petted."	   ;   	L["PET_TARGET"]="You pet <Target>."
L["PINCH"]="You pinch yourself."	   ;   	L["PINCH_TARGET"]="You pinch <Target>."
L["PITY"]="You pity those around you."	   ;   	L["PITY_TARGET"]="You look down upon <Target> with pity."
L["PLEAD"]="You drop to your knees and plead in desperation."	   ;   	L["PLEAD_TARGET"]="You plead with <Target>."
L["POINT"]="You point over yonder."	   ;   	L["POINT_TARGET"]="You point at <Target>."
L["POKE"]="You poke your belly and giggle."	   ;   	L["POKE_TARGET"]="You poke <Target>.  Hey!"
L["PONDER"]="You ponder the situation."	   ;   	L["PONDER_TARGET"]="You ponder <Target>'s actions."
L["POUNCE"]="You pounce out from the shadows."	   ;   	L["POUNCE_TARGET"]="You pounce on top of <Target>."
L["POUT"]="You pout at everyone around you."	   ;   	L["POUT_TARGET"]="You pout at <Target>."
L["PRAISE"]="You praise the Light."	   ;   	L["PRAISE_TARGET"]="You lavish praise upon <Target>."
L["PRAY"]="You pray to the Gods."	   ;   	L["PRAY_TARGET"]="You say a prayer for <Target>."
L["PROMISE"]=""	   ;   	L["PROMISE_TARGET"]="You make <Target> a promise."
L["PROUD"]="You are proud of yourself."	   ;   	L["PROUD_TARGET"]="You are proud of <Target>."
L["PULSE"]="You check your own pulse."	   ;   	L["PULSE_TARGET"]="You check <Target> for a pulse. Oh no!"
L["PUNCH"]="You punch yourself."	   ;   	L["PUNCH_TARGET"]="You punch <Target>'s shoulder."
L["PURR"]="You purr like a kitten."	   ;   	L["PURR_TARGET"]="You purr at <Target>."
L["PUZZLE"]="You are puzzled. What's going on here?"	   ;   	L["PUZZLE_TARGET"]="You are puzzled by <Target>."
L["RAISE"]="You raise your hand in the air."	   ;   	L["RAISE_TARGET"]="You look at <Target> and raise your hand."
L["RASP"]="You make a rude gesture."	   ;   	L["RASP_TARGET"]="You make a rude gesture at <Target>."
L["READY"]="You let everyone know that you are ready!"	   ;   	L["READY_TARGET"]="You let <Target> know that you are ready!"
L["REGRET"]="You are filled with regret."	   ;   	L["REGRET_TARGET"]="You think that <Target> will regret it."
L["REVENGE"]="You vow you will have your revenge."	   ;   	L["REVENGE_TARGET"]="You vow revenge on <Target>."
L["ROAR"]="You roar with bestial vigor.  So fierce!"	   ;   	L["ROAR_TARGET"]="You roar with bestial vigor at <Target>.  So fierce!"
L["ROFL"]="You roll on the floor laughing."	   ;   	L["ROFL_TARGET"]="You roar with bestial vigor at <Target>.  So fierce!"
L["ROLLEYES"]="You roll your eyes."	   ;   	L["ROLLEYES_TARGET"]="You roll your eyes at <Target>."
L["RUDE"]="You make a rude gesture."	   ;   	L["RUDE_TARGET"]="You make a rude gesture at <Target>."
L["RUFFLE"]="You ruffle your hair."	   ;   	L["RUFFLE_TARGET"]="You ruffle <Target>'s hair."
L["SAD"]="You hang your head dejectedly."	   ;   	L["SAD_TARGET"]="You hang your head dejectedly."
L["SALUTE"]="You stand at attention and salute."	   ;   	L["SALUTE_TARGET"]="You salute <Target> with respect."
L["SCARED"]="You are scared!"	   ;   	L["SCARED_TARGET"]="You are scared of <Target>."
L["SCOFF"]="You scoff."	   ;   	L["SCOFF_TARGET"]="You scoff at <Target>."
L["SCOLD"]="You scold yourself."	   ;   	L["SCOLD_TARGET"]="You scold <Target>."
L["SCOWL"]="You scowl."	   ;   	L["SCOWL_TARGET"]="You scowl at <Target>."
L["SCRATCH"]="You scratch yourself.  Ah, much better!"	   ;   	L["SCRATCH_TARGET"]="You scratch <Target>.  How catty!"
L["SEARCH"]="You search for something."	   ;   	L["SEARCH_TARGET"]="You search <Target> for something."
L["SEXY"]="You're too sexy for your tunic...so sexy it hurts."	   ;   	L["SEXY_TARGET"]="You think <Target> is a sexy devil."
L["SHAKE"]="You shake your rear."	   ;   	L["SHAKE_TARGET"]="You shake your rear at <Target>."
L["SHAKEFIST"]="You shake your fist."	   ;   	L["SHAKEFIST_TARGET"]="You shake your fist at <Target>."
L["SHIFTY"]="Your eyes shift back and forth suspiciously."	   ;   	L["SHIFTY_TARGET"]="You give <Target> a shifty look."
L["SHIMMY"]="You shimmy before the masses."	   ;   	L["SHIMMY_TARGET"]="You shimmy before <Target>."
L["SHIVER"]="You shiver in your boots. Chilling!"	   ;   	L["SHIVER_TARGET"]="You shiver beside <Target>. Chilling!"
L["SHOO"]="You shoo the measly pests away."	   ;   	L["SHOO_TARGET"]="You shoo <Target> away. Be gone pest!"
L["SHOUT"]="You shout."	   ;   	L["SHOUT_TARGET"]="You shake your rear at <Target>."
L["SHRUG"]="You shrug.  Who knows?"	   ;   	L["SHRUG_TARGET"]="You shrug at <Target>.  Who knows?"
L["SHUDDER"]="You shudder."	   ;   	L["SHUDDER_TARGET"]="You shudder at the sight of <Target>."
L["SHY"]="You smile shyly."	   ;   	L["SHY_TARGET"]="You smile shyly at <Target>."
L["SIGH"]="You let out a long, drawn-out sigh."	   ;   	L["SIGH_TARGET"]="You smile shyly at <Target>."
L["SIGNAL"]="You give the signal."	   ;   	L["SIGNAL_TARGET"]="You give <Target> the signal."
L["SILENCE"]="You tell everyone to be quiet. Shhh!"	   ;   	L["SILENCE_TARGET"]="You tell <Target> to be quiet. Shhh!"
L["SING"]="You burst into song."	   ;   	L["SING_TARGET"]="You serenade <Target> with a song."
L["SIT"]="<animation>"	   ;   	L["SIT_TARGET"]="<animation>"
L["SLAP"]="You slap yourself across the face. Ouch!"	   ;   	L["SLAP_TARGET"]="You slap <Target> across the face. Ouch!"
L["SLEEP"]="You fall asleep.  Zzzzzzz."	   ;   	L["SLEEP_TARGET"]="You fall asleep.  Zzzzzzz."
L["SMACK"]="You smack your forehead."	   ;   	L["SMACK_TARGET"]="You smack <Target> upside the head."
L["SMILE"]="You smile."	   ;   	L["SMILE_TARGET"]="You smile at <Target>."
L["SMIRK"]="A sly smirk spreads across your face."	   ;   	L["SMIRK_TARGET"]="You smirk slyly at <Target>."
L["SNAP"]="You snap your fingers."	   ;   	L["SNAP_TARGET"]="You snap your fingers at <Target>."
L["SNARL"]="You bare your teeth and snarl."	   ;   	L["SNARL_TARGET"]="You bare your teeth and snarl at <Target>."
L["SNEAK"]="You try to sneak away."	   ;   	L["SNEAK_TARGET"]="You try to sneak away from <Target>."
L["SNEEZE"]="You sneeze. Achoo!"	   ;   	L["SNEEZE_TARGET"]="You sneeze on <Target>. Achoo!"
L["SNICKER"]="You quietly snicker to yourself."	   ;   	L["SNICKER_TARGET"]="You snicker at <Target>."
L["SNIFF"]="You sniff the air around you."	   ;   	L["SNIFF_TARGET"]="You sniff <Target>."
L["SNORT"]="You snort."	   ;   	L["SNORT_TARGET"]="You snort derisively at <Target>."
L["SNUB"]="You snub all of the lowly peons around you."	   ;   	L["SNUB_TARGET"]="You snub <Target>."
L["SOOTHE"]="You need to be soothed."	   ;   	L["SOOTHE_TARGET"]="You soothe <Target>. There, there...things will be ok."
L["SPIT"]="You spit on the ground."	   ;   	L["SPIT_TARGET"]="You spit on <Target>."
L["SQUEAL"]="You squeal like a pig."	   ;   	L["SQUEAL_TARGET"]="You squeal at <Target>."
L["STAND"]="<animation>"	   ;   	L["STAND_TARGET"]="<animation>"
L["STARE"]="You stare off into the distance."	   ;   	L["STARE_TARGET"]="You stare <Target> down."
L["STINK"]="You smell the air around you. Wow, someone stinks!"	   ;   	L["STINK_TARGET"]="You smell <Target>. Wow, someone stinks!"
L["SURPRISED"]="You are so surprised!"	   ;   	L["SURPRISED_TARGET"]="You are surprised by <Target>'s actions."
L["SURRENDER"]="You surrender to your opponents."	   ;   	L["SURRENDER_TARGET"]="You are surprised by <Target>'s actions."
L["SUSPICIOUS"]="You narrow your eyes in suspicion."	   ;   	L["SUSPICIOUS_TARGET"]="You are suspicious of <Target>."
L["SWEAT"]="You are sweating."	   ;   	L["SWEAT_TARGET"]="You sweat at the sight of <Target>."
L["TALK"]="You talk to yourself since no one else seems interested."	   ;   	L["TALK_TARGET"]="You want to talk things over with <Target>."
L["TALKEX"]="You talk excitedly with everyone."	   ;   	L["TALKEX_TARGET"]="You talk excitedly with <Target>."
L["TALKQ"]="You want to know the meaning of life."	   ;   	L["TALKQ_TARGET"]="You question <Target>."
L["TAP"]="You tap your foot.  Hurry up already!"	   ;   	L["TAP_TARGET"]="You tap your foot as you wait for <Target>."
L["TAUNT"]="You taunt everyone around you. Bring it fools!"	   ;   	L["TAUNT_TARGET"]="You make a taunting gesture at <Target>. Bring it!"
L["TEASE"]="You are such a tease."	   ;   	L["TEASE_TARGET"]="You tease <Target>."
L["THANK"]="You thank everyone around you."	   ;   	L["THANK_TARGET"]="You thank <Target>."
L["THINK"]="You are lost in thought."	   ;   	L["THINK_TARGET"]="You think about <Target>."
L["THIRSTY"]="You are so thirsty. Can anyone spare a drink?"	   ;   	L["THIRSTY_TARGET"]="You let <Target> know you are thirsty. Spare a drink?"
L["THREATEN"]="You threaten everyone with the wrath of doom."	   ;   	L["THREATEN_TARGET"]="You threaten <Target> with the wrath of doom."
L["TICKLE"]="You want to be tickled.  Hee hee!"	   ;   	L["TICKLE_TARGET"]="You tickle <Target>.  Hee hee!"
L["TIRED"]="You let everyone know that you are tired."	   ;   	L["TIRED_TARGET"]="You let <Target> know that you are tired."
L["TRAIN"]="<Choo Choo Train Animation and sound>"	   ;   	L["TRAIN_TARGET"]="<Choo Choo Train Animation and sound>"
L["TRUCE"]="You offer a truce."	   ;   	L["TRUCE_TARGET"]="You offer <Target> a truce."
L["TWIDDLE"]="You twiddle your thumbs."	   ;   	L["TWIDDLE_TARGET"]="You twiddle your thumbs."
L["VETO"]="You veto the motion on the floor."	   ;   	L["VETO_TARGET"]="You veto <Target>'s motion."
L["VICTORY"]="You bask in the glory of victory."	   ;   	L["VICTORY_TARGET"]="You bask in the glory of victory with <Target>."
L["VIOLIN"]="You begin to play the world's smallest violin."	   ;   	L["VIOLIN_TARGET"]="You play the world's smallest violin for <Target>."
L["WAIT"]="You ask everyone to wait."	   ;   	L["WAIT_TARGET"]="You ask <Target> to wait."
L["WARN"]="You warn everyone."	   ;   	L["WARN_TARGET"]="You warn <Target>."
L["WAVE"]="You wave."	   ;   	L["WAVE_TARGET"]="You wave at <Target>."
L["WELCOME"]="You welcome everyone."	   ;   	L["WELCOME_TARGET"]="You welcome <Target>."
L["WHINE"]="You whine pathetically."	   ;   	L["WHINE_TARGET"]="You whine pathetically at <Target>."
L["WHISTLE"]="You let forth a sharp whistle."	   ;   	L["WHISTLE_TARGET"]="You whistle at <Target>."
L["WINK"]="You wink slyly."	   ;   	L["WINK_TARGET"]="You wink slyly at <Target>."
L["WORK"]="You begin to work."	   ;   	L["WORK_TARGET"]="You work with <Target>."
L["YAWN"]="You yawn sleepily."	   ;   	L["YAWN_TARGET"]="You yawn sleepily at <Target>."
L["YW"]="You were happy to help."	   ;   	L["YW_TARGET"]="You were happy to help <Target>."
