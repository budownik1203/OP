class_name Skrzynia
extends StaticBody3D
## Skrzynia z łupem. Zawartość odkrywa się stopniowo podczas przeszukiwania.

const LUP := [
	["paczka_556", 3], ["paczka_9", 3], ["bandaz", 3], ["opatrunek", 2], ["przeciwbolowe", 2],
	["konserwa", 3], ["suchary", 3], ["monety", 4], ["relikwia", 1], ["klucz", 1],
	["mag_kwarc", 1], ["mag_jaspis", 1], ["apteczka", 1], ["szyna", 1], ["chlebak", 1],
]

var pojemnik: Pojemnik


func przygotuj(los: RandomNumberGenerator) -> void:
	add_to_group("pojemniki")
	pojemnik = Pojemnik.new(4, 3, "E_SKRZYNIA")
	var ks := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.9, 0.55, 0.55)
	ks.shape = bs
	ks.position.y = 0.275
	add_child(ks)
	var dr := Mat.drewno()
	var zel := Mat.kolor(Color("2b2c2e"), 0.6, 0.6)
	Mat.blok(self, Vector3(0.9, 0.42, 0.55), Vector3(0, 0.21, 0), dr, false)
	Mat.blok(self, Vector3(0.94, 0.14, 0.59), Vector3(0, 0.49, 0), dr, false)
	for x in [-0.33, 0.33]:
		Mat.blok(self, Vector3(0.06, 0.57, 0.60), Vector3(x, 0.285, 0), zel, false)
	Mat.blok(self, Vector3(0.10, 0.12, 0.03), Vector3(0, 0.40, 0.29), zel, false)
	wypelnij(pojemnik, los, los.randi_range(2, 5))


static func wypelnij(poj: Pojemnik, los: RandomNumberGenerator, ile: int, tabela: Array = LUP) -> void:
	var suma := 0
	for l in tabela:
		suma += l[1]
	for i in ile:
		var r := los.randi_range(1, suma)
		var id := ""
		for l in tabela:
			r -= l[1]
			if r <= 0:
				id = l[0]
				break
		var p: Dictionary
		match Ekwipunek.PRZEDMIOTY[id]["typ"]:
			"mag":
				p = Ekwipunek.nowy_magazynek(id, "A_556_FMJ" if id == "mag_kwarc" else "A_9_FMJ", "", los.randi_range(3, 20))
			"amunicja":
				var typy := Amunicja.dla_kalibru(Ekwipunek.PRZEDMIOTY[id]["kaliber"])
				p = Ekwipunek.nowa_paczka(id, typy[los.randi_range(0, typy.size() - 1)], los.randi_range(8, 30))
			_:
				p = Ekwipunek.nowy(id)
		p["odkryty"] = false
		poj.wloz_gdziekolwiek(p)
