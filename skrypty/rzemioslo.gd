class_name Rzemioslo
extends RefCounted
## Receptury: piec hutniczy i stół rusznikarski.
## Receptura: {stacja, nazwa (tekst gotowy), wejscie {id: ile}, wyjscie {id: ile}, naboje [typ, ile], demontaz typ}

static func receptury(stacja: String) -> Array:
	var l := []
	if stacja == "piec":
		l.append({"wejscie": {"ruda_miedzi": 2}, "wyjscie": {"sztabka_mosiadzu": 1}})
		l.append({"wejscie": {"ruda_olowiu": 2}, "wyjscie": {"sztabka_olowiu": 1}})
		l.append({"wejscie": {"ruda_zelaza": 2, "wegiel": 1}, "wyjscie": {"sztabka_stali": 1}})
		return l
	l.append({"wejscie": {"siarka": 1, "saletra": 1, "wegiel": 1}, "wyjscie": {"proch": 40}})
	for kal in Amunicja.KALIBRY:
		var partia: int = Amunicja.KALIBRY[kal][2]
		l.append({"wejscie": {"sztabka_mosiadzu": 1}, "wyjscie": {Amunicja.luski(kal): partia}})
	for typ in Amunicja.TYPY:
		var kal: String = Amunicja.TYPY[typ]["kaliber"]
		var partia: int = Amunicja.KALIBRY[kal][2]
		var wej := {Amunicja.luski(kal): partia, "proch": partia * int(Amunicja.KALIBRY[kal][1]), "splonki": partia, "sztabka_olowiu": 1}
		if typ in Amunicja.ZE_STALA:
			wej["sztabka_stali"] = 1
		l.append({"wejscie": wej, "naboje": [typ, partia]})
	return l


static func opis(r: Dictionary) -> String:
	var we := []
	for id in r["wejscie"]:
		we.append("%d× %s" % [r["wejscie"][id], TranslationServer.translate(Ekwipunek.PRZEDMIOTY[id]["nazwa"])])
	var wy := ""
	if r.has("naboje"):
		wy = "%d× %s" % [r["naboje"][1], TranslationServer.translate(r["naboje"][0])]
	else:
		var cz := []
		for id in r["wyjscie"]:
			cz.append("%d× %s" % [r["wyjscie"][id], TranslationServer.translate(Ekwipunek.PRZEDMIOTY[id]["nazwa"])])
		wy = ", ".join(cz)
	return wy + "   ←   " + ", ".join(we)


static func mozna(r: Dictionary, ze_skrytka: bool) -> bool:
	for id in r["wejscie"]:
		if Ekwipunek.ile_zasobu(id, ze_skrytka) < int(r["wejscie"][id]):
			return false
	return true


## Wykonuje recepturę. Zwraca liczbę sztuk, które nie zmieściły się w ekwipunku.
static func wykonaj(r: Dictionary, ze_skrytka: bool) -> int:
	if not mozna(r, ze_skrytka):
		return -1
	for id in r["wejscie"]:
		Ekwipunek.zuzyj_zasob(id, int(r["wejscie"][id]), ze_skrytka)
	var reszta := 0
	if r.has("naboje"):
		reszta += Ekwipunek.dodaj_naboje(r["naboje"][0], int(r["naboje"][1]), ze_skrytka)
	else:
		for id in r["wyjscie"]:
			reszta += Ekwipunek.dodaj_zasob(id, int(r["wyjscie"][id]), ze_skrytka)
	return reszta


## Demontaż paczki naboi: wracają łuski, proch i spłonki; ołów przepada.
static func rozbierz(paczka: Dictionary, ze_skrytka: bool) -> void:
	var typ: String = paczka["dane"]["typ"]
	var kal: String = Amunicja.TYPY[typ]["kaliber"]
	var n := int(paczka["dane"]["ile"])
	Ekwipunek.wyjmij(paczka)
	Ekwipunek.skrytka.usun(paczka)
	Ekwipunek.dodaj_zasob(Amunicja.luski(kal), n, ze_skrytka)
	Ekwipunek.dodaj_zasob("proch", n * int(Amunicja.KALIBRY[kal][1]), ze_skrytka)
	Ekwipunek.dodaj_zasob("splonki", n, ze_skrytka)
