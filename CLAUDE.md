# Ostatni Pluton — zasady pracy w repozytorium

Ten plik czyta każda sesja Claude'a pracująca nad grą. Zawiera decyzje właściciela projektu i sposób pracy. Właściciel nie programuje; ocenia gotowe buildy.

## Decyzje właściciela (nie zmieniać bez pytania)

- Gra FPP dla jednego gracza, PC, docelowo Steam. Tytuł roboczy: Ostatni Pluton.
- Polski pluton 6 żołnierzy, trwała śmierć; na wyprawę idzie jeden żołnierz, sam.
- Gra wolna i trudna, z głodem i pragnieniem. Zapis tylko w bazie i przy biwaku, bez wczytywania po śmierci.
- Obsługa broni i ruch mają dawać odczucie jak w Escape from Tarkov. Ekwipunek jako siatka zależna od plecaka i kamizelki.
- Broń: własne nazwy na wzór prawdziwych modeli Wojska Polskiego, prawdziwe kalibry.
- Wrogowie: potwory i ludzie (Straż Zakonu). Brutalność wprost, rozczłonkowanie powiązane ze strefami pancerza.
- Lochy losowane co wyprawę.
- Języki od początku: polski i angielski. Każdy tekst przez `tr("KLUCZ")`, klucze w `skrypty/auto/jezyk.gd`.
- Styl: hybryda fasetowa w dwóch gęstościach (świat i potwory 800–2500 trójkątów, broń i ręce 4–8 tys.), małe tekstury bez wygładzania, obraz ok. 540 linii, bez drgania wierzchołków.
- Silnik Godot 4.7, modele skryptami w Blenderze. Repozytorium jest źródłem prawdy.
- Właściciel wymaga jakości docelowej, zwłaszcza modeli i animacji: realistyczne proporcje, żadnej karykatury. Każdy model sprawdzać na renderach przed wejściem do gry.
- Po każdym buildzie właściciel dostaje paczkę ZIP z projektem do pobrania (`git archive --format=zip --prefix=OstatniPluton-buildN/ HEAD`), wysłaną w rozmowie.
- Praca bez czekania na właściciela: buildy po kolei aż do wersji 0.1 (build 6), po każdym commit i wpis w `docs/ZMIANY.md`.

## Układ repozytorium

- `skrypty/` — GDScript. Sceny buduje się w kodzie; pliki `.tscn` zawierają tylko korzeń ze skryptem.
- `skrypty/swiat.gd` — baza każdej lokacji (gracz, ślady, krew, hałas); `strzelnica/`, `kopalnia.gd` to lokacje; `wrogowie/` — wrogowie i strefy trafień; `gracz/zdrowie.gd` — rany i leki.
- `skrypty/rzemioslo.gd` — receptury pieca i stołu rusznikarskiego; surowce to przedmioty ze stosem (`dane.ile`).
- `narzedzia/blender/bron_rodzina.py` — pozostała broń; dłonie z `rece.py` (`prawa_karabin`, `lewa_loze`, `prawa_pistolet`, `lewa_pistolet`).
- `narzedzia/blender/postacie.py` — wspólny szkielet człowieka i warianty wrogów.
- `skrypty/auto/` — autoloady: `Jezyk`, `Wejscie`, `Strojenie`, `Amunicja`, `Dzwiek`, `Ekwipunek` (stan żołnierza między lokacjami).
- `skrypty/ekwipunek/` — siatka (`Pojemnik`), przedmioty leżące, skrzynie; `skrypty/ui/ekwipunek_ui.gd` — ekran ekwipunku.
- Zapis: `user://baza.sav` (stan bazy i żołnierza) i `user://biwak.sav` (zawieszona wyprawa, kasowany przy wczytaniu); testy uruchamiane z `--test…`/`--zrzut…` nie zapisują.
- Uwaga: świat 3D jest w SubViewport i nie dostaje zdarzeń myszy. Wejście gracza przekazuje `gra.gd` (`Gracz.wejscie`). Kontrolki pełnoekranowe ustawiać przez `set_anchors_and_offsets_preset`.
- `narzedzia/blender/` — skrypty modeli (`python3 kwarc.py` generuje `zasoby/modele/kwarc.glb` i tekstury).
- `narzedzia/dzwiek/generuj.py` — synteza dźwięków zastępczych.
- `narzedzia/zrzuty.sh`, `narzedzia/podglad.sh` — zrzuty z gry i rzuty modeli do kontroli jakości.
- `docs/` — projekt gry, plan buildów, lista zmian.
- Gałąź `tools` trzyma binarkę Godota dla Linuksa (do testów bez okna).

## Konwencje

- Nazwy w kodzie po polsku bez znaków diakrytycznych, komentarze po polsku.
- Modele: X w prawo, Y do przodu, Z w górę, metry. Broń: początek układu na osi lufy z tyłu komory zamkowej; węzły `korpus`, `zamek`, `magazynek`, `reka_p`, `reka_l`, puste `wylot` i `celownik`.
- Jedna reguła penetracji dla całej gry: `Amunicja.rozstrzygnij()`. Próg klasy pancerza = klasa × 10.
- Każdy obiekt, w który może trafić pocisk, ma metodę `trafienie(info) -> Dictionary`.

## Sprawdzanie przed commitem

1. `godot --headless --import` bez błędów.
2. `godot --headless -- --test-balistyka` — tabela wyników zgodna z projektem.
3. `xvfb-run godot --rendering-driver opengl3 -- --test-gra` — przejście wszystkich czynności gracza bez błędów.
   `xvfb-run godot --rendering-driver opengl3 -- --test-ekwipunek` — siatka, waga, przeciąganie myszą, łup, śmierć.
   `godot --headless -- --test-ekstrakcja` — skrytka, zamiana noszonych rzeczy, głód, Przebudzenie, wyjścia, zapis i wznowienie.
   `godot --headless -- --test-rzemioslo` — każda broń, strzelba, receptury, żyły, oprawianie, łuski.
   `xvfb-run godot --rendering-driver opengl3 -- --zrzut-bron=KATALOG` — każda broń z biodra, w celowaniu i przy strzale.
   `godot --headless -- --swiat=kopalnia --test-loch` — wrogowie, strefy, rozczłonkowanie, ciosy, leki, śmierć.
4. `narzedzia/zrzuty.sh` i obejrzenie zrzutów; nowe modele dodatkowo przez `narzedzia/podglad.sh`.
