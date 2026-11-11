extends Node3D
## Symulacja pocisków: prędkość wylotowa, opór, opad, penetracja, rykoszet.

const GRAWITACJA := 9.81
const PODKROKI := 2
const CZAS_ZYCIA := 4.0

var _lista: Array = []
var _mat_smugi: StandardMaterial3D


func _ready() -> void:
	add_to_group("pociski")
	_mat_smugi = Mat.swiecacy(Color(1.0, 0.45, 0.15), 3.0)


func wystrzel(pozycja: Vector3, kierunek: Vector3, typ: String, strzelec: CollisionObject3D) -> void:
	var a: Dictionary = Amunicja.TYPY[typ]
	var p := {
		"poz": pozycja, "v": kierunek * float(a["v0"]), "typ": typ, "a": a,
		"start": pozycja, "t": 0.0, "wyklucz": [strzelec.get_rid()] if strzelec else [],
		"mn_przeb": 1.0, "rykoszety": 0, "smuga": null,
	}
	if a["smuga"]:
		var s := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.02, 0.02, 1.6)
		s.mesh = bm
		s.material_override = _mat_smugi
		s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(s)
		s.visible = false
		p["smuga"] = s
	_lista.append(p)


func _physics_process(dt: float) -> void:
	if _lista.is_empty():
		return
	var przestrzen := get_world_3d().direct_space_state
	var i := _lista.size() - 1
	while i >= 0:
		var p: Dictionary = _lista[i]
		var zyje := true
		var h := dt / PODKROKI
		for k in PODKROKI:
			if not _krok(p, h, przestrzen):
				zyje = false
				break
		p["t"] += dt
		if p["t"] > CZAS_ZYCIA or p["poz"].y < -40.0:
			zyje = false
		var smuga: MeshInstance3D = p["smuga"]
		if zyje and smuga:
			var v: Vector3 = p["v"]
			if p["t"] > 0.02 and v.length() > 1.0:
				smuga.visible = true
				smuga.global_position = p["poz"]
				smuga.look_at(p["poz"] + v, Vector3.UP if absf(v.normalized().y) < 0.99 else Vector3.RIGHT)
		if not zyje:
			if smuga:
				smuga.queue_free()
			_lista.remove_at(i)
		i -= 1


func _krok(p: Dictionary, h: float, przestrzen: PhysicsDirectSpaceState3D) -> bool:
	var a: Dictionary = p["a"]
	var v: Vector3 = p["v"]
	var szybkosc := v.length()
	v += Vector3.DOWN * GRAWITACJA * h - v * (float(a["opor"]) * szybkosc * h)
	var od: Vector3 = p["poz"]
	var do := od + v * h
	var q := PhysicsRayQueryParameters3D.create(od, do)
	q.exclude = p["wyklucz"]
	q.collision_mask = 1 | 2
	q.collide_with_areas = true
	var hit := przestrzen.intersect_ray(q)
	if hit.is_empty():
		p["poz"] = do
		p["v"] = v
		return true
	var cialo: Object = hit["collider"]
	var kier := v.normalized()
	var wsp := clampf(szybkosc / float(a["v0"]), 0.0, 1.2)
	var info := {
		"typ": p["typ"], "przeb": float(a["przeb"]) * wsp * float(p["mn_przeb"]),
		"obr": float(a["obr"]) * wsp, "kier": kier, "poz": hit["position"],
		"normalna": hit["normal"], "dystans": (p["start"] as Vector3).distance_to(hit["position"]),
		"predkosc": szybkosc,
	}
	var swiat := get_tree().get_first_node_in_group("swiat")
	if cialo != null and cialo.has_method("trafienie"):
		var w: Dictionary = cialo.trafienie(info)
		if w.get("przechodzi", false):
			var strata := clampf(1.0 - float(w.get("prog", 0.0)) / maxf(info["przeb"], 1.0) * 0.55, 0.3, 1.0)
			p["v"] = v * strata
			p["mn_przeb"] = float(p["mn_przeb"]) * strata
			p["poz"] = hit["position"] + kier * 0.02
			(p["wyklucz"] as Array).append(hit["rid"])
			return true
		if w.get("wynik", "") == "RYKOSZET" and int(p["rykoszety"]) < 1:
			p["rykoszety"] = 1
			var odbity := v.bounce(hit["normal"]) * 0.35
			odbity += Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * odbity.length() * 0.12
			p["v"] = odbity
			p["mn_przeb"] = float(p["mn_przeb"]) * 0.3
			p["poz"] = hit["position"] + (hit["normal"] as Vector3) * 0.02
			Dzwiek.w_swiecie("rykoszet", hit["position"], -4.0, 0.15, 10.0)
			return true
		return false
	# zwykła powierzchnia: ziemia, kamień, drewno
	if swiat and swiat.has_method("slad"):
		swiat.slad(hit["position"], hit["normal"], "ziemia")
	Dzwiek.w_swiecie("uderzenie", hit["position"], -8.0, 0.15, 8.0)
	# płaski kąt na twardym podłożu daje rykoszet
	var cos_k := absf(kier.dot(hit["normal"]))
	if cos_k < 0.22 and int(p["rykoszety"]) < 1 and randf() < 0.6:
		p["rykoszety"] = 1
		p["v"] = v.bounce(hit["normal"]) * 0.4
		p["poz"] = hit["position"] + (hit["normal"] as Vector3) * 0.02
		Dzwiek.w_swiecie("rykoszet", hit["position"], -6.0, 0.15, 10.0)
		return true
	return false
