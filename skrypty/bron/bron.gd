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
		"dzw_strzal": "strzal_556", "skok_zamka": 0.07, "zoom": 0.84, "zamek_zostaje": false, "szyna": Vector3(0, 0.11, 0.0395),
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
	"weteran": {
		"nazwa": "BRON_WETERAN", "kaliber": ".45", "rpm": 380.0,
		"tryby": ["TRYB_POJ"], "masa": 1.1, "dlugosc": 0.52,
		"odrzut_pion": 2.5, "odrzut_bok": 0.8, "odrzut_tyl": 0.9, "odrzut_kamera": 0.95,
		"czas_celu": 0.21, "poj": 7, "amunicja": "A_45_FMJ",
		"model": "res://zasoby/modele/weteran.glb",
		"biodro": Vector3(0.085, -0.135, -0.40), "biodro_rot": Vector3(0.0, 0.03, -0.04),
		"t_takt": 2.3, "t_szybkie": 1.6, "rozrzut_moa": 7.0,
		"dzw_strzal": "strzal_45", "skok_zamka": 0.038, "zoom": 0.92, "zamek_zostaje": true,
		"luska": Vector3(0.012, 0.012, 0.023),
	},
	"gabro": {
		"nazwa": "BRON_GABRO", "kaliber": "9x19", "rpm": 640.0,
		"tryby": ["TRYB_POJ", "TRYB_SERIA"], "masa": 2.2, "dlugosc": 0.58,
		"odrzut_pion": 0.75, "odrzut_bok": 0.5, "odrzut_tyl": 0.7, "odrzut_kamera": 0.35,
		"czas_celu": 0.24, "poj": 25, "amunicja": "A_9_FMJ",
		"model": "res://zasoby/modele/gabro.glb",
		"biodro": Vector3(0.095, -0.150, -0.30), "biodro_rot": Vector3(0.0, 0.04, -0.06),
		"t_takt": 2.5, "t_szybkie": 1.8, "rozrzut_moa": 4.0,
		"dzw_strzal": "strzal_9", "skok_zamka": 0.05, "zoom": 0.88, "zamek_zostaje": false, "szyna": Vector3(0, 0.11, 0.024),
		"luska": Vector3(0.0095, 0.0095, 0.019),
	},
	"granit": {
		"nazwa": "BRON_GRANIT", "kaliber": "7.62x39", "rpm": 600.0,
		"tryby": ["TRYB_POJ", "TRYB_SERIA"], "masa": 3.3, "dlugosc": 0.72,
		"odrzut_pion": 1.35, "odrzut_bok": 0.8, "odrzut_tyl": 1.15, "odrzut_kamera": 0.75,
		"czas_celu": 0.31, "poj": 30, "amunicja": "A_762_PS",
		"model": "res://zasoby/modele/granit.glb",
		"biodro": Vector3(0.105, -0.158, -0.225), "biodro_rot": Vector3(0.0, 0.045, -0.06),
		"t_takt": 3.0, "t_szybkie": 2.1, "rozrzut_moa": 3.5,
		"dzw_strzal": "strzal_762", "skok_zamka": 0.075, "zoom": 0.84, "zamek_zostaje": false, "szyna": Vector3(0, 0.11, 0.036),
		"luska": Vector3(0.0065, 0.0065, 0.039),
	},
	"lupek": {
		"nazwa": "BRON_LUPEK", "kaliber": "12/70", "rpm": 70.0,
		"tryby": ["TRYB_POJ"], "masa": 3.6, "dlugosc": 0.82,
		"odrzut_pion": 2.6, "odrzut_bok": 0.9, "odrzut_tyl": 2.0, "odrzut_kamera": 1.6,
		"czas_celu": 0.33, "poj": 6, "amunicja": "A_12_SRUT", "rurowy": true, "repetowanie": 0.55,
		"model": "res://zasoby/modele/lupek.glb",
		"biodro": Vector3(0.105, -0.152, -0.20), "biodro_rot": Vector3(0.0, 0.045, -0.06),
		"t_naboj": 0.55, "rozrzut_moa": 8.0, "rozrzut_srutu": 0.045,
		"dzw_strzal": "strzal_12", "skok_zamka": 0.0, "zoom": 0.88, "zamek_zostaje": false,
		"luska": Vector3(0.020, 0.020, 0.07),
	},
	"krzemien": {
		"nazwa": "BRON_KRZEMIEN", "kaliber": "7.62x51", "rpm": 60.0,
		"tryby": ["TRYB_POJ"], "masa": 6.0, "dlugosc": 0.92,
		"odrzut_pion": 2.0, "odrzut_bok": 0.5, "odrzut_tyl": 1.6, "odrzut_kamera": 1.25,
		"czas_celu": 0.42, "poj": 10, "amunicja": "A_76251_FMJ", "repetowanie": 1.0, "luneta": 4.0,
		"okular": Vector3(0, 0.0, 0.058), "obiektyw": Vector3(0, 0.37, 0.058), "r_soczewki": 0.0185,
		"model": "res://zasoby/modele/krzemien.glb",
		"biodro": Vector3(0.105, -0.155, -0.24), "biodro_rot": Vector3(0.0, 0.045, -0.06),
		"t_takt": 3.2, "t_szybkie": 2.4, "rozrzut_moa": 0.8,
		"dzw_strzal": "strzal_76251", "skok_zamka": 0.075, "zoom": 0.84, "zamek_zostaje": false,
		"luska": Vector3(0.0075, 0.0075, 0.051),
	},
}
const GLOWNE := ["kwarc", "granit", "gabro", "lupek", "krzemien"]
const BOCZNE := ["jaspis", "weteran"]


class Sprezyna:
	var x := Vector3.ZERO
	var v := Vector3.ZERO

	func krok(dt: float, k: float, c: float) -> void:
		var n := maxi(1, ceili(dt * 240.0))
		var h := dt / n
		for i in n:
			v += (-k * x - c * v) * h
			x += v * h


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
var _n_czolenko: Node3D
var _poz_czolenko := Vector3.ZERO
var _repet_t := 0.0              ## trwające repetowanie (czółenko, zamek czterotaktowy)
var typ_ladowany := ""           ## strzelba: rodzaj naboju dokładanego do rury
var luneta := 0.0                ## 0..1: jak bardzo celownik optyczny zasłania widok
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
var _dym: CPUParticles3D
var zaciecie := false            ## nabój nie wszedł do komory; R usuwa
var chwyt := false               ## chwyt przedni: mniejszy odrzut, szybsze składanie
var _latarka: SpotLight3D
var _okno_r := 0.0
var _fov_bazowe := 72.0
var test_cel := -1.0             ## tylko do zrzutów testowych: wymusza celowanie


func przygotuj(id_broni: String, wlasciciel: Gracz) -> void:
	id = id_broni
	d = DANE[id]
	gracz = wlasciciel
	_wczytaj_model()
	var st: Dictionary = Ekwipunek.stan(id)
	komora = st["komora"]
	_ustaw_mag(st["mag"])
	typ_ladowany = d["amunicja"]
	_zamontuj_dodatki()
	if d.has("luneta"):
		_zbuduj_lunete()
	_zbuduj_blysk()
	_zbuduj_dym()
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
	_n_czolenko = _znajdz("czolenko", Vector3.ZERO)
	_poz_czolenko = _n_czolenko.position
	_poz_mag = _n_mag.position
	_poz_zamek = _n_zamek.position
	_poz_reka_l = _n_reka_l.position
	_poz_cel = -_pozycja_w_modelu(_celownik)
	for s in _model.find_children("*", "MeshInstance3D", true, false):
		(s as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		(s as MeshInstance3D).extra_cull_margin = 2.0
		(s as MeshInstance3D).layers = 2          # warstwa 2: broń; kamera lunety jej nie rysuje
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


## Dym z wylotu: kilka szarych kłębków po każdym strzale, gęstszy przy tłumiku.
func _zbuduj_dym() -> void:
	_dym = CPUParticles3D.new()
	_dym.emitting = false
	_dym.one_shot = true
	_dym.amount = 7
	_dym.lifetime = 1.1
	_dym.explosiveness = 0.9
	_dym.local_coords = false
	_dym.direction = Vector3(0, 0.15, -1)
	_dym.spread = 22.0
	_dym.initial_velocity_min = 0.25
	_dym.initial_velocity_max = 0.9
	_dym.gravity = Vector3(0, 0.35, 0)
	_dym.damping_min = 1.2
	_dym.damping_max = 2.0
	_dym.scale_amount_min = 0.5
	_dym.scale_amount_max = 1.2
	var krzywa := Curve.new()
	krzywa.add_point(Vector2(0, 0.25))
	krzywa.add_point(Vector2(1, 1.0))
	_dym.scale_amount_curve = krzywa
	var grad := Gradient.new()
	grad.set_color(0, Color(0.75, 0.74, 0.72, 0.13))
	grad.set_color(1, Color(0.6, 0.6, 0.6, 0.0))
	_dym.color_ramp = grad
	var qm := QuadMesh.new()
	qm.size = Vector2(0.08, 0.08)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.vertex_color_use_as_albedo = true
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.no_depth_test = false
	qm.material = mat
	_dym.mesh = qm
	_dym.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_wylot.add_child(_dym)


func zuzycie() -> float:
	return float(Ekwipunek.stan(id).get("zuzycie", 0.0))


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


const SHADER_KOLIMATORA := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec3 os = vec3(0.0, 0.0, -1.0);
uniform float pierscien = 0.0;
void fragment() {
	float kat = length(normalize(VERTEX) - normalize(os));
	float kropka = 1.0 - smoothstep(0.0009, 0.0017, kat);
	float kolo = pierscien * (1.0 - smoothstep(0.0006, 0.0013, abs(kat - 0.0098)));
	float kreski = pierscien * step(0.0098, kat) * step(kat, 0.0125) * step(min(abs(normalize(VERTEX).x - normalize(os).x), abs(normalize(VERTEX).y - normalize(os).y)), 0.0007);
	float znak = max(kropka, max(kolo, kreski));
	ALBEDO = mix(vec3(0.20, 0.30, 0.27), vec3(1.0, 0.10, 0.05) * 2.6, znak);
	ALPHA = max(znak, 0.08);
}
"""
const SHADER_LUNETY := """
shader_type spatial;
render_mode unshaded;
uniform sampler2D obraz : source_color, filter_nearest;
uniform vec2 przes = vec2(0.0);
uniform float wl = 0.0;
void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	if (length(p) > 1.0) { discard; }
	vec3 c = texture(obraz, UV).rgb;
	float cien = smoothstep(0.72, 0.98, length(p - przes));
	float cienka = max(step(abs(p.x), 0.005), step(abs(p.y), 0.005));
	float gruba = max(step(abs(p.x), 0.020) * step(0.42, abs(p.y)), step(abs(p.y), 0.020) * step(0.42, abs(p.x)));
	float kropki = 0.0;
	for (int i = 1; i <= 3; i++) {
		float o = float(i) * 0.105;
		kropki = max(kropki, 1.0 - step(0.013, min(min(length(p - vec2(o, 0.0)), length(p + vec2(o, 0.0))), min(length(p - vec2(0.0, o)), length(p + vec2(0.0, o))))));
	}
	vec3 w = mix(c, vec3(0.0), max(max(cienka, gruba), max(kropki, cien)));
	ALBEDO = mix(vec3(0.012, 0.025, 0.032), w, wl);
}
"""

var _mat_kolimatora: ShaderMaterial
var _mat_lunety: ShaderMaterial
var _widok_lunety: SubViewport
var _kam_lunety: Camera3D
var _cel_spr := 0.0              ## sprężyna składania się do strzału (lekki przestrzał na końcu)
var _cel_spr_v := 0.0
var _ruch_lag := Vector3.ZERO    ## opóźnienie broni za ruchem ciała
var _seria := 0.0                ## licznik strzałów w serii; opada po przerwie
var _dryf := 0.0                 ## wędrówka odrzutu na boki w serii
var oddech := false              ## wstrzymany oddech


## Luneta z własnym obrazem: osobna kamera patrzy wzdłuż osi lunety, a jej obraz
## trafia na soczewkę okularu. Reszta ekranu nie jest przybliżana.
func _zbuduj_lunete() -> void:
	_widok_lunety = SubViewport.new()
	_widok_lunety.size = Vector2i(320, 320)
	_widok_lunety.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_widok_lunety.msaa_3d = Viewport.MSAA_DISABLED
	add_child(_widok_lunety)
	_kam_lunety = Camera3D.new()
	_kam_lunety.cull_mask = 0xFFFFF & ~2       # bez warstwy broni
	_kam_lunety.near = 0.1
	_kam_lunety.far = 900.0
	var ok: Vector3 = d["okular"]
	var r: float = d["r_soczewki"]
	var oko: float = absf(_poz_cel.z) - ok.y       # odległość oka od okularu
	_kam_lunety.fov = rad_to_deg(2.0 * atan(r / maxf(oko, 0.02))) / float(d["luneta"])
	_widok_lunety.add_child(_kam_lunety)
	var soczewka := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(r * 2.0, r * 2.0)
	soczewka.mesh = qm
	var sh := Shader.new()
	sh.code = SHADER_LUNETY
	_mat_lunety = ShaderMaterial.new()
	_mat_lunety.shader = sh
	_mat_lunety.set_shader_parameter("obraz", _widok_lunety.get_texture())
	soczewka.material_override = _mat_lunety
	soczewka.position = Vector3(ok.x, ok.z, -ok.y + 0.0048)
	_ustaw_czesc(soczewka)
	_model.add_child(soczewka)


var tlumik := false
var kolimator := false


## Buduje na modelu zamontowane dodatki: tłumik na wylocie, kolimator na szynie.
func _zamontuj_dodatki() -> void:
	var metal := Mat.kolor(Color("1b1c1e"), 0.55, 0.6)
	var id_tl := Ekwipunek.ma_dodatek(id, "wylot")
	if id_tl != "":
		tlumik = true
		var dl := 0.17 if id_tl == "tlumik_kar" else 0.13
		var s := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.019 if id_tl == "tlumik_kar" else 0.016
		cm.bottom_radius = cm.top_radius
		cm.height = dl
		cm.radial_segments = 10
		cm.rings = 1
		s.mesh = cm
		s.material_override = metal
		s.rotation.x = PI * 0.5
		s.position = Vector3(0, 0, -dl * 0.5 + 0.02)
		_ustaw_czesc(s)
		_wylot.add_child(s)
	if Ekwipunek.ma_dodatek(id, "chwyt") != "":
		chwyt = true
		var pw := _pozycja_w_modelu(_wylot)
		var ch := MeshInstance3D.new()
		var cmg := CylinderMesh.new()
		cmg.top_radius = 0.013
		cmg.bottom_radius = 0.015
		cmg.height = 0.085
		cmg.radial_segments = 8
		ch.mesh = cmg
		ch.material_override = metal
		ch.position = Vector3(0, pw.y - 0.075, pw.z * 0.52)
		_ustaw_czesc(ch)
		_model.add_child(ch)
		var podst := MeshInstance3D.new()
		var bmg := BoxMesh.new()
		bmg.size = Vector3(0.022, 0.012, 0.05)
		podst.mesh = bmg
		podst.material_override = metal
		podst.position = Vector3(0, pw.y - 0.030, pw.z * 0.52)
		_ustaw_czesc(podst)
		_model.add_child(podst)
	if Ekwipunek.ma_dodatek(id, "szyna") != "" and d.has("szyna"):
		kolimator = true
		var sz: Vector3 = d["szyna"]
		var k := Node3D.new()
		k.position = Vector3(sz.x, sz.z, -sz.y)       # Blender (x, y, z) -> Godot (x, z, -y)
		_model.add_child(k)
		var id_cel := Ekwipunek.ma_dodatek(id, "szyna")
		var holo := id_cel == "holo"
		var ws := 0.036 if holo else 0.026            # szerokość i wysokość okna
		var hs := 0.027 if holo else 0.022
		var cy := 0.012 + hs * 0.5 + 0.002
		var zo := -0.022 if holo else -0.021
		var czesci := [
			[Vector3(ws + 0.004, 0.012, 0.062 if holo else 0.052), Vector3(0, 0.006, 0)],
			[Vector3(0.003, hs + 0.004, 0.008), Vector3(-(ws + 0.003) * 0.5, cy, zo)],
			[Vector3(0.003, hs + 0.004, 0.008), Vector3((ws + 0.003) * 0.5, cy, zo)],
			[Vector3(ws + 0.006, 0.003, 0.008), Vector3(0, cy + hs * 0.5 + 0.0035, zo)],
			[Vector3(0.006, 0.006, 0.010), Vector3(ws * 0.5 + 0.005, 0.008, 0.012)],      # pokrętło jasności
		]
		if holo:
			# osłona okna: ścianki boczne biegnące do tyłu, jak w celowniku holograficznym
			czesci.append([Vector3(0.003, hs * 0.55, 0.030), Vector3(-(ws + 0.003) * 0.5, 0.012 + hs * 0.275, zo + 0.019)])
			czesci.append([Vector3(0.003, hs * 0.55, 0.030), Vector3((ws + 0.003) * 0.5, 0.012 + hs * 0.275, zo + 0.019)])
		for cz in czesci:
			var si := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = cz[0]
			si.mesh = bm
			si.material_override = metal
			si.position = cz[1]
			_ustaw_czesc(si)
			k.add_child(si)
		# szkło ze znakiem celowniczym rzutowanym w nieskończoność: znak trzyma się osi lufy,
		# a nie szkła, więc przy kołysaniu broni wędruje po oknie jak w prawdziwym kolimatorze
		var szklo := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(ws, hs)
		szklo.mesh = qm
		var sh := Shader.new()
		sh.code = SHADER_KOLIMATORA
		_mat_kolimatora = ShaderMaterial.new()
		_mat_kolimatora.shader = sh
		_mat_kolimatora.set_shader_parameter("pierscien", 1.0 if holo else 0.0)
		szklo.material_override = _mat_kolimatora
		szklo.position = Vector3(0, cy, zo)
		_ustaw_czesc(szklo)
		k.add_child(szklo)
		# oko na wysokości środka okna
		_poz_cel.y = -(sz.z + cy)


func _ustaw_czesc(s: MeshInstance3D) -> void:
	s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	s.extra_cull_margin = 2.0
	s.layers = 2


func _ustaw_mag(p: Dictionary) -> void:
	mag_p = p
	mag = null if p.is_empty() else p["dane"]["naboje"]
	if _n_mag:
		_n_mag.visible = mag != null


## Zapisuje stan broni do ekwipunku (przed zmianą lokacji).
func zapisz_stan() -> void:
	var st := Ekwipunek.stan(id)
	st["mag"] = mag_p
	st["komora"] = komora


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
	var dl: float = (d["dlugosc"] + (0.14 if tlumik else 0.0)) * lerpf(1.0, 0.82, cel)
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
	var wolna := _stan == "" and gracz.zdrowie.uzywa == "" and _repet_t <= 0.0
	var chce_cel := steruje and gracz.zdrowie.uzywa == "" and Input.is_action_pressed("celuj") and not gracz.sprintuje and zablokowana < 0.35 and (_stan == "" or _stan == "okno_r")
	if test_cel >= 0.0:
		chce_cel = test_cel > 0.5
	gracz.celuje = chce_cel and aktywna
	var szybkosc: float = Strojenie.w["S_CELOWANIE"] / (d["czas_celu"] * (0.85 if kolimator else 1.0) * (0.93 if chwyt else 1.0))
	cel = move_toward(cel, 1.0 if chce_cel else 0.0, dt * szybkosc)
	if not steruje:
		return
	if Input.is_action_just_pressed("latarka"):
		_latarka.visible = not _latarka.visible
		Dzwiek.przy_uchu("klik", -6.0)
	if Input.is_action_just_pressed("tryb_ognia") and wolna and d.get("rurowy", false):
		var typy := Amunicja.dla_kalibru(d["kaliber"])
		typ_ladowany = typy[(typy.find(typ_ladowany) + 1) % typy.size()]
		komunikat.emit(tr("LADUJ") + ": " + tr(typ_ladowany))
		Dzwiek.przy_uchu("klik", -4.0)
	elif Input.is_action_just_pressed("tryb_ognia") and wolna and d["tryby"].size() > 1:
		tryb = (tryb + 1) % d["tryby"].size()
		komunikat.emit(tr(d["tryby"][tryb]))
		Dzwiek.przy_uchu("klik", -4.0)
	if Input.is_action_just_pressed("sprawdz_mag") and wolna:
		_zacznij("sprawdz", 1.5, {0.55: "sprawdz"})
	if Input.is_action_just_pressed("przeladuj") and wolna and zaciecie:
		# szarpnięcie zamkiem: zakleszczony nabój wypada, następny wchodzi do komory
		_zacznij("sprawdz", 1.25, {0.35: "odblokuj"})
	elif Input.is_action_just_pressed("przeladuj"):
		if wolna:
			_stan = "okno_r"
			_okno_r = 0.28
		elif _stan == "okno_r":
			_zacznij_przeladowanie(true)
	if _stan == "rura" and Input.is_action_just_pressed("strzal"):
		_stan = ""
	var seria: bool = d["tryby"][tryb] == "TRYB_SERIA"
	var spust := Input.is_action_pressed("strzal") if seria else Input.is_action_just_pressed("strzal")
	if spust and wolna and zaciecie:
		if Input.is_action_just_pressed("strzal"):
			Dzwiek.przy_uchu("suchy", -3.0)
			komunikat.emit(tr("ZACIECIE"))
	elif spust and wolna and _do_strzalu <= 0.0 and not gracz.sprintuje and zablokowana < 0.35 and _wyjecie >= 1.0:
		if komora != "":
			var odstep: float = 60.0 / d["rpm"]
			if not seria:
				_do_strzalu = 0.0
			while _do_strzalu <= 0.0 and komora != "" and not zaciecie:
				_strzal()
				_do_strzalu += odstep
				if not seria:
					break
		elif Input.is_action_just_pressed("strzal"):
			Dzwiek.przy_uchu("suchy", -3.0)
			_do_strzalu = 0.2


var _ost_stan := ""


func _zacznij(stan: String, czas: float, zdarzenia: Dictionary) -> void:
	_ost_stan = stan
	_stan = stan
	_t = 0.0
	_t_max = czas
	_zdarzenia = zdarzenia.duplicate()


## Strzelba: naboje z paczek w kamizelce i kieszeniach, wybranego rodzaju jeśli jest.
func _paczka_do_rury() -> Dictionary:
	var paczki := []
	for poj in Ekwipunek.szybkie():
		for p in poj.rzeczy:
			if p["id"] == Amunicja.paczka(d["kaliber"]) and int(p["dane"]["ile"]) > 0:
				paczki.append(p)
	for p in paczki:
		if p["dane"]["typ"] == typ_ladowany:
			return p
	return paczki[0] if not paczki.is_empty() else {}


func _zacznij_przeladowanie(szybkie: bool) -> void:
	if d.get("rurowy", false):
		if mag.size() >= int(d["poj"]) and komora != "":
			_stan = ""
			return
		if _paczka_do_rury().is_empty():
			_stan = ""
			komunikat.emit(tr("BRAK_NABOI"))
			return
		_zacznij("rura", float(d["t_naboj"]), {0.6: "naboj"})
		return
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
	if _repet_t > 0.0:
		var bylo := _repet_t
		_repet_t = maxf(_repet_t - dt, 0.0)
		var calosc: float = d["repetowanie"]
		if bylo > calosc * 0.5 and _repet_t <= calosc * 0.5:
			Dzwiek.przy_uchu("czolenko" if d.get("rurowy", false) else "zamek", -2.0, 0.08)
			_wyrzuc_luske()
			if mag != null and not mag.is_empty():
				komora = mag.pop_back()
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
		# strzelba ładuje kolejne naboje, dopóki rura nie jest pełna albo gracz nie przerwie
		if _t_max > 0.0 and _ost_stan == "rura" and mag.size() < int(d["poj"]) and not Input.is_action_pressed("strzal"):
			_zacznij_przeladowanie(false)


func _zdarzenie(z: String) -> void:
	match z:
		"odblokuj":
			zaciecie = false
			Dzwiek.przy_uchu("zamek", 0.0, 0.05)
			_zamek_t = 0.12
			if komora == "" and mag != null and not mag.is_empty() and not d.has("repetowanie"):
				komora = mag.pop_back()
			komunikat.emit(tr("ZACIECIE_USUNIETE"))
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
		"naboj":
			var p := _paczka_do_rury()
			if not p.is_empty():
				p["dane"]["ile"] = int(p["dane"]["ile"]) - 1
				if komora == "" and mag.is_empty():
					komora = p["dane"]["typ"]
				else:
					mag.append(p["dane"]["typ"])   # ostatni włożony nabój trafi do komory pierwszy
				if int(p["dane"]["ile"]) <= 0:
					Ekwipunek.wyjmij(p)
				Ekwipunek.zmiana.emit()
				Dzwiek.przy_uchu("klik", -2.0, 0.15)


func _opis_magazynka() -> String:
	if d.get("rurowy", false):
		return "%s: %d / %d · %s" % [tr("RURA"), mag.size(), int(d["poj"]), tr("KOMORA_NABOJ" if komora != "" else "KOMORA_PUSTA")]
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
	if d.has("repetowanie"):
		_repet_t = float(d["repetowanie"])
	elif mag != null and not mag.is_empty():
		komora = mag.pop_back()
	_zamek_t = 0.07
	# zużycie: każda sztuka amunicji brudzi i wybija mechanizm; zaniedbana broń się zacina
	var st := Ekwipunek.stan(id)
	var zuz := minf(float(st.get("zuzycie", 0.0)) + 0.0003 * (1.5 if tlumik else 1.0), 1.0)
	st["zuzycie"] = zuz
	if not d.has("repetowanie") and not d.get("rurowy", false) and test_cel < 0.0:
		var szansa := pow(maxf(zuz - 0.25, 0.0), 2.0) * 0.12
		if randf() < szansa:
			zaciecie = true
			if komora != "":
				mag.append(komora)
				komora = ""
	var dane_a: Dictionary = Amunicja.TYPY[typ]
	# kierunek = oś lufy + rozrzut własny broni
	var baza := _wylot.global_transform.basis
	var rozrzut: float = d["rozrzut_moa"] / 3438.0
	var kat := randf() * TAU
	var r := sqrt(randf()) * rozrzut
	var kier := (-baza.z + baza.x * cos(kat) * r + baza.y * sin(kat) * r).normalized()
	var pociski := get_tree().get_first_node_in_group("pociski")
	if pociski:
		var ile_srutu: int = int(dane_a.get("srut", 1))
		for i in ile_srutu:
			var k := kier
			if ile_srutu > 1:
				var r2: float = float(d.get("rozrzut_srutu", 0.04)) * sqrt(randf())
				var kat2 := randf() * TAU
				k = (kier + baza.x * cos(kat2) * r2 + baza.y * sin(kat2) * r2).normalized()
			pociski.wystrzel(_wylot.global_position, k, typ, gracz)
	# odrzut
	var s: float = Strojenie.w["S_ODRZUT"]
	var postawa := 0.78 if gracz.kuca else 1.0
	var rece := lerpf(1.4, 1.0, gracz.wytrz_rece)
	var w_celu := lerpf(1.0, 0.72, cel)
	var moc := s * postawa * rece * w_celu * Ekwipunek.mod("odrzut") * (0.9 if tlumik else 1.0) * (0.88 if chwyt else 1.0)
	_odrz_poz.v.z += 0.95 * d["odrzut_tyl"] * moc
	_odrz_poz.v.y += 0.12 * d["odrzut_pion"] * moc
	# pierwsze strzały serii kopią najmocniej, potem strzelec „łapie” broń; lufa dryfuje na boki
	var w_serii := lerpf(1.25, 0.82, clampf(_seria / 5.0, 0.0, 1.0))
	_seria += 1.0
	_dryf = _dryf * 0.75 + randf_range(-1.0, 1.0) * 0.55
	_odrz_rot.v.x += 1.05 * d["odrzut_pion"] * moc * w_serii
	_odrz_rot.v.y += _dryf * 0.6 * d["odrzut_bok"] * moc
	_odrz_rot.v.z += randf_range(-1.0, 1.0) * 0.9 * moc
	gracz.kopniecie(d["odrzut_kamera"] * postawa * rece, randf_range(-0.35, 0.35) * d["odrzut_bok"])
	# efekty
	_blysk_t = 0.0 if tlumik else 0.045
	_dym.amount = 10 if tlumik else 7
	_dym.restart()
	_dym.emitting = true
	_blysk.rotation.z = randf() * TAU
	_blysk.scale = Vector3.ONE * randf_range(0.8, 1.25)
	Dzwiek.przy_uchu(d["dzw_strzal"], -13.0 if tlumik else 0.0, 0.035)
	if tlumik:
		Dzwiek.przy_uchu("zamek", -9.0, 0.1)
	var swiat_h := get_tree().get_first_node_in_group("swiat")
	if swiat_h:
		swiat_h.halas(gracz.global_position, 55.0 * float(dane_a["halas"]) * (0.35 if tlumik else 1.0))
	if not d.has("repetowanie"):
		_wyrzuc_luske()
	if swiat_h:
		swiat_h.dodaj_luske(d["kaliber"], gracz.global_position)


func _wyrzuc_luske() -> void:
	var swiat := get_tree().get_first_node_in_group("swiat")
	if swiat == null or not swiat.has_method("luska"):
		return
	var b := global_transform.basis
	var start := global_position + b * Vector3(0.03, 0.05, -0.05)
	var v := gracz.velocity + b.x * randf_range(2.2, 3.2) + b.y * randf_range(1.2, 2.0) + b.z * randf_range(-0.4, 0.6)
	swiat.luska(start, v, d["luska"])


func _poza(dt: float) -> void:
	# składanie się na sprężynie: szybki dojazd i lekki przestrzał zamiast liniowego przejścia
	var kroki := maxi(1, ceili(dt * 240.0))        # małe kroki: sprężyna stabilna przy każdej liczbie klatek
	var h := dt / kroki
	for i in kroki:
		_cel_spr_v += ((cel - _cel_spr) * 420.0 - _cel_spr_v * 34.0) * h
		_cel_spr = clampf(_cel_spr + _cel_spr_v * h, -0.02, 1.025)
	var t_cel := _cel_spr
	_seria = maxf(_seria - dt * 9.0, 0.0) if _do_strzalu <= -0.04 else _seria
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
	# wstrzymany oddech: broń prawie nieruchoma, ale ręce szybko się męczą
	oddech = aktywna and gracz.celuje and gracz.sterowanie and Input.is_action_pressed("oddech") and gracz.wytrz_rece > 0.05
	if oddech:
		amp *= 0.22
		gracz.wytrz_rece = maxf(gracz.wytrz_rece - 0.16 * dt, 0.0)
	# ciało ciągnie broń: przy kroku w bok broń przechyla się i zostaje w tyle, lądowanie ją dobija
	var v_lok := gracz.global_transform.basis.inverse() * gracz.velocity
	_ruch_lag = _ruch_lag.lerp(v_lok, 1.0 - exp(-7.0 * dt))
	var wr := lerpf(1.0, 0.35, clampf(t_cel, 0.0, 1.0))
	rot.z -= _ruch_lag.x * 0.014 * wr
	poz.x -= _ruch_lag.x * 0.0035 * wr
	poz.z += clampf(-_ruch_lag.z, -3.0, 3.0) * 0.0022 * wr
	var ladowanie: float = gracz.get("_ladowanie")
	poz.y -= ladowanie * 0.22
	rot.x -= ladowanie * 0.55
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
	elif _stan == "rura":
		var p := clampf(_t / _t_max, 0.0, 1.0)
		rot += Vector3(0.18, 0.0, 0.55) * pow(sin(p * PI), 0.5)
		poz += Vector3(0.0, -0.02, 0.02) * sin(p * PI)
	elif not d.get("rurowy", false):
		_n_reka_l.position = _n_reka_l.position.lerp(_poz_reka_l, 1.0 - exp(-18.0 * dt))
		_n_mag.position = _poz_mag

	transform = Transform3D(Basis.from_euler(rot), poz)
	if _mat_lunety:
		# cień okularu ucieka, gdy oko schodzi z osi: kołysanie i odrzut przesuwają obraz
		var odch := rot - (d["biodro_rot"] as Vector3).lerp(Vector3.ZERO, clampf(t_cel, 0.0, 1.0))
		_mat_lunety.set_shader_parameter("przes", Vector2(-odch.y, odch.x) * 9.0 + Vector2(poz.x - _poz_cel.x, -(poz.y - _poz_cel.y)) * 28.0 * clampf(t_cel, 0.0, 1.0))
		_mat_lunety.set_shader_parameter("wl", smoothstep(0.55, 0.95, t_cel))

	# lekkie przybliżenie przy celowaniu
	var bazowe: float = Strojenie.w["S_FOV"]
	var zoom: float = d["zoom"]
	if d.has("luneta"):
		zoom = d["zoom"]
	gracz.kamera.fov = lerpf(bazowe, bazowe * zoom, t_cel)
	gracz.przyblizenie = gracz.kamera.fov / bazowe
	if d.has("luneta"):
		gracz.przyblizenie = lerpf(1.0, 1.6 / float(d["luneta"]), clampf(t_cel, 0.0, 1.0))


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
	var rp := 0.0
	if _repet_t > 0.0:
		var calosc: float = d["repetowanie"]
		rp = sin(clampf(1.0 - _repet_t / calosc, 0.0, 1.0) * PI)
	if d.get("rurowy", false):
		_n_czolenko.position = _poz_czolenko + Vector3(0, 0, 0.085 * rp)
		_n_reka_l.position = _poz_reka_l + Vector3(0, 0, 0.085 * rp)
	elif d.has("repetowanie"):
		cofniecie = maxf(cofniecie, rp)
		_n_zamek.rotation.z = -1.1 * clampf(rp * 2.0, 0.0, 1.0)
	_n_zamek.position = _n_zamek.position.lerp(_poz_zamek + Vector3(0, 0, d["skok_zamka"] * cofniecie), 1.0 - exp(-60.0 * dt))
	# luneta: przy pełnym złożeniu model znika, a widok zastępuje nakładka w interfejsie
	if _mat_kolimatora:
		_mat_kolimatora.set_shader_parameter("os", -transform.basis.z)
	if _widok_lunety:
		var patrzy := aktywna and cel > 0.4
		_widok_lunety.render_target_update_mode = SubViewport.UPDATE_ALWAYS if patrzy else SubViewport.UPDATE_DISABLED
		if patrzy:
			var ob: Vector3 = d["obiektyw"]
			# przystrzelana na 100 m: oś lunety lekko pochylona ku torowi pocisku
			_kam_lunety.global_transform = _model.global_transform * Transform3D(Basis.from_euler(Vector3(-0.0013, 0, 0)), Vector3(ob.x, ob.z, -ob.y))
