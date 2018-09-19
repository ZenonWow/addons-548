(with thanks to Nicola L. for the translation)

Informazioni Generali
------------------------

MozzFullWorldMap Ã¨ di uso molto semplice : aggiunge una nuova casella di spunta in alto a sinistra sulla mappa del mondo denominato 'Mostra Aree Non Esplorate'.
Spuntare la casella farÃ  solo questo... rendere le aree non ancora esplorate nella mappa visibili. Questo AddOn aggiunge anche una sezione "MozzFullWorldMap" alla finestra di opzioni dell'interfaccia (Interfaccia -> AddOns - premi 'esc' e seleziona il tab "AddOns"), che puoi usare per selezionare le opzioni e i colori di MFWM (leggi le note piÃ¹ sotto)

Scegliere le opzioni di default comporta che le aree non esplorate appaiono con una tinta blu/verde. Credo che questa opzione sia la piÃ¹ utile, il che vuol dire che puoi vedere tutti i dettagli della mappa, mentre sei ancora in grado di identificare quali aree non hai ancora esplorato. Puoi cambiare il comportamento dell'AddOn attraverso i comandi da console spiegati in dettaglio piÃ¹ sotto, e rimuovere la tinta blu completamente, lasciandoti una vista standard di ogni mappa come se avessi esplorato ogni area.

Sono disponibili assegnazioni di tasti per gli utenti di AlphaMap / Cartographer / MetaMap

(NOTA: L'assegnazione tasti Ã¨ disabilitata mentre Ã¨ aperto la Mappa del Mondo - a meno che la Mappa non sia stata modificata da un altro addon come ad esempio AlphaMap)

MFWM Ã¨ compatibile con:

    WorldMapFrame
    AlphaMap
    MetaMap (faresti bene a disabilitare MetaMapFWM se stai usando questo AddOn)
    Cartographer (faresti bene a disabilitare Foglight se stai usando questo AddOn)
    nUI5
    Questo AddOn Ã¨ integrato direttamente all'interno di nUI6 e non c'Ã¨ bisogno (o non dovrebbe essercene) di installarlo separatamente quando usi nUI6.

MFWM usa uno strato di dati sovrapposto e non modificabile che duplica i dati disponibili nel client. Dato che interroga anche il client per capire quali strati sono stati scoperti (dovrebbe essere 100%) individuerÃ  discrepanze nei dati del client, e registrerÃ  ogni dato errato o non presente in un tabella chiamata 'Saved Errata'. Se hai dei dati errati salvati, stamperÃ  un messaggio a schermo al login con le istruzioni su come inviare i dati errati all'autore cosÃ¬ che possano essere aggiunti alla distribuzione, oppure puoi aggiungere i dati errati alla tua copia personale. Non hai altro da fare... MFWM fonderÃ  automaticamente i dati errati con quelli memorizzati, affinchÃ© tutti i tuoi personaggi beneficino da ciÃ² senza fare altro.

Originariamente scritto da Mozz, aggiornato da Shub e poi da Telic, e infine riscritto e attualmente tenuto operativo da K. Scott Piel (spiel2001).

Supporto Tecnico
----------------------

Se hai problemi con MozzFullWorldMap, sia che ti piacerebbe dare un suggerimento, sia che voglia inviare dati errati, o segnalare un bug, per favore visita http://forums.nUIaddon.com -- se non hai giÃ  un account su WoWInterface, puoi crearne uno gratis. Tieni presente che WoWI ti manderÃ  una email con un link che dovrai cliccare per confermare il tuo indirizzo email, prima che tu possa iniziare a inviare post al forum. Se non vedi questo messaggio, per favore controlla la casella dello spam.

Una volta ottenuto l'account su WoWInterface.com, e dopo aver verificato il tuo indirizzo email, troverai un topic specifico per il supporto di MFWM puntando a http://forums.nUIaddon.com. Tutti i feedback, i suggerimenti, segnalazione bug, e invio di dati errati sono sempre benvenuti. Troverai anche una grande comunitÃ  di utenti nUI e MWWM in questi forum, che saranno sempre felici di aiutarti, anche se io non sarÃ² disponibile.

Per favore mostra di voler supportare MFWM!
---------------------------------------------

Se trovi che MozzFullWorldMap sia utile, e migliora la tua esperienza di gioco, spero vivamente che tu possa prenderti un momento per visitare http://forums.nUIaddon.com e creare un account. Puoi anche tenerti aggiornato sugli sviluppi di nUI, MozzFullWorldMap e Party Spotter attraverso la newsletter gratuita (attraverso cui non verranno mai inviati messaggi spam, e che non sarÃ  mai condivisa con nessuno). Puoi anche fare una donazione all'autore attraverso il sito, e sottoscrivere i servizi premium, come ad esempio l'update diretto attraverso l'email, un'area riservata solo ai membri premium per evitare la follia del giorno dell'applicazione della patch, e molto altro. Le tue donazioni sono davvero apprezzate e sono il carburante che tengono i geek a lavorare sodo per te ~sorriso~

Comandi da console
--------------------

/mfwm    -- mostra la finestra per regolare le varie opzioni

* * * * * * * * * * * * * * * * * * * * * * * *

Opzioni di configurazione:

Con il comando '/mfwm' apri la schermata di configurazione di MozzFullWorldMap. Puoi anche aprire questa schermata premendo 'esc' dentro il gioco, quindi selezionando l'opzione del menu "Interfaccia", e infine cliccare sul tab "AddOns". MozzFullWorldMap apparirÃ  sul lato sinistro del menu... cliccaci su per aprire la schermata di opzioni.

Sono supportate le seguenti configurazioni per mostrare la mappa...

1)  "Rivela aree non esplorate sulla mappa"

    ---- Abilitata di default

    Quando questa opzione Ã¨ spuntata, MFWM mostrerÃ  le aree sulla mappa che il tuo personaggio non ha ancora esplorato. Normalmente le aree non esplorate sono nascoste. Deselezionare questa opzione renderÃ  il comportamento della mappa esattamente come fa la mappa della Blizzard.

2)  "Evidenzia sulla mappa tutti i dati in cache"

    ---- Disabilitata di default

    Questa opzione Ã¨ utilizzata per aiutarti a visualizzare quali dati MFWM ha giÃ  memorizzato riguardo alla mappa del mondo e che dati errati sono presenti nelle variabili salvate. Quando selezionata, MFWM mostrerÃ  ogni area che ha memorizzato in colore smeraldo, e i dati errati in rosso. CiÃ² viene fatto indipendentemente da quale area il tuo personaggio (o i tuoi personaggi) hanno o non hanno scoperto, e indipendentemente dai colori che hai selezionato per la trasparenza. Questa opzione Ã¨ pensata come uno strumento per capire "cosa cambia" tra ciÃ² che MFWM pensa di conoscere riguardo alla mappa e ciÃ² che hai "visto" esplorando il mondo.

Queste opzioni sono fornite ai fini di aggiornamento e supporto per MFWM...
    
3)    "Salva la cache corrente della mappa nelle variabili"

    ---- Disabilitata di default

    Quando viene abilitata questa opzione, MFWM salverÃ  la cache corrente della mappa, incluso sia i dati errati della mappa che quelli che hai raccolto, in [ World of Warcraft > WTF > {account} > Saved Variables > MozzFullWorldMap.lua ] al fine di aggiornare il set di dati conservato in [ Interface > AddOns > MozzFullWorldMap > MapData.lua ]. Questi sono i dati usati da MFWM quando sei nel gioco. *Non* ti Ã¨ richiesto di fare questo. Ãˆ richiesto solo dei dati della mappa di MFWM quando ci sono nuovi contenuti del mondo o altri cambiamenti. Perfino in questo caso, i giocatori non devono fare ciÃ², a meno che il messaggio "Hai dati errati" al login li annoi.

4)    "Scrivi i dati di debug nelle variabili"

    ---- Disabilitata di default

    Questa opzione andrebbe usata solo da coloro i quali hanno familiaritÃ  con la programmazione e il linguaggio Lua, quale aiuto per capire cosa fa MFWM quando gira nel gioco. Una volta abilitata, MFWM scriverÃ  i messaggi di testo nel file delle variabili del giocatore nella tabella MFWM_PlayerData.Debugging . Questi messaggi terranno traccia di continenti, zone, mappe e strati di copertura che MFWM sta mostrando insieme con i colori e gli alpha quale strumento aiuto per il debugging. La tabella di debug viene svuotata all'avvio ad ogni login o nuovo caricamento, e i dati raccolti fino al logout o altro caricamento vengono scritti nelle variabili del file MozzFullWorldMap.lua (nUI6.lua per utenti di nUI6). Possono essere molti dati se usi tanto la mappa, o apri/chiudi la mappa frequentemente. In genere, questa opzione dovrebbe essere sempre disabilitata.
 
5)    "Etichetta i pannelli della mappa per il debug visivo"

    ---- Disabilitata di default

    Come per la precedente opzione, questa Ã¨ fornita per coloro i quali tentano di capire cosa sta facendo MFWM e perchÃ©. L'opzione mostra il nome del pannello, la texture e la riga/colonna di ogni strato che disegna, quale aiuto per il debug visivo, cosa viene mostrato, e dove, sulla mappa. CosÃ¬ come per l'opzione di debug dei dati, questa dovrebbe normalmente essere disattivata.
    
    Queste sono le opzioni di colorazione della mappa. Solo una di queste dovrebbe essere attivata per volta. Selezionare una qualsiasi di queste tre opzioni deselezionerÃ  le altre due opzioni e cambierÃ  i settaggi colore...

6)    "Mostra aree non esplorate senza colorazione"

    ---- Disabilitata di default

    Quando questa opzione Ã¨ attivata, la mappa viene mostrata usando i colori normali della mappa, come se avessi esplorato tutta la mappa, indipendentemente che abbia o no scoperto ogni zona della mappa.    

7)    "Mostra aree non esplorate con colorazione smeraldo"

    ---- Abilitata di default

    Questa Ã¨ la colorazione standard della mappa e quando viene selezionata mostra le aree non esplorate in color smeraldo. Permette lo stesso all'utente di vedere i dettagli nelle aree non esplorate della mappa, ma rende chiaro quali aree della mappa sono o non sono state esplorate.    

8)    "Usa un colore personalizzato per colorare le aree non esplorate"

    ---- Disabilitata di default

    Questa opzione permette al giocatore di scegliere il colore preferito per mostrare le aree non esplorate della mappa. Quando viene selezionata, l'utente puÃ² usare la ruota dei colori e il cursore ross/giallo/blu per scegliere il colore da usare. Nota che quando selezioni l'opzione per il colore smeraldo, o quella per nessuna colorazione, ogni colore personalizzato scelto dal giocatore viene perso.    

Ci sono quattro cursori nella schermata di configurazione...

9)    "Aggiusta l'opacitÃ  per le aree non esplorate"

    ---- fissata al 100% di default

    Questo cursore modifica la trasparenza delle aree non esplorate della mappa. Oltre a poter colorare le aree non esplorate con un colore, puoi anche aggiustarne l'opacitÃ . Quando il cursore Ã¨ spostato tutto a destra, le aree non esplorate sono totalmente opache (mostrate), e quando Ã¨ tutto sulla sinistra, sono completamente trasparenti (invisibili).    

10)    "Assegna il valore del rosso della tinta (R)"

    ---- fissata al 20% di default (verde smeraldo)

    Questo cursore viene usato per controllare la componente rossa della schema di colore RGB per le aree non esplorate. Quando Ã¨ spostato completamente sulla destra, la componente rossa Ã¨ fissata al suo valore massimo (rosso), quando spostato completamente a sinistra, la componente rossa Ã¨ 0 (nero). Questo cursore puÃ² essere modificato solo quando l'opzione "Usa un colore personalizzato per colorare le aree non esplorate" Ã¨ selezionata. Quando l'opzione per non usare colorazione, o quella per usare la tinta smeraldo Ã¨ abilitata, questa barra mostra la componente rossa della tinta selezionata predefinita.    

11)    "Assegna il valore della tinta (R)"

    ---- fissata al 60% di default (verde smeraldo)

    Questo cursore viene usato per controllare la componente di verde, nello schema di colore RGB, per colorare le aree non esplorate. Quando viene spostato tutto a destra la componente di verde Ã¨ al massimo valore (verde), e quando viene spostata tutto a sinistra, la componente di verde Ã¨ 0 (nero). Questo cursore puÃ² essere azionato solo quando l'opzione "Usa un colore personalizzato per colorare le aree non esplorate" Ã¨ selezionata. Quando l'opzione per non usare colore, o quando Ã¨ selezionato il colore smeraldo, questa barra mostra la componente di verde della tinta predefinita selezionata.    

12)    "Assegna il valore blu del colore (R)"

    ---- fissata al 100% di default (verde smeraldo)

    Questo cursore Ã¨ usato per controllare la componente di blu, nello schema di colore RGB, per colorare le aree non esplorate. Quando viene spostato tutto a destra la componente di blu Ã¨ al massimo valore (blu), e quando viene spostata tutto a sinistra, la componente di verde Ã¨ 0 (nero). Questo cursore puÃ² essere azionato solo quando l'opzione "Usa un colore personalizzato per colorare le aree non esplorate" Ã¨ selezionata. Quando l'opzione per non usare colore, o quando Ã¨ selezionato il colore smeraldo, questa barra mostra la componente di verde della tinta predefinita selezionata.

13)    Ruota dei colori

    Oltre ai cursori per il rosso, verde e blu, la finestra di configurazione di MFWM fornisce una ruota dei colori che puÃ² essere usata per selezionare un colore cliccando dentro la ruota e trascinando il mouse intorno alla ruota per cambiare colori. Mentre muovi il mouse, i cursori del rosso, del verde e del blu si aggiorneranno per rispecchiare il colore scelto. Similmente, cambiare il valore dei cursori del rosso, verde o blu, cambierÃ  la posizione del cursore nella ruota dei colori, come quando si sceglie di non usare un colore o di usare la tinta smeraldo. La ruota dei colori puÃ² essere modificata solo quando l'opzione "Usa un colore personalizzato per colorare le aree non esplorate" Ã¨ selezionata.
    
* * * * * * * * * * * * * * * * * * * * * * * *

Come inviare i dati errati all'autore di MozzFullWorldMap:

Se trovi errori o dati mancanti nella mappa (MFWM visualizzerÃ  un messaggio al login, dicendoti che hai dati errati nella mappa), e hai tempo per dare aiuto, per favore fai una delle seguenti cose:

Come prima cosa, controlla i siti per il download e assicurati che tu abbia la versione piÃ¹ recente di MFWM. I punti ufficiali di distribuzione di MFWM sono (in ordine):

    http://www.nUIaddon.com
    http://www.WoWInterface.com
    http://www.curse.com
    http://wow.curseforge.com

Altre fonti di MFWM *non* somo ufficialmente approvate (sebben sia possibile trovarne) e possono o non possono essere corrette e/o aggiornate.

Se hai la versione piÃ¹ recente di MFWM presa da uno di questi siti, e hai dati errati della mappa nel tuo database, puoi fare una delle seguenti azioni per dare una mano, inviando i tuoi dati errati all'autore, affinchÃ© vengano inclusi in futuri rilasci...

Invio per e-mail...

    Esci totalmente dal gioco
    Vai alla tua cartella [ World of Warcraft > WTF > {account} > Saved Variables ]
    Invia per e-mail il file MozzFullWorldMap.lua a kscottpiel@gmail.com
    (se stai usando nUI6, invia il file nUI6.lua invece del file MozzFullWorldMap.lua)

Invio attraverso i forum di supporto...

    Esci totalmente dal gioco
    Vai su http://forums.nUIaddon.com e fai il login (crea un account se non ne hai giÃ  uno)
    Vai al forum di supporto di MozzFullWorldMap
    Crea un nuovo argomento (topic)
    Clicca sull'icona della graffetta nell'editor dei messaggi o scorri in basso fino a "Manage Attachments"
    Carica il tuo file [ World of Warcraft > WTF > {account} > Saved Variables > MozzFullWorldMap.lua ]
    (se stai usando nUI6, invia il file nUI6.lua invece del file MozzFullWorldMap.lua)  

Nota: il file MozzFullWorldMap.lua *NON* contiene dati personali. Se stai usando nUI6 e stai caricando il file nUI6.lua, questo contiene il nome del reame (server) su cui giochi, e i nomi dei personaggi in ogni reame (server), ma non aggancia questi nomi al tuo, alla tua e-mail o al tuo nome account, e non contiene altre informazioni personali.
     
* * * * * * * * * * * * * * * * * * * * * * * *

Come aggiornare i tuoi dati senza un aggiornamento:

Il processo di aggiornamento dei tuoi dati in cache Ã¨ stato semplificato nella versione di MFWM 5.00.05.00. In pratica, devi solo esplorare e il sistema automaticamente raccoglierÃ  le nuove informazioni, fondendole con quelle in cache. Gli "errata" saranno salvati nel tuo file [ World of Warcraft > WTF > {account } > Saved Variables > MozzFullWorldMap.lua ] (nUI6.lua per gli utenti nUI6) e possono essere facilmente revisionati esaminando il file con qualsiasi editor di testo... apparirÃ  nella tabella MFWM_PlayerData.Errata. Questi dati errati sono automaticamente fusi nei dati della mappa al login, e un messaggio verrÃ  mostrato a schermo per avvertirti che hai dati errati, e come fare per inviarli all'autore. Altrimenti, non c'Ã¨ veramente nulla da fare... una volta che hai esplorato una "nuova" area con qualsiasi dei tuoi personaggi, sarÃ  correttamente mostrata per tutti i tuoi personaggi.

Se vuoi effettivamente fondere i dati errati nei tuoi dati memorizzati, il metodo piÃ¹ facile Ã¨ di usare il comando '/mfwm' per aprire il pannello delle opzioni di interfaccia e controllare che l'opzione "Salva la cache della mappa attuale nelle variabili salvate", quindi clicca su "OK" ed esci dal gioco. Apri il tuo file [ World of Warcraft > WTF > {account} > Saved Variables > WorldOfWarcraft.lua ] con un editor di testo (nUI6.lua per gli utenti nUI6). Localizza la tabella MFWM_PlayerData e la tabella MapData al suo interno. Copia tutti i dati da MFWM_PlayerData.MapData in cima alla tabella MFWM.MapData nel file [ Interface > AddOns > MozzFullWorldMap > MapData.lua ] (Interface > AddOns > nUI6 > Features > MozzFullWorldMap > MapData.lua per utenti di nUI6), quindi salva il tutto e chiudi il file MapData.lua. Dopo aver copiato la tabella, cancella i dati in quella chiamata MFWM_PlayerData.Errata nel file delle variabili salvate MozzFullWorldMap.lua (nUI6.lua), e salva il file. Rientra nel gioco e controlla le mappe... dovrebbero essere corrette ora. Una volta ancora, usa il comando '/mfwm' per aprire la schermata delle opzioni, deseleziona l'opzione "Salva la cache della mappa attuale nelle variabili salvate" e clicca su "OK" -- sei pronto a ricominciare a giocare