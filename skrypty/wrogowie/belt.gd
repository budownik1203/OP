class_name Belt
extends Node3D
## Bełt z kuszy: leci po łuku, wbija się w ściany, rani gracza przy trafieniu.

var predkosc := Vector3.ZERO
var obr := 40.0
var swiat: Swiat
var _leci := true
var _t := 0.0


func _ready() -> void:
	var drzewce := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.014, 0.014, 0.36)
	drzewce.mesh = bm
	drzewce.material_override = Mat.drewno()
	add_child(drzewce)
	var grot := MeshInstance3D.new()
	var gm := BoxMesh.new()
	gm.size = Vector3(0.024, 0.024, 0.05)
	grot.mesh = gm
	grot.position.z = -0.19
	grot.material_override = Mat.stal()
	add_child(grot)


func _physics_process(dt: float) -> void:
	_t += dt
	if not _leci:
		if _t > 40.0:
			queue_free()
		return
	predkosc.y -= 4.0 * dt
	var od := global_position
	var do := od + predkosc * dt
	var g := swiat.gracz
	# gracz: odcinek lotu mija oś ciała bliżej niż promień tułowia
	if g != null and g.zdrowie.zyje:
		for wys in [0.5, 1.0, 1.45]:
			var srodek: Vector3 = g.global_position + Vector3.UP * wys * (0.65 if g.kuca else 1.0)
			var najbl := Geometry3D.get_closest_point_to_segment(srodek, od, do)
			if najbl.distance_to(srodek) < 0.27:
				g.zdrowie.cios(obr * randf_range(0.85, 1.15), false)
				g.kopniecie(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
				Dzwiek.przy_uchu("cios", -2.0, 0.1)
				queue_free()
				return
	var q := PhysicsRayQueryParameters3D.create(od, do)
	q.collision_mask = 1
	if g != null:
		q.exclude = [g.get_rid()]
	var r := get_world_3d().direct_space_state.intersect_ray(q)
	if not r.is_empty():
		global_position = (r["position"] as Vector3) - predkosc.normalized() * 0.12
		_leci = false
		_t = 0.0
		Dzwiek.w_swiecie("uderzenie", global_position, -8.0, 0.15, 10.0)
		return
	global_position = do
	if predkosc.length() > 0.1:
		look_at(global_position + predkosc, Vector3.UP)
	if _t > 6.0:
		queue_free()
