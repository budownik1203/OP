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

var _siatka: AStarGrid2D
var _start := Vector3.ZERO
var bez_wrogow := false


func _ready() -> void:
	przygotuj_swiat()
	_otoczenie()
	_poziom()
	stworz_gracza(_start + Vector3(0, 0.05, 0), -PI * 0.5)
	for b in bronie:
		b.wlacz_latarke(true)
	gracz.latarka = true


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


func przy_wyjsciu() -> bool:
	return gracz.global_position.distance_to(_start + Vector3(-0.8, 0, 0)) < 1.7


func podpowiedz() -> String:
	return tr("WYJSCIE_PODPOWIEDZ") if przy_wyjsciu() else ""


func uzyj(gra: Node) -> bool:
	if przy_wyjsciu():
		gra.zmien_swiat("strzelnica")
		return true
	return false
