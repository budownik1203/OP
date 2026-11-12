extends Node
## Tryb testowy: `godot -- --zrzut=katalog` robi serię zrzutów ekranu i kończy.
## Służy do oglądania gry bez grania. W zwykłej grze nic nie robi.

var _katalog := ""
var _kroki: Array = []
var _i := 0
var _czekaj := 0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--zrzut="):
			_katalog = a.trim_prefix("--zrzut=")
	if "--test-balistyka" in OS.get_cmdline_user_args():
		set_process(false)
		_test_balistyka.call_deferred()
		return
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--zrzut-bron="):
			_katalog = a.trim_prefix("--zrzut-bron=")
			set_process(false)
			_zrzuty_broni.call_deferred()
			return
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--zrzut-dodatki="):
			_katalog = a.trim_prefix("--zrzut-dodatki=")
			set_process(false)
			_zrzuty_dodatkow.call_deferred()
			return
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--zrzut-animacje="):
			_katalog = a.trim_prefix("--zrzut-animacje=")
			set_process(false)
			_zrzuty_animacji.call_deferred()
			return
	if "--test-pluton" in OS.get_cmdline_user_args():
		set_process(false)
		_test_pluton.call_deferred()
		return
	if "--test-rzemioslo" in OS.get_cmdline_user_args():
		set_process(false)
		_test_rzemioslo.call_deferred()
		return
	if "--test-ekstrakcja" in OS.get_cmdline_user_args():
		set_process(false)
		_test_ekstrakcja.call_deferred()
		return
	if "--test-ekwipunek" in OS.get_cmdline_user_args():
		set_process(false)
		_test_ekwipunek.call_deferred()
		return
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--zrzut-baza="):
			_katalog = a.trim_prefix("--zrzut-baza=")
			set_process(false)
			_zrzuty_bazy.call_deferred()
			return
	if "--test-generator" in OS.get_cmdline_user_args():
		set_process(false)
		_test_generator.call_deferred()
		return
	if "--test-wrogowie" in OS.get_cmdline_user_args():
		set_process(false)
		_test_wrogowie.call_deferred()
		return
	if "--test-loch" in OS.get_cmdline_user_args():
		set_process(false)
		_test_loch.call_deferred()
		return
	if "--test-gra" in OS.get_cmdline_user_args():
		set_process(false)
		_test_gra.call_deferred()
		return
	if _katalog == "":
		set_process(false)
		return
	DirAccess.make_dir_recursive_absolute(_katalog)
	if get_parent().nazwa_swiata == "kopalnia":
		set_process(false)
		_zrzuty_loch.call_deferred()
		return
	# [nazwa, pozycja, obrót Y w stopniach, pochylenie, broń, celowanie, strzały, kucanie]
	_kroki = [
		["01_biodro_karabinek", Vector3(0, 0.05, 0.4), 0.0, 0.0, 0, 0.0, 0, false],
		["02_cel_karabinek", Vector3(0, 0.05, 0.4), 0.0, -1.2, 0, 1.0, 0, false],
		["03_strzal_karabinek", Vector3(0, 0.05, 0.4), 0.0, -1.2, 0, 1.0, 3, false],
		["04_biodro_pistolet", Vector3(0, 0.05, 0.4), 0.0, 0.0, 1, 0.0, 0, false],
		["05_cel_pistolet", Vector3(0, 0.05, 0.4), 0.0, -1.0, 1, 1.0, 0, false],
		["06_manekin", Vector3(-9.0, 0.05, -11.2), 0.0, -4.0, 1, 1.0, 2, false],
		["07_tarcze_10m", Vector3(0.95, 0.05, -5.5), 0.0, -9.6, 0, 1.0, 3, false],
		["08_stol", Vector3(2.2, 0.05, 4.6), -25.0, -14.0, 0, 0.0, 0, false],
		["09_sciana", Vector3(12.0, 0.05, -4.0), -90.0, 0.0, 0, 0.0, 0, false],
		["10_widok_ogolny", Vector3(-6.0, 0.05, 5.5), -28.0, -2.0, 0, 0.0, 0, false],
		["11_skrytka", Vector3(-2.4, 0.05, 5.2), 18.0, -16.0, 0, 0.0, 0, false],
	]
	_czekaj = 30


func _process(_dt: float) -> void:
	_czekaj -= 1
	if _czekaj > 0:
		return
	var gra := get_parent()
	var swiat: Swiat = gra.swiat
	var g := swiat.gracz
	if _i > 0:
		var img := get_viewport().get_texture().get_image()
		img.save_png(_katalog + "/" + str(_kroki[_i - 1][0]) + ".png")
	if _i >= _kroki.size():
		get_tree().quit()
		return
	var k: Array = _kroki[_i]
	g.sterowanie = false
	g.global_position = k[1]
	g.velocity = Vector3.ZERO
	g.rotation.y = deg_to_rad(k[2])
	g.set("_pitch", deg_to_rad(k[3]))
	swiat.zmien_bron(k[4])
	for b in swiat.bronie:
		b.test_cel = k[5]
	for s in k[6]:
		get_tree().create_timer(0.5 + s * 0.11).timeout.connect(func():
			var b: Bron = swiat.bron()
			if b.komora != "":
				b.call("_strzal"))
	_i += 1
	_czekaj = 75 if k[6] == 0 else 50


## Strzela każdym typem amunicji w płyty każdej klasy z 10 m i wypisuje wyniki.
func _test_balistyka() -> void:
	var swiat: Swiat = get_parent().swiat
	swiat.gracz.sterowanie = false
	var pociski := get_tree().get_first_node_in_group("pociski")
	await get_tree().create_timer(0.3).timeout
	var plyty := []
	for p in get_tree().get_nodes_in_group("plyty"):
		if absf(p.global_position.z + 10.0) < 0.1 and p.nazwa_strefy == "":
			plyty.append(p)
	plyty.sort_custom(func(a, b): return a.klasa < b.klasa)
	for typ in Amunicja.TYPY:
		var linia := "%-10s" % typ
		for p in plyty:
			var wyniki := {}
			for i in 6:
				p.wyczysc()
				pociski.wystrzel(p.global_position + Vector3(0, 0, 9.0), Vector3(0, 0, -1), typ, swiat.gracz)
				await get_tree().create_timer(0.12).timeout
				var t: String = p.etykieta.text.split("\n")[0]
				wyniki[t] = wyniki.get(t, 0) + 1
			linia += " | K%d %s" % [p.klasa, str(wyniki)]
		print(linia)
	# opad i prędkość na 100 m
	for typ in ["A_556_FMJ", "A_9_FMJ"]:
		for p in get_tree().get_nodes_in_group("plyty"):
			if absf(p.global_position.z + 100.0) < 0.1 and p.klasa == 0:
				p.wyczysc()
				var start: Vector3 = Vector3(p.global_position.x, p.global_position.y + 0.3, 0.0)
				pociski.wystrzel(start, Vector3(0, 0, -1), typ, swiat.gracz)
				await get_tree().create_timer(0.6).timeout
				print(typ, " 100 m: ", p.etykieta.text.replace("\n", " / "))
	get_tree().quit()


func _akcja(akcja: String, wcisnieta: bool) -> void:
	var ev := InputEventAction.new()
	ev.action = akcja
	ev.pressed = wcisnieta
	Input.parse_input_event(ev)


func _nacisnij(akcja: String, czas := 0.05) -> void:
	_akcja(akcja, true)
	await get_tree().create_timer(czas).timeout
	_akcja(akcja, false)
	await get_tree().create_timer(0.05).timeout


## Przechodzi przez wszystkie czynności gracza, żeby wyłapać błędy wykonania.
func _test_gra() -> void:
	var gra := get_parent()
	var swiat: Swiat = gra.swiat
	var g := swiat.gracz
	var hud: Hud = gra.hud
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.8).timeout
	var b := swiat.bron()
	print("start: mag=", b.mag.size(), " komora=", b.komora, " zapas=", b.magi.size(), " mysz=", Input.mouse_mode)
	await _nacisnij("strzal", 0.05)
	print("po 1 strzale (pojedynczy): mag=", b.mag.size())
	await _nacisnij("tryb_ognia")
	await _nacisnij("strzal", 0.5)
	print("po serii 0,5 s: mag=", b.mag.size(), " (oczekiwane ok. 23)")
	await _nacisnij("sprawdz_mag")
	await get_tree().create_timer(1.7).timeout
	print("sprawdzenie: ", hud.get("_komunikat").text)
	await _nacisnij("przeladuj")
	await get_tree().create_timer(3.4).timeout
	print("po taktycznym: mag=", b.mag.size(), " zapas=", b.magi.size(), " (zapas bez zmian: 4)")
	await _nacisnij("przeladuj", 0.03)
	await _nacisnij("przeladuj", 0.03)
	await get_tree().create_timer(2.6).timeout
	print("po szybkim: mag=", b.mag.size(), " zapas=", b.magi.size(), " na ziemi=", get_tree().get_nodes_in_group("do_podniesienia").size())
	await get_tree().create_timer(0.6).timeout
	await _nacisnij("uzyj")
	print("po podniesieniu: zapas=", b.magi.size(), " na ziemi=", get_tree().get_nodes_in_group("do_podniesienia").size())
	# opróżnij magazynek do zera
	await _nacisnij("strzal", 3.2)
	print("po opróżnieniu: mag=", b.mag.size(), " komora='", b.komora, "'")
	await _nacisnij("strzal", 0.05)
	await _nacisnij("przeladuj")
	await get_tree().create_timer(3.4).timeout
	print("po przeładowaniu pustej: mag=", b.mag.size(), " komora=", b.komora)
	await _nacisnij("bron_2")
	await get_tree().create_timer(0.9).timeout
	b = swiat.bron()
	print("pistolet: ", b.id, " mag=", b.mag.size())
	for i in 16:
		await _nacisnij("strzal", 0.03)
		await get_tree().create_timer(0.14).timeout
	print("pistolet po 16 naciśnięciach: mag=", b.mag.size(), " komora='", b.komora, "'")
	await _nacisnij("przeladuj")
	await get_tree().create_timer(2.8).timeout
	print("pistolet po przeładowaniu: mag=", b.mag.size(), " komora=", b.komora)
	await _nacisnij("celuj", 0.6)
	await _nacisnij("kucnij")
	await _nacisnij("wychyl_lewo", 0.4)
	await _nacisnij("wychyl_prawo", 0.4)
	await _nacisnij("kucnij")
	_akcja("przod", true)
	_akcja("sprint", true)
	await get_tree().create_timer(2.0).timeout
	print("sprint: v=", snappedf(g.predkosc_pozioma, 0.01), " nogi=", snappedf(g.wytrz_nogi, 0.01), " z=", snappedf(g.global_position.z, 0.01))
	_akcja("sprint", false)
	await _nacisnij("skok")
	await get_tree().create_timer(1.0).timeout
	_akcja("przod", false)
	print("chód: z=", snappedf(g.global_position.z, 0.01), " y=", snappedf(g.global_position.y, 0.01))
	# prawdziwe zdarzenia myszy: obrót, pochylenie, kółko
	var obrot0 := g.rotation.y
	var pochyl0: float = g.get("_pitch")
	var tempo0 := g.tempo
	var ruch := InputEventMouseMotion.new()
	ruch.relative = Vector2(120, 60)
	Input.parse_input_event(ruch)
	var kolko := InputEventMouseButton.new()
	kolko.button_index = MOUSE_BUTTON_WHEEL_DOWN
	kolko.pressed = true
	Input.parse_input_event(kolko)
	await get_tree().create_timer(0.2).timeout
	print("mysz: obrót ", snappedf(g.rotation.y - obrot0, 0.001), " pochylenie ", snappedf(float(g.get("_pitch")) - pochyl0, 0.001), " tempo ", tempo0, " -> ", g.tempo)
	await _nacisnij("latarka")
	await _nacisnij("jezyk")
	await _nacisnij("pomoc")
	await _nacisnij("pomoc")
	await _nacisnij("strojenie")
	Strojenie.ustaw("S_PIKSEL", 360.0)
	Strojenie.ustaw("S_PIKSEL", 540.0)
	await _nacisnij("strojenie")
	g.global_position = swiat.stol_pozycja + Vector3(0, 0.05, 1.0)
	await get_tree().create_timer(0.3).timeout
	await _nacisnij("uzyj")
	print("stół otwarty: ", hud.panel_otwarty())
	await _nacisnij("wyjdz")
	b.zaladuj_magazynki("A_9_AP", "A_9_HP")
	print("przeplot: ", b.mag.slice(-5))
	await _nacisnij("wyczysc")
	await _nacisnij("bron_1")
	await get_tree().create_timer(1.0).timeout
	# ściana: stań twarzą do muru
	g.global_position = Vector3(12.1, 0.05, -4.0)
	g.rotation.y = -PI * 0.5
	await get_tree().create_timer(0.6).timeout
	print("przy ścianie: zablokowana=", snappedf(swiat.bron().zablokowana, 0.01))
	print("TEST GRY ZAKOŃCZONY")
	get_tree().quit()


func _strzel_w(swiat: Swiat, w: Wrog, segment: String, typ: String, rodzaj := "") -> void:
	var pociski := get_tree().get_first_node_in_group("pociski")
	for s in w.strefy:
		if s.segment == segment and (rodzaj == "" and s.rodzaj != "szczelina" or s.rodzaj == rodzaj):
			var cel: Vector3 = (s.get_child(0) as Node3D).global_position
			var od := swiat.gracz.kamera.global_position
			pociski.wystrzel(od, (cel - od).normalized(), typ, swiat.gracz)
			return


func _hp(w: Wrog, segment: String) -> float:
	for s in w.strefy:
		if s.segment == segment and s.rodzaj != "szczelina":
			return snappedf(s.hp, 0.1)
	return -999.0


## Sprawdza wrogów, strefy, rozczłonkowanie, pościg, ciosy, leki i śmierć gracza.
func _test_loch() -> void:
	var gra := get_parent()
	var swiat: Kopalnia = gra.swiat
	var g := swiat.gracz
	g.sterowanie = false
	print("wrogowie na mapie: ", swiat.wrogowie.size())
	for w in swiat.wrogowie.duplicate():
		w.queue_free()
	swiat.wrogowie.clear()
	await get_tree().create_timer(0.3).timeout
	var przed := g.global_position + Vector3(6.0, 0, 0)
	# ghul: strzał w głowę
	var gh := swiat.dodaj_wroga("ghul", przed, PI * 0.5)
	await get_tree().create_timer(0.3).timeout
	_strzel_w(swiat, gh, "glowa", "A_556_FMJ")
	await get_tree().create_timer(0.3).timeout
	print("ghul po strzale w głowę: zyje=", gh.zyje, " hp głowy=", _hp(gh, "glowa"))
	# ghul: noga i pełzanie
	var gh2 := swiat.dodaj_wroga("ghul", przed, PI * 0.5)
	await get_tree().create_timer(0.3).timeout
	for i in 3:
		_strzel_w(swiat, gh2, "udo_l", "A_9_HP")
		await get_tree().create_timer(0.2).timeout
	print("ghul po 3× 9 mm HP w udo: zyje=", gh2.zyje, " pełza=", gh2.get("_pelza"), " stan=", gh2.stan)
	gh2.queue_free()
	swiat.wrogowie.erase(gh2)
	# knecht: tarcza i głowa
	var kn := swiat.dodaj_wroga("knecht", przed, PI * 0.5)
	await get_tree().create_timer(0.3).timeout
	var tors_przed := _hp(kn, "tors")
	_strzel_w(swiat, kn, "tarcza", "A_9_FMJ")
	await get_tree().create_timer(0.25).timeout
	print("knecht: 9 mm w tarczę, tors ", tors_przed, " -> ", _hp(kn, "tors"), ", tarcza hp=", _hp(kn, "tarcza"))
	_strzel_w(swiat, kn, "glowa", "A_556_FMJ")
	await get_tree().create_timer(0.25).timeout
	print("knecht po 5,56 w głowę: zyje=", kn.zyje)
	kn.queue_free()
	swiat.wrogowie.erase(kn)
	# rycerz: napierśnik kontra wizjer
	var ry := swiat.dodaj_wroga("rycerz", przed, PI * 0.5)
	await get_tree().create_timer(0.3).timeout
	var t0 := _hp(ry, "tors")
	_strzel_w(swiat, ry, "tors", "A_556_FMJ")
	await get_tree().create_timer(0.25).timeout
	print("rycerz: 5,56 FMJ w napierśnik, tors ", t0, " -> ", _hp(ry, "tors"))
	_strzel_w(swiat, ry, "tors", "A_556_AP")
	await get_tree().create_timer(0.25).timeout
	print("rycerz: 5,56 AP w napierśnik, tors -> ", _hp(ry, "tors"))
	var g0 := _hp(ry, "glowa")
	_strzel_w(swiat, ry, "glowa", "A_9_FMJ", "szczelina")
	await get_tree().create_timer(0.25).timeout
	print("rycerz: 9 mm w wizjer, głowa ", g0, " -> ", _hp(ry, "glowa"))
	ry.queue_free()
	swiat.wrogowie.erase(ry)
	# pościg i cios
	var gh3 := swiat.dodaj_wroga("ghul", g.global_position + Vector3(9.0, 0, 0), PI * 0.5)
	var czas := 0.0
	var suma0 := 0.0
	for k in g.zdrowie.hp:
		suma0 += g.zdrowie.hp[k]
	while czas < 14.0:
		await get_tree().create_timer(0.25).timeout
		czas += 0.25
		var suma := 0.0
		for k in g.zdrowie.hp:
			suma += g.zdrowie.hp[k]
		if suma < suma0:
			break
	print("ghul dobiegł i uderzył po ", czas, " s; stan=", gh3.stan, " zdrowie gracza=", g.zdrowie.hp)
	print("rany: lekkie=", g.zdrowie.krwawienie_lekkie, " ciężkie=", g.zdrowie.krwawienie_ciezkie)
	gh3.queue_free()
	swiat.wrogowie.erase(gh3)
	g.zdrowie.krwawienie_lekkie = 1
	g.zdrowie.zacznij_uzycie("bandaz")
	await get_tree().create_timer(3.4).timeout
	print("po bandażu: lekkie=", g.zdrowie.krwawienie_lekkie, " bandaży=", g.zdrowie.leki["bandaz"])
	# hałas
	var gh4 := swiat.dodaj_wroga("ghul", g.global_position + Vector3(0, 0, 12.0), 0.0)
	await get_tree().create_timer(0.3).timeout
	swiat.halas(g.global_position, 40.0)
	await get_tree().create_timer(0.3).timeout
	print("ghul za ścianą po wystrzale: stan=", gh4.stan)
	g.zdrowie.cios(999.0)
	await get_tree().create_timer(6.0).timeout
	print("po śmierci: świat=", gra.nazwa_swiata, " gracz żyje=", gra.swiat.gracz.zdrowie.zyje)
	print("TEST LOCHU ZAKOŃCZONY")
	get_tree().quit()


func _klik(pozycja: Vector2, wcisniety: bool) -> void:
	var ruch := InputEventMouseMotion.new()
	ruch.position = pozycja
	ruch.global_position = pozycja
	Input.parse_input_event(ruch)
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = wcisniety
	ev.position = pozycja
	ev.global_position = pozycja
	Input.parse_input_event(ev)


func _klatki(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _zapisz(nazwa: String) -> void:
	await _klatki(3)
	get_viewport().get_texture().get_image().save_png(_katalog + "/" + nazwa + ".png")


## Zrzuty z kopalni: korytarz, każdy wróg z bliska, atak, zwłoki z krwią.
func _zrzuty_loch() -> void:
	var gra := get_parent()
	var swiat: Kopalnia = gra.swiat
	var g := swiat.gracz
	g.sterowanie = false
	for w in swiat.wrogowie.duplicate():
		w.queue_free()
	swiat.wrogowie.clear()
	await _klatki(40)
	await _zapisz("20_korytarz")
	var typy := ["ghul", "knecht", "rycerz"]
	for i in 3:
		var w := swiat.dodaj_wroga(typy[i], g.global_position + Vector3(3.4, 0, 0.25), PI * 0.5)
		w.set_physics_process(false)
		await _klatki(25)
		await _zapisz("2%d_%s" % [i + 1, typy[i]])
		if i == 0:
			w.stan = "goni"
			await _klatki(20)
			await _zapisz("24_ghul_goni")
			w.stan = "atak"
			w.set("_t_stan", 0.2)
			await _klatki(14)
			await _zapisz("25_ghul_zamach")
		if i == 2:
			w.stan = "atak"
			w.set("_t_stan", 0.3)
			await _klatki(16)
			await _zapisz("26_rycerz_zamach")
			w.stan = "czuwa"
			for b in swiat.bronie:
				b.test_cel = 1.0
			g.set("_pitch", deg_to_rad(1.5))
			await _klatki(30)
			await _zapisz("27_rycerz_cel")
			for b in swiat.bronie:
				b.test_cel = 0.0
			g.set("_pitch", 0.0)
		if i == 1:
			_strzel_w(swiat, w, "przedramie_p", "A_556_FMJ")
			await _klatki(6)
			_strzel_w(swiat, w, "glowa", "A_556_FMJ")
			_strzel_w(swiat, w, "tors", "A_556_AP")
			await _klatki(40)
			await _zapisz("28_knecht_zabity")
		w.queue_free()
		swiat.wrogowie.erase(w)
		await _klatki(4)
	var gh := swiat.dodaj_wroga("ghul", g.global_position + Vector3(3.0, 0, 0), PI * 0.5)
	gh.set_physics_process(false)
	await _klatki(10)
	_strzel_w(swiat, gh, "ramie_l", "A_556_FMJ")
	_strzel_w(swiat, gh, "ramie_l", "A_556_FMJ")
	await _klatki(4)
	_strzel_w(swiat, gh, "glowa", "A_556_FMJ")
	await _klatki(45)
	g.set("_pitch", deg_to_rad(-18.0))
	await _klatki(10)
	await _zapisz("29_ghul_zwloki")
	g.zdrowie.cios(30.0, true)
	g.zdrowie.cios(34.0, true)
	g.set("_pitch", 0.0)
	await _klatki(10)
	await _zapisz("30_rany")
	gra.hud.otworz_ekwipunek(gh.pojemnik if gh.pojemnik != null else Pojemnik.new(3, 2, "E_ZWLOKI"))
	var skrz: Skrzynia = get_tree().get_nodes_in_group("pojemniki")[0]
	gra.hud.otworz_ekwipunek(skrz.pojemnik)
	await _klatki(8)
	await _zapisz("31_ekwipunek_szukanie")
	for p in skrz.pojemnik.rzeczy:
		p["odkryty"] = true
	await _klatki(6)
	await _zapisz("32_ekwipunek")
	get_tree().quit()


## Siatka, waga, ładowanie magazynka, plecak, łup, przenoszenie między lokacjami, śmierć.
func _test_ekwipunek() -> void:
	var gra := get_parent()
	var E := Ekwipunek
	await get_tree().create_timer(0.3).timeout
	print("masa startowa: ", snappedf(E.masa(), 0.01), " kg; mnożnik ruchu ", E.mnoznik_ruchu())
	print("kamizelka: ", E.kamizelka.rzeczy.size(), " rzeczy; plecak: ", E.plecak.rzeczy.size(), "; kieszenie: ", E.kieszenie.rzeczy.size())
	# obrót i kolizje w siatce
	var szyna := E.nowy("szyna")
	var poj := Pojemnik.new(2, 2)
	print("szyna 1×2 w siatce 2×2: pion ", poj.wloz(szyna, 0, 0, false), ", druga obok ", poj.wloz(E.nowy("szyna"), 1, 0, false), ", trzecia ", poj.wloz_gdziekolwiek(E.nowy("szyna")))
	var poj2 := Pojemnik.new(2, 1)
	print("szyna w siatce 2×1 tylko po obrocie: ", poj2.wloz(E.nowy("szyna"), 0, 0, false), " / ", poj2.wloz_gdziekolwiek(E.nowy("szyna")))
	# ładowanie magazynka z paczki
	var mag: Dictionary = E.magazynki("kwarc")[0]
	mag["dane"]["naboje"].resize(20)
	var paczka := {}
	for p in E.plecak.rzeczy:
		if p["id"] == "paczka_556" and p["dane"]["typ"] == "A_556_SS":
			paczka = p
	print("start ładowania: ", E.zacznij_ladowanie(mag, paczka))
	await get_tree().create_timer(2.0).timeout
	print("po 2 s: w magazynku ", mag["dane"]["naboje"].size(), ", w paczce ", paczka["dane"]["ile"], ", na wierzchu ", mag["dane"]["naboje"][-1])
	E.przerwij_ladowanie()
	# przeciąganie myszą: bandaż z kieszeni do plecaka, z obrotem szyny
	gra.hud.otworz_ekwipunek(null)
	await get_tree().create_timer(0.3).timeout
	var ui: EkwipunekUI = gra.hud.ekwipunek
	var y_plecak := 150.0 + 58.0 * 2 + 64 + E.kamizelka.wys * 58.0 + 64
	var bandaze_k := 0
	for p in E.kieszenie.rzeczy:
		if p["id"] == "bandaz":
			bandaze_k += 1
	_klik(Vector2(430 + 20, 150 + 20), true)
	await get_tree().create_timer(0.15).timeout
	_klik(Vector2(430 + 3 * 58 + 20, y_plecak + 4 * 58 + 20), false)
	await get_tree().create_timer(0.15).timeout
	var bandaze_k2 := 0
	for p in E.kieszenie.rzeczy:
		if p["id"] == "bandaz":
			bandaze_k2 += 1
	var w_plecaku := not E.plecak.na_polu(3, 4).is_empty()
	print("przeciągnięcie: rozmiar ekranu ekwipunku ", ui.size, ", bandaże w kieszeniach ", bandaze_k, " -> ", bandaze_k2, ", w plecaku na (3,4): ", w_plecaku)
	gra.hud.zamknij_panele()
	# przeciążenie
	for i in 14:
		E.plecak.wloz_gdziekolwiek(E.nowy("konserwa"))
	for i in 3:
		E.plecak.wloz_gdziekolwiek(E.nowy("relikwia"))
	print("po dopakowaniu: ", snappedf(E.masa(), 0.01), " kg; mnożnik ruchu ", snappedf(E.mnoznik_ruchu(), 0.01), "; hałas ×", snappedf(E.mnoznik_halasu(), 0.01))
	# zrzucenie i podniesienie plecaka
	var przed := E.masa()
	gra.swiat.zrzuc_plecak()
	await get_tree().create_timer(1.2).timeout
	print("plecak zrzucony: ", snappedf(przed, 0.1), " -> ", snappedf(E.masa(), 0.1), " kg; leży: ", get_tree().get_nodes_in_group("do_podniesienia").size())
	var lezy: Node3D = gra.swiat.magazynek_w_zasiegu()
	if lezy != null and E.podnies(lezy.get("przedmiot")):
		lezy.queue_free()
	await get_tree().create_timer(0.2).timeout
	print("plecak podniesiony: ", snappedf(E.masa(), 0.1), " kg; rzeczy w plecaku: ", E.plecak.rzeczy.size())
	# przeniesienie stanu broni do kopalni
	var b: Bron = gra.swiat.bron()
	b.call("_strzal")
	b.call("_strzal")
	var w_mag: int = b.mag.size()
	E.relikwiarz.wloz_gdziekolwiek(E.nowy("monety"))
	gra.zmien_swiat("kopalnia")
	await get_tree().create_timer(1.0).timeout
	print("w kopalni: mag ", gra.swiat.bron().mag.size(), " (było ", w_mag, "), masa ", snappedf(E.masa(), 0.1))
	# skrzynia: przeszukiwanie odkrywa po jednym przedmiocie
	var skrzynia: Skrzynia = get_tree().get_nodes_in_group("pojemniki")[0]
	var ukryte := 0
	for p in skrzynia.pojemnik.rzeczy:
		if not p["odkryty"]:
			ukryte += 1
	gra.hud.otworz_ekwipunek(skrzynia.pojemnik)
	await get_tree().create_timer(1.6).timeout
	var ukryte2 := 0
	for p in skrzynia.pojemnik.rzeczy:
		if not p["odkryty"]:
			ukryte2 += 1
	print("skrzynia: ", skrzynia.pojemnik.rzeczy.size(), " rzeczy, ukryte ", ukryte, " -> ", ukryte2, " po 1,6 s")
	gra.hud.zamknij_panele()
	# śmierć: zostaje relikwiarz
	gra.swiat.gracz.zdrowie.cios(999.0)
	await get_tree().create_timer(6.0).timeout
	print("po śmierci: świat ", gra.nazwa_swiata, ", masa ", snappedf(E.masa(), 0.1), " kg, relikwiarz: ", E.relikwiarz.rzeczy.size(), ", plecak: ", E.plecak.rzeczy.size(), ", mag w broni: ", gra.swiat.bron().mag.size())
	print("TEST EKWIPUNKU ZAKOŃCZONY")
	get_tree().quit()


## Baza, skrytka, zamiana noszonych rzeczy, głód, Przebudzenie, wyjścia, zapis.
func _test_ekstrakcja() -> void:
	var gra := get_parent()
	var E := Ekwipunek
	await get_tree().create_timer(0.3).timeout
	print("skrytka: ", E.skrytka.rzeczy.size(), " rzeczy")
	var pas := {}
	var patrolowy := {}
	for p in E.skrytka.rzeczy:
		if p["id"] == "pas":
			pas = p
		elif p["id"] == "plecak_patrolowy":
			patrolowy = p
	print("pas zamiast kamizelki (4 magazynki 1×2 nie wejdą w 4×1): ", E.zamien_noszone(pas, E.skrytka), "; kamizelka nadal ", E.kamizelka_p["id"])
	var rzeczy_w_plecaku := E.plecak.rzeczy.size()
	print("plecak patrolowy: ", E.zamien_noszone(patrolowy, E.skrytka), "; siatka ", E.plecak.szer, "×", E.plecak.wys, "; stary plecak w skrytce z ", rzeczy_w_plecaku, " rzeczami")
	for p in E.skrytka.rzeczy.duplicate():
		if p["id"] == "plecak_szturmowy":
			E.zamien_noszone(p, E.skrytka)
	# zapis i odczyt stanu
	var masa0 := E.masa()
	var tekst := var_to_str(E.call("_stan"))
	E.call("_ustaw_stan", str_to_var(tekst))
	print("zapis bazy: ", tekst.length(), " znaków; masa ", snappedf(masa0, 0.01), " -> ", snappedf(E.masa(), 0.01), "; skrytka ", E.skrytka.rzeczy.size(), "; mag w stanie broni ", E.stan_broni["kwarc"]["mag"]["dane"]["naboje"].size())
	# jedzenie
	E.sytosc = 30.0
	E.nawodnienie = 20.0
	var racja := {}
	var manierka := {}
	for p in E.plecak.rzeczy:
		if p["id"] == "racja":
			racja = p
		elif p["id"] == "manierka":
			manierka = p
	var z: Zdrowie = gra.swiat.gracz.zdrowie
	print("niedobór przy pragnieniu 20%: ", snappedf(z.niedobor(), 0.01))
	z.zacznij_spozycie(manierka)
	await get_tree().create_timer(2.8).timeout
	z.zacznij_spozycie(racja)
	await get_tree().create_timer(5.3).timeout
	print("po manierce i racji: sytość ", E.sytosc, ", nawodnienie ", E.nawodnienie, ", porcje w manierce ", manierka["dane"]["porcje"])
	# wyprawa
	gra.wyrusz()
	await get_tree().create_timer(1.0).timeout
	var k: Kopalnia = gra.swiat
	print("w kopalni: na_wyprawie=", E.na_wyprawie, ", wrogów ", k.wrogowie.size(), ", przebudzenie ", snappedf(k.przebudzenie, 0.01))
	var n0 := E.nawodnienie
	await get_tree().create_timer(2.0).timeout
	print("pragnienie rośnie: ", snappedf(n0 - E.nawodnienie, 0.001), " pkt w 2 s")
	k.halas(k.gracz.global_position, 55.0)
	print("po wystrzale: przebudzenie ", snappedf(k.przebudzenie, 0.01))
	k.przebudzenie = 24.9
	await get_tree().create_timer(1.5).timeout
	print("próg 1: prog=", k.prog, ", wrogów ", k.wrogowie.size(), ", komunikat: ", gra.hud.get("_komunikat").text)
	k.przebudzenie = 50.0
	await get_tree().create_timer(0.5).timeout
	print("próg 2: chodnik zawalony=", k.chodnik_zawalony, ", wrogów ", k.wrogowie.size())
	# zapis biwaku
	k.gracz.zdrowie.cios(20.0)
	var stan := k.stan_do_zapisu()
	var stan2: Dictionary = str_to_var(var_to_str(stan))
	print("stan biwaku: żywi ", stan2["zywi"], ", skrzyń ", stan2["skrzynie"].size(), ", hp torsu ", snappedf(stan2["zdrowie"]["hp"]["tors"], 0.1))
	# wyjście przez kratę
	for w in k.wrogowie.duplicate():
		w.queue_free()
	k.wrogowie.clear()
	k.gracz.global_position = k.call("_srodek", 20, 9) + Vector3(0, 0.05, 0)
	await get_tree().create_timer(0.3).timeout
	print("przy kracie: ", k.podpowiedz())
	k.uzyj(gra)
	await get_tree().create_timer(0.3).timeout
	print("bez klucza: świat ", gra.nazwa_swiata)
	E.kieszenie.wloz_gdziekolwiek(E.nowy("klucz"))
	E.kieszenie.wloz_gdziekolwiek(E.nowy("monety"))
	k.uzyj(gra)
	await get_tree().create_timer(1.0).timeout
	print("z kluczem: świat ", gra.nazwa_swiata, ", na_wyprawie=", E.na_wyprawie, ", wyprawy=", E.wyprawy, ", monety wyniesione: ", E.leki().size() > 0 and not E.kieszenie.rzeczy.is_empty())
	# wznowienie z biwaku
	gra.set("_dane_biwaku", stan2)
	gra.zmien_swiat("kopalnia")
	await get_tree().create_timer(1.0).timeout
	k = gra.swiat
	print("wznowienie: przebudzenie ", snappedf(k.przebudzenie, 0.1), ", prog ", k.prog, ", chodnik zawalony ", k.chodnik_zawalony, ", hp torsu ", snappedf(k.gracz.zdrowie.hp["tors"], 0.1), ", pozycja przy biwaku ", k.podpowiedz())
	print("TEST EKSTRAKCJI ZAKOŃCZONY")
	get_tree().quit()


## Nowa broń, strzelba, zamek czterotaktowy, receptury, żyły, oprawianie, łuski.
func _test_rzemioslo() -> void:
	var gra := get_parent()
	var E := Ekwipunek
	await get_tree().create_timer(0.3).timeout
	# każda broń główna: wyjęcie, strzał, przeładowanie
	for id in Bron.GLOWNE:
		gra.przezbroj(id, "weteran" if id != "kwarc" else "jaspis")
		await get_tree().create_timer(0.8).timeout
		gra.hud.zamknij_panele()
		var b: Bron = gra.swiat.bron()
		var przed: int = b.mag.size()
		b.call("_strzal")
		await get_tree().create_timer(1.3).timeout
		print(id, ": mag ", przed, " -> ", b.mag.size(), ", komora '", b.komora, "', masa zestawu ", snappedf(E.masa(), 0.1))
	# strzelba: ładowanie po naboju z paczki w kieszeni
	gra.przezbroj("lupek", "weteran")
	await get_tree().create_timer(0.8).timeout
	gra.hud.zamknij_panele()
	var s: Bron = gra.swiat.bron()
	for i in 3:
		s.call("_strzal")
		await get_tree().create_timer(0.8).timeout
	print("strzelba po 3 strzałach: rura ", s.mag.size(), ", komora '", s.komora, "'")
	E.kieszenie.rzeczy.clear()
	E.kieszenie.wloz_gdziekolwiek(E.nowa_paczka("paczka_12", "A_12_BRENEKA", 10))
	s.typ_ladowany = "A_12_BRENEKA"
	s.call("_zacznij_przeladowanie", false)
	await get_tree().create_timer(3.0).timeout
	print("po ładowaniu: rura ", s.mag.size(), " ", s.mag, ", w paczce ", E.kieszenie.rzeczy[0]["dane"]["ile"], ", opis: ", s.call("_opis_magazynka"))
	gra.swiat.zmien_bron(1)
	await get_tree().create_timer(0.8).timeout
	var wt: Bron = gra.swiat.bron()
	wt.call("_strzal")
	print("weteran: mag ", wt.mag.size(), ", komora ", wt.komora)
	# receptury w bazie (ze skrytką)
	E.dodaj_zasob("ruda_miedzi", 4, true)
	E.dodaj_zasob("ruda_olowiu", 2, true)
	E.dodaj_zasob("ruda_zelaza", 2, true)
	E.dodaj_zasob("wegiel", 3, true)
	E.dodaj_zasob("siarka", 1, true)
	E.dodaj_zasob("saletra", 1, true)
	var spl0 := E.ile_zasobu("splonki", true)
	for r in Rzemioslo.receptury("piec"):
		Rzemioslo.wykonaj(r, true)
	print("piec: mosiądz ", E.ile_zasobu("sztabka_mosiadzu", true), ", ołów ", E.ile_zasobu("sztabka_olowiu", true), ", stal ", E.ile_zasobu("sztabka_stali", true))
	var stol := Rzemioslo.receptury("stol")
	Rzemioslo.wykonaj(stol[0], true)
	var n556 := 0
	for r in stol:
		if r.has("wyjscie") and r["wyjscie"].has("luski_556"):
			Rzemioslo.wykonaj(r, true)
	for r in stol:
		if r.has("naboje") and r["naboje"][0] == "A_556_SS":
			print("receptura: ", Rzemioslo.opis(r), " | można: ", Rzemioslo.mozna(r, true))
			var przed_ss := _ile_naboi("A_556_SS")
			Rzemioslo.wykonaj(r, true)
			n556 = _ile_naboi("A_556_SS") - przed_ss
	print("złożono 5,56 SS: ", n556, "; spłonki ", spl0, " -> ", E.ile_zasobu("splonki", true), "; proch ", E.ile_zasobu("proch", true), "; stal ", E.ile_zasobu("sztabka_stali", true))
	var paczka := {}
	for p in E.skrytka.rzeczy:
		if p["id"] == "paczka_9" and p["dane"]["typ"] == "A_9_HP":
			paczka = p
	var l9 := E.ile_zasobu("luski_9", true)
	Rzemioslo.rozbierz(paczka, true)
	print("demontaż 50× 9 mm HP: łuski 9 mm ", l9, " -> ", E.ile_zasobu("luski_9", true), ", spłonki ", E.ile_zasobu("splonki", true))
	# kopalnia: żyła, łuski, oprawianie
	gra.przezbroj("kwarc", "jaspis")
	await get_tree().create_timer(0.8).timeout
	gra.hud.zamknij_panele()
	gra.wyrusz()
	await get_tree().create_timer(1.0).timeout
	var k: Kopalnia = gra.swiat
	for w in k.wrogowie.duplicate():
		w.queue_free()
	k.wrogowie.clear()
	k.gracz.global_position = k.call("_srodek", 6, 1) + Vector3(0, 0.05, 0)
	await get_tree().create_timer(0.3).timeout
	print("przy żyle: ", k.podpowiedz())
	k.uzyj(gra)
	await get_tree().create_timer(0.2).timeout
	print("bez kilofa: ", gra.hud.get("_komunikat").text)
	E.plecak.wloz_gdziekolwiek(E.nowy("kilof"))
	var m0 := E.masa()
	var pb0: float = k.przebudzenie
	k.uzyj(gra)
	await get_tree().create_timer(7.4).timeout
	print("po kuciu: ruda miedzi ", E.ile_zasobu("ruda_miedzi"), ", masa +", snappedf(E.masa() - m0, 0.01), " kg, przebudzenie +", snappedf(k.przebudzenie - pb0, 0.1), ", w żyle zostało ", k.get("_zyly")[0]["ile"])
	var b2: Bron = k.bron()
	for i in 6:
		b2.call("_strzal")
	await get_tree().create_timer(0.3).timeout
	print("łuski: ", k.podpowiedz_wspolna())
	k.uzyj_wspolne(gra)
	await get_tree().create_timer(3.3).timeout
	print("zebrano łusek 5,56: ", E.ile_zasobu("luski_556"), " z 6 strzałów")
	var gh := k.dodaj_wroga("ghul", k.gracz.global_position + Vector3(1.2, 0, 0), 0.0)
	gh.set_physics_process(false)
	await get_tree().create_timer(0.2).timeout
	gh.call("_umrzyj", Vector3(1, 0, 0))
	await get_tree().create_timer(0.3).timeout
	print("przy zwłokach: ", k.podpowiedz_wspolna())
	k.opraw(gra)
	await get_tree().create_timer(4.4).timeout
	var czesci := []
	for p in gh.pojemnik.rzeczy:
		czesci.append(p["id"])
	print("po oprawieniu: ", czesci, ", oprawiony=", gh.oprawiony)
	k.gracz.global_position = k.call("_srodek", 18, 3) + Vector3(0, 0.05, 0)
	await get_tree().create_timer(0.2).timeout
	print("piec w lochu: ", k.podpowiedz())
	print("TEST RZEMIOSŁA ZAKOŃCZONY")
	get_tree().quit()


func _ile_naboi(typ: String) -> int:
	var n := 0
	for p in Ekwipunek.skrytka.rzeczy:
		if p["dane"].get("typ", "") == typ:
			n += int(p["dane"]["ile"])
	return n


## Każda broń z biodra i w celowaniu, do kontroli zgrania przyrządów.
func _zrzuty_broni() -> void:
	var gra := get_parent()
	DirAccess.make_dir_recursive_absolute(_katalog)
	await _klatki(20)
	for id in ["granit", "gabro", "lupek", "krzemien", "weteran"]:
		if id == "weteran":
			gra.przezbroj("kwarc", "weteran")
		else:
			gra.przezbroj(id, "jaspis")
		await _klatki(12)
		gra.hud.zamknij_panele()
		var sw: Swiat = gra.swiat
		sw.gracz.sterowanie = false
		sw.gracz.global_position = Vector3(0.95, 0.05, -4.0)
		sw.gracz.rotation.y = 0.0
		sw.gracz.set("_pitch", deg_to_rad(-7.0))
		if id == "weteran":
			sw.zmien_bron(1)
		await _klatki(50)
		await _zapisz("b_%s_biodro" % id)
		for b in sw.bronie:
			b.test_cel = 1.0
		await _klatki(50)
		await _zapisz("b_%s_cel" % id)
		sw.bron().call("_strzal")
		await _klatki(4)
		await _zapisz("b_%s_strzal" % id)
		await _klatki(40)
	get_tree().quit()


func _zrzuty_dodatkow() -> void:
	var gra := get_parent()
	var E := Ekwipunek
	DirAccess.make_dir_recursive_absolute(_katalog)
	await _klatki(20)
	E.skrytka.wloz_gdziekolwiek(E.nowy("tlumik_kar"))
	for p in E.skrytka.rzeczy.duplicate():
		if p["id"] in ["holo", "tlumik_kar"]:
			E.zamontuj("kwarc", p)
		elif p["id"] == "tlumik_9":
			E.zamontuj("jaspis", p)
	gra.przezbroj("kwarc", "jaspis", "pluton")
	await _klatki(12)
	await _zapisz("d_pluton")
	gra.hud.otworz_rzemioslo("stol", true)
	await _klatki(6)
	await _zapisz("d_stol")
	gra.hud.zamknij_panele()
	var sw: Swiat = gra.swiat
	sw.gracz.sterowanie = false
	sw.gracz.global_position = Vector3(0.95, 0.05, -4.0)
	sw.gracz.rotation.y = 0.0
	sw.gracz.set("_pitch", deg_to_rad(-7.0))
	await _klatki(50)
	await _zapisz("d_kwarc_biodro")
	for b in sw.bronie:
		b.test_cel = 1.0
	await _klatki(50)
	await _zapisz("d_kwarc_cel")
	sw.bron().call("_strzal")
	await _klatki(25)
	await _zapisz("d_kwarc_po_strzale")
	for b in sw.bronie:
		b.test_cel = 0.0
	sw.zmien_bron(1)
	await _klatki(60)
	await _zapisz("d_jaspis_biodro")
	get_tree().quit()


## Pluton: zadania, jedzenie, rany, śmierć, koniec kampanii, dodatki do broni.
func _test_pluton() -> void:
	var gra := get_parent()
	var E := Ekwipunek
	await get_tree().create_timer(0.3).timeout
	print("pluton: ", E.pluton.size(), ", idzie: ", E.zolnierz()["imie"], " (", E.spec(), "), odrzut ×", E.mod("odrzut"), ", hałas ×", E.mod("halas"))
	print("ranny nie zastąpi zdrowego: ", E.wyznacz(1), " -> ", E.zolnierz()["imie"], ", hałas ×", E.mod("halas"))
	E.wyznacz(0)
	# zadania
	E.pluton[1]["zadanie"] = E.ZADANIA.find("Z_ZWIAD")
	E.pluton[2]["zadanie"] = E.ZADANIA.find("Z_WYTOP")
	E.pluton[3]["zadanie"] = E.ZADANIA.find("Z_APROWIZACJA")
	E.pluton[5]["zadanie"] = E.ZADANIA.find("Z_AMUNICJA")
	E.dodaj_zasob("ruda_miedzi", 4, true)
	E.dodaj_zasob("ruda_olowiu", 2, true)
	var jedzenie := func() -> int:
		var n := 0
		for p in E.skrytka.rzeczy:
			if E.PRZEDMIOTY[p["id"]]["typ"] == "jedzenie":
				n += 1
		return n
	var j0: int = jedzenie.call()
	var n0 := _ile_naboi("A_556_FMJ")
	gra.wyrusz()
	await get_tree().create_timer(1.0).timeout
	gra.swiat.gracz.zdrowie.cios(40.0)
	gra.swiat.gracz.zdrowie.hp["tors"] = 30.0
	gra.swiat.gracz.zdrowie.hp["noga_l"] = 20.0
	print("rany po powrocie w tym stanie: ", gra.swiat.gracz.zdrowie.rany_po_powrocie())
	gra.ewakuacja()
	await get_tree().create_timer(1.0).timeout
	print("raport:")
	for r in E.raport:
		print("   ", r)
	print("jedzenie w skrytce ", j0, " -> ", jedzenie.call(), "; 5,56 FMJ ", n0, " -> ", _ile_naboi("A_556_FMJ"), "; mosiądz ", E.ile_zasobu("sztabka_mosiadzu", true), "; zwiad=", E.zwiad)
	print("po powrocie idzie: ", E.zolnierz()["imie"], "; Wilk rany=", E.pluton[0]["rany"], " wyprawy=", E.pluton[0]["wyprawy"], "; panel plutonu otwarty: ", gra.hud.panel_otwarty())
	gra.hud.zamknij_panele()
	# dodatki
	var kol := {}
	var tl := {}
	E.skrytka.wloz_gdziekolwiek(E.nowy("tlumik_kar"))
	for p in E.skrytka.rzeczy:
		if p["id"] == "kolimator":
			kol = p
		elif p["id"] == "tlumik_kar":
			tl = p
	print("kolimator na Kwarc: ", E.zamontuj("kwarc", kol), ", na Krzemień: ", E.zamontuj("krzemien", E.nowy("kolimator")), ", tłumik: ", E.zamontuj("kwarc", tl), " -> ", E.dodatki("kwarc"))
	gra.przezbroj("kwarc", "jaspis", "stol")
	await get_tree().create_timer(0.8).timeout
	gra.hud.zamknij_panele()
	var b: Bron = gra.swiat.bron()
	print("broń: tłumik=", b.tlumik, " kolimator=", b.kolimator)
	var st: Dictionary = str_to_var(var_to_str(E.call("_stan")))
	print("zapis: dodatki ", st["bron"]["kwarc"]["dodatki"], ", pluton ", st["pluton"].size(), ", aktywny ", st["aktywny"])
	E.zdejmij("kwarc", "tlumik_kar")
	print("po zdjęciu: ", E.dodatki("kwarc"), ", w skrytce tłumik: ", E.ile_zasobu("tlumik_kar", true))
	# kolejne wyprawy: lazaret, głód
	for p in E.skrytka.rzeczy.duplicate():
		if E.PRZEDMIOTY[p["id"]]["typ"] == "jedzenie":
			E.skrytka.usun(p)
	E.rozlicz_wyprawe(0)
	print("bez jedzenia: ", E.raport.map(func(r): return r[1]))
	# śmierć po kolei aż do końca kampanii
	var kolejnosc := []
	for i in 6:
		kolejnosc.append(E.zolnierz()["imie"])
		gra.wyrusz()
		await get_tree().create_timer(0.6).timeout
		gra.swiat.gracz.zdrowie.cios(999.0)
		await get_tree().create_timer(5.8).timeout
	print("ginęli: ", kolejnosc)
	print("żywi: ", E.zywi(), ", koniec kampanii: ", E.koniec_kampanii(), ", panel: ", gra.hud.panel_otwarty(), ", polegli ", E.polegli)
	E.nowa_kampania()
	print("nowa kampania: żywi ", E.zywi(), ", skrytka ", E.skrytka.rzeczy.size(), ", idzie ", E.zolnierz()["imie"])
	print("TEST PLUTONU ZAKOŃCZONY")
	get_tree().quit()


## Klatki animacji wrogów do kontroli jakości: chód z profilu, bieg, atak w trzech etapach, upadki.
## Uruchamiać z --swiat=kopalnia; opcjonalnie --typy=ghul,knecht.
func _zrzuty_animacji() -> void:
	DirAccess.make_dir_recursive_absolute(_katalog)
	await _klatki(30)
	var gra := get_parent()
	var swiat: Kopalnia = gra.swiat
	var g := swiat.gracz
	g.sterowanie = false
	for w in swiat.wrogowie.duplicate():
		w.queue_free()
	swiat.wrogowie.clear()
	for b in swiat.bronie:
		b.visible = false
	var typy := ["ghul", "knecht", "rycerz"]
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--typy="):
			typy = Array(a.trim_prefix("--typy=").split(","))
	var miejsce := g.global_position + Vector3(3.6, 0, 0.0)
	var lampa := OmniLight3D.new()
	lampa.omni_range = 9.0
	lampa.light_energy = 2.2
	swiat.add_child(lampa)
	lampa.global_position = g.global_position + Vector3(1.2, 1.9, 0.6)
	for typ in typy:
		var d: Dictionary = Wrog.TYPY[typ]
		# chód i bieg z profilu
		for tryb in ["chod", "bieg"]:
			var w := swiat.dodaj_wroga(typ, miejsce, 0.0)
			w.set_physics_process(false)
			w.stan = "goni" if tryb == "bieg" else "szuka"
			w.velocity = Vector3(0, 0, -float(d[tryb]))
			await _klatki(20)
			for i in 6:
				w.set("_faza", PI * 2.0 * i / 6.0)
				await _klatki(1)
				w.velocity = Vector3.ZERO
				var faza: float = w.get("_faza")
				for k in 10:
					w.set("_faza", faza)
					w.velocity = Vector3(0, 0, -float(d[tryb]))
					await _klatki(1)
				await _zapisz("%s_%s_%d" % [typ, tryb, i])
			w.queue_free()
			swiat.wrogowie.erase(w)
			await _klatki(3)
		# atak: zamach, cios, wyprowadzenie (z ukosa)
		var wa := swiat.dodaj_wroga(typ, miejsce, PI * 0.28)
		wa.set_physics_process(false)
		wa.stan = "atak"
		var zam: float = d["zamach"]
		var czasy := [zam * 0.9, zam + 0.10, zam + 0.45]
		for i in 3:
			for k in 30:
				wa.set("_t_stan", czasy[i])
				await _klatki(1)
			await _zapisz("%s_atak_%d" % [typ, i])
		# stany szczególne: litania, celowanie z kuszy, napinanie
		var dodatkowe := []
		if d.get("kaznodzieja", false):
			dodatkowe.append("kazanie")
		if d.has("strzela"):
			dodatkowe.append_array(["celuje", "laduje"])
		for st in dodatkowe:
			wa.stan = st
			for k in 30:
				wa.set("_t_stan", 0.6)
				await _klatki(1)
			await _zapisz("%s_stan_%s" % [typ, st])
		wa.queue_free()
		swiat.wrogowie.erase(wa)
		# wzdrygnięcie i trzy upadki
		var kierunki := [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1)]
		for i in 3:
			var wu := swiat.dodaj_wroga(typ, miejsce, PI * 0.5 if i < 2 else PI * 0.5)
			wu.rotation.y = [PI * 0.25, PI * 0.25, PI * 0.5][i]
			wu.set_physics_process(false)
			await _klatki(15)
			var lok: Vector3 = wu.global_transform.basis * ([Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0.2)][i] as Vector3)
			if i == 0:
				wu.set("_wstrzas", Vector3(0.42, 0.34, -0.1))
				await _klatki(5)
				await _zapisz("%s_wstrzas" % typ)
			seed(7 + i)
			wu.call("_umrzyj", lok.normalized())
			await _klatki(14)
			await _zapisz("%s_upadek%d_a" % [typ, i])
			await _klatki(14)
			await _zapisz("%s_upadek%d_b" % [typ, i])
			await _klatki(60)
			await _zapisz("%s_upadek%d_c" % [typ, i])
			if OS.has_environment("DIAG"):
				var sm: Dictionary = wu.get("_smierc")
				var mm: Node3D = wu.get("_model")
				print(typ, i, " bok=", sm["bok"], " kier=", sm["kier"], " model=", mm.rotation, " rl=", (wu.get("_w")["ramie_l"] as Node3D).rotation, " rp=", (wu.get("_w")["ramie_p"] as Node3D).rotation, " tors=", (wu.get("_w")["tors"] as Node3D).rotation, " pl=", (wu.get("_w")["przedramie_l"] as Node3D).rotation)
			wu.queue_free()
			swiat.wrogowie.erase(wu)
			await _klatki(3)
	print("ZRZUTY ANIMACJI ZAPISANE")
	get_tree().quit()


func _odczekaj(sek: float) -> void:
	await get_tree().create_timer(sek).timeout


func _sprzataj(swiat: Kopalnia) -> void:
	for w in swiat.wrogowie.duplicate():
		if is_instance_valid(w):
			w.queue_free()
	swiat.wrogowie.clear()
	await _odczekaj(0.2)


## Nowi wrogowie z builda 6b: ucieczka warga, regeneracja trolla, morale Zakonu, kusza, litania, walka frakcji.
func _test_wrogowie() -> void:
	var gra := get_parent()
	var swiat: Kopalnia = gra.swiat
	var g := swiat.gracz
	g.sterowanie = false
	var typy := {}
	for w in swiat.wrogowie:
		typy[w.typ] = int(typy.get(w.typ, 0)) + 1
	print("wrogowie na mapie: ", typy)
	await _sprzataj(swiat)
	var przed := g.global_position + Vector3(6.0, 0, 0)
	# warg: dwa trafienia w tułów i ucieczka
	var wa := swiat.dodaj_wroga("warg", przed, 0.0)
	wa.set_physics_process(false)
	await _odczekaj(0.3)
	wa.stan = "goni"
	_strzel_w(swiat, wa, "tulow", "A_556_FMJ")
	await _odczekaj(0.2)
	_strzel_w(swiat, wa, "tulow", "A_556_FMJ")
	await _odczekaj(0.3)
	print("warg po 2× 5,56 w tułów: hp=", _hp(wa, "tulow"), " stan=", wa.stan, " żyje=", wa.zyje)
	wa.set_physics_process(true)
	await _odczekaj(1.5)
	print("warg po 1,5 s ucieczki: odległość od gracza ", snappedf(wa.global_position.distance_to(g.global_position), 0.1), " m (było 6)")
	_strzel_w(swiat, wa, "glowa", "A_556_FMJ")
	await _sprzataj(swiat)
	# troll: skóra klasy 3, regeneracja, ciężki kaliber
	var tr_ := swiat.dodaj_wroga("troll", przed, PI * 0.5)
	tr_.set_physics_process(false)
	await _odczekaj(0.3)
	_strzel_w(swiat, tr_, "tors", "A_9_FMJ")
	await _odczekaj(0.2)
	print("troll: 9 mm FMJ w tors: ", _hp(tr_, "tors"), " / 420")
	for i in 4:
		_strzel_w(swiat, tr_, "tors", "A_556_AP")
		await _odczekaj(0.15)
	var po := _hp(tr_, "tors")
	await _odczekaj(3.0)
	print("troll: 4× 5,56 AP -> ", po, ", po 3 s regeneracji -> ", _hp(tr_, "tors"))
	tr_.set_physics_process(false)
	tr_.rotation.y = PI * 0.5
	await _odczekaj(0.1)
	_strzel_w(swiat, tr_, "tors", "A_76251_AP")
	await _odczekaj(0.2)
	var po2 := _hp(tr_, "tors")
	await _odczekaj(3.0)
	print("troll: 7,62×51 AP -> ", po2, ", po 3 s -> ", _hp(tr_, "tors"), " (rany nie zarastają)")
	_strzel_w(swiat, tr_, "glowa", "A_556_FMJ")
	await _odczekaj(0.2)
	print("troll: 5,56 FMJ w czaszkę klasy 5: ", _hp(tr_, "glowa"), " / 90")
	await _sprzataj(swiat)
	# morale Zakonu: huk bez dowódcy i z dowódcą
	var ucieklo := 0
	for i in 20:
		var z := swiat.dodaj_wroga("wlocznik", przed + Vector3(0, 0, 0), 0.0)
		z.set_physics_process(false)
		z.uslyszal(g.global_position, 55.0)
		if z.stan == "ucieka":
			ucieklo += 1
	print("Zakon bez dowódcy: po pierwszym wystrzale ucieka ", ucieklo, " z 20")
	await _sprzataj(swiat)
	swiat.dodaj_wroga("komtur", przed + Vector3(1, 0, 0), 0.0).set_physics_process(false)
	ucieklo = 0
	for i in 20:
		var z := swiat.dodaj_wroga("wlocznik", przed, 0.0)
		z.set_physics_process(false)
		z.uslyszal(g.global_position, 55.0)
		if z.stan == "ucieka":
			ucieklo += 1
	print("Zakon z komturem: ucieka ", ucieklo, " z 20")
	await _sprzataj(swiat)
	# kusznik: celuje, strzela, ładuje
	var ku := swiat.dodaj_wroga("kusznik", g.global_position + Vector3(9.0, 0, 0), PI * 0.5)
	ku.set("_poznal_huk", true)
	g.latarka = true
	var hp0: float = 0.0
	for k in g.zdrowie.hp:
		hp0 += float(g.zdrowie.hp[k])
	var stany := []
	var beltow := 0
	for i in 60:
		await _odczekaj(0.1)
		if stany.is_empty() or stany[-1] != ku.stan:
			stany.append(ku.stan)
		for c in swiat.get_children():
			if c is Belt:
				beltow = 1
	var hp1: float = 0.0
	for k in g.zdrowie.hp:
		hp1 += float(g.zdrowie.hp[k])
	print("kusznik z 9 m: stany ", stany, " bełt w locie: ", beltow == 1, " zdrowie gracza ", snappedf(hp0, 0.1), " -> ", snappedf(hp1, 0.1))
	await _sprzataj(swiat)
	# kaznodzieja: litania budzi loch i wprawia ghula w szał
	var p0 := swiat.przebudzenie
	var gh := swiat.dodaj_wroga("ghul", g.global_position + Vector3(9.0, 0, 0), 0.0)
	gh.set_physics_process(false)
	var ka := swiat.dodaj_wroga("kultysta", g.global_position + Vector3(8.0, 0, 0), PI * 0.5)
	await _odczekaj(4.0)
	print("kaznodzieja: stan=", ka.stan, " przebudzenie ", snappedf(p0, 0.1), " -> ", snappedf(swiat.przebudzenie, 0.1), " szał ghula=", float(gh.get("_szal")) > 0.0)
	await _sprzataj(swiat)
	# frakcje: włócznik i ghul obok siebie, gracz daleko i po ciemku
	g.latarka = false
	var daleko := g.global_position + Vector3(6.0, 0, 0)
	var wl := swiat.dodaj_wroga("wlocznik", daleko, PI * 0.5)
	var gh3 := swiat.dodaj_wroga("ghul", daleko + Vector3(2.5, 0, 0), -PI * 0.5)
	var t := 0.0
	while t < 25.0 and wl.zyje and gh3.zyje:
		await _odczekaj(0.25)
		t += 0.25
	print("włócznik kontra ghul: po ", t, " s włócznik żyje=", wl.zyje, " ghul żyje=", gh3.zyje)
	print("TEST WROGÓW ZAKOŃCZONY")
	get_tree().quit()


## Generator lochu: moduły mają przejścia, 300 ziaren daje kompletne i przechodnie lochy,
## to samo ziarno daje ten sam loch, a loch z --ziarno= buduje się w grze.
func _test_generator() -> void:
	for m in GeneratorLochu.ZWYKLE + [GeneratorLochu.M_START, GeneratorLochu.M_BIWAK, GeneratorLochu.M_WARSZTAT, GeneratorLochu.M_CHODNIK, GeneratorLochu.M_ARENA]:
		assert(m.size() == 5)
		for wiersz in m:
			assert((wiersz as String).length() == 7)
		for c in [[3, 0], [3, 4], [0, 2], [6, 2]]:
			assert((m[c[1]] as String)[c[0]] != "#", "moduł bez przejścia")
	var rozne := {}
	var min_w := 99
	var max_w := 0
	var z_trollem := 0
	for ziarno in 300:
		var u := GeneratorLochu.generuj(ziarno)
		assert(u.has("mapa") and (u["zyly"] as Array).size() >= 6 and (u["skrzynie"] as Array).size() >= 4)
		var rudy := {}
		for z in u["zyly"]:
			rudy[z[1]] = true
		assert(rudy.size() == 5, "brak którejś rudy")
		var sklad := GeneratorLochu.sklad(u["mapa"])
		assert(sklad.has("troll_stary") and sklad.has("wlocznik") and sklad.has("kusznik"))
		var ilu := 0
		for t in sklad:
			ilu += int(sklad[t])
		min_w = mini(min_w, ilu)
		max_w = maxi(max_w, ilu)
		if sklad.has("troll"):
			z_trollem += 1
		rozne["|".join(PackedStringArray(u["mapa"]))] = true
	print("300 ziaren: różnych układów ", rozne.size(), ", wrogów od ", min_w, " do ", max_w, ", z trollem jaskiniowym ", z_trollem)
	var a := GeneratorLochu.generuj(4242)
	var b := GeneratorLochu.generuj(4242)
	print("to samo ziarno daje ten sam loch: ", a["mapa"] == b["mapa"] and a["zyly"] == b["zyly"])
	var gra := get_parent()
	if gra.swiat is Kopalnia:
		var k: Kopalnia = gra.swiat
		print("loch w grze: ziarno ", k.ziarno, ", pól ", k.mapa[0].length(), "×", k.mapa.size(), ", wrogów ", k.wrogowie.size(), ", skrzyń ", k.skrzynie_pola.size(), ", żył ", k.zyly_pola.size())
		for wiersz in k.mapa:
			print("  ", wiersz)
		# droga po siatce od zejścia do każdego wyjścia i biwaku
		for para in [["szyb", k.P_SZYB], ["chodnik", k.P_CHODNIK], ["biwak", k.P_BIWAK], ["piec", k.P_PIEC], ["stół", k.P_STOL]]:
			var c: Vector2i = para[1]
			var droga := k.sciezka(k.gracz.global_position, k.call("_srodek", c.x, c.y))
			print("  droga do: ", para[0], " — ", droga.size(), " punktów")
		var boss := 0
		for w in k.wrogowie:
			if w.typ == "troll_stary":
				boss += 1
				print("  boss: tors ", _hp(w, "tors"), " pkt, klasa ", (w.call("_strefa_segmentu", "tors") as StrefaWroga).klasa, ", ", snappedf(w.global_position.distance_to(k.call("_srodek", k.P_SZYB.x, k.P_SZYB.y)), 0.1), " m od szybu")
		assert(boss == 1)
	print("TEST GENERATORA ZAKOŃCZONY")
	get_tree().quit()


## Ekran bazy 2D, ekwipunek ze slotami i menu kontekstowym, modyfikacja broni. Uruchamiać z --baza.
func _zrzuty_bazy() -> void:
	DirAccess.make_dir_recursive_absolute(_katalog)
	var gra := get_parent()
	var hud: Hud = gra.hud
	await _klatki(20)
	assert(hud.baza.visible, "ekran bazy powinien być widoczny po starcie")
	for id in ["holo", "kolimator", "tlumik_kar", "tlumik_9", "chwyt_przedni"]:
		Ekwipunek.skrytka.wloz_gdziekolwiek(Ekwipunek.nowy(id))
	Ekwipunek.zwiad = true
	hud.baza.odswiez()
	await _klatki(5)
	await _zapisz("40_baza")
	hud.otworz_ekwipunek(Ekwipunek.skrytka)
	await _klatki(5)
	await _zapisz("41_ekwipunek_baza")
	# menu kontekstowe na pierwszym przedmiocie ze stosem w skrytce
	var e: EkwipunekUI = hud.ekwipunek
	var wybrany := {}
	for p in Ekwipunek.skrytka.rzeczy:
		if p["dane"].has("naboje") and not (p["dane"]["naboje"] as Array).is_empty():
			wybrany = p
			break
	var obszar := Vector2.ZERO
	for o in e.get("_obszary"):
		if o["poj"] == Ekwipunek.skrytka:
			obszar = o["pos"]
	var gdzie := obszar + Vector2(wybrany["x"] + 0.5, wybrany["y"] + 0.5) * EkwipunekUI.POLE
	e.call("_menu_przedmiotu", wybrany, Ekwipunek.skrytka, gdzie)
	await _klatki(5)
	await _zapisz("42_menu_przedmiotu")
	(e.get("_menu") as PopupMenu).hide()
	var przed: int = (wybrany["dane"]["naboje"] as Array).size()
	e.call("_rozladuj", wybrany, Ekwipunek.skrytka)
	print("rozładowanie magazynka: ", przed, " -> ", (wybrany["dane"]["naboje"] as Array).size())
	for p in Ekwipunek.skrytka.rzeczy:
		if int(p["dane"].get("ile", 1)) > 1:
			var ile := int(p["dane"]["ile"])
			var n0 := Ekwipunek.skrytka.rzeczy.size()
			e.call("_podziel", p, Ekwipunek.skrytka)
			print("podział stosu ", ile, " -> ", int(p["dane"]["ile"]), " + nowy stos; przedmiotów ", n0, " -> ", Ekwipunek.skrytka.rzeczy.size())
			break
	e.call("_pokaz_info", e.call("_linie_info", wybrany), gdzie)
	await _klatki(5)
	await _zapisz("43_informacje")
	e.call("_menu_slotu", "glowna", Vector2(200, 290))
	await _klatki(5)
	await _zapisz("44_menu_broni")
	(e.get("_menu") as PopupMenu).hide()
	hud.otworz_modyfikacje(Ekwipunek.bron_glowna)
	await _klatki(8)
	await _zapisz("45_modyfikacje_puste")
	var m: ModyfikacjeUI = hud.modyfikacje
	for slot in ["szyna", "wylot", "chwyt"]:
		var opcje: Array = m.get("_opcje")[slot]
		if opcje.size() > 1:
			m.call("_wybrano", slot, 1)
	await _klatki(8)
	print("dodatki po montażu: ", Ekwipunek.dodatki(Ekwipunek.bron_glowna))
	await _zapisz("46_modyfikacje_zamontowane")
	m.set("_obrot", Vector2(-0.5, 2.4))
	await _klatki(5)
	await _zapisz("47_modyfikacje_obrot")
	hud.zamknij_panele()
	await _klatki(3)
	assert(hud.baza.visible and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	gra.na_strzelnice()
	await _klatki(30)
	# zużycie i zacięcia: zaniedbana broń zacina się, R usuwa zacięcie, naprawa w bazie zeruje zużycie
	var b: Bron = gra.swiat.bron()
	Ekwipunek.stan(b.id)["zuzycie"] = 0.95
	var zaciec := 0
	var strzalow := 0
	for i in 400:
		if b.komora == "" and not b.zaciecie:
			b.komora = "A_556_FMJ"
		if b.zaciecie:
			zaciec += 1
			b.call("_zdarzenie", "odblokuj")
			continue
		b.call("_strzal")
		strzalow += 1
	Ekwipunek.stan(b.id)["zuzycie"] = 0.0
	var czysta := 0
	for i in 300:
		b.komora = "A_556_FMJ"
		b.call("_strzal")
		if b.zaciecie:
			czysta += 1
			b.zaciecie = false
	print("zużyta broń (5% stanu): ", zaciec, " zacięć na ", strzalow, " strzałów; nowa broń: ", czysta, " na 300; zużycie po 300 strzałach z tłumikiem: ", snappedf(b.zuzycie(), 0.001))
	Ekwipunek.stan(b.id)["zuzycie"] = 0.6
	Ekwipunek.dodaj_zasob("sztabka_stali", 1, true)
	print("naprawa: ", Ekwipunek.napraw_bron(b.id), " stan po naprawie ", Ekwipunek.stan_techniczny(b.id), " chwyt=", b.chwyt)
	print("strzelnica: baza widoczna=", hud.baza.visible, " broń z dodatkami: tłumik=", gra.swiat.bron().tlumik, " kolimator=", gra.swiat.bron().kolimator)
	await _zapisz("48_strzelnica")
	print("ZRZUTY BAZY ZAPISANE")
	get_tree().quit()
