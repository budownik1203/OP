class_name LezacyPrzedmiot
extends RigidBody3D
## Przedmiot leżący w świecie: rzucony magazynek, zrzucony plecak, wyrzucona rzecz.

var przedmiot := {}
var _zagral := false


func przygotuj(p: Dictionary) -> void:
	przedmiot = p
	var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
	add_to_group("do_podniesienia")
	mass = maxf(Ekwipunek.masa_przedmiotu(p), 0.1)
	collision_layer = 4
	collision_mask = 1
	var rozmiar := Vector3(0.05 * def["w"], 0.035, 0.085 * def["h"])
	match def["typ"]:
		"mag":
			rozmiar = Vector3(0.03, 0.17, 0.065) if def["bron"] == "kwarc" else Vector3(0.025, 0.12, 0.035)
		"plecak":
			var s: Vector2i = def["siatka"]
			rozmiar = Vector3(0.07 * s.x, 0.09 * s.y, 0.18)
		"kamizelka":
			rozmiar = Vector3(0.34, 0.08, 0.30)
	var ks := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = rozmiar
	ks.shape = bs
	add_child(ks)
	var si := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = rozmiar
	si.mesh = bm
	si.material_override = Mat.kolor(Color(def["kolor"]), 0.8, 0.2 if def["typ"] == "mag" else 0.0)
	add_child(si)
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(func(_c):
		if not _zagral:
			_zagral = true
			Dzwiek.w_swiecie("mag_ziemia" if def["typ"] == "mag" else "uderzenie", global_position, -8.0, 0.1, 4.0))
