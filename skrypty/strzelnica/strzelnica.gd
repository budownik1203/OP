class_name Strzelnica
extends Node3D
## Build 1: strzelnica za murami klasztoru. Tarcze z płytami klas 0–5
## na 10, 25, 50 i 100 m, dwa manekiny rycerza, stół amunicyjny.

const DYSTANSE := [10.0, 25.0, 50.0, 100.0]
const MAKS_SLADOW := 400
const MAKS_LUSEK := 40

var gracz: Gracz
var bronie: Array[Bron] = []
var aktywna := 0
var stol_pozycja := Vector3(3.2, 0.0, 2.2)

var _slady: Array[MeshInstance3D] = []
var _i_slad := 0
var _luski: Array[RigidBody3D] = []
var _siatka_sladu: QuadMesh
var _mat_dziura: StandardMaterial3D
var _mat_wgniot: StandardMaterial3D
var _mat_ziemia: StandardMaterial3D
var _mat_luska: StandardMaterial3D


func _ready() -> void:
	add_to_group("swiat")
	_materialy_sladow()
	_niebo_i_swiatlo()
	_teren()
	_stanowisko()
	_tarcze()
	_manekiny()
	_tlo()
	var pociski := Node3D.new()
	pociski.set_script(load("res://skrypty/bron/pociski.gd"))
	add_child(pociski)
	_gracz()


func _materialy_sladow() -> void:
	_siatka_sladu = QuadMesh.new()
	_siatka_sladu.size = Vector2(0.035, 0.035)
	_mat_dziura = Mat.swiecacy(Color(0.02, 0.02, 0.02), 1.0)
	_mat_wgniot = Mat.kolor(Color("b9bcc0"), 0.35, 0.9)
	_mat_ziemia = Mat.swiecacy(Color(0.05, 0.045, 0.04), 1.0)
	_mat_luska = Mat.kolor(Color("a8842e"), 0.4, 0.85)


func _niebo_i_swiatlo() -> void:
	var srod := Environment.new()
	var niebo := Sky.new()
	var pm := ProceduralSkyMaterial.new()
	pm.sky_top_color = Color("1d2228")
	pm.sky_horizon_color = Color("6b6a5e")
	pm.ground_bottom_color = Color("15130f")
	pm.ground_horizon_color = Color("55534a")
	pm.sky_curve = 0.09
	pm.sun_angle_max = 8.0
	niebo.sky_material = pm
	srod.background_mode = Environment.BG_SKY
	srod.sky = niebo
	srod.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	srod.ambient_light_energy = 1.35
	srod.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	srod.fog_enabled = true
	srod.fog_light_color = Color("5d5e58")
	srod.fog_density = 0.006
	srod.fog_sky_affect = 0.35
	srod.adjustment_enabled = true
	srod.adjustment_saturation = 0.82
	srod.adjustment_contrast = 1.08
	var we := WorldEnvironment.new()
	we.environment = srod
	add_child(we)
	var slonce := DirectionalLight3D.new()
	slonce.rotation_degrees = Vector3(-27.0, -38.0, 0.0)
	slonce.light_color = Color("cfd3d8")
	slonce.light_energy = 0.85
	slonce.shadow_enabled = true
	slonce.directional_shadow_max_distance = 130.0
	add_child(slonce)


func _teren() -> void:
	Mat.blok(self, Vector3(40.0, 1.0, 180.0), Vector3(0.0, -0.5, -60.0), Mat.ziemia())
	# mury boczne: ruina, nierówna korona
	var los := RandomNumberGenerator.new()
	los.seed = 1203
	for strona in [-1.0, 1.0]:
		var z := 8.0
		while z > -116.0:
			var dl := los.randf_range(3.0, 5.5)
			var wys := los.randf_range(2.6, 4.6)
			if los.randf() < 0.12:
				wys = los.randf_range(1.0, 1.8)
			Mat.blok(self, Vector3(1.1, wys, dl), Vector3(strona * 13.0, wys * 0.5, z - dl * 0.5), Mat.kamien())
			if los.randf() < 0.4:
				Mat.blok(self, Vector3(1.5, wys * 0.8, 0.9), Vector3(strona * 12.4, wys * 0.4, z - dl * 0.5), Mat.kamien_ciemny())
			z -= dl
	# mur za plecami z bramą
	Mat.blok(self, Vector3(11.0, 4.2, 1.2), Vector3(-7.6, 2.1, 8.6), Mat.kamien())
	Mat.blok(self, Vector3(11.0, 4.2, 1.2), Vector3(7.6, 2.1, 8.6), Mat.kamien())
	Mat.blok(self, Vector3(4.4, 1.2, 1.2), Vector3(0.0, 3.6, 8.6), Mat.kamien_ciemny())
	Mat.blok(self, Vector3(4.2, 3.0, 0.2), Vector3(0.0, 1.5, 8.9), Mat.drewno())
	# kulochwyt: wał ziemny
	Mat.blok(self, Vector3(27.0, 7.0, 6.0), Vector3(0.0, 2.0, -112.0), Mat.ziemia(), true, Vector3(deg_to_rad(-28.0), 0.0, 0.0))
	Mat.blok(self, Vector3(27.0, 5.0, 4.0), Vector3(0.0, 2.5, -116.0), Mat.ziemia())
	# niskie wały za rzędami tarcz
	for d in DYSTANSE:
		if d < 100.0:
			Mat.blok(self, Vector3(13.0, 0.5, 0.8), Vector3(0.0, 0.25, -d - 1.6), Mat.ziemia())


func _stanowisko() -> void:
	var dr := Mat.drewno()
	# wiata za linią ognia: schronienie dla stołu amunicyjnego
	for x in [-4.6, 4.6]:
		for z in [0.9, 3.6]:
			Mat.blok(self, Vector3(0.16, 2.7, 0.16), Vector3(x, 1.35, z), dr)
	Mat.blok(self, Vector3(9.8, 0.10, 3.3), Vector3(0.0, 2.80, 2.25), dr, true, Vector3(deg_to_rad(6.0), 0.0, 0.0))
	Mat.blok(self, Vector3(9.4, 0.12, 0.14), Vector3(0.0, 2.62, 0.9), dr, false)
	Mat.blok(self, Vector3(9.4, 0.12, 0.14), Vector3(0.0, 2.50, 3.6), dr, false)
	# linia ognia: niska belka na ziemi
	Mat.blok(self, Vector3(9.0, 0.08, 0.18), Vector3(0.0, 0.04, -1.9), dr, false)
	# worki z piaskiem
	for i in 5:
		Mat.blok(self, Vector3(0.62, 0.20, 0.34), Vector3(-3.6 + 0.66 * (i % 3) + (0.33 if i >= 3 else 0.0), 0.10 + 0.2 * int(i / 3.0), -2.2), Mat.plotno())
	# stół amunicyjny
	Mat.blok(self, Vector3(1.6, 0.06, 0.8), stol_pozycja + Vector3(0.0, 0.88, 0.0), dr)
	for sx in [-0.7, 0.7]:
		for sz in [-0.32, 0.32]:
			Mat.blok(self, Vector3(0.08, 0.86, 0.08), stol_pozycja + Vector3(sx, 0.43, sz), dr, false)
	var zielony := Mat.kolor(Color("3b4a2c"), 0.8)
	Mat.blok(self, Vector3(0.42, 0.20, 0.26), stol_pozycja + Vector3(-0.45, 1.01, 0.05), zielony, false)
	Mat.blok(self, Vector3(0.42, 0.20, 0.26), stol_pozycja + Vector3(0.05, 1.01, -0.10), zielony, false, Vector3(0.0, 0.3, 0.0))
	Mat.blok(self, Vector3(0.30, 0.12, 0.20), stol_pozycja + Vector3(0.52, 0.97, 0.12), Mat.kolor(Color("5a4a2a"), 0.8), false)
	var napis := Label3D.new()
	napis.text = tr("STOL_AMUNICYJNY")
	napis.set_meta("klucz", "STOL_AMUNICYJNY")
	napis.add_to_group("napisy")
	napis.position = stol_pozycja + Vector3(0.0, 1.45, 0.0)
	_styl_napisu(napis, 0.004, Color("d8c9a0"))
	napis.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	add_child(napis)
	# kosze z ogniem
	for x in [-5.4, 5.4]:
		Mat.blok(self, Vector3(0.5, 0.7, 0.5), Vector3(x, 0.35, -2.6), Mat.kolor(Color("1d1b1a"), 0.7, 0.6))
		Mat.blok(self, Vector3(0.36, 0.12, 0.36), Vector3(x, 0.74, -2.6), Mat.swiecacy(Color(1.0, 0.42, 0.1), 2.5), false)
		var ogien := OmniLight3D.new()
		ogien.position = Vector3(x, 1.1, -2.6)
		ogien.light_color = Color(1.0, 0.55, 0.22)
		ogien.light_energy = 1.3
		ogien.omni_range = 7.0
		ogien.shadow_enabled = true
		ogien.set_script(load("res://skrypty/strzelnica/ogien.gd"))
		add_child(ogien)


func _styl_napisu(n: Label3D, piksel: float, kolor: Color) -> void:
	n.pixel_size = piksel
	n.font_size = 48
	n.outline_size = 12
	n.modulate = kolor
	n.outline_modulate = Color(0.03, 0.03, 0.03, 0.9)
	n.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	n.shaded = false
	n.double_sided = true


func _tarcze() -> void:
	var dr := Mat.drewno()
	for d in DYSTANSE:
		var skala := 1.0
		if d >= 50.0:
			skala = 1.35
		if d >= 100.0:
			skala = 2.0
		var szer := 0.5 * skala
		var wys := 0.7 * skala
		var odstep := maxf(1.9, szer + 1.1)
		for klasa in 6:
			var x := (klasa - 2.5) * odstep
			var srodek := Vector3(x, 0.55 + wys * 0.5 + (0.25 if d >= 50.0 else 0.0), -d)
			# stojak
			Mat.blok(self, Vector3(0.08, srodek.y + wys * 0.5 + 0.1, 0.08), Vector3(x - szer * 0.5 - 0.07, (srodek.y + wys * 0.5 + 0.1) * 0.5, -d), dr, false)
			Mat.blok(self, Vector3(0.08, srodek.y + wys * 0.5 + 0.1, 0.08), Vector3(x + szer * 0.5 + 0.07, (srodek.y + wys * 0.5 + 0.1) * 0.5, -d), dr, false)
			Mat.blok(self, Vector3(szer + 0.3, 0.08, 0.08), Vector3(x, srodek.y + wys * 0.5 + 0.09, -d), dr, false)
			var p := Plyta.new()
			p.klasa = klasa
			p.rozmiar = Vector3(szer, wys, 0.012 + 0.006 * klasa)
			p.position = srodek
			p.dzwiek = "stal" if klasa > 0 else "uderzenie"
			add_child(p)
			p.zbuduj(Mat.cialo() if klasa == 0 else Mat.stal(klasa))
			var e := Label3D.new()
			e.position = srodek + Vector3(0.0, wys * 0.5 + 0.55 * skala * (1.0 + d / 80.0), 0.0)
			_styl_napisu(e, 0.0042 * skala * (1.0 + d / 50.0), Color.WHITE)
			add_child(e)
			p.etykieta = e
			var nr := Label3D.new()
			nr.text = "%s %d" % [tr("KLASA"), klasa]
			nr.set_meta("klucz_klasa", klasa)
			nr.add_to_group("napisy")
			nr.position = Vector3(x, srodek.y - wys * 0.5 - 0.16 * skala, -d + 0.02)
			_styl_napisu(nr, 0.0034 * skala * (1.0 + d / 60.0), Color("d8c9a0"))
			nr.billboard = BaseMaterial3D.BILLBOARD_DISABLED
			add_child(nr)
		var znak := Label3D.new()
		znak.text = "%d m" % int(d)
		znak.position = Vector3(-8.2 - d * 0.02, 1.6 + d * 0.012, -d)
		_styl_napisu(znak, 0.006 * (1.0 + d / 40.0), Color("d8c9a0"))
		add_child(znak)


func _manekiny() -> void:
	for i in 2:
		var m := Node3D.new()
		m.set_script(load("res://skrypty/strzelnica/manekin.gd"))
		m.position = Vector3(-9.0 + i * 18.0, 0.0, -15.0)
		m.rotation.y = 0.0 if i == 0 else PI
		add_child(m)
		m.call("zbuduj", self)


func _tlo() -> void:
	# sylweta klasztoru za wałem: nawa z dachem, wieża z hełmem, przypory, mur
	var c := Mat.kolor(Color("17181c"), 1.0)
	var c2 := Mat.kolor(Color("101114"), 1.0)
	Mat.blok(self, Vector3(22.0, 20.0, 46.0), Vector3(-14.0, 10.0, -172.0), c, false, Vector3(0.0, deg_to_rad(74.0), 0.0))
	Mat.daszek(self, 23.0, 13.0, 47.0, Vector3(-14.0, 20.0, -172.0), c2, deg_to_rad(74.0))
	for i in 5:
		Mat.blok(self, Vector3(2.4, 15.0, 4.0), Vector3(-33.0 + i * 9.4, 7.5, -158.5 - i * 2.7), c2, false, Vector3(0.0, deg_to_rad(74.0), 0.0))
	Mat.blok(self, Vector3(10.0, 38.0, 10.0), Vector3(18.0, 19.0, -166.0), c, false)
	Mat.blok(self, Vector3(11.4, 1.6, 11.4), Vector3(18.0, 38.0, -166.0), c2, false)
	Mat.daszek(self, 10.0, 19.0, 10.0, Vector3(18.0, 38.8, -166.0), c2)
	Mat.daszek(self, 10.0, 19.0, 10.0, Vector3(18.0, 38.8, -166.0), c2, PI * 0.5)
	Mat.blok(self, Vector3(1.4, 5.0, 2.0), Vector3(18.0, 30.0, -160.8), Mat.kolor(Color("0a0a0c"), 1.0), false)
	Mat.blok(self, Vector3(7.0, 14.0, 7.0), Vector3(-41.0, 7.0, -150.0), c, false)
	Mat.daszek(self, 7.6, 6.0, 7.6, Vector3(-41.0, 14.0, -150.0), c2)
	Mat.blok(self, Vector3(90.0, 7.0, 2.5), Vector3(0.0, 3.5, -138.0), c, false)
	for i in 9:
		Mat.blok(self, Vector3(3.0, 1.6, 2.6), Vector3(-40.0 + i * 10.0, 7.6, -138.0), c, false)


func _gracz() -> void:
	gracz = Gracz.new()
	gracz.position = Vector3(0.0, 0.05, 0.4)
	add_child(gracz)
	for id in ["kwarc", "jaspis"]:
		var b := Bron.new()
		gracz.kamera.add_child(b)
		b.przygotuj(id, gracz)
		bronie.append(b)
	bronie[0].wyjmij()
	gracz.krok.connect(func(g: float): Dzwiek.przy_uchu("krok", linear_to_db(clampf(g, 0.05, 1.0)) - 6.0, 0.12))


func zmien_bron(i: int) -> void:
	if i == aktywna or i >= bronie.size():
		return
	bronie[aktywna].schowaj()
	aktywna = i
	bronie[i].wyjmij()


func bron() -> Bron:
	return bronie[aktywna]


## Ślad po kuli: mały znak przyklejony do powierzchni.
func slad(pozycja: Vector3, normalna: Vector3, rodzaj: String) -> void:
	var s: MeshInstance3D
	if _slady.size() < MAKS_SLADOW:
		s = MeshInstance3D.new()
		s.mesh = _siatka_sladu
		s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(s)
		_slady.append(s)
	else:
		s = _slady[_i_slad]
		_i_slad = (_i_slad + 1) % MAKS_SLADOW
	s.visible = true
	match rodzaj:
		"dziura":
			s.material_override = _mat_dziura
		"wgniot":
			s.material_override = _mat_wgniot
		_:
			s.material_override = _mat_ziemia
	var n := normalna.normalized()
	s.global_position = pozycja + n * 0.004
	var gora := Vector3.UP if absf(n.y) < 0.95 else Vector3.RIGHT
	s.look_at(pozycja - n, gora)
	s.rotate_object_local(Vector3.FORWARD, randf() * TAU)
	var sk := randf_range(0.8, 1.3) * (1.6 if rodzaj == "ziemia" else 1.0)
	s.scale = Vector3(sk, sk, 1.0)


func luska(pozycja: Vector3, predkosc: Vector3, rozmiar: Vector3) -> void:
	var rb: RigidBody3D
	if _luski.size() < MAKS_LUSEK:
		rb = RigidBody3D.new()
		rb.mass = 0.012
		rb.collision_layer = 4
		rb.collision_mask = 1
		var ks := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(0.01, 0.01, 0.04)
		ks.shape = bs
		rb.add_child(ks)
		var si := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3.ONE
		si.mesh = bm
		si.material_override = _mat_luska
		si.name = "s"
		rb.add_child(si)
		add_child(rb)
		_luski.append(rb)
	else:
		rb = _luski.pop_front()
		_luski.append(rb)
	(rb.get_node("s") as MeshInstance3D).scale = rozmiar
	rb.global_position = pozycja
	rb.linear_velocity = predkosc
	rb.angular_velocity = Vector3(randf_range(-20, 20), randf_range(-20, 20), randf_range(-20, 20))
	rb.sleeping = false


func wyczysc() -> void:
	for s in _slady:
		s.visible = false
	for p in get_tree().get_nodes_in_group("plyty"):
		p.wyczysc()


func odswiez_napisy() -> void:
	for n in get_tree().get_nodes_in_group("napisy"):
		if n.has_meta("klucz"):
			n.text = tr(n.get_meta("klucz"))
		elif n.has_meta("klucz_klasa"):
			n.text = "%s %d" % [tr("KLASA"), n.get_meta("klucz_klasa")]


## Najbliższy upuszczony magazynek w zasięgu ręki albo null.
func magazynek_w_zasiegu() -> Node3D:
	var najlepszy: Node3D = null
	var odl := 2.0
	for m in get_tree().get_nodes_in_group("do_podniesienia"):
		var dd: float = (m as Node3D).global_position.distance_to(gracz.kamera.global_position)
		if dd < odl:
			odl = dd
			najlepszy = m
	return najlepszy


func przy_stole() -> bool:
	return gracz.global_position.distance_to(stol_pozycja) < 2.0
