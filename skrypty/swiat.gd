class_name Swiat
extends Node3D
## Wspólna część każdej lokacji: gracz, broń, ślady po kulach, łuski, krew, hałas.

signal komunikat_swiata(tekst: String)

const MAKS_SLADOW := 500
const MAKS_LUSEK := 40

var gracz: Gracz
var bronie: Array[Bron] = []
var aktywna := 0
var wrogowie: Array = []
var wyprawa := false            ## true w lochu: płynie głód i pragnienie

var _slady: Array[MeshInstance3D] = []
var _i_slad := 0
var _luski: Array[RigidBody3D] = []
var _siatka_sladu: QuadMesh
var _mat_sladow := {}
var _mat_luska: StandardMaterial3D
var _bryzgi: Array[CPUParticles3D] = []
var _i_bryzg := 0
var _skupiska: Array = []      ## łuski do zebrania: {poz, kal: {kaliber: liczba}}


func przygotuj_swiat() -> void:
	add_to_group("swiat")
	_siatka_sladu = QuadMesh.new()
	_siatka_sladu.size = Vector2(0.035, 0.035)
	_mat_sladow = {
		"dziura": Mat.swiecacy(Color(0.02, 0.02, 0.02), 1.0),
		"wgniot": Mat.kolor(Color("b9bcc0"), 0.35, 0.9),
		"ziemia": Mat.swiecacy(Color(0.05, 0.045, 0.04), 1.0),
		"krew": Mat.kolor(Color("3d0806"), 0.35, 0.0),
	}
	_mat_luska = Mat.kolor(Color("a8842e"), 0.4, 0.85)
	var pociski := Node3D.new()
	pociski.set_script(load("res://skrypty/bron/pociski.gd"))
	add_child(pociski)
	for i in 10:
		var c := CPUParticles3D.new()
		c.emitting = false
		c.one_shot = true
		c.explosiveness = 0.95
		c.amount = 18
		c.lifetime = 0.7
		c.direction = Vector3(0, 0.3, 1)
		c.spread = 28.0
		c.initial_velocity_min = 1.5
		c.initial_velocity_max = 5.0
		c.gravity = Vector3(0, -9.8, 0)
		c.scale_amount_min = 0.5
		c.scale_amount_max = 1.2
		var bm := BoxMesh.new()
		bm.size = Vector3(0.022, 0.022, 0.022)
		c.mesh = bm
		c.material_override = _mat_sladow["krew"]
		c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(c)
		_bryzgi.append(c)


func stworz_gracza(pozycja: Vector3, obrot_y: float) -> void:
	gracz = Gracz.new()
	gracz.position = pozycja
	gracz.rotation.y = obrot_y
	add_child(gracz)
	for id in [Ekwipunek.bron_glowna, Ekwipunek.bron_boczna]:
		var b := Bron.new()
		gracz.kamera.add_child(b)
		b.przygotuj(id, gracz)
		bronie.append(b)
	bronie[0].wyjmij()
	gracz.krok.connect(func(g: float):
		Dzwiek.przy_uchu("krok", linear_to_db(clampf(g, 0.05, 1.0)) - 6.0, 0.12)
		halas(gracz.global_position, g * 7.0))


func zmien_bron(i: int) -> void:
	if i == aktywna or i >= bronie.size():
		return
	bronie[aktywna].schowaj()
	aktywna = i
	bronie[i].wyjmij()


func bron() -> Bron:
	return bronie[aktywna]


## Ślad przyklejony do powierzchni: dziura, wgniot w stali, ziemia albo krew.
func slad(pozycja: Vector3, normalna: Vector3, rodzaj: String, skala := 1.0) -> void:
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
	s.material_override = _mat_sladow.get(rodzaj, _mat_sladow["ziemia"])
	var n := normalna.normalized()
	s.global_position = pozycja + n * (0.004 + randf() * 0.002)
	var gora := Vector3.UP if absf(n.y) < 0.95 else Vector3.RIGHT
	s.look_at(pozycja - n, gora)
	s.rotate_object_local(Vector3.FORWARD, randf() * TAU)
	var sk := randf_range(0.8, 1.3) * (1.6 if rodzaj == "ziemia" else 1.0) * skala
	s.scale = Vector3(sk, sk * randf_range(0.7, 1.3), 1.0)


## Bryzg krwi: cząstki w kierunku lotu pocisku i plamy na tym, co jest za celem.
func krew(pozycja: Vector3, kierunek: Vector3, ilosc := 1.0) -> void:
	var c := _bryzgi[_i_bryzg]
	_i_bryzg = (_i_bryzg + 1) % _bryzgi.size()
	c.global_position = pozycja
	var k := kierunek.normalized()
	c.look_at(pozycja - k, Vector3.UP if absf(k.y) < 0.95 else Vector3.RIGHT)
	c.amount = clampi(int(14 * ilosc), 6, 40)
	c.restart()
	var przestrzen := get_world_3d().direct_space_state
	for i in clampi(int(2 * ilosc) + 1, 1, 6):
		var rozrzut := Vector3(randf_range(-0.35, 0.35), randf_range(-0.6, 0.1), randf_range(-0.35, 0.35))
		var q := PhysicsRayQueryParameters3D.create(pozycja, pozycja + (k + rozrzut).normalized() * 3.5)
		q.collision_mask = 1
		var hit := przestrzen.intersect_ray(q)
		if not hit.is_empty():
			slad(hit["position"], hit["normal"], "krew", randf_range(2.5, 6.0) * sqrt(ilosc))


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


## Hałas w świecie: słyszą go wrogowie w promieniu (metry).
func halas(pozycja: Vector3, promien: float) -> void:
	for w in wrogowie:
		if is_instance_valid(w):
			w.uslyszal(pozycja, promien)


## Droga po podłodze od punktu do punktu. Lokacje z siatką nadpisują.
func sciezka(od: Vector3, do: Vector3) -> PackedVector3Array:
	return PackedVector3Array([do])


## Kładzie przedmiot w świecie (rzucony magazynek, zrzucony plecak).
func upusc(p: Dictionary, pozycja: Vector3, predkosc := Vector3.ZERO) -> void:
	var rb := LezacyPrzedmiot.new()
	add_child(rb)
	rb.przygotuj(p)
	rb.global_position = pozycja
	rb.linear_velocity = predkosc
	rb.angular_velocity = Vector3(randf_range(-3, 3), randf_range(-3, 3), randf_range(-3, 3))


func zrzuc_plecak() -> void:
	if Ekwipunek.plecak_p.is_empty():
		return
	var p := Ekwipunek.zdejmij_plecak()
	upusc(p, gracz.global_position + Vector3.UP * 1.1 + gracz.global_transform.basis.z * 0.35, gracz.velocity * 0.5)
	Dzwiek.przy_uchu("bron_wyjmij", -4.0)


## Najbliższa skrzynia albo zwłoki w zasięgu ręki: obiekt z polem `pojemnik`.
func pojemnik_w_zasiegu() -> Node3D:
	var najlepszy: Node3D = null
	var odl := 2.1
	for m in get_tree().get_nodes_in_group("pojemniki"):
		var dd: float = (m as Node3D).global_position.distance_to(gracz.global_position)
		if dd < odl:
			odl = dd
			najlepszy = m
	return najlepszy


func magazynek_w_zasiegu() -> Node3D:
	var najlepszy: Node3D = null
	var odl := 2.0
	for m in get_tree().get_nodes_in_group("do_podniesienia"):
		var dd: float = (m as Node3D).global_position.distance_to(gracz.kamera.global_position)
		if dd < odl:
			odl = dd
			najlepszy = m
	return najlepszy


## Łuska spadła na ziemię: zapamiętaj, żeby dało się ją później zebrać.
func dodaj_luske(kaliber: String, pozycja: Vector3) -> void:
	for sk in _skupiska:
		if (sk["poz"] as Vector3).distance_to(pozycja) < 3.0:
			sk["kal"][kaliber] = int(sk["kal"].get(kaliber, 0)) + 1
			return
	_skupiska.append({"poz": pozycja, "kal": {kaliber: 1}})


func _skupisko_w_zasiegu() -> Dictionary:
	for sk in _skupiska:
		var n := 0
		for k in sk["kal"]:
			n += int(sk["kal"][k])
		if n >= 3 and (sk["poz"] as Vector3).distance_to(gracz.global_position) < 2.6:
			return sk
	return {}


func _martwy_do_oprawienia() -> Wrog:
	for w in wrogowie:
		if is_instance_valid(w) and not w.zyje and not w.oprawiony and not (w.d["oprawa"] as Array).is_empty() and w.global_position.distance_to(gracz.global_position) < 2.1:
			return w
	return null


## Podpowiedzi wspólne dla każdej lokacji, o niższym priorytecie niż własne.
func podpowiedz_wspolna() -> String:
	if _martwy_do_oprawienia() != null:
		return tr("E_PRZESZUKAJ") + "   " + tr("OPRAW_PODP")
	if not _skupisko_w_zasiegu().is_empty():
		return tr("LUSKI_PODP")
	return ""


func uzyj_wspolne(gra: Node) -> bool:
	var sk := _skupisko_w_zasiegu()
	if sk.is_empty():
		return false
	gracz.zdrowie.zacznij_czynnosc("ZBIERANIE", 3.0, func():
		for k in sk["kal"]:
			var n := int(floor(int(sk["kal"][k]) * 0.6))
			if n > 0:
				Ekwipunek.dodaj_zasob(Amunicja.luski(k), n)
		_skupiska.erase(sk)
		gra.hud.komunikat(tr("ZEBRANO_LUSKI")))
	return true


## Oprawianie zwłok nożem: części trafiają do łupu na zwłokach.
func opraw(gra: Node) -> void:
	var w := _martwy_do_oprawienia()
	if w == null:
		return
	gracz.zdrowie.zacznij_czynnosc("OPRAWIANIE", 4.0, func():
		if not is_instance_valid(w):
			return
		w.oprawiony = true
		for cz in w.d["oprawa"]:
			if randf() <= float(cz[2]):
				var p := Ekwipunek.nowy(cz[0], {"ile": int(cz[1])})
				w.pojemnik.wloz_gdziekolwiek(p)
		krew(w.global_position + Vector3.UP * 0.3, Vector3.DOWN, 1.5)
		Dzwiek.w_swiecie("cialo", w.global_position, -3.0, 0.2, 6.0)
		gra.hud.komunikat(tr("OPRAWIONO")),
		func(): Dzwiek.w_swiecie("cialo", gracz.global_position, -8.0, 0.3, 5.0))


func wyczysc() -> void:
	for s in _slady:
		s.visible = false


func odswiez_napisy() -> void:
	pass


func podpowiedz() -> String:
	return ""


func uzyj(_gra: Node) -> bool:
	return false
