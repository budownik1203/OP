extends Node
## Wartości do strojenia odczuć gry. Panel F1 zmienia je na żywo i zapisuje.

signal zmieniono(klucz: String)

## klucz: [domyślna, min, max, krok]
const DEF := {
	"S_ODRZUT": [1.0, 0.0, 2.5, 0.05],
	"S_KAMERA_ODRZUT": [1.0, 0.0, 2.5, 0.05],
	"S_KOLYSANIE": [1.0, 0.0, 2.5, 0.05],
	"S_BEZWLADNOSC": [1.0, 0.0, 2.5, 0.05],
	"S_KROK": [1.0, 0.0, 2.5, 0.05],
	"S_CELOWANIE": [1.0, 0.4, 2.0, 0.05],
	"S_RUCH": [1.0, 0.6, 1.6, 0.05],
	"S_MYSZ": [1.0, 0.2, 3.0, 0.05],
	"S_FOV": [62.0, 50.0, 85.0, 1.0],
	"S_PIKSEL": [540.0, 360.0, 1080.0, 60.0],
	"S_DITHER": [1.0, 0.0, 1.0, 1.0],
	"S_GLOSNOSC": [0.8, 0.0, 1.0, 0.05],
}

var w := {}


func _ready() -> void:
	for k in DEF:
		w[k] = DEF[k][0]
	var zapis := ConfigFile.new()
	if zapis.load("user://strojenie.cfg") == OK:
		for k in DEF:
			w[k] = clampf(float(zapis.get_value("strojenie", k, w[k])), DEF[k][1], DEF[k][2])


func ustaw(klucz: String, wartosc: float) -> void:
	w[klucz] = wartosc
	zmieniono.emit(klucz)


func zapisz() -> void:
	var zapis := ConfigFile.new()
	for k in w:
		zapis.set_value("strojenie", k, w[k])
	zapis.save("user://strojenie.cfg")


func przywroc() -> void:
	for k in DEF:
		w[k] = DEF[k][0]
		zmieniono.emit(k)
	zapisz()
