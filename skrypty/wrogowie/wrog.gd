class_name Wrog
extends CharacterBody3D
## Wróg człekokształtny ze sztywnych segmentów. Animacja liczona na żywo
## obrotami stawów; strefy trafień poruszają się razem z segmentami.

## Stawy w układzie modelu (Blender), potrzebne do ustawienia dodatkowych stref.
const STAWY := {
	"glowa": Vector3(0, 0.005, 1.50), "tors": Vector3(0, 0, 1.06),
	"udo_p": Vector3(0.092, 0, 0.94), "udo_l": Vector3(-0.092, 0, 0.94),
}

## segment: [klucz strefy, rodzaj, klasa, zdrowie]
const STREFY_GHUL := {
	"glowa": ["STREFA_GLOWA", "glowa", 0, 30.0], "tors": ["STREFA_TORS", "tors", 0, 85.0],
	"miednica": ["STREFA_BRZUCH", "tors", 0, 70.0],
	"ramie_l": ["STREFA_REKA", "reka", 0, 35.0], "ramie_p": ["STREFA_REKA", "reka", 0, 35.0],
	"przedramie_l": ["STREFA_REKA", "reka", 0, 30.0], "przedramie_p": ["STREFA_REKA", "reka", 0, 30.0],
	"udo_l": ["STREFA_NOGA", "noga", 0, 45.0], "udo_p": ["STREFA_NOGA", "noga", 0, 45.0],
	"golen_l": ["STREFA_NOGA", "noga", 0, 35.0], "golen_p": ["STREFA_NOGA", "noga", 0, 35.0],
}
const STREFY_KNECHT := {
	"glowa": ["STREFA_GLOWA", "glowa", 1, 34.0], "tors": ["STREFA_TORS", "tors", 2, 95.0],
	"miednica": ["STREFA_BRZUCH", "tors", 2, 80.0],
	"ramie_l": ["STREFA_REKA", "reka", 2, 40.0], "ramie_p": ["STREFA_REKA", "reka", 2, 40.0],
	"przedramie_l": ["STREFA_REKA", "reka", 1, 34.0], "przedramie_p": ["STREFA_REKA", "reka", 1, 34.0],
	"udo_l": ["STREFA_NOGA", "noga", 1, 50.0], "udo_p": ["STREFA_NOGA", "noga", 1, 50.0],
	"golen_l": ["STREFA_NOGA", "noga", 0, 40.0], "golen_p": ["STREFA_NOGA", "noga", 0, 40.0],
	"tarcza": ["STREFA_TARCZA", "tarcza", 3, 260.0],
}
const STREFY_RYCERZ := {
	"glowa": ["STREFA_GLOWA", "glowa", 4, 45.0], "tors": ["STREFA_TORS", "tors", 4, 130.0],
	"miednica": ["STREFA_BRZUCH", "tors", 3, 110.0],
	"ramie_l": ["STREFA_REKA", "reka", 3, 55.0], "ramie_p": ["STREFA_REKA", "reka", 3, 55.0],
	"przedramie_l": ["STREFA_REKA", "reka", 3, 45.0], "przedramie_p": ["STREFA_REKA", "reka", 3, 45.0],
	"udo_l": ["STREFA_NOGA", "noga", 3, 65.0], "udo_p": ["STREFA_NOGA", "noga", 3, 65.0],
	"golen_l": ["STREFA_NOGA", "noga", 3, 55.0], "golen_p": ["STREFA_NOGA", "noga", 3, 55.0],
}
const STREFY_KULTYSTA := {
	"glowa": ["STREFA_GLOWA", "glowa", 0, 30.0], "tors": ["STREFA_TORS", "tors", 0, 75.0],
	"miednica": ["STREFA_BRZUCH", "tors", 0, 65.0],
	"ramie_l": ["STREFA_REKA", "reka", 0, 32.0], "ramie_p": ["STREFA_REKA", "reka", 0, 32.0],
	"przedramie_l": ["STREFA_REKA", "reka", 0, 28.0], "przedramie_p": ["STREFA_REKA", "reka", 0, 28.0],
	"udo_l": ["STREFA_NOGA", "noga", 0, 42.0], "udo_p": ["STREFA_NOGA", "noga", 0, 42.0],
	"golen_l": ["STREFA_NOGA", "noga", 0, 34.0], "golen_p": ["STREFA_NOGA", "noga", 0, 34.0],
}
const STREFY_WLOCZNIK := {
	"glowa": ["STREFA_GLOWA", "glowa", 3, 34.0], "tors": ["STREFA_TORS", "tors", 2, 90.0],
	"miednica": ["STREFA_BRZUCH", "tors", 1, 75.0],
	"ramie_l": ["STREFA_REKA", "reka", 2, 40.0], "ramie_p": ["STREFA_REKA", "reka", 2, 40.0],
	"przedramie_l": ["STREFA_REKA", "reka", 1, 34.0], "przedramie_p": ["STREFA_REKA", "reka", 1, 34.0],
	"udo_l": ["STREFA_NOGA", "noga", 0, 48.0], "udo_p": ["STREFA_NOGA", "noga", 0, 48.0],
	"golen_l": ["STREFA_NOGA", "noga", 0, 38.0], "golen_p": ["STREFA_NOGA", "noga", 0, 38.0],
	"tarcza": ["STREFA_TARCZA", "tarcza", 3, 240.0],
}
const STREFY_KUSZNIK := {
	"glowa": ["STREFA_GLOWA", "glowa", 0, 32.0], "tors": ["STREFA_TORS", "tors", 1, 85.0],
	"miednica": ["STREFA_BRZUCH", "tors", 1, 70.0],
	"ramie_l": ["STREFA_REKA", "reka", 1, 36.0], "ramie_p": ["STREFA_REKA", "reka", 1, 36.0],
	"przedramie_l": ["STREFA_REKA", "reka", 1, 32.0], "przedramie_p": ["STREFA_REKA", "reka", 1, 32.0],
	"udo_l": ["STREFA_NOGA", "noga", 0, 46.0], "udo_p": ["STREFA_NOGA", "noga", 0, 46.0],
	"golen_l": ["STREFA_NOGA", "noga", 0, 36.0], "golen_p": ["STREFA_NOGA", "noga", 0, 36.0],
}
const STREFY_TROLL := {
	"glowa": ["STREFA_GLOWA", "glowa", 5, 90.0], "tors": ["STREFA_TORS", "tors", 3, 420.0],
	"miednica": ["STREFA_BRZUCH", "tors", 3, 340.0],
	"ramie_l": ["STREFA_REKA", "reka", 3, 150.0], "ramie_p": ["STREFA_REKA", "reka", 3, 150.0],
	"przedramie_l": ["STREFA_REKA", "reka", 3, 130.0], "przedramie_p": ["STREFA_REKA", "reka", 3, 130.0],
	"udo_l": ["STREFA_NOGA", "noga", 3, 170.0], "udo_p": ["STREFA_NOGA", "noga", 3, 170.0],
	"golen_l": ["STREFA_NOGA", "noga", 3, 150.0], "golen_p": ["STREFA_NOGA", "noga", 3, 150.0],
}
const STREFY_WARG := {
	"glowa": ["STREFA_GLOWA", "glowa", 0, 38.0], "tulow": ["STREFA_TORS", "tors", 0, 150.0],
	"szyja": ["STREFA_TORS", "tors", 0, 60.0],
	"lapa_pl": ["STREFA_NOGA", "noga", 0, 34.0], "lapa_pp": ["STREFA_NOGA", "noga", 0, 34.0],
	"lapa_tl": ["STREFA_NOGA", "noga", 0, 38.0], "lapa_tp": ["STREFA_NOGA", "noga", 0, 38.0],
	"lapa_pl2": ["STREFA_NOGA", "noga", 0, 26.0], "lapa_pp2": ["STREFA_NOGA", "noga", 0, 26.0],
	"lapa_tl2": ["STREFA_NOGA", "noga", 0, 28.0], "lapa_tp2": ["STREFA_NOGA", "noga", 0, 28.0],
}
## szczeliny w zbroi: [segment, klucz, środek w układzie modelu, rozmiar w układzie modelu]
const SZCZELINY_RYCERZ := [
	["glowa", "STREFA_WIZJER", Vector3(0, 0.155, 1.703), Vector3(0.17, 0.03, 0.03)],
	["tors", "STREFA_PACHA", Vector3(0.184, 0.0, 1.39), Vector3(0.04, 0.30, 0.11)],
	["tors", "STREFA_PACHA", Vector3(-0.184, 0.0, 1.39), Vector3(0.04, 0.30, 0.11)],
	["udo_p", "STREFA_KOLANO", Vector3(0.097, -0.115, 0.545), Vector3(0.10, 0.03, 0.09)],
	["udo_l", "STREFA_KOLANO", Vector3(-0.097, -0.115, 0.545), Vector3(0.10, 0.03, 0.09)],
]

const TYPY := {
	"ghul": {
		"model": "res://zasoby/modele/ghul.glb", "strefy": STREFY_GHUL, "szczeliny": [],
		"chod": 1.1, "bieg": 4.3, "zasieg": 1.55, "obr": 20.0, "zamach": 0.50, "po_ataku": 0.55,
		"ciezki": false, "wzrok": 1.0, "krwawi": true, "oglusza_od": 30.0, "skala_tors": Vector3(0.9, 1, 1),
		"ryk": "ghul_ryk", "krok": "krok", "zasieg_krokow": 5.0,
		"lup": [["monety", 1], ["klucz", 1]], "lup_min": 0, "lup_max": 1,
		"oprawa": [["kosc", 1, 1.0], ["sciegna", 1, 0.8], ["gruczol", 1, 0.4]],
	},
	"knecht": {
		"model": "res://zasoby/modele/knecht.glb", "strefy": STREFY_KNECHT, "szczeliny": [],
		"chod": 0.9, "bieg": 1.9, "zasieg": 1.9, "obr": 30.0, "zamach": 0.70, "po_ataku": 0.8,
		"ciezki": false, "wzrok": 0.8, "krwawi": false, "oglusza_od": 60.0, "skala_tors": Vector3(0.9, 1, 1),
		"ryk": "trup_jek", "krok": "zbroja", "zasieg_krokow": 9.0,
		"lup": [["monety", 4], ["suchary", 2], ["klucz", 1], ["bandaz", 1]], "lup_min": 1, "lup_max": 2,
		"oprawa": [["kosc", 2, 1.0]],
	},
	"rycerz": {
		"model": "res://zasoby/modele/rycerz.glb", "strefy": STREFY_RYCERZ, "szczeliny": SZCZELINY_RYCERZ,
		"chod": 0.8, "bieg": 1.55, "zasieg": 2.35, "obr": 52.0, "zamach": 0.90, "po_ataku": 1.0,
		"ciezki": true, "wzrok": 0.7, "krwawi": false, "oglusza_od": 999.0, "skala_tors": Vector3(0.84, 1, 0.9),
		"ryk": "trup_jek", "krok": "zbroja", "zasieg_krokow": 12.0,
		"lup": [["monety", 4], ["relikwia", 3], ["klucz", 2]], "lup_min": 2, "lup_max": 3,
		"oprawa": [],
	},
	# kaznodzieja: sam słaby, ale litanią budzi loch i wprawia potwory w szał
	"kultysta": {
		"model": "res://zasoby/modele/kultysta.glb", "styl": "czlowiek", "strefy": STREFY_KULTYSTA, "szczeliny": [],
		"chod": 1.0, "bieg": 2.6, "zasieg": 2.1, "obr": 18.0, "zamach": 0.75, "po_ataku": 0.9,
		"ciezki": false, "wzrok": 1.1, "krwawi": true, "oglusza_od": 25.0, "skala_tors": Vector3(0.85, 1, 0.9),
		"ryk": "kazanie", "krok": "krok", "zasieg_krokow": 5.0, "kaznodzieja": true, "bron_obrot": -0.35, "bron_kat": -0.12,
		"lup": [["monety", 3], ["relikwia", 2], ["klucz", 1], ["bandaz", 1]], "lup_min": 1, "lup_max": 2,
		"oprawa": [],
	},
	# Straż Zakonu: żywi ludzie, walczą z potworami, pierwszy huk broni palnej łamie im szyk
	"wlocznik": {
		"model": "res://zasoby/modele/wlocznik.glb", "styl": "knecht", "strefy": STREFY_WLOCZNIK, "szczeliny": [], "frakcja": "zakon",
		"chod": 1.2, "bieg": 3.1, "zasieg": 2.75, "obr": 34.0, "zamach": 0.60, "po_ataku": 0.75,
		"ciezki": false, "wzrok": 1.25, "krwawi": true, "oglusza_od": 40.0, "skala_tors": Vector3(0.9, 1, 1),
		"ryk": "krzyk", "krok": "zbroja", "zasieg_krokow": 9.0, "pchniecie": true, "bron_obrot": -1.5, "bron_kat": -1.5,
		"lup": [["monety", 4], ["suchary", 3], ["bandaz", 2]], "lup_min": 1, "lup_max": 2,
		"oprawa": [],
	},
	"kusznik": {
		"model": "res://zasoby/modele/kusznik.glb", "styl": "czlowiek", "strefy": STREFY_KUSZNIK, "szczeliny": [], "frakcja": "zakon",
		"chod": 1.2, "bieg": 3.3, "zasieg": 1.7, "obr": 14.0, "zamach": 0.55, "po_ataku": 0.8,
		"ciezki": false, "wzrok": 1.4, "krwawi": true, "oglusza_od": 35.0, "skala_tors": Vector3(0.9, 1, 1),
		"ryk": "krzyk", "krok": "krok", "zasieg_krokow": 6.0, "bron_obrot": -1.5, "bron_kat": -1.52,
		"strzela": {"od": 4.5, "do": 24.0, "celowanie": 1.25, "ladowanie": 3.4, "obr": 40.0, "v": 46.0},
		"lup": [["monety", 3], ["suchary", 3], ["bandaz", 2]], "lup_min": 1, "lup_max": 2,
		"oprawa": [],
	},
	"komtur": {
		"model": "res://zasoby/modele/komtur.glb", "styl": "rycerz", "strefy": STREFY_RYCERZ, "szczeliny": SZCZELINY_RYCERZ, "frakcja": "zakon",
		"chod": 1.0, "bieg": 2.3, "zasieg": 2.35, "obr": 50.0, "zamach": 0.80, "po_ataku": 0.9,
		"ciezki": true, "wzrok": 1.1, "krwawi": true, "oglusza_od": 999.0, "skala_tors": Vector3(0.84, 1, 0.9),
		"ryk": "krzyk", "krok": "zbroja", "zasieg_krokow": 12.0, "dowodca": true, "oburacz": true,
		"lup": [["monety", 5], ["relikwia", 4], ["klucz", 2]], "lup_min": 2, "lup_max": 3,
		"oprawa": [],
	},
	# troll: skóra jak płyta, rany zarastają, dopóki nie dostanie z ciężkiego kalibru
	"troll": {
		"model": "res://zasoby/modele/troll.glb", "styl": "ghul", "strefy": STREFY_TROLL, "szczeliny": [], "skala": 1.3,
		"chod": 0.9, "bieg": 2.5, "zasieg": 2.9, "obr": 70.0, "zamach": 1.05, "po_ataku": 1.2,
		"ciezki": true, "wzrok": 0.75, "krwawi": true, "oglusza_od": 999.0, "skala_tors": Vector3(0.9, 1, 0.8),
		"ryk": "troll_ryk", "krok": "krok_ciezki", "zasieg_krokow": 16.0, "oczy": 2.1,
		"kapsula": Vector2(0.48, 2.3), "regeneracja": 0.035, "ciezki_kaliber": ["7.62x51", "12/70"], "bez_wstrzasu": true,
		"lup": [], "lup_min": 0, "lup_max": 0,
		"oprawa": [["kosc", 3, 1.0], ["sciegna", 2, 1.0], ["gruczol", 2, 0.8]],
	},
	# warg: szybki, zachodzi z boku, ranny ucieka i wraca
	"warg": {
		"model": "res://zasoby/modele/warg.glb", "strefy": STREFY_WARG, "szczeliny": [], "cialo": "warg",
		"chod": 1.5, "bieg": 6.2, "zasieg": 1.9, "obr": 26.0, "zamach": 0.38, "po_ataku": 0.7,
		"ciezki": false, "wzrok": 1.3, "krwawi": true, "oglusza_od": 45.0, "skala_tors": Vector3(1, 1, 1),
		"ryk": "warg_warkot", "krok": "krok", "zasieg_krokow": 4.0, "oczy": 0.95,
		"kapsula": Vector2(0.38, 1.0), "oskrzydla": true, "ucieka_ponizej": 0.55,
		"lup": [], "lup_min": 0, "lup_max": 0,
		"oprawa": [["kosc", 1, 1.0], ["sciegna", 2, 0.9]],
	},
}

var typ := "ghul"
var d := {}
var swiat: Swiat
var stan := "czuwa"
var zyje := true
var pojemnik: Pojemnik          ## łup na zwłokach, tworzony przy śmierci
var oprawiony := false
var strefy: Array[StrefaWroga] = []

var _model: Node3D
var _w := {}                 ## nazwa -> węzeł segmentu
var _poza := {}              ## nazwa -> docelowy obrót (Vector3)
var _szybkosc_pozy := 8.0
var _faza := 0.0
var _t := 0.0
var _t_stan := 0.0
var _cel_poz := Vector3.ZERO
var _droga := PackedVector3Array()
var _i_droga := 0
var _t_droga := 0.0
var _t_zmysly := randf() * 0.2
var _uderzyl := false
var _pelza := false
var _bez_broni := false
var _krwotok := 0.0
var _hp_ogolne := 1.0
var _ost_krok := 0
var _kapsula: CollisionShape3D
var _pochyl := 0.0
var _model_y := 0.0
var _wstrzas := Vector3.ZERO     ## wzdrygnięcie po trafieniu, dodawane do tułowia i głowy
var _t_smierc := 0.0
var _smierc := {}                ## wariant upadku: kier (1 na plecy, -1 na twarz), bok, tempo
var _upadl := false
var frakcja := "potwory"
var skala := 1.0
var cel_wrog: Wrog               ## wróg z innej frakcji, z którym teraz walczy (null = gracz)
var _szal := 0.0                 ## litania kaznodziei: szybszy bieg i krótszy zamach
var _t_ciezka := 0.0             ## po ciężkim kalibrze rany trolla przez chwilę nie zarastają
var _uciekal := false
var _poznal_huk := false
var _bok_oskrzydlenia := 1.0
var _t_kazanie := 0.0
var _warg := false
var _styl := ""


func przygotuj(typ_wroga: String, swiat_: Swiat) -> void:
	typ = typ_wroga
	d = TYPY[typ]
	swiat = swiat_
	collision_layer = 8
	collision_mask = 1 | 8
	_kapsula = CollisionShape3D.new()
	var ks := CapsuleShape3D.new()
	var wym: Vector2 = d.get("kapsula", Vector2(0.33, 1.8))
	ks.radius = wym.x
	ks.height = wym.y
	_kapsula.shape = ks
	_kapsula.position.y = wym.y * 0.5
	frakcja = d.get("frakcja", "potwory")
	skala = d.get("skala", 1.0)
	_warg = d.get("cialo", "") == "warg"
	_styl = d.get("styl", typ)
	_bok_oskrzydlenia = 1.0 if randf() < 0.5 else -1.0
	add_child(_kapsula)
	_model = (load(d["model"]) as PackedScene).instantiate()
	add_child(_model)
	for n in _model.find_children("*", "Node3D", true, false):
		_w[String(n.name)] = n
		if n is MeshInstance3D:
			var siatka := (n as MeshInstance3D).mesh
			for i in siatka.get_surface_count():
				var mat := siatka.surface_get_material(i)
				if mat is BaseMaterial3D:
					(mat as BaseMaterial3D).texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	_model.scale = Vector3.ONE * skala
	_zbuduj_strefy()
	if _w.has("bron"):
		(_w["bron"] as Node3D).rotation.x = d.get("bron_obrot", -1.35)
	floor_snap_length = 0.3


func _zbuduj_strefy() -> void:
	var tabela: Dictionary = d["strefy"]
	for nazwa in tabela:
		if not _w.has(nazwa):
			continue
		var wezel: MeshInstance3D = _w[nazwa]
		var aabb := wezel.get_aabb()
		var rozmiar := aabb.size
		if _warg and nazwa == "tulow":
			# grzbiet z sierścią i brzuch nie są ciałem: węższa strefa
			rozmiar = Vector3(rozmiar.x * 0.9, rozmiar.y * 0.62, rozmiar.z * 0.92)
		if nazwa == "tors":
			rozmiar *= d["skala_tors"]
		var s := _nowa_strefa(wezel, nazwa, tabela[nazwa][0], tabela[nazwa][1], tabela[nazwa][2], tabela[nazwa][3])
		s.ustaw(rozmiar * 0.96, aabb.get_center())
	# dłonie i stopy to osobne segmenty; trafienie liczy się przedramieniu albo goleni
	for para in [["dlon_l", "przedramie_l"], ["dlon_p", "przedramie_p"], ["stopa_l", "golen_l"], ["stopa_p", "golen_p"]]:
		if _w.has(para[0]) and tabela.has(para[1]) and _w[para[0]] is MeshInstance3D:
			var m: MeshInstance3D = _w[para[0]]
			var ab := m.get_aabb()
			var sd := _nowa_strefa(m, para[1], tabela[para[1]][0], "szczelina", tabela[para[1]][2], 0.0)
			sd.ustaw(ab.size * 0.96, ab.get_center())
	for sz in d["szczeliny"]:
		var seg: String = sz[0]
		var lok: Vector3 = (sz[2] as Vector3) - (STAWY[seg] as Vector3)
		var roz: Vector3 = sz[3]
		var s := _nowa_strefa(_w[seg], seg, sz[1], "szczelina", 1, 0.0)
		s.ustaw(Vector3(roz.x, roz.z, roz.y), Vector3(lok.x, lok.z, -lok.y))


func _nowa_strefa(wezel: Node3D, segment: String, klucz: String, rodzaj: String, klasa: int, hp: float) -> StrefaWroga:
	var s := StrefaWroga.new()
	s.wrog = self
	s.segment = segment
	s.klucz = klucz
	s.rodzaj = rodzaj
	s.klasa = klasa
	s.hp = hp
	s.hp_max = hp
	wezel.add_child(s)
	strefy.append(s)
	return s


func _strefa_segmentu(segment: String) -> StrefaWroga:
	for s in strefy:
		if s.segment == segment and s.rodzaj != "szczelina":
			return s
	return null


# ====================================================================== trafienia

func trafiony(strefa: StrefaWroga, info: Dictionary) -> Dictionary:
	var kier: Vector3 = info["kier"]
	var cos_k := absf(kier.dot(info["normalna"]))
	var w := Amunicja.rozstrzygnij(info["przeb"], info["obr"], strefa.klasa, strefa.stan, cos_k, randf())
	strefa.stan = maxf(strefa.stan - float(w["uszk"]) * 1.4, 0.0)
	var obr: float = w["obr"]
	if not zyje:
		if w["przechodzi"] or strefa.klasa == 0:
			swiat.krew(info["poz"], kier, 0.5)
		w["przechodzi"] = false
		return w
	if strefa.rodzaj == "tarcza":
		strefa.hp -= info["obr"]
		Dzwiek.w_swiecie("uderzenie", info["poz"], -3.0, 0.1, 14.0)
		if strefa.hp <= 0.0:
			_odetnij("tarcza", kier, false)
		_zauwaz(swiat.gracz.global_position)
		return w
	# szczelina przekazuje obrażenia strefie segmentu, w którym jest
	var cel := strefa if strefa.rodzaj != "szczelina" else _strefa_segmentu(strefa.segment)
	if w["tepe"]:
		Dzwiek.w_swiecie("stal", info["poz"], -5.0, 0.08, 22.0)
	else:
		Dzwiek.w_swiecie("cialo", info["poz"], -2.0, 0.12, 10.0)
		swiat.krew(info["poz"], kier, clampf(obr / 45.0, 0.4, 2.2))
	if d.has("ciezki_kaliber") and obr > 1.0 and info.has("typ") and Amunicja.TYPY.has(info["typ"]):
		if String(Amunicja.TYPY[info["typ"]]["kaliber"]) in (d["ciezki_kaliber"] as Array):
			_t_ciezka = 12.0
	if cel != null:
		cel.hp -= obr
		_po_trafieniu(cel, obr, kier, info)
	if zyje and cel_wrog != null:
		cel_wrog = null
	# pocisk przechodzi przez ciało tylko z dużym zapasem przebicia
	w["przechodzi"] = bool(w["przechodzi"]) and float(info["przeb"]) > float(w["prog"]) + 18.0
	w["prog"] = float(w["prog"]) + 12.0
	if zyje:
		_zauwaz(swiat.gracz.global_position)
	return w


func _po_trafieniu(s: StrefaWroga, obr: float, kier: Vector3, info: Dictionary) -> void:
	var nadmiar := -s.hp
	match s.rodzaj:
		"glowa":
			if s.hp <= 0.0:
				if nadmiar > 12.0 or obr > 50.0:
					_odetnij("glowa", kier, true)
				_umrzyj(kier)
		"tors":
			if s.hp <= 0.0:
				_umrzyj(kier)
		"reka":
			if s.hp <= 0.0:
				var prawa := s.segment.ends_with("_p")
				if nadmiar > 10.0 or obr > 45.0:
					_odetnij(s.segment, kier, true)
				_wylacz_segment(s.segment)
				if prawa:
					_bez_broni = true
					if _w.has("bron") and is_instance_valid(_w["bron"]) and (_w["bron"] as Node3D).is_inside_tree():
						_odetnij("bron", kier, false)
		"noga":
			if s.hp <= 0.0:
				if nadmiar > 10.0 or obr > 45.0:
					_odetnij(s.segment, kier, true)
				_wylacz_segment(s.segment)
				_pelza = true
	if zyje and d.has("ucieka_ponizej") and not _uciekal:
		var tors := _strefa_segmentu("tulow")
		if _pelza or (tors != null and tors.hp < tors.hp_max * float(d["ucieka_ponizej"])):
			_uciekaj(7.0)
			Dzwiek.w_swiecie("warg_skowyt", global_position + Vector3.UP * 0.8, 0.0, 0.1, 20.0)
	if zyje and not d.get("bez_wstrzasu", false):
		var lok := global_transform.basis.inverse() * kier
		var sila := clampf(obr / 35.0, 0.25, 1.0) * (0.55 if typ == "rycerz" else 1.0)
		var bok := 1.0 if s.segment.ends_with("_p") else (-1.0 if s.segment.ends_with("_l") else signf(randf() - 0.5))
		_wstrzas = Vector3(lok.z * 0.42, bok * 0.34 * (1.0 if lok.z > 0.0 else -1.0), -bok * 0.10) * sila
	elif zyje:
		_wstrzas = Vector3(0.10, 0.08 * signf(randf() - 0.5), 0.0)
	if zyje and obr >= float(d["oglusza_od"]) and stan != "ogluszony" and stan != "ucieka":
		_ustaw_stan("ogluszony")
		_t_stan = 0.4


## Strefy zniszczonego segmentu i tego, co z niego wyrasta, przestają przyjmować trafienia.
func _wylacz_segment(segment: String) -> void:
	var pary := {"ramie_l": "przedramie_l", "ramie_p": "przedramie_p", "udo_l": "golen_l", "udo_p": "golen_p",
		"lapa_pl": "lapa_pl2", "lapa_pp": "lapa_pp2", "lapa_tl": "lapa_tl2", "lapa_tp": "lapa_tp2"}
	for s in strefy:
		if s.segment == segment or s.segment == pary.get(segment, ""):
			s.hp = minf(s.hp, 0.0)


func _odetnij(segment: String, kier: Vector3, krwawi: bool) -> void:
	if not _w.has(segment):
		return
	var wezel: Node3D = _w[segment]
	if not is_instance_valid(wezel) or wezel.get_parent() is RigidBody3D:
		return
	var gt := wezel.global_transform
	var rb := RigidBody3D.new()
	rb.collision_layer = 4
	rb.collision_mask = 1
	rb.mass = 3.0
	swiat.add_child(rb)
	rb.global_transform = gt
	var aabb := AABB(Vector3(-0.05, -0.2, -0.05), Vector3(0.1, 0.4, 0.1))
	if wezel is MeshInstance3D:
		aabb = (wezel as MeshInstance3D).get_aabb()
	var ks := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = aabb.size.max(Vector3(0.05, 0.05, 0.05))
	ks.shape = bs
	ks.position = aabb.get_center()
	rb.add_child(ks)
	wezel.get_parent().remove_child(wezel)
	rb.add_child(wezel)
	wezel.transform = Transform3D.IDENTITY
	for a in wezel.find_children("*", "Area3D", true, false):
		strefy.erase(a)
		a.queue_free()
	rb.linear_velocity = kier * randf_range(1.5, 3.5) + Vector3.UP * randf_range(1.0, 2.5)
	rb.angular_velocity = Vector3(randf_range(-6, 6), randf_range(-6, 6), randf_range(-6, 6))
	if krwawi and d["krwawi"]:
		swiat.krew(gt.origin, kier + Vector3.UP * 0.5, 2.5)
		_krwotok += 5.0
	elif krwawi:
		swiat.krew(gt.origin, kier, 0.6)
	Dzwiek.w_swiecie("cialo", gt.origin, 0.0, 0.2, 12.0)


func _umrzyj(kier: Vector3) -> void:
	if not zyje:
		return
	zyje = false
	_ustaw_stan("martwy")
	velocity = Vector3.ZERO
	pojemnik = Pojemnik.new(3, 2, "E_ZWLOKI")
	var los := RandomNumberGenerator.new()
	los.randomize()
	var tabela: Array = d["lup"]
	if not tabela.is_empty():
		Skrzynia.wypelnij(pojemnik, los, los.randi_range(d["lup_min"], d["lup_max"]), tabela)
	add_to_group("pojemniki")
	_kapsula.set_deferred("disabled", true)
	collision_layer = 0
	# upadek w dwóch etapach: najpierw uginają się kolana, potem ciało leci tam, dokąd pchnął je pocisk
	var przod := -global_transform.basis.z
	var prawo := global_transform.basis.x
	var do_tylu := kier.dot(przod) < 0.0
	var boczny := absf(kier.dot(prawo)) > 0.55 or randf() < 0.25
	_smierc = {
		"kier": 1.0 if do_tylu else -1.0,
		"bok": (signf(kier.dot(prawo)) if absf(kier.dot(prawo)) > 0.2 else signf(randf() - 0.5)) if boczny else 0.0,
		"tempo": randf_range(0.85, 1.2) * (1.35 if not _w.has("glowa") or (_w["glowa"] as Node3D).get_parent() is RigidBody3D else 1.0),
		"skret": randf_range(-0.5, 0.5),
		# kończyny leżą przy ziemi: ręce rozrzucone na boki, na plecach jedno kolano może sterczeć
		"reka_l": Vector3(randf_range(-0.12, 0.12), 0.0, randf_range(-1.25, -0.2)),
		"reka_p": Vector3(randf_range(-0.12, 0.12), 0.0, randf_range(0.2, 1.25)),
		"lokiec_l": randf_range(0.0, 0.35), "lokiec_p": randf_range(0.0, 0.35),
		"noga_l": Vector3(randf_range(0.0, 0.55) if do_tylu else randf_range(-0.08, 0.04), 0.0, randf_range(-0.30, -0.02)),
		"noga_p": Vector3(randf_range(-0.05, 0.1) if do_tylu else randf_range(-0.08, 0.04), 0.0, randf_range(0.02, 0.30)),
		"kolano_l": 0.0, "kolano_p": randf_range(0.0, 0.25),
		"glowa": Vector3(randf_range(-0.3, 0.3), randf_range(-0.7, 0.7), randf_range(-0.25, 0.25)),
	}
	if float(_smierc["bok"]) != 0.0:
		# na boku: ręce przed tułowiem, nogi lekko podkurczone - nic nie sterczy w górę
		_smierc["reka_l"] = Vector3(randf_range(0.25, 0.9), 0.0, -0.08)
		_smierc["reka_p"] = Vector3(randf_range(0.25, 0.9), 0.0, 0.08)
		_smierc["lokiec_l"] = randf_range(0.2, 1.0)
		_smierc["lokiec_p"] = randf_range(0.2, 1.0)
		_smierc["noga_l"] = Vector3(randf_range(0.1, 0.7), 0.0, 0.0)
		_smierc["noga_p"] = Vector3(randf_range(0.1, 0.7), 0.0, 0.0)
		_smierc["kolano_p"] = float((_smierc["noga_p"] as Vector3).x) * 1.5
	_smierc["kolano_l"] = float((_smierc["noga_l"] as Vector3).x) * 1.9
	_t_smierc = 0.0
	_upadl = false
	_wstrzas = Vector3.ZERO
	if d["krwawi"]:
		swiat.krew(global_position + Vector3.UP * 0.9, kier, 1.4)


# ====================================================================== zmysły

func uslyszal(pozycja: Vector3, promien: float) -> void:
	if not zyje:
		return
	# pierwszy wystrzał, jaki słyszy człowiek Zakonu: bez dowódcy w pobliżu szyk pęka
	if frakcja == "zakon" and promien >= 30.0 and not _poznal_huk and global_position.distance_to(pozycja) <= promien:
		_poznal_huk = true
		if not d.get("dowodca", false) and not _dowodca_blisko() and randf() < 0.7:
			_uciekaj(randf_range(4.0, 7.0))
			Dzwiek.w_swiecie("krzyk", global_position + Vector3.UP * 1.5, -2.0, 0.2, 16.0)
			return
	if stan == "goni" or stan == "atak" or stan == "ucieka" or stan == "celuje" or stan == "laduje" or stan == "kazanie":
		return
	if global_position.distance_to(pozycja) <= promien:
		_cel_poz = pozycja
		if stan != "szuka":
			_ustaw_stan("szuka")
		_t_droga = 0.0


func _dowodca_blisko() -> bool:
	for w in swiat.wrogowie:
		if is_instance_valid(w) and w != self and w.zyje and w.d.get("dowodca", false) and w.global_position.distance_to(global_position) < 16.0:
			return true
	return false


func _uciekaj(czas: float) -> void:
	_uciekal = true
	cel_wrog = null
	_cel_poz = swiat.punkt_ucieczki(global_position, swiat.gracz.global_position)
	_ustaw_stan("ucieka")
	_t_stan = -czas          # stan kończy się, gdy licznik dojdzie do zera
	_t_droga = 0.0


## Litania kaznodziei: potwory w zasięgu głosu biegną szybciej i wiedzą, gdzie jest gracz.
func wpadnij_w_szal(czas: float, gdzie: Vector3) -> void:
	if not zyje or frakcja != "potwory" or d.get("kaznodzieja", false):
		return
	_szal = maxf(_szal, czas)
	if stan == "czuwa" or stan == "szuka":
		_cel_poz = gdzie
		_ustaw_stan("goni")


func _zauwaz(pozycja: Vector3) -> void:
	if stan == "czuwa" or stan == "szuka":
		_cel_poz = pozycja
		_ustaw_stan("goni")
		Dzwiek.w_swiecie(d["ryk"], global_position + Vector3.UP * 1.5 * skala, 0.0, 0.12, 18.0)
		# krzyk słyszą inni
		for w in swiat.wrogowie:
			if w != self and is_instance_valid(w) and w.frakcja == frakcja:
				w.uslyszal(global_position, 14.0)


func _oczy() -> Vector3:
	return global_position + Vector3.UP * (0.5 if _pelza and not _warg else float(d.get("oczy", 1.6)))


func _widzi_gracza() -> bool:
	var g := swiat.gracz
	if g == null or not g.zdrowie.zyje:
		return false
	var oczy := _oczy()
	var cel := g.kamera.global_position
	var odl := oczy.distance_to(cel)
	var zasieg := (24.0 if g.latarka else (5.0 if g.kuca else 7.5)) * float(d["wzrok"])
	if odl > zasieg:
		return false
	var przod := -global_transform.basis.z
	var do_gracza := (cel - oczy).normalized()
	if odl > 2.5 and przod.dot(do_gracza) < 0.15 and not (stan == "goni"):
		return false
	var q := PhysicsRayQueryParameters3D.create(oczy, cel)
	q.collision_mask = 1
	q.exclude = [g.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(q).is_empty()


## Najbliższy żywy wróg z innej frakcji w zasięgu wzroku (Zakon i potwory walczą ze sobą).
func _szukaj_wroga_frakcji() -> Wrog:
	var najl: Wrog = null
	var najodl := 9.0
	for w in swiat.wrogowie:
		if not is_instance_valid(w) or w == self or not w.zyje or w.frakcja == frakcja:
			continue
		var odl := global_position.distance_to(w.global_position)
		if odl >= najodl:
			continue
		var q := PhysicsRayQueryParameters3D.create(_oczy(), w.global_position + Vector3.UP * 1.0)
		q.collision_mask = 1
		if get_world_3d().direct_space_state.intersect_ray(q).is_empty():
			najl = w
			najodl = odl
	return najl


## Cios od innego wroga: bez stref, pancerz tułowia odejmuje część obrażeń.
func cios_od(obr: float, kto: Wrog) -> void:
	if not zyje:
		return
	var tors := _strefa_segmentu("tulow" if _warg else "tors")
	if tors == null:
		return
	var ile := obr * maxf(0.25, 1.0 - tors.klasa * 0.17)
	tors.hp -= ile
	_wstrzas = Vector3(0.3, 0.2 * signf(randf() - 0.5), 0.0)
	Dzwiek.w_swiecie("cialo", global_position + Vector3.UP, -3.0, 0.15, 10.0)
	if d["krwawi"]:
		swiat.krew(global_position + Vector3.UP * 1.1, (global_position - kto.global_position).normalized(), 0.8)
	if tors.hp <= 0.0:
		_umrzyj((global_position - kto.global_position).normalized())
	elif cel_wrog == null and is_instance_valid(kto) and kto.zyje:
		cel_wrog = kto
		if stan == "czuwa" or stan == "szuka":
			_ustaw_stan("goni")


# ====================================================================== zachowanie

func _ustaw_stan(nowy: String) -> void:
	stan = nowy
	_t_stan = 0.0
	_uderzyl = false


func _cel_pozycja() -> Vector3:
	return cel_wrog.global_position if cel_wrog != null else swiat.gracz.global_position


func _cel_zyje() -> bool:
	return cel_wrog.zyje if cel_wrog != null else swiat.gracz.zdrowie.zyje


func _physics_process(dt: float) -> void:
	if not zyje:
		return
	if cel_wrog != null and (not is_instance_valid(cel_wrog) or not cel_wrog.zyje):
		cel_wrog = null
	_t_stan += dt if stan != "ogluszony" else 0.0
	_szal = maxf(_szal - dt, 0.0)
	if _krwotok > 0.0:
		_hp_ogolne -= _krwotok * dt / 100.0
		if randf() < dt * 4.0:
			swiat.slad(global_position + Vector3(randf_range(-0.2, 0.2), 0.02, randf_range(-0.2, 0.2)), Vector3.UP, "krew", randf_range(2.0, 4.0))
		if _hp_ogolne <= 0.0:
			_umrzyj(-global_transform.basis.z)
			return
	_t_zmysly -= dt
	var widzi := false
	if _t_zmysly <= 0.0:
		_t_zmysly = 0.15
		widzi = _widzi_gracza()
		if cel_wrog == null and stan != "ucieka":
			var obcy := _szukaj_wroga_frakcji()
			# gracz ma pierwszeństwo tylko wtedy, gdy jest bliżej niż obcy
			if obcy != null and (not widzi or obcy.global_position.distance_to(global_position) < swiat.gracz.global_position.distance_to(global_position)):
				cel_wrog = obcy
				_cel_poz = obcy.global_position
				if stan == "czuwa" or stan == "szuka":
					_zauwaz(_cel_poz)
		if cel_wrog != null:
			_cel_poz = cel_wrog.global_position
		elif widzi:
			_cel_poz = swiat.gracz.global_position
			if stan == "czuwa" or stan == "szuka":
				_zauwaz(_cel_poz)
	var kier_ruchu := Vector3.ZERO
	var predkosc := 0.0
	var mnoznik := 1.3 if _szal > 0.0 else 1.0
	match stan:
		"szuka":
			predkosc = float(d["chod"]) * 1.3
			kier_ruchu = _kierunek_do(_cel_poz, dt)
			if global_position.distance_to(_cel_poz) < 1.6:
				predkosc = 0.0
				if _t_stan > 4.0:
					_ustaw_stan("czuwa")
		"ucieka":
			predkosc = float(d["bieg"])
			kier_ruchu = _kierunek_do(_cel_poz, dt)
			if global_position.distance_to(_cel_poz) < 1.5:
				predkosc = 0.0
			if _t_stan >= 0.0:
				_cel_poz = swiat.gracz.global_position
				_ustaw_stan("goni" if frakcja == "zakon" or d.has("ucieka_ponizej") else "szuka")
		"goni":
			if not _cel_zyje():
				cel_wrog = null
				_ustaw_stan("czuwa")
			else:
				predkosc = float(d["bieg"]) * mnoznik
				var cp := _cel_pozycja()
				var odl := global_position.distance_to(cp)
				var dokad := _cel_poz
				# warg nie biegnie prosto: zachodzi z boku, jeśli jest tam wolne miejsce
				if d.get("oskrzydla", false) and cel_wrog == null and odl > 4.5 and odl < 14.0:
					var do_c := (cp - global_position)
					do_c.y = 0.0
					var bok_p := cp + do_c.normalized().cross(Vector3.UP) * _bok_oskrzydlenia * 3.2
					var qb := PhysicsRayQueryParameters3D.create(cp + Vector3.UP * 0.8, bok_p + Vector3.UP * 0.8)
					qb.collision_mask = 1
					qb.exclude = [swiat.gracz.get_rid()]
					if get_world_3d().direct_space_state.intersect_ray(qb).is_empty():
						dokad = bok_p
				kier_ruchu = _kierunek_do(dokad, dt)
				var widzi_cel := widzi or cel_wrog != null
				if d.get("kaznodzieja", false) and cel_wrog == null and odl > 4.0 and odl < 20.0 and _widzi_gracza():
					_ustaw_stan("kazanie")
					predkosc = 0.0
				elif d.has("strzela") and cel_wrog == null and odl > float(d["strzela"]["od"]) and odl < float(d["strzela"]["do"]) and _t_stan > 0.4 and _widzi_gracza():
					_ustaw_stan("celuje")
					predkosc = 0.0
				elif odl < float(d["zasieg"]) * 0.9:
					_ustaw_stan("atak")
					predkosc = 0.0
				elif odl > 3.0 and global_position.distance_to(_cel_poz) < 1.2 and _t_stan > 3.0 and not widzi_cel:
					_ustaw_stan("szuka")
		"kazanie":
			_obroc_do(swiat.gracz.global_position, dt)
			_t_kazanie -= dt
			if _t_kazanie <= 0.0:
				_t_kazanie = 2.3
				Dzwiek.w_swiecie("kazanie", global_position + Vector3.UP * 1.6, 2.0, 0.05, 30.0)
				if swiat.has_method("litania"):
					swiat.call("litania", 2.6)
				for w in swiat.wrogowie:
					if is_instance_valid(w) and w != self and w.global_position.distance_to(global_position) < 22.0:
						w.wpadnij_w_szal(6.0, swiat.gracz.global_position)
			var odl_k := global_position.distance_to(swiat.gracz.global_position)
			if odl_k < 3.5 or not swiat.gracz.zdrowie.zyje or (_t_stan > 2.0 and not _widzi_gracza()):
				_ustaw_stan("goni")
		"celuje":
			var g := swiat.gracz
			_obroc_do(g.global_position, dt * 1.6)
			if _t_stan >= float(d["strzela"]["celowanie"]):
				if _widzi_gracza() and not _bez_broni:
					_wystrzel_belt(g)
				_ustaw_stan("laduje")
			elif global_position.distance_to(g.global_position) < float(d["strzela"]["od"]) * 0.7:
				_ustaw_stan("goni")
		"laduje":
			if _t_stan >= float(d["strzela"]["ladowanie"]):
				_ustaw_stan("goni")
		"atak":
			var cp := _cel_pozycja()
			var do_g := cp - global_position
			do_g.y = 0.0
			_obroc_do(cp, dt)
			var zamach: float = float(d["zamach"]) * (0.8 if _szal > 0.0 else 1.0)
			if _t_stan >= zamach and not _uderzyl:
				_uderzyl = true
				Dzwiek.w_swiecie("swist", global_position + Vector3.UP * 1.3, -2.0, 0.1, 8.0)
				var przod := -global_transform.basis.z
				if do_g.length() < float(d["zasieg"]) + 0.25 and przod.dot(do_g.normalized()) > 0.45 and _cel_zyje():
					var obr: float = d["obr"] * (0.4 if _bez_broni else 1.0) * randf_range(0.85, 1.15)
					if cel_wrog != null:
						cel_wrog.cios_od(obr, self)
					else:
						var g := swiat.gracz
						g.zdrowie.cios(obr, d["ciezki"] and not _bez_broni)
						g.kopniecie(randf_range(-2.0, 2.0), randf_range(-2.5, 2.5))
						Dzwiek.przy_uchu("cios", 0.0, 0.1)
			if _t_stan >= zamach + float(d["po_ataku"]):
				_ustaw_stan("goni")
		"ogluszony":
			_t_stan -= dt
			if _t_stan <= 0.0:
				_ustaw_stan("goni")
	if _pelza:
		predkosc = minf(predkosc, 2.2 if _warg else 0.75)
	# ruch
	if kier_ruchu.length() > 0.01 and predkosc > 0.0:
		rotation.y = lerp_angle(rotation.y, atan2(-kier_ruchu.x, -kier_ruchu.z), 1.0 - exp(-7.0 * dt))
		var cel_v := -global_transform.basis.z * predkosc
		velocity.x = move_toward(velocity.x, cel_v.x, 12.0 * dt)
		velocity.z = move_toward(velocity.z, cel_v.z, 12.0 * dt)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 14.0 * dt)
		velocity.z = move_toward(velocity.z, 0.0, 14.0 * dt)
	if not is_on_floor():
		velocity.y -= 12.0 * dt
	move_and_slide()


func _obroc_do(cel: Vector3, dt: float) -> void:
	var k := cel - global_position
	k.y = 0.0
	if k.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-k.x, -k.z), 1.0 - exp(-6.0 * dt))


func _wystrzel_belt(g: Gracz) -> void:
	var b := Belt.new()
	b.swiat = swiat
	b.obr = float(d["strzela"]["obr"])
	swiat.add_child(b)
	var skad := global_position + Vector3.UP * 1.38 - global_transform.basis.z * 0.5
	var cel := g.global_position + Vector3.UP * (0.75 if g.kuca else 1.15)
	var odl := skad.distance_to(cel)
	var v: float = d["strzela"]["v"]
	var czas := odl / v
	var kier := (cel + Vector3.UP * 2.0 * czas * czas - skad).normalized()
	# rozrzut około 1,3 stopnia: z 20 metrów bełt mija stojącego mniej więcej co drugi raz
	kier = (kier + Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * 0.023).normalized()
	b.global_position = skad
	b.predkosc = kier * v
	b.look_at(skad + kier, Vector3.UP)
	Dzwiek.w_swiecie("kusza", skad, 0.0, 0.08, 26.0)


func _kierunek_do(cel: Vector3, dt: float) -> Vector3:
	_t_droga -= dt
	if _t_droga <= 0.0 or _droga.is_empty():
		_t_droga = 0.45
		_droga = swiat.sciezka(global_position, cel)
		_i_droga = 0
	while _i_droga < _droga.size() - 1 and Vector2(global_position.x - _droga[_i_droga].x, global_position.z - _droga[_i_droga].z).length() < 0.7:
		_i_droga += 1
	if _droga.is_empty():
		return Vector3.ZERO
	var p := _droga[mini(_i_droga, _droga.size() - 1)]
	var k := p - global_position
	k.y = 0.0
	return k.normalized() if k.length() > 0.15 else Vector3.ZERO


# ====================================================================== animacja

func _process(dt: float) -> void:
	_t += dt
	var v := Vector2(velocity.x, velocity.z).length()
	if zyje:
		_t_ciezka = maxf(_t_ciezka - dt, 0.0)
		if d.has("regeneracja") and _t_ciezka <= 0.0:
			for st in strefy:
				if st.hp_max > 0.0 and st.hp > 0.0 and st.hp < st.hp_max:
					st.hp = minf(st.hp + st.hp_max * float(d["regeneracja"]) * dt, st.hp_max)
			_krwotok = maxf(_krwotok - 2.0 * dt, 0.0)
		if _warg:
			_ustaw_poze_warg(v, dt)
		else:
			_ustaw_poze(v, dt)
	else:
		_poza_smierci(dt)
	for n in _poza:
		if _w.has(n) and is_instance_valid(_w[n]):
			var wezel: Node3D = _w[n]
			if wezel.get_parent() is RigidBody3D:
				continue
			wezel.rotation = wezel.rotation.lerp(_poza[n], 1.0 - exp(-_szybkosc_pozy * dt))
	if zyje:
		_model.rotation.x = lerp_angle(_model.rotation.x, _pochyl, 1.0 - exp(-5.0 * dt))
		_model.position.y = lerpf(_model.position.y, _model_y * skala, 1.0 - exp(-9.0 * dt))


## Śmierć: kolana puszczają, tułów zapada się, potem ciało przewraca się z przyspieszeniem
## i dopiero po uderzeniu o ziemię kończyny rozkładają się bezwładnie.
func _poza_smierci(dt: float) -> void:
	_t_smierc += dt * float(_smierc["tempo"])
	var kier: float = _smierc["kier"]
	var bok: float = _smierc["bok"]
	var t1 := 0.30
	var t2 := 0.62
	var k1 := clampf(_t_smierc / t1, 0.0, 1.0)
	var k2 := clampf((_t_smierc - t1 * 0.6) / t2, 0.0, 1.0)
	var spad := k2 * k2
	_szybkosc_pozy = 11.0
	if _warg:
		# zwierzę pada na bok: łapy sztywnieją, łeb opada
		var strona: float = bok if bok != 0.0 else kier
		for n in ["lapa_pl", "lapa_pp", "lapa_tl", "lapa_tp"]:
			_poza[n] = Vector3((0.35 if n.begins_with("lapa_p") else -0.3) * spad + float(_smierc["skret"]) * 0.3, 0, 0)
			_poza[n + "2"] = Vector3((-0.5 if n.begins_with("lapa_p") else 0.4) * spad, 0, 0)
		_poza["szyja"] = Vector3(-0.5 * spad, 0, 0.3 * strona * spad)
		_poza["glowa"] = Vector3(-0.2, 0, 0)
		_poza["zuchwa"] = Vector3(-0.35, 0, 0)
		_poza["ogon"] = Vector3(-0.4, 0, 0)
		_poza["tulow"] = Vector3.ZERO
		_model.rotation.z = -strona * (PI * 0.5 - 0.08) * spad
		_model.rotation.x = 0.0
		_model.position.y = lerpf(_model.position.y, 0.17, spad)
		if k2 >= 1.0 and not _upadl:
			_upadl = true
			Dzwiek.w_swiecie("cialo_upadek", global_position, -4.0, 0.1, 12.0)
			swiat.krew(global_position + Vector3.UP * 0.3, Vector3.DOWN, 2.0)
		return
	if not _pelza:
		if k2 < 1.0:
			var ugiecie := sin(k1 * PI * 0.5)
			_poza["udo_l"] = Vector3(0.75 * ugiecie, 0, -0.06)
			_poza["udo_p"] = Vector3(0.55 * ugiecie, 0, 0.08)
			_poza["golen_l"] = Vector3(-1.45 * ugiecie, 0, 0)
			_poza["golen_p"] = Vector3(-1.15 * ugiecie, 0, 0)
			_poza["stopa_l"] = Vector3(0.5 * ugiecie, 0, 0)
			_poza["stopa_p"] = Vector3(0.4 * ugiecie, 0, 0)
			_poza["tors"] = Vector3(0.30 * kier * ugiecie - 0.25 * ugiecie, float(_smierc["skret"]), 0.18 * bok)
			_poza["glowa"] = Vector3(0.5 * kier * ugiecie, 0, 0.25 * bok)
			_poza["ramie_l"] = Vector3(0.35 * kier, 0, -0.35 * ugiecie)
			_poza["ramie_p"] = Vector3(0.35 * kier, 0, 0.35 * ugiecie)
			_poza["przedramie_l"] = Vector3(0.5, 0, 0)
			_poza["przedramie_p"] = Vector3(0.5, 0, 0)
		else:
			_szybkosc_pozy = 7.0
			_poza["udo_l"] = _smierc["noga_l"]
			_poza["udo_p"] = _smierc["noga_p"]
			_poza["golen_l"] = Vector3(-float(_smierc["kolano_l"]), 0, 0)
			_poza["golen_p"] = Vector3(-float(_smierc["kolano_p"]), 0, 0)
			_poza["stopa_l"] = Vector3(-0.55, 0, 0)
			_poza["stopa_p"] = Vector3(-0.45, 0, 0)
			_poza["tors"] = Vector3(0.0, float(_smierc["skret"]) * 0.4, 0.10 * bok)
			_poza["glowa"] = _smierc["glowa"]
			_poza["ramie_l"] = _smierc["reka_l"]
			_poza["ramie_p"] = _smierc["reka_p"]
			_poza["przedramie_l"] = Vector3(float(_smierc["lokiec_l"]), 0, 0)
			_poza["przedramie_p"] = Vector3(float(_smierc["lokiec_p"]), 0, 0)
			_poza["dlon_l"] = Vector3(0.4, 0, 0)
			_poza["dlon_p"] = Vector3(0.3, 0, 0)
		_poza["miednica"] = Vector3.ZERO
	var kat := PI * 0.5 - 0.05
	var start_x := -1.32 if _pelza else 0.0
	if bok != 0.0 and not _pelza:
		_model.rotation.x = kier * 0.35 * spad
		_model.rotation.z = -bok * kat * spad
		_model.position.y = lerpf(-0.17 * sin(k1 * PI * 0.5), 0.21, spad) * skala
	else:
		_model.rotation.x = lerpf(start_x, kat * (kier if not _pelza else -1.0), spad)
		_model.position.y = lerpf(-0.17 * sin(k1 * PI * 0.5) if not _pelza else 0.22, 0.12 if kier > 0.0 and not _pelza else 0.15, spad) * skala
	if k2 >= 1.0 and not _upadl:
		_upadl = true
		Dzwiek.w_swiecie("cialo_upadek", global_position, -2.0, 0.1, 12.0)
		if d["krwawi"]:
			swiat.krew(global_position + Vector3.UP * 0.3, Vector3.DOWN, 2.0)
		if _w.has("bron") and is_instance_valid(_w["bron"]) and not ((_w["bron"] as Node3D).get_parent() is RigidBody3D):
			_odetnij("bron", Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3)), false)


## Warg: kłus na przekątnych parach łap, w biegu galop z pracą grzbietu, skok z rozwartą paszczą.
func _ustaw_poze_warg(v: float, dt: float) -> void:
	var galop := clampf((v - 2.6) / 2.0, 0.0, 1.0)
	_faza += v * dt * PI / lerpf(0.55, 1.05, galop)
	var a := clampf(v / 1.4, 0.0, 1.0) * lerpf(0.42, 0.72, galop)
	_szybkosc_pozy = 14.0
	_pochyl = 0.0
	# przesunięcia faz: kłus (pl+tp razem), galop (przednie razem, tylne pół cyklu później)
	var fazy := {
		"lapa_pl": 0.0, "lapa_tp": lerpf(0.0, PI * 0.9, galop),
		"lapa_pp": lerpf(PI, 0.45, galop), "lapa_tl": lerpf(PI, PI * 0.9 + 0.45, galop),
	}
	for n in fazy:
		var f: float = _faza + float(fazy[n])
		var przod: bool = (n as String).begins_with("lapa_p")
		var zg := maxf(0.0, cos(f))
		_poza[n] = Vector3(sin(f) * a + (0.0 if przod else -0.08), 0, 0)
		_poza[n + "2"] = Vector3((-1.0 if przod else 0.9) * zg * zg * a * 1.5, 0, 0)
	var grzbiet := sin(_faza) * 0.10 * galop
	_poza["tulow"] = Vector3(grzbiet, sin(_faza) * 0.05 * a * (1.0 - galop), 0)
	_model_y = -absf(sin(_faza)) * 0.03 * a + maxf(0.0, cos(_faza)) * 0.06 * galop
	var goni := stan == "goni" or stan == "atak"
	var nasluch := sin(_t * 0.6) * 0.3 * (0.0 if goni else 1.0)
	_poza["szyja"] = Vector3((-0.38 if goni else 0.05) - grzbiet, nasluch, 0)
	_poza["glowa"] = Vector3(0.22 if goni else 0.0, nasluch * 0.6, 0)
	_poza["zuchwa"] = Vector3(-0.12 - 0.08 * sin(_t * 9.0) if goni else -0.03, 0, 0)
	_poza["ogon"] = Vector3((0.55 if goni else 0.1) + sin(_faza) * 0.12, sin(_t * 2.1) * 0.15, 0)
	if stan == "ucieka":
		_poza["ogon"] = Vector3(-0.5, 0, 0)
		_poza["szyja"] = Vector3(-0.3, 0, 0)
	if stan == "atak":
		var zamach: float = d["zamach"]
		var etap := 0 if _t_stan < zamach else (1 if _t_stan < zamach + 0.2 else 2)
		_szybkosc_pozy = [9.0, 30.0, 6.0][etap]
		# przysiad na zadzie, skok z wyciągniętymi łapami, lądowanie
		_poza["tulow"] = Vector3([-0.20, 0.16, 0.0][etap], 0, 0)
		_poza["lapa_tl"] = Vector3([0.55, -0.75, 0.0][etap], 0, 0)
		_poza["lapa_tp"] = Vector3([0.55, -0.75, 0.0][etap], 0, 0)
		_poza["lapa_tl2"] = Vector3([0.7, 0.1, 0.2][etap], 0, 0)
		_poza["lapa_tp2"] = Vector3([0.7, 0.1, 0.2][etap], 0, 0)
		_poza["lapa_pl"] = Vector3([-0.2, 0.95, 0.3][etap], 0, 0)
		_poza["lapa_pp"] = Vector3([-0.2, 1.05, 0.3][etap], 0, 0)
		_poza["lapa_pl2"] = Vector3([-0.5, -0.2, -0.2][etap], 0, 0)
		_poza["lapa_pp2"] = Vector3([-0.5, -0.2, -0.2][etap], 0, 0)
		_poza["szyja"] = Vector3([-0.45, 0.15, -0.2][etap], 0, 0)
		_poza["glowa"] = Vector3([0.3, 0.25, 0.1][etap], 0, 0)
		_poza["zuchwa"] = Vector3([-0.25, -0.75, -0.15][etap], 0, 0)
		_model_y = [-0.10, 0.14, 0.0][etap]
	elif stan == "ogluszony":
		_poza["szyja"] = Vector3(-0.5, 0.4, 0)
		_model_y = -0.08
	if _pelza:
		# okulały: zad niżej, krótki krok
		_poza["tulow"] = Vector3(-0.12, 0, 0.06)
		_model_y -= 0.06
	if _wstrzas.length() > 0.02:
		_poza["tulow"] = (_poza["tulow"] as Vector3) + Vector3(_wstrzas.x * 0.4, _wstrzas.y * 0.5, _wstrzas.z)
		_poza["szyja"] = (_poza["szyja"] as Vector3) + Vector3(0.2, _wstrzas.y, 0)
		_wstrzas *= exp(-6.0 * dt)
	var nr := int(_faza / PI)
	if nr != _ost_krok and v > 0.3:
		_ost_krok = nr
		Dzwiek.w_swiecie(d["krok"], global_position, -10.0, 0.2, d["zasieg_krokow"])


func _ustaw_poze(v: float, dt: float) -> void:
	var dl_kroku := (0.62 if _styl == "ghul" else (0.74 if _styl == "knecht" else 0.70)) * skala
	_faza += v * dt * PI / dl_kroku
	var bieg := clampf((v / skala - 1.4) / 2.0, 0.0, 1.0)
	var a := clampf(v / skala / 1.5, 0.0, 1.0) * (0.50 + 0.22 * bieg)
	var s := sin(_faza)
	var c := cos(_faza)
	_szybkosc_pozy = 12.0
	_pochyl = 0.0
	# środek ciężkości: najniżej przy podwójnym podporze, najwyżej nad nogą podporową
	_model_y = -(0.012 + absf(s) * (0.030 + 0.03 * bieg)) * (a / 0.5)
	# noga w przenoszeniu (leci do przodu) zgina kolano; podporowa prawie prosta
	var zg_l := maxf(0.0, c)
	var zg_p := maxf(0.0, -c)
	var kol := 0.95 + 0.5 * bieg
	_poza["udo_l"] = Vector3((s + 0.12 + 0.35 * zg_l) * a, 0, -0.03)
	_poza["udo_p"] = Vector3((-s + 0.12 + 0.35 * zg_p) * a, 0, 0.03)
	_poza["golen_l"] = Vector3(-0.07 - (0.16 + kol * zg_l * zg_l) * a * 1.7, 0, 0)
	_poza["golen_p"] = Vector3(-0.07 - (0.16 + kol * zg_p * zg_p) * a * 1.7, 0, 0)
	# stopa: płasko w podporze, palce w dół przy wybiciu, w górę przed postawieniem pięty
	_poza["stopa_l"] = Vector3(-(_poza["udo_l"].x + _poza["golen_l"].x) * 0.75 - 0.45 * a * maxf(0.0, -s) * zg_l + 0.25 * a * maxf(0.0, s), 0, 0)
	_poza["stopa_p"] = Vector3(-(_poza["udo_p"].x + _poza["golen_p"].x) * 0.75 - 0.45 * a * maxf(0.0, s) * zg_p + 0.25 * a * maxf(0.0, -s), 0, 0)
	# miednica idzie za nogą wykroczną i opada po stronie nogi przenoszonej; barki odwrotnie
	_poza["miednica"] = Vector3(0, -s * 0.16 * a, c * 0.07 * a)
	var oddech := sin(_t * 1.7) * 0.03
	var goni := stan == "goni" or stan == "atak" or stan == "celuje" or stan == "kazanie"
	var stoi := 1.0 - clampf(v / 0.4, 0.0, 1.0)
	var kolys := sin(_t * 0.9) * 0.02 * stoi
	if _styl == "ghul":
		_poza["tors"] = Vector3(-0.30 - (0.22 if goni else 0.0) + oddech, s * 0.34 * a, -c * 0.07 * a + kolys * 2.0)
		_poza["glowa"] = Vector3(0.28 + (0.2 if goni else 0.0), sin(_t * 0.7) * 0.25 * (0.0 if goni else 1.0) - s * 0.15 * a, sin(_t * 1.3) * 0.06)
		var siega := 1.15 if goni else 0.15
		_poza["ramie_l"] = Vector3(siega - s * a * 0.7, 0, -0.14 - kolys)
		_poza["ramie_p"] = Vector3(siega + s * a * 0.7, 0, 0.14 + kolys)
		_poza["przedramie_l"] = Vector3((0.45 if goni else 0.25) + maxf(0.0, -s) * a * 0.5, 0, 0)
		_poza["przedramie_p"] = Vector3((0.45 if goni else 0.25) + maxf(0.0, s) * a * 0.5, 0, 0)
		_poza["dlon_l"] = Vector3(0.35 if goni else 0.1, 0, 0)
		_poza["dlon_p"] = Vector3(0.35 if goni else 0.1, 0, 0)
	else:
		_poza["tors"] = Vector3(-0.05 - 0.10 * bieg + oddech * 0.5, s * 0.30 * a, -c * 0.06 * a + kolys)
		_poza["glowa"] = Vector3(0.04 + 0.08 * bieg, sin(_t * 0.5) * 0.18 * (0.0 if goni else 1.0) - s * 0.14 * a, 0)
		_poza["ramie_l"] = Vector3(0.06 - s * a * 0.75, 0, -0.07 - kolys)
		_poza["przedramie_l"] = Vector3(0.18 + maxf(0.0, -s) * a * 0.8 + 0.5 * bieg, 0, 0)
		_poza["ramie_p"] = Vector3((0.50 if goni else 0.08) + s * a * (0.3 if goni else 0.75), 0, 0.07 + kolys)
		_poza["przedramie_p"] = Vector3((0.60 if goni else 0.18) + maxf(0.0, s) * a * 0.6, 0, 0)
		_poza["dlon_l"] = Vector3(0.08, 0, 0)
		_poza["dlon_p"] = Vector3(0.08, 0, 0)
		if _styl == "knecht" and goni:
			# tarcza przed sobą
			_poza["ramie_l"] = Vector3(0.22 - s * a * 0.10, 0, 0.16)
			_poza["przedramie_l"] = Vector3(0.42, 0, 0)
		if _styl == "rycerz" and goni:
			_poza["ramie_l"] = Vector3(0.55 - s * a * 0.2, 0, 0.25)
			_poza["przedramie_l"] = Vector3(0.75, 0, 0)
	if stan == "atak":
		var zamach: float = d["zamach"]
		var etap := 0 if _t_stan < zamach else (1 if _t_stan < zamach + 0.16 else 2)
		_szybkosc_pozy = [6.5, 30.0, 5.0][etap]
		# wykrok przy ciosie, cofnięcie ciężaru przy zamachu
		var wykrok: float = [-0.10, 0.55, 0.30][etap]
		_poza["udo_p"] = Vector3(wykrok, 0, 0.04)
		_poza["golen_p"] = Vector3(-0.15 - maxf(0.0, wykrok) * 0.9, 0, 0)
		_poza["udo_l"] = Vector3(-wykrok * 0.6 + 0.1, 0, -0.04)
		_poza["golen_l"] = Vector3(-0.30, 0, 0)
		_poza["stopa_p"] = Vector3(-(_poza["udo_p"].x + _poza["golen_p"].x), 0, 0)
		_poza["stopa_l"] = Vector3(-(_poza["udo_l"].x + _poza["golen_l"].x), 0, 0)
		_model_y = [-0.03, -0.09, -0.06][etap]
		if _styl == "ghul":
			_poza["ramie_p"] = [Vector3(-0.9, 0, 0.55), Vector3(2.1, 0, -0.35), Vector3(0.9, 0, -0.55)][etap]
			_poza["ramie_l"] = [Vector3(0.7, 0, -0.35), Vector3(1.8, 0, 0.25), Vector3(0.6, 0, 0.2)][etap]
			_poza["przedramie_p"] = Vector3([1.3, 0.1, 0.7][etap], 0, 0)
			_poza["przedramie_l"] = Vector3([0.9, 0.2, 0.8][etap], 0, 0)
			_poza["dlon_p"] = Vector3([-0.5, 0.6, 0.3][etap], 0, 0)
			_poza["tors"] = [Vector3(-0.12, 0.55, 0.08), Vector3(-0.80, -0.45, -0.08), Vector3(-0.95, -0.65, -0.1)][etap]
			_poza["glowa"] = Vector3([0.2, 0.75, 0.6][etap], 0, 0)
			_poza["miednica"] = Vector3(0, [0.25, -0.25, -0.3][etap], 0)
		else:
			_poza["ramie_p"] = [Vector3(2.75, 0, 0.30), Vector3(0.70, 0, -0.20), Vector3(-0.05, 0, -0.35)][etap]
			_poza["przedramie_p"] = Vector3([1.15, 0.12, 0.30][etap], 0, 0)
			_poza["dlon_p"] = Vector3([-0.3, 0.35, 0.2][etap], 0, 0)
			_poza["tors"] = [Vector3(0.14, 0.42, 0.06), Vector3(-0.40, -0.38, -0.05), Vector3(-0.55, -0.55, -0.08)][etap]
			_poza["glowa"] = Vector3([-0.05, 0.25, 0.3][etap], [-0.3, 0.25, 0.3][etap], 0)
			_poza["miednica"] = Vector3(0, [0.22, -0.2, -0.25][etap], 0)
			if _styl == "rycerz":
				_poza["ramie_l"] = [Vector3(2.55, 0, -0.30), Vector3(0.85, 0, 0.45), Vector3(0.10, 0, 0.5)][etap]
				_poza["przedramie_l"] = Vector3([1.0, 0.45, 0.6][etap], 0, 0)
			else:
				_poza["ramie_l"] = [Vector3(0.75, 0, 0.25), Vector3(0.35, 0, -0.25), Vector3(0.3, 0, -0.2)][etap]
				_poza["przedramie_l"] = Vector3([1.1, 0.8, 0.8][etap], 0, 0)
		if d.get("pchniecie", false):
			# włócznia: cofnięcie łokcia, pchnięcie całym ciałem zza tarczy
			_poza["ramie_p"] = [Vector3(-0.75, 0, 0.25), Vector3(1.25, 0, 0.05), Vector3(0.75, 0, 0.1)][etap]
			_poza["przedramie_p"] = Vector3([1.75, 0.25, 0.9][etap], 0, 0)
			_poza["dlon_p"] = Vector3.ZERO
			_poza["tors"] = [Vector3(-0.10, 0.50, 0.0), Vector3(-0.38, -0.42, 0.0), Vector3(-0.28, -0.2, 0.0)][etap]
			_poza["ramie_l"] = Vector3(0.30, 0, 0.18)
			_poza["przedramie_l"] = Vector3(0.50, 0, 0)
	elif stan == "kazanie":
		# kostur w górze, wolna ręka wyciągnięta ku graczowi, kołysanie w rytm litanii
		var rytm := sin(_t * 2.7)
		_poza["ramie_p"] = Vector3(2.35 + rytm * 0.12, 0, 0.25)
		_poza["przedramie_p"] = Vector3(0.45, 0, 0)
		_poza["ramie_l"] = Vector3(1.35 + rytm * 0.10, 0, -0.35)
		_poza["przedramie_l"] = Vector3(0.25, 0, 0)
		_poza["dlon_l"] = Vector3(-0.5, 0, 0)
		_poza["tors"] = Vector3(0.10 + rytm * 0.05, rytm * 0.08, 0)
		_poza["glowa"] = Vector3(-0.25, 0, rytm * 0.06)
	elif stan == "celuje":
		# kusza przy policzku: prawa ręka pod łożem, lewa podpiera, tułów bokiem
		_szybkosc_pozy = 9.0
		_poza["tors"] = Vector3(-0.06, -0.30, 0)
		_poza["glowa"] = Vector3(0.05, 0.28, -0.12)
		_poza["ramie_p"] = Vector3(1.05, 0, 0.30)
		_poza["przedramie_p"] = Vector3(0.50, 0, 0)
		_poza["dlon_p"] = Vector3.ZERO
		_poza["ramie_l"] = Vector3(1.20, 0, 0.55)
		_poza["przedramie_l"] = Vector3(0.55, 0, 0)
		_poza["udo_l"] = Vector3(0.22, 0, -0.08)
		_poza["udo_p"] = Vector3(-0.18, 0, 0.08)
	elif stan == "laduje":
		# napinanie: stopa w strzemieniu, plecy zgięte, obie ręce ciągną cięciwę
		var ciag := clampf(_t_stan / 2.2, 0.0, 1.0)
		_szybkosc_pozy = 6.0
		_poza["tors"] = Vector3(-0.95 + ciag * 0.55, 0, 0)
		_poza["glowa"] = Vector3(0.35, 0, 0)
		_poza["ramie_p"] = Vector3(0.75 - ciag * 0.3, 0, -0.10)
		_poza["ramie_l"] = Vector3(0.75 - ciag * 0.3, 0, 0.10)
		_poza["przedramie_p"] = Vector3(0.15 + ciag * 0.9, 0, 0)
		_poza["przedramie_l"] = Vector3(0.15 + ciag * 0.9, 0, 0)
		_poza["udo_p"] = Vector3(0.45, 0, 0)
		_poza["golen_p"] = Vector3(-0.75, 0, 0)
		_model_y = -0.06
	elif stan == "ogluszony":
		_poza["tors"] = Vector3(0.38, 0.25, 0.14)
		_poza["glowa"] = Vector3(-0.35, 0.2, 0.25)
		_poza["udo_l"] = Vector3(0.35, 0, -0.1)
		_poza["golen_l"] = Vector3(-0.6, 0, 0)
		_poza["udo_p"] = Vector3(-0.2, 0, 0.1)
		_poza["golen_p"] = Vector3(-0.35, 0, 0)
		_poza["ramie_l"] = Vector3(-0.3, 0, -0.6)
		_poza["ramie_p"] = Vector3(0.1, 0, 0.5)
		_model_y = -0.07
	if _pelza:
		_pochyl = -1.32
		_model_y = 0.22
		c = sin(_t * 3.0) * (1.0 if v > 0.1 else 0.2)
		_poza["miednica"] = Vector3(0, c * 0.1, 0)
		_poza["stopa_l"] = Vector3(-0.6, 0, 0)
		_poza["stopa_p"] = Vector3(-0.6, 0, 0)
		_poza["tors"] = Vector3(0.25, c * 0.15, 0)
		_poza["glowa"] = Vector3(0.9, 0, 0)
		_poza["ramie_l"] = Vector3(2.5 + c * 0.5, 0, -0.3)
		_poza["ramie_p"] = Vector3(2.5 - c * 0.5, 0, 0.3)
		_poza["przedramie_l"] = Vector3(0.5 - c * 0.4, 0, 0)
		_poza["przedramie_p"] = Vector3(0.5 + c * 0.4, 0, 0)
		_poza["udo_l"] = Vector3(-0.1, 0, 0)
		_poza["udo_p"] = Vector3(-0.1, 0, 0)
		_poza["golen_l"] = Vector3(-0.1, 0, 0)
		_poza["golen_p"] = Vector3(-0.1, 0, 0)
	# broń drzewcowa i kusza trzymają stały kąt względem ziemi niezależnie od zgięcia ręki
	if d.has("bron_kat") and not _pelza:
		var kat: float = d["bron_kat"]
		if stan == "laduje":
			kat = -2.9
		if stan == "atak" and not d.get("pchniecie", false):
			_poza["bron"] = Vector3(d.get("bron_obrot", -1.35), 0, 0)
		else:
			_poza["bron"] = Vector3(kat - (_poza["ramie_p"] as Vector3).x - (_poza["przedramie_p"] as Vector3).x - (_poza["tors"] as Vector3).x, 0, 0)
	# wzdrygnięcie po trafieniu nakłada się na każdą pozę i szybko gaśnie
	if _wstrzas.length() > 0.02:
		_poza["tors"] = (_poza["tors"] as Vector3) + _wstrzas
		_poza["glowa"] = (_poza["glowa"] as Vector3) + _wstrzas * Vector3(-0.6, 0.5, 1.0)
		_poza["ramie_l"] = (_poza["ramie_l"] as Vector3) + Vector3(-_wstrzas.x * 0.6, 0, -absf(_wstrzas.y) * 0.5)
		_poza["ramie_p"] = (_poza["ramie_p"] as Vector3) + Vector3(-_wstrzas.x * 0.6, 0, absf(_wstrzas.y) * 0.5)
		_szybkosc_pozy = maxf(_szybkosc_pozy, 22.0)
		_wstrzas *= exp(-5.5 * dt)
	# odgłos kroków
	var nr := int(_faza / PI)
	if nr != _ost_krok and v > 0.3:
		_ost_krok = nr
		Dzwiek.w_swiecie(d["krok"], global_position, -8.0 if _styl == "ghul" else -2.0, 0.15, d["zasieg_krokow"])
