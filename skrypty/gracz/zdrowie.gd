class_name Zdrowie
extends Node
## Zdrowie strefowe żołnierza, rany i leki.
## Strefy: głowa, tors, ręce, nogi. Śmierć: głowa albo tors spada do zera.

signal zmiana
signal obrazenie(strefa: String, ile: float)
signal smierc
signal komunikat(tekst: String)

const MAKS := {"glowa": 35.0, "tors": 85.0, "reka_l": 60.0, "reka_p": 60.0, "noga_l": 65.0, "noga_p": 65.0}
const WAGI := {"glowa": 0.08, "tors": 0.40, "reka_l": 0.14, "reka_p": 0.14, "noga_l": 0.12, "noga_p": 0.12}
## lek: [klucz tekstu, czas użycia w sekundach, startowa liczba]
const LEKI := {
	"bandaz": ["LEK_BANDAZ", 3.0, 2],
	"opatrunek": ["LEK_OPATRUNEK", 4.0, 1],
	"szyna": ["LEK_SZYNA", 6.0, 1],
	"apteczka": ["LEK_APTECZKA", 5.0, 1],
	"przeciwbolowe": ["LEK_PRZECIWBOLOWE", 2.0, 2],
}
const KOLEJNOSC := ["bandaz", "opatrunek", "szyna", "apteczka", "przeciwbolowe"]

var hp := {}
var krwawienie_lekkie := 0       ## liczba lekkich krwawień
var krwawienie_ciezkie := false
var zlamania := {}               ## strefa -> true
var bol := 0.0                   ## 0..1
var znieczulenie := 0.0          ## sekundy działania środków przeciwbólowych
var leki: Dictionary:
	get:
		return Ekwipunek.leki()
var zyje := true
var uzywa := ""                  ## lek w trakcie użycia
var uzycie_t := 0.0
var uzycie_max := 1.0
var _spozywany := {}
var czynnosc_nazwa := ""        ## klucz tekstu trwającej czynności (kucie, oprawianie…)
var _cz_po := Callable()
var _cz_tik := Callable()
var _cz_t := 0.0

const CZAS_PRAGNIENIA := 1800.0   ## sekundy od pełnego nawodnienia do zera
const CZAS_GLODU := 3300.0


func _ready() -> void:
	for s in MAKS:
		hp[s] = MAKS[s]


## Cios zadany przez wroga. ciezki: miecz, maczuga — może łamać kości.
func cios(ile: float, ciezki := false, tnacy := true) -> void:
	if not zyje:
		return
	var los := randf()
	var strefa := "tors"
	for s in WAGI:
		los -= WAGI[s]
		if los <= 0.0:
			strefa = s
			break
	_odejmij(strefa, ile)
	obrazenie.emit(strefa, ile)
	bol = minf(bol + ile / 70.0, 1.0)
	if tnacy:
		if ile >= 32.0 and randf() < 0.55:
			krwawienie_ciezkie = true
		elif randf() < 0.6:
			krwawienie_lekkie = mini(krwawienie_lekkie + 1, 3)
	if ciezki and strefa != "tors" and strefa != "glowa" and randf() < 0.45:
		zlamania[strefa] = true
	zmiana.emit()


func _odejmij(strefa: String, ile: float) -> void:
	var zostalo: float = hp[strefa] - ile
	if zostalo >= 0.0:
		hp[strefa] = zostalo
	else:
		hp[strefa] = 0.0
		if strefa == "glowa" or strefa == "tors":
			_umrzyj()
			return
		# zniszczona kończyna: nadmiar obrażeń rozchodzi się po reszcie ciała
		var nadmiar := -zostalo * 0.7
		var zywe := []
		for s in hp:
			if hp[s] > 0.0:
				zywe.append(s)
		for s in zywe:
			hp[s] = maxf(hp[s] - nadmiar / zywe.size(), 0.0)
		if hp["glowa"] <= 0.0 or hp["tors"] <= 0.0:
			_umrzyj()


func _umrzyj() -> void:
	if not zyje:
		return
	zyje = false
	uzywa = ""
	zmiana.emit()
	smierc.emit()


func _process(dt: float) -> void:
	if not zyje:
		return
	var ubytek := krwawienie_lekkie * 0.45 + (1.7 if krwawienie_ciezkie else 0.0)
	if ubytek > 0.0:
		# krew tracona jest z całego ciała, najpierw z torsu
		_odejmij("tors", ubytek * dt)
		zmiana.emit()
	var sw := get_tree().get_first_node_in_group("swiat")
	if sw != null and sw.get("wyprawa"):
		Ekwipunek.nawodnienie = maxf(Ekwipunek.nawodnienie - dt * 100.0 / CZAS_PRAGNIENIA, 0.0)
		Ekwipunek.sytosc = maxf(Ekwipunek.sytosc - dt * 100.0 / CZAS_GLODU, 0.0)
		if Ekwipunek.nawodnienie <= 0.0 or Ekwipunek.sytosc <= 0.0:
			_odejmij("tors", 0.15 * dt)
			zmiana.emit()
	znieczulenie = maxf(znieczulenie - dt, 0.0)
	bol = maxf(bol - dt * (0.02 if znieczulenie <= 0.0 else 0.25), 0.0)
	if uzywa == "czynnosc":
		var g := get_parent() as Gracz
		if g != null and g.predkosc_pozioma > 1.0:
			przerwij_uzycie()
			return
		_cz_t += dt
		if _cz_t >= 1.0:
			_cz_t = 0.0
			if _cz_tik.is_valid():
				_cz_tik.call()
	if uzywa != "":
		uzycie_t += dt
		if uzycie_t >= uzycie_max:
			if uzywa == "czynnosc":
				uzywa = ""
				czynnosc_nazwa = ""
				if _cz_po.is_valid():
					_cz_po.call()
				zmiana.emit()
				return
			if uzywa == "spozycie":
				if Ekwipunek.spozyj(_spozywany):
					komunikat.emit(tr(Ekwipunek.PRZEDMIOTY[_spozywany["id"]]["nazwa"]) + ": " + tr("LEK_UZYTO"))
				_spozywany = {}
			else:
				_zastosuj(uzywa)
			uzywa = ""
			zmiana.emit()


func zacznij_uzycie(lek: String) -> void:
	if not zyje or uzywa != "":
		return
	if leki.get(lek, 0) <= 0:
		komunikat.emit(tr("LEK_BRAK"))
		return
	if not _potrzebny(lek):
		komunikat.emit(tr("LEK_NIEPOTRZEBNY"))
		return
	uzywa = lek
	uzycie_t = 0.0
	uzycie_max = LEKI[lek][1]
	Dzwiek.przy_uchu("lek", -6.0)
	zmiana.emit()


## Dłuższa czynność z paskiem postępu: kucie rudy, oprawianie, zbieranie łusek.
## Ruch ją przerywa. co_sekunde: np. hałas kilofa.
func zacznij_czynnosc(klucz: String, czas: float, po: Callable, co_sekunde := Callable()) -> void:
	if not zyje or uzywa != "":
		return
	uzywa = "czynnosc"
	czynnosc_nazwa = klucz
	uzycie_t = 0.0
	uzycie_max = czas
	_cz_po = po
	_cz_tik = co_sekunde
	_cz_t = 0.0
	zmiana.emit()


## Jedzenie i picie: trwa kilka sekund, broń opuszczona.
func zacznij_spozycie(p: Dictionary) -> void:
	if not zyje or uzywa != "":
		return
	var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
	if def["typ"] == "picie" and int(p["dane"].get("porcje", 0)) <= 0:
		komunikat.emit(tr("E_PUSTE"))
		return
	_spozywany = p
	uzywa = "spozycie"
	uzycie_t = 0.0
	uzycie_max = 5.0 if def["typ"] == "jedzenie" else 2.5
	Dzwiek.przy_uchu("lek", -6.0)
	zmiana.emit()


## 0 = syty i napojony, 1 = skrajny niedobór. Kary zaczynają się poniżej 25%.
func niedobor() -> float:
	var n := minf(Ekwipunek.sytosc, Ekwipunek.nawodnienie)
	return clampf((25.0 - n) / 25.0, 0.0, 1.0)


func przerwij_uzycie() -> void:
	uzywa = ""
	czynnosc_nazwa = ""
	zmiana.emit()


func _potrzebny(lek: String) -> bool:
	match lek:
		"bandaz":
			return krwawienie_lekkie > 0
		"opatrunek":
			return krwawienie_ciezkie or krwawienie_lekkie > 0
		"szyna":
			return not zlamania.is_empty()
		"apteczka":
			for s in hp:
				if hp[s] < MAKS[s]:
					return true
			return false
	return true


func _zastosuj(lek: String) -> void:
	if not Ekwipunek.zuzyj_lek(lek):
		return
	match lek:
		"bandaz":
			krwawienie_lekkie = maxi(krwawienie_lekkie - 1, 0)
		"opatrunek":
			if krwawienie_ciezkie:
				krwawienie_ciezkie = false
			else:
				krwawienie_lekkie = 0
		"szyna":
			zlamania.erase(zlamania.keys()[0])
		"apteczka":
			var pula := 70.0
			var kolejka := hp.keys()
			kolejka.sort_custom(func(a, b): return hp[a] / MAKS[a] < hp[b] / MAKS[b])
			for s in kolejka:
				var brak: float = MAKS[s] - hp[s]
				var daj := minf(brak, pula)
				hp[s] += daj
				pula -= daj
		"przeciwbolowe":
			znieczulenie = 180.0
	komunikat.emit(tr(LEKI[lek][0]) + ": " + tr("LEK_UZYTO"))


## Mnożnik prędkości ruchu wynikający z ran.
func mnoznik_ruchu() -> float:
	var m := 1.0
	for n in ["noga_l", "noga_p"]:
		if zlamania.has(n) or hp[n] <= 0.0:
			m *= 0.62 if znieczulenie <= 0.0 else 0.85
	if uzywa != "":
		m *= 0.5
	return m * lerpf(1.0, 0.85, odczuwany_bol())


func moze_sprintowac() -> bool:
	for n in ["noga_l", "noga_p"]:
		if zlamania.has(n) or hp[n] <= 0.0:
			return false
	return uzywa == ""


## Mnożnik kołysania broni: ból i uszkodzone ręce.
func mnoznik_kolysania() -> float:
	var m := 1.0 + odczuwany_bol() * 1.5 + niedobor() * 1.2
	for r in ["reka_l", "reka_p"]:
		if zlamania.has(r) or hp[r] <= 0.0:
			m += 1.2
	return m


func odczuwany_bol() -> float:
	return bol * (0.25 if znieczulenie > 0.0 else 1.0)
