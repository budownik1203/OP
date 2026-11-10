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


func przygotuj(g: Node) -> void:
	gra = g
	_korzen = Control.new()
	_korzen.set_anchors_preset(Control.PRESET_FULL_RECT)
	_korzen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_korzen)
	_komunikat = _etykieta(26, Color("e6dcc0"))
	_komunikat.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_komunikat.position = Vector2(-500, -190)
	_komunikat.size = Vector2(1000, 40)
	_komunikat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_komunikat.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_podpowiedz = _etykieta(22, Color("d8c9a0"))
	_podpowiedz.set_anchors_preset(Control.PRESET_CENTER)
	_podpowiedz.position = Vector2(-400, 120)
	_podpowiedz.size = Vector2(800, 30)
	_podpowiedz.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wskazowka = _etykieta(20, Color("d8c9a0"))
	_wskazowka.position = Vector2(28, 22)
	_tempo = _etykieta(18, Color("d8c9a0"))
	_tempo.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_tempo.position = Vector2(30, -128)
	_pasek_nogi = _pasek(Color("8a9a5b"))
	_pasek_nogi.position = Vector2(92, -84)
	_pasek_rece = _pasek(Color("b08d57"))
	_pasek_rece.position = Vector2(92, -60)
	_et_nogi = _etykieta(15, Color("d8c9a0"))
	_et_nogi.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_et_nogi.position = Vector2(30, -92)
	_et_rece = _etykieta(15, Color("d8c9a0"))
	_et_rece.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_et_rece.position = Vector2(30, -68)
	_zbuduj_pomoc()
	_zbuduj_strojenie()
	odswiez()


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
	p.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	p.custom_minimum_size = Vector2(170, 8)
	p.size = Vector2(170, 8)
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
	_wskazowka.text = tr("TYTUL") + " · build 1 · " + tr("PODPOWIEDZ_H")
	_et_nogi.text = tr("WYTRZ_NOGI")
	_et_rece.text = tr("WYTRZ_RECE")
	(_panel_pomoc.find_child("naglowek", true, false) as Label).text = tr("POMOC")
	_pomoc_tekst.text = tr("POMOC_TRESC")
	(_panel_stroj.find_child("naglowek", true, false) as Label).text = tr("STROJENIE") + " — " + tr("STRZELNICA")
	(_panel_stroj.find_child("przywroc", true, false) as Button).text = tr("PRZYWROC")
	(_panel_stroj.find_child("zamknij", true, false) as Button).text = tr("ZAMKNIJ")
	for k in _suwaki:
		_suwaki[k][0].text = tr(k)


func komunikat(tekst: String) -> void:
	_komunikat.text = tekst
	_kom_t = 2.8


func panel_otwarty() -> bool:
	return _panel_stroj.visible or _panel_pomoc.visible or (_panel_stol != null and _panel_stol.visible)


func zamknij_panele() -> bool:
	if not panel_otwarty():
		return false
	if _panel_stroj.visible:
		Strojenie.zapisz()
	_panel_stroj.visible = false
	_panel_pomoc.visible = false
	if _panel_stol:
		_panel_stol.visible = false
	_wroc_do_gry()
	return true


func _wroc_do_gry() -> void:
	gra.swiat.gracz.sterowanie = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
		if gra.swiat.magazynek_w_zasiegu() != null:
			tekst = "[F] " + tr("MAG_PODNIESIONY").to_lower()
		elif gra.swiat.przy_stole():
			tekst = tr("STOL_PODPOWIEDZ")
		elif gra.swiat.bron().zablokowana > 0.35:
			tekst = tr("BRON_ZABLOKOWANA")
	_podpowiedz.text = tekst
