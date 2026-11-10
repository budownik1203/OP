class_name Plyta
extends StaticBody3D
## Płyta o zadanej klasie pancerza. Pokazuje wynik każdego trafienia.
## Ta sama logika obsłuży później strefy pancerza wrogów.

var klasa := 0
var stan := 1.0
var rozmiar := Vector3(0.5, 0.7, 0.03)
var nazwa_strefy := ""
var etykieta: Label3D           ## może być wspólna dla kilku stref (manekin)
var dzwiek := "stal"
var _siatka: MeshInstance3D
var _obrot_startowy := Vector3.ZERO


func zbuduj(material: Material) -> void:
	var ks := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = rozmiar
	ks.shape = bs
	add_child(ks)
	_siatka = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = rozmiar
	_siatka.mesh = bm
	_siatka.material_override = material
	add_child(_siatka)
	_obrot_startowy = rotation
	add_to_group("plyty")


func trafienie(info: Dictionary) -> Dictionary:
	var kier: Vector3 = info["kier"]
	var n: Vector3 = info["normalna"]
	var cos_k := absf(kier.dot(n))
	var w := Amunicja.rozstrzygnij(info["przeb"], info["obr"], klasa, stan, cos_k, randf())
	var byla_cala := stan > 0.0
	stan = maxf(stan - float(w["uszk"]), 0.0)
	var swiat := get_tree().get_first_node_in_group("swiat")
	if swiat and swiat.has_method("slad"):
		swiat.slad(info["poz"], n, "dziura" if w["przechodzi"] else "wgniot")
	if klasa > 0:
		Dzwiek.w_swiecie(dzwiek, info["poz"], -2.0 if not w["przechodzi"] else -6.0, 0.05, 30.0)
	else:
		Dzwiek.w_swiecie("uderzenie", info["poz"], -6.0, 0.1, 8.0)
	_pokaz(w, info)
	if byla_cala and stan <= 0.0 and klasa > 0:
		rotation = _obrot_startowy + Vector3(randf_range(-0.2, 0.2), 0.0, randf_range(-0.35, 0.35))
	# lekkie drgnięcie trafionej płyty
	var tw := create_tween()
	tw.tween_property(_siatka, "position:z", -0.02, 0.03)
	tw.tween_property(_siatka, "position:z", 0.0, 0.12)
	return w


func _pokaz(w: Dictionary, info: Dictionary) -> void:
	if etykieta == null:
		return
	var kolor := Color("d8c9a0")
	match w["wynik"]:
		"PRZEBICIE":
			kolor = Color("c94b3a")
		"CZESCIOWE":
			kolor = Color("d98a3a")
		"ZATRZYMANY":
			kolor = Color("9fb0b8")
		"RYKOSZET":
			kolor = Color("c8c26a")
	var linia1 := tr(w["wynik"])
	if nazwa_strefy != "":
		linia1 = "%s (%s %d): %s" % [tr(nazwa_strefy), tr("KLASA").to_lower(), klasa, linia1]
	var obr := "%s: %d" % [tr("OBRAZENIA"), roundi(w["obr"])]
	if w["tepe"]:
		obr += " (%s)" % tr("TEPE")
	var linia2 := "%s · %s %d m" % [obr, tr("DYSTANS"), roundi(info["dystans"])]
	var linia3 := "%s %d%%" % [tr("STAN_PLYTY"), roundi(stan * 100.0)] if stan > 0.0 else tr("PLYTA_ZNISZCZONA")
	if klasa == 0:
		linia3 = ""
	etykieta.text = linia1 + "\n" + linia2 + ("\n" + linia3 if linia3 != "" else "")
	etykieta.modulate = kolor


func wyczysc() -> void:
	stan = 1.0
	rotation = _obrot_startowy
	if etykieta:
		etykieta.text = ""
