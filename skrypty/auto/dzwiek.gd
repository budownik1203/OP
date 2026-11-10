extends Node
## Odtwarzanie dźwięków z puli. Pliki: res://zasoby/dzwiek/<nazwa>.wav

const KATALOG := "res://zasoby/dzwiek/"
const PULA_3D := 24
const PULA_2D := 8

var _strumienie := {}
var _gracze_3d: Array[AudioStreamPlayer3D] = []
var _gracze_2d: Array[AudioStreamPlayer] = []
var _i3 := 0
var _i2 := 0


func _ready() -> void:
	for i in PULA_3D:
		var g := AudioStreamPlayer3D.new()
		g.unit_size = 12.0
		g.max_distance = 400.0
		g.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		add_child(g)
		_gracze_3d.append(g)
	for i in PULA_2D:
		var g := AudioStreamPlayer.new()
		add_child(g)
		_gracze_2d.append(g)
	_ustaw_glosnosc()
	Strojenie.zmieniono.connect(func(k): if k == "S_GLOSNOSC": _ustaw_glosnosc())


func _ustaw_glosnosc() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(Strojenie.w["S_GLOSNOSC"], 0.0001)))


func _strumien(nazwa: String) -> AudioStream:
	if _strumienie.has(nazwa):
		return _strumienie[nazwa]
	var sciezka := KATALOG + nazwa + ".wav"
	var s: AudioStream = null
	if ResourceLoader.exists(sciezka):
		s = load(sciezka)
	_strumienie[nazwa] = s
	return s


## Dźwięk w świecie. rozrzut = losowa zmiana wysokości tonu.
func w_swiecie(nazwa: String, pozycja: Vector3, db := 0.0, rozrzut := 0.06, zasieg := 12.0) -> void:
	var s := _strumien(nazwa)
	if s == null:
		return
	var g := _gracze_3d[_i3]
	_i3 = (_i3 + 1) % PULA_3D
	g.stream = s
	g.global_position = pozycja
	g.volume_db = db
	g.unit_size = zasieg
	g.pitch_scale = 1.0 + randf_range(-rozrzut, rozrzut)
	g.play()


## Dźwięk „w głowie” gracza: własna broń, interfejs.
func przy_uchu(nazwa: String, db := 0.0, rozrzut := 0.04) -> void:
	var s := _strumien(nazwa)
	if s == null:
		return
	var g := _gracze_2d[_i2]
	_i2 = (_i2 + 1) % PULA_2D
	g.stream = s
	g.volume_db = db
	g.pitch_scale = 1.0 + randf_range(-rozrzut, rozrzut)
	g.play()
