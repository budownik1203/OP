extends RigidBody3D
## Magazynek rzucony przy szybkim przeładowaniu. Trzeba po niego wrócić.

var naboje: Array = []
var id_broni := ""
var rozmiar := Vector3(0.03, 0.17, 0.065)


func _ready() -> void:
	add_to_group("do_podniesienia")
	mass = 0.2
	collision_layer = 4
	collision_mask = 1
	var ks := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = rozmiar
	ks.shape = bs
	add_child(ks)
	var s := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = rozmiar
	s.mesh = bm
	s.material_override = Mat.kolor(Color("26282a"), 0.6, 0.4)
	add_child(s)
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_uderzenie)


var _zagral := false


func _uderzenie(_cialo: Node) -> void:
	if not _zagral:
		_zagral = true
		Dzwiek.w_swiecie("mag_ziemia", global_position, -6.0, 0.1, 4.0)
