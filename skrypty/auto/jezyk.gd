extends Node
## Tłumaczenia PL/EN budowane w kodzie. Wszędzie w grze używamy tr("KLUCZ").

signal zmieniono

const TEKSTY := {
	"TYTUL": ["Ostatni Pluton", "The Last Platoon"],
	"STRZELNICA": ["Strzelnica", "Firing range"],
	"KLASA": ["Klasa", "Class"],
	"PRZEBICIE": ["PRZEBICIE", "PENETRATION"],
	"CZESCIOWE": ["PRZEBICIE CZĘŚCIOWE", "PARTIAL PENETRATION"],
	"ZATRZYMANY": ["ZATRZYMANY", "STOPPED"],
	"RYKOSZET": ["RYKOSZET", "RICOCHET"],
	"OBRAZENIA": ["obrażenia", "damage"],
	"TEPE": ["tępe", "blunt"],
	"DYSTANS": ["dystans", "range"],
	"PLYTA_ZNISZCZONA": ["płyta rozbita", "plate destroyed"],
	"STAN_PLYTY": ["stan płyty", "plate integrity"],
	"TRYB_POJ": ["OGIEŃ POJEDYNCZY", "SEMI-AUTO"],
	"TRYB_SERIA": ["OGIEŃ CIĄGŁY", "FULL AUTO"],
	"TRYB_ZABEZP": ["ZABEZPIECZONA", "SAFE"],
	"MAG_PELNY": ["Magazynek pełny", "Magazine full"],
	"MAG_PRAWIE_PELNY": ["Magazynek prawie pełny", "Magazine nearly full"],
	"MAG_PONAD_POL": ["Ponad połowa", "More than half"],
	"MAG_POLOWA": ["Około połowy", "About half"],
	"MAG_MNIEJ_POL": ["Mniej niż połowa", "Less than half"],
	"MAG_PRAWIE_PUSTY": ["Prawie pusty", "Nearly empty"],
	"MAG_PUSTY": ["Magazynek pusty", "Magazine empty"],
	"BRAK_MAG": ["Brak magazynków", "No magazines left"],
	"KOMORA_PUSTA": ["komora pusta", "chamber empty"],
	"KOMORA_NABOJ": ["nabój w komorze", "round chambered"],
	"MAG_UPUSZCZONY": ["Magazynek rzucony na ziemię", "Magazine dropped"],
	"MAG_PODNIESIONY": ["Podniesiono magazynek", "Magazine picked up"],
	"STOL_AMUNICYJNY": ["Stół amunicyjny", "Ammunition bench"],
	"STOL_PODPOWIEDZ": ["[F] Stół amunicyjny", "[F] Ammunition bench"],
	"STOL_OPIS": ["Wybierz amunicję. Wszystkie magazynki zostaną załadowane od nowa.", "Choose ammunition. All magazines will be reloaded."],
	"STOL_PRZEPLOT": ["Przeplot: 2× pierwszy typ, 1× drugi", "Mixed: 2× first type, 1× second"],
	"ZAMKNIJ": ["Zamknij", "Close"],
	"STROJENIE": ["Strojenie", "Tuning"],
	"PRZYWROC": ["Przywróć domyślne", "Restore defaults"],
	"POMOC": ["Sterowanie", "Controls"],
	"POMOC_TRESC": [
		"WSAD — ruch\nMysz — rozglądanie\nKółko myszy — prędkość chodu\nShift — sprint\nC — kucanie\nSpacja — skok\nQ / E — wychylenie\nLPM — strzał\nPPM — celowanie\nR — przeładowanie taktyczne\nR dwa razy — przeładowanie szybkie (magazynek na ziemię)\nT — sprawdź magazynek\nB — tryb ognia\n1 / 2 — karabinek / pistolet\nL — latarka\nF — użyj\nG — wyczyść tarcze\nF1 — strojenie\nF2 — język\nH — ta pomoc\nEsc — zwolnij mysz",
		"WASD — move\nMouse — look\nMouse wheel — walk speed\nShift — sprint\nC — crouch\nSpace — jump\nQ / E — lean\nLMB — fire\nRMB — aim\nR — tactical reload\nR twice — quick reload (magazine dropped)\nT — check magazine\nB — fire mode\n1 / 2 — carbine / pistol\nL — flashlight\nF — use\nG — reset targets\nF1 — tuning\nF2 — language\nH — this help\nEsc — release mouse"],
	"PODPOWIEDZ_H": ["H — sterowanie", "H — controls"],
	"TARCZE_WYCZYSZCZONE": ["Tarcze wyczyszczone", "Targets reset"],
	"MANEKIN": ["Manekin: rycerz", "Dummy: knight"],
	"STREFA_GLOWA": ["hełm", "helmet"],
	"STREFA_WIZJER": ["wizjer", "visor slit"],
	"STREFA_TORS": ["napierśnik", "breastplate"],
	"STREFA_PACHA": ["pacha", "armpit"],
	"STREFA_REKA": ["ręka", "arm"],
	"STREFA_NOGA": ["noga", "leg"],
	"STREFA_KOLANO": ["tył kolana", "back of knee"],
	"STREFA_BRZUCH": ["fartuch", "fauld"],
	"BRON_KWARC": ["Karabinek „Kwarc” wz. 96", "\"Kwarc\" wz. 96 carbine"],
	"BRON_JASPIS": ["Pistolet „Jaspis”", "\"Jaspis\" pistol"],
	"S_ODRZUT": ["Odrzut", "Recoil"],
	"S_KOLYSANIE": ["Kołysanie broni", "Weapon sway"],
	"S_BEZWLADNOSC": ["Bezwładność broni", "Weapon inertia"],
	"S_KROK": ["Bujanie przy chodzie", "Walk bob"],
	"S_CELOWANIE": ["Szybkość składania się", "Aim speed"],
	"S_RUCH": ["Prędkość ruchu", "Move speed"],
	"S_MYSZ": ["Czułość myszy", "Mouse sensitivity"],
	"S_FOV": ["Pole widzenia", "Field of view"],
	"S_PIKSEL": ["Wysokość obrazu (linie)", "Render height (lines)"],
	"S_DITHER": ["Dithering", "Dithering"],
	"S_GLOSNOSC": ["Głośność", "Volume"],
	"S_KAMERA_ODRZUT": ["Odrzut kamery", "Camera kick"],
	"WYTRZ_NOGI": ["nogi", "legs"],
	"WYTRZ_RECE": ["ręce", "arms"],
	"BRON_ZABLOKOWANA": ["broń zablokowana o ścianę", "weapon blocked by wall"],
}

var _jezyk := "pl"


func _ready() -> void:
	var pl := Translation.new()
	pl.locale = "pl"
	var en := Translation.new()
	en.locale = "en"
	for k in TEKSTY:
		pl.add_message(k, TEKSTY[k][0])
		en.add_message(k, TEKSTY[k][1])
	for a in Amunicja_teksty():
		pl.add_message(a[0], a[1])
		en.add_message(a[0], a[2])
	TranslationServer.add_translation(pl)
	TranslationServer.add_translation(en)
	var zapis := ConfigFile.new()
	if zapis.load("user://ustawienia.cfg") == OK:
		_jezyk = zapis.get_value("gra", "jezyk", "pl")
	elif not OS.get_locale_language() == "pl":
		_jezyk = "en"
	TranslationServer.set_locale(_jezyk)


func Amunicja_teksty() -> Array:
	return [
		["A_9_FMJ", "9×19 pełnopłaszczowy", "9×19 FMJ"],
		["A_9_HP", "9×19 grzybkujący", "9×19 hollow point"],
		["A_9_AP", "9×19 przeciwpancerny", "9×19 armour-piercing"],
		["A_9_SUB", "9×19 poddźwiękowy", "9×19 subsonic"],
		["A_556_FMJ", "5,56×45 pełnopłaszczowy", "5.56×45 FMJ"],
		["A_556_SS", "5,56×45 z rdzeniem stalowym", "5.56×45 steel core"],
		["A_556_AP", "5,56×45 przeciwpancerny", "5.56×45 armour-piercing"],
		["A_556_T", "5,56×45 smugowy", "5.56×45 tracer"],
	]


func przelacz() -> void:
	_jezyk = "en" if _jezyk == "pl" else "pl"
	TranslationServer.set_locale(_jezyk)
	var zapis := ConfigFile.new()
	zapis.load("user://ustawienia.cfg")
	zapis.set_value("gra", "jezyk", _jezyk)
	zapis.save("user://ustawienia.cfg")
	zmieniono.emit()
