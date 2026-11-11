# Lista zmian

## Build 2 — Pierwszy loch (2026-11-11)

Z bramy za strzelnicą (F) schodzi się do ręcznie ułożonej kopalni. Drabina przy wejściu wyprowadza z powrotem.

**Kopalnia**
- Poziom z chodników i komór na siatce pól 3×3 m, z obudową drewnianą, odłamami skał i pochodniami.
- Prawdziwa ciemność: poza pochodniami widać tylko to, co oświetli latarka na broni.

**Wrogowie**
- Ghul (klasa 0): szybki, biegnie z wyciągniętymi rękami, uderza szponami.
- Umarły knecht (kolczuga klasy 2, tarcza klasy 3): powolny, tarcza zatrzymuje pociski pistoletowe.
- Upadły rycerz (płyta klasy 4, szczeliny klasy 1: wizjer, pachy, tył kolan): wolny, cios mieczem łamie kości.
- Modele z jednego szkieletu człowieka 1,80 m, ze sztywnych segmentów; animacja liczona na żywo.
- Zmysły: wzrok zależny od latarki gracza i kucania, słuch reagujący na wystrzały i kroki, krzyk alarmujący sąsiadów.
- Droga do gracza wyznaczana po siatce poziomu; atak ma wyraźny zamach (0,5–0,9 s).

**Rany wrogów**
- Każdy segment ciała to osobna strefa z klasą pancerza, stanem pancerza i zdrowiem.
- Zniszczona głowa lub tors zabija; zniszczona noga zmusza do pełzania; zniszczona ręka z bronią rozbraja.
- Duży nadmiar obrażeń odcina kończynę albo głowę; odcięte części leżą na ziemi.
- Krew: bryzg w kierunku lotu pocisku, plamy na ścianach i podłodze, ślad pod krwawiącym ghulem.
- Ghul wykrwawia się po utracie kończyny; nieumarli nie krwawią.

**Zdrowie gracza**
- Strefy: głowa, tors, ręce, nogi. Śmierć po utracie głowy albo torsu; po śmierci powrót na strzelnicę.
- Krwawienie lekkie i ciężkie, złamania, ból. Rany nóg spowalniają i blokują sprint, rany rąk i ból kołyszą bronią.
- Leki pod klawiszami 4–8: bandaż, opatrunek hemostatyczny, szyna, apteczka, środki przeciwbólowe. Użycie trwa 2–6 s i opuszcza broń.
- Sylwetka ze stanem stref, lista ran i zapas leków na ekranie.

**Hałas**
- Wystrzał słychać z ok. 55 m (poddźwiękowy 9 mm z ok. 30 m), kroki z 1–7 m zależnie od tempa.

**Poprawki do builda 1**
- Elementy interfejsu były źle zakotwiczone i część lądowała poza ekranem.
- Latarka ma szerszy snop i poświatę.

**Znane braki**
- Zwłoki to przewrócony model, bez fizyki ciała.
- Wrogowie nie otwierają drzwi i nie omijają się nawzajem w wąskich przejściach.
- Sprzęt nie przechodzi między strzelnicą a kopalnią; ekwipunek powstanie w buildzie 3.
- Bez tłumika broń budzi pół poziomu; tłumiki przyjdą z dodatkami do broni.

## Build 1 — Strzelnica (2026-11-10)

Pierwszy build. Cel: sprawdzić, czy samo strzelanie jest dobre, zanim powstanie reszta gry.

**Ruch**
- Ciężki ruch z bezwładnością; tempo chodu regulowane kółkiem myszy (7 stopni).
- Sprint, skok, płynne kucanie, wychylanie na Q/E ograniczane przez ściany.
- Dwie pule wytrzymałości: nogi (sprint, skok) i ręce (trzymanie celu; zmęczone ręce kołyszą bronią).

**Broń**
- Karabinek „Kwarc” wz. 96 (5,56×45, ogień pojedynczy i ciągły, 700 strz./min) i pistolet „Jaspis” (9×19).
- Ruch broni liczony na żywo: bezwładność za kamerą, kołysanie, bujanie przy chodzie, oddech, odrzut na sprężynach.
- Brak krzyżyka. Pocisk leci tam, gdzie patrzy lufa; celowanie przez prawdziwe przyrządy.
- Lufa blokuje się o ścianę: przy przeszkodzie broń unosi się i nie strzela.
- Magazynki jako osobne przedmioty, brak licznika naboi, sprawdzanie stanu „na oko” (T).
- Przeładowanie taktyczne i szybkie; rzucony magazynek leży na ziemi i można go podnieść.
- Nabój w komorze liczony osobno; pistolet zostaje z zamkiem w tylnym położeniu po ostatnim strzale.
- Mieszanie dwóch typów naboi w magazynku w przeplocie 2:1 (stół amunicyjny).
- Latarka na broni (L).

**Balistyka i pancerz**
- Pocisk jako obiekt: prędkość wylotowa, opór powietrza, opad, rykoszety.
- Osiem typów amunicji (po cztery na kaliber) z obrażeniami, przebiciem i prędkością.
- Jedna reguła penetracji: próg klasy = klasa × 10; pełne przebicie, przebicie częściowe, zatrzymanie, rykoszet.
- Pancerz się niszczy: każde trafienie obniża stan płyty, a rozbita płyta przestaje chronić.
- Kąt trafienia ma znaczenie: ukośne trafienie przebija trudniej.

**Strzelnica**
- Płyty klas 0–5 na 10, 25, 50 i 100 m; nad każdą wynik ostatniego trafienia.
- Dwa manekiny rycerza z pancerzem strefowym (napierśnik klasy 4, szczeliny klasy 1), jeden odwrócony tyłem.
- Stół amunicyjny, kosze z ogniem, sylweta klasztoru w tle.

**Obraz i dźwięk**
- Styl: hybryda fasetowa, obraz w ok. 540 liniach skalowany bez wygładzania, lekki dithering.
- Dźwięki z syntezy (zastępcze): wystrzały, mechanika broni, trafienia w stal, rykoszety, kroki.

**Narzędzia**
- Panel strojenia (F1): odrzut, kołysanie, bezwładność, czułość, pole widzenia, pikselizacja; ustawienia się zapisują.
- Polski i angielski (F2).
- Testy automatyczne: balistyka, przejście wszystkich czynności gracza, zrzuty ekranu, przeglądarka modeli.

**Znane braki**
- Dłonie są sztywne; przy przeładowaniu lewa ręka zjeżdża z magazynkiem bez osobnej animacji palców.
- Brak łusek i błysku wystrzału w docelowej jakości; brak dymu i iskier przy trafieniu.
- Gra testowana na programowym rendererze OpenGL; na karcie graficznej (Vulkan) nie była jeszcze uruchamiana.
