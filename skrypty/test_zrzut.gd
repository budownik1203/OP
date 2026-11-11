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
	get_tree().quit()
