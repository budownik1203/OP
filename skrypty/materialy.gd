class_name Mat
extends RefCounted
## Materiały stylu „hybryda fasetowa”: małe tekstury bez wygładzania,
## ograniczona paleta, światło liczone na płaskich ściankach.

static var _pamiec := {}


## Tekstura szumu skwantowana do kilku odcieni palety.
static func tekstura(nazwa: String, paleta: Array, rozmiar := 64, czest := 0.08, ziarno := 1, pasy := 0.0, mur := false) -> ImageTexture:
	var klucz := "t_" + nazwa
	if _pamiec.has(klucz):
		return _pamiec[klucz]
	var szum := FastNoiseLite.new()
	szum.seed = ziarno
	szum.frequency = czest
	szum.noise_type = FastNoiseLite.TYPE_SIMPLEX
	szum.fractal_octaves = 3
	var drobny := FastNoiseLite.new()
	drobny.seed = ziarno + 77
	drobny.frequency = czest * 6.0
	var img := Image.create(rozmiar, rozmiar, true, Image.FORMAT_RGB8)
	var n := paleta.size()
	for y in rozmiar:
		for x in rozmiar:
			# szum zawijany, żeby tekstura kafelkowała się bez szwów
			var u := float(x) / rozmiar * TAU
			var v := float(y) / rozmiar * TAU
			var r := rozmiar / TAU
			var a := szum.get_noise_3d(cos(u) * r, sin(u) * r, cos(v) * r + sin(v) * r * 1.7)
			var b := drobny.get_noise_3d(cos(u) * r, sin(u) * r + 31.0, cos(v) * r + sin(v) * r * 1.7)
			var w := a * 0.75 + b * 0.25
			if pasy > 0.0:
				w += sin(float(y) / rozmiar * TAU * pasy + a * 3.0) * 0.35
			var i := clampi(int((w * 0.5 + 0.5) * n), 0, n - 1)
			if mur:
				# ciosy kamienne: 4 warstwy na kafel, co druga przesunięta
				var warstwa := int(y * 4 / rozmiar)
				var xp := (x + (rozmiar / 4 if warstwa % 2 == 1 else 0)) % (rozmiar / 2)
				if y % (rozmiar / 4) == 0 or xp == 0:
					i = 0
				else:
					i = clampi(i + 1 + (warstwa * 7 + int((x + (rozmiar / 4 if warstwa % 2 == 1 else 0)) / (rozmiar / 2)) * 3) % 2 - 1, 1, n - 1)
			img.set_pixel(x, y, paleta[i])
	img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	_pamiec[klucz] = t
	return t


static func _baza(nazwa: String, tex: Texture2D, skala: float, szorstkosc: float, metal: float) -> StandardMaterial3D:
	if _pamiec.has(nazwa):
		return _pamiec[nazwa]
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE * skala
	m.roughness = szorstkosc
	m.metallic = metal
	m.metallic_specular = 0.3
	_pamiec[nazwa] = m
	return m


static func kamien() -> StandardMaterial3D:
	var p := [Color("2b2a2c"), Color("3a383a"), Color("46433f"), Color("524d47"), Color("5f584f")]
	return _baza("kamien", tekstura("kamien", p, 64, 0.16, 11, 0.0, true), 0.42, 0.95, 0.0)


static func kamien_ciemny() -> StandardMaterial3D:
	var p := [Color("1c1b1e"), Color("262528"), Color("302e2f"), Color("3a3735")]
	return _baza("kamien_c", tekstura("kamien_c", p, 64, 0.18, 12, 0.0, true), 0.42, 0.95, 0.0)


static func ziemia() -> StandardMaterial3D:
	var p := [Color("231d17"), Color("2e261d"), Color("3a3023"), Color("3f3a2a"), Color("2f3322")]
	return _baza("ziemia", tekstura("ziemia", p, 64, 0.30, 21), 0.55, 1.0, 0.0)


static func drewno() -> StandardMaterial3D:
	var p := [Color("2a1d13"), Color("3a2819"), Color("4a3420"), Color("5a4129")]
	return _baza("drewno", tekstura("drewno", p, 64, 0.05, 31, 9.0), 1.2, 0.9, 0.0)


static func stal(klasa := 3) -> StandardMaterial3D:
	var nazwa := "stal_%d" % klasa
	if _pamiec.has(nazwa):
		return _pamiec[nazwa]
	var jasnosc := 0.75 + 0.07 * klasa
	var p := [Color("3c3d40") * jasnosc, Color("4b4d50") * jasnosc, Color("5b5d60") * jasnosc, Color("6a6c6e") * jasnosc, Color("5a4638") * jasnosc]
	var m := _baza(nazwa, tekstura(nazwa, p, 32, 0.22, 40 + klasa), 2.5, 0.6, 0.3)
	return m


static func cialo() -> StandardMaterial3D:
	var p := [Color("6d5a4c"), Color("7a6656"), Color("86705e")]
	return _baza("cialo", tekstura("cialo", p, 32, 0.10, 51), 2.0, 0.9, 0.0)


static func plotno() -> StandardMaterial3D:
	var p := [Color("3d3a2c"), Color("48452f"), Color("545036")]
	return _baza("plotno", tekstura("plotno", p, 32, 0.20, 61), 3.0, 1.0, 0.0)


static func kolor(c: Color, szorstkosc := 0.9, metal := 0.0) -> StandardMaterial3D:
	var nazwa := "k_%s_%s_%s" % [c.to_html(), szorstkosc, metal]
	if _pamiec.has(nazwa):
		return _pamiec[nazwa]
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = szorstkosc
	m.metallic = metal
	_pamiec[nazwa] = m
	return m


static func swiecacy(c: Color, moc := 2.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c * moc
	return m


## Pudełko z kolizją. Zwraca StaticBody3D.
static func blok(rodzic: Node, rozmiar: Vector3, pozycja: Vector3, material: Material, kolizja := true, obrot := Vector3.ZERO) -> Node3D:
	var siatka := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = rozmiar
	siatka.mesh = bm
	siatka.material_override = material
	if not kolizja:
		siatka.position = pozycja
		siatka.rotation = obrot
		rodzic.add_child(siatka)
		return siatka
	var cialo_s := StaticBody3D.new()
	cialo_s.position = pozycja
	cialo_s.rotation = obrot
	var ks := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = rozmiar
	ks.shape = bs
	cialo_s.add_child(ks)
	cialo_s.add_child(siatka)
	rodzic.add_child(cialo_s)
	return cialo_s


## Dach dwuspadowy albo hełm wieży: graniastosłup o trójkątnym przekroju wzdłuż osi Z.
static func daszek(rodzic: Node, szer: float, wys: float, dl: float, pozycja: Vector3, material: Material, obrot_y := 0.0) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := Vector3(-szer * 0.5, 0.0, -dl * 0.5)
	var b := Vector3(szer * 0.5, 0.0, -dl * 0.5)
	var c := Vector3(0.0, wys, -dl * 0.5)
	var d := Vector3(-szer * 0.5, 0.0, dl * 0.5)
	var e := Vector3(szer * 0.5, 0.0, dl * 0.5)
	var f := Vector3(0.0, wys, dl * 0.5)
	for t in [[a, c, b], [d, e, f], [a, d, f], [a, f, c], [b, c, f], [b, f, e], [a, b, e], [a, e, d]]:
		for v in t:
			st.add_vertex(v)
	st.generate_normals()
	var s := MeshInstance3D.new()
	s.mesh = st.commit()
	s.material_override = material
	s.position = pozycja
	s.rotation.y = obrot_y
	rodzic.add_child(s)
	return s
