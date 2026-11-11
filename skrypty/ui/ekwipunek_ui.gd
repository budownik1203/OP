class_name EkwipunekUI
extends Control
## Ekran ekwipunku: siatki kieszeni, kamizelki, plecaka i relikwiarza,
## a po prawej przeszukiwany pojemnik. Gra się nie zatrzymuje.
## LPM przeciąga, R obraca, Ctrl+LPM przenosi, PPM wyrzuca.

const POLE := 58.0
const CZAS_ODKRYCIA := 0.7

var gra: Node
var lup: Pojemnik = null
var _obszary: Array = []         ## {poj, pos}
var _ciag := {}                  ## przeciągany przedmiot
var _ciag_z: Pojemnik = null
var _ciag_start := {}
var _ciag_obr := false
var _t_szuk := 0.0
var _czcionka: Font


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_czcionka = ThemeDB.fallback_font


func otworz(pojemnik: Pojemnik = null) -> void:
	lup = pojemnik
	_t_szuk = 0.0
	visible = true


func zamknij() -> void:
	_odloz_ciagniety()
	Ekwipunek.przerwij_ladowanie()
	visible = false
	lup = null


func _uklad() -> void:
	_obszary.clear()
	var x := 430.0
	var y := 150.0
	_obszary.append({"poj": Ekwipunek.kieszenie, "pos": Vector2(x, y)})
	_obszary.append({"poj": Ekwipunek.relikwiarz, "pos": Vector2(x + 5 * POLE, y)})
	y += POLE * 2 + 64
	_obszary.append({"poj": Ekwipunek.kamizelka, "pos": Vector2(x, y)})
	y += Ekwipunek.kamizelka.wys * POLE + 64
	if Ekwipunek.plecak != null:
		_obszary.append({"poj": Ekwipunek.plecak, "pos": Vector2(x, y)})
	if lup != null:
		_obszary.append({"poj": lup, "pos": Vector2(maxf(size.x - lup.szer * POLE - 60, x + 8 * POLE), 150.0)})


func _process(dt: float) -> void:
	if not visible:
		return
	if lup != null:
		_t_szuk += dt
		if _t_szuk >= CZAS_ODKRYCIA:
			_t_szuk = 0.0
			for p in lup.rzeczy:
				if not p.get("odkryty", true):
					p["odkryty"] = true
					Dzwiek.przy_uchu("klik", -14.0, 0.3)
					break
	queue_redraw()


func _szuka() -> bool:
	if lup == null:
		return false
	for p in lup.rzeczy:
		if not p.get("odkryty", true):
			return true
	return false


func _tekst(pos: Vector2, t: String, rozmiar := 18, kolor := Color("d8c9a0"), szer := -1.0) -> void:
	draw_string(_czcionka, pos, t, HORIZONTAL_ALIGNMENT_LEFT, szer, rozmiar, kolor)


func _draw() -> void:
	_uklad()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.025, 0.86))
	# lewa kolumna: obciążenie, noszone rzeczy, broń
	var m := Ekwipunek.masa()
	var kolor_m := Color("d8c9a0")
	if m >= Ekwipunek.LIMIT_CIEZKI:
		kolor_m = Color("c94b3a")
	elif m >= Ekwipunek.LIMIT_LEKKI:
		kolor_m = Color("d9a05a")
	_tekst(Vector2(60, 120), tr("E_EKWIPUNEK"), 30, Color("e6dcc0"))
	_tekst(Vector2(60, 176), "%s: %.1f kg" % [tr("E_OBCIAZENIE"), m], 22, kolor_m)
	_tekst(Vector2(60, 204), tr("E_LIMITY"), 15, Color("8f8872"))
	var y := 262.0
	_tekst(Vector2(60, y), tr("E_KAMIZELKA") + ":", 16, Color("8f8872"))
	_tekst(Vector2(60, y + 24), tr(Ekwipunek.PRZEDMIOTY[Ekwipunek.kamizelka_p["id"]]["nazwa"]), 19)
	y += 70
	_tekst(Vector2(60, y), tr("E_PLECAK") + ":", 16, Color("8f8872"))
	_tekst(Vector2(60, y + 24), tr(Ekwipunek.PRZEDMIOTY[Ekwipunek.plecak_p["id"]]["nazwa"]) if not Ekwipunek.plecak_p.is_empty() else tr("E_PLECAK_BRAK"), 19)
	y += 70
	for b in gra.swiat.bronie:
		_tekst(Vector2(60, y), tr(b.d["nazwa"]), 17)
		var opis := tr("BRAK_MAG") if b.mag_p.is_empty() else Ekwipunek.opis_magazynka(b.mag_p)
		_tekst(Vector2(60, y + 22), opis, 15, Color("8f8872"))
		y += 58
	# siatki
	var najechany := {}
	var mysz := get_local_mouse_position()
	for o in _obszary:
		var poj: Pojemnik = o["poj"]
		var pos: Vector2 = o["pos"]
		var tytul := tr(poj.nazwa)
		if poj == lup and _szuka():
			tytul += " — " + tr("E_SZUKANIE")
		_tekst(pos + Vector2(0, -12), tytul, 18, Color("bdb59c"))
		for cy in poj.wys:
			for cx in poj.szer:
				var r := Rect2(pos + Vector2(cx, cy) * POLE, Vector2(POLE - 2, POLE - 2))
				draw_rect(r, Color(0.09, 0.09, 0.10, 0.95))
				draw_rect(r, Color(0.22, 0.21, 0.19), false, 1.0)
		for p in poj.rzeczy:
			var w := Pojemnik.wymiary(p, p["obr"])
			var r := Rect2(pos + Vector2(p["x"], p["y"]) * POLE + Vector2(1, 1), Vector2(w.x, w.y) * POLE - Vector2(4, 4))
			_rysuj_przedmiot(p, r)
			if r.has_point(mysz) and _ciag.is_empty() and p.get("odkryty", true):
				najechany = p
	# przeciągany przedmiot i podgląd miejsca
	if not _ciag.is_empty():
		var w := Pojemnik.wymiary(_ciag, _ciag_obr)
		var cel := _cel_pod_mysza(mysz)
		if not cel.is_empty():
			var poj: Pojemnik = cel["poj"]
			var ok := poj.przyjmuje(_ciag) and poj.wolne(cel["x"], cel["y"], w.x, w.y)
			var r := Rect2((cel["pos"] as Vector2) + Vector2(cel["x"], cel["y"]) * POLE, Vector2(w.x, w.y) * POLE - Vector2(2, 2))
			draw_rect(r, Color(0.35, 0.55, 0.3, 0.35) if ok else Color(0.6, 0.2, 0.15, 0.35))
		_rysuj_przedmiot(_ciag, Rect2(mysz - Vector2(POLE, POLE) * 0.5, Vector2(w.x, w.y) * POLE - Vector2(4, 4)), 0.85)
	elif not najechany.is_empty():
		_podpowiedz(najechany, mysz)
	if not Ekwipunek.ladowanie.is_empty():
		_tekst(Vector2(430, size.y - 96), tr("E_LADOWANIE"), 18, Color("d9a05a"))
	_tekst(Vector2(60, size.y - 80), tr("E_DWUKLIK"), 16, Color("8f8872"))
	_tekst(Vector2(60, size.y - 56), tr("E_PODPOWIEDZ"), 16, Color("8f8872"))


func _rysuj_przedmiot(p: Dictionary, r: Rect2, alfa := 1.0) -> void:
	if not p.get("odkryty", true):
		draw_rect(r, Color(0.05, 0.05, 0.05, 0.95))
		_tekst(r.position + Vector2(r.size.x * 0.5 - 6, r.size.y * 0.5 + 8), "?", 24, Color("5c574a"))
		return
	var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
	var kolor := Color(def["kolor"])
	kolor.a = alfa
	draw_rect(r, kolor)
	draw_rect(r, kolor.lightened(0.35), false, 2.0)
	var nazwa := tr(def["nazwa"])
	var slowa := nazwa.split(" ")
	var yy := 15.0
	for s in slowa:
		if yy > r.size.y - 4:
			break
		_tekst(r.position + Vector2(3, yy), s, 11, Color(0.93, 0.9, 0.82, alfa), r.size.x - 4)
		yy += 13.0
	if p["dane"].has("ile"):
		_tekst(r.position + Vector2(4, r.size.y - 5), "×%d" % int(p["dane"]["ile"]), 13, Color(1, 0.95, 0.7, alfa))
	if p["dane"].has("porcje"):
		_tekst(r.position + Vector2(4, r.size.y - 5), "%d/%d" % [int(p["dane"]["porcje"]), int(def["porcje"])], 13, Color(0.75, 0.9, 1.0, alfa))
	if not Ekwipunek.ladowanie.is_empty() and is_same(Ekwipunek.ladowanie["mag"], p):
		draw_rect(r, Color("d9a05a"), false, 3.0)


func _podpowiedz(p: Dictionary, mysz: Vector2) -> void:
	var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
	var linie := [tr(def["nazwa"]), "%.2f kg" % Ekwipunek.masa_przedmiotu(p)]
	if p["dane"].has("naboje"):
		linie.append(Ekwipunek.opis_magazynka(p))
		var naboje: Array = p["dane"]["naboje"]
		if not naboje.is_empty():
			linie.append(tr("E_NA_WIERZCHU") + ": " + tr(naboje[-1]))
	if p["dane"].has("typ"):
		linie.append(tr(p["dane"]["typ"]))
	if p["dane"].has("porcje"):
		linie.append("%s: %d" % [tr("E_PORCJE"), int(p["dane"]["porcje"])])
	if def.has("siatka"):
		linie.append("%s: %d×%d" % [tr("E_POJEMNOSC"), def["siatka"].x, def["siatka"].y])
	var szer := 0.0
	for l in linie:
		szer = maxf(szer, _czcionka.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x)
	var pos := mysz + Vector2(18, 14)
	pos.x = minf(pos.x, size.x - szer - 30)
	var r := Rect2(pos, Vector2(szer + 20, linie.size() * 22 + 12))
	draw_rect(r, Color(0.03, 0.03, 0.035, 0.96))
	draw_rect(r, Color("5a5140"), false, 1.0)
	for i in linie.size():
		_tekst(pos + Vector2(10, 24 + i * 22), linie[i], 16, Color("e6dcc0") if i == 0 else Color("bdb59c"))


## Pole siatki pod kursorem: {poj, pos, x, y} albo {}.
func _cel_pod_mysza(mysz: Vector2) -> Dictionary:
	for o in _obszary:
		var poj: Pojemnik = o["poj"]
		var lok: Vector2 = (mysz - (o["pos"] as Vector2)) / POLE
		if lok.x >= 0 and lok.y >= 0 and lok.x < poj.szer and lok.y < poj.wys:
			return {"poj": poj, "pos": o["pos"], "x": int(lok.x), "y": int(lok.y)}
	return {}


func _odloz_ciagniety() -> void:
	if _ciag.is_empty():
		return
	if not _ciag_z.wloz(_ciag, _ciag_start["x"], _ciag_start["y"], _ciag_start["obr"]):
		if not _ciag_z.wloz_gdziekolwiek(_ciag) and not Ekwipunek.podnies(_ciag):
			gra.swiat.upusc(_ciag, gra.swiat.gracz.global_position + Vector3.UP * 0.8)
	_ciag = {}
	Ekwipunek.zmiana.emit()


func _input(ev: InputEvent) -> void:
	if visible and not _ciag.is_empty() and ev.is_action_pressed("obroc"):
		_ciag_obr = not _ciag_obr
		get_viewport().set_input_as_handled()


func _gui_input(ev: InputEvent) -> void:
	if not (ev is InputEventMouseButton):
		return
	var mb := ev as InputEventMouseButton
	var cel := _cel_pod_mysza(mb.position)
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed and mb.double_click:
		_odloz_ciagniety()
		if not cel.is_empty():
			var pojd: Pojemnik = cel["poj"]
			var pd := pojd.na_polu(cel["x"], cel["y"])
			if not pd.is_empty() and pd.get("odkryty", true):
				_uzyj(pd, pojd)
		return
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		if cel.is_empty():
			return
		var poj: Pojemnik = cel["poj"]
		var p := poj.na_polu(cel["x"], cel["y"])
		if p.is_empty() or not p.get("odkryty", true):
			return
		Ekwipunek.przerwij_ladowanie()
		if mb.ctrl_pressed:
			_szybko_przenies(p, poj)
			return
		_ciag = p
		_ciag_z = poj
		_ciag_start = {"x": p["x"], "y": p["y"], "obr": p["obr"]}
		_ciag_obr = p["obr"]
		poj.usun(p)
	elif mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed and not _ciag.is_empty():
		if cel.is_empty():
			_odloz_ciagniety()
			return
		var poj: Pojemnik = cel["poj"]
		var na_celu := poj.na_polu(cel["x"], cel["y"])
		# paczka naboi upuszczona na magazynek (albo odwrotnie) zaczyna ładowanie
		if not na_celu.is_empty():
			var a := _ciag
			_odloz_ciagniety()
			if not Ekwipunek.zacznij_ladowanie(na_celu, a):
				Ekwipunek.zacznij_ladowanie(a, na_celu)
			return
		if poj.wloz(_ciag, cel["x"], cel["y"], _ciag_obr):
			_ciag = {}
			Dzwiek.przy_uchu("klik", -10.0, 0.2)
			Ekwipunek.zmiana.emit()
		else:
			_odloz_ciagniety()
	elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed and _ciag.is_empty() and not cel.is_empty():
		var poj: Pojemnik = cel["poj"]
		var p := poj.na_polu(cel["x"], cel["y"])
		if not p.is_empty() and p.get("odkryty", true):
			poj.usun(p)
			var g: Gracz = gra.swiat.gracz
			gra.swiat.upusc(p, g.global_position + Vector3.UP * 1.0 - g.global_transform.basis.z * 0.5, -g.global_transform.basis.z * 1.5)
			Ekwipunek.zmiana.emit()


## Ctrl+klik: z łupu do siebie, od siebie do łupu, a bez łupu między plecakiem i kamizelką.
func _szybko_przenies(p: Dictionary, z: Pojemnik) -> void:
	z.usun(p)
	var ok := false
	if z == lup:
		ok = Ekwipunek.podnies(p)
	elif lup != null:
		ok = lup.wloz_gdziekolwiek(p)
	elif z == Ekwipunek.plecak:
		ok = Ekwipunek.kamizelka.wloz_gdziekolwiek(p) or Ekwipunek.kieszenie.wloz_gdziekolwiek(p)
	elif Ekwipunek.plecak != null:
		ok = Ekwipunek.plecak.wloz_gdziekolwiek(p)
	if not ok:
		z.wloz(p, p["x"], p["y"], p["obr"])
		gra.hud.komunikat(tr("E_BRAK_MIEJSCA"))
	else:
		Dzwiek.przy_uchu("klik", -10.0, 0.2)
	Ekwipunek.zmiana.emit()


## Dwuklik: lek leczy, jedzenie i picie są spożywane, kamizelka i plecak zakładane.
func _uzyj(p: Dictionary, z: Pojemnik) -> void:
	var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
	var zdrowie: Zdrowie = gra.swiat.gracz.zdrowie
	match def["typ"]:
		"lek":
			if z != lup or Ekwipunek.podnies(_wyjety(p, z)):
				zdrowie.zacznij_uzycie(p["id"])
		"jedzenie", "picie":
			if z == lup:
				if not Ekwipunek.podnies(_wyjety(p, z)):
					z.wloz_gdziekolwiek(p)
					gra.hud.komunikat(tr("E_BRAK_MIEJSCA"))
					return
			zdrowie.zacznij_spozycie(p)
		"kamizelka", "plecak":
			if Ekwipunek.zamien_noszone(p, z):
				gra.hud.komunikat(tr("E_ZALOZONO") + ": " + tr(def["nazwa"]))
				Dzwiek.przy_uchu("bron_wyjmij", -6.0)
			else:
				gra.hud.komunikat(tr("E_NIE_MIESCI") if def["typ"] == "kamizelka" else tr("E_BRAK_MIEJSCA"))


func _wyjety(p: Dictionary, z: Pojemnik) -> Dictionary:
	z.usun(p)
	return p
