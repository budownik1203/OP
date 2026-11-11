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


func przygotuj(typ_wroga: String, swiat_: Swiat) -> void:
	typ = typ_wroga
	d = TYPY[typ]
	swiat = swiat_
	collision_layer = 8
	collision_mask = 1 | 8
	_kapsula = CollisionShape3D.new()
	var ks := CapsuleShape3D.new()
	ks.radius = 0.33
	ks.height = 1.8
	_kapsula.shape = ks
	_kapsula.position.y = 0.9
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
	_zbuduj_strefy()
	if _w.has("bron"):
		(_w["bron"] as Node3D).rotation.x = -1.35
	floor_snap_length = 0.3


func _zbuduj_strefy() -> void:
	var tabela: Dictionary = d["strefy"]
	for nazwa in tabela:
		if not _w.has(nazwa):
			continue
		var wezel: MeshInstance3D = _w[nazwa]
		var aabb := wezel.get_aabb()
		var rozmiar := aabb.size
		if nazwa == "tors":
			rozmiar *= d["skala_tors"]
		var s := _nowa_strefa(wezel, nazwa, tabela[nazwa][0], tabela[nazwa][1], tabela[nazwa][2], tabela[nazwa][3])
		s.ustaw(rozmiar * 0.96, aabb.get_center())
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
	if cel != null:
		cel.hp -= obr
		_po_trafieniu(cel, obr, kier, info)
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
	if zyje and obr >= float(d["oglusza_od"]) and stan != "ogluszony":
		_ustaw_stan("ogluszony")
		_t_stan = 0.4


## Strefy zniszczonego segmentu i tego, co z niego wyrasta, przestają przyjmować trafienia.
func _wylacz_segment(segment: String) -> void:
	var pary := {"ramie_l": "przedramie_l", "ramie_p": "przedramie_p", "udo_l": "golen_l", "udo_p": "golen_p"}
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
	# upadek: na plecy, gdy pocisk leciał od przodu, na twarz w przeciwnym razie
	var przod := -global_transform.basis.z
	var do_tylu := kier.dot(przod) < 0.0
	_pochyl = (PI * 0.5 - 0.06) * (1.0 if do_tylu else -1.0)
	_model_y = 0.13 if do_tylu else 0.16
	for n in ["ramie_l", "ramie_p", "udo_l", "udo_p", "przedramie_l", "przedramie_p", "golen_l", "golen_p", "glowa", "tors"]:
		var noga: bool = n.begins_with("udo") or n.begins_with("golen")
		_poza[n] = Vector3(randf_range(-0.25, 0.25) if noga else randf_range(-0.5, 0.5), 0.0, randf_range(-0.12, 0.12) if noga else randf_range(-0.35, 0.35))
	_szybkosc_pozy = 5.0
	Dzwiek.w_swiecie("cialo_upadek", global_position, -2.0, 0.1, 12.0)
	if d["krwawi"]:
		swiat.krew(global_position + Vector3.UP * 0.4, Vector3.DOWN, 2.0)


# ====================================================================== zmysły

func uslyszal(pozycja: Vector3, promien: float) -> void:
	if not zyje or stan == "goni" or stan == "atak":
		return
	if global_position.distance_to(pozycja) <= promien:
		_cel_poz = pozycja
		if stan != "szuka":
			_ustaw_stan("szuka")
		_t_droga = 0.0


func _zauwaz(pozycja: Vector3) -> void:
	if stan == "czuwa" or stan == "szuka":
		_cel_poz = pozycja
		_ustaw_stan("goni")
		Dzwiek.w_swiecie(d["ryk"], global_position + Vector3.UP * 1.5, 0.0, 0.12, 18.0)
		# krzyk słyszą inni
		for w in swiat.wrogowie:
			if w != self and is_instance_valid(w):
				w.uslyszal(global_position, 14.0)


func _widzi_gracza() -> bool:
	var g := swiat.gracz
	if g == null or not g.zdrowie.zyje:
		return false
	var oczy := global_position + Vector3.UP * (0.5 if _pelza else 1.6)
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


# ====================================================================== zachowanie

func _ustaw_stan(nowy: String) -> void:
	stan = nowy
	_t_stan = 0.0
	_uderzyl = false


func _physics_process(dt: float) -> void:
	if not zyje:
		return
	_t_stan += dt if stan != "ogluszony" else 0.0
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
		if widzi:
			_cel_poz = swiat.gracz.global_position
			if stan == "czuwa" or stan == "szuka":
				_zauwaz(_cel_poz)
	var kier_ruchu := Vector3.ZERO
	var predkosc := 0.0
	match stan:
		"szuka":
			predkosc = float(d["chod"]) * 1.3
			kier_ruchu = _kierunek_do(_cel_poz, dt)
			if global_position.distance_to(_cel_poz) < 1.6:
				predkosc = 0.0
				if _t_stan > 4.0:
					_ustaw_stan("czuwa")
		"goni":
			var g := swiat.gracz
			if not g.zdrowie.zyje:
				_ustaw_stan("czuwa")
			else:
				predkosc = float(d["bieg"])
				var odl := global_position.distance_to(g.global_position)
				kier_ruchu = _kierunek_do(_cel_poz, dt)
				if odl < float(d["zasieg"]) * 0.9:
					_ustaw_stan("atak")
					predkosc = 0.0
				elif odl > 3.0 and global_position.distance_to(_cel_poz) < 1.2 and _t_stan > 3.0 and not widzi:
					_ustaw_stan("szuka")
		"atak":
			var g := swiat.gracz
			var do_g := g.global_position - global_position
			do_g.y = 0.0
			if do_g.length() > 0.1:
				rotation.y = lerp_angle(rotation.y, atan2(-do_g.x, -do_g.z), 1.0 - exp(-6.0 * dt))
			var zamach: float = d["zamach"]
			if _t_stan >= zamach and not _uderzyl:
				_uderzyl = true
				Dzwiek.w_swiecie("swist", global_position + Vector3.UP * 1.3, -2.0, 0.1, 8.0)
				var przod := -global_transform.basis.z
				if do_g.length() < float(d["zasieg"]) + 0.25 and przod.dot(do_g.normalized()) > 0.45 and g.zdrowie.zyje:
					var obr: float = d["obr"] * (0.4 if _bez_broni else 1.0) * randf_range(0.85, 1.15)
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
		predkosc = minf(predkosc, 0.75)
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
		_ustaw_poze(v, dt)
	for n in _poza:
		if _w.has(n) and is_instance_valid(_w[n]):
			var wezel: Node3D = _w[n]
			if wezel.get_parent() is RigidBody3D:
				continue
			wezel.rotation = wezel.rotation.lerp(_poza[n], 1.0 - exp(-_szybkosc_pozy * dt))
	_model.rotation.x = lerp_angle(_model.rotation.x, _pochyl, 1.0 - exp(-(7.0 if not zyje else 5.0) * dt))
	_model.position.y = lerpf(_model.position.y, _model_y, 1.0 - exp(-7.0 * dt))


func _ustaw_poze(v: float, dt: float) -> void:
	_faza += v * dt * PI / (0.62 if typ == "ghul" else 0.7)
	var a := clampf(v / 1.6, 0.0, 1.0) * 0.6
	var s := sin(_faza)
	_szybkosc_pozy = 10.0
	_pochyl = 0.0
	_model_y = -absf(s) * 0.025 * a
	_poza["udo_l"] = Vector3(s * a, 0, 0)
	_poza["udo_p"] = Vector3(-s * a, 0, 0)
	_poza["golen_l"] = Vector3(-(0.12 + 1.0 * maxf(0.0, -cos(_faza))) * a, 0, 0)
	_poza["golen_p"] = Vector3(-(0.12 + 1.0 * maxf(0.0, cos(_faza))) * a, 0, 0)
	var oddech := sin(_t * 1.7) * 0.03
	var goni := stan == "goni" or stan == "atak"
	if typ == "ghul":
		_poza["tors"] = Vector3(-0.30 - (0.22 if goni else 0.0) + oddech, s * 0.10 * a, 0)
		_poza["glowa"] = Vector3(0.28 + (0.2 if goni else 0.0), sin(_t * 0.7) * 0.25 * (0.0 if goni else 1.0), 0)
		var siega := 1.15 if goni else 0.15
		_poza["ramie_l"] = Vector3(siega - s * a * 0.5, 0, -0.12)
		_poza["ramie_p"] = Vector3(siega + s * a * 0.5, 0, 0.12)
		_poza["przedramie_l"] = Vector3(0.45 if goni else 0.25, 0, 0)
		_poza["przedramie_p"] = Vector3(0.45 if goni else 0.25, 0, 0)
	else:
		_poza["tors"] = Vector3(-0.06 + oddech * 0.5, s * 0.08 * a, 0)
		_poza["glowa"] = Vector3(0.05, sin(_t * 0.5) * 0.18 * (0.0 if goni else 1.0), 0)
		_poza["ramie_l"] = Vector3(0.10 - s * a * 0.3, 0, -0.06)
		_poza["przedramie_l"] = Vector3(0.20, 0, 0)
		_poza["ramie_p"] = Vector3((0.55 if goni else 0.12) + s * a * 0.25, 0, 0.06)
		_poza["przedramie_p"] = Vector3(0.55 if goni else 0.2, 0, 0)
		if typ == "rycerz" and goni:
			_poza["ramie_l"] = Vector3(0.55 - s * a * 0.2, 0, 0.25)
			_poza["przedramie_l"] = Vector3(0.75, 0, 0)
	if stan == "atak":
		var zamach: float = d["zamach"]
		var uderza := _t_stan >= zamach
		_szybkosc_pozy = 26.0 if uderza else 7.0
		if typ == "ghul":
			_poza["ramie_p"] = Vector3(2.0 if uderza else -0.7, 0, 0.3 if uderza else -0.2)
			_poza["ramie_l"] = Vector3(1.7 if uderza else 0.6, 0, -0.25)
			_poza["przedramie_p"] = Vector3(0.15 if uderza else 1.1, 0, 0)
			_poza["tors"] = Vector3(-0.75 if uderza else -0.15, -0.35 if uderza else 0.4, 0)
		else:
			_poza["ramie_p"] = Vector3(0.75 if uderza else 2.85, 0, 0.1)
			_poza["przedramie_p"] = Vector3(0.15 if uderza else 0.6, 0, 0)
			_poza["tors"] = Vector3(-0.38 if uderza else 0.12, -0.25 if uderza else 0.3, 0)
			if typ == "rycerz":
				_poza["ramie_l"] = Vector3(0.9 if uderza else 2.6, 0, 0.45)
				_poza["przedramie_l"] = Vector3(0.5 if uderza else 0.9, 0, 0)
	elif stan == "ogluszony":
		_poza["tors"] = Vector3(0.35, 0.2, 0.1)
		_poza["glowa"] = Vector3(-0.3, 0, 0.2)
	if _pelza:
		_pochyl = -1.32
		_model_y = 0.22
		var c := sin(_t * 3.0) * (1.0 if v > 0.1 else 0.2)
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
	# odgłos kroków
	var nr := int(_faza / PI)
	if nr != _ost_krok and v > 0.3:
		_ost_krok = nr
		Dzwiek.w_swiecie(d["krok"], global_position, -8.0 if typ == "ghul" else -2.0, 0.15, d["zasieg_krokow"])
