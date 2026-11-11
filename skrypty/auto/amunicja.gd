extends Node
## Baza amunicji i jedna reguła penetracji dla całej gry.
## Próg klasy pancerza = klasa × 10. Wartości startowe, do strojenia.

const TYPY := {
	"A_9_FMJ": {"kaliber": "9x19", "obr": 50.0, "przeb": 16.0, "v0": 360.0, "opor": 0.0018, "halas": 0.80, "smuga": false},
	"A_9_HP": {"kaliber": "9x19", "obr": 72.0, "przeb": 6.0, "v0": 350.0, "opor": 0.0021, "halas": 0.80, "smuga": false},
	"A_9_AP": {"kaliber": "9x19", "obr": 44.0, "przeb": 26.0, "v0": 400.0, "opor": 0.0017, "halas": 0.85, "smuga": false},
	"A_9_SUB": {"kaliber": "9x19", "obr": 48.0, "przeb": 14.0, "v0": 300.0, "opor": 0.0016, "halas": 0.55, "smuga": false},
	"A_556_FMJ": {"kaliber": "5.56x45", "obr": 54.0, "przeb": 31.0, "v0": 920.0, "opor": 0.00142, "halas": 1.0, "smuga": false},
	"A_556_SS": {"kaliber": "5.56x45", "obr": 50.0, "przeb": 40.0, "v0": 900.0, "opor": 0.00135, "halas": 1.0, "smuga": false},
	"A_556_AP": {"kaliber": "5.56x45", "obr": 46.0, "przeb": 52.0, "v0": 940.0, "opor": 0.00130, "halas": 1.0, "smuga": false},
	"A_556_T": {"kaliber": "5.56x45", "obr": 52.0, "przeb": 29.0, "v0": 900.0, "opor": 0.00150, "halas": 1.0, "smuga": true},
	"A_45_FMJ": {"kaliber": ".45", "obr": 68.0, "przeb": 14.0, "v0": 260.0, "opor": 0.0020, "halas": 0.75, "smuga": false},
	"A_45_HP": {"kaliber": ".45", "obr": 95.0, "przeb": 4.0, "v0": 250.0, "opor": 0.0023, "halas": 0.75, "smuga": false},
	"A_12_SRUT": {"kaliber": "12/70", "obr": 22.0, "przeb": 3.0, "v0": 400.0, "opor": 0.0060, "halas": 1.05, "smuga": false, "srut": 8},
	"A_12_BRENEKA": {"kaliber": "12/70", "obr": 160.0, "przeb": 22.0, "v0": 430.0, "opor": 0.0030, "halas": 1.05, "smuga": false},
	"A_762_PS": {"kaliber": "7.62x39", "obr": 62.0, "przeb": 33.0, "v0": 715.0, "opor": 0.00170, "halas": 1.0, "smuga": false},
	"A_762_HP": {"kaliber": "7.62x39", "obr": 85.0, "przeb": 17.0, "v0": 700.0, "opor": 0.00190, "halas": 1.0, "smuga": false},
	"A_762_AP": {"kaliber": "7.62x39", "obr": 56.0, "przeb": 45.0, "v0": 730.0, "opor": 0.00160, "halas": 1.0, "smuga": false},
	"A_76251_FMJ": {"kaliber": "7.62x51", "obr": 82.0, "przeb": 43.0, "v0": 840.0, "opor": 0.00110, "halas": 1.1, "smuga": false},
	"A_76251_AP": {"kaliber": "7.62x51", "obr": 72.0, "przeb": 62.0, "v0": 850.0, "opor": 0.00105, "halas": 1.1, "smuga": false},
}

## kaliber: [przyrostek id przedmiotów, ładunki prochu na nabój, wielkość partii przy składaniu]
const KALIBRY := {
	"9x19": ["9", 1, 30], ".45": ["45", 1, 30], "5.56x45": ["556", 2, 30],
	"7.62x39": ["762x39", 2, 30], "7.62x51": ["762x51", 3, 20], "12/70": ["12", 2, 10],
}
## typy wymagające stali na rdzeń
const ZE_STALA := ["A_9_AP", "A_556_SS", "A_556_AP", "A_762_AP", "A_76251_AP"]


func paczka(kaliber: String) -> String:
	return "paczka_" + String(KALIBRY[kaliber][0])


func luski(kaliber: String) -> String:
	return "luski_" + String(KALIBRY[kaliber][0])


func dla_kalibru(kaliber: String) -> Array:
	var wynik := []
	for k in TYPY:
		if TYPY[k]["kaliber"] == kaliber:
			wynik.append(k)
	return wynik


## Rozstrzyga trafienie pocisku w płytę pancerza.
## przeb_akt i obr_akt to wartości już przeskalowane prędkością pocisku.
## cos_kata: 1 = trafienie prostopadłe. stan: 1 = płyta cała, 0 = rozbita.
func rozstrzygnij(przeb_akt: float, obr_akt: float, klasa: int, stan: float, cos_kata: float, los: float) -> Dictionary:
	var prog := float(klasa) * 10.0 * lerpf(0.6, 1.0, clampf(stan, 0.0, 1.0))
	if stan <= 0.0:
		prog = 0.0
	prog /= clampf(cos_kata, 0.6, 1.0)
	var brak := prog - przeb_akt
	var w := {"wynik": "PRZEBICIE", "obr": obr_akt, "tepe": false, "uszk": 0.0, "przechodzi": true, "prog": prog}
	if klasa <= 0 or brak <= 1.0:
		w["uszk"] = 0.03 + 0.0005 * przeb_akt
		return w
	if brak <= 10.0:
		if los < 0.5:
			w["wynik"] = "CZESCIOWE"
			w["obr"] = obr_akt * 0.5
			w["uszk"] = 0.08
			return w
		w["wynik"] = "ZATRZYMANY"
		w["obr"] = obr_akt * 0.12
		w["tepe"] = true
		w["uszk"] = 0.08
		w["przechodzi"] = false
		return w
	w["wynik"] = "RYKOSZET" if cos_kata < 0.75 else "ZATRZYMANY"
	w["obr"] = obr_akt * 0.10
	w["tepe"] = true
	w["uszk"] = 0.015 + 0.0004 * obr_akt
	w["przechodzi"] = false
	return w
