class_name Ikony
extends RefCounted
## Ikony przedmiotów rysowane wektorowo w polu siatki (bez plików graficznych)
## oraz ikony broni renderowane z modeli 3D przy starcie gry.

static var bron := {}            ## id broni -> ImageTexture (profil broni bez rąk)


## Rysuje ikonę przedmiotu p w prostokącie r na kontrolce ci.
static func rysuj(ci: CanvasItem, p: Dictionary, r: Rect2, alfa := 1.0) -> void:
	var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
	var id: String = p["id"]
	var k := Color(def["kolor"])
	# tło: ciemne pole z lekkim odcieniem kategorii, jak w Tarkovie
	var tlo := Color(0.085, 0.09, 0.10).lerp(k, 0.22)
	tlo.a = alfa
	ci.draw_rect(r, tlo)
	var ram := k.lightened(0.25)
	ram.a = alfa * 0.9
	ci.draw_rect(r, ram, false, 1.0)
	# obszar rysunku: pod nazwą, nad licznikiem
	var o := Rect2(r.position + Vector2(5, 16), r.size - Vector2(10, 24))
	if o.size.x < 8 or o.size.y < 8:
		return
	var c := o.get_center()
	var s := minf(o.size.x, o.size.y)
	var jasny := k.lightened(0.45)
	jasny.a = alfa
	var sredni := k.lightened(0.18)
	sredni.a = alfa
	var ciemny := k.darkened(0.45)
	ciemny.a = alfa
	var mosiadz := Color(0.78, 0.62, 0.25, alfa)
	var stal := Color(0.62, 0.64, 0.68, alfa)
	match String(def["typ"]):
		"mag", "wewn":
			# magazynek: pudełko (łukowe dla karabinowych) z okienkiem pokazującym stan załadowania
			var w := minf(o.size.x * 0.52, 26.0)
			var h := o.size.y * 0.92
			var luk := 0.18 if def["kaliber"] in ["5.56x45", "7.62x39"] else 0.0
			var pts := PackedVector2Array([
				c + Vector2(-w * 0.5, -h * 0.5), c + Vector2(w * 0.5, -h * 0.5),
				c + Vector2(w * 0.5 + w * luk, 0), c + Vector2(w * 0.5 + w * luk * 2.2, h * 0.5),
				c + Vector2(-w * 0.5 + w * luk * 2.2, h * 0.5), c + Vector2(-w * 0.5 + w * luk, 0)])
			ci.draw_colored_polygon(pts, sredni)
			ci.draw_polyline(pts + PackedVector2Array([pts[0]]), jasny, 1.0)
			ci.draw_rect(Rect2(c + Vector2(-w * 0.5, -h * 0.5 - 2), Vector2(w, 4)), stal)
			if p["dane"].has("naboje"):
				var pelny := float((p["dane"]["naboje"] as Array).size()) / maxf(float(def["poj"]), 1.0)
				var sl := Rect2(c + Vector2(-w * 0.5 + w * luk * 2.2 - 6, -h * 0.5 + 4), Vector2(3, h - 8))
				ci.draw_rect(sl, ciemny)
				ci.draw_rect(Rect2(sl.position + Vector2(0, sl.size.y * (1.0 - pelny)), Vector2(3, sl.size.y * pelny)), mosiadz)
		"amunicja":
			# trzy naboje: łuska, pocisk; śrut jako krótkie, grube łuski
			var srut: bool = def["kaliber"] == "12/70"
			for i in 3:
				var x := c.x + (i - 1) * s * 0.26
				var hh := s * (0.50 if srut else 0.62)
				var ww := s * (0.20 if srut else 0.13)
				ci.draw_rect(Rect2(x - ww * 0.5, c.y - hh * 0.2, ww, hh * 0.7), Color(0.62, 0.16, 0.12, alfa) if srut else mosiadz)
				if srut:
					ci.draw_rect(Rect2(x - ww * 0.5, c.y + hh * 0.3, ww, hh * 0.2), mosiadz)
				else:
					ci.draw_colored_polygon(PackedVector2Array([Vector2(x - ww * 0.5, c.y - hh * 0.2), Vector2(x + ww * 0.5, c.y - hh * 0.2), Vector2(x, c.y - hh * 0.62)]), Color(0.72, 0.45, 0.25, alfa))
		"lek":
			match id:
				"bandaz":
					ci.draw_circle(c, s * 0.36, jasny)
					ci.draw_arc(c, s * 0.24, 0, TAU, 20, sredni, 2.0)
					ci.draw_circle(c, s * 0.09, ciemny)
				"szyna":
					ci.draw_rect(Rect2(c + Vector2(-s * 0.22, -o.size.y * 0.46), Vector2(s * 0.44, o.size.y * 0.92)), sredni)
					for i in 3:
						ci.draw_rect(Rect2(c + Vector2(-s * 0.28, -o.size.y * 0.32 + i * o.size.y * 0.3), Vector2(s * 0.56, 5)), jasny)
				"przeciwbolowe":
					ci.draw_rect(Rect2(c - Vector2(s * 0.40, s * 0.28), Vector2(s * 0.80, s * 0.56)), sredni)
					for ix in 3:
						for iy in 2:
							ci.draw_circle(c + Vector2((ix - 1) * s * 0.24, (iy - 0.5) * s * 0.26), s * 0.075, Color(0.92, 0.9, 0.86, alfa))
				_:
					# opatrunek i apteczka: pakiet z krzyżem
					var pak := Rect2(c - Vector2(minf(o.size.x * 0.42, s * 0.8), s * 0.36), Vector2(minf(o.size.x * 0.84, s * 1.6), s * 0.72))
					ci.draw_rect(pak, sredni)
					ci.draw_rect(pak, jasny, false, 1.0)
					var kk := Color(0.9, 0.88, 0.82, alfa) if id == "apteczka" else Color(0.7, 0.16, 0.13, alfa)
					ci.draw_rect(Rect2(c - Vector2(s * 0.07, s * 0.24), Vector2(s * 0.14, s * 0.48)), kk)
					ci.draw_rect(Rect2(c - Vector2(s * 0.24, s * 0.07), Vector2(s * 0.48, s * 0.14)), kk)
		"jedzenie":
			if id == "konserwa":
				ci.draw_rect(Rect2(c - Vector2(s * 0.34, s * 0.30), Vector2(s * 0.68, s * 0.60)), stal)
				ci.draw_rect(Rect2(c - Vector2(s * 0.34, s * 0.10), Vector2(s * 0.68, s * 0.22)), Color(0.55, 0.2, 0.15, alfa))
				ci.draw_line(c + Vector2(-s * 0.34, -s * 0.30), c + Vector2(s * 0.34, -s * 0.30), jasny, 2.0)
			elif id == "suchary":
				for i in 3:
					ci.draw_rect(Rect2(c + Vector2(-s * 0.36 + i * 4, -s * 0.30 + i * s * 0.16), Vector2(s * 0.62, s * 0.24)), jasny if i == 2 else sredni)
			else:
				var pak2 := Rect2(c - Vector2(s * 0.36, o.size.y * 0.44), Vector2(s * 0.72, o.size.y * 0.88))
				ci.draw_rect(pak2, sredni)
				ci.draw_rect(pak2, jasny, false, 1.0)
				ci.draw_rect(Rect2(pak2.position + Vector2(4, pak2.size.y * 0.3), Vector2(pak2.size.x - 8, 3)), ciemny)
				ci.draw_rect(Rect2(pak2.position + Vector2(4, pak2.size.y * 0.3 + 7), Vector2(pak2.size.x * 0.5, 3)), ciemny)
		"picie":
			var hc := o.size.y * 0.80
			ci.draw_rect(Rect2(c + Vector2(-s * 0.09, -hc * 0.5 - 2), Vector2(s * 0.18, hc * 0.2)), stal)
			var kor := PackedVector2Array()
			for i in 16:
				var a := TAU * i / 16.0
				kor.append(c + Vector2(cos(a) * s * 0.32, hc * 0.12 + sin(a) * hc * 0.38))
			ci.draw_colored_polygon(kor, sredni)
			ci.draw_polyline(kor + PackedVector2Array([kor[0]]), jasny, 1.0)
		"kamizelka":
			var pk := PackedVector2Array([c + Vector2(-s * 0.42, -s * 0.36), c + Vector2(-s * 0.18, -s * 0.42), c + Vector2(0, -s * 0.26), c + Vector2(s * 0.18, -s * 0.42), c + Vector2(s * 0.42, -s * 0.36), c + Vector2(s * 0.36, s * 0.40), c + Vector2(-s * 0.36, s * 0.40)])
			if id == "pas":
				pk = PackedVector2Array([c + Vector2(-o.size.x * 0.46, -s * 0.14), c + Vector2(o.size.x * 0.46, -s * 0.14), c + Vector2(o.size.x * 0.46, s * 0.14), c + Vector2(-o.size.x * 0.46, s * 0.14)])
			ci.draw_colored_polygon(pk, sredni)
			ci.draw_polyline(pk + PackedVector2Array([pk[0]]), jasny, 1.0)
			for i in 3:
				ci.draw_rect(Rect2(c + Vector2((i - 1) * s * 0.24 - s * 0.09, s * 0.02 if id != "pas" else -s * 0.10), Vector2(s * 0.18, s * 0.28 if id != "pas" else s * 0.20)), ciemny)
		"plecak":
			var bw := minf(o.size.x * 0.40, s * 0.44)
			var bh := o.size.y * 0.42
			var pp := PackedVector2Array([c + Vector2(-bw * 0.8, -bh), c + Vector2(bw * 0.8, -bh), c + Vector2(bw, -bh * 0.6), c + Vector2(bw, bh), c + Vector2(-bw, bh), c + Vector2(-bw, -bh * 0.6)])
			ci.draw_colored_polygon(pp, sredni)
			ci.draw_polyline(pp + PackedVector2Array([pp[0]]), jasny, 1.0)
			ci.draw_rect(Rect2(c + Vector2(-bw * 0.6, bh * 0.15), Vector2(bw * 1.2, bh * 0.6)), ciemny)
			ci.draw_line(c + Vector2(-bw, -bh * 0.25), c + Vector2(bw, -bh * 0.25), jasny, 1.0)
			ci.draw_arc(c + Vector2(0, -bh), bw * 0.3, PI, TAU, 8, jasny, 2.0)
		"dodatek":
			if def["slot"] == "wylot":
				var dl := o.size.y * 0.86 if int(def["h"]) > 1 else s * 0.8
				if int(def["h"]) > 1:
					ci.draw_rect(Rect2(c - Vector2(s * 0.15, dl * 0.5), Vector2(s * 0.30, dl)), sredni.lightened(0.15))
					ci.draw_rect(Rect2(c + Vector2(-s * 0.09, dl * 0.5 - 3), Vector2(s * 0.18, 5)), stal)
				else:
					ci.draw_rect(Rect2(c - Vector2(dl * 0.5, s * 0.14), Vector2(dl, s * 0.28)), sredni.lightened(0.15))
					ci.draw_rect(Rect2(c + Vector2(dl * 0.5 - 3, -s * 0.08), Vector2(5, s * 0.16)), stal)
			elif def["slot"] == "chwyt":
				ci.draw_rect(Rect2(c + Vector2(-s * 0.30, -s * 0.34), Vector2(s * 0.60, s * 0.14)), stal)
				ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.12, -s * 0.20), c + Vector2(s * 0.12, -s * 0.20), c + Vector2(s * 0.16, s * 0.38), c + Vector2(-s * 0.16, s * 0.38)]), sredni.lightened(0.2))
			else:
				ci.draw_rect(Rect2(c + Vector2(-s * 0.34, s * 0.14), Vector2(s * 0.68, s * 0.16)), sredni.lightened(0.2))
				var okno := Rect2(c + Vector2(-s * 0.26, -s * 0.34), Vector2(s * 0.52, s * 0.48))
				ci.draw_rect(okno, Color(0.18, 0.24, 0.28, alfa))
				ci.draw_rect(okno, stal, false, 2.0)
				ci.draw_circle(okno.get_center(), 2.5, Color(0.95, 0.2, 0.15, alfa))
				if id == "holo":
					ci.draw_arc(okno.get_center(), s * 0.13, 0, TAU, 16, Color(0.95, 0.2, 0.15, alfa), 1.0)
		"narzedzie":
			ci.draw_line(c + Vector2(0, -o.size.y * 0.36), c + Vector2(0, o.size.y * 0.46), Color(0.5, 0.36, 0.2, alfa), 4.0)
			ci.draw_arc(c + Vector2(0, -o.size.y * 0.10), o.size.x * 0.46, PI * 1.15, PI * 1.85, 10, stal, 4.0)
		"lup":
			match id:
				"monety":
					for i in 4:
						ci.draw_circle(c + Vector2((i % 2 - 0.5) * s * 0.3, (i / 2 - 0.5) * s * 0.26 + (i % 2) * 3), s * 0.17, Color(0.72, 0.6, 0.22, alfa))
						ci.draw_arc(c + Vector2((i % 2 - 0.5) * s * 0.3, (i / 2 - 0.5) * s * 0.26 + (i % 2) * 3), s * 0.17, 0, TAU, 12, Color(0.4, 0.32, 0.1, alfa), 1.0)
				"klucz":
					ci.draw_arc(c + Vector2(-s * 0.2, 0), s * 0.15, 0, TAU, 12, stal, 3.0)
					ci.draw_line(c + Vector2(-s * 0.05, 0), c + Vector2(s * 0.38, 0), stal, 3.0)
					ci.draw_line(c + Vector2(s * 0.26, 0), c + Vector2(s * 0.26, s * 0.14), stal, 3.0)
					ci.draw_line(c + Vector2(s * 0.36, 0), c + Vector2(s * 0.36, s * 0.12), stal, 3.0)
				"relikwia":
					ci.draw_rect(Rect2(c - Vector2(s * 0.07, o.size.y * 0.40), Vector2(s * 0.14, o.size.y * 0.80)), Color(0.75, 0.62, 0.3, alfa))
					ci.draw_rect(Rect2(c - Vector2(s * 0.30, o.size.y * 0.20), Vector2(s * 0.60, s * 0.14)), Color(0.75, 0.62, 0.3, alfa))
					ci.draw_circle(c + Vector2(0, -o.size.y * 0.13), s * 0.08, jasny)
				_:
					var se := PackedVector2Array()
					for i in 14:
						var a := TAU * i / 14.0
						se.append(c + Vector2(cos(a) * s * (0.34 + 0.06 * sin(a * 3.0)), sin(a) * s * 0.38))
					ci.draw_colored_polygon(se, Color(0.42, 0.14, 0.14, alfa))
					ci.draw_polyline(se + PackedVector2Array([se[0]]), jasny, 1.0)
					ci.draw_line(c + Vector2(-s * 0.1, -s * 0.36), c + Vector2(-s * 0.16, -s * 0.5), jasny, 3.0)
					ci.draw_line(c + Vector2(s * 0.1, -s * 0.36), c + Vector2(s * 0.2, -s * 0.5), jasny, 3.0)
		_:
			# surowce
			if id.begins_with("luski"):
				for i in 4:
					var x := c.x + (i - 1.5) * s * 0.2
					ci.draw_rect(Rect2(x - s * 0.06, c.y - s * 0.22 + (i % 2) * 4, s * 0.12, s * 0.44), mosiadz if id != "luski_12" else Color(0.62, 0.16, 0.12, alfa))
					ci.draw_rect(Rect2(x - s * 0.06, c.y - s * 0.22 + (i % 2) * 4, s * 0.12, 3), ciemny)
			elif id.begins_with("sztabka"):
				var sz := PackedVector2Array([c + Vector2(-s * 0.30, -s * 0.16), c + Vector2(s * 0.30, -s * 0.16), c + Vector2(s * 0.42, s * 0.20), c + Vector2(-s * 0.42, s * 0.20)])
				ci.draw_colored_polygon(sz, jasny)
				ci.draw_polyline(sz + PackedVector2Array([sz[0]]), ciemny, 1.0)
				ci.draw_line(c + Vector2(-s * 0.24, -s * 0.06), c + Vector2(s * 0.24, -s * 0.06), Color(1, 1, 1, alfa * 0.35), 2.0)
			elif id in ["proch", "siarka", "saletra", "splonki"]:
				ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.40, s * 0.28), c + Vector2(-s * 0.12, -s * 0.12), c + Vector2(s * 0.06, -s * 0.22), c + Vector2(s * 0.40, s * 0.28)]), jasny)
				for i in 5:
					ci.draw_circle(c + Vector2((i - 2) * s * 0.13, s * 0.14 - absf(i - 2) * 2.0), 1.6, ciemny)
			elif id == "kosc":
				ci.draw_line(c + Vector2(-s * 0.28, s * 0.22), c + Vector2(s * 0.28, -s * 0.22), jasny, 5.0)
				for e in [Vector2(-s * 0.30, s * 0.24), Vector2(s * 0.30, -s * 0.24)]:
					ci.draw_circle(c + e + Vector2(-3, -2), 4.5, jasny)
					ci.draw_circle(c + e + Vector2(3, 2), 4.5, jasny)
			elif id == "sciegna":
				for i in 3:
					ci.draw_arc(c + Vector2(0, (i - 1) * s * 0.16), s * 0.3, PI * 0.1, PI * 0.9, 10, jasny, 2.0)
			else:
				# bryła rudy, węgla albo gruczoł: nieregularny wielokąt z żyłką
				var br := PackedVector2Array()
				var los := RandomNumberGenerator.new()
				los.seed = id.hash()
				for i in 9:
					var a := TAU * i / 9.0
					br.append(c + Vector2(cos(a), sin(a) * 0.82) * s * los.randf_range(0.28, 0.42))
				ci.draw_colored_polygon(br, sredni)
				ci.draw_polyline(br + PackedVector2Array([br[0]]), jasny, 1.0)
				ci.draw_line(br[1].lerp(c, 0.4), br[5].lerp(c, 0.5), jasny, 2.0)
				ci.draw_line(br[3].lerp(c, 0.5), br[7].lerp(c, 0.3), ciemny, 2.0)


## Renderuje profil każdej broni do tekstury. Wołane raz, po starcie; czeka kilka klatek.
static func przygotuj_bron(rodzic: Node) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(640, 256)
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	rodzic.add_child(vp)
	var kam := Camera3D.new()
	kam.projection = Camera3D.PROJECTION_ORTHOGONAL
	kam.rotation.y = PI * 0.5          # patrzy wzdłuż -X: broń widać z lewego boku, lufą w lewo
	vp.add_child(kam)
	var sw := DirectionalLight3D.new()
	sw.rotation = Vector3(-0.8, 1.9, 0)
	sw.light_energy = 1.8
	vp.add_child(sw)
	var otocz := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0, 0, 0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.75, 0.8)
	env.ambient_light_energy = 1.0
	otocz.environment = env
	vp.add_child(otocz)
	for id in Bron.GLOWNE + Bron.BOCZNE:
		var model: Node3D = (load(Bron.DANE[id]["model"]) as PackedScene).instantiate()
		for n in ["reka_p", "reka_l"]:
			var reka := model.find_child(n, true, false)
			if reka != null:
				reka.get_parent().remove_child(reka)
				reka.free()
		vp.add_child(model)
		var dl := float(Bron.DANE[id]["dlugosc"])
		# kadr: cała długość broni z zapasem; środek mniej więcej w połowie między kolbą a wylotem
		var wylot := model.find_child("wylot", true, false) as Node3D
		var przod := -wylot.position.z if wylot != null else dl * 0.6
		var tyl := maxf(dl - przod, 0.05)
		var srodek_z := -(przod - tyl) * 0.5
		kam.size = maxf(dl * 1.12 / 2.5, 0.11)
		kam.position = Vector3(2.0, -kam.size * 0.14, srodek_z)
		await rodzic.get_tree().process_frame
		await rodzic.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var obraz := vp.get_texture().get_image()
		bron[id] = ImageTexture.create_from_image(obraz)
		vp.remove_child(model)
		model.free()
	vp.queue_free()
