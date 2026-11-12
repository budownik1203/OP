class_name GeneratorLochu
extends RefCounted
## Składa kopalnię z ręcznie zrobionych modułów. To samo ziarno daje ten sam loch,
## więc zwiad w bazie pokazuje prawdziwy skład, a biwak wznawia ten sam układ.
##
## Moduł ma 7×5 pól. Przejścia zawsze na środku każdej krawędzi: (3,0) (3,4) (0,2) (6,2).
## Znaki: # skała, . podłoga, T pochodnia, $ miejsce na skrzynię, * miejsce na żyłę,
## S zejście, B biwak, P piec, W stół rusznikarski, C stary chodnik, E szyb za kratą, X legowisko bossa.

const MS := 7          ## szerokość modułu
const MW := 5          ## wysokość modułu
const KOLUMNY := 3
const RZEDY := 3

const ZWYKLE := [
	["###.###",
	 "#*...$#",
	 ".......",
	 "#*.T..#",
	 "###.###"],
	["......*",
	 ".#.T.#.",
	 ".......",
	 ".#...#$",
	 "*......"],
	["#...###",
	 "#.####*",
	 ".......",
	 "*####.#",
	 "###..$#"],
	["#T...##",
	 "#.#.#.$",
	 "..#....",
	 "#*..#.*",
	 "##...##"],
	["*......",
	 ".##.##.",
	 "..$.*..",
	 ".##.##.",
	 "...T..."],
	["###.#*#",
	 "#$....#",
	 "...#...",
	 "#....T#",
	 "#*#.###"],
	["#..T..#",
	 "..#.#..",
	 ".##.##.",
	 "*.#.#.$",
	 "#.....#"],
	["##...*#",
	 "#$.#..#",
	 "...#...",
	 "#..#.T#",
	 "#*...##"],
]
const M_START := ["###.###", "#S....#", ".......", "#..T..#", "###.###"]
const M_BIWAK := ["###.###", "#.....#", "...B...", "#*...$#", "###.###"]
const M_WARSZTAT := ["#P...W#", "#.....#", "...T...", "#*....#", "###.###"]
const M_CHODNIK := ["###.###", "#C....#", "...#...", "#....*#", "###.###"]
const M_ARENA := ["#.....#", ".E#.#..", "...X...", "..#.#.$", "#.....#"]

const RUDY := ["ruda_miedzi", "ruda_olowiu", "ruda_zelaza", "siarka", "saletra"]
const ZNAKI_WROGOW := {"g": "ghul", "k": "knecht", "r": "rycerz", "w": "warg", "c": "kultysta",
	"z": "wlocznik", "x": "kusznik", "K": "komtur", "O": "troll", "X": "troll_stary"}


## Zwraca {mapa, start, szyb, chodnik, biwak, piec, stol, boss, skrzynie, zyly, ziarno}.
static func generuj(ziarno: int) -> Dictionary:
	var proba := 0
	while true:
		var wynik := _proba(ziarno * 31 + proba)
		if not wynik.is_empty():
			wynik["ziarno"] = ziarno
			return wynik
		proba += 1
	return {}


static func _proba(ziarno: int) -> Dictionary:
	var los := RandomNumberGenerator.new()
	los.seed = ziarno
	var n := KOLUMNY * RZEDY
	# drzewo rozpinające po gniazdach (każde osiągalne) i dwa dodatkowe przejścia (pętle)
	var polaczenia := {}
	var odwiedzone := {0: true}
	var stos := [0]
	while not stos.is_empty():
		var akt: int = stos[-1]
		var sasiedzi := []
		for s in _sasiedzi(akt):
			if not odwiedzone.has(s):
				sasiedzi.append(s)
		if sasiedzi.is_empty():
			stos.pop_back()
			continue
		var nast: int = sasiedzi[los.randi_range(0, sasiedzi.size() - 1)]
		polaczenia[_klucz(akt, nast)] = true
		odwiedzone[nast] = true
		stos.append(nast)
	var dodatkowe := 0
	var bezpiecznik := 0
	while dodatkowe < 2 and bezpiecznik < 50:
		bezpiecznik += 1
		var a := los.randi_range(0, n - 1)
		var ss := _sasiedzi(a)
		var b: int = ss[los.randi_range(0, ss.size() - 1)]
		if not polaczenia.has(_klucz(a, b)):
			polaczenia[_klucz(a, b)] = true
			dodatkowe += 1
	# role gniazd: start w rogu, szyb z bossem najdalej, chodnik daleko, biwak w połowie drogi
	var rogi := [0, KOLUMNY - 1, n - KOLUMNY, n - 1]
	var start: int = rogi[los.randi_range(0, 3)]
	var odl := _odleglosci(start, polaczenia)
	var kolejnosc := range(n)
	kolejnosc.erase(start)
	kolejnosc.sort_custom(func(a: int, b: int) -> bool: return odl[a] > odl[b] or (odl[a] == odl[b] and a < b))
	var rola := {start: M_START}
	var arena: int = kolejnosc[0]
	rola[arena] = M_ARENA
	var chodnik: int = kolejnosc[1 + los.randi_range(0, 1)]
	rola[chodnik] = M_CHODNIK
	var wolne := []
	for g in kolejnosc:
		if not rola.has(g):
			wolne.append(g)
	# biwak: gniazdo o środkowej odległości; warsztat: losowe z reszty
	var biwak: int = wolne[wolne.size() / 2]
	rola[biwak] = M_BIWAK
	wolne.erase(biwak)
	var warsztat: int = wolne[los.randi_range(0, wolne.size() - 1)]
	rola[warsztat] = M_WARSZTAT
	wolne.erase(warsztat)
	var talia := range(ZWYKLE.size())
	for g in wolne:
		var i: int = talia[los.randi_range(0, talia.size() - 1)]
		talia.erase(i)
		rola[g] = _odbij(ZWYKLE[i], los.randf() < 0.5, los.randf() < 0.5)
	# siatka pól: wszystko skała, potem moduły i przejścia
	var szer := KOLUMNY * (MS + 1) + 1
	var wys := RZEDY * (MW + 1) + 1
	var pola := []
	for y in wys:
		var wiersz := []
		wiersz.resize(szer)
		wiersz.fill("#")
		pola.append(wiersz)
	for g in n:
		var x0 := 1 + (g % KOLUMNY) * (MS + 1)
		var y0 := 1 + (g / KOLUMNY) * (MW + 1)
		var m: Array = rola[g]
		for y in MW:
			for x in MS:
				pola[y0 + y][x0 + x] = (m[y] as String)[x]
	for k in polaczenia:
		var a: int = int(k) / 100
		var b: int = int(k) % 100
		var ax := 1 + (a % KOLUMNY) * (MS + 1)
		var ay := 1 + (a / KOLUMNY) * (MW + 1)
		if b == a + 1:
			pola[ay + 2][ax + MS] = "."
		else:
			pola[ay + MW][ax + 3] = "."
	# pozycje znaków szczególnych, miejsca na skrzynie i żyły
	var w := {"skrzynie": [], "zyly": []}
	var sloty_s := []
	var sloty_z := []
	for y in wys:
		for x in szer:
			var c := Vector2i(x, y)
			match pola[y][x]:
				"S": w["start"] = c
				"B": w["biwak"] = c
				"P": w["piec"] = c
				"W": w["stol"] = c
				"C": w["chodnik"] = c
				"E": w["szyb"] = c
				"X": w["boss"] = c
				"$": sloty_s.append(c)
				"*": sloty_z.append(c)
			if pola[y][x] in ["B", "P", "W", "C", "E", "$", "*"]:
				pola[y][x] = "."
	_tasuj(sloty_s, los)
	_tasuj(sloty_z, los)
	for i in mini(6, sloty_s.size()):
		w["skrzynie"].append(sloty_s[i])
	var ile_zyl := mini(8, sloty_z.size())
	for i in ile_zyl:
		w["zyly"].append([sloty_z[i], RUDY[i % RUDY.size()]])
	if ile_zyl < 6 or w["skrzynie"].size() < 4:
		return {}
	# wrogowie: im dalej od zejścia, tym groźniejsi; Straż Zakonu stoi razem w jednym module
	var zajete := {}
	for c in w["skrzynie"]:
		zajete[c] = true
	for z in w["zyly"]:
		zajete[z[0]] = true
	for kl in ["start", "biwak", "piec", "stol", "chodnik", "szyb", "boss"]:
		zajete[w[kl]] = true
	var zwykle_gniazda := wolne.duplicate()
	zwykle_gniazda.sort_custom(func(a: int, b: int) -> bool: return odl[a] < odl[b] or (odl[a] == odl[b] and a < b))
	var gniazdo_zakonu: int = zwykle_gniazda[los.randi_range(maxi(0, zwykle_gniazda.size() - 2), zwykle_gniazda.size() - 1)]
	var zestaw := ["g", "g", "g", "k", "k", "w", "c", "r"]
	if los.randf() < 0.5:
		zestaw.append("w")
	if los.randf() < 0.5:
		zestaw.append("O")
	if los.randf() < 0.5:
		zestaw.append("g")
	# słabi bliżej, silni dalej: sortowanie zestawu po sile i gniazd po odległości
	var sila := {"g": 1, "w": 2, "k": 2, "c": 3, "r": 4, "O": 5}
	zestaw.sort_custom(func(a: String, b: String) -> bool: return sila[a] < sila[b])
	var gniazda_wrogow := []
	for g in n:
		if g != start and g != gniazdo_zakonu and g != arena:
			gniazda_wrogow.append(g)
	gniazda_wrogow.sort_custom(func(a: int, b: int) -> bool: return odl[a] < odl[b] or (odl[a] == odl[b] and a < b))
	for i in zestaw.size():
		var g: int = gniazda_wrogow[mini(int(float(i) / zestaw.size() * gniazda_wrogow.size() + los.randf() * 0.99), gniazda_wrogow.size() - 1)]
		var c := _wolne_pole(pola, g, zajete, los)
		if c.x >= 0:
			pola[c.y][c.x] = zestaw[i]
			zajete[c] = true
	var straz := ["z", "x"]
	if los.randf() < 0.6:
		straz.append("K")
	if los.randf() < 0.5:
		straz.append("z")
	for znak in straz:
		var c := _wolne_pole(pola, gniazdo_zakonu, zajete, los)
		if c.x >= 0:
			pola[c.y][c.x] = znak
			zajete[c] = true
	# kontrola: z zejścia da się dojść do każdego ważnego miejsca
	var dostepne := _zalew(pola, w["start"])
	for kl in ["biwak", "piec", "stol", "chodnik", "szyb", "boss"]:
		if not dostepne.has(w[kl]):
			return {}
	for c in w["skrzynie"]:
		if not dostepne.has(c):
			return {}
	for z in w["zyly"]:
		if not dostepne.has(z[0]):
			return {}
	var mapa := []
	for y in wys:
		mapa.append("".join(PackedStringArray(pola[y])))
	w["mapa"] = mapa
	return w


static func _klucz(a: int, b: int) -> int:
	return mini(a, b) * 100 + maxi(a, b)


static func _sasiedzi(g: int) -> Array:
	var w := []
	var x := g % KOLUMNY
	var y := g / KOLUMNY
	if x > 0:
		w.append(g - 1)
	if x < KOLUMNY - 1:
		w.append(g + 1)
	if y > 0:
		w.append(g - KOLUMNY)
	if y < RZEDY - 1:
		w.append(g + KOLUMNY)
	return w


static func _odleglosci(start: int, polaczenia: Dictionary) -> Dictionary:
	var odl := {start: 0}
	var kolejka := [start]
	while not kolejka.is_empty():
		var a: int = kolejka.pop_front()
		for b in _sasiedzi(a):
			if polaczenia.has(_klucz(a, b)) and not odl.has(b):
				odl[b] = int(odl[a]) + 1
				kolejka.append(b)
	return odl


static func _odbij(m: Array, poziomo: bool, pionowo: bool) -> Array:
	var w := []
	for wiersz in m:
		w.append((wiersz as String).reverse() if poziomo else wiersz)
	if pionowo:
		w.reverse()
	return w


static func _tasuj(t: Array, los: RandomNumberGenerator) -> void:
	for i in range(t.size() - 1, 0, -1):
		var j := los.randi_range(0, i)
		var tmp = t[i]
		t[i] = t[j]
		t[j] = tmp


## Wolne pole podłogi w module, nie w przejściu i nie zajęte.
static func _wolne_pole(pola: Array, g: int, zajete: Dictionary, los: RandomNumberGenerator) -> Vector2i:
	var x0 := 1 + (g % KOLUMNY) * (MS + 1)
	var y0 := 1 + (g / KOLUMNY) * (MW + 1)
	var kandydaci := []
	for y in MW:
		for x in MS:
			var c := Vector2i(x0 + x, y0 + y)
			var w_przejsciu := (x == 3 and (y == 0 or y == MW - 1)) or (y == 2 and (x == 0 or x == MS - 1))
			if pola[c.y][c.x] == "." and not zajete.has(c) and not w_przejsciu:
				kandydaci.append(c)
	if kandydaci.is_empty():
		return Vector2i(-1, -1)
	return kandydaci[los.randi_range(0, kandydaci.size() - 1)]


static func _zalew(pola: Array, od: Vector2i) -> Dictionary:
	var w := {od: true}
	var kolejka := [od]
	while not kolejka.is_empty():
		var c: Vector2i = kolejka.pop_front()
		for k in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var s: Vector2i = c + k
			if s.y < 0 or s.y >= pola.size() or s.x < 0 or s.x >= pola[0].size():
				continue
			if pola[s.y][s.x] != "#" and not w.has(s):
				w[s] = true
				kolejka.append(s)
	return w


## Liczba wrogów każdego typu na mapie (do zwiadu).
static func sklad(mapa: Array) -> Dictionary:
	var licz := {}
	for wiersz in mapa:
		for znak in (wiersz as String):
			if ZNAKI_WROGOW.has(znak):
				licz[ZNAKI_WROGOW[znak]] = int(licz.get(ZNAKI_WROGOW[znak], 0)) + 1
	return licz
