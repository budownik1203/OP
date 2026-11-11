class_name Pojemnik
extends RefCounted
## Siatka pól na przedmioty. Przedmiot to słownik:
## {id, x, y, obr (obrócony o 90°), dane (np. naboje magazynka), odkryty}.

var szer := 1
var wys := 1
var rzeczy: Array = []
var nazwa := ""              ## klucz tekstu
var tylko := ""              ## jeśli ustawione: przyjmuje tylko przedmioty tego typu


func _init(s := 1, w := 1, n := "") -> void:
	szer = s
	wys = w
	nazwa = n


static func wymiary(p: Dictionary, obr: bool) -> Vector2i:
	var def: Dictionary = Ekwipunek.PRZEDMIOTY[p["id"]]
	return Vector2i(def["h"], def["w"]) if obr else Vector2i(def["w"], def["h"])


func wolne(x: int, y: int, w: int, h: int, pomin: Dictionary = {}) -> bool:
	if x < 0 or y < 0 or x + w > szer or y + h > wys:
		return false
	for r in rzeczy:
		if is_same(r, pomin):
			continue
		var wr := wymiary(r, r["obr"])
		if x < r["x"] + wr.x and r["x"] < x + w and y < r["y"] + wr.y and r["y"] < y + h:
			return false
	return true


func przyjmuje(p: Dictionary) -> bool:
	return tylko == "" or Ekwipunek.PRZEDMIOTY[p["id"]]["typ"] == tylko


func wloz(p: Dictionary, x: int, y: int, obr: bool) -> bool:
	if not przyjmuje(p):
		return false
	var w := wymiary(p, obr)
	if not wolne(x, y, w.x, w.y, p):
		return false
	p["x"] = x
	p["y"] = y
	p["obr"] = obr
	if not rzeczy.has(p):
		rzeczy.append(p)
	return true


func wloz_gdziekolwiek(p: Dictionary) -> bool:
	if not przyjmuje(p):
		return false
	for obr in [false, true]:
		var w := wymiary(p, obr)
		for y in wys:
			for x in szer:
				if wolne(x, y, w.x, w.y):
					return wloz(p, x, y, obr)
	return false


func usun(p: Dictionary) -> void:
	for i in rzeczy.size():
		if is_same(rzeczy[i], p):
			rzeczy.remove_at(i)
			return


func na_polu(x: int, y: int) -> Dictionary:
	for r in rzeczy:
		var wr := wymiary(r, r["obr"])
		if x >= r["x"] and x < r["x"] + wr.x and y >= r["y"] and y < r["y"] + wr.y:
			return r
	return {}


func masa() -> float:
	var m := 0.0
	for r in rzeczy:
		m += Ekwipunek.masa_przedmiotu(r)
	return m
