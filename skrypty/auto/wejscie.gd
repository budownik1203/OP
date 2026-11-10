extends Node
## Rejestruje akcje sterowania w kodzie, żeby project.godot pozostał czytelny.

const KLAWISZE := {
	"przod": KEY_W, "tyl": KEY_S, "lewo": KEY_A, "prawo": KEY_D,
	"sprint": KEY_SHIFT, "kucnij": KEY_C, "skok": KEY_SPACE,
	"wychyl_lewo": KEY_Q, "wychyl_prawo": KEY_E,
	"przeladuj": KEY_R, "sprawdz_mag": KEY_T, "tryb_ognia": KEY_B,
	"bron_1": KEY_1, "bron_2": KEY_2, "latarka": KEY_L, "uzyj": KEY_F,
	"wyczysc": KEY_G, "strojenie": KEY_F1, "jezyk": KEY_F2, "pomoc": KEY_H,
	"wyjdz": KEY_ESCAPE,
}
const MYSZ := {"strzal": MOUSE_BUTTON_LEFT, "celuj": MOUSE_BUTTON_RIGHT}


func _ready() -> void:
	for nazwa in KLAWISZE:
		if not InputMap.has_action(nazwa):
			InputMap.add_action(nazwa)
		var ev := InputEventKey.new()
		ev.physical_keycode = KLAWISZE[nazwa]
		InputMap.action_add_event(nazwa, ev)
	for nazwa in MYSZ:
		if not InputMap.has_action(nazwa):
			InputMap.add_action(nazwa)
		var ev := InputEventMouseButton.new()
		ev.button_index = MYSZ[nazwa]
		InputMap.action_add_event(nazwa, ev)
