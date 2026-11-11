"""Wrogowie z builda 6b: kaznodzieja, Straż Zakonu (włócznik, kusznik, komtur), troll jaskiniowy, warg.
Uruchom: python3 postacie2.py [nazwy]. Ludzie i troll korzystają ze szkieletu z postacie.py."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wspolne as w
import postacie as P

CIEMNY = lambda: w.material("ciemny", w.tekstura("ciemny", ["#040404", "#070707"], ziarno=5), 1.0)


# =================================================================== KAZNODZIEJA
def mat_kultysta():
    t = w.tekstura
    habit = w.material("habit", t("habit", ["#2a1414", "#331a18", "#3d201c", "#1e1512"], skala=3.5, ziarno=61, drobny=0.5, progi=[0.3, 0.7, 0.93]), 1.0)
    return {
        "skora": w.material("skora_blada", t("skora_blada", ["#7d7466", "#8a8072", "#978c7d", "#6a5a50"], skala=6.0, ziarno=62, drobny=0.3, progi=[0.3, 0.7, 0.93]), 0.85),
        "ubranie": habit,
        "golen": w.material("onuce", t("onuce", ["#3a342a", "#454033", "#514a3b"], skala=5.0, ziarno=63, drobny=0.5), 1.0),
        "but": w.material("but", t("but", ["#1c1815", "#231e1a", "#2b2520"], skala=4.0, ziarno=45, drobny=0.4), 0.9),
        "sznur": w.material("sznur", t("sznur", ["#5a4d36", "#685a40", "#75664a"], skala=8.0, ziarno=64, drobny=0.6), 1.0),
        "zelazo": w.material("zelazo", t("zelazo", ["#3b3c3d", "#47484a", "#545556", "#4a3526"], skala=5.0, ziarno=46, drobny=0.4, progi=[0.3, 0.7, 0.93]), 0.5, 0.6),
        "drewno": w.material("deska", t("deska", ["#33261a", "#402f20", "#4d3926"], skala=9.0, ziarno=47, drobny=0.2), 0.9),
        "kosc": w.material("kosc_stara", t("kosc_stara", ["#8a8068", "#978c72", "#a4997c"], skala=6.0, ziarno=65, drobny=0.3), 0.8),
        "zar": w.material("zar", t("zar", ["#b5521a", "#d06a1e", "#e88a2a"], skala=6.0, ziarno=66, drobny=0.4), 0.6),
        "ciemny": CIEMNY(),
    }


def kultysta_glowa(s, m):
    # kaptur: głęboki, opadający na barki, szpic z tyłu
    s.rura([((0, -0.004, 1.470), 0.330, 0.250), ((0, -0.002, 1.560), 0.235, 0.235), ((0, -0.006, 1.660), 0.205, 0.250),
            ((0, -0.014, 1.760), 0.200, 0.262), ((0, -0.030, 1.828), 0.150, 0.205), ((0, -0.085, 1.850), 0.050, 0.070)], m["ubranie"])
    s.segment((0, 0.085, 1.790), (0, 0.118, 1.740), 0.170, 0.050, 0.150, 0.020, m["ubranie"], gora=(0, 0, 1), boki=6)   # daszek kaptura
    s.pudlo((-0.062, 0.100, 1.645), (0.062, 0.1045, 1.748), m["ciemny"])                                               # cień twarzy


def kultysta_miednica(s, m):
    # habit do kolan, rozcięty z boków, przepasany sznurem
    s.rura([((0, 0, 1.060), 0.300, 0.215), ((0, 0.004, 0.900), 0.350, 0.265), ((0, 0.006, 0.700), 0.385, 0.300), ((0, 0.008, 0.560), 0.405, 0.320)], m["ubranie"])
    s.rura([((0, 0, 1.085), 0.305, 0.220), ((0, 0, 1.055), 0.305, 0.220)], m["sznur"])
    s.segment((0.085, 0.112, 1.06), (0.095, 0.150, 0.74), 0.022, 0.022, 0.018, 0.018, m["sznur"], gora=(0, 1, 0), boki=6)
    for i in range(3):
        s.segment((0.092, 0.142, 0.84 - i * 0.05), (0.094, 0.146, 0.815 - i * 0.05), 0.034, 0.034, 0.034, 0.034, m["sznur"], gora=(0, 1, 0), boki=6)


def kultysta_tors(s, m):
    # szkaplerz i amulet z kości
    s.segment((0, 0.122, 1.44), (0, 0.118, 1.09), 0.150, 0.010, 0.170, 0.008, m["golen"], gora=(0, 1, 0))
    s.segment((0, -0.122, 1.44), (0, -0.112, 1.09), 0.150, 0.010, 0.170, 0.008, m["golen"], gora=(0, 1, 0))
    s.segment((0, 0.132, 1.330), (0, 0.134, 1.270), 0.030, 0.012, 0.012, 0.010, m["kosc"], gora=(0, 1, 0))
    s.pudlo((-0.022, 0.128, 1.300), (0.022, 0.138, 1.312), m["kosc"])


def kultysta_ramie(s, m, strona):
    # szeroki rękaw
    b, l = P.lustro(P.BARK, strona), P.lustro(P.LOKIEC, strona)
    s.rura([((b[0], b[1], b[2] - 0.05), 0.135, 0.150), ((l[0], l[1] - 0.01, l[2] + 0.01), 0.150, 0.185)], m["ubranie"])


def kultysta_dodatki(seg, m, lista):
    # kostur z żelazną kadzielnicą: żar w koszu, łańcuszki
    b = w.Siatka("bron", lista)
    cx, cy, cz = 0.236, 0.04, 0.805
    b.rura([((cx, cy, cz - 0.62), 0.030, 0.030), ((cx, cy, cz), 0.034, 0.034), ((cx, cy, cz + 0.95), 0.030, 0.030)], m["drewno"], boki=6)
    b.rura([((cx, cy, cz - 0.66), 0.020, 0.020), ((cx, cy, cz - 0.60), 0.036, 0.036)], m["zelazo"], boki=6)
    b.rura([((cx, cy, cz + 0.94), 0.040, 0.040), ((cx, cy, cz + 0.99), 0.110, 0.110), ((cx, cy, cz + 1.09), 0.125, 0.125), ((cx, cy, cz + 1.12), 0.100, 0.100)], m["zelazo"], boki=6)
    b.rura([((cx, cy, cz + 1.02), 0.085, 0.085), ((cx, cy, cz + 1.125), 0.085, 0.085)], m["zar"], boki=6)
    for kat in range(4):
        import math
        dx, dy = math.cos(kat * math.pi / 2 + 0.78) * 0.066, math.sin(kat * math.pi / 2 + 0.78) * 0.066
        b.pudlo((cx + dx - 0.005, cy + dy - 0.005, cz + 1.09), (cx + dx + 0.005, cy + dy + 0.005, cz + 1.21), m["zelazo"])
    b.rura([((cx, cy, cz + 1.20), 0.150, 0.150), ((cx, cy, cz + 1.225), 0.060, 0.060), ((cx, cy, cz + 1.30), 0.016, 0.016)], m["zelazo"], boki=6)
    seg["bron"] = b.obiekt(faza=0.001, gestosc=320, rodzic=seg["przedramie_p"], poczatek=(cx, cy, cz))


KULTYSTA = {"grubosc": 0.92, "helm_pelny": True, "glowa": kultysta_glowa, "miednica": kultysta_miednica, "tors": kultysta_tors,
            "ramie": kultysta_ramie, "dodatki": kultysta_dodatki}


# =================================================================== STRAŻ ZAKONU
def mat_zakon():
    t = w.tekstura
    kolczuga = w.material("kolczuga_z", t("kolczuga_z", ["#4a4d51", "#5a5d61", "#6a6d71", "#3c3d40"], skala=1.6, ziarno=71, drobny=0.8, progi=[0.3, 0.72, 0.95]), 0.5, 0.55)
    return {
        "skora": w.material("skora_zywa", t("skora_zywa", ["#8a6a55", "#977561", "#a4816c", "#7a5a48"], skala=6.0, ziarno=72, drobny=0.25, progi=[0.3, 0.7, 0.93]), 0.8),
        "ubranie": w.material("przeszywanica_z", t("przeszywanica_z", ["#4c4435", "#575040", "#625a49"], skala=3.0, ziarno=73, drobny=0.5), 1.0),
        "kolczuga": kolczuga,
        "noga": w.material("nogawice", t("nogawice", ["#2c2a27", "#35332f", "#3e3b37"], skala=4.0, ziarno=74, drobny=0.5), 1.0),
        "przedramie": w.material("skora_wyprawiona", t("skora_wyprawiona", ["#2c211a", "#372a20", "#423226"], skala=4.0, ziarno=44, drobny=0.4), 0.85),
        "but": w.material("but", t("but", ["#1c1815", "#231e1a", "#2b2520"], skala=4.0, ziarno=45, drobny=0.4), 0.9),
        "zelazo": w.material("stal_z", t("stal_z", ["#5a5c5f", "#686a6d", "#76787b", "#4c4640"], skala=5.0, ziarno=75, drobny=0.4, progi=[0.3, 0.7, 0.94]), 0.42, 0.7),
        "drewno": w.material("deska", t("deska", ["#33261a", "#402f20", "#4d3926"], skala=9.0, ziarno=47, drobny=0.2), 0.9),
        "plaszcz": w.material("plaszcz_z", t("plaszcz_z", ["#8d8778", "#9a9484", "#a7a190", "#746a5c"], skala=4.0, ziarno=76, drobny=0.35, progi=[0.3, 0.7, 0.92]), 1.0),
        "znak": w.material("znak_z", t("znak_z", ["#0f0e0d", "#151413", "#1b1a18"], skala=5.0, ziarno=77), 1.0),
        "ciemny": CIEMNY(),
    }


def zakon_jaka(s, m, znak=True):
    # jaka: jasna tunika bez rękawów z czarnym znakiem zakonu (pionowy klin przecięty belką)
    s.rura([((0, 0.004, 1.070), 0.292, 0.222), ((0, 0.010, 1.255), 0.348, 0.256), ((0, 0.012, 1.365), 0.384, 0.272), ((0, 0.004, 1.445), 0.330, 0.240)], m["plaszcz"])
    if znak:
        s.profil([(-0.016, 1.40), (0.016, 1.40), (0.028, 1.16), (0.0, 1.12), (-0.028, 1.16)], "y", 0.137, 0.1405, m["znak"])
        s.pudlo((-0.060, 0.137, 1.315), (0.060, 0.1405, 1.340), m["znak"])


def zakon_miednica(s, m):
    s.rura([((0, 0, 1.070), 0.302, 0.222), ((0, 0.002, 0.900), 0.345, 0.255), ((0, 0.004, 0.730), 0.372, 0.280)], m["plaszcz"])
    s.rura([((0, 0, 1.090), 0.306, 0.226), ((0, 0, 1.050), 0.306, 0.226)], m["przedramie"])
    s.pudlo((-0.024, 0.108, 1.050), (0.024, 0.120, 1.090), m["zelazo"])


def helm_lebka(s, m):
    # łebka z nosalem na czepcu kolczym
    s.rura([((0, 0.0, 1.470), 0.290, 0.225), ((0, 0.004, 1.560), 0.190, 0.200), ((0, 0.006, 1.640), 0.176, 0.212), ((0, 0.006, 1.720), 0.170, 0.212)], m["kolczuga"])
    s.rura([((0, 0.008, 1.712), 0.180, 0.222), ((0, 0.008, 1.770), 0.172, 0.212), ((0, 0.006, 1.812), 0.120, 0.150), ((0, 0.006, 1.828), 0.040, 0.050)], m["zelazo"])
    s.pudlo((-0.011, 0.108, 1.650), (0.011, 0.126, 1.722), m["zelazo"])
    # odsłonięta twarz
    s.rura([((0, 0.058, 1.588), 0.098, 0.090), ((0, 0.062, 1.650), 0.122, 0.092), ((0, 0.060, 1.708), 0.126, 0.088)], m["skora"], boki=6)
    for sx in (-1, 1):
        s.pudlo((sx * 0.022, 0.098, 1.684), (sx * 0.046, 0.1085, 1.700), m["ciemny"])
    s.pudlo((-0.026, 0.094, 1.612), (0.026, 0.1065, 1.620), m["ciemny"])


def wlocznik_tors(s, m):
    zakon_jaka(s, m)


def wlocznik_ramie(s, m, strona):
    b, l = P.lustro(P.BARK, strona), P.lustro(P.LOKIEC, strona)
    s.rura([((b[0], b[1], b[2] + 0.045), 0.132, 0.140), ((b[0] + strona * 0.006, 0, b[2] - 0.11), 0.136, 0.146), ((l[0], l[1], l[2] + 0.07), 0.118, 0.126)], m["kolczuga"])


def wlocznik_dodatki(seg, m, lista):
    # tarcza migdałowa z umbem i znakiem
    t = w.Siatka("tarcza", lista)
    x0 = -0.225
    t.profil([(-0.20, 1.40), (0.0, 1.44), (0.20, 1.40), (0.23, 1.20), (0.15, 0.86), (0.0, 0.62), (-0.15, 0.86), (-0.23, 1.20)], "y", 0.150, 0.170, m["plaszcz"])
    t.profil([(-0.022, 1.36), (0.022, 1.36), (0.034, 0.98), (0.0, 0.74), (-0.034, 0.98)], "y", 0.170, 0.174, m["znak"])
    t.pudlo((-0.11, 0.170, 1.19), (0.11, 0.174, 1.225), m["znak"])
    t.walec((0, 0.170, 1.12), (0, 0.205, 1.12), 0.058, m["zelazo"], n=8, r1=0.022)
    for p in t.bm.verts:
        p.co.x += x0
    seg["tarcza"] = t.obiekt(faza=0.002, gestosc=320, rodzic=seg["przedramie_l"], poczatek=(x0, 0.16, 1.10))
    # włócznia 2,2 m z liściastym grotem i tuleją
    b = w.Siatka("bron", lista)
    cx, cy, cz = 0.236, 0.04, 0.805
    b.rura([((cx, cy, cz - 0.75), 0.026, 0.026), ((cx, cy, cz), 0.032, 0.032), ((cx, cy, cz + 1.12), 0.028, 0.028)], m["drewno"], boki=6)
    b.rura([((cx, cy, cz + 1.10), 0.034, 0.034), ((cx, cy, cz + 1.22), 0.024, 0.024)], m["zelazo"], boki=6)
    b.profil([(cy - 0.008, cz + 1.22), (cy + 0.008, cz + 1.22), (cy + 0.034, cz + 1.30), (cy, cz + 1.50), (cy - 0.034, cz + 1.30)], "x", cx - 0.004, cx + 0.004, m["zelazo"])
    b.rura([((cx, cy, cz - 0.80), 0.014, 0.014), ((cx, cy, cz - 0.74), 0.030, 0.030)], m["zelazo"], boki=6)
    seg["bron"] = b.obiekt(faza=0.001, gestosc=320, rodzic=seg["przedramie_p"], poczatek=(cx, cy, cz))


WLOCZNIK = {"grubosc": 1.0, "helm_pelny": True, "glowa": helm_lebka, "tors": wlocznik_tors, "miednica": zakon_miednica,
            "ramie": wlocznik_ramie, "dodatki": wlocznik_dodatki}


def kusznik_glowa(s, m):
    # kaptur z pelerynką i odsłonięta twarz z brodą
    s.rura([((0, 0.0, 1.455), 0.340, 0.250), ((0, 0.002, 1.555), 0.200, 0.205), ((0, 0.002, 1.650), 0.176, 0.214),
            ((0, 0.000, 1.745), 0.172, 0.216), ((0, -0.006, 1.805), 0.126, 0.160), ((0, -0.03, 1.822), 0.04, 0.05)], m["noga"])
    s.rura([((0, 0.058, 1.575), 0.090, 0.092), ((0, 0.064, 1.650), 0.122, 0.094), ((0, 0.062, 1.722), 0.124, 0.088)], m["skora"], boki=6)
    s.segment((0, 0.100, 1.690), (0, 0.124, 1.648), 0.022, 0.016, 0.032, 0.020, m["skora"], gora=(0, 1, 0))
    for sx in (-1, 1):
        s.pudlo((sx * 0.022, 0.098, 1.692), (sx * 0.046, 0.1105, 1.706), m["ciemny"])
    s.rura([((0, 0.092, 1.630), 0.086, 0.030), ((0, 0.098, 1.560), 0.050, 0.030)], m["przedramie"], boki=6)      # broda


def kusznik_tors(s, m):
    zakon_jaka(s, m)
    # pas przez pierś i kołczan na bełty na plecach przy biodrze
    s.segment((0.14, 0.132, 1.43), (-0.15, 0.128, 1.10), 0.040, 0.008, 0.040, 0.008, m["przedramie"], gora=(0, 1, 0))
    s.segment((0.14, -0.128, 1.43), (-0.15, -0.126, 1.10), 0.040, 0.008, 0.040, 0.008, m["przedramie"], gora=(0, 1, 0))


def kusznik_miednica(s, m):
    zakon_miednica(s, m)
    s.rura([((-0.20, -0.06, 1.04), 0.085, 0.060), ((-0.215, -0.10, 0.76), 0.070, 0.050)], m["przedramie"], boki=6)
    for i in range(4):
        x = -0.222 + i * 0.014
        s.pudlo((x - 0.004, -0.058 + i * 0.004, 1.04), (x + 0.004, -0.050 + i * 0.004, 1.11), m["drewno"])
        s.pudlo((x - 0.008, -0.060 + i * 0.004, 1.085), (x + 0.008, -0.048 + i * 0.004, 1.115), m["plaszcz"])


def kusznik_dodatki(seg, m, lista):
    # kusza: łoże, łuczysko stalowe, strzemię, cięciwa, bełt; trzymana prawą ręką, lufą w dół w spoczynku
    b = w.Siatka("bron", lista)
    cx, cy, cz = 0.236, 0.04, 0.805
    # oś kuszy = oś Z węzła (w górę); w grze węzeł obracany do poziomu
    b.rura([((cx, cy, cz - 0.30), 0.040, 0.060), ((cx, cy, cz - 0.05), 0.044, 0.056), ((cx, cy, cz + 0.42), 0.040, 0.046)], m["drewno"], boki=6)
    b.segment((cx - 0.34, cy, cz + 0.33), (cx - 0.12, cy, cz + 0.40), 0.014, 0.030, 0.022, 0.036, m["zelazo"], gora=(0, 1, 0))
    b.segment((cx + 0.34, cy, cz + 0.33), (cx + 0.12, cy, cz + 0.40), 0.014, 0.030, 0.022, 0.036, m["zelazo"], gora=(0, 1, 0))
    b.pudlo((cx - 0.13, cy - 0.020, cz + 0.385), (cx + 0.13, cy + 0.020, cz + 0.415), m["zelazo"])
    b.segment((cx - 0.335, cy + 0.012, cz + 0.33), (cx, cy + 0.030, cz + 0.02), 0.005, 0.005, 0.005, 0.005, m["plaszcz"], gora=(0, 1, 0))
    b.segment((cx + 0.335, cy + 0.012, cz + 0.33), (cx, cy + 0.030, cz + 0.02), 0.005, 0.005, 0.005, 0.005, m["plaszcz"], gora=(0, 1, 0))
    b.rura([((cx, cy + 0.034, cz + 0.03), 0.012, 0.012), ((cx, cy + 0.034, cz + 0.44), 0.012, 0.012)], m["drewno"], boki=6)
    b.rura([((cx, cy + 0.034, cz + 0.44), 0.018, 0.018), ((cx, cy + 0.034, cz + 0.50), 0.004, 0.004)], m["zelazo"], boki=6)
    b.pudlo((cx - 0.035, cy - 0.006, cz + 0.42), (cx + 0.035, cy + 0.006, cz + 0.43), m["zelazo"])
    b.pudlo((cx - 0.035, cy - 0.006, cz + 0.42), (cx - 0.027, cy + 0.006, cz + 0.52), m["zelazo"])
    b.pudlo((cx + 0.027, cy - 0.006, cz + 0.42), (cx + 0.035, cy + 0.006, cz + 0.52), m["zelazo"])
    b.pudlo((cx - 0.035, cy - 0.006, cz + 0.51), (cx + 0.035, cy + 0.006, cz + 0.52), m["zelazo"])
    b.pudlo((cx - 0.006, cy - 0.060, cz - 0.16), (cx + 0.006, cy - 0.028, cz - 0.02), m["zelazo"])      # spust
    seg["bron"] = b.obiekt(faza=0.001, gestosc=320, rodzic=seg["przedramie_p"], poczatek=(cx, cy, cz))


KUSZNIK = {"grubosc": 0.96, "helm_pelny": True, "glowa": kusznik_glowa, "tors": kusznik_tors, "miednica": kusznik_miednica,
           "dodatki": kusznik_dodatki}


def mat_komtur():
    t = w.tekstura
    m = mat_zakon()
    plyta = w.material("plyta_z", t("plyta_z", ["#5f6265", "#6d7073", "#7b7e81", "#8c8f92", "#504a44"], skala=6.0, ziarno=81, drobny=0.3, progi=[0.25, 0.6, 0.86, 0.96]), 0.36, 0.8)
    plyta2 = w.material("plyta_z2", t("plyta_z2", ["#3f4144", "#4a4c4f", "#55575a"], skala=6.0, ziarno=82, drobny=0.3), 0.45, 0.75)
    m.update({"skora": plyta, "ubranie": plyta, "dlon": plyta2, "golen": plyta, "but": plyta2, "biodra": plyta2, "plyta2": plyta2, "noga": plyta,
              "szczelina": w.material("przeszywanica_c", t("przeszywanica_c", ["#16130f", "#1c1813", "#221d17"], skala=3.0, ziarno=53, drobny=0.5), 1.0),
              "barwa": m["plaszcz"], "przedramie": plyta,
              "rekojesc": w.material("rekojesc", t("rekojesc", ["#1d1611", "#261c15", "#2f231a"], skala=4.0, ziarno=56), 0.9)})
    return m


def komtur_glowa(s, m):
    P.rycerz_glowa(s, m)
    # grzebień z końskiego włosia w barwach zakonu
    s.profil([(-0.10, 1.836), (0.10, 1.836), (0.12, 1.93), (0.04, 1.965), (-0.09, 1.94), (-0.15, 1.87)], "x", -0.012, 0.012, m["znak"])


def komtur_tors(s, m):
    P.rycerz_tors(s, m)
    s.profil([(-0.014, 1.33), (0.014, 1.33), (0.024, 1.15), (0.0, 1.10), (-0.024, 1.15)], "y", 0.150, 0.153, m["znak"])
    s.pudlo((-0.050, 0.150, 1.265), (0.050, 0.153, 1.285), m["znak"])
    # płaszcz na plecach do łydek, spięty na obojczykach
    s.profil([(-0.21, 1.47), (0.21, 1.47), (0.27, 1.10), (0.31, 0.62), (0.26, 0.36), (0.0, 0.32), (-0.26, 0.36), (-0.31, 0.62), (-0.27, 1.10)], "y", -0.150, -0.128, m["plaszcz"])
    for sx in (-1, 1):
        s.segment((sx * 0.21, -0.13, 1.47), (sx * 0.10, 0.10, 1.45), 0.05, 0.014, 0.04, 0.012, m["plaszcz"], gora=(0, 0, 1))


KOMTUR = dict(P.RYCERZ)
KOMTUR.update({"glowa": komtur_glowa, "tors": komtur_tors})


# =================================================================== TROLL JASKINIOWY
def mat_troll():
    t = w.tekstura
    skora = w.material("troll_skora", t("troll_skora", ["#3d4038", "#484b42", "#54574c", "#33302b", "#5f6256"], skala=4.5, ziarno=91, drobny=0.45, progi=[0.22, 0.58, 0.84, 0.95]), 0.95)
    return {
        "skora": skora, "ubranie": skora,
        "biodra": w.material("skora_futro", t("skora_futro", ["#2a221a", "#342a20", "#3e3226"], skala=5.0, ziarno=92, drobny=0.7), 1.0),
        "kamien": w.material("narosl", t("narosl", ["#2b2d2c", "#343635", "#3e403f", "#494b4a"], skala=6.0, ziarno=93, drobny=0.5, progi=[0.3, 0.68, 0.92]), 1.0),
        "kosc": w.material("kiel", t("kiel", ["#7a725c", "#888066", "#968d70"], skala=5.0, ziarno=94, drobny=0.3), 0.7),
        "ciemny": CIEMNY(),
        "oko": w.material("oko_trolla", t("oko_trolla", ["#8a6a1c", "#a88422"], skala=4.0, ziarno=95), 0.4),
    }


def troll_glowa(s, m):
    # niska, szeroka czaszka wysunięta do przodu, gruby wał brwiowy, masywna żuchwa z kłami
    k = m["skora"]
    s.rura([((0, 0.000, 1.470), 0.230, 0.230), ((0, 0.030, 1.550), 0.215, 0.225)], k)
    s.rura([((0, 0.060, 1.530), 0.210, 0.210), ((0, 0.070, 1.590), 0.262, 0.290), ((0, 0.066, 1.670), 0.258, 0.300),
            ((0, 0.050, 1.735), 0.230, 0.270), ((0, 0.030, 1.770), 0.150, 0.180)], k)
    s.segment((0, 0.205, 1.700), (0, 0.222, 1.672), 0.235, 0.050, 0.220, 0.036, m["kamien"], gora=(0, 1, 0), boki=6)       # wał brwiowy
    s.segment((0, 0.215, 1.672), (0, 0.250, 1.612), 0.050, 0.040, 0.082, 0.046, k, gora=(0, 1, 0), boki=6)                   # nos
    for sx in (-1, 1):
        s.pudlo((sx * 0.040, 0.196, 1.652), (sx * 0.082, 0.2135, 1.672), m["ciemny"])
        s.pudlo((sx * 0.052, 0.208, 1.656), (sx * 0.068, 0.2165, 1.668), m["oko"])
        s.segment((sx * 0.130, 0.05, 1.640), (sx * 0.175, 0.02, 1.700), 0.020, 0.060, 0.010, 0.030, k, gora=(0, 1, 0))      # uszy
        s.segment((sx * 0.062, 0.228, 1.568), (sx * 0.074, 0.240, 1.640), 0.028, 0.028, 0.008, 0.008, m["kosc"], gora=(0, 1, 0), boki=6)   # kły
    s.rura([((0, 0.120, 1.520), 0.200, 0.200), ((0, 0.135, 1.572), 0.236, 0.230)], k)                                         # żuchwa
    s.pudlo((-0.080, 0.215, 1.574), (0.080, 0.2525, 1.590), m["ciemny"])
    for i in range(3):                                                                                                       # kamienne narośla na ciemieniu
        s.segment((-0.07 + i * 0.07, 0.03 - i * 0.02, 1.74), (-0.08 + i * 0.08, 0.01, 1.80 + (i % 2) * 0.03), 0.07, 0.07, 0.02, 0.02, m["kamien"], gora=(0, 1, 0), boki=6)


def troll_tors(s, m):
    k = m["skora"]
    # garb i kark, ciężki brzuch, kamienne płyty na grzbiecie
    s.rura([((0, -0.100, 1.300), 0.300, 0.160), ((0, -0.135, 1.420), 0.360, 0.200), ((0, -0.090, 1.520), 0.250, 0.180)], k)
    s.rura([((0, 0.085, 1.080), 0.300, 0.150), ((0, 0.120, 1.180), 0.330, 0.180), ((0, 0.095, 1.290), 0.300, 0.140)], k)
    for i, (x, z, r) in enumerate([(-0.11, 1.44, 0.13), (0.10, 1.40, 0.15), (0.0, 1.29, 0.12), (-0.13, 1.22, 0.10), (0.14, 1.20, 0.09)]):
        s.segment((x, -0.19, z), (x * 1.1, -0.255, z + 0.02), r, r * 0.9, r * 0.45, r * 0.4, m["kamien"], gora=(0, 0, 1), boki=6)


def troll_miednica(s, m):
    s.segment((0, 0.150, 1.04), (0, 0.165, 0.66), 0.300, 0.016, 0.200, 0.010, m["biodra"], gora=(0, 1, 0))
    s.segment((0, -0.150, 1.04), (0, -0.160, 0.70), 0.320, 0.016, 0.240, 0.010, m["biodra"], gora=(0, 1, 0))
    s.rura([((0, 0, 1.085), 0.420, 0.300), ((0, 0, 1.035), 0.430, 0.310)], m["biodra"])


def troll_ramie(s, m, strona):
    b = P.lustro(P.BARK, strona)
    s.segment((b[0] + strona * 0.02, -0.01, b[2] + 0.07), (b[0] + strona * 0.075, -0.02, b[2] + 0.10), 0.13, 0.14, 0.05, 0.06, m["kamien"], gora=(0, 1, 0), boki=6)


def troll_dlon(s, m, strona, nadg, kon):
    # tępe pazury
    for i in range(4):
        y = kon[1] - 0.045 + i * 0.022
        s.segment((kon[0] - strona * 0.014, y, kon[2] + 0.02), (kon[0] - strona * 0.028, y + 0.006, kon[2] - 0.022), 0.018, 0.018, 0.008, 0.008, m["kosc"], gora=(0, 1, 0))


TROLL = {"grubosc": 1.34, "przedramie": 0.10, "talia": 0.40, "helm_pelny": True, "glowa": troll_glowa, "tors": troll_tors,
         "miednica": troll_miednica, "ramie": troll_ramie, "przedramie_el": troll_dlon}


# =================================================================== WARG
def warg():
    """Czworonóg: 0,95 m w kłębie, 1,75 m długości. Patrzy w +Y.
    tulow > (szyja > glowa > zuchwa, ogon, lapa_pl > lapa_pl2, lapa_pp > …, lapa_tl > lapa_tl2, lapa_tp > …)"""
    w.reset()
    t = w.tekstura
    m = {
        "siersc": w.material("warg_siersc", t("warg_siersc", ["#2a2725", "#34302d", "#3e3935", "#48423c", "#201d1b"], skala=5.0, ziarno=101, drobny=0.7, progi=[0.2, 0.55, 0.82, 0.95]), 1.0),
        "spod": w.material("warg_spod", t("warg_spod", ["#35302b", "#3f3933", "#49423b"], skala=5.0, ziarno=102, drobny=0.7), 1.0),
        "kosc": w.material("kiel", t("kiel", ["#7a725c", "#888066", "#968d70"], skala=5.0, ziarno=94, drobny=0.3), 0.7),
        "ciemny": CIEMNY(),
        "oko": w.material("oko_warga", t("oko_warga", ["#b08a20", "#c89c26"], skala=4.0, ziarno=103), 0.3),
        "pysk": w.material("warg_pysk", t("warg_pysk", ["#120f0e", "#191514", "#3a1512"], skala=5.0, ziarno=104, drobny=0.4), 0.7),
    }
    lista = list(m.values())
    korzen = w.pusty("warg", (0, 0, 0))
    seg = {}
    X = (1, 0, 0)
    BIODRA, LOPATKI = (0, -0.50, 0.86), (0, 0.38, 0.93)
    s = w.Siatka("tulow", lista)
    # zad, lędźwie (wcięcie), klatka głęboka, kłąb z garbem sierści
    s.rura([((0, -0.72, 0.84), 0.150, 0.200), ((0, -0.58, 0.83), 0.300, 0.380), ((0, -0.36, 0.82), 0.310, 0.370), ((0, -0.12, 0.80), 0.290, 0.350),
            ((0, 0.12, 0.76), 0.350, 0.470), ((0, 0.36, 0.76), 0.380, 0.520), ((0, 0.55, 0.80), 0.330, 0.430), ((0, 0.66, 0.84), 0.220, 0.300)], m["siersc"], gora=(0, 0, 1))
    s.rura([((0, -0.10, 0.655), 0.200, 0.060), ((0, 0.20, 0.560), 0.260, 0.080), ((0, 0.50, 0.620), 0.230, 0.070)], m["spod"], gora=(0, 0, 1), boki=6)
    for i in range(6):                                                                    # zjeżona sierść na grzbiecie
        y = 0.56 - i * 0.14
        s.segment((0, y, 0.975 - i * 0.012), (0, y - 0.11, 1.030 - i * 0.016), 0.150, 0.100, 0.040, 0.020, m["siersc"], gora=(0, 1, 0), boki=4)
    seg["tulow"] = s.obiekt(faza=0.003, gestosc=320, rodzic=korzen, poczatek=(0, 0, 0.82))
    # szyja
    SZ = (0, 0.60, 0.88)
    s = w.Siatka("szyja", lista)
    s.rura([((0, 0.56, 0.84), 0.250, 0.330), ((0, 0.76, 0.96), 0.210, 0.270), ((0, 0.92, 1.06), 0.180, 0.210)], m["siersc"], gora=(0, 0, 1))
    for i in range(3):
        s.segment((0, 0.66 + i * 0.09, 1.05 + i * 0.05), (0, 0.58 + i * 0.09, 1.11 + i * 0.05), 0.130, 0.080, 0.030, 0.016, m["siersc"], gora=(0, 1, 0), boki=4)
    seg["szyja"] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["tulow"], poczatek=SZ)
    # głowa: szeroka czaszka, długi pysk, uszy, oczy
    GL = (0, 0.90, 1.05)
    s = w.Siatka("glowa", lista)
    s.rura([((0, 0.86, 1.06), 0.190, 0.200), ((0, 0.98, 1.08), 0.215, 0.200), ((0, 1.08, 1.06), 0.170, 0.150), ((0, 1.20, 1.045), 0.110, 0.095), ((0, 1.31, 1.035), 0.085, 0.070)], m["siersc"], gora=(0, 0, 1))
    s.rura([((0, 1.295, 1.050), 0.060, 0.045), ((0, 1.325, 1.044), 0.050, 0.036)], m["pysk"], gora=(0, 0, 1), boki=6)             # nos
    for sx in (-1, 1):
        s.segment((sx * 0.075, 0.94, 1.16), (sx * 0.100, 0.90, 1.27), 0.070, 0.030, 0.012, 0.010, m["siersc"], gora=(0, 1, 0), boki=4)   # uszy
        s.pudlo((sx * 0.062, 1.058, 1.098), (sx * 0.088, 1.084, 1.114), m["oko"])
        for i in range(3):                                                                # górne zęby
            s.segment((sx * (0.034 + (2 - i) * 0.004), 1.16 + i * 0.045, 1.005), (sx * (0.034 + (2 - i) * 0.004), 1.165 + i * 0.045, 0.975 - (0.022 if i == 2 else 0)), 0.014, 0.014, 0.003, 0.003, m["kosc"], gora=(0, 1, 0))
    seg["glowa"] = s.obiekt(faza=0.002, gestosc=320, rodzic=seg["szyja"], poczatek=GL)
    ZU = (0, 1.02, 1.00)
    s = w.Siatka("zuchwa", lista)
    s.rura([((0, 1.00, 0.985), 0.150, 0.060), ((0, 1.16, 0.975), 0.090, 0.045), ((0, 1.29, 0.975), 0.064, 0.034)], m["siersc"], gora=(0, 0, 1), boki=6)
    s.pudlo((-0.036, 1.06, 0.992), (0.036, 1.27, 1.0005), m["pysk"])
    for sx in (-1, 1):
        s.segment((sx * 0.028, 1.265, 0.99), (sx * 0.028, 1.262, 1.03), 0.013, 0.013, 0.003, 0.003, m["kosc"], gora=(0, 1, 0))
    seg["zuchwa"] = s.obiekt(faza=0.002, gestosc=320, rodzic=seg["glowa"], poczatek=ZU)
    # ogon
    s = w.Siatka("ogon", lista)
    s.rura([((0, -0.70, 0.86), 0.090, 0.090), ((0, -0.86, 0.76), 0.105, 0.105), ((0, -1.00, 0.60), 0.085, 0.085), ((0, -1.08, 0.44), 0.030, 0.030)], m["siersc"], gora=(0, 1, 0), boki=6)
    seg["ogon"] = s.obiekt(faza=0.002, gestosc=320, rodzic=seg["tulow"], poczatek=(0, -0.70, 0.86))
    # łapy: przednie (łopatka-łokieć-nadgarstek-palce), tylne (udo-kolano-staw skokowy-palce)
    for strona, lit in ((1, "p"), (-1, "l")):
        x = strona * 0.150
        bark, lok = (x, 0.42, 0.80), (x, 0.36, 0.46)
        s = w.Siatka("lapa_p" + lit, lista)
        s.rura([((x * 0.9, 0.44, 0.90), 0.120, 0.230), ((x, 0.41, 0.70), 0.130, 0.210), ((x, 0.37, 0.50), 0.105, 0.140), (lok, 0.098, 0.120)], m["siersc"])
        seg["lapa_p" + lit] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["tulow"], poczatek=bark)
        s = w.Siatka("lapa_p" + lit + "2", lista)
        s.rura([((x, 0.36, 0.48), 0.098, 0.120), ((x, 0.375, 0.28), 0.084, 0.100), ((x, 0.385, 0.060), 0.080, 0.092)], m["siersc"])
        s.rura([((x, 0.34, 0.045), 0.110, 0.090), ((x, 0.47, 0.038), 0.124, 0.070), ((x, 0.53, 0.026), 0.100, 0.046)], m["siersc"], gora=(0, 0, 1), boki=6)
        for i in range(3):
            s.segment((x + (i - 1) * 0.028, 0.515, 0.026), (x + (i - 1) * 0.032, 0.560, 0.006), 0.014, 0.014, 0.004, 0.004, m["kosc"], gora=(0, 0, 1))
        seg["lapa_p" + lit + "2"] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["lapa_p" + lit], poczatek=lok)
        x = strona * 0.135
        bio, kol, skok = (x, -0.50, 0.80), (x, -0.40, 0.50), (x, -0.62, 0.27)
        s = w.Siatka("lapa_t" + lit, lista)
        s.rura([((x * 0.9, -0.52, 0.90), 0.125, 0.270), ((x, -0.47, 0.70), 0.140, 0.270), ((x, -0.42, 0.54), 0.115, 0.180), (kol, 0.105, 0.140)], m["siersc"])
        seg["lapa_t" + lit] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["tulow"], poczatek=bio)
        s = w.Siatka("lapa_t" + lit + "2", lista)
        s.rura([((x, -0.39, 0.52), 0.105, 0.140), ((x, -0.52, 0.38), 0.090, 0.120), (skok, 0.078, 0.092)], m["siersc"])
        s.rura([((x, -0.62, 0.29), 0.078, 0.090), ((x, -0.585, 0.060), 0.074, 0.084)], m["siersc"])
        s.rura([((x, -0.63, 0.045), 0.106, 0.090), ((x, -0.50, 0.038), 0.120, 0.070), ((x, -0.44, 0.026), 0.096, 0.046)], m["siersc"], gora=(0, 0, 1), boki=6)
        for i in range(3):
            s.segment((x + (i - 1) * 0.027, -0.46, 0.026), (x + (i - 1) * 0.031, -0.415, 0.006), 0.014, 0.014, 0.004, 0.004, m["kosc"], gora=(0, 0, 1))
        seg["lapa_t" + lit + "2"] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["lapa_t" + lit], poczatek=kol)
    w.eksport("warg")


if __name__ == "__main__":
    ktore = sys.argv[1:] or ["kultysta", "wlocznik", "kusznik", "komtur", "troll", "warg"]
    if "kultysta" in ktore:
        P.buduj("kultysta", mat_kultysta, KULTYSTA)
    if "wlocznik" in ktore:
        P.buduj("wlocznik", mat_zakon, WLOCZNIK)
    if "kusznik" in ktore:
        P.buduj("kusznik", mat_zakon, KUSZNIK)
    if "komtur" in ktore:
        P.buduj("komtur", mat_komtur, KOMTUR)
    if "troll" in ktore:
        P.buduj("troll", mat_troll, TROLL)
    if "warg" in ktore:
        warg()
