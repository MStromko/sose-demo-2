# sose-demo-2

SOSE prezentácia – demo 2: iteratívny vývoj s AI agentom. Agent najprv navrhne plán bez kódu a potom implementuje len presne vymedzenú časť (Pomodoro Timer).

## Čo je to za aplikáciu

Pomodoro Timer v čistom HTML/CSS/JS (bez frameworku, bez build kroku, bez závislostí):

| Súbor | Úloha |
|---|---|
| [index.html](index.html) | Hotová štruktúra stránky (displej času, tlačidlá, počítadlo cyklov) a načítanie `app.js` |
| [style.css](style.css) | Hotový vzhľad |
| [app.js](app.js) | V bode 0 prázdny, logiku doplní demo |

## Ako demo spustiť

Aplikácia je statická, stačí ju servírovať ľubovoľným HTTP serverom. Z koreňa repozitára:

```bash
python3 -m http.server 8007
```

Potom otvor <http://localhost:8007>. Port sa líši od Dema 1 (8006), takže môžu bežať obe naraz.

## Úloha pre agenta (to, čo sa bude demovať)

### Východiskový stav (bod 0)

Stránka vyzerá hotovo, ale **nič nerobí**: zobrazuje `25:00`, tlačidlá nereagujú a [app.js](app.js) obsahuje len komentár.

Elementy, na ktoré sa logika napája:

| ID | Účel |
|---|---|
| `time-display` | zobrazenie času v tvare MM:SS |
| `btn-start` | tlačidlo štart |
| `btn-pause` | tlačidlo pauza |
| `btn-reset` | tlačidlo reset |
| `cycle-count` | zobrazenie počtu dokončených cyklov |

### Scenár v dvoch krokoch

Demo ukazuje rozdiel v prístupe: namiesto „napíš mi celý Pomodoro časovač“ si agent najprv pripraví plán a potom sa implementuje len schválená časť. Oba prompty majú štruktúru **Context, Instruction, Input, Definition of Done, Output** (CIIDO) a idú **v tom istom chate za sebou**, lebo Krok 2 nadväzuje na plán z Kroku 1.

#### Krok 1 – vyžiadanie plánu (zero-code fáza)

Agentovi sa zakáže programovať, má len vytvoriť logickú štruktúru pre existujúce HTML.

```text
CONTEXT:
Si Senior Frontend Architekt. Vytvárame Pomodoro Timer. Vizuálna časť (HTML a CSS) je už kompletne hotová a obsahuje konkrétne elementy s IDčkami. Teraz potrebujeme navrhnúť architektúru pre JavaScript logiku predtým, než napíšeme čo i len jeden riadok kódu.

INSTRUCTION:
Navrhni detailný krok za krokom plán implementácie JS logiky. Zatiaľ nepíš žiadny skutočný JavaScript kód, iba navrhni štruktúru a postupnosť prác.

INPUT:
Existujúce HTML ID atribúty, na ktoré sa musíme napojiť:
- `time-display` (pre zobrazenie času v tvare MM:SS)
- `btn-start` (tlačidlo štart)
- `btn-pause` (tlačidlo pauza)
- `btn-reset` (tlačidlo reset)
- `cycle-count` (zobrazenie počtu dokončených cyklov)

Požadovaná funkcionalita: 25 minútový odpočet a ukladanie počtu dokončených cyklov do LocalStorage.

DEFINITION OF DONE:
- Plán je rozdelený na logické fázy implementácie (napr. Fáza 1: Formátovanie času a odpočet, Fáza 2: Ovládanie tlačidlami, Fáza 3: LocalStorage a cykly).
- Pri každej fáze je zoznam navrhovaných JS funkcií a premenných s krátkym popisom.
- Výstup neobsahuje žiadny spustiteľný programovací kód.

OUTPUT:
Štruktúrovaný text vo formáte Markdown (odrážky, tučné písmo). Žiadne bloky kódu.
```

Čo povedať publiku:

> Všimnite si, že agent teraz negeneruje žiadne halucinácie ani zbytočný kód. Týmto promptom som ho prinútil pochopiť moje už existujúce prostredie (moje HTML IDčka) a vytvoriť si kontext.

#### Krok 2 – cielená implementácia (Fáza 1 a 2)

Namiesto celého časovača sa pýta len prvá časť z plánu. Prompt sa pošle ako odpoveď na výstup z Kroku 1.

```text
CONTEXT:
Plán architektúry je schválený. Ideme realizovať iteratívny vývoj, aby sme mali plnú kontrolu nad kódom a minimalizovali chyby.

INSTRUCTION:
Implementuj v JavaScripte výhradne Fázu 1 a Fázu 2 z tvojho plánu: napojenie premenných na DOM elementy (cez dodané ID), formátovanie času do tvaru MM:SS a základnú logiku časovača (funkcie pre btn-start, btn-pause a btn-reset).

INPUT:
Schválená logika pre odpočet (25 minút). Dočasne ignoruj funkcionalitu počítania cyklov a ukladania do LocalStorage – to budeme robiť až v ďalšom kroku.

DEFINITION OF DONE:
- Kód správne odpočítava čas po stlačení Start.
- Kód zastaví odpočet po stlačení Pause.
- Kód vráti čas na 25:00 po stlačení Reset.
- Kód neobsahuje žiadnu logiku pre LocalStorage.

OUTPUT:
Vráť výhradne blok kódu s čistým JavaScriptom (Vanilla JS). Žiadne vysvetľujúce texty, žiadne HTML, žiadne CSS. Len JS kód pripravený na vloženie do `app.js`.
```

Čo povedať publiku:

> Teraz pýtam len presne vymedzený kus kódu. Rýchlosť generovania je okamžitá, spotreba tokenov je minimálna a agent nemá priestor rozbiť funkciu LocalStorage, pretože som mu ju ešte nedovolil implementovať.

Výstup agenta sa **vloží do [app.js](app.js)** (nahradí komentár) a stránka sa obnoví.

### Očakávaný výsledok

- Po Kroku 1: plán vo fázach, so zoznamom funkcií a premenných, bez blokov kódu. V repozitári sa nič nezmenilo.
- Po Kroku 2: zmenený je len [app.js](app.js). Fáza 3 sa v deme neimplementuje, takže `cycle-count` ostáva na `Dokončené cykly: 0`.

### Ako overiť, že to funguje (live na demo)

1. Klikni na **Start** → po pár sekundách displej ukazuje menej ako `25:00` (napr. `24:57`) v tvare MM:SS.
2. Klikni na **Pause** → čas sa zastaví a ďalej nebeží.
3. Klikni znova na **Start** → odpočet pokračuje od zastaveného času.
4. Klikni na **Reset** → displej ukazuje `25:00`.
5. Klikni dvakrát rýchlo za sebou na **Start** → čas stále klesá o jednu sekundu za sekundu (nezrýchli sa).
6. V DevTools otvor **Application → Local Storage** → po tomto kroku v ňom aplikácia nič neuložila. Prípadne vyhľadaj `localStorage` priamo v [app.js](app.js).

Body 1, 2, 4 a 6 vychádzajú z DoD Kroku 2. Body 3 a 5 sú doplnkové kontroly bežných chýb časovača a prompt ich výslovne nežiada.

## Reset dema do bodu 0

Pre opakované predvádzanie slúži script **`reset-demo.sh`** v koreni repozitára. Vráti repozitár do stavu pred vložením kódu z dema.

- Referenčný bod 0 je commit s pripravenou šablónou, týmto README a `reset-demo.sh`, označený git tagom **`demo-start`**. Ak tag neexistuje, script skončí s chybou.
- Script zahodí všetky lokálne zmeny (necommitnuté aj commitnuté po `demo-start`) a vráti `main` na `demo-start`.
- Zmaže lokálne pracovné vetvy, ktoré počas dema vznikli.
- Pracuje **len lokálne** – nič nepushuje ani neprepisuje na vzdialenom repozitári (`origin`).
- Pred zmazaním zmien vypíše, čo sa zahodí, a vypýta si potvrdenie (alebo sa spustí s `--yes`).

Použitie:

```bash
./reset-demo.sh          # interaktívne, s potvrdením
./reset-demo.sh --yes    # bez potvrdenia (tesne pred prezentáciou)
```

Pred ďalším behom treba začať **nový chat**, aby sa plán z predchádzajúceho behu neprenášal.

### Príprava pred prvým použitím

```bash
git add README.md reset-demo.sh app.js index.html
git commit -m "Add demo description and reset script"
git tag demo-start
```
