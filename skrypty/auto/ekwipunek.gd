extends Node
## Ekwipunek żołnierza. Przetrwa zmianę lokacji; ginie razem z żołnierzem
## (poza relikwiarzem). Pojemność zależy od kamizelki i plecaka.

signal zmiana
signal komunikat(tekst: String)

## id: nazwa (klucz), w × h pól, masa kg, typ, kolor kafelka; dodatkowe pola wg typu
const PRZEDMIOTY := {
	"mag_kwarc": {"nazwa": "P_MAG_KWARC", "w": 1, "h": 2, "masa": 0.12, "typ": "mag", "kolor": "3d3a33", "bron": "kwarc", "poj": 30, "kaliber": "5.56x45"},
	"mag_jaspis": {"nazwa": "P_MAG_JASPIS", "w": 1, "h": 1, "masa": 0.08, "typ": "mag", "kolor": "34363a", "bron": "jaspis", "poj": 15, "kaliber": "9x19"},
	"paczka_556": {"nazwa": "P_PACZKA_556", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "5a5231", "kaliber": "5.56x45", "poj": 30},
	"paczka_9": {"nazwa": "P_PACZKA_9", "w": 1, "h": 1, "masa": 0.03, "typ": "amunicja", "kolor": "5a4a31", "kaliber": "9x19", "poj": 50},
	"bandaz": {"nazwa": "LEK_BANDAZ", "w": 1, "h": 1, "masa": 0.05, "typ": "lek", "kolor": "8a8676"},
	"opatrunek": {"nazwa": "LEK_OPATRUNEK", "w": 1, "h": 1, "masa": 0.08, "typ": "lek", "kolor": "7d6f52"},
	"szyna": {"nazwa": "LEK_SZYNA", "w": 1, "h": 2, "masa": 0.30, "typ": "lek", "kolor": "6f7462"},
	"apteczka": {"nazwa": "LEK_APTECZKA", "w": 2, "h": 1, "masa": 0.55, "typ": "lek", "kolor": "7a2f28"},
	"przeciwbolowe": {"nazwa": "LEK_PRZECIWBOLOWE", "w": 1, "h": 1, "masa": 0.03, "typ": "lek", "kolor": "8c8a80"},
	"konserwa": {"nazwa": "P_KONSERWA", "w": 1, "h": 1, "masa": 0.40, "typ": "inne", "kolor": "6b6f72"},
	"suchary": {"nazwa": "P_SUCHARY", "w": 1, "h": 1, "masa": 0.20, "typ": "inne", "kolor": "8a7a52"},
	"monety": {"nazwa": "P_MONETY", "w": 1, "h": 1, "masa": 0.15, "typ": "lup", "kolor": "8f7a2e"},
	"relikwia": {"nazwa": "P_RELIKWIA", "w": 1, "h": 2, "masa": 0.60, "typ": "lup", "kolor": "6e5a7a"},
	"klucz": {"nazwa": "P_KLUCZ", "w": 1, "h": 1, "masa": 0.05, "typ": "lup", "kolor": "5c5f63"},
	"pas": {"nazwa": "P_PAS", "w": 2, "h": 1, "masa": 0.5, "typ": "kamizelka", "kolor": "4a4a36", "siatka": Vector2i(4, 1)},
	"chest_rig": {"nazwa": "P_CHEST_RIG", "w": 2, "h": 2, "masa": 1.1, "typ": "kamizelka", "kolor": "4a4f36", "siatka": Vector2i(5, 2)},
	"torba": {"nazwa": "P_TORBA", "w": 2, "h": 1, "masa": 0.3, "typ": "plecak", "kolor": "55503a", "siatka": Vector2i(2, 2)},
	"chlebak": {"nazwa": "P_CHLEBAK", "w": 2, "h": 2, "masa": 0.6, "typ": "plecak", "kolor": "5a5a40", "siatka": Vector2i(3, 3)},
	"plecak_szturmowy": {"nazwa": "P_PLECAK_SZT", "w": 3, "h": 3, "masa": 1.2, "typ": "plecak", "kolor": "454a34", "siatka": Vector2i(4, 5)},
	"plecak_patrolowy": {"nazwa": "P_PLECAK_PAT", "w": 3, "h": 4, "masa": 1.8, "typ": "plecak", "kolor": "3f4530", "siatka": Vector2i(5, 6)},
}
const MASA_NABOJU := {"5.56x45": 0.012, "9x19": 0.012}
const MASA_BRONI := 4.4          ## karabinek i pistolet bez magazynków
const LIMIT_LEKKI := 25.0
const LIMIT_CIEZKI := 40.0

var kieszenie: Pojemnik
var kamizelka: Pojemnik
var plecak: Pojemnik            ## null, gdy plecak zrzucony albo brak
var relikwiarz: Pojemnik
var kamizelka_p := {}           ## przedmiot kamizelki
var plecak_p := {}              ## przedmiot plecaka ({} = brak)
var stan_broni := {}            ## id broni -> {"mag": przedmiot albo {}, "komora": typ}
var ladowanie := {}             ## trwające ładowanie magazynka: {mag, paczka, t}


func _ready() -> void:
	nowy_zestaw()


static func nowy(id: String, dane := {}) -> Dictionary:
	return {"id": id, "x": 0, "y": 0, "obr": false, "dane": dane, "odkryty": true}


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
	plecak.wloz_gdziekolwiek(nowy("konserwa"))
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
	zmiana.emit()


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
		m += int(dane["ile"]) * float(MASA_NABOJU[def["kaliber"]])
	if dane.has("pojemnik") and dane["pojemnik"] != null:
		m += (dane["pojemnik"] as Pojemnik).masa()
	return m


func masa() -> float:
	var m := MASA_BRONI + kieszenie.masa() + kamizelka.masa() + relikwiarz.masa()
	m += masa_przedmiotu(kamizelka_p)
	if not plecak_p.is_empty():
		m += masa_przedmiotu(plecak_p)
	for id in stan_broni:
		var mg: Dictionary = stan_broni[id]["mag"]
		if not mg.is_empty():
			m += masa_przedmiotu(mg)
	return m


## Mnożnik prędkości od obciążenia: do 25 kg bez kary, przy 40 kg i więcej 0,7.
func mnoznik_ruchu() -> float:
	return lerpf(1.0, 0.7, clampf((masa() - LIMIT_LEKKI) / (LIMIT_CIEZKI - LIMIT_LEKKI), 0.0, 1.0))


func moze_sprintowac() -> bool:
	return masa() < LIMIT_CIEZKI


func mnoznik_halasu() -> float:
	return 1.0 + clampf((masa() - 15.0) / 30.0, 0.0, 1.0) * 0.8


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
