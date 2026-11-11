class_name Kopalnia
extends Swiat
## Build 2: pierwszy loch. Ręcznie ułożony poziom zatopionej kopalni.
## Mapa to siatka pól 3×3 m. Znaki: # skała, . chodnik, S wejście (drabina),
## T pochodnia, g ghul, k umarły knecht, r upadły rycerz.

const POLE := 3.0
const WYS := 3.1
const SKRZYNIE := [Vector2i(20, 1), Vector2i(9, 3), Vector2i(1, 7), Vector2i(11, 9), Vector2i(1, 11)]
const MAPA := [
	"######################",
	"#S...#.......#g....#.#",
	"#.##.#.#####.#.###.#.#",
	"#.#....#g..#...#.T...#",
	"#.#.####...#####.###.#",
	"#...T..#.......#...#.#",
	"####.#.###.###.###.#.#",
	"#..#.#...#.#k#...#...#",
	"#.g#.###.#.#.###.#####",
	"#....#...#...#.....T.#",
	"#.####.#######.###.#.#",
	"#......T...k.....#.r.#",
	"######################",
]

const P_SZYB := Vector2i(20, 9)       ## wyjście za kratą: wymaga żelaznego klucza
const P_CHODNIK := Vector2i(1, 9)     ## stary chodnik: zawala się przy Przebudzeniu 50
const P_BIWAK := Vector2i(7, 7)
const P_PIEC := Vector2i(18, 3)
const P_STOL := Vector2i(8, 9)
const ZYLY := [
	[Vector2i(6, 1), "ruda_miedzi"], [Vector2i(12, 1), "ruda_olowiu"], [Vector2i(10, 5), "ruda_zelaza"],
	[Vector2i(3, 9), "siarka"], [Vector2i(15, 9), "saletra"], [Vector2i(14, 11), "ruda_miedzi"],
	[Vector2i(5, 11), "ruda_olowiu"], [Vector2i(18, 5), "ruda_zelaza"],
]
## próg Przebudzenia: [komunikat, wrogowie do wypuszczenia]
const PROGI := [
	[25.0, "BUDZI_1", ["ghul", "ghul"]],
	[50.0, "BUDZI_2", ["knecht", "ghul"]],
	[75.0, "BUDZI_3", ["rycerz", "ghul", "ghul"]],
	[100.0, "BUDZI_4", ["ghul", "ghul", "knecht"]],
]

var _siatka: AStarGrid2D
var _start := Vector3.ZERO
var bez_wrogow := false
var przebudzenie := 0.0
var prog := 0                     ## ile progów już minęło
var chodnik_zawalony := false
var dane_biwaku := {}             ## ustawiane przed wejściem do drzewa przy wznowieniu
var _lista_skrzyn: Array[Skrzynia] = []
var _wrogowie_startowi: Array = []
var _t_fala := 0.0
var _zawal: Node3D
var _zyly: Array = []             ## {poz, id, ile, wezel}
var _los := RandomNumberGenerator.new()


func _ready() -> void:
	wyprawa = true
	_los.randomize()
	przygotuj_swiat()
	_otoczenie()
	_poziom()
	_wyjscia_i_biwak()
	_wrogowie_startowi = wrogowie.duplicate()
	var poz := _start + Vector3(0, 0.05, 0)
	if not dane_biwaku.is_empty():
		poz = _srodek(P_BIWAK.x, P_BIWAK.y) + Vector3(0, 0.05, 0)
	stworz_gracza(poz, -PI * 0.5)
	for b in bronie:
		b.wlacz_latarke(true)
	gracz.latarka = true
	if not dane_biwaku.is_empty():
		_wznow(dane_biwaku)


func _wyjscia_i_biwak() -> void:
	var dr := Mat.drewno()
	var zel := Mat.kolor(Color("26282b"), 0.6, 0.7)
	# krata szybu
	var ps := _srodek(P_SZYB.x, P_SZYB.y)
	for i in 6:
		Mat.blok(self, Vector3(0.05, WYS, 0.05), ps + Vector3(-1.0 + i * 0.4, WYS * 0.5, 1.2), zel, false)
	for y in [0.5, 1.6, 2.6]:
		Mat.blok(self, Vector3(2.4, 0.06, 0.06), ps + Vector3(0, y, 1.2), zel, false)
	var sw := OmniLight3D.new()
	sw.position = ps + Vector3(0, 2.4, 0.6)
	sw.light_color = Color(0.55, 0.62, 0.75)
	sw.light_energy = 0.6
	sw.omni_range = 5.0
	add_child(sw)
	# stary chodnik: pochylnia w górę i blade światło
	var pc := _srodek(P_CHODNIK.x, P_CHODNIK.y)
	Mat.blok(self, Vector3(2.2, 0.2, 2.6), pc + Vector3(-0.2, 0.35, 0.9), dr, false, Vector3(deg_to_rad(-22), 0, 0))
	var sw2 := OmniLight3D.new()
	sw2.position = pc + Vector3(0, 2.3, 1.0)
	sw2.light_color = Color(0.6, 0.66, 0.72)
	sw2.light_energy = 0.7
	sw2.omni_range = 5.5
	add_child(sw2)
	_zawal = Node3D.new()
	_zawal.visible = false
	add_child(_zawal)
	for i in 9:
		var r := Vector3(_los.randf_range(0.6, 1.3), _los.randf_range(0.5, 1.1), _los.randf_range(0.6, 1.2))
		Mat.blok(_zawal, r, pc + Vector3(_los.randf_range(-1.0, 1.0), 0.3 + (i / 3) * 0.7, _los.randf_range(0.2, 1.3)), Mat.skala(), false, Vector3(_los.randf(), _los.randf() * 3.0, _los.randf()))
	# biwak: palenisko i posłanie
	var pb := _srodek(P_BIWAK.x, P_BIWAK.y)
	for i in 6:
		var kat := i * TAU / 6.0
		Mat.blok(self, Vector3(0.22, 0.16, 0.18), pb + Vector3(cos(kat) * 0.38, 0.08, sin(kat) * 0.38), Mat.kamien_ciemny(), false, Vector3(0, -kat, 0))
	Mat.blok(self, Vector3(0.5, 0.07, 0.07), pb + Vector3(0, 0.06, 0), dr, false, Vector3(0, 0.6, 0))
	Mat.blok(self, Vector3(0.5, 0.07, 0.07), pb + Vector3(0, 0.10, 0), dr, false, Vector3(0, -0.7, 0))
	Mat.blok(self, Vector3(0.7, 0.06, 1.8), pb + Vector3(0.95, 0.03, 0.2), Mat.plotno(), false)
	_zbuduj_zyly()
	# stary piec górniczy i stół rusznikarski zostawiony przez poprzedni patrol
	var pp := _srodek(P_PIEC.x, P_PIEC.y) + _sciana_przy(P_PIEC) * 0.9
	Mat.blok(self, Vector3(1.0, 1.1, 1.0), pp + Vector3(0, 0.55, 0), Mat.kamien_ciemny())
	Mat.blok(self, Vector3(0.4, 0.3, 0.4), pp + Vector3(0, 0.5, 0) - _sciana_przy(P_PIEC) * 0.35, Mat.swiecacy(Color(0.9, 0.3, 0.05), 1.2), false)
	var pst := _srodek(P_STOL.x, P_STOL.y) + _sciana_przy(P_STOL) * 0.95
	Mat.blok(self, Vector3(1.3, 0.06, 0.7), pst + Vector3(0, 0.86, 0), dr, true, Vector3(0, atan2(_sciana_przy(P_STOL).x, _sciana_przy(P_STOL).z), 0))
	Mat.blok(self, Vector3(0.9, 0.84, 0.5), pst + Vector3(0, 0.42, 0), dr, false, Vector3(0, atan2(_sciana_przy(P_STOL).x, _sciana_przy(P_STOL).z), 0))
	Mat.blok(self, Vector3(0.3, 0.14, 0.2), pst + Vector3(0.2, 0.96, 0), Mat.kolor(Color("3b4a2c"), 0.8), false)


func _sciana_przy(c: Vector2i) -> Vector3:
	for k in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if _znak(c.x + k.x, c.y + k.y) == "#":
			return Vector3(k.x, 0, k.y)
	return Vector3.ZERO


func _zbuduj_zyly() -> void:
	for z in ZYLY:
		var c: Vector2i = z[0]
		var bok := _sciana_przy(c)
		var poz := _srodek(c.x, c.y) + bok * 1.38 + Vector3(0, 1.25, 0)
		var wezel := Node3D.new()
		add_child(wezel)
		var mat := Mat.kolor(Color(Ekwipunek.PRZEDMIOTY[z[1]]["kolor"]).lightened(0.12), 0.45, 0.35)
		for i in 7:
			var r := Vector3(_los.randf_range(0.14, 0.34), _los.randf_range(0.12, 0.3), _los.randf_range(0.14, 0.34))
			var wzdluz := Vector3(bok.z, 0, bok.x)
			Mat.blok(wezel, r, poz + wzdluz * _los.randf_range(-0.6, 0.6) + Vector3(0, _los.randf_range(-0.55, 0.55), 0), mat, false, Vector3(_los.randf(), _los.randf() * 3.0, _los.randf()))
		_zyly.append({"poz": poz, "id": z[1], "ile": 3, "wezel": wezel})


func _zyla_w_zasiegu() -> Dictionary:
	for z in _zyly:
		var d: Vector3 = (z["poz"] as Vector3) - gracz.global_position
		if int(z["ile"]) > 0 and Vector2(d.x, d.z).length() < 2.0:
			return z
	return {}


func _kuj(gra: Node, z: Dictionary) -> void:
	if Ekwipunek.ile_zasobu("kilof") <= 0:
		gra.hud.komunikat(tr("ZYLA_BRAK_KILOFA"))
		return
	gracz.zdrowie.zacznij_czynnosc("KUCIE", 7.0 * Ekwipunek.mod("kucie"), func():
		z["ile"] = int(z["ile"]) - 1
		var id: String = z["id"]
		if Ekwipunek.dodaj_zasob(id, 1) > 0:
			upusc(Ekwipunek.nowy(id, {"ile": 1}), gracz.global_position + Vector3.UP * 0.8)
		gra.hud.komunikat(tr("WYDOBYTO") + ": " + tr(Ekwipunek.PRZEDMIOTY[id]["nazwa"]))
		if int(z["ile"]) <= 0:
			(z["wezel"] as Node3D).visible = false
			gra.hud.komunikat(tr("ZYLA_PUSTA")),
		func():
			Dzwiek.w_swiecie("kilof", z["poz"], 0.0, 0.1, 20.0)
			halas(gracz.global_position, 20.0))


## Stan lochu do zapisu przy biwaku.
func stan_do_zapisu() -> Dictionary:
	var zywi := []
	for w in _wrogowie_startowi:
		zywi.append(is_instance_valid(w) and w.zyje)
	var skrz := []
	for s in _lista_skrzyn:
		skrz.append(s.pojemnik.do_danych())
	var z := gracz.zdrowie
	return {
		"wersja": 1, "przebudzenie": przebudzenie, "prog": prog, "chodnik": chodnik_zawalony,
		"zywi": zywi, "skrzynie": skrz, "zyly": _zyly.map(func(z): return int(z["ile"])),
		"zdrowie": {"hp": z.hp.duplicate(), "lekkie": z.krwawienie_lekkie, "ciezkie": z.krwawienie_ciezkie, "zlamania": z.zlamania.duplicate(), "bol": z.bol},
	}


func _wznow(d: Dictionary) -> void:
	przebudzenie = float(d["przebudzenie"])
	prog = int(d["prog"])
	chodnik_zawalony = bool(d["chodnik"])
	_zawal.visible = chodnik_zawalony
	var zywi: Array = d["zywi"]
	for i in mini(zywi.size(), _wrogowie_startowi.size()):
		if not zywi[i]:
			var w: Wrog = _wrogowie_startowi[i]
			wrogowie.erase(w)
			w.queue_free()
	var skrz: Array = d["skrzynie"]
	for i in mini(skrz.size(), _lista_skrzyn.size()):
		_lista_skrzyn[i].pojemnik = Pojemnik.z_danych(skrz[i])
	var zy: Array = d.get("zyly", [])
	for i in mini(zy.size(), _zyly.size()):
		_zyly[i]["ile"] = int(zy[i])
		(_zyly[i]["wezel"] as Node3D).visible = int(zy[i]) > 0
	var z := gracz.zdrowie
	for k in d["zdrowie"]["hp"]:
		z.hp[k] = float(d["zdrowie"]["hp"][k])
	z.krwawienie_lekkie = int(d["zdrowie"]["lekkie"])
	z.krwawienie_ciezkie = bool(d["zdrowie"]["ciezkie"])
	z.zlamania = d["zdrowie"]["zlamania"]
	z.bol = float(d["zdrowie"]["bol"])


func halas(pozycja: Vector3, promien: float) -> void:
	super(pozycja, promien)
	# głośne dźwięki budzą loch: wystrzał bez tłumika to około 1,4 punktu
	if promien >= 20.0:
		przebudzenie = minf(przebudzenie + promien * 0.025, 100.0)


func _process(dt: float) -> void:
	if gracz == null or not gracz.zdrowie.zyje:
		return
	przebudzenie = minf(przebudzenie + dt * 100.0 / 2400.0, 100.0)
	while prog < PROGI.size() and przebudzenie >= float(PROGI[prog][0]):
		var p: Array = PROGI[prog]
		prog += 1
		komunikat_swiata.emit(tr(p[1]))
		Dzwiek.przy_uchu("dudnienie", -2.0, 0.05)
		if prog >= 2 and not chodnik_zawalony:
			chodnik_zawalony = true
			_zawal.visible = true
		for typ in p[2]:
			_wypusc(typ)
	if prog >= PROGI.size():
		_t_fala += dt
		if _t_fala >= 45.0:
			_t_fala = 0.0
			_wypusc("ghul")


## Wypuszcza wroga daleko od gracza i wysyła go w jego stronę.
func _wypusc(typ: String) -> void:
	if bez_wrogow:
		return
	var wolne := []
	for cz in MAPA.size():
		for cx in MAPA[0].length():
			if MAPA[cz][cx] != "#" and _srodek(cx, cz).distance_to(gracz.global_position) > 18.0:
				wolne.append(Vector2i(cx, cz))
	if wolne.is_empty():
		return
	var c: Vector2i = wolne[_los.randi_range(0, wolne.size() - 1)]
	_wrog(typ, _srodek(c.x, c.y), _los.randf() * TAU)
	var w: Wrog = wrogowie[-1]
	w.uslyszal.call_deferred(gracz.global_position, 999.0)


func _otoczenie() -> void:
	var srod := Environment.new()
	srod.background_mode = Environment.BG_COLOR
	srod.background_color = Color(0, 0, 0)
	srod.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	srod.ambient_light_color = Color(0.30, 0.34, 0.42)
	srod.ambient_light_energy = 0.045
	srod.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	srod.fog_enabled = true
	srod.fog_light_color = Color(0.0, 0.0, 0.0)
	srod.fog_density = 0.035
	srod.adjustment_enabled = true
	srod.adjustment_saturation = 0.85
	srod.adjustment_contrast = 1.1
	var we := WorldEnvironment.new()
	we.environment = srod
	add_child(we)


func _srodek(cx: int, cz: int) -> Vector3:
	return Vector3(cx * POLE + POLE * 0.5, 0.0, cz * POLE + POLE * 0.5)


func _poziom() -> void:
	var wys := MAPA.size()
	var szer: int = MAPA[0].length()
	var skala := Mat.skala()
	var los := RandomNumberGenerator.new()
	los.seed = 96
	_siatka = AStarGrid2D.new()
	_siatka.region = Rect2i(0, 0, szer, wys)
	_siatka.cell_size = Vector2(POLE, POLE)
	_siatka.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_siatka.update()
	# spąg i strop
	Mat.blok(self, Vector3(szer * POLE, 1.0, wys * POLE), Vector3(szer * POLE * 0.5, -0.5, wys * POLE * 0.5), Mat.ziemia())
	Mat.blok(self, Vector3(szer * POLE, 1.0, wys * POLE), Vector3(szer * POLE * 0.5, WYS + 0.5, wys * POLE * 0.5), skala)
	for cz in wys:
		for cx in szer:
			var znak: String = MAPA[cz][cx]
			var p := _srodek(cx, cz)
			if znak == "#":
				_siatka.set_point_solid(Vector2i(cx, cz), true)
				if _sasiad_wolny(cx, cz):
					Mat.blok(self, Vector3(POLE, WYS, POLE), p + Vector3(0, WYS * 0.5, 0), skala)
				continue
			# nierówności: odłamy skały przy ścianach i obniżenia stropu
			for kier in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if _znak(cx + kier.x, cz + kier.y) == "#" and los.randf() < 0.75:
					var bok: Vector3 = Vector3(kier.x, 0, kier.y)
					var wzdluz: Vector3 = Vector3(kier.y, 0, kier.x)
					var r := Vector3(los.randf_range(0.5, 1.3), los.randf_range(0.5, 1.9), los.randf_range(0.5, 1.3))
					var poz := p + bok * (POLE * 0.5 - r.x * 0.2) + wzdluz * los.randf_range(-1.0, 1.0)
					poz.y = r.y * 0.5 if los.randf() < 0.6 else WYS - r.y * 0.5
					Mat.blok(self, r, poz, skala, true, Vector3(los.randf_range(-0.3, 0.3), los.randf_range(0, 3.1), los.randf_range(-0.3, 0.3)))
			if los.randf() < 0.4:
				Mat.blok(self, Vector3(los.randf_range(1.2, 2.6), los.randf_range(0.2, 0.55), los.randf_range(1.2, 2.6)), p + Vector3(0, WYS - 0.1, 0), skala, false, Vector3(0, los.randf() * 3.0, 0))
			# obudowa drewniana w chodnikach
			var pion := _znak(cx, cz - 1) != "#" or _znak(cx, cz + 1) != "#"
			var poziom := _znak(cx - 1, cz) != "#" or _znak(cx + 1, cz) != "#"
			if pion != poziom and (cx + cz) % 2 == 0:
				_obudowa(p, poziom)
			match znak:
				"S":
					_start = p
					_drabina(p)
				"T":
					_pochodnia(p, los)
				"g", "k", "r":
					if not bez_wrogow:
						_wrog({"g": "ghul", "k": "knecht", "r": "rycerz"}[znak], p, los.randf() * TAU)
	_skrzynie(los)


func _skrzynie(los: RandomNumberGenerator) -> void:
	for c in SKRZYNIE:
		var p := _srodek(c.x, c.y)
		var bok := Vector3.ZERO
		for k in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if _znak(c.x + k.x, c.y + k.y) == "#":
				bok = Vector3(k.x, 0, k.y)
				break
		var s := Skrzynia.new()
		s.position = p + bok * 0.95
		s.rotation.y = atan2(-bok.x, -bok.z) + PI
		add_child(s)
		s.przygotuj(los)
		_lista_skrzyn.append(s)


func _znak(cx: int, cz: int) -> String:
	if cz < 0 or cz >= MAPA.size() or cx < 0 or cx >= MAPA[0].length():
		return "#"
	return MAPA[cz][cx]


func _sasiad_wolny(cx: int, cz: int) -> bool:
	for dz in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if _znak(cx + dx, cz + dz) != "#":
				return true
	return false


func _obudowa(p: Vector3, wzdluz_x: bool) -> void:
	var dr := Mat.drewno()
	var bok := Vector3(0, 0, 1) if wzdluz_x else Vector3(1, 0, 0)
	for s in [-1.0, 1.0]:
		Mat.blok(self, Vector3(0.20, WYS - 0.25, 0.20), p + bok * s * 1.28 + Vector3(0, (WYS - 0.25) * 0.5, 0), dr)
	var belka := Vector3(0.22, 0.24, 2.9) if wzdluz_x else Vector3(2.9, 0.24, 0.22)
	Mat.blok(self, belka, p + Vector3(0, WYS - 0.24, 0), dr, false)


func _drabina(p: Vector3) -> void:
	var dr := Mat.drewno()
	for s in [-0.28, 0.28]:
		Mat.blok(self, Vector3(0.08, WYS, 0.08), p + Vector3(-1.2, WYS * 0.5, s), dr, false)
	for i in 9:
		Mat.blok(self, Vector3(0.05, 0.05, 0.62), p + Vector3(-1.2, 0.3 + i * 0.33, 0), dr, false)
	var sw := OmniLight3D.new()
	sw.position = p + Vector3(-0.9, WYS - 0.3, 0)
	sw.light_color = Color(0.62, 0.68, 0.78)
	sw.light_energy = 0.7
	sw.omni_range = 5.0
	add_child(sw)


func _pochodnia(p: Vector3, _los: RandomNumberGenerator) -> void:
	var kier := Vector3.ZERO
	for k in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var c: Vector2i = Vector2i(int(p.x / POLE), int(p.z / POLE)) + k
		if _znak(c.x, c.y) == "#":
			kier = Vector3(k.x, 0, k.y)
			break
	var poz := p + kier * (POLE * 0.5 - 0.22) + Vector3(0, 1.75, 0)
	Mat.blok(self, Vector3(0.06, 0.5, 0.06), poz + Vector3(0, -0.2, 0), Mat.drewno(), false, Vector3(kier.z * 0.35, 0, -kier.x * 0.35))
	Mat.blok(self, Vector3(0.11, 0.13, 0.11), poz + Vector3(0, 0.1, 0) - kier * 0.07, Mat.swiecacy(Color(1.0, 0.5, 0.14), 2.6), false)
	var ogien := OmniLight3D.new()
	ogien.position = poz + Vector3(0, 0.2, 0) - kier * 0.25
	ogien.light_color = Color(1.0, 0.55, 0.22)
	ogien.light_energy = 1.3
	ogien.omni_range = 8.5
	ogien.shadow_enabled = true
	ogien.set_script(load("res://skrypty/strzelnica/ogien.gd"))
	add_child(ogien)


func _wrog(typ: String, p: Vector3, obrot: float) -> void:
	var w := Wrog.new()
	add_child(w)
	w.position = p + Vector3(0, 0.05, 0)
	w.rotation.y = obrot
	w.przygotuj(typ, self)
	wrogowie.append(w)


func dodaj_wroga(typ: String, p: Vector3, obrot: float) -> Wrog:
	_wrog(typ, p, obrot)
	return wrogowie[-1]


func sciezka(od: Vector3, do: Vector3) -> PackedVector3Array:
	var a := Vector2i(int(od.x / POLE), int(od.z / POLE))
	var b := Vector2i(int(do.x / POLE), int(do.z / POLE))
	var wynik := PackedVector3Array()
	if not _siatka.is_in_boundsv(a) or not _siatka.is_in_boundsv(b) or _siatka.is_point_solid(b):
		wynik.append(do)
		return wynik
	var pola := _siatka.get_id_path(a, b)
	for i in range(1, pola.size() - 1):
		wynik.append(_srodek(pola[i].x, pola[i].y))
	wynik.append(Vector3(do.x, 0.0, do.z))
	return wynik


func _przy(pole: Vector2i, zasieg := 1.9) -> bool:
	return gracz.global_position.distance_to(_srodek(pole.x, pole.y)) < zasieg


func przy_wyjsciu() -> bool:
	return gracz.global_position.distance_to(_start + Vector3(-0.8, 0, 0)) < 1.7


func podpowiedz() -> String:
	if przy_wyjsciu():
		return tr("WYJSCIE_PODPOWIEDZ")
	if _przy(P_SZYB):
		return tr("WYJSCIE_KRATA")
	if _przy(P_CHODNIK):
		return tr("WYJSCIE_ZAWALONE") if chodnik_zawalony else tr("WYJSCIE_CHODNIK")
	if _przy(P_BIWAK, 1.6):
		return tr("BIWAK_PODP")
	if not _zyla_w_zasiegu().is_empty():
		return tr("ZYLA_PODP")
	if _przy(P_PIEC):
		return tr("PIEC_PODP")
	if _przy(P_STOL):
		return tr("RUSZNIKARZ_PODP")
	return ""


func uzyj(gra: Node) -> bool:
	if przy_wyjsciu():
		gra.ewakuacja()
		return true
	if _przy(P_SZYB):
		if Ekwipunek.zuzyj_lek("klucz"):
			gra.ewakuacja()
		else:
			gra.hud.komunikat(tr("WYJSCIE_BRAK_KLUCZA"))
		return true
	if _przy(P_CHODNIK) and not chodnik_zawalony:
		gra.ewakuacja()
		return true
	if _przy(P_BIWAK, 1.6):
		gra.hud.otworz_biwak()
		return true
	var zyla := _zyla_w_zasiegu()
	if not zyla.is_empty():
		_kuj(gra, zyla)
		return true
	if _przy(P_PIEC):
		gra.hud.otworz_rzemioslo("piec", false)
		return true
	if _przy(P_STOL):
		gra.hud.otworz_rzemioslo("stol", false)
		return true
	return false


## Odpoczynek przy ogniu: wytrzymałość wraca, ale dym i światło budzą loch.
func odpocznij() -> void:
	gracz.wytrz_nogi = 1.0
	gracz.wytrz_rece = 1.0
	gracz.zdrowie.bol = maxf(gracz.zdrowie.bol - 0.4, 0.0)
	przebudzenie = minf(przebudzenie + 6.0, 100.0)
