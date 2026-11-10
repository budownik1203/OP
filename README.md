# Ostatni Pluton

Gra FPP dla jednego gracza: polski pluton współczesnego wojska odcięty w umierającym świecie mrocznego fantasy. Roguelike z ekstrakcją, realistyczną balistyką i pancerzem strefowym wrogów. Silnik: Godot 4.7, modele: Blender sterowany skryptami. Całość kodu i zasobów tworzy Claude.

## Stan

**Build 1 — Strzelnica.** Ruch, karabinek „Kwarc” i pistolet „Jaspis”, balistyka, penetracja, tarcze z klasami pancerza 0–5, manekin rycerza z pancerzem strefowym, stół amunicyjny, panel strojenia.

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
| L | Latarka |
| F | Użyj: stół amunicyjny, podniesienie magazynka |
| G | Wyczyszczenie tarcz |
| F1 | Panel strojenia (odrzut, kołysanie, czułość, pikselizacja) |
| F2 | Język PL / EN |
| H | Pomoc |
