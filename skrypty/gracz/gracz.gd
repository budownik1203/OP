class_name Gracz
extends CharacterBody3D
## Ruch żołnierza: ciężki, z bezwładnością, regulowanym tempem chodu,
## wychylaniem, kucaniem i dwiema pulami wytrzymałości.

signal krok(glosnosc: float)

const WYS_STOI := 1.78
const WYS_KUCA := 1.15
const PROMIEN := 0.28
const OCZY_STOI := 1.64
const OCZY_KUCA := 1.02
const V_CHOD := 3.1
const V_SPRINT := 5.4
const V_KUCA := 1.7
const PRZYSP := 11.0
const HAMOWANIE := 14.0
const GRAWITACJA := 12.5
const V_SKOK := 4.1
const KAT_WYCHYLENIA := 0.24
const BOK_WYCHYLENIA := 0.26

var tempo := 0.75            ## 0.25..1, kółko myszy
var kuca := false
var sprintuje := false
var celuje := false          ## ustawiane przez broń
var wytrz_nogi := 1.0
var wytrz_rece := 1.0
var krok_faza := 0.0
var predkosc_pozioma := 0.0
var ruch_myszy := Vector2.ZERO   ## zbierany dla broni, zerowany przez broń
var sterowanie := true
var zdrowie: Zdrowie
var latarka := false           ## ustawiane przez broń; wrogowie widzą światło z daleka

var szyja: Node3D
var os_kamery: Node3D
var kamera: Camera3D
var _kolizja: CollisionShape3D
var _kapsula: CapsuleShape3D
var _wys := WYS_STOI
var _wychyl := 0.0
var _kop := Vector2.ZERO         ## odchylenie kamery od odrzutu (pitch, yaw)
var _kop_v := Vector2.ZERO
var _pitch := 0.0
var _ladowanie := 0.0
var _byl_na_ziemi := true


func _ready() -> void:
	zdrowie = Zdrowie.new()
	add_child(zdrowie)
	collision_layer = 1
	collision_mask = 1 | 8
	_kapsula = CapsuleShape3D.new()
	_kapsula.radius = PROMIEN
	_kapsula.height = WYS_STOI
	_kolizja = CollisionShape3D.new()
	_kolizja.shape = _kapsula
	_kolizja.position.y = WYS_STOI * 0.5
	add_child(_kolizja)
	szyja = Node3D.new()
	szyja.position.y = OCZY_STOI
	add_child(szyja)
	os_kamery = Node3D.new()
	szyja.add_child(os_kamery)
	kamera = Camera3D.new()
	kamera.near = 0.03
	kamera.far = 600.0
	kamera.fov = Strojenie.w["S_FOV"]
	os_kamery.add_child(kamera)
	kamera.make_current()
	# słabe światło wypełniające tylko dla broni i rąk (warstwa 2), żeby było je widać w cieniu
	var wyp := OmniLight3D.new()
	wyp.position = Vector3(-0.15, 0.25, 0.15)
	wyp.light_cull_mask = 2
	wyp.light_energy = 0.55
	wyp.omni_range = 2.5
	wyp.omni_attenuation = 0.6
	wyp.light_color = Color(0.82, 0.86, 0.92)
	wyp.light_specular = 0.2
	kamera.add_child(wyp)
	floor_snap_length = 0.25
	floor_max_angle = deg_to_rad(46.0)
	Strojenie.zmieniono.connect(func(k): if k == "S_FOV": kamera.fov = Strojenie.w["S_FOV"])


## Wejście gracza. Wywoływane z korzenia gry: zdarzenia myszy nie docierają
## same do węzłów wewnątrz obrazu renderowanego w niskiej rozdzielczości.
func wejscie(ev: InputEvent) -> void:
	if not sterowanie or not zdrowie.zyje:
		return
	if ev is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var czulosc: float = 0.0022 * Strojenie.w["S_MYSZ"] * (0.6 if celuje else 1.0)
		rotate_y(-ev.relative.x * czulosc)
		_pitch = clampf(_pitch - ev.relative.y * czulosc, -1.48, 1.48)
		ruch_myszy += ev.relative
	elif ev is InputEventMouseButton and ev.pressed:
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			tempo = minf(tempo + 0.125, 1.0)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			tempo = maxf(tempo - 0.125, 0.25)
	elif ev.is_action_pressed("kucnij"):
		if kuca:
			if _moze_wstac():
				kuca = false
		else:
			kuca = true


func _moze_wstac() -> bool:
	var q := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.5, global_position + Vector3.UP * (WYS_STOI + 0.05))
	q.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _physics_process(dt: float) -> void:
	var wej := Vector2.ZERO
	var chce_sprint := false
	var chce_skok := false
	var wych := 0.0
	if sterowanie and zdrowie.zyje:
		wej = Input.get_vector("lewo", "prawo", "przod", "tyl")
		chce_sprint = Input.is_action_pressed("sprint")
		chce_skok = Input.is_action_just_pressed("skok")
		wych = Input.get_axis("wychyl_prawo", "wychyl_lewo")
	var na_ziemi := is_on_floor()

	# --- prędkość docelowa ---
	sprintuje = chce_sprint and wej.y < -0.5 and not kuca and not celuje and wytrz_nogi > 0.08 and na_ziemi and zdrowie.moze_sprintowac() and Ekwipunek.moze_sprintowac()
	var v_max := V_CHOD * tempo
	if kuca:
		v_max = V_KUCA * lerpf(0.6, 1.0, tempo)
	elif sprintuje:
		v_max = V_SPRINT
	if celuje:
		v_max *= 0.62
	if wej.y > 0.1:
		v_max *= 0.75
	v_max *= Strojenie.w["S_RUCH"] * zdrowie.mnoznik_ruchu() * Ekwipunek.mnoznik_ruchu()
	var kier := (global_transform.basis * Vector3(wej.x, 0.0, wej.y))
	kier.y = 0.0
	if kier.length() > 1.0:
		kier = kier.normalized()
	var cel := kier * v_max
	var poz := Vector3(velocity.x, 0.0, velocity.z)
	if na_ziemi:
		var tempo_zmiany := PRZYSP if cel.length() > poz.length() else HAMOWANIE
		poz = poz.move_toward(cel, tempo_zmiany * dt)
	else:
		poz = poz.move_toward(cel, 1.5 * dt)
	velocity.x = poz.x
	velocity.z = poz.z

	# --- pion ---
	if na_ziemi:
		if chce_skok and wytrz_nogi > 0.15 and not kuca:
			velocity.y = V_SKOK
			wytrz_nogi -= 0.14
	else:
		velocity.y -= GRAWITACJA * dt
	var v_spadku := velocity.y
	move_and_slide()
	if is_on_floor() and not _byl_na_ziemi:
		_ladowanie = clampf(-v_spadku * 0.035, 0.0, 0.25)
		krok.emit(clampf(-v_spadku * 0.2, 0.3, 1.0))
	_byl_na_ziemi = is_on_floor()
	predkosc_pozioma = Vector2(velocity.x, velocity.z).length()

	# --- wytrzymałość ---
	if sprintuje:
		wytrz_nogi = maxf(wytrz_nogi - 0.105 * dt, 0.0)
	else:
		var odp := 0.085 if predkosc_pozioma < 0.5 else 0.05
		wytrz_nogi = minf(wytrz_nogi + odp * dt, 1.0)
	if celuje:
		wytrz_rece = maxf(wytrz_rece - 0.028 * dt, 0.0)
	else:
		wytrz_rece = minf(wytrz_rece + 0.09 * dt, 1.0)

	# --- kroki ---
	if is_on_floor() and predkosc_pozioma > 0.3:
		var dlugosc_kroku := 0.72 if not sprintuje else 1.05
		var poprzednia := krok_faza
		krok_faza += predkosc_pozioma / dlugosc_kroku * dt * PI
		if int(poprzednia / PI) != int(krok_faza / PI):
			var g := clampf(predkosc_pozioma / V_SPRINT, 0.12, 1.0) * Ekwipunek.mnoznik_halasu()
			if kuca:
				g *= 0.5
			krok.emit(minf(g, 1.6))

	# --- wysokość, wychylenie, kamera ---
	var cel_wys := WYS_KUCA if kuca else WYS_STOI
	_wys = move_toward(_wys, cel_wys, 2.6 * dt)
	_kapsula.height = _wys
	_kolizja.position.y = _wys * 0.5
	var t := inverse_lerp(WYS_KUCA, WYS_STOI, _wys)
	_ladowanie = move_toward(_ladowanie, 0.0, dt * 0.9)
	if sprintuje or not is_on_floor():
		wych = 0.0
	wych = _ogranicz_wychylenie(wych)
	_wychyl = lerpf(_wychyl, wych, 1.0 - exp(-9.0 * dt))
	szyja.position = Vector3(-_wychyl * BOK_WYCHYLENIA, lerpf(OCZY_KUCA, OCZY_STOI, t) - _ladowanie - absf(_wychyl) * 0.04, 0.0)
	szyja.rotation.z = _wychyl * KAT_WYCHYLENIA

	# sprężyna odrzutu kamery
	var k := 140.0
	var tl := 17.0
	_kop_v += (-k * _kop - tl * _kop_v) * dt
	_kop += _kop_v * dt
	var buj := Vector2.ZERO
	if is_on_floor():
		var sila: float = clampf(predkosc_pozioma / V_SPRINT, 0.0, 1.0) * Strojenie.w["S_KROK"]
		buj.x = sin(krok_faza * 2.0) * 0.006 * sila
		buj.y = sin(krok_faza) * 0.004 * sila
		kamera.position.y = -absf(sin(krok_faza)) * 0.035 * sila
	os_kamery.rotation = Vector3(_pitch + _kop.x + buj.x, _kop.y + buj.y, 0.0)


func _ogranicz_wychylenie(w: float) -> float:
	if absf(w) < 0.01:
		return 0.0
	var start := global_position + Vector3.UP * szyja.position.y
	var bok := -global_transform.basis.x * signf(w)
	var q := PhysicsRayQueryParameters3D.create(start, start + bok * (BOK_WYCHYLENIA + 0.25))
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return w
	var d: float = start.distance_to(hit["position"]) - 0.25
	return w * clampf(d / BOK_WYCHYLENIA, 0.0, 1.0)


## Odrzut kamery: impuls w radianach na sekundę (w górę, w bok).
func kopniecie(pion: float, bok: float) -> void:
	var s: float = Strojenie.w["S_KAMERA_ODRZUT"]
	_kop_v += Vector2(pion, bok) * s
	# część odrzutu zostaje na stałe: lufa „wspina się” przy ogniu ciągłym
	_pitch = clampf(_pitch + pion * 0.0035 * s, -1.48, 1.48)
