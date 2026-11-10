extends Node3D
## Przeglądarka modeli do kontroli jakości:
## godot res://sceny/podglad.tscn -- --model=res://zasoby/modele/x.glb --wyjscie=/sciezka
## Zapisuje rzuty prostokątne z kilku stron. Służy do sprawdzania proporcji.

var _model: Node3D
var _kamera: Camera3D
var _widoki: Array = []
var _i := 0
var _czekaj := 20
var _wyjscie := "user://podglad"
var _nazwa := "model"
var _srodek := Vector3.ZERO
var _rozmiar := 1.0


func _ready() -> void:
	var sciezka := ""
	var ukryj := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--model="):
			sciezka = a.trim_prefix("--model=")
		elif a.begins_with("--wyjscie="):
			_wyjscie = a.trim_prefix("--wyjscie=")
		elif a.begins_with("--ukryj="):
			ukryj = a.trim_prefix("--ukryj=")
	if sciezka == "":
		get_tree().quit()
		return
	_nazwa = sciezka.get_file().get_basename()
	DirAccess.make_dir_recursive_absolute(_wyjscie)
	_model = (load(sciezka) as PackedScene).instantiate()
	add_child(_model)
	for n in ukryj.split(",", false):
		var w := _model.find_child(n, true, false)
		if w:
			(w as Node3D).visible = false
	var aabb := AABB()
	var pierwszy := true
	for s in _model.find_children("*", "MeshInstance3D", true, false):
		var mi := s as MeshInstance3D
		if not mi.is_visible_in_tree():
			continue
		for i in mi.mesh.get_surface_count():
			var mat := mi.mesh.surface_get_material(i)
			if mat is BaseMaterial3D:
				(mat as BaseMaterial3D).texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		var b := mi.global_transform * mi.get_aabb()
		aabb = b if pierwszy else aabb.merge(b)
		pierwszy = false
	_srodek = aabb.get_center()
	_rozmiar = maxf(aabb.size.x, maxf(aabb.size.y, aabb.size.z))
	var srod := Environment.new()
	srod.background_mode = Environment.BG_COLOR
	srod.background_color = Color(0.42, 0.44, 0.46)
	srod.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	srod.ambient_light_color = Color(0.55, 0.57, 0.6)
	srod.ambient_light_energy = 0.9
	var we := WorldEnvironment.new()
	we.environment = srod
	add_child(we)
	var sw := DirectionalLight3D.new()
	sw.rotation_degrees = Vector3(-40, -35, 0)
	sw.light_energy = 1.3
	add_child(sw)
	var sw2 := DirectionalLight3D.new()
	sw2.rotation_degrees = Vector3(-20, 150, 0)
	sw2.light_energy = 0.5
	add_child(sw2)
	_kamera = Camera3D.new()
	_kamera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_kamera.size = _rozmiar * 0.62
	_kamera.near = 0.01
	_kamera.far = 50.0
	add_child(_kamera)
	_kamera.make_current()
	# [nazwa, kierunek patrzenia od kamery do modelu]
	_widoki = [
		["prawa", Vector3(-1, 0, 0)], ["lewa", Vector3(1, 0, 0)], ["gora", Vector3(0, -1, 0.001)],
		["przod", Vector3(0, 0, 1)], ["tyl", Vector3(0, 0, -1)],
		["ukos_p", Vector3(-0.7, -0.35, -0.6)], ["ukos_l", Vector3(0.7, -0.35, 0.6)],
		["strzelec", Vector3(0.28, -0.45, -0.85)],
	]


func _process(_dt: float) -> void:
	_czekaj -= 1
	if _czekaj > 0:
		return
	if _i > 0:
		get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [_wyjscie, _nazwa, _widoki[_i - 1][0]])
	if _i >= _widoki.size():
		get_tree().quit()
		return
	var kier: Vector3 = (_widoki[_i][1] as Vector3).normalized()
	_kamera.global_position = _srodek - kier * (_rozmiar * 2.0 + 1.0)
	_kamera.look_at(_srodek, Vector3.UP if absf(kier.y) < 0.9 else Vector3.FORWARD)
	_i += 1
	_czekaj = 6
