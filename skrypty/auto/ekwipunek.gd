extends Node
## Ekwipunek żołnierza. Przetrwa zmianę lokacji; ginie razem z żołnierzem
## (poza relikwiarzem). Pojemność zależy od kamizelki i plecaka.

signal zmiana
signal komunikat(tekst: String)

## id: nazwa (klucz), w × h pól, masa kg, typ, kolor kafelka; dodatkowe pola wg typu
const PRZEDMIOTY := {
	"mag_kwarc": {"nazwa": "P_MAG_KWARC", "w": 1, "h": 2, "masa": 0.12, "typ": "mag", "kolor": "3d3a33", "bron": "kwarc", "poj": 30, "kaliber": "5.56x45"},
	"mag_jaspis": {"nazwa": "P_MAG_JASPIS", "w": 1, "h": 1, "masa": 0.08, "typ": "mag", "kolor": "34363a", "bron": "jaspis", "poj": 15, "kaliber": "9x19"},
	"mag_granit": {"nazwa": "P_MAG_GRANIT", "w": 1, "h": 2, "masa": 0.33, "typ": "mag", "kolor": "4a2a1c", "bron": "granit", "poj": 30, "kaliber": "7.62x39"},
	"mag_gabro": {"nazwa": "P_MAG_GABRO", "w": 1, "h": 2, "masa": 0.15, "typ": "mag", "kolor": "2e3034", "bron": "gabro", "poj": 25, "kaliber": "9x19"},
	"mag_krzemien": {"nazwa": "P_MAG_KRZEMIEN", "w": 1, "h": 1, "masa": 0.20, "typ": "mag", "kolor": "3a3d2e", "bron": "krzemien", "poj": 10, "kaliber": "7.62x51"},
	"mag_weteran": {"nazwa": "P_MAG_WETERAN", "w": 1, "h": 1, "masa": 0.07, "typ": "mag", "kolor": "4a4d51", "bron": "weteran", "poj": 7, "kaliber": ".45"},
	"rura_lupek": {"nazwa": "BRON_LUPEK", "w": 1, "h": 1, "masa": 0.0, "typ": "wewn", "kolor": "232427", "bron": "lupek", "poj": 6, "kaliber": "12/70"},
	"paczka_556": {"nazwa": "P_PACZKA_556", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "5a5231", "kaliber": "5.56x45", "poj": 30},
	"paczka_9": {"nazwa": "P_PACZKA_9", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "5a4a31", "kaliber": "9x19", "poj": 50},
	"bandaz": {"nazwa": "LEK_BANDAZ", "w": 1, "h": 1, "masa": 0.05, "typ": "lek", "kolor": "8a8676"},
	"opatrunek": {"nazwa": "LEK_OPATRUNEK", "w": 1, "h": 1, "masa": 0.08, "typ": "lek", "kolor": "7d6f52"},
	"szyna": {"nazwa": "LEK_SZYNA", "w": 1, "h": 2, "masa": 0.30, "typ": "lek", "kolor": "6f7462"},
	"apteczka": {"nazwa": "LEK_APTECZKA", "w": 2, "h": 1, "masa": 0.55, "typ": "lek", "kolor": "7a2f28"},
	"przeciwbolowe": {"nazwa": "LEK_PRZECIWBOLOWE", "w": 1, "h": 1, "masa": 0.03, "typ": "lek", "kolor": "8c8a80"},
	"konserwa": {"nazwa": "P_KONSERWA", "w": 1, "h": 1, "masa": 0.40, "typ": "jedzenie", "kolor": "6b6f72", "sytosc": 55.0, "woda": 0.0},
	"suchary": {"nazwa": "P_SUCHARY", "w": 1, "h": 1, "masa": 0.20, "typ": "jedzenie", "kolor": "8a7a52", "sytosc": 25.0, "woda": -5.0},
	"racja": {"nazwa": "P_RACJA", "w": 1, "h": 2, "masa": 0.55, "typ": "jedzenie", "kolor": "5b5a3c", "sytosc": 80.0, "woda": 10.0},
	"manierka": {"nazwa": "P_MANIERKA", "w": 1, "h": 2, "masa": 0.30, "typ": "picie", "kolor": "4f5a3e", "woda": 35.0, "porcje": 3},
	"buklak": {"nazwa": "P_BUKLAK", "w": 1, "h": 1, "masa": 0.15, "typ": "picie", "kolor": "5c4630", "woda": 35.0, "porcje": 1},
	"paczka_45": {"nazwa": "P_PACZKA_45", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "5a4431", "kaliber": ".45", "poj": 50},
	"paczka_12": {"nazwa": "P_PACZKA_12", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "6a2f28", "kaliber": "12/70", "poj": 25},
	"paczka_762x39": {"nazwa": "P_PACZKA_762X39", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "5a4f2a", "kaliber": "7.62x39", "poj": 30},
	"paczka_762x51": {"nazwa": "P_PACZKA_762X51", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "4f5a2a", "kaliber": "7.62x51", "poj": 20},
	"luski_9": {"nazwa": "P_LUSKI_9", "w": 1, "h": 1, "masa": 0.004, "typ": "surowiec", "kolor": "8a742e", "stos": 120},
	"luski_45": {"nazwa": "P_LUSKI_45", "w": 1, "h": 1, "masa": 0.006, "typ": "surowiec", "kolor": "8a742e", "stos": 120},
	"luski_556": {"nazwa": "P_LUSKI_556", "w": 1, "h": 1, "masa": 0.006, "typ": "surowiec", "kolor": "8a742e", "stos": 120},
	"luski_12": {"nazwa": "P_LUSKI_12", "w": 1, "h": 1, "masa": 0.008, "typ": "surowiec", "kolor": "7a3a2e", "stos": 60},
	"luski_762x39": {"nazwa": "P_LUSKI_762X39", "w": 1, "h": 1, "masa": 0.007, "typ": "surowiec", "kolor": "6f6a3e", "stos": 120},
	"luski_762x51": {"nazwa": "P_LUSKI_762X51", "w": 1, "h": 1, "masa": 0.011, "typ": "surowiec", "kolor": "8a742e", "stos": 80},
	"kilof": {"nazwa": "P_KILOF", "w": 1, "h": 3, "masa": 2.4, "typ": "narzedzie", "kolor": "4a3a2a"},
	"ruda_miedzi": {"nazwa": "P_RUDA_MIEDZI", "w": 1, "h": 1, "masa": 1.5, "typ": "surowiec", "kolor": "5a6f52", "stos": 4},
	"ruda_olowiu": {"nazwa": "P_RUDA_OLOWIU", "w": 1, "h": 1, "masa": 1.8, "typ": "surowiec", "kolor": "55585f", "stos": 4},
	"ruda_zelaza": {"nazwa": "P_RUDA_ZELAZA", "w": 1, "h": 1, "masa": 1.6, "typ": "surowiec", "kolor": "6a4a3a", "stos": 4},
	"siarka": {"nazwa": "P_SIARKA", "w": 1, "h": 1, "masa": 0.3, "typ": "surowiec", "kolor": "9a8f2e", "stos": 10},
	"saletra": {"nazwa": "P_SALETRA", "w": 1, "h": 1, "masa": 0.3, "typ": "surowiec", "kolor": "9a9a90", "stos": 10},
	"wegiel": {"nazwa": "P_WEGIEL", "w": 1, "h": 1, "masa": 0.2, "typ": "surowiec", "kolor": "232323", "stos": 10},
	"sztabka_mosiadzu": {"nazwa": "P_SZT_MOSIADZ", "w": 1, "h": 1, "masa": 0.5, "typ": "surowiec", "kolor": "a8842e", "stos": 10},
	"sztabka_olowiu": {"nazwa": "P_SZT_OLOW", "w": 1, "h": 1, "masa": 0.6, "typ": "surowiec", "kolor": "5c5f66", "stos": 10},
	"sztabka_stali": {"nazwa": "P_SZT_STAL", "w": 1, "h": 1, "masa": 0.5, "typ": "surowiec", "kolor": "7a7f86", "stos": 10},
	"proch": {"nazwa": "P_PROCH", "w": 1, "h": 1, "masa": 0.003, "typ": "surowiec", "kolor": "2e2a26", "stos": 300},
	"splonki": {"nazwa": "P_SPLONKI", "w": 1, "h": 1, "masa": 0.001, "typ": "surowiec", "kolor": "b08d57", "stos": 300},
	"kosc": {"nazwa": "P_KOSC", "w": 1, "h": 1, "masa": 0.3, "typ": "surowiec", "kolor": "b9b29a", "stos": 6},
	"sciegna": {"nazwa": "P_SCIEGNA", "w": 1, "h": 1, "masa": 0.1, "typ": "surowiec", "kolor": "8a5a52", "stos": 6},
	"gruczol": {"nazwa": "P_GRUCZOL", "w": 1, "h": 1, "masa": 0.15, "typ": "surowiec", "kolor": "5a7a3a", "stos": 4},
	"kolimator": {"nazwa": "P_KOLIMATOR", "w": 1, "h": 1, "masa": 0.12, "typ": "dodatek", "kolor": "2a2c30", "slot": "szyna", "pasuje": ["kwarc", "granit", "gabro"]},
	"holo": {"nazwa": "P_HOLO", "w": 1, "h": 1, "masa": 0.30, "typ": "dodatek", "kolor": "2a2c30", "slot": "szyna", "pasuje": ["kwarc", "granit", "gabro"]},
	"tlumik_9": {"nazwa": "P_TLUMIK_9", "w": 1, "h": 1, "masa": 0.20, "typ": "dodatek", "kolor": "1f2022", "slot": "wylot", "pasuje": ["jaspis", "gabro"]},
	"tlumik_kar": {"nazwa": "P_TLUMIK_KAR", "w": 1, "h": 2, "masa": 0.45, "typ": "dodatek", "kolor": "1f2022", "slot": "wylot", "pasuje": ["kwarc", "granit"]},
	"chwyt_przedni": {"nazwa": "P_CHWYT", "w": 1, "h": 1, "masa": 0.11, "typ": "dodatek", "kolor": "26282b", "slot": "chwyt", "pasuje": ["kwarc", "granit", "gabro"]},
	"monety": {"nazwa": "P_MONETY", "w": 1, "h": 1, "masa": 0.15, "typ": "lup", "kolor": "8f7a2e"},
	"serce_trolla": {"nazwa": "P_SERCE_TROLLA", "w": 2, "h": 2, "masa": 2.4, "typ": "lup", "kolor": "5a6a58"},
	"relikwia": {"nazwa": "P_RELIKWIA", "w": 1, "h": 2, "masa": 0.60, "typ": "lup", "kolor": "6e5a7a"},
	"klucz": {"nazwa": "P_KLUCZ", "w": 1, "h": 1, "masa": 0.05, "typ": "lup", "kolor": "5c5f63"},
	"pas": {"nazwa": "P_PAS", "w": 2, "h": 1, "masa": 0.5, "typ": "kamizelka", "kolor": "4a4a36", "siatka": Vector2i(4, 1)},
	"chest_rig": {"nazwa": "P_CHEST_RIG", "w": 2, "h": 2, "masa": 1.1, "typ": "kamizelka", "kolor": "4a4f36", "siatka": Vector2i(5, 2)},
	"torba": {"nazwa": "P_TORBA", "w": 2, "h": 1, "masa": 0.3, "typ": "plecak", "kolor": "55503a", "siatka": Vector2i(2, 2)},
	"chlebak": {"nazwa": "P_CHLEBAK", "w": 2, "h": 2, "masa": 0.6, "typ": "plecak", "kolor": "5a5a40", "siatka": Vector2i(3, 3)},
	"plecak_szturmowy": {"nazwa": "P_PLECAK_SZT", "w": 3, "h": 3, "masa": 1.2, "typ": "plecak", "kolor": "454a34", "siatka": Vector2i(4, 5)},
	"plecak_patrolowy": {"nazwa": "P_PLECAK_PAT", "w": 3, "h": 4, "masa": 1.8, "typ": "plecak", "kolor": "3f4530", "siatka": Vector2i(5, 6)},
}
const MASA_NABOJU := {"5.56x45": 0.012, "9x19": 0.012, ".45": 0.021, "12/70": 0.045, "7.62x39": 0.016, "7.62x51": 0.024}
const LIMIT_LEKKI := 25.0
const LIMIT_CIEZKI := 40.0

var kieszenie: Pojemnik
var kamizelka: Pojemnik
var plecak: Pojemnik            ## null, gdy plecak zrzucony albo brak
var relikwiarz: Pojemnik
var kamizelka_p := {}           ## przedmiot kamizelki
var plecak_p := {}              ## przedmiot plecaka ({} = brak)
var bron_glowna := "kwarc"
var bron_boczna := "jaspis"
var stan_broni := {}            ## id broni -> {"mag": przedmiot albo {}, "komora": typ}
var ladowanie := {}             ## trwające ładowanie magazynka: {mag, paczka, t}
var skrytka: Pojemnik           ## skrytka w bazie
var sytosc := 100.0             ## 0..100
var nawodnienie := 100.0        ## 0..100
var na_wyprawie := false        ## ustawiane przy wyjściu z bazy; wyjście z gry w lochu bez biwaku = strata żołnierza
var wyprawy := 0
var polegli := 0
var komunikat_startowy := ""
var zapis_wlaczony := true      ## testy wyłączają zapis na dysk

const PLIK_BAZY := "user://baza.sav"
const PLIK_BIWAKU := "user://biwak.sav"


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--test") or a.begins_with("--zrzut"):
			zapis_wlaczony = false
	skrytka = Pojemnik.new(10, 14, "E_SKRYTKA")
	nowy_zestaw()
	_zapas_startowy()
	nowy_pluton()
	if zapis_wlaczony and wczytaj_baze():
		if na_wyprawie and not FileAccess.file_exists(PLIK_BIWAKU):
			# gra została zamknięta w lochu bez biwaku: żołnierz nie wrócił
			po_smierci()
			komunikat_startowy = "POLEGL_BEZ_BIWAKU"
			zapisz_baze()


## Pierwsze wyposażenie skrytki w nowej kampanii.
func _zapas_startowy() -> void:
	for i in 4:
		skrytka.wloz_gdziekolwiek(nowy_magazynek("mag_kwarc", "A_556_FMJ"))
	for i in 2:
		skrytka.wloz_gdziekolwiek(nowy_magazynek("mag_jaspis", "A_9_FMJ"))
	for id in ["paczka_556", "paczka_556", "paczka_556"]:
		skrytka.wloz_gdziekolwiek(nowa_paczka(id, "A_556_FMJ"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_556", "A_556_SS"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_556", "A_556_AP", 20))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_9", "A_9_FMJ"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_9", "A_9_HP"))
	skrytka.wloz_gdziekolwiek(nowy("kilof"))
	skrytka.wloz_gdziekolwiek(nowy("kolimator"))
	skrytka.wloz_gdziekolwiek(nowy("chwyt_przedni"))
	skrytka.wloz_gdziekolwiek(nowy("holo"))
	skrytka.wloz_gdziekolwiek(nowy("tlumik_9"))
	for id in ["konserwa", "konserwa", "suchary", "suchary", "racja"]:
		skrytka.wloz_gdziekolwiek(nowy(id))
	for i in 4:
		skrytka.wloz_gdziekolwiek(nowy_magazynek("mag_granit", "A_762_PS"))
		skrytka.wloz_gdziekolwiek(nowy_magazynek("mag_gabro", "A_9_FMJ"))
	for i in 3:
		skrytka.wloz_gdziekolwiek(nowy_magazynek("mag_krzemien", "A_76251_FMJ"))
		skrytka.wloz_gdziekolwiek(nowy_magazynek("mag_weteran", "A_45_FMJ"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_762x39", "A_762_PS"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_762x39", "A_762_HP"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_12", "A_12_SRUT"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_12", "A_12_BRENEKA", 15))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_762x51", "A_76251_FMJ"))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_762x51", "A_76251_AP", 10))
	skrytka.wloz_gdziekolwiek(nowa_paczka("paczka_45", "A_45_FMJ", 35))
	dodaj_zasob("splonki", 120, true)
	dodaj_zasob("proch", 60, true)
	for id in ["racja", "racja", "racja", "konserwa", "konserwa", "suchary", "manierka", "bandaz", "bandaz", "bandaz", "opatrunek", "opatrunek", "szyna", "apteczka", "przeciwbolowe", "pas", "chlebak", "plecak_patrolowy"]:
		skrytka.wloz_gdziekolwiek(nowy(id))


static func nowy(id: String, dane := {}) -> Dictionary:
	var d: Dictionary = dane.duplicate()
	if PRZEDMIOTY[id].has("porcje") and not d.has("porcje"):
		d["porcje"] = PRZEDMIOTY[id]["porcje"]
	return {"id": id, "x": 0, "y": 0, "obr": false, "dane": d, "odkryty": true}


func nowy_magazynek(id: String, typ_a: String, typ_b := "", ile := -1) -> Dictionary:
	var poj: int = PRZEDMIOTY[id]["poj"]
	var n := poj if ile < 0 else mini(ile, poj)
	var naboje := []
	for i in n:
		naboje.append(typ_b if typ_b != "" and i % 3 == 2 else typ_a)
	return nowy(id, {"naboje": naboje})


func nowa_paczka(id: String, typ: String, ile := -1) -> Dictionary:
	return nowy(id, {"typ": typ, "ile": PRZEDMIOTY[id]["poj"] if ile < 0 else ile})


## Minimalny przydział: to, co baza wydaje każdemu żołnierzowi.
func nowy_zestaw() -> void:
	kieszenie = Pojemnik.new(4, 1, "E_KIESZENIE")
	relikwiarz = Pojemnik.new(2, 2, "E_RELIKWIARZ")
	_zaloz_kamizelke(nowy("chest_rig"))
	_zaloz_plecak(nowy("plecak_szturmowy"))
	for i in 4:
		kamizelka.wloz_gdziekolwiek(nowy_magazynek("mag_kwarc", "A_556_FMJ"))
	for i in 2:
		kamizelka.wloz_gdziekolwiek(nowy_magazynek("mag_jaspis", "A_9_FMJ"))
	kieszenie.wloz_gdziekolwiek(nowy("bandaz"))
	kieszenie.wloz_gdziekolwiek(nowy("bandaz"))
	kieszenie.wloz_gdziekolwiek(nowy_magazynek("mag_jaspis", "A_9_FMJ"))
	for id in ["opatrunek", "szyna", "apteczka", "przeciwbolowe", "przeciwbolowe"]:
		plecak.wloz_gdziekolwiek(nowy(id))
	plecak.wloz_gdziekolwiek(nowa_paczka("paczka_556", "A_556_FMJ"))
	plecak.wloz_gdziekolwiek(nowa_paczka("paczka_556", "A_556_SS"))
	plecak.wloz_gdziekolwiek(nowa_paczka("paczka_9", "A_9_FMJ"))
	plecak.wloz_gdziekolwiek(nowy("racja"))
	plecak.wloz_gdziekolwiek(nowy("manierka"))
	sytosc = 100.0
	nawodnienie = 100.0
	bron_glowna = "kwarc"
	bron_boczna = "jaspis"
	stan_broni = {
		"kwarc": {"mag": nowy_magazynek("mag_kwarc", "A_556_FMJ", "", 29), "komora": "A_556_FMJ"},
		"jaspis": {"mag": nowy_magazynek("mag_jaspis", "A_9_FMJ", "", 14), "komora": "A_9_FMJ"},
	}
	ladowanie = {}
	zmiana.emit()


## Śmierć żołnierza: zostaje tylko zawartość relikwiarza.
func po_smierci() -> void:
	var ocalone := relikwiarz.rzeczy.duplicate()
	nowy_zestaw()
	for p in ocalone:
		relikwiarz.wloz(p, p["x"], p["y"], p["obr"])
	na_wyprawie = false
	polegli += 1
	if not pluton.is_empty():
		pluton[aktywny]["zyje"] = false
		rozlicz_wyprawe(0)
	zmiana.emit()


## Stan broni z plutonowej zbrojowni; przy pierwszym użyciu broń ma załadowany magazynek.
func stan(id: String) -> Dictionary:
	if not stan_broni.has(id):
		var bd: Dictionary = Bron.DANE[id]
		var m: Dictionary
		if bd.get("rurowy", false):
			var naboje := []
			for i in int(bd["poj"]) - 1:
				naboje.append(bd["amunicja"])
			m = nowy("rura_" + id, {"naboje": naboje})
		else:
			m = nowy_magazynek("mag_" + id, bd["amunicja"], "", int(bd["poj"]) - 1)
		stan_broni[id] = {"mag": m, "komora": bd["amunicja"]}
	return stan_broni[id]


func _zaloz_kamizelke(p: Dictionary) -> void:
	kamizelka_p = p
	var s: Vector2i = PRZEDMIOTY[p["id"]]["siatka"]
	kamizelka = Pojemnik.new(s.x, s.y, "E_KAMIZELKA")


func _zaloz_plecak(p: Dictionary) -> void:
	plecak_p = p
	var s: Vector2i = PRZEDMIOTY[p["id"]]["siatka"]
	plecak = p["dane"].get("pojemnik", null)
	if plecak == null:
		plecak = Pojemnik.new(s.x, s.y, "E_PLECAK")
		p["dane"]["pojemnik"] = plecak


## Zakłada plecak podniesiony z ziemi. Zwraca false, gdy plecak już jest na plecach.
func zaloz_plecak(p: Dictionary) -> bool:
	if not plecak_p.is_empty():
		return false
	_zaloz_plecak(p)
	zmiana.emit()
	return true


## Zdejmuje plecak z zawartością; zwraca przedmiot do położenia w świecie.
func zdejmij_plecak() -> Dictionary:
	var p := plecak_p
	plecak_p = {}
	plecak = null
	zmiana.emit()
	return p


func pojemniki() -> Array:
	var l := [kieszenie, kamizelka]
	if plecak != null:
		l.append(plecak)
	l.append(relikwiarz)
	return l


func szybkie() -> Array:
	return [kamizelka, kieszenie]


func masa_przedmiotu(p: Dictionary) -> float:
	var def: Dictionary = PRZEDMIOTY[p["id"]]
	var m: float = def["masa"]
	var dane: Dictionary = p["dane"]
	if dane.has("naboje"):
		m += dane["naboje"].size() * float(MASA_NABOJU[def["kaliber"]])
	if dane.has("ile"):
		if def.has("kaliber"):
			m += int(dane["ile"]) * float(MASA_NABOJU[def["kaliber"]])
		else:
			m = float(def["masa"]) * int(dane["ile"])
	if dane.has("porcje"):
		m += int(dane["porcje"]) * 0.33
	if dane.has("pojemnik") and dane["pojemnik"] != null:
		m += (dane["pojemnik"] as Pojemnik).masa()
	return m


func masa() -> float:
	var m: float = float(Bron.DANE[bron_glowna]["masa"]) + float(Bron.DANE[bron_boczna]["masa"]) + kieszenie.masa() + kamizelka.masa() + relikwiarz.masa()
	m += masa_przedmiotu(kamizelka_p)
	if not plecak_p.is_empty():
		m += masa_przedmiotu(plecak_p)
	for id in [bron_glowna, bron_boczna]:
		var mg: Dictionary = stan(id)["mag"]
		if not mg.is_empty():
			m += masa_przedmiotu(mg)
	return m


## Mnożnik prędkości od obciążenia: do 25 kg bez kary, przy 40 kg i więcej 0,7.
func mnoznik_ruchu() -> float:
	return lerpf(1.0, 0.7, clampf((masa() - LIMIT_LEKKI) / (LIMIT_CIEZKI - LIMIT_LEKKI), 0.0, 1.0))


func moze_sprintowac() -> bool:
	return masa() < LIMIT_CIEZKI


func mnoznik_halasu() -> float:
	return (1.0 + clampf((masa() - 15.0) / 30.0, 0.0, 1.0) * 0.8) * mod("halas")


## Magazynki do danej broni dostępne od ręki (kamizelka i kieszenie).
func magazynki(id_broni: String) -> Array:
	var l := []
	for poj in szybkie():
		for p in poj.rzeczy:
			var def: Dictionary = PRZEDMIOTY[p["id"]]
			if def["typ"] == "mag" and def["bron"] == id_broni:
				l.append(p)
	return l


func wszystkie_magazynki(id_broni: String) -> Array:
	var l := []
	for poj in pojemniki():
		for p in poj.rzeczy:
			var def: Dictionary = PRZEDMIOTY[p["id"]]
			if def["typ"] == "mag" and def["bron"] == id_broni:
				l.append(p)
	return l


func pojemnik_przedmiotu(p: Dictionary) -> Pojemnik:
	for poj in pojemniki():
		for r in poj.rzeczy:
			if is_same(r, p):
				return poj
	return null


func wyjmij(p: Dictionary) -> void:
	var poj := pojemnik_przedmiotu(p)
	if poj != null:
		poj.usun(p)
		zmiana.emit()


## Wkłada tam, skąd da się szybko wyjąć; preferuje wskazane miejsce.
func wloz_do_szybkich(p: Dictionary, gdzie: Pojemnik = null, x := 0, y := 0, obr := false) -> bool:
	if gdzie != null and gdzie.wloz(p, x, y, obr):
		zmiana.emit()
		return true
	for poj in szybkie():
		if poj.wloz_gdziekolwiek(p):
			zmiana.emit()
			return true
	return false


## Podniesienie z ziemi: kieszenie, kamizelka, plecak.
func podnies(p: Dictionary) -> bool:
	var typ: String = PRZEDMIOTY[p["id"]]["typ"]
	if typ == "plecak" and plecak_p.is_empty():
		return zaloz_plecak(p)
	var kolejnosc := [kamizelka, kieszenie] if typ == "mag" else [kieszenie, kamizelka]
	if plecak != null:
		kolejnosc.append(plecak)
	for poj in kolejnosc:
		if poj.wloz_gdziekolwiek(p):
			zmiana.emit()
			return true
	return false


func leki() -> Dictionary:
	var l := {}
	for id in Zdrowie.KOLEJNOSC:
		l[id] = 0
	for poj in pojemniki():
		for p in poj.rzeczy:
			if l.has(p["id"]):
				l[p["id"]] += 1
	return l


func zuzyj_lek(id: String) -> bool:
	for poj in [kieszenie, kamizelka, plecak, relikwiarz]:
		if poj == null:
			continue
		for p in poj.rzeczy:
			if p["id"] == id:
				poj.usun(p)
				zmiana.emit()
				return true
	return false


## Ładowanie magazynka luźnymi nabojami z paczki: jeden nabój co 0,35 s.
func zacznij_ladowanie(mag: Dictionary, paczka: Dictionary) -> bool:
	var dm: Dictionary = PRZEDMIOTY[mag["id"]]
	var dp: Dictionary = PRZEDMIOTY[paczka["id"]]
	if dm["typ"] != "mag" or dp["typ"] != "amunicja" or dm["kaliber"] != dp["kaliber"]:
		return false
	if mag["dane"]["naboje"].size() >= dm["poj"] or int(paczka["dane"]["ile"]) <= 0:
		return false
	ladowanie = {"mag": mag, "paczka": paczka, "t": 0.0}
	return true


func przerwij_ladowanie() -> void:
	ladowanie = {}


func _process(dt: float) -> void:
	if ladowanie.is_empty():
		return
	ladowanie["t"] += dt
	if ladowanie["t"] < 0.35:
		return
	ladowanie["t"] = 0.0
	var mag: Dictionary = ladowanie["mag"]
	var paczka: Dictionary = ladowanie["paczka"]
	mag["dane"]["naboje"].append(paczka["dane"]["typ"])
	paczka["dane"]["ile"] = int(paczka["dane"]["ile"]) - 1
	Dzwiek.przy_uchu("klik", -12.0, 0.2)
	if int(paczka["dane"]["ile"]) <= 0:
		wyjmij(paczka)
		ladowanie = {}
	elif mag["dane"]["naboje"].size() >= int(PRZEDMIOTY[mag["id"]]["poj"]):
		ladowanie = {}
	zmiana.emit()


## Opis stanu magazynka „na oko”.
func opis_magazynka(p: Dictionary) -> String:
	var r := float(p["dane"]["naboje"].size()) / float(PRZEDMIOTY[p["id"]]["poj"])
	var k := "MAG_PUSTY"
	if r >= 1.0:
		k = "MAG_PELNY"
	elif r >= 0.85:
		k = "MAG_PRAWIE_PELNY"
	elif r >= 0.6:
		k = "MAG_PONAD_POL"
	elif r >= 0.4:
		k = "MAG_POLOWA"
	elif r >= 0.15:
		k = "MAG_MNIEJ_POL"
	elif r > 0.0:
		k = "MAG_PRAWIE_PUSTY"
	return tr(k)


# ====================================================================== noszone rzeczy

## Zakłada kamizelkę albo plecak leżący w pojemniku `zrodlo`; stary trafia na jego miejsce.
func zamien_noszone(p: Dictionary, zrodlo: Pojemnik) -> bool:
	var typ: String = PRZEDMIOTY[p["id"]]["typ"]
	if typ == "kamizelka":
		var s: Vector2i = PRZEDMIOTY[p["id"]]["siatka"]
		var nowa := Pojemnik.new(s.x, s.y, "E_KAMIZELKA")
		var kolejka := kamizelka.rzeczy.duplicate()
		kolejka.sort_custom(func(a, b): return Pojemnik.wymiary(a, false).y > Pojemnik.wymiary(b, false).y)
		for r in kolejka:
			if not nowa.wloz_gdziekolwiek(r.duplicate()):
				return false
		var stara := kamizelka_p
		zrodlo.usun(p)
		if not zrodlo.wloz_gdziekolwiek(stara):
			zrodlo.wloz(p, p["x"], p["y"], p["obr"])
			return false
		kamizelka_p = p
		kamizelka = nowa
		zmiana.emit()
		return true
	if typ == "plecak":
		var stary := plecak_p
		zrodlo.usun(p)
		if not stary.is_empty() and not zrodlo.wloz_gdziekolwiek(stary):
			zrodlo.wloz(p, p["x"], p["y"], p["obr"])
			return false
		plecak_p = {}
		_zaloz_plecak(p)
		zmiana.emit()
		return true
	return false


# ====================================================================== głód i pragnienie

## Spożycie jedzenia albo picia. Zwraca false, gdy przedmiot się do tego nie nadaje.
func spozyj(p: Dictionary) -> bool:
	var def: Dictionary = PRZEDMIOTY[p["id"]]
	if def["typ"] == "jedzenie":
		sytosc = clampf(sytosc + float(def["sytosc"]), 0.0, 100.0)
		nawodnienie = clampf(nawodnienie + float(def["woda"]), 0.0, 100.0)
		wyjmij(p)
		return true
	if def["typ"] == "picie":
		if int(p["dane"].get("porcje", 0)) <= 0:
			return false
		nawodnienie = clampf(nawodnienie + float(def["woda"]), 0.0, 100.0)
		p["dane"]["porcje"] = int(p["dane"]["porcje"]) - 1
		zmiana.emit()
		return true
	return false


## Baza: manierki napełniają się przy studni.
func napelnij_manierki() -> void:
	for poj in pojemniki() + [skrytka]:
		for p in poj.rzeczy:
			if p["id"] == "manierka":
				p["dane"]["porcje"] = PRZEDMIOTY["manierka"]["porcje"]


# ====================================================================== zapis

func _stan() -> Dictionary:
	var bron := {}
	for id in stan_broni:
		bron[id] = {"mag": Pojemnik.przedmiot_do_danych(stan_broni[id]["mag"]), "komora": stan_broni[id]["komora"], "dodatki": stan_broni[id].get("dodatki", [])}
	return {
		"wersja": 2, "glowna": bron_glowna, "boczna": bron_boczna, "kieszenie": kieszenie.do_danych(), "kamizelka": kamizelka.do_danych(),
		"relikwiarz": relikwiarz.do_danych(), "skrytka": skrytka.do_danych(),
		"kamizelka_p": Pojemnik.przedmiot_do_danych(kamizelka_p), "plecak_p": Pojemnik.przedmiot_do_danych(plecak_p),
		"bron": bron, "sytosc": sytosc, "nawodnienie": nawodnienie, "na_wyprawie": na_wyprawie,
		"wyprawy": wyprawy, "polegli": polegli, "pluton": pluton, "aktywny": aktywny, "zwiad": zwiad, "raport": raport, "ziarno": ziarno_wyprawy,
	}


func _ustaw_stan(d: Dictionary) -> void:
	kieszenie = Pojemnik.z_danych(d["kieszenie"])
	kamizelka = Pojemnik.z_danych(d["kamizelka"])
	relikwiarz = Pojemnik.z_danych(d["relikwiarz"])
	skrytka = Pojemnik.z_danych(d["skrytka"])
	kamizelka_p = Pojemnik.przedmiot_z_danych(d["kamizelka_p"])
	plecak_p = Pojemnik.przedmiot_z_danych(d["plecak_p"])
	plecak = null if plecak_p.is_empty() else plecak_p["dane"]["pojemnik"]
	stan_broni = {}
	for id in d["bron"]:
		stan_broni[id] = {"mag": Pojemnik.przedmiot_z_danych(d["bron"][id]["mag"]), "komora": d["bron"][id]["komora"], "dodatki": d["bron"][id].get("dodatki", [])}
	bron_glowna = d.get("glowna", "kwarc")
	bron_boczna = d.get("boczna", "jaspis")
	sytosc = float(d["sytosc"])
	nawodnienie = float(d["nawodnienie"])
	na_wyprawie = bool(d["na_wyprawie"])
	wyprawy = int(d.get("wyprawy", 0))
	polegli = int(d.get("polegli", 0))
	if d.has("pluton"):
		pluton = d["pluton"]
		aktywny = int(d.get("aktywny", 0))
	zwiad = bool(d.get("zwiad", false))
	ziarno_wyprawy = int(d.get("ziarno", randi() % 1000000))
	raport = d.get("raport", [])
	ladowanie = {}
	zmiana.emit()


func zapisz_baze() -> void:
	if not zapis_wlaczony:
		return
	var f := FileAccess.open(PLIK_BAZY, FileAccess.WRITE)
	if f:
		f.store_string(var_to_str(_stan()))


func wczytaj_baze() -> bool:
	if not FileAccess.file_exists(PLIK_BAZY):
		return false
	var d = str_to_var(FileAccess.get_file_as_string(PLIK_BAZY))
	if not (d is Dictionary) or int(d.get("wersja", 0)) != 2:
		return false
	_ustaw_stan(d)
	return true


## Biwak: zawieszenie wyprawy. Zapis znika przy wczytaniu.
func zapisz_biwak(dane_swiata: Dictionary) -> void:
	if not zapis_wlaczony:
		return
	zapisz_baze()
	var f := FileAccess.open(PLIK_BIWAKU, FileAccess.WRITE)
	if f:
		f.store_string(var_to_str(dane_swiata))


func wczytaj_biwak() -> Dictionary:
	if not zapis_wlaczony or not FileAccess.file_exists(PLIK_BIWAKU):
		return {}
	var d = str_to_var(FileAccess.get_file_as_string(PLIK_BIWAKU))
	DirAccess.remove_absolute(PLIK_BIWAKU)
	return d if d is Dictionary else {}


# ====================================================================== surowce w stosach

func _zrodla(ze_skrytka: bool) -> Array:
	var l := pojemniki()
	if ze_skrytka:
		l.append(skrytka)
	return l


func ile_zasobu(id: String, ze_skrytka := false) -> int:
	var n := 0
	for poj in _zrodla(ze_skrytka):
		for p in poj.rzeczy:
			if p["id"] == id:
				n += int(p["dane"].get("ile", 1))
	return n


func zuzyj_zasob(id: String, ile: int, ze_skrytka := false) -> bool:
	if ile_zasobu(id, ze_skrytka) < ile:
		return false
	for poj in _zrodla(ze_skrytka):
		for p in poj.rzeczy.duplicate():
			if p["id"] != id or ile <= 0:
				continue
			var ma := int(p["dane"].get("ile", 1))
			var bierz := mini(ma, ile)
			ile -= bierz
			if bierz >= ma:
				poj.usun(p)
			else:
				p["dane"]["ile"] = ma - bierz
	zmiana.emit()
	return true


## Dodaje surowiec, dopełniając istniejące stosy. Zwraca liczbę sztuk, które się nie zmieściły.
func dodaj_zasob(id: String, ile: int, do_skrytki := false) -> int:
	var stos: int = PRZEDMIOTY[id].get("stos", 1)
	var cele: Array = [skrytka] if do_skrytki else [plecak, kieszenie, kamizelka]
	for poj in cele:
		if poj == null:
			continue
		for p in poj.rzeczy:
			if p["id"] == id and ile > 0:
				var wolne := stos - int(p["dane"].get("ile", 1))
				var daj := mini(wolne, ile)
				if daj > 0:
					p["dane"]["ile"] = int(p["dane"].get("ile", 1)) + daj
					ile -= daj
	while ile > 0:
		var daj := mini(stos, ile)
		var p := nowy(id, {"ile": daj})
		var ok := false
		for poj in cele:
			if poj != null and poj.wloz_gdziekolwiek(p):
				ok = true
				break
		if not ok:
			break
		ile -= daj
	zmiana.emit()
	return ile


## Dodaje naboje danego typu, dopełniając paczki tego samego typu.
func dodaj_naboje(typ: String, ile: int, do_skrytki := false) -> int:
	var id: String = Amunicja.paczka(Amunicja.TYPY[typ]["kaliber"])
	var poj_max: int = PRZEDMIOTY[id]["poj"]
	var cele: Array = [skrytka] if do_skrytki else [plecak, kieszenie, kamizelka]
	for poj in cele:
		if poj == null:
			continue
		for p in poj.rzeczy:
			if p["id"] == id and p["dane"]["typ"] == typ and ile > 0:
				var daj := mini(poj_max - int(p["dane"]["ile"]), ile)
				p["dane"]["ile"] = int(p["dane"]["ile"]) + daj
				ile -= daj
	while ile > 0:
		var daj := mini(poj_max, ile)
		var p := nowa_paczka(id, typ, daj)
		var ok := false
		for poj in cele:
			if poj != null and poj.wloz_gdziekolwiek(p):
				ok = true
				break
		if not ok:
			break
		ile -= daj
	zmiana.emit()
	return ile


# ====================================================================== pluton

const SKLAD := [
	["kpr. Marek Wilk", "strzelec"], ["st. szer. Tomasz Sowa", "zwiadowca"], ["szer. Paweł Dąb", "saper"],
	["kpr. Anna Lis", "sanitariusz"], ["plut. Jan Kruk", "wyborowy"], ["st. szer. Adam Bóbr", "rusznikarz"],
]
const ZADANIA := ["Z_ODPOCZYNEK", "Z_AMUNICJA", "Z_WYTOP", "Z_APROWIZACJA", "Z_ZWIAD"]

var pluton: Array = []          ## {imie, spec, zyje, rany (wyprawy do wyleczenia), wyprawy, zadanie}
var aktywny := 0                ## kto idzie na wyprawę
var ziarno_wyprawy := 1          ## z niego składa się loch najbliższej wyprawy; losowane po każdym powrocie i śmierci
var zwiad := false              ## wynik zwiadu na najbliższą wyprawę
var raport: Array = []          ## co pluton zrobił podczas ostatniej wyprawy


func nowy_pluton() -> void:
	pluton = []
	for s in SKLAD:
		pluton.append({"imie": s[0], "spec": s[1], "zyje": true, "rany": 0, "wyprawy": 0, "zadanie": 0})
	aktywny = 0
	zwiad = false
	raport = []


func zolnierz() -> Dictionary:
	return pluton[aktywny] if not pluton.is_empty() else {}


func spec() -> String:
	return zolnierz().get("spec", "")


## Premie specjalności żołnierza, który jest na wyprawie.
func mod(co: String) -> float:
	match [co, spec()]:
		["odrzut", "strzelec"]:
			return 0.85
		["kolysanie", "wyborowy"]:
			return 0.7
		["leczenie", "sanitariusz"]:
			return 0.6
		["kucie", "saper"]:
			return 0.6
		["halas", "zwiadowca"]:
			return 0.7
	return 1.0


func zywi() -> int:
	var n := 0
	for z in pluton:
		if z["zyje"]:
			n += 1
	return n


func koniec_kampanii() -> bool:
	return zywi() == 0


## Wyznacza żołnierza na wyprawę. Ranny może iść tylko wtedy, gdy nie ma zdrowych.
func wyznacz(i: int) -> bool:
	var z: Dictionary = pluton[i]
	if not z["zyje"]:
		return false
	if int(z["rany"]) > 0 and _jest_zdrowy():
		return false
	aktywny = i
	zmiana.emit()
	return true


func _jest_zdrowy() -> bool:
	for z in pluton:
		if z["zyje"] and int(z["rany"]) == 0:
			return true
	return false


func _wybierz_nastepnego() -> void:
	var najlepszy := -1
	for i in pluton.size():
		var z: Dictionary = pluton[i]
		if z["zyje"] and (najlepszy < 0 or int(z["rany"]) < int(pluton[najlepszy]["rany"])):
			najlepszy = i
	if najlepszy >= 0:
		aktywny = najlepszy


func _zjedz_ze_skrytki() -> bool:
	for p in skrytka.rzeczy:
		if PRZEDMIOTY[p["id"]]["typ"] == "jedzenie":
			skrytka.usun(p)
			return true
	return false


## Rozliczenie po wyprawie: żołnierze w bazie jedzą, leczą się i wykonują zadania.
## rany_aktywnego: na ile wypraw wracający żołnierz trafia do lazaretu.
func rozlicz_wyprawe(rany_aktywnego: int) -> void:
	raport = []
	nowy_loch()
	for i in pluton.size():
		var z: Dictionary = pluton[i]
		if not z["zyje"] or i == aktywny:
			continue
		var nazwisko: String = z["imie"]
		if int(z["rany"]) > 0:
			z["rany"] = maxi(int(z["rany"]) - 1, 0)
			raport.append([nazwisko, "R_LAZARET" if int(z["rany"]) > 0 else "R_WYLECZONY", ""])
			continue
		if not _zjedz_ze_skrytki():
			raport.append([nazwisko, "R_GLOD", ""])
			continue
		raport.append([nazwisko, ZADANIA[int(z["zadanie"])], _wykonaj_zadanie(z)])
	var a: Dictionary = pluton[aktywny]
	if a["zyje"]:
		a["wyprawy"] = int(a["wyprawy"]) + 1
		a["rany"] = rany_aktywnego
		if rany_aktywnego > 0:
			raport.append([a["imie"], "R_RANNY", str(rany_aktywnego)])
	if not a["zyje"] or rany_aktywnego > 0:
		_wybierz_nastepnego()
	zmiana.emit()


func _wykonaj_zadanie(z: Dictionary) -> String:
	var premia: int = 1 if z["spec"] == "rusznikarz" else 0
	match ZADANIA[int(z["zadanie"])]:
		"Z_AMUNICJA":
			var kal: String = Bron.DANE[bron_glowna]["kaliber"]
			var zrobione := 0
			for n in 2 + premia:
				var ok := false
				for r in Rzemioslo.receptury("stol"):
					if r.has("naboje") and Amunicja.TYPY[r["naboje"][0]]["kaliber"] == kal and Rzemioslo.mozna(r, true):
						Rzemioslo.wykonaj(r, true)
						zrobione += int(r["naboje"][1])
						ok = true
						break
				if ok:
					continue
				for r in Rzemioslo.receptury("stol"):
					var jest_prochem: bool = r.has("wyjscie") and r["wyjscie"].has("proch")
					var jest_luska: bool = r.has("wyjscie") and r["wyjscie"].has(Amunicja.luski(kal))
					if (jest_prochem or jest_luska) and Rzemioslo.mozna(r, true):
						Rzemioslo.wykonaj(r, true)
						break
			return str(zrobione)
		"Z_WYTOP":
			var sztabki := 0
			for n in 6 + premia * 2:
				for r in Rzemioslo.receptury("piec"):
					if Rzemioslo.mozna(r, true):
						Rzemioslo.wykonaj(r, true)
						sztabki += 1
						break
			return str(sztabki)
		"Z_APROWIZACJA":
			for id in ["konserwa", "suchary", "suchary", "racja"]:
				skrytka.wloz_gdziekolwiek(nowy(id))
			skrytka.wloz_gdziekolwiek(nowy("wegiel", {"ile": 2}))
			return "4"
		"Z_ZWIAD":
			zwiad = true
	return ""


## Nowa kampania po stracie całego plutonu.
func nowy_loch() -> void:
	ziarno_wyprawy = randi() % 1000000


func nowa_kampania() -> void:
	nowy_loch()
	skrytka = Pojemnik.new(10, 14, "E_SKRYTKA")
	stan_broni = {}
	nowy_zestaw()
	_zapas_startowy()
	nowy_pluton()
	wyprawy = 0
	polegli = 0
	na_wyprawie = false
	if zapis_wlaczony:
		DirAccess.remove_absolute(PLIK_BIWAKU)
	zapisz_baze()


# ====================================================================== dodatki do broni

func dodatki(id_broni: String) -> Array:
	return stan(id_broni).get("dodatki", [])


func ma_dodatek(id_broni: String, slot: String) -> String:
	for d in dodatki(id_broni):
		if PRZEDMIOTY[d]["slot"] == slot:
			return d
	return ""


func zamontuj(id_broni: String, p: Dictionary) -> bool:
	var def: Dictionary = PRZEDMIOTY[p["id"]]
	if def["typ"] != "dodatek" or not (id_broni in def["pasuje"]) or ma_dodatek(id_broni, def["slot"]) != "":
		return false
	wyjmij(p)
	skrytka.usun(p)
	var st := stan(id_broni)
	st["dodatki"] = dodatki(id_broni) + [p["id"]]
	zmiana.emit()
	return true


func zdejmij(id_broni: String, id_dodatku: String) -> void:
	var st := stan(id_broni)
	var l: Array = dodatki(id_broni).duplicate()
	l.erase(id_dodatku)
	st["dodatki"] = l
	if not skrytka.wloz_gdziekolwiek(nowy(id_dodatku)):
		podnies(nowy(id_dodatku))
	zmiana.emit()


## Stan techniczny broni 0..1 (1 = jak nowa). Zużycie rośnie z każdym strzałem.
func stan_techniczny(id_broni: String) -> float:
	return 1.0 - float(stan(id_broni).get("zuzycie", 0.0))


## Naprawa w bazie: wymiana zużytych części kosztuje sztabkę stali ze skrytki.
func napraw_bron(id_broni: String) -> bool:
	if stan_techniczny(id_broni) >= 0.995 or ile_zasobu("sztabka_stali", true) <= 0:
		return false
	zuzyj_zasob("sztabka_stali", 1, true)
	stan(id_broni)["zuzycie"] = 0.0
	zmiana.emit()
	return true
