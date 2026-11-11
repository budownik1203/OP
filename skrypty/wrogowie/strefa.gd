class_name StrefaWroga
extends Area3D
## Strefa trafienia na ciele wroga: własna klasa pancerza, stan pancerza i zdrowie.

var wrog: Node
var klucz := ""          ## klucz tekstu, np. STREFA_GLOWA
var segment := ""        ## nazwa węzła segmentu
var rodzaj := ""         ## glowa, tors, reka, noga, tarcza, szczelina
var klasa := 0
var stan := 1.0
var hp := 50.0
var hp_max := 50.0


func ustaw(rozmiar: Vector3, srodek: Vector3) -> void:
	collision_layer = 2
	collision_mask = 0
	monitoring = false
	var ks := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = rozmiar
	ks.shape = bs
	ks.position = srodek
	add_child(ks)


func trafienie(info: Dictionary) -> Dictionary:
	return wrog.trafiony(self, info)
