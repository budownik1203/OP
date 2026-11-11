# Ostatni Pluton

Gra FPP dla jednego gracza: polski pluton współczesnego wojska odcięty w umierającym świecie mrocznego fantasy. Roguelike z ekstrakcją, realistyczną balistyką i pancerzem strefowym wrogów. Silnik: Godot 4.7, modele: Blender sterowany skryptami. Całość kodu i zasobów tworzy Claude.

## Stan

**Build 3 — Ekwipunek.** Siatka przedmiotów z kieszeniami, kamizelką, plecakiem i relikwiarzem, magazynki i leki jako przedmioty, waga, skrzynie i zwłoki do przeszukania.

**Build 2 — Pierwszy loch.** Strzelnica z builda 1 oraz kopalnia z trzema wrogami (ghul, umarły knecht, upadły rycerz), pancerzem strefowym, rozczłonkowaniem, zdrowiem strefowym gracza i lekami. Do kopalni schodzi się przez bramę za plecami na strzelnicy (F).

Plan kolejnych buildów: `docs/PLAN.md`. Lista zmian: `docs/ZMIANY.md`. Projekt gry: `docs/PROJEKT.md`.

## Jak uruchomić

1. Zainstaluj Godot 4.7.2 (wersja standardowa, nie .NET).
2. Pobierz repozytorium (zielony przycisk **Code → Download ZIP** albo `git clone`).
3. W Godocie: **Importuj** → wskaż plik `project.godot` → **Importuj i edytuj**.
4. Pierwsze otwarcie trwa chwilę, bo Godot importuje modele i dźwięki.
5. Naciśnij **F5**.

## Sterowanie

| Klawisz | Działanie |
| --- | --- |
| WSAD, mysz | Ruch, rozglądanie |
| Kółko myszy | Prędkość chodu (wolniej = ciszej) |
| Shift, C, Spacja | Sprint, kucanie, skok |
| Q / E | Wychylenie |
| LPM / PPM | Strzał / celowanie przez przyrządy |
| R | Przeładowanie taktyczne (magazynek wraca do kamizelki) |
| R dwa razy | Przeładowanie szybkie (magazynek ląduje na ziemi, F podnosi) |
| T | Sprawdzenie magazynka (licznika naboi nie ma) |
| B | Tryb ognia |
| 1 / 2 | Karabinek / pistolet |
| 4–8 | Leki: bandaż, opatrunek, szyna, apteczka, przeciwbólowe |
| Tab | Ekwipunek (LPM przeciąga, R obraca, Ctrl+LPM przenosi, PPM wyrzuca) |
| Z | Zrzucenie plecaka |
| L | Latarka |
| F | Użyj, podnieś, przeszukaj |
| G | Wyczyszczenie tarcz |
| F1 | Panel strojenia (odrzut, kołysanie, czułość, pikselizacja) |
| F2 | Język PL / EN |
| H | Pomoc |
