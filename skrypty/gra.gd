extends Node
## Korzeń gry. Świat 3D rysuje się w niskiej rozdzielczości (ok. 540 linii)
## i jest skalowany bez wygładzania; interfejs zostaje ostry.

const SHADER_OBRAZU := """
shader_type canvas_item;
uniform float sila = 1.0;
uniform float poziomy = 40.0;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	ivec2 p = ivec2(floor(UV / TEXTURE_PIXEL_SIZE));
	int i = (p.x & 3) + (p.y & 3) * 4;
	float b[16] = float[](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
	float d = (b[i] / 16.0 - 0.47) / poziomy;
	vec3 q = floor((c.rgb + d) * poziomy + 0.5) / poziomy;
	COLOR = vec4(mix(c.rgb, q, sila), 1.0);
}
"""

var kontener: SubViewportContainer
var widok: SubViewport
var swiat: Swiat
var nazwa_swiata := ""
var hud: Hud
var _mat_obrazu: ShaderMaterial


func _ready() -> void:
	kontener = SubViewportContainer.new()
	kontener.set_anchors_preset(Control.PRESET_FULL_RECT)
	kontener.stretch = true
	kontener.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	kontener.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = SHADER_OBRAZU
	_mat_obrazu = ShaderMaterial.new()
	_mat_obrazu.shader = sh
	kontener.material = _mat_obrazu
	add_child(kontener)
	widok = SubViewport.new()
	widok.handle_input_locally = false
	widok.audio_listener_enable_3d = true
	widok.msaa_3d = Viewport.MSAA_DISABLED
	widok.positional_shadow_atlas_size = 2048
	kontener.add_child(widok)
	hud = Hud.new()
	add_child(hud)
	var start := "strzelnica"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--swiat="):
			start = a.trim_prefix("--swiat=")
	hud.przygotuj(self)
	_zaladuj_swiat(start)
	_zastosuj_obraz()
	Strojenie.zmieniono.connect(func(k): if k in ["S_PIKSEL", "S_DITHER"]: _zastosuj_obraz())
	Jezyk.zmieniono.connect(func(): swiat.odswiez_napisy(); hud.odswiez())
	var test := Node.new()
	test.set_script(load("res://skrypty/test_zrzut.gd"))
	add_child(test)


## Zmiana lokacji. Wykonywana po zakończeniu bieżącej klatki.
func zmien_swiat(nazwa: String) -> void:
	_zaladuj_swiat.call_deferred(nazwa)


func _zaladuj_swiat(nazwa: String) -> void:
	if swiat != null:
		hud.zamknij_panele()
		widok.remove_child(swiat)
		swiat.free()
	nazwa_swiata = nazwa
	swiat = Kopalnia.new() if nazwa == "kopalnia" else Strzelnica.new()
	widok.add_child(swiat)
	for b in swiat.bronie:
		b.komunikat.connect(hud.komunikat)
	var z := swiat.gracz.zdrowie
	z.komunikat.connect(hud.komunikat)
	z.obrazenie.connect(hud.obrazenie)
	z.smierc.connect(_smierc)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if nazwa == "kopalnia":
		hud.komunikat(tr("KOPALNIA"))


func _smierc() -> void:
	hud.pokaz_smierc()
	await get_tree().create_timer(5.0).timeout
	hud.ukryj_smierc()
	zmien_swiat("strzelnica")


func _zastosuj_obraz() -> void:
	var linie: float = Strojenie.w["S_PIKSEL"]
	kontener.stretch_shrink = clampi(roundi(1080.0 / linie), 1, 3)
	_mat_obrazu.set_shader_parameter("sila", Strojenie.w["S_DITHER"])


func _unhandled_input(ev: InputEvent) -> void:
	if swiat != null and not hud.panel_otwarty():
		swiat.gracz.wejscie(ev)
	if ev.is_action_pressed("wyjdz"):
		if hud.zamknij_panele():
			return
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif ev is InputEventMouseButton and ev.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not hud.panel_otwarty():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
	elif ev.is_action_pressed("strojenie"):
		hud.przelacz_strojenie()
	elif ev.is_action_pressed("jezyk"):
		Jezyk.przelacz()
	elif ev.is_action_pressed("pomoc"):
		hud.przelacz_pomoc()
	elif hud.panel_otwarty():
		return
	elif ev.is_action_pressed("bron_1"):
		swiat.zmien_bron(0)
	elif ev.is_action_pressed("bron_2"):
		swiat.zmien_bron(1)
	elif ev.is_action_pressed("wyczysc"):
		swiat.wyczysc()
		hud.komunikat(tr("TARCZE_WYCZYSZCZONE"))
	elif ev.is_action_pressed("uzyj"):
		var m := swiat.magazynek_w_zasiegu()
		if m != null:
			for b in swiat.bronie:
				if b.id == m.get("id_broni"):
					b.oddaj_magazynek(m.get("naboje"))
			m.queue_free()
		else:
			swiat.uzyj(self)
	else:
		for i in Zdrowie.KOLEJNOSC.size():
			if ev.is_action_pressed("lek_%d" % (i + 1)):
				swiat.gracz.zdrowie.zacznij_uzycie(Zdrowie.KOLEJNOSC[i])
