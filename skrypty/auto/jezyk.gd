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
		"WSAD — ruch\nMysz — rozglądanie\nKółko myszy — prędkość chodu\nShift — sprint\nC — kucanie\nSpacja — skok\nQ / E — wychylenie\nLPM — strzał\nPPM — celowanie\nR — przeładowanie taktyczne\nR dwa razy — przeładowanie szybkie (magazynek na ziemię)\nT — sprawdź magazynek\nB — tryb ognia\n1 / 2 — karabinek / pistolet\n4–8 — leki: bandaż, opatrunek, szyna, apteczka, przeciwbólowe\nL — latarka\nF — użyj, podnieś, przeszukaj\nTab — ekwipunek\nZ — zrzuć plecak\nG — wyczyść tarcze\nF1 — strojenie\nF2 — język\nH — ta pomoc\nEsc — zwolnij mysz",
		"WASD — move\nMouse — look\nMouse wheel — walk speed\nShift — sprint\nC — crouch\nSpace — jump\nQ / E — lean\nLMB — fire\nRMB — aim\nR — tactical reload\nR twice — quick reload (magazine dropped)\nT — check magazine\nB — fire mode\n1 / 2 — carbine / pistol\n4–8 — meds: bandage, dressing, splint, first aid kit, painkillers\nL — flashlight\nF — use, pick up, search\nTab — inventory\nZ — drop backpack\nG — reset targets\nF1 — tuning\nF2 — language\nH — this help\nEsc — release mouse"],
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
	"BRAMA_PODPOWIEDZ": ["[F] Zejdź do kopalni", "[F] Descend into the mine"],
	"WYJSCIE_PODPOWIEDZ": ["[F] Wróć na powierzchnię", "[F] Return to the surface"],
	"LEK_BANDAZ": ["Bandaż", "Bandage"],
	"LEK_OPATRUNEK": ["Opatrunek hemostatyczny", "Haemostatic dressing"],
	"LEK_SZYNA": ["Szyna", "Splint"],
	"LEK_APTECZKA": ["Apteczka", "First aid kit"],
	"LEK_PRZECIWBOLOWE": ["Środki przeciwbólowe", "Painkillers"],
	"LEK_BRAK": ["Brak tego środka", "None left"],
	"LEK_NIEPOTRZEBNY": ["Teraz niepotrzebne", "Not needed now"],
	"LEK_UZYTO": ["użyto", "used"],
	"STAN_KRWAWIENIE": ["krwawienie", "bleeding"],
	"STAN_KRWOTOK": ["KRWOTOK", "HEAVY BLEEDING"],
	"STAN_ZLAMANIE": ["złamanie", "fracture"],
	"STAN_BOL": ["ból", "pain"],
	"STAN_ZNIECZULENIE": ["znieczulenie", "painkillers active"],
	"C_glowa": ["głowa", "head"], "C_tors": ["tors", "torso"],
	"C_reka_l": ["lewa ręka", "left arm"], "C_reka_p": ["prawa ręka", "right arm"],
	"C_noga_l": ["lewa noga", "left leg"], "C_noga_p": ["prawa noga", "right leg"],
	"POLEGL": ["Żołnierz poległ", "Soldier killed in action"],
	"POLEGL_OPIS": ["Wszystko, co miał przy sobie, zostało w lochu.", "Everything he carried stays in the dungeon."],
	"STREFA_TARCZA": ["tarcza", "shield"],
	"KOPALNIA": ["Zatopiona kopalnia", "The Drowned Mine"],
	"P_MAG_KWARC": ["Magazynek 5,56 „Kwarc”", "5.56 \"Kwarc\" magazine"],
	"P_MAG_JASPIS": ["Magazynek 9 mm „Jaspis”", "9 mm \"Jaspis\" magazine"],
	"P_PACZKA_556": ["Naboje 5,56×45", "5.56×45 rounds"],
	"P_PACZKA_9": ["Naboje 9×19", "9×19 rounds"],
	"P_KONSERWA": ["Konserwa", "Tinned meat"],
	"P_SUCHARY": ["Suchary", "Hardtack"],
	"P_MONETY": ["Miejscowe monety", "Local coins"],
	"P_RELIKWIA": ["Relikwia", "Relic"],
	"P_KLUCZ": ["Żelazny klucz", "Iron key"],
	"P_PAS": ["Pas taktyczny", "Battle belt"],
	"P_CHEST_RIG": ["Kamizelka taktyczna", "Chest rig"],
	"P_TORBA": ["Torba biodrowa", "Waist pack"],
	"P_CHLEBAK": ["Chlebak", "Bread bag"],
	"P_PLECAK_SZT": ["Plecak szturmowy", "Assault pack"],
	"P_PLECAK_PAT": ["Plecak patrolowy", "Patrol pack"],
	"E_EKWIPUNEK": ["Ekwipunek", "Inventory"],
	"E_KIESZENIE": ["Kieszenie", "Pockets"],
	"E_KAMIZELKA": ["Kamizelka", "Vest"],
	"E_PLECAK": ["Plecak", "Backpack"],
	"E_PLECAK_BRAK": ["— brak (zrzucony) —", "— none (dropped) —"],
	"E_RELIKWIARZ": ["Relikwiarz", "Reliquary"],
	"E_SKRZYNIA": ["Skrzynia", "Chest"],
	"E_ZWLOKI": ["Zwłoki", "Corpse"],
	"E_BRAK_MIEJSCA": ["Brak miejsca", "No room"],
	"E_OBCIAZENIE": ["Obciążenie", "Load"],
	"E_LIMITY": ["do 25 kg bez kary · od 40 kg brak sprintu", "no penalty up to 25 kg · no sprint from 40 kg"],
	"E_SZUKANIE": ["przeszukiwanie…", "searching…"],
	"E_LADOWANIE": ["Ładowanie magazynka nabojami…", "Loading magazine…"],
	"E_NA_WIERZCHU": ["na wierzchu", "top round"],
	"E_POJEMNOSC": ["pojemność", "capacity"],
	"E_PODPOWIEDZ": ["LPM przeciągnij · R obróć · Ctrl+LPM przenieś · PPM wyrzuć · upuść naboje na magazynek, żeby go załadować · Tab zamknij", "LMB drag · R rotate · Ctrl+LMB move · RMB drop · drop rounds on a magazine to load it · Tab close"],
	"E_PRZESZUKAJ": ["[F] Przeszukaj", "[F] Search"],
	"E_PODNIES": ["[F] Podnieś", "[F] Pick up"],
	"E_PODNIESIONO": ["Podniesiono", "Picked up"],
	"E_PLECAK_ZRZUCONY": ["Plecak zrzucony", "Backpack dropped"],
	"P_RACJA": ["Racja żywnościowa", "Field ration"],
	"P_MANIERKA": ["Manierka", "Canteen"],
	"P_BUKLAK": ["Bukłak", "Waterskin"],
	"E_SKRYTKA": ["Skrytka", "Stash"],
	"E_SKRYTKA_PODP": ["[F] Skrytka", "[F] Stash"],
	"E_PUSTE": ["Puste", "Empty"],
	"E_PORCJE": ["porcje", "portions"],
	"E_ZALOZONO": ["Założono", "Equipped"],
	"E_NIE_MIESCI": ["Zawartość nie mieści się w nowej kamizelce", "Contents do not fit the new vest"],
	"E_DWUKLIK": ["Dwuklik: użyj, zjedz, załóż", "Double-click: use, eat, equip"],
	"GLOD": ["głód", "hunger"], "PRAGNIENIE": ["pragnienie", "thirst"],
	"ODPRAWA": ["Odprawa", "Briefing"],
	"ODPRAWA_CEL": ["Cel: Zatopiona kopalnia", "Destination: The Drowned Mine"],
	"ODPRAWA_OPIS": ["Trzy wyjścia: drabina przy wejściu, krata w szybie (żelazny klucz) i stary chodnik, który zawali się, gdy loch się obudzi. Zapis tylko przy biwaku.", "Three exits: the ladder at the entrance, the shaft grate (iron key) and an old gallery that collapses once the dungeon wakes. Saving only at a bivouac."],
	"ODPRAWA_MAG": ["Magazynki pod ręką", "Magazines at hand"],
	"ODPRAWA_BRAK_JEDZENIA": ["Uwaga: brak jedzenia", "Warning: no food"],
	"ODPRAWA_BRAK_WODY": ["Uwaga: brak wody", "Warning: no water"],
	"ODPRAWA_BRAK_LEKOW": ["Uwaga: brak opatrunków", "Warning: no dressings"],
	"WYRUSZ": ["Wyrusz", "Set out"],
	"WROC": ["Wróć", "Back"],
	"POWROT": ["Wróciłeś z wyprawy", "You returned from the expedition"],
	"POLEGL_BEZ_BIWAKU": ["Żołnierz nie wrócił z poprzedniej wyprawy. Gra została przerwana w lochu bez biwaku.", "The soldier never returned. The game was closed in the dungeon without a bivouac."],
	"WYJSCIE_KRATA": ["[F] Otwórz kratę szybu (żelazny klucz)", "[F] Open the shaft grate (iron key)"],
	"WYJSCIE_BRAK_KLUCZA": ["Krata zamknięta. Potrzebny żelazny klucz.", "The grate is locked. An iron key is needed."],
	"WYJSCIE_CHODNIK": ["[F] Wyjdź starym chodnikiem", "[F] Leave through the old gallery"],
	"WYJSCIE_ZAWALONE": ["Chodnik zawalony", "The gallery has collapsed"],
	"BIWAK_PODP": ["[F] Rozbij biwak", "[F] Make camp"],
	"BIWAK": ["Biwak", "Bivouac"],
	"BIWAK_OPIS": ["Tu można odpocząć. Zapis zawiesza wyprawę i zamyka grę; po wczytaniu zapis znika. Ogień budzi loch.", "You can rest here. Saving suspends the expedition and closes the game; the save is erased on load. Fire wakes the dungeon."],
	"BIWAK_ZAPISZ": ["Zapisz i zakończ grę", "Save and quit"],
	"BIWAK_ODPOCZNIJ": ["Odpocznij przy ogniu", "Rest by the fire"],
	"BIWAK_WCZYTANO": ["Wyprawa wznowiona przy biwaku", "Expedition resumed at the bivouac"],
	"BUDZI_1": ["Coś się poruszyło w głębi", "Something stirs below"],
	"BUDZI_2": ["Loch się budzi. Stary chodnik się zawalił.", "The dungeon is waking. The old gallery has collapsed."],
	"BUDZI_3": ["Słychać kroki w zbroi", "Armoured footsteps echo"],
	"BUDZI_4": ["Loch nie śpi. Uciekaj.", "The dungeon is awake. Run."],
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
