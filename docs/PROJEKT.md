# Projekt gry — skrót

Pełny dokument projektowy (analiza konceptu, mechaniki, listy przedmiotów, zakres 1.0):
https://claude.ai/artifact/RcsnVzZSz4ymGT9bPiWBNW

## Filary

1. Kaliber ma znaczenie: wybór broni i naboju przed wyprawą to najważniejsza decyzja.
2. Każdy nabój jest policzony: amunicji jest zawsze trochę za mało, a jej źródłem jest praca gracza.
3. Mrok i hałas: gracz widzi tyle, ile oświetli, a loch słyszy wszystko.
4. Chciwość zabija: im głębiej i dłużej, tym lepszy łup i mniejsza szansa na powrót.

## Pętla wyprawy (45–75 minut)

Odprawa w bazie → wejście do losowego lochu → eksploracja, walka, kopanie rudy, oprawianie → decyzja: wracać czy zejść niżej → ekstrakcja → baza: wytop, produkcja amunicji, leczenie, zadania dla pozostałych żołnierzy.

## Penetracja

Każdy nabój ma przebicie, każda strefa ciała wroga klasę pancerza 0–6. Próg = klasa × 10.

| Przebicie względem progu | Skutek |
| --- | --- |
| Równe lub wyższe | Pełne obrażenia |
| Niższe o 1–10 | 50% szans na przebicie z połową obrażeń |
| Niższe o ponad 10 | Zatrzymanie lub rykoszet, 10–12% obrażeń tępych |

Pancerz jest strefowy, niszczy się od trafień, a jego klasy gracz poznaje przez bestiariusz.

## Amunicja w buildzie 1

| Nabój | Obrażenia | Przebicie | Prędkość m/s |
| --- | --- | --- | --- |
| 9×19 pełnopłaszczowy | 50 | 16 | 360 |
| 9×19 grzybkujący | 72 | 6 | 350 |
| 9×19 przeciwpancerny | 44 | 26 | 400 |
| 9×19 poddźwiękowy | 48 | 14 | 300 |
| 5,56×45 pełnopłaszczowy | 54 | 31 | 920 |
| 5,56×45 z rdzeniem stalowym | 50 | 40 | 900 |
| 5,56×45 przeciwpancerny | 46 | 52 | 940 |
| 5,56×45 smugowy | 52 | 29 | 900 |
