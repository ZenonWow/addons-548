--[[****************************************************************************
  * NPCScan.Overlay by Saiket                                                 *
  * Locales/Locale-ptBR.lua - Localized string constants (pt-BR/pt-PT).        *
  ****************************************************************************]]


if ( GetLocale() ~= "ptBR" and GetLocale() ~= "ptPT" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan-overlay/localization/ptBR/
local private = select( 2, ... );
private.L = setmetatable( {
	NPCs = setmetatable( {
	}, { __index = private.L.NPCs; } );
}, { __index = private.L; } );

private.L.NPCs["100"] = "Rude Mordelogo"
private.L.NPCs["10077"] = "Goela da Morte"
private.L.NPCs["10078"] = "Chamuska"
private.L.NPCs["10080"] = "Sandarr Aniquiladunas"
private.L.NPCs["10081"] = "Assombração de Poeira"
private.L.NPCs["10082"] = "Zerillis"
private.L.NPCs["10119"] = "Volchan"
private.L.NPCs["10196"] = "General Colbatann"
private.L.NPCs["10197"] = "Mezzir, o Rugidor"
private.L.NPCs["10198"] = "Kashoch, o Aniquilador"
private.L.NPCs["10199"] = "Pardo Pataneve"
private.L.NPCs["10200"] = "Rak'shiri"
private.L.NPCs["10202"] = "Azuros"
private.L.NPCs["10263"] = "Guarda Vil Ardente"
private.L.NPCs["10356"] = "Bayne"
private.L.NPCs["10357"] = "Ressan, o Agulheiro"
private.L.NPCs["10358"] = "Vulto de Fellicent"
private.L.NPCs["10359"] = "Tok'aya"
private.L.NPCs["10376"] = "Presa de Cristal"
private.L.NPCs["10393"] = "Kranio"
private.L.NPCs["10509"] = "Jed Mirarruna"
private.L.NPCs["10558"] = "Cantalar Forresten"
private.L.NPCs["10559"] = "Lady Véspia"
private.L.NPCs["1063"] = "Jade"
private.L.NPCs["10639"] = "Rórguis Papão"
private.L.NPCs["10640"] = "Fagarra"
private.L.NPCs["10641"] = "Quebra-galhos"
private.L.NPCs["10642"] = "Eck'alom"
private.L.NPCs["10644"] = "Uivador da Névoa"
private.L.NPCs["10647"] = "Príncipe Arrazear"
private.L.NPCs["10741"] = "Sian-Rotam"
private.L.NPCs["10809"] = "Petrespáduas"
private.L.NPCs["10817"] = "Duggan Martelo Feroz"
private.L.NPCs["10818"] = "Cavaleiro da Morte Portalmas"
private.L.NPCs["10819"] = "Barão Ruinassangue"
private.L.NPCs["10820"] = "Duque Rasgafúria"
private.L.NPCs["10821"] = "Hed'mush, o Apodrecente"
private.L.NPCs["10823"] = "Zul'Brin Entortagalho"
private.L.NPCs["10824"] = "Caça-morte Falcolança"
private.L.NPCs["10825"] = "Gish, o Impassível"
private.L.NPCs["10826"] = "Lorde Foicenegra"
private.L.NPCs["10827"] = "Morta-voz Selendre"
private.L.NPCs["10828"] = "Lynnia Abbendis"
private.L.NPCs["1106"] = "Cozinheiro dos Perdidos"
private.L.NPCs["1112"] = "Viúva Negra Sanguessuga"
private.L.NPCs["1119"] = "Martela-Espinha"
private.L.NPCs["1130"] = "Bjarn"
private.L.NPCs["1132"] = "Lenho"
private.L.NPCs["1137"] = "Edan, o Uivador"
private.L.NPCs["11383"] = "Alta-sacerdotisa Hai'watna"
private.L.NPCs["1140"] = "Matriarca Rasgaqueixo"
private.L.NPCs["11447"] = "Papagog"
private.L.NPCs["11467"] = "Tsu'zee"
private.L.NPCs["11497"] = "A Razia"
private.L.NPCs["11498"] = "Cikkatriz, o Alquebrado"
private.L.NPCs["11688"] = "Centauro Amaldiçoado"
private.L.NPCs["12037"] = "Ursol'lok"
private.L.NPCs["12237"] = "Meshloc, o Ceifador"
private.L.NPCs["12431"] = "Dilaceros"
private.L.NPCs["12433"] = "Krethis Umbrateia"
private.L.NPCs["1260"] = "Grande Pai Articos"
private.L.NPCs["12902"] = "Lorgus Jett"
private.L.NPCs["13896"] = "Barbescama"
private.L.NPCs["1398"] = "Chefe Galgosh"
private.L.NPCs["1399"] = "Magosh"
private.L.NPCs["14221"] = "Galvão Filmaeu"
private.L.NPCs["14222"] = "Araga"
private.L.NPCs["14223"] = "Benji Rabugento"
private.L.NPCs["14224"] = "7:XT"
private.L.NPCs["14225"] = "Príncipe Kellen"
private.L.NPCs["14226"] = "Kaskk"
private.L.NPCs["14227"] = "Ssibilak"
private.L.NPCs["14228"] = "Risadinha"
private.L.NPCs["14229"] = "Maledicente Lâmina Fugídia"
private.L.NPCs["14230"] = "Olho Gordo"
private.L.NPCs["14231"] = "Drogoth, o Errante"
private.L.NPCs["14232"] = "Dardo"
private.L.NPCs["14233"] = "Rancascame"
private.L.NPCs["14234"] = "Hayoc"
private.L.NPCs["14235"] = "A Podrisqueira"
private.L.NPCs["14236"] = "Senhor Pesqueiro"
private.L.NPCs["14237"] = "Vermelesga"
private.L.NPCs["1424"] = "Mestre Escavador"
private.L.NPCs["1425"] = "Kubb"
private.L.NPCs["14266"] = "Shanda, a Tecelã"
private.L.NPCs["14267"] = "Emogg, o Esmagador"
private.L.NPCs["14268"] = "Lorde Condar"
private.L.NPCs["14269"] = "Perscrutador Aqualon"
private.L.NPCs["14270"] = "Lulício"
private.L.NPCs["14271"] = "Quebra-costelas"
private.L.NPCs["14272"] = "Rosnaflama"
private.L.NPCs["14273"] = "Pedregoso"
private.L.NPCs["14275"] = "Tâmara Lançatroz"
private.L.NPCs["14276"] = "Rasguelra"
private.L.NPCs["14277"] = "Lady Zefris"
private.L.NPCs["14278"] = "Do'Late"
private.L.NPCs["14279"] = "Rastejatriz"
private.L.NPCs["14280"] = "Zé Comilão"
private.L.NPCs["14281"] = "Jimmy, o Sangrador"
private.L.NPCs["14339"] = "Uivo Mortífero"
private.L.NPCs["14340"] = "Alshirr Ruinálito"
private.L.NPCs["14342"] = "Patafúria"
private.L.NPCs["14343"] = "Olm, o Sábio"
private.L.NPCs["14344"] = "Mestiça"
private.L.NPCs["14345"] = "O Ongar"
private.L.NPCs["14424"] = "Lamedo"
private.L.NPCs["14425"] = "Roedosso"
private.L.NPCs["14426"] = "Harb Montanha Suja"
private.L.NPCs["14427"] = "Quiproquó"
private.L.NPCs["14428"] = "Uruson"
private.L.NPCs["14429"] = "Bocarranca"
private.L.NPCs["14430"] = "Espreitador do Crepúsculo"
private.L.NPCs["14431"] = "Fúria Shelda"
private.L.NPCs["14432"] = "Threggil"
private.L.NPCs["14433"] = "Lodogã"
private.L.NPCs["14445"] = "Capitão Serpeac"
private.L.NPCs["14446"] = "Pinato"
private.L.NPCs["14447"] = "Guelrrânio"
private.L.NPCs["14448"] = "Brotacardos"
private.L.NPCs["14471"] = "Setis"
private.L.NPCs["14472"] = "Gretheer"
private.L.NPCs["14473"] = "Lapress"
private.L.NPCs["14474"] = "Zora"
private.L.NPCs["14475"] = "Rex Ashil"
private.L.NPCs["14476"] = "Krellack"
private.L.NPCs["14477"] = "Larvator"
private.L.NPCs["14478"] = "Furacônio"
private.L.NPCs["14479"] = "Senhor do Crepúsculo Everun"
private.L.NPCs["14487"] = "Gluggl"
private.L.NPCs["14488"] = "Roloch"
private.L.NPCs["14490"] = "Razga"
private.L.NPCs["14491"] = "Kurmokk"
private.L.NPCs["14492"] = "Piadonix"
private.L.NPCs["1531"] = "Alma Perdida"
private.L.NPCs["1533"] = "Espírito Atormentado"
private.L.NPCs["1552"] = "Ventrescama"
private.L.NPCs["16179"] = "Hyakiss, a Tocaieira"
private.L.NPCs["16180"] = "Shadikith, o Planador"
private.L.NPCs["16181"] = "Rokad, o Assolador"
private.L.NPCs["16184"] = "Feitor Nerubiano"
private.L.NPCs["16854"] = "Eldinarcos"
private.L.NPCs["16855"] = "Tregla"
private.L.NPCs["17144"] = "Trincador"
private.L.NPCs["18241"] = "Siri Cascudo"
private.L.NPCs["1837"] = "Juiz Escarlate"
private.L.NPCs["1838"] = "Interrogador Escarlate"
private.L.NPCs["1839"] = "Alto-clérigo Escarlate"
private.L.NPCs["1841"] = "Carrasco Escarlate"
private.L.NPCs["1843"] = "Encarregado Jerris"
private.L.NPCs["1844"] = "Encarregado Marcrid"
private.L.NPCs["1847"] = "Crinapodre"
private.L.NPCs["1848"] = "Lorde Maldazzar"
private.L.NPCs["1849"] = "Murmuratroz"
private.L.NPCs["1850"] = "Putrídius"
private.L.NPCs["1851"] = "Cascabulho"
private.L.NPCs["18677"] = "Mekthorg, o Selvagem"
private.L.NPCs["18678"] = "Engole-tudo"
private.L.NPCs["18679"] = "Vorakem Voz-da-Ruína"
private.L.NPCs["18680"] = "Marticar"
private.L.NPCs["18681"] = "Emissária Presacurva"
private.L.NPCs["18682"] = "Tocaieiro do Brejo"
private.L.NPCs["18683"] = "Caçador Caótico Yar"
private.L.NPCs["18684"] = "Bro'Gaz, o sem Clã" -- Needs review
private.L.NPCs["18685"] = "Okrek"
private.L.NPCs["18686"] = "Agoureiro Jurim"
private.L.NPCs["18689"] = "Aleijador"
private.L.NPCs["18690"] = "Smagga"
private.L.NPCs["18692"] = "Hemathion"
private.L.NPCs["18693"] = "Orador Mar'grom"
private.L.NPCs["18694"] = "Collidus, o Observador Dimensional"
private.L.NPCs["18695"] = "Embaixador Jerrikar"
private.L.NPCs["18696"] = "Kraator"
private.L.NPCs["18697"] = "Engenheiro-chefe Lorthander"
private.L.NPCs["18698"] = "Perenúcleo, o Castigador"
private.L.NPCs["1885"] = "Ferreiro Escarlate"
private.L.NPCs["1910"] = "Muad"
private.L.NPCs["1911"] = "Díbi"
private.L.NPCs["1936"] = "Fazendeiro Solliden"
private.L.NPCs["2090"] = "Ma'ruk Serpescama"
private.L.NPCs["20932"] = "Nuramoc"
private.L.NPCs["2108"] = "Garneg Carbocrânio"
private.L.NPCs["2162"] = "Agal"
private.L.NPCs["2172"] = "Mamãe Moa da Floresta"
private.L.NPCs["21724"] = "Falcazar"
private.L.NPCs["2175"] = "Garrassombra"
private.L.NPCs["2184"] = "Lady Miralua"
private.L.NPCs["2186"] = "Carnivo, o Quebrador"
private.L.NPCs["2191"] = "Licillino"
private.L.NPCs["2192"] = "Arauto das Chamas Radison"
private.L.NPCs["22060"] = "Fenissa, a Assassina"
private.L.NPCs["22062"] = "Dr. Mirracorpo"
private.L.NPCs["2258"] = "Maggarrak"
private.L.NPCs["2452"] = "Scol"
private.L.NPCs["2453"] = "Lo'Grosh"
private.L.NPCs["2476"] = "Gosh-Haldir"
private.L.NPCs["2541"] = "Lorde Sakrasis"
private.L.NPCs["2598"] = "Darbel Montrose"
private.L.NPCs["2600"] = "Canora"
private.L.NPCs["2601"] = "Buchorrendo"
private.L.NPCs["2602"] = "Ruul Uma-pedra"
private.L.NPCs["2603"] = "Kovork"
private.L.NPCs["2604"] = "Molok, o Esmagador"
private.L.NPCs["2605"] = "Zalas Cascasseca"
private.L.NPCs["2606"] = "Nimar, o Matador"
private.L.NPCs["2609"] = "Geomante Adaga-de-sílex"
private.L.NPCs["2744"] = "Comandante de Umbraforja"
private.L.NPCs["2749"] = "Barricada"
private.L.NPCs["2751"] = "Golem de Guerra"
private.L.NPCs["2752"] = "Estrondor"
private.L.NPCs["2753"] = "Barnabus"
private.L.NPCs["2754"] = "Anátemus"
private.L.NPCs["2779"] = "Príncipe Nazjak"
private.L.NPCs["2850"] = "Dente Quebrado"
private.L.NPCs["2931"] = "Zaricotl"
private.L.NPCs["3058"] = "Arra'chea"
private.L.NPCs["3068"] = "Mazzranache"
private.L.NPCs["32357"] = "Velho Tronco Cristalino"
private.L.NPCs["32358"] = "Bolharrir Marchavento"
private.L.NPCs["32361"] = "Chifrígido"
private.L.NPCs["32377"] = "Ruginante, o Sanguinário"
private.L.NPCs["32386"] = "Vigdis, a Donzela Guerreira"
private.L.NPCs["32398"] = "Rei Pingoo"
private.L.NPCs["32400"] = "Tokemute"
private.L.NPCs["32409"] = "Sobrevivente Indu'le Enlouquecido"
private.L.NPCs["32417"] = "Grã-senhora Escarlate Daion"
private.L.NPCs["32422"] = "Grocklar"
private.L.NPCs["32429"] = "Ódio Calcinante"
private.L.NPCs["32435"] = "Vern"
private.L.NPCs["32438"] = "Syreian, a Entalha-ossos"
private.L.NPCs["32447"] = "Sentinela de Zul'Drak"
private.L.NPCs["32471"] = "Griegen"
private.L.NPCs["32475"] = "Tece-Terror"
private.L.NPCs["32481"] = "Aotona"
private.L.NPCs["32485"] = "Rei Mó"
private.L.NPCs["32487"] = "Putridus, o Ancestral"
private.L.NPCs["32491"] = "Protodraco do Tempo Perdido"
private.L.NPCs["32495"] = "Hildana Furta-morte"
private.L.NPCs["32500"] = "Dirkee"
private.L.NPCs["32501"] = "Grão-Thane Iorfus"
private.L.NPCs["32517"] = "Loque'nahak"
private.L.NPCs["3253"] = "Ceifador Silitídeo"
private.L.NPCs["32630"] = "Viragosa"
private.L.NPCs["3270"] = "Místico Ancião Cardafuça"
private.L.NPCs["3295"] = "Anomalia no Lodo"
private.L.NPCs["33776"] = "Gondria"
private.L.NPCs["3398"] = "Gesharahan"
private.L.NPCs["3470"] = "Rathorian"
private.L.NPCs["35189"] = "Skoll"
private.L.NPCs["3535"] = "Limonegro, o Fétido"
private.L.NPCs["3581"] = "Fera do Esgoto"
private.L.NPCs["3652"] = "Trígora, a Açoitadora"
private.L.NPCs["3672"] = "Jibohm"
private.L.NPCs["3735"] = "Boticário Fábio"
private.L.NPCs["3736"] = "Matador Mordenthal"
private.L.NPCs["3773"] = "Akkrilus"
private.L.NPCs["3792"] = "Senhor da Alcateia Terrorlupo"
private.L.NPCs["38453"] = "Arcturis"
private.L.NPCs["3872"] = "Capitão Devoto da Morte"
private.L.NPCs["39183"] = "Escórpitar"
private.L.NPCs["39185"] = "Babaqueixo"
private.L.NPCs["39186"] = "Fitaverno"
private.L.NPCs["4066"] = "Nal'taszar"
private.L.NPCs["4132"] = "Krkk'kx"
private.L.NPCs["4339"] = "Sulfúrio"
private.L.NPCs["43488"] = "Mordai, o Rasgaterra"
private.L.NPCs["43613"] = "Agoureiro Trilha Astuta"
private.L.NPCs["43720"] = "\"Cutuco\" Mantospinho"
private.L.NPCs["4380"] = "Viúva Névoa Negra"
private.L.NPCs["44224"] = "Dois-dedão"
private.L.NPCs["44225"] = "Rúbio Tironegro"
private.L.NPCs["44226"] = "Sarilodonte"
private.L.NPCs["44227"] = "Gazz, o Caçador do Lago"
private.L.NPCs["4425"] = "Caçador Cego"
private.L.NPCs["44714"] = "Fronkel, o Perturbado"
private.L.NPCs["44722"] = "Reflexão Distorcida de Narain"
private.L.NPCs["44750"] = "Califa Escorpicada"
private.L.NPCs["44759"] = "André Barbarruiva"
private.L.NPCs["44761"] = "Aquementas, o Desacorrentado"
private.L.NPCs["44767"] = "Occulus, o Corrompido"
private.L.NPCs["45257"] = "Mordak Dobranoite"
private.L.NPCs["45258"] = "Cássia Flavya, a Rainha Serpenteante"
private.L.NPCs["45260"] = "Folhanegra"
private.L.NPCs["45262"] = "Narixxus, o Arauto da Ruína"
private.L.NPCs["45369"] = "Morick Malzibirra"
private.L.NPCs["45380"] = "Caudagris"
private.L.NPCs["45384"] = "Patassábio"
private.L.NPCs["45398"] = "Grizlak"
private.L.NPCs["45399"] = "Optimo"
private.L.NPCs["45401"] = "Pinalva"
private.L.NPCs["45402"] = "Nix"
private.L.NPCs["45404"] = "Geoscultora Maren"
private.L.NPCs["45739"] = "O Soldado Desconhecido"
private.L.NPCs["45740"] = "Vigia Veloso"
private.L.NPCs["45771"] = "Marus"
private.L.NPCs["45785"] = "Abroba"
private.L.NPCs["45801"] = "Elisa"
private.L.NPCs["45811"] = "Marina DeSirrus"
private.L.NPCs["462"] = "Vultros"
private.L.NPCs["46981"] = "Vergasta"
private.L.NPCs["46992"] = "Bernardo, o Lunático"
private.L.NPCs["47003"] = "Bolgaff"
private.L.NPCs["47008"] = "Fernão Thatros"
private.L.NPCs["47009"] = "Aquarius, o Desatado"
private.L.NPCs["47010"] = "Índigos"
private.L.NPCs["47012"] = "Effritus"
private.L.NPCs["47015"] = "Filho Perdido de Arugal"
private.L.NPCs["47023"] = "Thule Corvinalle"
private.L.NPCs["471"] = "Mãe Veneno"
private.L.NPCs["472"] = "Comefuncho"
private.L.NPCs["47386"] = "Aniamiss, a Rainha da Colônia"
private.L.NPCs["47387"] = "Harakiss, o Infestador"
private.L.NPCs["4842"] = "Arauto da Terra Halmgar"
private.L.NPCs["49822"] = "Presajade" -- Needs review
private.L.NPCs["49913"] = "Lady La-La" -- Needs review
private.L.NPCs["50005"] = "[Poseidus]"
private.L.NPCs["50009"] = "Mobus"
private.L.NPCs["50050"] = "Shok'sharak"
private.L.NPCs["50051"] = "Rastejante Espectral" -- Needs review
private.L.NPCs["50052"] = "Burgy Cordisnero"
private.L.NPCs["50053"] = "Thartuk, o Exilado"
private.L.NPCs["50056"] = "Garr" -- Needs review
private.L.NPCs["50057"] = "Chaminasa"
private.L.NPCs["50058"] = "Terrortuga"
private.L.NPCs["50059"] = "Golgarok" -- Needs review
private.L.NPCs["50060"] = "Terborus" -- Needs review
private.L.NPCs["50061"] = "Xariona" -- Needs review
private.L.NPCs["50062"] = "Aeonaxx" -- Needs review
private.L.NPCs["50063"] = "Akma'hat" -- Needs review
private.L.NPCs["50064"] = "Cyrus, o Negro"
private.L.NPCs["50065"] = "Tatudumal"
private.L.NPCs["50085"] = "Lorde Supremo Furicorte"
private.L.NPCs["50086"] = "Tarvus, o Torpe"
private.L.NPCs["50089"] = "Julak-Doom" -- Needs review
private.L.NPCs["50138"] = "Karoma" -- Needs review
private.L.NPCs["50154"] = "Madexx" -- Needs review
private.L.NPCs["50159"] = "Simbas"
private.L.NPCs["50328"] = "Fangora"
private.L.NPCs["50329"] = "Rrakk"
private.L.NPCs["50330"] = "Kree"
private.L.NPCs["50331"] = "Go-Kan"
private.L.NPCs["50332"] = "Korda Torros"
private.L.NPCs["50333"] = "Lon, o Touro"
private.L.NPCs["50334"] = "Dak, o Quebrador"
private.L.NPCs["50335"] = "Uíscas"
private.L.NPCs["50336"] = "Yorik Vistaboa"
private.L.NPCs["50337"] = "Gárgala"
private.L.NPCs["50338"] = "Kor'nas Noite Preta"
private.L.NPCs["50339"] = "Sulik'shor"
private.L.NPCs["50340"] = "Gaarn, o Tóxico"
private.L.NPCs["50341"] = "Borginn Punho Negro"
private.L.NPCs["50342"] = "Heronis"
private.L.NPCs["50343"] = "Quall"
private.L.NPCs["50344"] = "Norlaxx"
private.L.NPCs["50345"] = "Alit"
private.L.NPCs["50346"] = "Ronak"
private.L.NPCs["50347"] = "Karr, o Obscurecente"
private.L.NPCs["50348"] = "Norissis"
private.L.NPCs["50349"] = "Kang, o Ladrão de Almas"
private.L.NPCs["50350"] = "Morgrinn Rachapresa"
private.L.NPCs["50351"] = "Jonn-Dar"
private.L.NPCs["50352"] = "Qa'nas"
private.L.NPCs["50353"] = "Manas"
private.L.NPCs["50354"] = "Havak"
private.L.NPCs["50355"] = "Kah'tir"
private.L.NPCs["50356"] = "Krol, a Lâmina"
private.L.NPCs["50357"] = "Asassol"
private.L.NPCs["50358"] = "Constructo Fendessol Enlouquecido"
private.L.NPCs["50359"] = "Urgolax"
private.L.NPCs["50361"] = "Ornat"
private.L.NPCs["50362"] = "Charcabreu"
private.L.NPCs["50363"] = "Krax'ik"
private.L.NPCs["50364"] = "Nal'lak, o Estripador"
private.L.NPCs["50370"] = "Carapax"
private.L.NPCs["50388"] = "Torik-Ethis"
private.L.NPCs["50409"] = "Estátua de Camelo Misteriosa"
private.L.NPCs["506"] = "Sargento Garrafina"
private.L.NPCs["507"] = "Fenros"
private.L.NPCs["50724"] = "Naracna"
private.L.NPCs["50725"] = "Azelisk"
private.L.NPCs["50726"] = "Kalixx"
private.L.NPCs["50727"] = "Strix, o Farpado"
private.L.NPCs["50728"] = "Golpe da Morte"
private.L.NPCs["50730"] = "Envenenas"
private.L.NPCs["50731"] = "Perfúria"
private.L.NPCs["50733"] = "Ski'thik"
private.L.NPCs["50734"] = "Lith'ik, o Espreitador"
private.L.NPCs["50735"] = "Guizante"
private.L.NPCs["50737"] = "Acroniss"
private.L.NPCs["50738"] = "Brilhescama"
private.L.NPCs["50739"] = "Gar'lok"
private.L.NPCs["50741"] = "Kaxx"
private.L.NPCs["50742"] = "Chem"
private.L.NPCs["50743"] = "Manax"
private.L.NPCs["50744"] = "Qu'rik"
private.L.NPCs["50745"] = "Losaj"
private.L.NPCs["50746"] = "Bornix, o Escavador"
private.L.NPCs["50747"] = "Tix"
private.L.NPCs["50748"] = "Nyaj"
private.L.NPCs["50749"] = "Kal'tik, a Praga"
private.L.NPCs["50750"] = "Aethis"
private.L.NPCs["50752"] = "Tarantis"
private.L.NPCs["50759"] = "Iriss, a Viúva"
private.L.NPCs["50763"] = "Assombrante"
private.L.NPCs["50764"] = "Paraliss"
private.L.NPCs["50765"] = "Miasmiss"
private.L.NPCs["50766"] = "Sele'na"
private.L.NPCs["50768"] = "Andáguas Cournith"
private.L.NPCs["50769"] = "Zai, o Pária"
private.L.NPCs["50770"] = "Zorn"
private.L.NPCs["50772"] = "Eshelon"
private.L.NPCs["50775"] = "Likk, o Caçador"
private.L.NPCs["50776"] = "Nalash Verdantis"
private.L.NPCs["50777"] = "Agulha"
private.L.NPCs["50778"] = "Ferroteia"
private.L.NPCs["50779"] = "Bátima"
private.L.NPCs["50780"] = "Sahn Caçador de Maré"
private.L.NPCs["50782"] = "Sarnak"
private.L.NPCs["50783"] = "Salyin Batedor da Guerra"
private.L.NPCs["50784"] = "Anith"
private.L.NPCs["50785"] = "Caelumbra"
private.L.NPCs["50786"] = "Fagulhasa"
private.L.NPCs["50787"] = "Arness, a Balança"
private.L.NPCs["50788"] = "Quetzl"
private.L.NPCs["50789"] = "Nessos, o Oráculo"
private.L.NPCs["50790"] = "Ionis"
private.L.NPCs["50791"] = "Siltriss, o Afiador"
private.L.NPCs["50792"] = "Chiaa"
private.L.NPCs["50797"] = "Yukiko"
private.L.NPCs["50803"] = "Mascaosso"
private.L.NPCs["50804"] = "Rasgasa"
private.L.NPCs["50805"] = "Omnis Grinlok"
private.L.NPCs["50806"] = "Moldo Caolho"
private.L.NPCs["50807"] = "Catal"
private.L.NPCs["50808"] = "Urobi, o Andarilho"
private.L.NPCs["50809"] = "Menga"
private.L.NPCs["50810"] = "Favorito de Isiset"
private.L.NPCs["50811"] = "Nasra Pintalgas"
private.L.NPCs["50812"] = "Arae"
private.L.NPCs["50813"] = "Fene-mal"
private.L.NPCs["50814"] = "Comecorpos"
private.L.NPCs["50815"] = "Skarr" -- Needs review
private.L.NPCs["50816"] = "Ruun Patalmas"
private.L.NPCs["50817"] = "Ahone, o Errante"
private.L.NPCs["50818"] = "O Predador Sombrio"
private.L.NPCs["50819"] = "Garrálgido"
private.L.NPCs["50820"] = "Yul Garragreste"
private.L.NPCs["50821"] = "Ai-Li Espelho do Céu"
private.L.NPCs["50822"] = "Ai-Ran, a Nuvem que Passa"
private.L.NPCs["50823"] = "Mestre Feroz"
private.L.NPCs["50825"] = "Feras"
private.L.NPCs["50828"] = "Bonobos"
private.L.NPCs["50830"] = "Gálion"
private.L.NPCs["50831"] = "Kossa"
private.L.NPCs["50832"] = "O Berrante"
private.L.NPCs["50833"] = "Courescuro"
private.L.NPCs["50836"] = "Ik-Ik, o Ligeiro"
private.L.NPCs["50837"] = "Kash"
private.L.NPCs["50838"] = "Tabbs"
private.L.NPCs["50839"] = "Cão Cromado"
private.L.NPCs["50840"] = "Major Nananina"
private.L.NPCs["50842"] = "Magmadan"
private.L.NPCs["50846"] = "Babagorja"
private.L.NPCs["50855"] = "Jaxx Raivoso"
private.L.NPCs["50856"] = "Snark"
private.L.NPCs["50858"] = "Asapó"
private.L.NPCs["50864"] = "Estígia"
private.L.NPCs["50865"] = "Saurix"
private.L.NPCs["50874"] = "Tenok"
private.L.NPCs["50875"] = "Nychus"
private.L.NPCs["50876"] = "Avis"
private.L.NPCs["50882"] = "Chupacabras"
private.L.NPCs["50884"] = "Levanta-poeira, o Covarde"
private.L.NPCs["50886"] = "Asamar"
private.L.NPCs["50891"] = "Boros"
private.L.NPCs["50892"] = "Cyn"
private.L.NPCs["50895"] = "Volux"
private.L.NPCs["50897"] = "Fexik, o Espreitador das Dunas"
private.L.NPCs["50901"] = "Teromak"
private.L.NPCs["50903"] = "Orlix, o Senhor do Pântano"
private.L.NPCs["50905"] = "Matante"
private.L.NPCs["50906"] = "Mutilax"
private.L.NPCs["50908"] = "Uivo Noturno"
private.L.NPCs["50915"] = "Bufa"
private.L.NPCs["50916"] = "Aleijão, o Lamuriento"
private.L.NPCs["50922"] = "Warg"
private.L.NPCs["50925"] = "Patada"
private.L.NPCs["50926"] = "Ben Grisalho"
private.L.NPCs["50929"] = "Pequeno Bjorn"
private.L.NPCs["50930"] = "Hibernus, o Adormecido"
private.L.NPCs["50931"] = "Sarna"
private.L.NPCs["50937"] = "Porcouro"
private.L.NPCs["50940"] = "Swee"
private.L.NPCs["50942"] = "Roto Rúter"
private.L.NPCs["50945"] = "Kaska"
private.L.NPCs["50946"] = "Porcozilla"
private.L.NPCs["50947"] = "Uira Puru"
private.L.NPCs["50948"] = "Lomboduro"
private.L.NPCs["50949"] = "Gambito do Finn"
private.L.NPCs["50952"] = "João Conchão"
private.L.NPCs["50955"] = "Carcinak"
private.L.NPCs["50957"] = "Garrão"
private.L.NPCs["50959"] = "Karkin" -- Needs review
private.L.NPCs["50964"] = "Kortz"
private.L.NPCs["50967"] = "Nopapo, o Assolador"
private.L.NPCs["50986"] = "Cernelha Dourada"
private.L.NPCs["50993"] = "Gal'dorak"
private.L.NPCs["50995"] = "Bordoeiro"
private.L.NPCs["50997"] = "Bornak, o Lacerante"
private.L.NPCs["51000"] = "Cascabreu, o Impenetrável"
private.L.NPCs["51001"] = "Garra de Peçonha"
private.L.NPCs["51002"] = "Escorpoxx"
private.L.NPCs["51004"] = "Toxx"
private.L.NPCs["51007"] = "Serkett"
private.L.NPCs["51008"] = "O Terror Farpado"
private.L.NPCs["51010"] = "Picada"
private.L.NPCs["51014"] = "Duracasca"
private.L.NPCs["51017"] = "Ferrante"
private.L.NPCs["51018"] = "Zormus"
private.L.NPCs["51021"] = "Vórticos"
private.L.NPCs["51022"] = "Córdix"
private.L.NPCs["51025"] = "Dilennaa"
private.L.NPCs["51026"] = "Gnath"
private.L.NPCs["51027"] = "Agúlica"
private.L.NPCs["51028"] = "O Escavador do Abismo"
private.L.NPCs["51029"] = "Parasitus"
private.L.NPCs["51031"] = "Farejador"
private.L.NPCs["51037"] = "Cão de Guerra Guilneano Perdido"
private.L.NPCs["51040"] = "Buffo"
private.L.NPCs["51042"] = "Cordúmbria"
private.L.NPCs["51044"] = "Peste"
private.L.NPCs["51045"] = "Arcanus"
private.L.NPCs["51046"] = "Fidonis"
private.L.NPCs["51048"] = "Rexxus"
private.L.NPCs["51052"] = "Gib, o Guardador de Bananas"
private.L.NPCs["51053"] = "Quirix"
private.L.NPCs["51057"] = "Bezorra"
private.L.NPCs["51058"] = "Aphis"
private.L.NPCs["51059"] = "Yaungol Nível 2"
private.L.NPCs["51061"] = "Roth-Salam"
private.L.NPCs["51062"] = "Khep-Re"
private.L.NPCs["51063"] = "Phalanax"
private.L.NPCs["51066"] = "Prezacristal"
private.L.NPCs["51067"] = "Brílio"
private.L.NPCs["51069"] = "Cintillex"
private.L.NPCs["51071"] = "Capitão Florêncio"
private.L.NPCs["51076"] = "Lupicínio"
private.L.NPCs["51077"] = "Felpas"
private.L.NPCs["51078"] = "Ferdinando"
private.L.NPCs["51079"] = "Capitão Ventoruim"
private.L.NPCs["51401"] = "Madexx"
private.L.NPCs["51402"] = "Madexx"
private.L.NPCs["51403"] = "Madexx"
private.L.NPCs["51404"] = "Madexx"
private.L.NPCs["51658"] = "Mogh, o Morto"
private.L.NPCs["51661"] = "Tsul'kalu"
private.L.NPCs["51662"] = "Mahamba"
private.L.NPCs["51663"] = "Pogeyan"
private.L.NPCs["519"] = "Raso"
private.L.NPCs["520"] = "Leso"
private.L.NPCs["521"] = "Lupos"
private.L.NPCs["52146"] = "Tremida"
private.L.NPCs["534"] = "Nefaru"
private.L.NPCs["5343"] = "Lady Szallah"
private.L.NPCs["5345"] = "Cabeça de Diamante"
private.L.NPCs["5346"] = "Rugessangue, o Espreitador"
private.L.NPCs["5347"] = "Antilus, que Voa Alto"
private.L.NPCs["5348"] = "Forquilíngua Velassonhos"
private.L.NPCs["5349"] = "Arash-ethis"
private.L.NPCs["5350"] = "Qirot"
private.L.NPCs["5352"] = "Velho Pançagris"
private.L.NPCs["5354"] = "Rosno Frondefráter"
private.L.NPCs["5356"] = "Rosnador"
private.L.NPCs["54318"] = "Ankha" -- Needs review
private.L.NPCs["54319"] = "Magria" -- Needs review
private.L.NPCs["54320"] = "Ban'thalos" -- Needs review
private.L.NPCs["54321"] = "Solix" -- Needs review
private.L.NPCs["54322"] = "Deth'tilac" -- Needs review
private.L.NPCs["54323"] = "Kirix" -- Needs review
private.L.NPCs["54324"] = "Rastejante das Chamas"
private.L.NPCs["54338"] = "Anthriss" -- Needs review
private.L.NPCs["54533"] = "Príncipe Lakma"
private.L.NPCs["56081"] = "Benji Otimista"
private.L.NPCs["572"] = "Leprithus"
private.L.NPCs["573"] = "Ceifador de Inimigos 4000"
private.L.NPCs["574"] = "Naraxis"
private.L.NPCs["5785"] = "Irmã Raivergasta"
private.L.NPCs["5786"] = "Lança Infame"
private.L.NPCs["5787"] = "Impositor Emilgund"
private.L.NPCs["5807"] = "O Estraçalhador"
private.L.NPCs["5809"] = "Sargento Carlos"
private.L.NPCs["5822"] = "Tecevil Dezzprezo"
private.L.NPCs["5823"] = "Açoita-morte"
private.L.NPCs["5824"] = "Capitão Presa Chata"
private.L.NPCs["5826"] = "Geolorde Mosqueado"
private.L.NPCs["5828"] = "Humar, o Senhor dos Leões"
private.L.NPCs["5829"] = "Roncão, o Importuno"
private.L.NPCs["5830"] = "Irmã Rathalon"
private.L.NPCs["5831"] = "Crinaveloz"
private.L.NPCs["5832"] = "Atroadonte"
-- private.L.NPCs["58336"] = "Darkmoon Rabbit"
private.L.NPCs["5834"] = "Azzere, o Cortacéu"
private.L.NPCs["5835"] = "Feitor Grelha"
private.L.NPCs["5836"] = "Engenheiro Revestrés"
private.L.NPCs["5837"] = "Braço-de-pedra"
private.L.NPCs["5838"] = "Lança-partida"
private.L.NPCs["584"] = "Kazon"
private.L.NPCs["5841"] = "Lança-de-rocha"
private.L.NPCs["5842"] = "Takk, o Saltador"
private.L.NPCs["5847"] = "Heggin Barbapedra"
private.L.NPCs["58474"] = "Matriarca Aguilhão Sangrento"
private.L.NPCs["5848"] = "Malgin Cervevada"
private.L.NPCs["5849"] = "Cavador Forjaflama"
private.L.NPCs["5851"] = "Capitão Gerogg Pé-de-malho"
private.L.NPCs["5859"] = "Hagg Quebra-tauren"
private.L.NPCs["5863"] = "Geo-sacerdote Gukk'rok"
private.L.NPCs["5864"] = "Porcino Couriço"
private.L.NPCs["5865"] = "Dishu"
private.L.NPCs["58768"] = "Estaladonte"
private.L.NPCs["58769"] = "Boca-de-alicate"
private.L.NPCs["58771"] = "Quid"
private.L.NPCs["58778"] = "Aetha"
private.L.NPCs["58817"] = "Espírito de Lao-Fe"
private.L.NPCs["58949"] = "Bai-Jin, o Carniceiro"
private.L.NPCs["5912"] = "Dragoleta Anormal"
private.L.NPCs["5915"] = "Irmão Corvalho"
private.L.NPCs["5928"] = "Pesarasa"
private.L.NPCs["5930"] = "Irmã Rasga"
private.L.NPCs["5932"] = "Capataz Presaçoite"
private.L.NPCs["5933"] = "Achellios, o Banido"
private.L.NPCs["5935"] = "Olho-de-ferro, o Invencível"
private.L.NPCs["59369"] = "Doutor Theolen Krastinov"
private.L.NPCs["5937"] = "Torpicada"
private.L.NPCs["596"] = "Nobre Reprogramado"
private.L.NPCs["599"] = "Marisa du'Paige"
private.L.NPCs["60491"] = "Sha da Raiva" -- Needs review
private.L.NPCs["61"] = "Turos Mão-leve"
private.L.NPCs["6118"] = "Fantasma de Varo'then"
private.L.NPCs["616"] = "Palpos"
private.L.NPCs["62"] = "Guga Velagorda"
private.L.NPCs["6228"] = "Embaixador Ferro Negro"
private.L.NPCs["62346"] = "Gailleon" -- Needs review
private.L.NPCs["62880"] = "Gochao, o Punho de Ferro"
private.L.NPCs["62881"] = "Gaohun, o Corta-almas"
private.L.NPCs["63101"] = "General Temuja"
private.L.NPCs["63240"] = "Mestre Sombrio Sydow"
private.L.NPCs["63510"] = "Wulon"
private.L.NPCs["63691"] = "Huo-Shuang"
private.L.NPCs["63695"] = "Baolai, o Imolador"
private.L.NPCs["63977"] = "Vyraxxis"
private.L.NPCs["63978"] = "Kri'chon"
private.L.NPCs["64403"] = "Alani" -- Needs review
private.L.NPCs["6581"] = "Matriarca Ravassauro"
private.L.NPCs["6582"] = "Mamãe Zavas"
private.L.NPCs["6583"] = "Grufo"
private.L.NPCs["6584"] = "Rei Mosh"
private.L.NPCs["6585"] = "Uhk'loc"
private.L.NPCs["6648"] = "Antilos"
private.L.NPCs["6649"] = "Lady Sesspira"
private.L.NPCs["6650"] = "General Presaferror"
private.L.NPCs["6651"] = "Guarda-pórtico Rugifúria"
private.L.NPCs["68317"] = "Mavis Prejuz"
private.L.NPCs["68318"] = "Dalan Rompenoite"
private.L.NPCs["68319"] = "Disha Fazmedrar"
private.L.NPCs["68320"] = "Ubunti, o Vulto"
private.L.NPCs["68321"] = "Kar Belikoz"
private.L.NPCs["68322"] = "Muerta"
-- private.L.NPCs["69099"] = "Nalak"
private.L.NPCs["69664"] = "Mumta"
private.L.NPCs["69768"] = "Batedor da Guerra Zandalari"
private.L.NPCs["69769"] = "Armipotente Zandalari"
private.L.NPCs["69841"] = "Armipotente Zandalari"
private.L.NPCs["69842"] = "Armipotente Zandalari"
private.L.NPCs["69843"] = "Zao'cho"
private.L.NPCs["69996"] = "Ku'lai, a Garra dos Céus"
private.L.NPCs["69997"] = "Primogenitus"
private.L.NPCs["69998"] = "Goda"
private.L.NPCs["69999"] = "Deus-bruto Ramuk"
private.L.NPCs["70000"] = "Al'tabim, que Tudo Vê"
private.L.NPCs["70001"] = "Quebradorso Uru"
private.L.NPCs["70002"] = "Lu-Ban"
private.L.NPCs["70003"] = "Molthor"
private.L.NPCs["70096"] = "Deus da Guerra Dokah"
private.L.NPCs["70126"] = "Willy Wilder"
private.L.NPCs["7015"] = "Gorgulho, o Cruel"
private.L.NPCs["7016"] = "Lady Vespira"
private.L.NPCs["7017"] = "Lorde Iniquicida"
private.L.NPCs["70238"] = "Olho Sempre Aberto"
private.L.NPCs["70243"] = "Arquirritualista Kelada"
private.L.NPCs["70249"] = "Olho Focado"
private.L.NPCs["70276"] = "No'kah Manda-procela"
private.L.NPCs["70323"] = "Krakkanon"
private.L.NPCs["70430"] = "Horror de Pedra"
private.L.NPCs["70440"] = "Monara"
private.L.NPCs["70530"] = "Ra'sha"
private.L.NPCs["7104"] = "Áridus"
private.L.NPCs["7137"] = "Immolatus"
private.L.NPCs["71864"] = "Spelurk"
private.L.NPCs["71919"] = "Zhu-Gon, o Azedo"
-- private.L.NPCs["71992"] = "Moonfang"
private.L.NPCs["72045"] = "Chelon"
private.L.NPCs["72048"] = "Chiadeira"
private.L.NPCs["72049"] = "Mastigarça"
private.L.NPCs["72193"] = "Karkanos"
private.L.NPCs["72245"] = "Zesqua"
private.L.NPCs["72769"] = "Espírito de Flamejade"
private.L.NPCs["72775"] = "Bufo"
private.L.NPCs["72808"] = "Tsavo'ka"
private.L.NPCs["72909"] = "Gu'chi, o Arauto do Enxame"
private.L.NPCs["72970"] = "Golganarr"
private.L.NPCs["73157"] = "Musgo Rochoso"
private.L.NPCs["73158"] = "Ganso Esmeralda"
private.L.NPCs["73160"] = "Chifreaço Veloférreo"
private.L.NPCs["73161"] = "Grande Tartaruga Cascofúria"
private.L.NPCs["73163"] = "Píton Imperial"
private.L.NPCs["73166"] = "Garrespinha Monstruoso"
private.L.NPCs["73167"] = "Huolon"
private.L.NPCs["73169"] = "Jakur de Ordon"
private.L.NPCs["73170"] = "Vigia Osu"
private.L.NPCs["73171"] = "Campeão da Chama Negra"
private.L.NPCs["73172"] = "Gairan, o Senhor da Centelha"
private.L.NPCs["73173"] = "Urdur, o Cauterizador"
private.L.NPCs["73174"] = "Bispo das Chamas"
private.L.NPCs["73175"] = "Chuva de Cinzas"
private.L.NPCs["73277"] = "Remenda-folhas"
private.L.NPCs["73279"] = "Bocarra"
private.L.NPCs["73281"] = "Navio Fantasma Vazúvio"
private.L.NPCs["73282"] = "Garnia"
private.L.NPCs["73293"] = "Whizzig"
private.L.NPCs["73666"] = "Bispo das Chamas"
private.L.NPCs["73704"] = "Trança-fétida"
private.L.NPCs["763"] = "Chefe dos Perdidos"
private.L.NPCs["7846"] = "Teremus, o Devorador"
private.L.NPCs["79"] = "Narg, o Capataz"
private.L.NPCs["8199"] = "Líder Guerreiro Krazzilak"
private.L.NPCs["8200"] = "Jin'Zallah, o Arauto da Areia"
private.L.NPCs["8201"] = "Omgorn, o Perdido"
private.L.NPCs["8203"] = "Kregg Khaldus"
private.L.NPCs["8204"] = "Soriid, o Devorador"
private.L.NPCs["8205"] = "Haarka, o Voraz"
private.L.NPCs["8207"] = "Brasalado"
private.L.NPCs["8210"] = "Garravalha"
private.L.NPCs["8211"] = "Velho Pula-penhasco"
private.L.NPCs["8212"] = "A Fedegosa"
private.L.NPCs["8213"] = "Cascaférrea"
private.L.NPCs["8214"] = "Jalinde Dracoestio"
private.L.NPCs["8215"] = "Grandônum"
private.L.NPCs["8216"] = "Retherokk, o Berserker"
private.L.NPCs["8217"] = "Mith'rethis, o Encantador"
private.L.NPCs["8218"] = "[Witherheart the Stalker]"
private.L.NPCs["8219"] = "Zul'arek Odiento"
private.L.NPCs["8277"] = "Rekk'tilac"
private.L.NPCs["8278"] = "Fervar"
private.L.NPCs["8279"] = "Golem de Guerra Defeituoso"
private.L.NPCs["8280"] = "Shleipnarr"
private.L.NPCs["8281"] = "Escaldo"
private.L.NPCs["8282"] = "Grão-lorde Hastragand"
private.L.NPCs["8283"] = "Senhor de Escravos Cordisnero"
private.L.NPCs["8296"] = "Mojo, o Pervertido"
private.L.NPCs["8297"] = "Magronos, o Inflexível"
private.L.NPCs["8298"] = "Akubar, o Vidente"
private.L.NPCs["8299"] = "Láquila"
private.L.NPCs["8300"] = "Rasgarga"
private.L.NPCs["8301"] = "Clack, o Aniquilador"
private.L.NPCs["8302"] = "Olho da Morte"
private.L.NPCs["8303"] = "Grunhido"
private.L.NPCs["8304"] = "Skárnio"
private.L.NPCs["8503"] = "Gibblewilt"
private.L.NPCs["8660"] = "Malifatius"
private.L.NPCs["8923"] = "Panzor, o Invencível"
private.L.NPCs["8924"] = "O Beemote"
private.L.NPCs["8976"] = "Hematos"
private.L.NPCs["8978"] = "Thauris Balgarr"
private.L.NPCs["8979"] = "Gruklash"
private.L.NPCs["8981"] = "Aniquilador Defeituoso"
private.L.NPCs["9217"] = "Mestre Mago Agulhapétrea"
private.L.NPCs["9218"] = "Senhor da Batalha Agulhapétrea"
private.L.NPCs["9219"] = "Carniceiro Agulhapétrea"
private.L.NPCs["947"] = "Rohh, o Taciturno"
private.L.NPCs["9596"] = "Bannok Sinistracha"
private.L.NPCs["9602"] = "Hahk'Zor"
private.L.NPCs["9604"] = "Gorgon'och"
private.L.NPCs["9718"] = "Ghok Surrabem"
private.L.NPCs["9736"] = "Intendente Zigris"
private.L.NPCs["99"] = "Morgana, a Dissimulada"

-- private.L["BUTTON_TOOLTIP_LINE1"] = "|cffffee00 NPCScan.Overlay|r"
-- private.L["BUTTON_TOOLTIP_LINE2"] = "Toggle World Map paths"
-- private.L["BUTTON_TOOLTIP_LINE3"] = "Toggle World Map key"
-- private.L["BUTTON_TOOLTIP_LINE4"] = "Toggle Mini Map paths"
-- private.L["BUTTON_TOOLTIP_LINE5"] = "Toggle display of Mini and World Map paths"
-- private.L["BUTTON_TOOLTIP_LINE6"] = "Open Options Menu"
private.L["CONFIG_ALPHA"] = "Alfa"
-- private.L["CONFIG_COLORLIST_INST"] = "Click on mob title to choose its color."
-- private.L["CONFIG_COLORLIST_LABEL"] = "Overlay Path Color Table"
-- private.L["CONFIG_COLORLIST_PLACEHOLDER"] = "Key Mob "
private.L["CONFIG_DESC"] = "Controla qual mapas mostrarão sobreposição do caminho de unidades. A maioria dos addons que modifica mapas são controlados com a opção de Mapa Mundi."
-- private.L["CONFIG_LOCKSWAP"] = "Swap Mob Key Movement Controls"
-- private.L["CONFIG_LOCKSWAP_DESC"] = "Sets the  mob key to move on mouse over and holding <Shift> to prevent movement."
-- private.L["CONFIG_SETCOLOR"] = "Set Path Colors"
-- private.L["CONFIG_SETCOLOR_DESC"] = "Click to set Map Key & Path Colors."
private.L["CONFIG_SHOWALL"] = "Sempre mostrar todos os caminhos"
private.L["CONFIG_SHOWALL_DESC"] = "Normalmente, quando uma unidade não está sendo buscada, seu caminho é tirado do mapa. Habilite esta opção para sempre mostrar todas as rotas conhecidas."
-- private.L["CONFIG_SHOWKEY"] = "Show Mob Key on Map"
-- private.L["CONFIG_SHOWKEY_DESC"] = "Toggles the displaying of the mob key on the world map."
private.L["CONFIG_TITLE"] = "Sobreposição"
private.L["CONFIG_TITLE_STANDALONE"] = "_|cffCCCC88NPCScan|r.Overlay (Sobreposição)"
private.L["MODULE_ALPHAMAP3"] = "AddOn AlphaMap3"
private.L["MODULE_BATTLEFIELDMINIMAP"] = "Mapa de Batalha"
private.L["MODULE_MINIMAP"] = "Mini Mapa"
-- private.L["MODULE_OMEGAMAP"] = "OmegaMap AddOn"
private.L["MODULE_RANGERING_DESC"] = "Nota: O anel de distância só aparece em zonas com buscas por unidades raras."
private.L["MODULE_RANGERING_FORMAT"] = "Mostrar anel de %d jardas para distância de detecção aproximada."
private.L["MODULE_WORLDMAP"] = "Mapa Mundi"
private.L["MODULE_WORLDMAP_KEY_FORMAT"] = "• %s"
-- private.L["MODULE_WORLDMAP_KEYTOGGLE"] = "Toggle Mob Path Key"
-- private.L["MODULE_WORLDMAP_KEYTOGGLE_DESC"] = "Toggle Path Key."
private.L["MODULE_WORLDMAP_TOGGLE"] = "PNJs"
private.L["MODULE_WORLDMAP_TOGGLE_DESC"] = "Habilita/Desabilita a sobreposição de caminhos do _|cffCCCC88NPCScan|r.Overlay para os PNJs procurados."

