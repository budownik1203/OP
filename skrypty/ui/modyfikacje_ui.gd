class_name ModyfikacjeUI
extends Control
## Modyfikacja broni: obracany model 3D i okienka gniazd z listą posiadanych dodatków,
## połączone liniami z miejscem montażu.

const GNIAZDA := [["szyna", "M_CELOWNIK"], ["wylot", "M_WYLOT"], ["chwyt", "M_CHWYT"]]

var hud: Hud
var id_broni := ""
var _widok: SubViewport
var _kamera: Camera3D
var _os: Node3D
var _model: Node3D
var _punkty := {}                 ## slot -> Node3D w miejscu montażu
var _okna := {}                   ## slot -> PanelContainer
var _listy := {}                  ## slot -> OptionButton
var _opcje := {}                  ## slot -> Array (id dodatku albo "")
var _tytul: Label
var _dane: Label
var _wybor: OptionButton
var _napraw: Button
var _obrot := Vector2(-0.10, 1.32)
var _ciagnie := false
var _ramka: Rect2


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_ramka = Rect2(260, 170, 1400, 720)
	var kont := SubViewportContainer.new()
	kont.position = _ramka.position
	kont.size = _ramka.size
	kont.stretch = true
	kont.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(kont)
	_widok = SubViewport.new()
	_widok.own_world_3d = true
	_widok.transparent_bg = true
	_widok.msaa_3d = Viewport.MSAA_4X
	kont.add_child(_widok)
	_kamera = Camera3D.new()
	_kamera.fov = 28.0
	_kamera.position = Vector3(0, 0, 1.6)
	_widok.add_child(_kamera)
	var sw := DirectionalLight3D.new()
	sw.rotation = Vector3(-0.7, 0.6, 0)
	sw.light_energy = 1.6
	_widok.add_child(sw)
	var sw2 := DirectionalLight3D.new()
	sw2.rotation = Vector3(0.4, -2.2, 0)
	sw2.light_energy = 0.6
	_widok.add_child(sw2)
	var otocz := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0, 0, 0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.5, 0.55)
	env.ambient_light_energy = 0.7
	otocz.environment = env
	_widok.add_child(otocz)
	_os = Node3D.new()
	_widok.add_child(_os)
	_tytul = Label.new()
	_tytul.position = Vector2(260, 100)
	_tytul.add_theme_font_size_override("font_size", 30)
	_tytul.add_theme_color_override("font_color", Color("e6dcc0"))
	add_child(_tytul)
	_wybor = OptionButton.new()
	_wybor.position = Vector2(1240, 100)
	_wybor.custom_minimum_size = Vector2(300, 40)
	_wybor.add_theme_font_size_override("font_size", 19)
	for id in Bron.GLOWNE + Bron.BOCZNE:
		_wybor.add_item(tr(Bron.DANE[id]["nazwa"]))
	_wybor.item_selected.connect(func(i: int): otworz((Bron.GLOWNE + Bron.BOCZNE)[i]))
	add_child(_wybor)
	var zamknij := Button.new()
	zamknij.text = "✕"
	zamknij.position = Vector2(1600, 100)
	zamknij.custom_minimum_size = Vector2(60, 40)
	zamknij.add_theme_font_size_override("font_size", 20)
	zamknij.pressed.connect(func(): hud.zamknij_panele())
	add_child(zamknij)
	_dane = Label.new()
	_dane.position = Vector2(280, 900)
	_dane.add_theme_font_size_override("font_size", 19)
	_dane.add_theme_color_override("font_color", Color("bdb59c"))
	add_child(_dane)
	_napraw = Button.new()
	_napraw.position = Vector2(1340, 912)
	_napraw.custom_minimum_size = Vector2(320, 44)
	_napraw.add_theme_font_size_override("font_size", 19)
	_napraw.pressed.connect(func():
		if Ekwipunek.napraw_bron(id_broni):
			Dzwiek.przy_uchu("zamek", -4.0, 0.1)
		_zbuduj())
	add_child(_napraw)
	var pozycje := {"szyna": Vector2(820, 190), "wylot": Vector2(300, 640), "chwyt": Vector2(700, 760)}
	for g in GNIAZDA:
		var okno := PanelContainer.new()
		var st := StyleBoxFlat.new()
		st.bg_color = Color(0.07, 0.075, 0.085, 0.96)
		st.border_color = Color("5a5140")
		st.set_border_width_all(1)
		st.set_content_margin_all(10)
		okno.add_theme_stylebox_override("panel", st)
		okno.position = pozycje[g[0]]
		okno.custom_minimum_size = Vector2(300, 0)
		add_child(okno)
		var v := VBoxContainer.new()
		okno.add_child(v)
		var et := Label.new()
		et.text = tr(g[1])
		et.add_theme_font_size_override("font_size", 15)
		et.add_theme_color_override("font_color", Color("8f8872"))
		v.add_child(et)
		var lista := OptionButton.new()
		lista.add_theme_font_size_override("font_size", 18)
		lista.custom_minimum_size = Vector2(280, 38)
		var slot: String = g[0]
		lista.item_selected.connect(func(i: int): _wybrano(slot, i))
		v.add_child(lista)
		_okna[slot] = okno
		_listy[slot] = lista


func otworz(id: String) -> void:
	id_broni = id
	visible = true
	_wybor.selected = (Bron.GLOWNE + Bron.BOCZNE).find(id)
	_zbuduj()


func _zbuduj() -> void:
	var d: Dictionary = Bron.DANE[id_broni]
	_tytul.text = "%s — %s" % [tr("B_MODYFIKACJE"), tr(d["nazwa"])]
	if _model != null:
		_model.queue_free()
	_punkty.clear()
	_model = (load(d["model"]) as PackedScene).instantiate()
	_os.add_child(_model)
	# na stole leży sama broń, bez rąk strzelca
	for n in ["reka_p", "reka_l"]:
		var reka := _model.find_child(n, true, false)
		if reka != null:
			reka.get_parent().remove_child(reka)
			reka.queue_free()
	# środek i skala: broń ma się mieścić w kadrze niezależnie od długości
	var aabb := _zakres(_model, Transform3D.IDENTITY)
	_model.position = -aabb.get_center()
	_kamera.position.z = maxf(maxf(aabb.size.z, aabb.size.y * 1.8), 0.22) * 2.05 + 0.12
	var wylot := _model.find_child("wylot", true, false) as Node3D
	var metal := Mat.kolor(Color("1b1c1e"), 0.55, 0.6)
	if wylot != null:
		_punkty["wylot"] = wylot
		var id_tl := Ekwipunek.ma_dodatek(id_broni, "wylot")
		if id_tl != "":
			var dl := 0.17 if id_tl == "tlumik_kar" else 0.13
			var s := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.019 if id_tl == "tlumik_kar" else 0.016
			cm.bottom_radius = cm.top_radius
			cm.height = dl
			cm.radial_segments = 12
			s.mesh = cm
			s.material_override = metal
			s.rotation.x = PI * 0.5
			s.position = Vector3(0, 0, -dl * 0.5 + 0.02)
			wylot.add_child(s)
	if wylot != null and _gniazdo_istnieje("chwyt"):
		var pw: Vector3 = _model.global_transform.affine_inverse() * wylot.global_position
		var kch := Node3D.new()
		kch.position = Vector3(0, pw.y - 0.030, pw.z * 0.52)
		_model.add_child(kch)
		_punkty["chwyt"] = kch
		if Ekwipunek.ma_dodatek(id_broni, "chwyt") != "":
			var ch := MeshInstance3D.new()
			var cmg := CylinderMesh.new()
			cmg.top_radius = 0.013
			cmg.bottom_radius = 0.015
			cmg.height = 0.085
			ch.mesh = cmg
			ch.material_override = metal
			ch.position = Vector3(0, -0.045, 0)
			kch.add_child(ch)
	if d.has("szyna"):
		var sz: Vector3 = d["szyna"]
		var k := Node3D.new()
		k.position = Vector3(sz.x, sz.z, -sz.y)
		_model.add_child(k)
		_punkty["szyna"] = k
		var id_cel := Ekwipunek.ma_dodatek(id_broni, "szyna")
		if id_cel != "":
			var holo := id_cel == "holo"
			var ws := 0.036 if holo else 0.026
			var hs := 0.027 if holo else 0.022
			for cz in [[Vector3(ws + 0.004, 0.012, 0.062 if holo else 0.052), Vector3(0, 0.006, 0)],
					[Vector3(0.003, hs + 0.004, 0.008 if not holo else 0.036), Vector3(-(ws + 0.003) * 0.5, 0.014 + hs * 0.5, -0.021)],
					[Vector3(0.003, hs + 0.004, 0.008 if not holo else 0.036), Vector3((ws + 0.003) * 0.5, 0.014 + hs * 0.5, -0.021)],
					[Vector3(ws + 0.006, 0.003, 0.008 if not holo else 0.036), Vector3(0, 0.014 + hs + 0.0035, -0.021)]]:
				var si := MeshInstance3D.new()
				var bm := BoxMesh.new()
				bm.size = cz[0]
				si.mesh = bm
				si.material_override = metal
				si.position = cz[1]
				k.add_child(si)
	# listy gniazd: brak, zamontowany, posiadane pasujące
	for g in GNIAZDA:
		var slot: String = g[0]
		var lista: OptionButton = _listy[slot]
		var okno: PanelContainer = _okna[slot]
		okno.visible = _punkty.has(slot) and _gniazdo_istnieje(slot)
		lista.clear()
		var opcje := [""]
		lista.add_item(tr("M_PUSTE"))
		var zamontowany := Ekwipunek.ma_dodatek(id_broni, slot)
		if zamontowany != "":
			opcje.append(zamontowany)
			lista.add_item(tr(Ekwipunek.PRZEDMIOTY[zamontowany]["nazwa"]) + "  ●")
		var policzone := {}
		for p in _posiadane(slot):
			policzone[p["id"]] = int(policzone.get(p["id"], 0)) + 1
		for idd in policzone:
			if idd != zamontowany:
				opcje.append(idd)
				lista.add_item("%s  ×%d" % [tr(Ekwipunek.PRZEDMIOTY[idd]["nazwa"]), policzone[idd]])
		if opcje.size() == 1:
			lista.set_item_text(0, tr("M_BRAK_PASUJACYCH"))
		lista.selected = 1 if zamontowany != "" else 0
		_opcje[slot] = opcje
	# liczby jak na ekranie modyfikacji w Tarkovie: co dodatki zmieniają względem gołej broni
	var tl := Ekwipunek.ma_dodatek(id_broni, "wylot") != ""
	var cel := Ekwipunek.ma_dodatek(id_broni, "szyna")
	var chw := Ekwipunek.ma_dodatek(id_broni, "chwyt") != ""
	var odrzut := (0.9 if tl else 1.0) * (0.88 if chw else 1.0)
	var czas: float = float(d["czas_celu"]) * (0.85 if cel != "" else 1.0) * (0.93 if chw else 1.0)
	var masa: float = d["masa"]
	for x in Ekwipunek.dodatki(id_broni):
		masa += float(Ekwipunek.PRZEDMIOTY[x]["masa"])
	var stan := Ekwipunek.stan_techniczny(id_broni)
	var linie := PackedStringArray()
	linie.append("%s: %s" % [tr("M_KALIBER"), d["kaliber"]])
	linie.append("%s: %d%%" % [tr("M_ODRZUT"), roundi(odrzut * 100.0)])
	linie.append("%s: %.2f s" % [tr("M_SKLADANIE"), czas])
	linie.append("%s: %.1f MOA" % [tr("M_ROZRZUT"), float(d["rozrzut_moa"])])
	linie.append("%s: %.2f kg" % [tr("M_MASA"), masa])
	var linie2 := PackedStringArray()
	linie2.append("%s: %s" % [tr("M_HALAS"), tr("M_STLUMIONY") if tl else tr("M_PELNY")])
	linie2.append("%s: %s" % [tr("M_CELOWNIK"), tr(Ekwipunek.PRZEDMIOTY[cel]["nazwa"]) if cel != "" else (tr("M_LUNETA") if d.has("luneta") else tr("M_MECHANICZNE"))])
	linie2.append("%s: %d%%%s" % [tr("M_STAN"), roundi(stan * 100.0), (" (" + tr("M_ZACINA") + ")") if stan < 0.75 else ""])
	_dane.text = "   ·   ".join(linie) + "\n" + "   ·   ".join(linie2) + "\n" + tr("M_PODPOWIEDZ")
	_napraw.text = tr("M_NAPRAW")
	_napraw.disabled = stan >= 0.995 or Ekwipunek.ile_zasobu("sztabka_stali", true) <= 0
	_napraw.visible = hud.baza.visible


func _gniazdo_istnieje(slot: String) -> bool:
	for idd in Ekwipunek.PRZEDMIOTY:
		var def: Dictionary = Ekwipunek.PRZEDMIOTY[idd]
		if def["typ"] == "dodatek" and def["slot"] == slot and id_broni in def["pasuje"]:
			return true
	return false


func _posiadane(slot: String) -> Array:
	var w := []
	for poj in [Ekwipunek.skrytka, Ekwipunek.plecak, Ekwipunek.kamizelka, Ekwipunek.kieszenie]:
		if poj == null:
			continue
		for p in poj.rzeczy:
			var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
			if def["typ"] == "dodatek" and def["slot"] == slot and id_broni in def["pasuje"]:
				w.append(p)
	return w


func _wybrano(slot: String, i: int) -> void:
	var chce: String = _opcje[slot][i]
	var jest := Ekwipunek.ma_dodatek(id_broni, slot)
	if chce == jest:
		return
	if jest != "":
		Ekwipunek.zdejmij(id_broni, jest)
	if chce != "":
		for p in _posiadane(slot):
			if p["id"] == chce:
				Ekwipunek.zamontuj(id_broni, p)
				break
	Dzwiek.przy_uchu("mag_wl", -6.0, 0.1)
	_zbuduj()


func _zakres(w: Node, t: Transform3D) -> AABB:
	var wynik := AABB()
	var pierwszy := true
	for c in w.get_children():
		if not (c is Node3D):
			continue
		var tc: Transform3D = t * (c as Node3D).transform
		if c is MeshInstance3D and (c as MeshInstance3D).mesh != null:
			var a: AABB = tc * (c as MeshInstance3D).get_aabb()
			wynik = a if pierwszy else wynik.merge(a)
			pierwszy = false
		var pod := _zakres(c, tc)
		if pod.size.length() > 0.0:
			wynik = pod if pierwszy else wynik.merge(pod)
			pierwszy = false
	return wynik


func _process(_dt: float) -> void:
	if not visible:
		return
	_os.rotation = Vector3(_obrot.x, _obrot.y, 0)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.045, 0.05, 0.055, 1.0) if hud.baza.visible else Color(0.02, 0.02, 0.025, 0.93))
	draw_rect(_ramka, Color(0.05, 0.055, 0.06, 1.0))
	draw_rect(_ramka, Color("3a3a36"), false, 1.0)
	var skala := _ramka.size / Vector2(_widok.size)
	for slot in _punkty:
		var okno: PanelContainer = _okna[slot]
		if not okno.visible:
			continue
		var p3: Vector3 = (_punkty[slot] as Node3D).global_position
		if _kamera.is_position_behind(p3):
			continue
		var p2 := _ramka.position + _kamera.unproject_position(p3) * skala
		var od := okno.position + Vector2(okno.size.x * 0.5, okno.size.y if okno.position.y < p2.y else 0.0)
		draw_line(od, p2, Color("b08d57"), 1.5, true)
		draw_circle(p2, 5.0, Color("b08d57"))
		draw_circle(p2, 2.5, Color("15171a"))


func _gui_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_ciagnie = (ev as InputEventMouseButton).pressed and _ramka.has_point((ev as InputEventMouseButton).position)
	elif ev is InputEventMouseMotion and _ciagnie:
		var r := (ev as InputEventMouseMotion).relative
		_obrot.y += r.x * 0.008
		_obrot.x = clampf(_obrot.x + r.y * 0.008, -1.2, 1.2)
