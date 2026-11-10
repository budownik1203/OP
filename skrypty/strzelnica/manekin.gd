extends Node3D
## Manekin rycerza: pancerz strefowy na drewnianym słupie.
## Proporcje człowieka 1,80 m; klasy jak u „upadłego rycerza” z bestiariusza.

## [klucz strefy, klasa, rozmiar, środek]
const STREFY := [
	["STREFA_GLOWA", 4, Vector3(0.21, 0.25, 0.24), Vector3(0.0, 1.675, 0.0)],
	["STREFA_WIZJER", 1, Vector3(0.15, 0.022, 0.02), Vector3(0.0, 1.70, 0.125)],
	["STREFA_TORS", 4, Vector3(0.42, 0.46, 0.26), Vector3(0.0, 1.27, 0.0)],
	["STREFA_BRZUCH", 3, Vector3(0.38, 0.22, 0.24), Vector3(0.0, 0.93, 0.0)],
	["STREFA_PACHA", 1, Vector3(0.045, 0.14, 0.16), Vector3(-0.232, 1.40, 0.0)],
	["STREFA_PACHA", 1, Vector3(0.045, 0.14, 0.16), Vector3(0.232, 1.40, 0.0)],
	["STREFA_REKA", 3, Vector3(0.11, 0.64, 0.12), Vector3(-0.31, 1.17, 0.0)],
	["STREFA_REKA", 3, Vector3(0.11, 0.64, 0.12), Vector3(0.31, 1.17, 0.0)],
	["STREFA_NOGA", 3, Vector3(0.16, 0.82, 0.17), Vector3(-0.105, 0.41, 0.0)],
	["STREFA_NOGA", 3, Vector3(0.16, 0.82, 0.17), Vector3(0.105, 0.41, 0.0)],
	["STREFA_KOLANO", 1, Vector3(0.13, 0.11, 0.02), Vector3(-0.105, 0.48, -0.095)],
	["STREFA_KOLANO", 1, Vector3(0.13, 0.11, 0.02), Vector3(0.105, 0.48, -0.095)],
]


func zbuduj(swiat: Strzelnica) -> void:
	var etykieta := Label3D.new()
	etykieta.position = Vector3(0.0, 2.62, 0.0)
	swiat._styl_napisu(etykieta, 0.0034, Color.WHITE)
	add_child(etykieta)
	var tytul := Label3D.new()
	tytul.text = tr("MANEKIN")
	tytul.set_meta("klucz", "MANEKIN")
	tytul.add_to_group("napisy")
	tytul.position = Vector3(0.0, 2.02, 0.0)
	swiat._styl_napisu(tytul, 0.0026, Color("d8c9a0"))
	add_child(tytul)
	Mat.blok(self, Vector3(0.09, 1.9, 0.09), Vector3(0.0, 0.95, -0.19), Mat.drewno(), false)
	Mat.blok(self, Vector3(0.7, 0.08, 0.5), Vector3(0.0, 0.04, -0.19), Mat.drewno(), false)
	for s in STREFY:
		var p := Plyta.new()
		p.klasa = s[1]
		p.rozmiar = s[2]
		p.position = s[3]
		p.nazwa_strefy = s[0]
		p.etykieta = etykieta
		add_child(p)
		p.zbuduj(Mat.plotno() if s[1] <= 1 else Mat.stal(s[1]))
