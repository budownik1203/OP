class_name Bron
extends Node3D
## Broń liczona proceduralnie: bezwładność, kołysanie, odrzut na sprężynach,
## celowanie przez przyrządy, magazynki jako przedmioty, kolizja lufy ze ścianą.
## Pocisk leci tam, gdzie faktycznie patrzy lufa.

signal komunikat(tekst: String)

const DANE := {
	"kwarc": {
		"nazwa": "BRON_KWARC", "kaliber": "5.56x45", "rpm": 700.0,
		"tryby": ["TRYB_POJ", "TRYB_SERIA"], "masa": 3.4, "dlugosc": 0.74,
		"odrzut_pion": 1.0, "odrzut_bok": 0.55, "odrzut_tyl": 1.0, "odrzut_kamera": 0.55,
		"czas_celu": 0.30, "poj": 30, "ile_mag": 5, "amunicja": "A_556_FMJ",
		"model": "res://zasoby/modele/kwarc.glb",
		"biodro": Vector3(0.105, -0.158, -0.225), "biodro_rot": Vector3(0.0, 0.045, -0.06),
		"t_takt": 2.9, "t_szybkie": 2.0, "rozrzut_moa": 2.5,
		"dzw_strzal": "strzal_556", "skok_zamka": 0.07, "zoom": 0.84, "zamek_zostaje": false,
		"luska": Vector3(0.0057, 0.0057, 0.045),
	},
	"jaspis": {
		"nazwa": "BRON_JASPIS", "kaliber": "9x19", "rpm": 420.0,
		"tryby": ["TRYB_POJ"], "masa": 0.95, "dlugosc": 0.50,
		"odrzut_pion": 1.9, "odrzut_bok": 0.9, "odrzut_tyl": 0.8, "odrzut_kamera": 0.75,
		"czas_celu": 0.20, "poj": 15, "ile_mag": 4, "amunicja": "A_9_FMJ",
		"model": "res://zasoby/modele/jaspis.glb",
		"biodro": Vector3(0.085, -0.135, -0.40), "biodro_rot": Vector3(0.0, 0.03, -0.04),
		"t_takt": 2.3, "t_szybkie": 1.6, "rozrzut_moa": 6.0,
		"dzw_strzal": "strzal_9", "skok_zamka": 0.036, "zoom": 0.92, "zamek_zostaje": true,
		"luska": Vector3(0.0095, 0.0095, 0.019),
	},
}


class Sprezyna:
	var x := Vector3.ZERO
	var v := Vector3.ZERO

	func krok(dt: float, k: float, c: float) -> void:
		v += (-k * x - c * v) * dt
		x += v * dt


var id := ""
var d := {}
var gracz: Gracz
var aktywna := false
var komora := ""                 ## typ naboju w komorze albo ""
var mag: Variant = null          ## Array nabojów magazynka w broni albo null
var mag_p := {}                  ## przedmiot magazynka w broni ({} = brak)
## zapasowe magazynki dostępne od ręki (kamizelka i kieszenie), jako listy nabojów
var magi: Array:
	get:
		return Ekwipunek.magazynki(id).map(func(p): return p["dane"]["naboje"])
var tryb := 0
var cel := 0.0                   ## 0 biodro .. 1 przyrządy
var zablokowana := 0.0

var _model: Node3D
var _wylot: Node3D
var _celownik: Node3D
var _n_mag: Node3D
var _n_zamek: Node3D
var _n_reka_l: Node3D
var _poz_mag := Vector3.ZERO
var _poz_zamek := Vector3.ZERO
var _poz_reka_l := Vector3.ZERO
var _poz_cel := Vector3.ZERO
var _odrz_poz := Sprezyna.new()
var _odrz_rot := Sprezyna.new()
var _lag := Vector2.ZERO
var _czas := 0.0
var _do_strzalu := 0.0
var _wyjecie := 0.0
var _sprint_f := 0.0
var _lek_f := 0.0
var _stan := ""
var _t := 0.0
var _t_max := 1.0
var _zdarzenia := {}
var _nowy_mag := {}
var _miejsce := {}
var _zamek_t := 0.0
var _blysk: MeshInstance3D
var _blysk_swiatlo: OmniLight3D
var _blysk_t := 0.0
var _latarka: SpotLight3D
var _okno_r := 0.0
var _fov_bazowe := 72.0
var test_cel := -1.0             ## tylko do zrzutów testowych: wymusza celowanie


func przygotuj(id_broni: String, wlasciciel: Gracz) -> void:
	id = id_broni
	d = DANE[id]
	gracz = wlasciciel
	_wczytaj_model()
	var st: Dictionary = Ekwipunek.stan_broni[id]
	komora = st["komora"]
	_ustaw_mag(st["mag"])
	_zbuduj_blysk()
	_zbuduj_latarke()
	visible = false


func _wczytaj_model() -> void:
	if ResourceLoader.exists(d["model"]):
		var scena: PackedScene = load(d["model"])
		_model = scena.instantiate()
	else:
		_model = Node3D.new()
		push_warning("Brak modelu broni: " + d["model"])
	add_child(_model)
	_wylot = _znajdz("wylot", Vector3(0, 0.03, -0.5))
	_celownik = _znajdz("celownik", Vector3(0, 0.08, 0.1))
	_n_mag = _znajdz("magazynek", Vector3.ZERO)
	_n_zamek = _znajdz("zamek", Vector3.ZERO)
	_n_reka_l = _znajdz("reka_l", Vector3.ZERO)
	_poz_mag = _n_mag.position
	_poz_zamek = _n_zamek.position
	_poz_reka_l = _n_reka_l.position
	_poz_cel = -_pozycja_w_modelu(_celownik)
	for s in _model.find_children("*", "MeshInstance3D", true, false):
		(s as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		(s as MeshInstance3D).extra_cull_margin = 2.0
		(s as MeshInstance3D).layers = 1 | 2
		var siatka := (s as MeshInstance3D).mesh
		for i in siatka.get_surface_count():
			var mat := siatka.surface_get_material(i)
			if mat is BaseMaterial3D:
				(mat as BaseMaterial3D).texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS


func _znajdz(nazwa: String, zapas: Vector3) -> Node3D:
	var n := _model.find_child(nazwa, true, false)
	if n == null:
		n = Node3D.new()
		n.name = nazwa
		(n as Node3D).position = zapas
		_model.add_child(n)
	return n as Node3D


func _pozycja_w_modelu(n: Node3D) -> Vector3:
	var t := Transform3D.IDENTITY
	var w: Node = n
	while w != null and w != self:
		t = (w as Node3D).transform * t
		w = w.get_parent()
	return t.origin


func _zbuduj_blysk() -> void:
	_blysk = MeshInstance3D.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r := 0.055 if d["kaliber"] == "5.56x45" else 0.04
	var dl := 0.16 if d["kaliber"] == "5.56x45" else 0.09
	for i in 3:
		var kat := i * PI / 3.0
		var bok := Vector3(cos(kat), sin(kat), 0.0) * r
		for v in [Vector3.ZERO, bok + Vector3(0, 0, -dl * 0.35), Vector3(0, 0, -dl), Vector3.ZERO, Vector3(0, 0, -dl), -bok + Vector3(0, 0, -dl * 0.35)]:
			st.add_vertex(v)
	_blysk.mesh = st.commit()
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(1.0, 0.78, 0.42) * 2.2
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_blysk.material_override = m
	_blysk.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_blysk.visible = false
	_wylot.add_child(_blysk)
	_blysk_swiatlo = OmniLight3D.new()
	_blysk_swiatlo.light_color = Color(1.0, 0.72, 0.4)
	_blysk_swiatlo.omni_range = 9.0
	_blysk_swiatlo.light_energy = 0.0
	_blysk_swiatlo.position = Vector3(0, 0.02, -0.12)
	_wylot.add_child(_blysk_swiatlo)


func _zbuduj_latarke() -> void:
	_latarka = SpotLight3D.new()
	_latarka.spot_range = 45.0
	_latarka.spot_angle = 30.0
	_latarka.spot_angle_attenuation = 0.9
	_latarka.spot_attenuation = 0.55
	_latarka.light_energy = 5.2
	_latarka.light_color = Color(0.95, 0.97, 1.0)
	_latarka.shadow_enabled = true
	_latarka.position = Vector3(0.03, -0.03, 0.06)
	_latarka.visible = false
	_wylot.add_child(_latarka)
	# słaba poświata wokół snopu, żeby było widać ściany tuż obok
	var poswiata := SpotLight3D.new()
	poswiata.spot_range = 14.0
	poswiata.spot_angle = 62.0
	poswiata.spot_angle_attenuation = 1.6
	poswiata.light_energy = 1.0
	poswiata.spot_attenuation = 0.6
	poswiata.light_color = Color(0.9, 0.94, 1.0)
	_latarka.add_child(poswiata)


func _ustaw_mag(p: Dictionary) -> void:
	mag_p = p
	mag = null if p.is_empty() else p["dane"]["naboje"]
	if _n_mag:
		_n_mag.visible = mag != null


## Zapisuje stan broni do ekwipunku (przed zmianą lokacji).
func zapisz_stan() -> void:
	Ekwipunek.stan_broni[id] = {"mag": mag_p, "komora": komora}


## Stół amunicyjny: napełnia wszystkie magazynki tej broni. typ_b: przeplot 2:1.
func zaladuj_magazynki(typ_a: String, typ_b: String) -> void:
	var lista := Ekwipunek.wszystkie_magazynki(id)
	if not mag_p.is_empty():
		lista.append(mag_p)
	for p in lista:
		var naboje: Array = p["dane"]["naboje"]
		naboje.clear()
		for i in d["poj"]:
			naboje.append(typ_b if typ_b != "" and i % 3 == 2 else typ_a)
	if mag != null and komora == "":
		komora = mag.pop_back()
	Ekwipunek.zmiana.emit()


func wyjmij() -> void:
	aktywna = true
	visible = true
	_stan = "zmiana"
	_t = 0.0
	_t_max = 0.45
	_zdarzenia = {}
	Dzwiek.przy_uchu("bron_wyjmij", -8.0)


func wlacz_latarke(stan: bool) -> void:
	_latarka.visible = stan
	gracz.latarka = stan


func schowaj() -> void:
	aktywna = false
	if not _nowy_mag.is_empty():
		if mag == null:
			_ustaw_mag(_nowy_mag)
		else:
			Ekwipunek.podnies(_nowy_mag)
		_nowy_mag = {}
	_stan = ""
	cel = 0.0
	gracz.celuje = false


func _process(dt: float) -> void:
	_czas += dt
	_wyjecie = move_toward(_wyjecie, 1.0 if aktywna else 0.0, dt / 0.32)
	if not aktywna and _wyjecie <= 0.0:
		visible = false
		return
	var steruje := aktywna and gracz.sterowanie and gracz.zdrowie.zyje and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	gracz.latarka = _latarka.visible if aktywna else gracz.latarka
	_sprawdz_sciane(dt)
	_obsluz_wejscie(dt, steruje)
	_stan_krok(dt)
	_poza(dt)
	_efekty(dt)


func _sprawdz_sciane(dt: float) -> void:
	var kam := gracz.kamera
	var od := kam.global_position
	var dl: float = d["dlugosc"] * lerpf(1.0, 0.82, cel)
	var q := PhysicsRayQueryParameters3D.create(od, od - kam.global_transform.basis.z * dl)
	q.exclude = [gracz.get_rid()]
	q.collision_mask = 1
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	var blok := 0.0
	if not hit.is_empty():
		blok = clampf((1.0 - od.distance_to(hit["position"]) / dl) * 1.8, 0.0, 1.0)
	zablokowana = lerpf(zablokowana, blok, 1.0 - exp(-12.0 * dt))


func _obsluz_wejscie(dt: float, steruje: bool) -> void:
	# ujemna reszta przenosi się na kolejny strzał: szybkostrzelność nie zależy od liczby klatek
	_do_strzalu = maxf(_do_strzalu - dt, -0.05)
	var wolna := _stan == "" and gracz.zdrowie.uzywa == ""
	var chce_cel := steruje and gracz.zdrowie.uzywa == "" and Input.is_action_pressed("celuj") and not gracz.sprintuje and zablokowana < 0.35 and (_stan == "" or _stan == "okno_r")
	if test_cel >= 0.0:
		chce_cel = test_cel > 0.5
	gracz.celuje = chce_cel and aktywna
	var szybkosc: float = Strojenie.w["S_CELOWANIE"] / d["czas_celu"]
	cel = move_toward(cel, 1.0 if chce_cel else 0.0, dt * szybkosc)
	if not steruje:
		return
	if Input.is_action_just_pressed("latarka"):
		_latarka.visible = not _latarka.visible
		Dzwiek.przy_uchu("klik", -6.0)
	if Input.is_action_just_pressed("tryb_ognia") and wolna and d["tryby"].size() > 1:
		tryb = (tryb + 1) % d["tryby"].size()
		komunikat.emit(tr(d["tryby"][tryb]))
		Dzwiek.przy_uchu("klik", -4.0)
	if Input.is_action_just_pressed("sprawdz_mag") and wolna:
		_zacznij("sprawdz", 1.5, {0.55: "sprawdz"})
	if Input.is_action_just_pressed("przeladuj"):
		if wolna:
			_stan = "okno_r"
			_okno_r = 0.28
		elif _stan == "okno_r":
			_zacznij_przeladowanie(true)
	var seria: bool = d["tryby"][tryb] == "TRYB_SERIA"
	var spust := Input.is_action_pressed("strzal") if seria else Input.is_action_just_pressed("strzal")
	if spust and wolna and _do_strzalu <= 0.0 and not gracz.sprintuje and zablokowana < 0.35 and _wyjecie >= 1.0:
		if komora != "":
			var odstep: float = 60.0 / d["rpm"]
			if not seria:
				_do_strzalu = 0.0
			while _do_strzalu <= 0.0 and komora != "":
				_strzal()
				_do_strzalu += odstep
				if not seria:
					break
		elif Input.is_action_just_pressed("strzal"):
			Dzwiek.przy_uchu("suchy", -3.0)
			_do_strzalu = 0.2


func _zacznij(stan: String, czas: float, zdarzenia: Dictionary) -> void:
	_stan = stan
	_t = 0.0
	_t_max = czas
	_zdarzenia = zdarzenia.duplicate()


func _zacznij_przeladowanie(szybkie: bool) -> void:
	var zapas := Ekwipunek.magazynki(id)
	if zapas.is_empty():
		_stan = ""
		komunikat.emit(tr("BRAK_MAG"))
		return
	var najlepszy: Dictionary = zapas[0]
	for p in zapas:
		if p["dane"]["naboje"].size() > najlepszy["dane"]["naboje"].size():
			najlepszy = p
	if najlepszy["dane"]["naboje"].is_empty() and (mag == null or not mag.is_empty()):
		_stan = ""
		komunikat.emit(tr("BRAK_MAG"))
		return
	# zapamiętaj miejsce w kamizelce: stary magazynek wróci tam, skąd wyjęto nowy
	_nowy_mag = najlepszy
	_miejsce = {"poj": Ekwipunek.pojemnik_przedmiotu(najlepszy), "x": najlepszy["x"], "y": najlepszy["y"], "obr": najlepszy["obr"]}
	Ekwipunek.wyjmij(najlepszy)
	var zd := {0.24: "mag_wyj_s" if szybkie else "mag_wyj", 0.66: "mag_wl", 0.86: "zamek"}
	_zacznij("przelad", d["t_szybkie"] if szybkie else d["t_takt"], zd)


func _stan_krok(dt: float) -> void:
	if _stan == "":
		return
	if _stan == "okno_r":
		_okno_r -= dt
		if _okno_r <= 0.0:
			_zacznij_przeladowanie(false)
		return
	_t += dt
	var p := _t / _t_max
	for prog in _zdarzenia.keys():
		if p >= prog:
			var z: String = _zdarzenia[prog]
			_zdarzenia.erase(prog)
			_zdarzenie(z)
	if p >= 1.0:
		_stan = ""


func _zdarzenie(z: String) -> void:
	match z:
		"mag_wyj", "mag_wyj_s":
			Dzwiek.przy_uchu("mag_wyj", -3.0)
			if mag != null:
				var stary := mag_p
				if z == "mag_wyj_s":
					_upusc_magazynek(stary)
					komunikat.emit(tr("MAG_UPUSZCZONY"))
				elif not Ekwipunek.wloz_do_szybkich(stary, _miejsce.get("poj"), _miejsce.get("x", 0), _miejsce.get("y", 0), _miejsce.get("obr", false)):
					_upusc_magazynek(stary)
					komunikat.emit(tr("E_BRAK_MIEJSCA"))
			_ustaw_mag({})
		"mag_wl":
			Dzwiek.przy_uchu("mag_wl", -2.0)
			_ustaw_mag(_nowy_mag)
			_nowy_mag = {}
		"zamek":
			if komora == "" and mag != null and not mag.is_empty():
				komora = mag.pop_back()
				_zamek_t = 0.16
				Dzwiek.przy_uchu("zamek", -2.0)
		"sprawdz":
			komunikat.emit(_opis_magazynka())


func _opis_magazynka() -> String:
	var tekst := tr("BRAK_MAG")
	if mag != null:
		var r := float(mag.size()) / float(d["poj"])
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
		tekst = tr(k)
	return tekst + " · " + tr("KOMORA_NABOJ" if komora != "" else "KOMORA_PUSTA")


func _upusc_magazynek(p: Dictionary) -> void:
	var swiat := get_tree().get_first_node_in_group("swiat")
	if swiat == null:
		Ekwipunek.podnies(p)
		return
	swiat.upusc(p, _n_mag.global_position + Vector3.DOWN * 0.1, gracz.velocity + Vector3.DOWN)


func _strzal() -> void:
	var typ := komora
	komora = ""
	if mag != null and not mag.is_empty():
		komora = mag.pop_back()
	_zamek_t = 0.07
	var dane_a: Dictionary = Amunicja.TYPY[typ]
	# kierunek = oś lufy + rozrzut własny broni
	var baza := _wylot.global_transform.basis
	var rozrzut: float = d["rozrzut_moa"] / 3438.0
	var kat := randf() * TAU
	var r := sqrt(randf()) * rozrzut
	var kier := (-baza.z + baza.x * cos(kat) * r + baza.y * sin(kat) * r).normalized()
	var pociski := get_tree().get_first_node_in_group("pociski")
	if pociski:
		# start z pozycji kamery rzutowanej na oś lufy, żeby nie strzelać przez ścianę
		pociski.wystrzel(_wylot.global_position, kier, typ, gracz)
	# odrzut
	var s: float = Strojenie.w["S_ODRZUT"]
	var postawa := 0.78 if gracz.kuca else 1.0
	var rece := lerpf(1.4, 1.0, gracz.wytrz_rece)
	var w_celu := lerpf(1.0, 0.72, cel)
	var moc := s * postawa * rece * w_celu
	_odrz_poz.v.z += 0.95 * d["odrzut_tyl"] * moc
	_odrz_poz.v.y += 0.12 * d["odrzut_pion"] * moc
	_odrz_rot.v.x += 1.05 * d["odrzut_pion"] * moc
	_odrz_rot.v.y += randf_range(-1.0, 1.0) * 0.55 * d["odrzut_bok"] * moc
	_odrz_rot.v.z += randf_range(-1.0, 1.0) * 0.9 * moc
	gracz.kopniecie(d["odrzut_kamera"] * postawa * rece, randf_range(-0.35, 0.35) * d["odrzut_bok"])
	# efekty
	_blysk_t = 0.045
	_blysk.rotation.z = randf() * TAU
	_blysk.scale = Vector3.ONE * randf_range(0.8, 1.25)
	Dzwiek.przy_uchu(d["dzw_strzal"], 0.0, 0.035)
	var swiat_h := get_tree().get_first_node_in_group("swiat")
	if swiat_h:
		swiat_h.halas(gracz.global_position, 55.0 * float(dane_a["halas"]))
	_wyrzuc_luske()


func _wyrzuc_luske() -> void:
	var swiat := get_tree().get_first_node_in_group("swiat")
	if swiat == null or not swiat.has_method("luska"):
		return
	var b := global_transform.basis
	var start := global_position + b * Vector3(0.03, 0.05, -0.05)
	var v := gracz.velocity + b.x * randf_range(2.2, 3.2) + b.y * randf_range(1.2, 2.0) + b.z * randf_range(-0.4, 0.6)
	swiat.luska(start, v, d["luska"])


func _poza(dt: float) -> void:
	var t_cel := smoothstep(0.0, 1.0, cel)
	var poz: Vector3 = (d["biodro"] as Vector3).lerp(_poz_cel, t_cel)
	var rot: Vector3 = (d["biodro_rot"] as Vector3).lerp(Vector3.ZERO, t_cel)

	# wyjmowanie / chowanie
	var w := 1.0 - smoothstep(0.0, 1.0, _wyjecie)
	poz += Vector3(0.05, -0.38, 0.10) * w
	rot += Vector3(-0.95, 0.35, 0.0) * w

	# sprint
	_sprint_f = move_toward(_sprint_f, 1.0 if gracz.sprintuje else 0.0, dt * 5.0)
	var sf := smoothstep(0.0, 1.0, _sprint_f)
	if d["kaliber"] == "9x19":
		poz += Vector3(0.0, -0.05, 0.10) * sf
		rot += Vector3(0.55, 0.0, 0.0) * sf
	else:
		poz += Vector3(-0.07, -0.05, 0.06) * sf
		rot += Vector3(-0.22, 0.75, 0.30) * sf

	# leczenie: broń opuszczona
	_lek_f = move_toward(_lek_f, 1.0 if gracz.zdrowie.uzywa != "" else 0.0, dt * 4.0)
	var lf := smoothstep(0.0, 1.0, _lek_f)
	poz += Vector3(0.02, -0.22, 0.06) * lf
	rot += Vector3(-0.7, 0.4, 0.2) * lf

	# ściana
	var zb := smoothstep(0.0, 1.0, zablokowana)
	poz += Vector3(-0.02, -0.03, 0.16) * zb
	rot += Vector3(0.85, 0.30, 0.0) * zb

	# bezwładność: broń spóźnia się za kamerą
	var m := gracz.ruch_myszy
	gracz.ruch_myszy = Vector2.ZERO
	var bezwl: float = Strojenie.w["S_BEZWLADNOSC"] * sqrt(d["masa"] / 3.4)
	var cel_lag := Vector2(m.y, m.x) / maxf(dt, 0.001) * 0.000042 * bezwl
	cel_lag = cel_lag.limit_length(0.085)
	_lag = _lag.lerp(cel_lag, 1.0 - exp(-11.0 * dt))
	var lag_w := lerpf(1.0, 0.45, t_cel)
	rot.x += _lag.x * lag_w
	rot.y += _lag.y * lag_w
	rot.z -= _lag.y * 0.7 * lag_w
	poz.x -= _lag.y * 0.05 * lag_w
	poz.y += _lag.x * 0.04 * lag_w

	# chód
	var sila: float = clampf(gracz.predkosc_pozioma / Gracz.V_SPRINT, 0.0, 1.0) * Strojenie.w["S_KROK"] * lerpf(1.0, 0.18, t_cel)
	var f := gracz.krok_faza
	poz.x += sin(f) * 0.016 * sila
	poz.y -= absf(cos(f)) * 0.013 * sila
	rot.z += sin(f) * 0.03 * sila
	rot.x += cos(f * 2.0) * 0.012 * sila

	# oddech i zmęczenie rąk
	var amp: float = (0.0022 + 0.014 * (1.0 - gracz.wytrz_rece)) * Strojenie.w["S_KOLYSANIE"] * gracz.zdrowie.mnoznik_kolysania()
	if gracz.kuca:
		amp *= 0.7
	rot.x += (sin(_czas * 1.13) + sin(_czas * 2.71) * 0.3) * amp
	rot.y += (sin(_czas * 0.83 + 1.3) + sin(_czas * 1.97) * 0.25) * amp * 1.25
	poz.y += sin(_czas * 1.13) * amp * 0.25

	# odrzut
	_odrz_poz.krok(dt, 210.0, 22.0)
	_odrz_rot.krok(dt, 170.0, 19.0)
	poz += _odrz_poz.x
	rot += _odrz_rot.x

	# przeładowanie i sprawdzanie magazynka
	if _stan == "przelad" or _stan == "sprawdz":
		var p := clampf(_t / _t_max, 0.0, 1.0)
		var obw := pow(sin(p * PI), 0.55)
		poz += Vector3(-0.015, -0.035, 0.03) * obw * (1.0 - t_cel * 0.3)
		rot += Vector3(0.30, 0.10, 0.42) * obw
		if _stan == "przelad":
			var reka := smoothstep(0.16, 0.30, p) * (1.0 - smoothstep(0.58, 0.70, p))
			_n_reka_l.position = _poz_reka_l + Vector3(-0.03, -0.26, 0.10) * reka
			_n_mag.position = _poz_mag + Vector3(0.0, -0.22, 0.02) * reka
			# szarpnięcie przy wpinaniu magazynka
			rot.x += sin(clampf((p - 0.66) * 14.0, 0.0, 1.0) * PI) * 0.035
		else:
			_n_reka_l.position = _poz_reka_l
	else:
		_n_reka_l.position = _n_reka_l.position.lerp(_poz_reka_l, 1.0 - exp(-18.0 * dt))
		_n_mag.position = _poz_mag

	transform = Transform3D(Basis.from_euler(rot), poz)

	# lekkie przybliżenie przy celowaniu
	var bazowe: float = Strojenie.w["S_FOV"]
	gracz.kamera.fov = lerpf(bazowe, bazowe * d["zoom"], t_cel)


func _efekty(dt: float) -> void:
	_blysk_t = maxf(_blysk_t - dt, 0.0)
	_blysk.visible = _blysk_t > 0.0
	_blysk_swiatlo.light_energy = 5.0 * (_blysk_t / 0.045)
	_zamek_t = maxf(_zamek_t - dt, 0.0)
	var cofniecie := 0.0
	if _zamek_t > 0.0:
		cofniecie = 1.0
	elif d["zamek_zostaje"] and komora == "":
		cofniecie = 0.9
	_n_zamek.position = _n_zamek.position.lerp(_poz_zamek + Vector3(0, 0, d["skok_zamka"] * cofniecie), 1.0 - exp(-60.0 * dt))
