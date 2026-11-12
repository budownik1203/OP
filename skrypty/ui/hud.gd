class_name Hud
extends CanvasLayer
## Interfejs minimalny: bez krzyżyka, bez licznika naboi, bez minimapy.

var gra: Node
var _komunikat: Label
var _kom_t := 0.0
var _podpowiedz: Label
var _wskazowka: Label
var _wsk_t := 10.0
var _pasek_nogi: ProgressBar
var _pasek_rece: ProgressBar
var _et_nogi: Label
var _et_rece: Label
var _tempo: Label
var _tempo_t := 0.0
var _ost_tempo := -1.0
var _panel_stroj: PanelContainer
var _panel_pomoc: PanelContainer
var _panel_stol: PanelContainer
var _pomoc_tekst: Label
var _suwaki := {}
var _korzen: Control
var ekwipunek: EkwipunekUI
var _cialo := {}
var _stany: Label
var _leki: Label
var _pasek_uzycia: ProgressBar
var _blysk: ColorRect
var _blysk_a := 0.0
var _smierc: ColorRect
var _smierc_tekst: Label
var _potrzeby: Label
var _luneta: ColorRect
var _budzenie: Array[ColorRect] = []
var _panel_odprawa: PanelContainer
var _panel_biwak: PanelContainer
var baza: BazaUI
var modyfikacje: ModyfikacjeUI


func przygotuj(g: Node) -> void:
	gra = g
	_korzen = Control.new()
	_korzen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_korzen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_korzen)
	_komunikat = _etykieta(26, Color("e6dcc0"))
	_umiesc(_komunikat, Control.PRESET_CENTER_BOTTOM, -500, -190, 1000, 40)
	_komunikat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_komunikat.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_podpowiedz = _etykieta(22, Color("d8c9a0"))
	_umiesc(_podpowiedz, Control.PRESET_CENTER, -400, 120, 800, 30)
	_podpowiedz.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wskazowka = _etykieta(20, Color("d8c9a0"))
	_umiesc(_wskazowka, Control.PRESET_TOP_LEFT, 28, 22, 900, 30)
	_tempo = _etykieta(18, Color("d8c9a0"))
	_umiesc(_tempo, Control.PRESET_BOTTOM_LEFT, 30, -128, 300, 24)
	_pasek_nogi = _pasek(Color("8a9a5b"))
	_umiesc(_pasek_nogi, Control.PRESET_BOTTOM_LEFT, 92, -84, 170, 8)
	_pasek_rece = _pasek(Color("b08d57"))
	_umiesc(_pasek_rece, Control.PRESET_BOTTOM_LEFT, 92, -60, 170, 8)
	_et_nogi = _etykieta(15, Color("d8c9a0"))
	_umiesc(_et_nogi, Control.PRESET_BOTTOM_LEFT, 30, -94, 60, 20)
	_et_rece = _etykieta(15, Color("d8c9a0"))
	_umiesc(_et_rece, Control.PRESET_BOTTOM_LEFT, 30, -70, 60, 20)
	_zbuduj_zdrowie()
	# baza 2D zakrywa widżety gry; ekwipunek, panele i komunikaty rysują się nad nią
	baza = BazaUI.new()
	baza.gra = gra
	baza.hud = self
	_korzen.add_child(baza)
	ekwipunek = EkwipunekUI.new()
	ekwipunek.gra = gra
	_korzen.add_child(ekwipunek)
	modyfikacje = ModyfikacjeUI.new()
	modyfikacje.hud = self
	_korzen.add_child(modyfikacje)
	_komunikat.z_index = 50
	Ikony.przygotuj_bron(self)
	_zbuduj_pomoc()
	_zbuduj_strojenie()
	odswiez()


## Sylwetka ze strefami ciała, lista ran, leki, pasek użycia, błysk bólu, ekran śmierci.
func _zbuduj_zdrowie() -> void:
	_blysk = ColorRect.new()
	_blysk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_blysk.color = Color(0.45, 0.0, 0.0, 0.0)
	_blysk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_korzen.add_child(_blysk)
	_korzen.move_child(_blysk, 0)
	var sylw := Control.new()
	_umiesc(sylw, Control.PRESET_BOTTOM_LEFT, 34, -330, 80, 165)
	sylw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_korzen.add_child(sylw)
	var czesci := {
		"glowa": Rect2(27, 0, 22, 24), "tors": Rect2(18, 27, 40, 58),
		"reka_p": Rect2(2, 28, 13, 62), "reka_l": Rect2(61, 28, 13, 62),
		"noga_p": Rect2(18, 88, 18, 72), "noga_l": Rect2(40, 88, 18, 72),
	}
	for k in czesci:
		var r := ColorRect.new()
		r.position = czesci[k].position
		r.size = czesci[k].size
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sylw.add_child(r)
		_cialo[k] = r
	_stany = _etykieta(18, Color("d9a05a"))
	_umiesc(_stany, Control.PRESET_BOTTOM_LEFT, 124, -326, 500, 160)
	_leki = _etykieta(17, Color("bdb59c"))
	_umiesc(_leki, Control.PRESET_BOTTOM_RIGHT, -430, -170, 400, 140)
	_leki.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_pasek_uzycia = _pasek(Color("b9b08f"))
	_umiesc(_pasek_uzycia, Control.PRESET_CENTER, -150, 170, 300, 10)
	# nakładka lunety: czarna maska z okręgiem i krzyżem
	_luneta = ColorRect.new()
	_luneta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_luneta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform float sila = 1.0;
uniform float proporcje = 1.777;
void fragment() {
	vec2 p = (UV - 0.5) * vec2(proporcje, 1.0);
	float r = length(p);
	float poza = smoothstep(0.40, 0.412, r);
	float cienki = max(step(abs(p.x), 0.0011), step(abs(p.y), 0.0011));
	float gruby = max(step(abs(p.x), 0.0045) * step(0.13, abs(p.y)), step(abs(p.y), 0.0045) * step(0.13, abs(p.x)));
	COLOR = vec4(0.0, 0.0, 0.0, max(poza, max(cienki, gruby) * step(r, 0.40)) * sila);
}
"""
	var msh := ShaderMaterial.new()
	msh.shader = sh
	_luneta.material = msh
	_luneta.visible = false
	_korzen.add_child(_luneta)
	_korzen.move_child(_luneta, 1)
	_potrzeby = _etykieta(17, Color("d9a05a"))
	_umiesc(_potrzeby, Control.PRESET_BOTTOM_LEFT, 34, -158, 400, 44)
	# Przebudzenie lochu: cztery znaczniki w prawym górnym rogu
	for i in 4:
		var zn := ColorRect.new()
		zn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_korzen.add_child(zn)
		_umiesc(zn, Control.PRESET_TOP_RIGHT, -130 + i * 24, 26, 16, 16)
		_budzenie.append(zn)
	_smierc = ColorRect.new()
	_smierc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_smierc.color = Color(0.03, 0.0, 0.0, 0.0)
	_smierc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_smierc.visible = false
	_korzen.add_child(_smierc)
	_smierc_tekst = Label.new()
	_smierc_tekst.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_smierc_tekst.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_smierc_tekst.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_smierc_tekst.add_theme_font_size_override("font_size", 44)
	_smierc_tekst.add_theme_color_override("font_color", Color("b33a2e"))
	_smierc.add_child(_smierc_tekst)


func obrazenie(_strefa: String, ile: float) -> void:
	_blysk_a = clampf(_blysk_a + ile / 45.0, 0.25, 0.8)


func pokaz_smierc() -> void:
	_smierc.visible = true
	_smierc_tekst.text = tr("POLEGL") + "\n\n" + tr("POLEGL_OPIS")
	var tw := create_tween()
	tw.tween_property(_smierc, "color:a", 0.93, 1.6)


func ukryj_smierc() -> void:
	_smierc.visible = false
	_smierc.color.a = 0.0
	_blysk_a = 0.0


func _odswiez_zdrowie(dt: float) -> void:
	var z: Zdrowie = gra.swiat.gracz.zdrowie
	for k in _cialo:
		var u: float = z.hp[k] / Zdrowie.MAKS[k]
		var kolor := Color(0.05, 0.05, 0.05, 0.85)
		if u > 0.0:
			kolor = Color("7c1f17").lerp(Color("6f7a5a"), u)
			kolor.a = 0.85
		if z.zlamania.has(k):
			kolor = kolor.lerp(Color("d9a05a"), 0.5 + 0.3 * sin(Time.get_ticks_msec() * 0.008))
		_cialo[k].color = kolor
	var linie := []
	if z.krwawienie_ciezkie:
		linie.append(tr("STAN_KRWOTOK"))
	if z.krwawienie_lekkie > 0:
		linie.append("%s ×%d" % [tr("STAN_KRWAWIENIE"), z.krwawienie_lekkie])
	for k in z.zlamania:
		linie.append("%s: %s" % [tr("STAN_ZLAMANIE"), tr("C_" + k)])
	if z.odczuwany_bol() > 0.25:
		linie.append(tr("STAN_BOL"))
	if z.znieczulenie > 0.0:
		linie.append(tr("STAN_ZNIECZULENIE"))
	_stany.text = "\n".join(linie)
	var l := []
	for i in Zdrowie.KOLEJNOSC.size():
		var id: String = Zdrowie.KOLEJNOSC[i]
		l.append("%s ×%d   [%d]" % [tr(Zdrowie.LEKI[id][0]), z.leki[id], i + 4])
	_leki.text = "\n".join(l)
	_pasek_uzycia.visible = z.uzywa != ""
	if z.uzywa == "czynnosc" and not panel_otwarty():
		_podpowiedz.text = tr(z.czynnosc_nazwa) + "…"
	if z.uzywa != "":
		_pasek_uzycia.value = z.uzycie_t / z.uzycie_max
	var sila_l: float = gra.swiat.bron().luneta
	_luneta.visible = sila_l > 0.02
	if _luneta.visible:
		(_luneta.material as ShaderMaterial).set_shader_parameter("sila", sila_l)
		(_luneta.material as ShaderMaterial).set_shader_parameter("proporcje", _korzen.size.x / maxf(_korzen.size.y, 1.0))
	var potrzeby := []
	if Ekwipunek.sytosc < 60.0:
		potrzeby.append("%s %d%%" % [tr("GLOD"), roundi(100.0 - Ekwipunek.sytosc)])
	if Ekwipunek.nawodnienie < 60.0:
		potrzeby.append("%s %d%%" % [tr("PRAGNIENIE"), roundi(100.0 - Ekwipunek.nawodnienie)])
	_potrzeby.text = " · ".join(potrzeby)
	_potrzeby.add_theme_color_override("font_color", Color("c94b3a") if z.niedobor() > 0.0 else Color("d9a05a"))
	var w_lochu: bool = gra.swiat is Kopalnia
	for i in 4:
		_budzenie[i].visible = w_lochu
		if w_lochu:
			var k: Kopalnia = gra.swiat
			var pelny := k.przebudzenie >= (i + 1) * 25.0
			var czesc := clampf((k.przebudzenie - i * 25.0) / 25.0, 0.0, 1.0)
			_budzenie[i].color = Color("b33a2e") if pelny else Color(0.25, 0.23, 0.2, 0.35 + 0.4 * czesc)
	_blysk_a = maxf(_blysk_a - dt * 0.9, 0.0)
	var stale := z.odczuwany_bol() * 0.12 + (0.06 if z.krwawienie_ciezkie else 0.0)
	_blysk.color.a = clampf(_blysk_a + stale, 0.0, 0.8)


## Ustawia kontrolkę względem kotwicy: x, y to odsunięcie lewego górnego rogu.
func _umiesc(c: Control, kotwica: int, x: float, y: float, w: float, h: float) -> void:
	c.set_anchors_preset(kotwica)
	c.offset_left = x
	c.offset_top = y
	c.offset_right = x + w
	c.offset_bottom = y + h


func _etykieta(rozmiar: int, kolor: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", rozmiar)
	l.add_theme_color_override("font_color", kolor)
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 0.95))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_korzen.add_child(l)
	return l


func _pasek(kolor: Color) -> ProgressBar:
	var p := ProgressBar.new()
	p.min_value = 0.0
	p.max_value = 1.0
	p.show_percentage = false
	var tlo := StyleBoxFlat.new()
	tlo.bg_color = Color(0.03, 0.03, 0.03, 0.7)
	var wyp := StyleBoxFlat.new()
	wyp.bg_color = kolor
	p.add_theme_stylebox_override("background", tlo)
	p.add_theme_stylebox_override("fill", wyp)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_korzen.add_child(p)
	return p


func _styl_panelu() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.045, 0.045, 0.05, 0.93)
	s.border_color = Color("5a5140")
	s.set_border_width_all(2)
	s.set_content_margin_all(26)
	return s


func _panel(szer: float) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _styl_panelu())
	p.set_anchors_preset(Control.PRESET_CENTER)
	p.custom_minimum_size = Vector2(szer, 0)
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.grow_vertical = Control.GROW_DIRECTION_BOTH
	p.visible = false
	_korzen.add_child(p)
	return p


func _naglowek(tekst: String) -> Label:
	var l := Label.new()
	l.text = tekst
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color("e6dcc0"))
	return l


func _zbuduj_pomoc() -> void:
	_panel_pomoc = _panel(560)
	var v := VBoxContainer.new()
	_panel_pomoc.add_child(v)
	var n := _naglowek("")
	n.name = "naglowek"
	v.add_child(n)
	_pomoc_tekst = Label.new()
	_pomoc_tekst.add_theme_font_size_override("font_size", 21)
	_pomoc_tekst.add_theme_color_override("font_color", Color("cfc6ad"))
	v.add_child(_pomoc_tekst)


func _zbuduj_strojenie() -> void:
	_panel_stroj = _panel(720)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_panel_stroj.add_child(v)
	var n := _naglowek("")
	n.name = "naglowek"
	v.add_child(n)
	for k in Strojenie.DEF:
		var h := HBoxContainer.new()
		var l := Label.new()
		l.custom_minimum_size = Vector2(300, 0)
		l.add_theme_font_size_override("font_size", 20)
		l.set_meta("klucz", k)
		h.add_child(l)
		var s := HSlider.new()
		s.min_value = Strojenie.DEF[k][1]
		s.max_value = Strojenie.DEF[k][2]
		s.step = Strojenie.DEF[k][3]
		s.value = Strojenie.w[k]
		s.custom_minimum_size = Vector2(300, 26)
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(s)
		var wart := Label.new()
		wart.custom_minimum_size = Vector2(70, 0)
		wart.add_theme_font_size_override("font_size", 20)
		wart.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		wart.text = _fmt(Strojenie.w[k])
		h.add_child(wart)
		s.value_changed.connect(func(x: float): Strojenie.ustaw(k, x); wart.text = _fmt(x))
		_suwaki[k] = [l, s, wart]
		v.add_child(h)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	var b1 := Button.new()
	b1.name = "przywroc"
	b1.add_theme_font_size_override("font_size", 20)
	b1.pressed.connect(func():
		Strojenie.przywroc()
		for k in _suwaki:
			_suwaki[k][1].set_value_no_signal(Strojenie.w[k])
			_suwaki[k][2].text = _fmt(Strojenie.w[k]))
	hb.add_child(b1)
	var b2 := Button.new()
	b2.name = "zamknij"
	b2.add_theme_font_size_override("font_size", 20)
	b2.pressed.connect(przelacz_strojenie)
	hb.add_child(b2)
	v.add_child(hb)


func _fmt(x: float) -> String:
	return str(int(x)) if absf(x) >= 10.0 else "%.2f" % x


func odswiez() -> void:
	_wskazowka.text = tr("TYTUL") + " · 0.1 / build 7b · " + tr("PODPOWIEDZ_H")
	_et_nogi.text = tr("WYTRZ_NOGI")
	_et_rece.text = tr("WYTRZ_RECE")
	(_panel_pomoc.find_child("naglowek", true, false) as Label).text = tr("POMOC")
	_pomoc_tekst.text = tr("POMOC_TRESC")
	(_panel_stroj.find_child("naglowek", true, false) as Label).text = tr("STROJENIE") + " — " + tr("STRZELNICA")
	(_panel_stroj.find_child("przywroc", true, false) as Button).text = tr("PRZYWROC")
	(_panel_stroj.find_child("zamknij", true, false) as Button).text = tr("ZAMKNIJ")
	for k in _suwaki:
		_suwaki[k][0].text = tr(k)


func komunikat(tekst: String, czas := 2.8) -> void:
	_komunikat.text = tekst
	_kom_t = czas


func panel_otwarty() -> bool:
	return _panel_stroj.visible or _panel_pomoc.visible or ekwipunek.visible or modyfikacje.visible or (_panel_stol != null and _panel_stol.visible) or (_panel_odprawa != null and _panel_odprawa.visible) or (_panel_biwak != null and _panel_biwak.visible) or (_panel_rzem != null and _panel_rzem.visible) or (_panel_pluton != null and _panel_pluton.visible)


func zamknij_panele() -> bool:
	if not panel_otwarty():
		return false
	if _panel_stroj.visible:
		Strojenie.zapisz()
	_panel_stroj.visible = false
	_panel_pomoc.visible = false
	if ekwipunek.visible:
		ekwipunek.zamknij()
	modyfikacje.visible = false
	if _panel_stol:
		_panel_stol.visible = false
	if _panel_odprawa:
		_panel_odprawa.visible = false
	if _panel_biwak:
		_panel_biwak.visible = false
	if _panel_rzem:
		_panel_rzem.visible = false
	if _panel_pluton:
		_panel_pluton.visible = false
	_wroc_do_gry()
	return true


func _wroc_do_gry() -> void:
	if baza.visible:
		# w bazie nie ma do czego wracać: zostaje kursor i ekran bazy
		gra.swiat.gracz.sterowanie = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		baza.odswiez()
		return
	gra.swiat.gracz.sterowanie = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func otworz_modyfikacje(id_broni: String) -> void:
	zamknij_panele()
	modyfikacje.otworz(id_broni)
	gra.swiat.gracz.sterowanie = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _otworz(p: PanelContainer) -> void:
	zamknij_panele()
	p.visible = true
	gra.swiat.gracz.sterowanie = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func przelacz_strojenie() -> void:
	if _panel_stroj.visible:
		zamknij_panele()
	else:
		_otworz(_panel_stroj)


func _przycisk(tekst: String, akcja: Callable) -> Button:
	var b := Button.new()
	b.text = tekst
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(akcja)
	return b


func _opis(tekst: String, rozmiar := 19, kolor := Color("cfc6ad")) -> Label:
	var l := Label.new()
	l.text = tekst
	l.add_theme_font_size_override("font_size", rozmiar)
	l.add_theme_color_override("font_color", kolor)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Odprawa przed wyprawą: cel, obciążenie i ostrzeżenia o brakach.
func otworz_odprawe() -> void:
	if _panel_odprawa:
		_panel_odprawa.queue_free()
	_panel_odprawa = _panel(640)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_panel_odprawa.add_child(v)
	v.add_child(_naglowek(tr("ODPRAWA")))
	v.add_child(_opis(tr("ODPRAWA_CEL"), 22, Color("e6dcc0")))
	var kto: Dictionary = Ekwipunek.zolnierz()
	v.add_child(_opis("%s — %s" % [kto["imie"], tr("SPEC_" + String(kto["spec"]))], 19, Color("e6dcc0")))
	if Ekwipunek.zwiad:
		# zwiad liczy to, co naprawdę czeka w lochu tej wyprawy
		var sklad := GeneratorLochu.sklad(GeneratorLochu.generuj(Ekwipunek.ziarno_wyprawy)["mapa"])
		var czesci := PackedStringArray()
		for typ in ["ghul", "warg", "knecht", "kultysta", "rycerz", "troll", "wlocznik", "kusznik", "komtur", "troll_stary"]:
			if sklad.has(typ):
				czesci.append(tr("ZW_" + typ) if typ == "troll_stary" else "%s ×%d" % [tr("ZW_" + typ), sklad[typ]])
		v.add_child(_opis("%s: %s" % [tr("ZWIAD_WYNIK"), ", ".join(czesci)], 18, Color("9fb0b8")))
	v.add_child(_opis(tr("ODPRAWA_OPIS")))
	v.add_child(_opis("%s: %.1f kg" % [tr("E_OBCIAZENIE"), Ekwipunek.masa()]))
	# wybór broni z plutonowej zbrojowni
	var wyb_g := OptionButton.new()
	var wyb_b := OptionButton.new()
	for id in Bron.GLOWNE:
		wyb_g.add_item(tr(Bron.DANE[id]["nazwa"]))
	for id in Bron.BOCZNE:
		wyb_b.add_item(tr(Bron.DANE[id]["nazwa"]))
	wyb_g.selected = Bron.GLOWNE.find(Ekwipunek.bron_glowna)
	wyb_b.selected = Bron.BOCZNE.find(Ekwipunek.bron_boczna)
	for para in [[tr("BRON_GLOWNA"), wyb_g], [tr("BRON_BOCZNA"), wyb_b]]:
		var hw := HBoxContainer.new()
		var lw := _opis(para[0] + ":")
		lw.custom_minimum_size = Vector2(200, 0)
		lw.autowrap_mode = TextServer.AUTOWRAP_OFF
		hw.add_child(lw)
		(para[1] as OptionButton).add_theme_font_size_override("font_size", 19)
		hw.add_child(para[1])
		v.add_child(hw)
	var zmiana_broni := func(_i: int): gra.przezbroj(Bron.GLOWNE[wyb_g.selected], Bron.BOCZNE[wyb_b.selected])
	wyb_g.item_selected.connect(zmiana_broni)
	wyb_b.item_selected.connect(zmiana_broni)
	v.add_child(_opis("%s: %d + %d" % [tr("ODPRAWA_MAG"), Ekwipunek.magazynki(Ekwipunek.bron_glowna).size(), Ekwipunek.magazynki(Ekwipunek.bron_boczna).size()]))
	var jedzenie := 0
	var woda := 0
	for poj in Ekwipunek.pojemniki():
		for p in poj.rzeczy:
			var typ: String = Ekwipunek.PRZEDMIOTY[p["id"]]["typ"]
			if typ == "jedzenie":
				jedzenie += 1
			elif typ == "picie":
				woda += int(p["dane"].get("porcje", 0))
	var leki := Ekwipunek.leki()
	var ostrz := Color("d9a05a")
	if jedzenie == 0:
		v.add_child(_opis(tr("ODPRAWA_BRAK_JEDZENIA"), 19, ostrz))
	if woda == 0:
		v.add_child(_opis(tr("ODPRAWA_BRAK_WODY"), 19, ostrz))
	if leki["bandaz"] + leki["opatrunek"] == 0:
		v.add_child(_opis(tr("ODPRAWA_BRAK_LEKOW"), 19, ostrz))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	h.add_child(_przycisk(tr("WYRUSZ"), func():
		zamknij_panele()
		gra.wyrusz()))
	h.add_child(_przycisk(tr("WROC"), zamknij_panele))
	v.add_child(h)
	_otworz(_panel_odprawa)


func otworz_biwak() -> void:
	if _panel_biwak:
		_panel_biwak.queue_free()
	_panel_biwak = _panel(640)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_panel_biwak.add_child(v)
	v.add_child(_naglowek(tr("BIWAK")))
	v.add_child(_opis(tr("BIWAK_OPIS")))
	v.add_child(_przycisk(tr("BIWAK_ODPOCZNIJ"), func():
		(gra.swiat as Kopalnia).odpocznij()
		zamknij_panele()))
	v.add_child(_przycisk(tr("BIWAK_ZAPISZ"), func(): gra.zapisz_biwak_i_wyjdz()))
	v.add_child(_przycisk(tr("WROC"), zamknij_panele))
	_otworz(_panel_biwak)


## Piec hutniczy albo stół rusznikarski: lista receptur z przyciskami.
var _panel_rzem: PanelContainer


func otworz_rzemioslo(stacja: String, ze_skrytka: bool) -> void:
	if _panel_rzem:
		_panel_rzem.queue_free()
	_panel_rzem = _panel(1000)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_panel_rzem.add_child(v)
	v.add_child(_naglowek(tr("PIEC") if stacja == "piec" else tr("RUSZNIKARZ")))
	if ze_skrytka:
		v.add_child(_opis(tr("R_ZE_SKRYTKA"), 16, Color("8f8872")))
	var przewijanie := ScrollContainer.new()
	przewijanie.custom_minimum_size = Vector2(960, 560)
	v.add_child(przewijanie)
	przewijanie.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var margines := MarginContainer.new()
	margines.add_theme_constant_override("margin_right", 26)
	margines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	przewijanie.add_child(margines)
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margines.add_child(lista)
	for r in Rzemioslo.receptury(stacja):
		var wiersz := HBoxContainer.new()
		var ok := Rzemioslo.mozna(r, ze_skrytka)
		var l := _opis(Rzemioslo.opis(r), 17, Color("cfc6ad") if ok else Color("6f6a5c"))
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
		wiersz.add_child(l)
		var b := _przycisk(tr("WYTWORZ"), func():
			var reszta := Rzemioslo.wykonaj(r, ze_skrytka)
			Dzwiek.przy_uchu("zamek" if stacja != "piec" else "uderzenie", -6.0)
			if reszta > 0:
				komunikat(tr("R_BRAK_MIEJSCA"), 4.0)
			otworz_rzemioslo(stacja, ze_skrytka))
		b.add_theme_font_size_override("font_size", 17)
		b.disabled = not ok
		wiersz.add_child(b)
		lista.add_child(wiersz)
	if stacja != "piec":
		var zrodla: Array = Ekwipunek.pojemniki()
		if ze_skrytka:
			zrodla.append(Ekwipunek.skrytka)
		for poj in zrodla:
			for p in poj.rzeczy:
				if Ekwipunek.PRZEDMIOTY[p["id"]]["typ"] != "amunicja":
					continue
				var wiersz := HBoxContainer.new()
				var l := _opis("%s: %d× %s" % [tr("R_DEMONTAZ"), int(p["dane"]["ile"]), tr(p["dane"]["typ"])], 17, Color("a89f86"))
				l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				wiersz.add_child(l)
				var b := _przycisk(tr("R_DEMONTAZ"), func():
					Rzemioslo.rozbierz(p, ze_skrytka)
					otworz_rzemioslo(stacja, ze_skrytka))
				b.add_theme_font_size_override("font_size", 17)
				wiersz.add_child(b)
				lista.add_child(wiersz)
	if ze_skrytka and stacja != "piec":
		lista.add_child(_opis(tr("DODATKI"), 20, Color("e6dcc0")))
		for idb in [Ekwipunek.bron_glowna, Ekwipunek.bron_boczna]:
			for dd in Ekwipunek.dodatki(idb):
				var w1 := HBoxContainer.new()
				var l1 := _opis("%s: %s" % [tr(Bron.DANE[idb]["nazwa"]), tr(Ekwipunek.PRZEDMIOTY[dd]["nazwa"])], 17)
				l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				w1.add_child(l1)
				var b1 := _przycisk(tr("ZDEJMIJ"), func():
					Ekwipunek.zdejmij(idb, dd)
					gra.przezbroj(Ekwipunek.bron_glowna, Ekwipunek.bron_boczna, "stol"))
				b1.add_theme_font_size_override("font_size", 17)
				w1.add_child(b1)
				lista.add_child(w1)
			for poj in Ekwipunek.pojemniki() + [Ekwipunek.skrytka]:
				for p in poj.rzeczy:
					var defd: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
					if defd["typ"] != "dodatek" or not (idb in defd["pasuje"]) or Ekwipunek.ma_dodatek(idb, defd["slot"]) != "":
						continue
					var w2 := HBoxContainer.new()
					var l2 := _opis("%s ← %s" % [tr(Bron.DANE[idb]["nazwa"]), tr(defd["nazwa"])], 17, Color("a89f86"))
					l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					w2.add_child(l2)
					var b2 := _przycisk(tr("ZAMONTUJ"), func():
						Ekwipunek.zamontuj(idb, p)
						gra.przezbroj(Ekwipunek.bron_glowna, Ekwipunek.bron_boczna, "stol"))
					b2.add_theme_font_size_override("font_size", 17)
					w2.add_child(b2)
					lista.add_child(w2)
	v.add_child(_przycisk(tr("ZAMKNIJ"), zamknij_panele))
	_otworz(_panel_rzem)


var _panel_pluton: PanelContainer


## Tablica plutonu: kto idzie, kto leży w lazarecie, zadania dla pozostałych, raport z bazy.
func otworz_pluton() -> void:
	if not (gra.swiat is Strzelnica):
		return
	if _panel_pluton:
		_panel_pluton.queue_free()
	_panel_pluton = _panel(1040)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_panel_pluton.add_child(v)
	v.add_child(_naglowek(tr("PLUTON")))
	v.add_child(_opis(tr("PLUTON_OPIS"), 16, Color("8f8872")))
	for i in Ekwipunek.pluton.size():
		var z: Dictionary = Ekwipunek.pluton[i]
		var w := HBoxContainer.new()
		w.add_theme_constant_override("separation", 12)
		var kolor := Color("cfc6ad")
		var status := "%s: %d" % [tr("WYPRAW"), int(z["wyprawy"])]
		if not z["zyje"]:
			kolor = Color("6f3a34")
			status = tr("POLEGLY")
		elif i == Ekwipunek.aktywny:
			kolor = Color("e6dcc0")
			status = tr("IDZIE")
		elif int(z["rany"]) > 0:
			kolor = Color("d9a05a")
			status = "%s: %d" % [tr("W_LAZARECIE"), int(z["rany"])]
		var l := _opis("%s — %s" % [z["imie"], tr("SPEC_" + String(z["spec"]))], 18, kolor)
		l.custom_minimum_size = Vector2(520, 0)
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
		w.add_child(l)
		var ls := _opis(status, 16, kolor)
		ls.custom_minimum_size = Vector2(190, 0)
		ls.autowrap_mode = TextServer.AUTOWRAP_OFF
		w.add_child(ls)
		if z["zyje"] and i != Ekwipunek.aktywny:
			if int(z["rany"]) == 0:
				var wyb := OptionButton.new()
				for zad in Ekwipunek.ZADANIA:
					wyb.add_item(tr(zad))
				wyb.selected = int(z["zadanie"])
				wyb.add_theme_font_size_override("font_size", 16)
				wyb.item_selected.connect(func(nr: int): z["zadanie"] = nr)
				w.add_child(wyb)
			var b := _przycisk(tr("WYZNACZ"), func():
				if Ekwipunek.wyznacz(i):
					otworz_pluton())
			b.add_theme_font_size_override("font_size", 16)
			w.add_child(b)
		v.add_child(w)
	if not Ekwipunek.raport.is_empty():
		v.add_child(_opis(tr("RAPORT"), 20, Color("e6dcc0")))
		for r in Ekwipunek.raport:
			var tekst := "%s: %s" % [r[0], tr(r[1]).to_lower()]
			if String(r[2]) != "":
				tekst += " (%s)" % r[2]
			v.add_child(_opis(tekst, 16, Color("a89f86")))
	v.add_child(_przycisk(tr("ZAMKNIJ"), zamknij_panele))
	_otworz(_panel_pluton)


func otworz_koniec() -> void:
	if _panel_pluton:
		_panel_pluton.queue_free()
	_panel_pluton = _panel(700)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	_panel_pluton.add_child(v)
	v.add_child(_naglowek(tr("KONIEC")))
	v.add_child(_opis(tr("KONIEC_OPIS")))
	for z in Ekwipunek.pluton:
		v.add_child(_opis("✝ %s — %s: %d" % [z["imie"], tr("WYPRAW"), int(z["wyprawy"])], 17, Color("8f8872")))
	v.add_child(_przycisk(tr("NOWA_KAMPANIA"), func():
		Ekwipunek.nowa_kampania()
		gra.swiat.bronie.clear()
		zamknij_panele()
		gra.zmien_swiat("strzelnica")))
	_otworz(_panel_pluton)


func przelacz_ekwipunek() -> void:
	if ekwipunek.visible:
		zamknij_panele()
	else:
		otworz_ekwipunek(null)


func otworz_ekwipunek(pojemnik: Pojemnik) -> void:
	zamknij_panele()
	ekwipunek.otworz(pojemnik)
	gra.swiat.gracz.sterowanie = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Dzwiek.przy_uchu("bron_wyjmij", -10.0)


func przelacz_pomoc() -> void:
	if _panel_pomoc.visible:
		zamknij_panele()
	else:
		_otworz(_panel_pomoc)


func otworz_stol() -> void:
	if _panel_stol:
		_panel_stol.queue_free()
	_panel_stol = _panel(640)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_panel_stol.add_child(v)
	var b: Bron = gra.swiat.bron()
	v.add_child(_naglowek(tr("STOL_AMUNICYJNY") + " — " + tr(b.d["nazwa"])))
	var opis := Label.new()
	opis.text = tr("STOL_OPIS")
	opis.add_theme_font_size_override("font_size", 19)
	opis.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(opis)
	var typy := Amunicja.dla_kalibru(b.d["kaliber"])
	var wyb_a := OptionButton.new()
	var wyb_b := OptionButton.new()
	wyb_b.add_item("—")
	for t in typy:
		var a: Dictionary = Amunicja.TYPY[t]
		var linia := "%s   (%s %d · %s %d)" % [tr(t), tr("OBRAZENIA"), a["obr"], tr("PRZEBICIE").to_lower(), a["przeb"]]
		wyb_a.add_item(linia)
		wyb_b.add_item(linia)
	for w in [wyb_a, wyb_b]:
		w.add_theme_font_size_override("font_size", 20)
	v.add_child(wyb_a)
	var przeplot := Label.new()
	przeplot.text = tr("STOL_PRZEPLOT")
	przeplot.add_theme_font_size_override("font_size", 18)
	v.add_child(przeplot)
	v.add_child(wyb_b)
	var ok := Button.new()
	ok.text = "OK"
	ok.add_theme_font_size_override("font_size", 22)
	ok.pressed.connect(func():
		var ta: String = typy[wyb_a.selected]
		var tb: String = "" if wyb_b.selected <= 0 else typy[wyb_b.selected - 1]
		b.zaladuj_magazynki(ta, tb)
		Dzwiek.przy_uchu("mag_wl", -3.0)
		zamknij_panele())
	v.add_child(ok)
	_otworz(_panel_stol)


func _process(dt: float) -> void:
	_kom_t = maxf(_kom_t - dt, 0.0)
	_komunikat.modulate.a = clampf(_kom_t / 0.6, 0.0, 1.0)
	_wsk_t = maxf(_wsk_t - dt, 0.0)
	_wskazowka.modulate.a = clampf(_wsk_t / 1.5, 0.0, 1.0)
	var g: Gracz = gra.swiat.gracz
	var pok_n := g.wytrz_nogi < 0.995
	var pok_r := g.wytrz_rece < 0.995
	_pasek_nogi.visible = pok_n
	_et_nogi.visible = pok_n
	_pasek_rece.visible = pok_r
	_et_rece.visible = pok_r
	_pasek_nogi.value = g.wytrz_nogi
	_pasek_rece.value = g.wytrz_rece
	if not is_equal_approx(g.tempo, _ost_tempo):
		if _ost_tempo >= 0.0:
			_tempo_t = 1.4
		_ost_tempo = g.tempo
		var n := roundi((g.tempo - 0.25) / 0.125)
		_tempo.text = "▮".repeat(n + 1) + "▯".repeat(6 - n)
	_tempo_t = maxf(_tempo_t - dt, 0.0)
	_tempo.modulate.a = clampf(_tempo_t / 0.4, 0.0, 1.0)
	var tekst := ""
	if not panel_otwarty():
		var lezy: Node3D = gra.swiat.magazynek_w_zasiegu()
		if lezy != null:
			tekst = tr("E_PODNIES") + ": " + tr(Ekwipunek.PRZEDMIOTY[lezy.get("przedmiot")["id"]]["nazwa"])
		elif gra.swiat.podpowiedz_wspolna().contains("[V]"):
			tekst = gra.swiat.podpowiedz_wspolna()
		elif gra.swiat.pojemnik_w_zasiegu() != null:
			tekst = tr("E_PRZESZUKAJ")
		elif gra.swiat.podpowiedz() != "":
			tekst = gra.swiat.podpowiedz()
		elif gra.swiat.podpowiedz_wspolna() != "":
			tekst = gra.swiat.podpowiedz_wspolna()
		elif gra.swiat.bron().zablokowana > 0.35:
			tekst = tr("BRON_ZABLOKOWANA")
	_podpowiedz.text = tekst
	_odswiez_zdrowie(dt)
