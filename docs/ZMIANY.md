# Lista zmian

## Build 5 — Ruda i naboje (2026-11-11)

**Nowa broń (wybór w odprawie przy bramie)**
- Karabinek „Granit” 7,62×39: mocniejszy i z większym odrzutem niż „Kwarc”.
- Pistolet maszynowy „Gabro” 9×19: mały odrzut, tania amunicja.
- Strzelba „Łupek” 12/70: ładowana po jednym naboju z paczki w kamizelce lub kieszeni, przeładowywana czółenkiem po każdym strzale. Klawisz B wybiera rodzaj dokładanego naboju; strzał przerywa ładowanie.
- Karabin wyborowy „Krzemień” 7,62×51: zamek ślizgowy repetowany po każdym strzale, luneta z przybliżeniem i krzyżem.
- Pistolet „Weteran” .45 ACP jako druga broń boczna.
- Dziewięć nowych typów amunicji: .45 (2), 12/70 śrut i breneka, 7,62×39 (3), 7,62×51 (2). Śrut to osiem osobnych pocisków.
- Każda broń ma własny model z Blendera, magazynki jako przedmioty i własny dźwięk.

**Wydobycie**
- Osiem żył w kopalni: miedź, ołów, żelazo, siarka, saletra. Każda daje trzy bryły.
- Kucie wymaga kilofa (jest w skrytce), trwa 7 s na bryłę, hałasuje i budzi loch o ok. 3 punkty.
- Ruda jest ciężka: 1,5–1,8 kg za bryłę.

**Oprawianie i łuski**
- Klawisz V przy zwłokach potwora: 4 s pracy nożem, do łupu trafiają kość, ścięgna, czasem gruczoł.
- Po strzelaninie można zebrać własne łuski (F w miejscu walki, 3 s); odzysk 60%.

**Rzemiosło**
- Piec hutniczy (w bazie i jeden w kopalni): dwie bryły rudy na sztabkę; stal wymaga też węgla.
- Stół rusznikarski (w bazie zamiast stołu amunicyjnego i jeden w kopalni): proch z siarki, saletry i węgla; łuski z mosiądzu; naboje z łusek, prochu, spłonek i ołowiu; typy przeciwpancerne wymagają stali.
- Demontaż naboi: wracają łuski, proch i spłonki.
- Spłonek nie da się wytworzyć: pochodzą z zapasu startowego, skrzyń i demontażu.
- W bazie receptury korzystają ze skrytki i tam odkładają wyniki.

**Zmiany**
- Darmowe napełnianie magazynków przy stole zniknęło. Amunicję trzeba mieć albo zrobić.
- Stare zapisy bazy z builda 4 nie są wczytywane (zmienił się format); gra zaczyna nową kampanię.

**Znane braki**
- Dłonie na nowych broniach to te same sztywne modele, dopasowane przesunięciem; na „Gabro” lewa dłoń trzyma chwyt przedni niedokładnie.
- Brak animacji wkładania pojedynczego naboju do strzelby i ruchu ręki przy zamku karabinu wyborowego.
- Luneta ma stałe przybliżenie i nie ma regulacji na odległość.
- Liczby gospodarki (30 łusek ze sztabki, 40 porcji prochu z zestawu) są ustawione na wyczucie.

## Build 4 — Ekstrakcja (2026-11-11)

Pierwsza zamknięta pętla: baza → odprawa → kopalnia → wyjście z łupem → skrytka → kolejna wyprawa.

**Baza**
- Strzelnica jest teraz bazą. Pod wiatą stoi skrytka (10×14 pól) z zapasem startowym.
- Dwuklik w ekwipunku: lek leczy, jedzenie i picie są spożywane, kamizelka i plecak zakładane.
- Zamiana kamizelki przenosi zawartość do nowej, o ile się mieści; zamiana plecaka odkłada stary razem z zawartością.
- Brama otwiera odprawę: cel, obciążenie, liczba magazynków pod ręką, ostrzeżenia o braku jedzenia, wody i opatrunków.
- Stan bazy i żołnierza zapisuje się na dysk przy każdym powrocie i przy wyjściu z gry w bazie.

**Wyprawa**
- Trzy wyjścia z kopalni: drabina przy wejściu, krata szybu (zużywa żelazny klucz) i stary chodnik.
- Przebudzenie lochu: rośnie z czasem (pełne po 40 minutach) i od hałasu (wystrzał bez tłumika ok. +1,4 pkt).
- Progi 25/50/75/100: z głębi wychodzą kolejni wrogowie i idą w stronę gracza; przy 50 stary chodnik się zawala; przy 100 ghule napływają co 45 s.
- Cztery znaczniki Przebudzenia w prawym górnym rogu.
- Wyniesiony łup zostaje. Śmierć zabiera wszystko poza relikwiarzem.
- Zamknięcie gry w lochu bez biwaku oznacza stratę żołnierza przy następnym uruchomieniu.

**Głód i pragnienie**
- Płyną tylko na wyprawie: woda wystarcza na 30 minut, jedzenie na 55.
- Poniżej 25% rośnie kołysanie broni i wolniej wraca wytrzymałość; przy zerze ubywa zdrowia.
- Racja żywnościowa, konserwa, suchary, manierka na trzy porcje (napełniana w bazie), bukłak.

**Biwak**
- W jednej z komór jest palenisko. Odpoczynek przywraca wytrzymałość i zmniejsza ból, ale podnosi Przebudzenie.
- „Zapisz i zakończ grę” zawiesza wyprawę: zapisuje ekwipunek, rany, Przebudzenie, zabitych wrogów i skrzynie. Zapis znika po wczytaniu.

**Znane braki**
- Po wznowieniu z biwaku wrogowie wypuszczeni przez Przebudzenie i przedmioty leżące na ziemi nie wracają.
- Rany leczą się same po powrocie do bazy; lazaret przyjdzie z plutonem w buildzie 6.
- Baza nie ma jeszcze osobnej lokacji ani pozostałych żołnierzy.

## Build 3 — Ekwipunek (2026-11-11)

**Siatka przedmiotów (Tab)**
- Kieszenie 4×1, kamizelka 5×2, plecak szturmowy 4×5, relikwiarz 2×2. Pojemność wynika z noszonej kamizelki i plecaka.
- Przeciąganie myszą, obrót klawiszem R, szybkie przenoszenie Ctrl+klik, wyrzucanie prawym przyciskiem.
- Podpowiedź po najechaniu: nazwa, waga, stan magazynka „na oko”, nabój na wierzchu.
- Gra nie zatrzymuje się podczas grzebania w ekwipunku.

**Magazynki i amunicja jako przedmioty**
- Przeładować można tylko magazynkiem z kamizelki albo kieszeni; magazynki w plecaku się nie liczą.
- Przy przeładowaniu taktycznym stary magazynek wraca w miejsce, z którego wyjęto nowy.
- Luźne naboje w paczkach: upuszczenie paczki na magazynek ładuje go po jednym naboju co 0,35 s.
- Leki są przedmiotami; klawisze 4–8 zużywają je z ekwipunku.

**Waga**
- Każdy przedmiot waży, naboje też. Do 25 kg bez kary, 25–40 kg rosnące spowolnienie, od 40 kg brak sprintu.
- Cięższy żołnierz głośniej chodzi.
- Plecak można zrzucić (Z) i później podnieść razem z zawartością.

**Łup**
- Pięć skrzyń w kopalni z losową zawartością; zwłoki wrogów też można przeszukać (F).
- Przeszukiwanie trwa: przedmioty odkrywają się po jednym co 0,7 s.
- Przedmioty leżące na ziemi podnosi się klawiszem F.

**Ciągłość**
- Ekwipunek i stan broni (magazynek, nabój w komorze) przechodzą między strzelnicą a kopalnią.
- Śmierć zabiera wszystko poza relikwiarzem; baza wydaje minimalny przydział.

**Poprawki**
- Rozglądanie myszą nie działało (zgłoszone przez właściciela). Testy sprawdzają teraz prawdziwe zdarzenia myszy.
- Elementy pełnoekranowe interfejsu miały zerowy rozmiar.

**Znane braki**
- Przedmioty to kolorowe kafelki z nazwą, bez ikon.
- Nie da się jeszcze zamienić noszonej kamizelki ani plecaka na inny przez przeciągnięcie; plecak z łupu zakłada się tylko, gdy własny jest zrzucony.
- Brak skrytki w bazie; wejdzie w buildzie 4.

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
