AIGMos vNext — mitä seuraavaan päivitykseen tulee

AIGMos vNextin pääsuunta on lukittu:

AIGMos ei ole agenttiframework.
AIGMos on local-first controlled AI runtime, jossa agenttisuus on vain yksi rajattu kerros.

Ydinajatus:
Runtime owns execution.
Models request.
AIGMos validates.
AIGMos executes.
AIGMos stops.


1. Local-first core

AIGMos rakennetaan ensisijaisesti paikallisesti ajettavaksi runtimeksi.

Phone-capable käyttö on tärkeä näyttö matalasta laitevaatimuksesta:
jos käytössä on puhelin ja shell/runtime, AIGMos-työnkulkuja voi jo rakentaa.

Tämä ei tarkoita phone-only-arkkitehtuuria.
Sama järjestelmä voi toimia puhelimella, läppärillä, desktopilla, serverillä tai järeämmän koneen ohjaamana.


2. Clean core

Core pidetään puhtaana.

Core ei sisällä oletuksena:
- demoja
- sample-dataa
- tutorial-dataa
- ulkoisia integraatioita
- cloud-riippuvuutta
- desktop UI -vaatimusta

Core käynnistyy ja toimii yksin.


3. Triggerit, eventit ja runnerit nostetaan keskiöön

AIGMos:n perusmalli on event-driven:

state
→ trigger
→ event
→ command / routine / runner

Tämä on koko järjestelmän operatiivinen pohja.

Tutorialeissa ja dokumentaatiossa nämä opetetaan aikaisin, koska kaikki muu rakentuu niiden päälle.


4. Expression engine dokumentoidaan kunnolla

Expression engine eli ?-root saa oman vahvan dokumentaationsa.

? ei ole normaali state-arvo.
? sisältää expression-määritelmän, joka evaluoitaessa tuottaa tuloksen.

Tulee erillinen:

test exp

Se validoi expression-määritelmät, formaatin, mappingin ja reload-säännöt.


5. User-moduulit lukitaan neljään päätyyppiin

User module -tyypit ovat vain:

- command
- input
- adapter
- layout

Näille tulee sopimukset ja validointi.

Uusi komento:

test usermodules

Se validoi vain nämä neljä moduulityyppiä.

test user varataan myöhempään käyttöön eikä sitä käytetä aliasina.


6. #T ja #MCP capability registryt

#T ja #MCP otetaan mukaan capability-/tool-sopimuksiin.

#T:
sisäiset mallien käytettävät capabilityt qt/qct-loopissa

#MCP:
ulkoisesti käskytettävät MCP-capabilityt

Tärkeä sääntö:
#T- tai #MCP-polku ei ole komennon nimi.

Capability määrittelee mitä saa pyytää.
command-kenttä määrittelee mitä AIGMos oikeasti ajaa.

Root-scopeja ei sallita:

#T  = error
#MCP = error

Sallittuja ovat vain tarkemmat polut, esim:

#T:state
#T:state:read_public
#MCP:public
#MCP:public:state


7. test tools

Uusi:

test tools

Se validoi #T- ja #MCP-määrittelyt.

Se tarkistaa mm:
- JSON-formaatin
- schemat
- command-viittauksen
- authority_class-arvon
- scope-määritykset
- forbidden rootit
- root-scope-virheet

test tools ei koskaan suorita työkaluja.


8. qt ja qct tekevät järjestelmästä agenttisen

AIGMos ei ole oletuksena agentti.

Agenttisuus tulee vain qt/qct-kerroksesta:

q  = chatbot ilman työkaluja
qt = chatbot + työkalut

qc  = coder / validator / trainer ilman työkaluja
qct = coder / validator / trainer + työkalut

qt/qct tool loop on rajattu ja runtime-omisteinen.

Malli saa pyytää työkaluja.
AIGMos päättää saako niitä käyttää.
AIGMos päättää milloin looppi katkaistaan.

Jokainen ajo päättyy stop_reasoniin.


9. #BOT foundation

#BOT:n tarkoitus on parantaa bottien toimintaa AIGMos:n sisällä.

Ensimmäinen kova kohde on llama4b / 4B-luokan pienet mallit, koska AIGMos toimii jo kevyessä ympäristössä.

#BOT ei ole llama4b-spesifi.
Se on yleinen bot-improvement / validation / instruction system.

vNextissä varaudutaan:
- traceihin
- ihmisen merkintöihin
- validointiin
- role/instruction/tutorial-kandidaatteihin
- export/import-polkuun
- myöhempään LoRA/weight/reward/autonomous promotion -kehitykseen

Mutta tässä vaiheessa:
- ei automaattista promootiota
- ei automaattista mallin korvaamista
- ei raskasta training executionia


10. Koulutus voi olla phone-controllable

AIGMos ei oleta, että raskas koulutus tehdään samalla laitteella.

Puhelin voi toimia:
- ohjaimena
- käyttöliittymänä
- shellinä
- validointipäätteenä
- training jobien käynnistäjänä

Järeämpi kone voi tehdä raskaan mallityön.

AIGMos pitää huolta sopimuksesta:
export → train/optimize elsewhere → import artifact/spec back.


11. Optional package mechanism

vNextiin tulee first boot -kysymys optional data -paketeille.

Varatut paketit:

tutorial-data
sample-data

Nämä ovat kriittisiä adaptaation tukipaketteja, mutta eivät core-runtimea.

Tässä vaiheessa tehdään:
- first boot prompt
- package source resolver
- manifest validation
- installer
- ledger
- package status/list/install/remove

Ei vielä tehdä:
- tutorial-data sisältöjä
- sample-data sisältöjä
- varsinaista tutorial-speksiä

Oletus:
core only.


12. REST/webserver ja web-ohjaus valmistellaan dokumentaatiotasolla

Webserver on olennainen local-first / phone-capable käytössä.

Tuleva tutorial-polku:

phone browser
→ web UI
→ REST request
→ #REST
→ ? expression
→ state / command / response
→ visible feedback

Default bind:
127.0.0.1

0.0.0.0 vain eksplisiittisesti ja varoituksella.


13. Dokumentaatio on release gate

vNext ei ole valmis ilman kunnollista dokumentaatiota.

Pakollisia dokumentoitavia alueita:

- local-first käyttö
- phone-capable käyttö
- symbol rootit
- triggerit
- eventit
- runnerit
- expression engine
- REST/webserver
- usermodule contractit
- #T ja #MCP
- test usermodules
- test exp
- test tools
- qt/qct tool loop
- #BOT
- optional package mechanism


14. Ei tehdä tässä versiossa

Ei tehdä vielä:
- Gmail-integraatiota
- Telegram-integraatiota
- muita konkreettisia ulkoisia integraatioita
- tutorial-data sisältöä
- sample-data sisältöä
- koko tutorial-curriculumia
- LoRA-ajuria
- weight trainingia
- reward modelia
- autonomous role promotionia

Nämä ovat arkkitehtuurin mahdollistamia asioita, eivät vNextin toteutuskohteita.


Yhteenveto

AIGMos vNext tekee järjestelmästä selkeämmin:

- local-first
- clean core
- event-driven
- turvallisesti laajennettavan
- testattavan
- dokumentoidun
- phone-capable
- small-model-friendly
- bounded-agentic qt/qct-kerroksen kautta

Lopullinen periaate:

Core remains clean.
Runtime owns execution.
Models request.
AIGMos validates.
AIGMos executes.
AIGMos stops.
