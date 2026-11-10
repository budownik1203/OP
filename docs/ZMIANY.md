# Lista zmian

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
