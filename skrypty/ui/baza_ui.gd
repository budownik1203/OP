class_name BazaUI
extends Control
## Baza plutonu jako interfejs 2D. Trójwymiar zaczyna się dopiero po wymarszu
## (albo po wejściu na strzelnicę, żeby przestrzelać broń).

var gra: Node
var hud: Hud
var _tytul: Label
var _zolnierz: Label
var _pluton: VBoxContainer
var _zapasy: Label
var _zwiad: Label
var _przyciski: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var tlo := ColorRect.new()
	tlo.color = Color("0c0d0e")
	tlo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tlo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tlo)
	var pas := ColorRect.new()
	pas.color = Color("15171a")
	pas.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	pas.offset_bottom = 96
	pas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pas)
	_tytul = _napis("", 34, Color("e6dcc0"))
	_tytul.position = Vector2(48, 24)
	add_child(_tytul)
	# lewa kolumna: stanowiska bazy
	_przyciski = VBoxContainer.new()
	_przyciski.position = Vector2(48, 140)
	_przyciski.custom_minimum_size = Vector2(500, 0)
	_przyciski.add_theme_constant_override("separation", 10)
	add_child(_przyciski)
	# środek: żołnierz i pluton
	var srodek := VBoxContainer.new()
	srodek.position = Vector2(610, 140)
	srodek.custom_minimum_size = Vector2(660, 0)
	srodek.add_theme_constant_override("separation", 14)
	add_child(srodek)
	srodek.add_child(_naglowek("B_ZOLNIERZ"))
	_zolnierz = _napis("", 20, Color("cfc6ad"))
	srodek.add_child(_zolnierz)
	srodek.add_child(_naglowek("PLUTON"))
	_pluton = VBoxContainer.new()
	_pluton.add_theme_constant_override("separation", 4)
	srodek.add_child(_pluton)
	# prawa kolumna: zapasy i zwiad
	var prawa := VBoxContainer.new()
	prawa.position = Vector2(1330, 140)
	prawa.custom_minimum_size = Vector2(540, 0)
	prawa.add_theme_constant_override("separation", 14)
	add_child(prawa)
	prawa.add_child(_naglowek("B_ZAPASY"))
	_zapasy = _napis("", 20, Color("cfc6ad"))
	prawa.add_child(_zapasy)
	prawa.add_child(_naglowek("B_NASTEPNA"))
	_zwiad = _napis("", 20, Color("9fb0b8"))
	_zwiad.custom_minimum_size = Vector2(530, 0)
	_zwiad.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prawa.add_child(_zwiad)
	Ekwipunek.zmiana.connect(func(): if visible: odswiez())
	Jezyk.zmieniono.connect(func(): if visible: odswiez())


func _napis(t: String, rozmiar: int, kolor: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", rozmiar)
	l.add_theme_color_override("font_color", kolor)
	return l


func _naglowek(klucz: String) -> Label:
	var l := _napis(tr(klucz).to_upper(), 17, Color("8f8872"))
	l.set_meta("klucz", klucz)
	return l


func _stanowisko(klucz: String, opis: String, akcja: Callable, wyrozniony := false) -> void:
	var b := Button.new()
	b.text = tr(klucz) + "\n" + tr(opis)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(500, 78)
	b.add_theme_font_size_override("font_size", 20)
	var s := StyleBoxFlat.new()
	s.bg_color = Color("3a2f1c") if wyrozniony else Color("1b1d20")
	s.border_color = Color("8a6f3a") if wyrozniony else Color("3a3a36")
	s.set_border_width_all(1)
	s.content_margin_left = 18
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal", s)
	var s2: StyleBoxFlat = s.duplicate()
	s2.bg_color = s.bg_color.lightened(0.12)
	b.add_theme_stylebox_override("hover", s2)
	b.add_theme_stylebox_override("pressed", s2)
	b.add_theme_color_override("font_color", Color("e6dcc0"))
	b.pressed.connect(func():
		Dzwiek.przy_uchu("klik", -10.0, 0.1)
		akcja.call())
	_przyciski.add_child(b)


func pokaz() -> void:
	visible = true
	gra.kontener.visible = false
	if gra.swiat != null and gra.swiat.gracz != null:
		gra.swiat.gracz.sterowanie = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	odswiez()


func ukryj() -> void:
	visible = false
	gra.kontener.visible = true


func odswiez() -> void:
	_tytul.text = "%s — %s" % [tr("TYTUL"), tr("B_BAZA")]
	for c in _przyciski.get_children():
		c.queue_free()
	_stanowisko("B_EKWIPUNEK", "B_EKWIPUNEK_O", func(): hud.otworz_ekwipunek(Ekwipunek.skrytka))
	_stanowisko("B_PLUTON", "B_PLUTON_O", func(): hud.otworz_pluton())
	_stanowisko("B_RUSZNIKARZ", "B_RUSZNIKARZ_O", func(): hud.otworz_rzemioslo("stol", true))
	_stanowisko("B_PIEC", "B_PIEC_O", func(): hud.otworz_rzemioslo("piec", true))
	_stanowisko("B_MODYFIKACJE", "B_MODYFIKACJE_O", func(): hud.otworz_modyfikacje(Ekwipunek.bron_glowna))
	_stanowisko("B_STRZELNICA", "B_STRZELNICA_O", func(): gra.na_strzelnice())
	_stanowisko("B_WYMARSZ", "B_WYMARSZ_O", func(): hud.otworz_odprawe(), true)
	var z: Dictionary = Ekwipunek.zolnierz()
	if not z.is_empty():
		var linie := PackedStringArray()
		linie.append("%s — %s" % [z["imie"], tr("SPEC_" + String(z["spec"]))])
		linie.append("%s: %s   ·   %s: %s" % [tr("BRON_GLOWNA"), tr(Bron.DANE[Ekwipunek.bron_glowna]["nazwa"]), tr("BRON_BOCZNA"), tr(Bron.DANE[Ekwipunek.bron_boczna]["nazwa"])])
		linie.append("%s: %.1f kg   ·   %s %d%%   ·   %s %d%%" % [tr("E_OBCIAZENIE"), Ekwipunek.masa(), tr("B_SYTOSC"), int(Ekwipunek.sytosc), tr("B_NAWODNIENIE"), int(Ekwipunek.nawodnienie)])
		_zolnierz.text = "\n".join(linie)
	for c in _pluton.get_children():
		c.queue_free()
	for i in Ekwipunek.pluton.size():
		var p: Dictionary = Ekwipunek.pluton[i]
		var stan := tr("B_POLEGL")
		var kolor := Color("6f5a52")
		if p["zyje"]:
			kolor = Color("e6dcc0") if i == Ekwipunek.aktywny else Color("bdb59c")
			if i == Ekwipunek.aktywny:
				stan = tr("B_IDZIE")
			elif int(p.get("rany", 0)) > 0:
				stan = "%s (%d)" % [tr("B_RANNY"), int(p["rany"])]
				kolor = Color("d9a05a")
			else:
				stan = tr(Ekwipunek.ZADANIA[int(p.get("zadanie", 0))])
		_pluton.add_child(_napis("%s  —  %s" % [p["imie"], stan], 19, kolor))
	var jedzenie := 0
	var naboje := 0
	var rudy := 0
	for p in Ekwipunek.skrytka.rzeczy:
		var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
		if def["typ"] == "jedzenie":
			jedzenie += int(p["dane"].get("porcje", 1))
		elif p["dane"].has("naboje"):
			naboje += (p["dane"]["naboje"] as Array).size()
		elif def["typ"] == "surowiec":
			rudy += int(p["dane"].get("ile", 1))
	_zapasy.text = "%s: %d\n%s: %d\n%s: %d\n%s: %d   ·   %s: %d" % [tr("B_JEDZENIE"), jedzenie, tr("B_NABOJE"), naboje, tr("B_SUROWCE"), rudy, tr("B_WYPRAWY"), Ekwipunek.wyprawy, tr("B_POLEGLI"), Ekwipunek.polegli]
	if Ekwipunek.zwiad:
		var sklad := GeneratorLochu.sklad(GeneratorLochu.generuj(Ekwipunek.ziarno_wyprawy)["mapa"])
		var cz := PackedStringArray()
		for typ in ["ghul", "warg", "knecht", "kultysta", "rycerz", "troll", "wlocznik", "kusznik", "komtur", "troll_stary"]:
			if sklad.has(typ):
				cz.append(tr("ZW_" + typ) if typ == "troll_stary" else "%s ×%d" % [tr("ZW_" + typ), sklad[typ]])
		_zwiad.text = "%s: %s" % [tr("ZWIAD_WYNIK"), ", ".join(cz)]
	else:
		_zwiad.text = tr("B_BRAK_ZWIADU")
