"""Postacie człekokształtne ze sztywnych segmentów. Uruchom: python3 postacie.py
Wzrost 1,80 m, proporcje 7,5 głowy. Postać patrzy w stronę +Y, prawa strona to +X.
Każdy segment ma początek w swoim stawie, więc animacja to obroty węzłów.
Hierarchia: korzen > miednica > tors > (glowa, ramie_x > przedramie_x), miednica > udo_x > golen_x."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wspolne as w

# stawy (prawa strona; lewa to odbicie w X)
BIODRO = (0.092, 0.0, 0.94)
KOLANO = (0.097, 0.005, 0.50)
KOSTKA = (0.097, -0.005, 0.085)
BARK = (0.205, 0.0, 1.43)
LOKIEC = (0.228, -0.005, 1.14)
NADGARSTEK = (0.236, 0.02, 0.875)
PAS = (0.0, 0.0, 1.06)
SZYJA = (0.0, 0.005, 1.50)
MIEDNICA = (0.0, 0.0, 0.98)


def lustro(p, strona):
    return (p[0] * strona, p[1], p[2])


def rura(s, pierscienie, m, boki=8, gora=(0, 1, 0)):
    """Łańcuch segmentów przez kolejne przekroje (punkt, szerokość, głębokość)."""
    s.rura(pierscienie, m, gora=gora, boki=boki)


def miedzy(a, b, t, dy=0.0):
    return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t + dy, a[2] + (b[2] - a[2]) * t)


def buduj(nazwa, m, cechy):
    """m: słownik materiałów; cechy: funkcje dokładające elementy wariantu.
    Segmenty: miednica > tors > (glowa, ramie > przedramie > dlon), miednica > udo > golen > stopa."""
    w.reset()
    mat = m()
    lista = list(mat.values())
    korzen = w.pusty(nazwa, (0, 0, 0))
    g = cechy.get("grubosc", 1.0)        # mnożnik grubości kończyn
    dl_przedr = cechy.get("przedramie", 0.0)
    skora, ubranie = mat["skora"], mat["ubranie"]
    c_tors = mat.get("tors", ubranie)
    c_reka = mat.get("reka", ubranie)
    c_noga = mat.get("noga", ubranie)
    c_dlon = mat.get("dlon", skora)
    seg = {}

    # miednica: szersza w biodrach, zwężona ku talii, z zarysem pośladków
    s = w.Siatka("miednica", lista)
    cb = mat.get("biodra", ubranie)
    rura(s, [((0, -0.004, 0.885), 0.250 * g, 0.170 * g), ((0, -0.008, 0.945), 0.325 * g, 0.225 * g),
             ((0, -0.004, 1.010), 0.315 * g, 0.215 * g), ((0, 0, 1.068), 0.285 * g, 0.200 * g)], cb)
    cechy.get("miednica", lambda *_: None)(s, mat)
    seg["miednica"] = s.obiekt(faza=0.003, gestosc=320, rodzic=korzen, poczatek=MIEDNICA)

    # tors: talia, żebra, klatka, obręcz barkowa, kaptur do szyi
    s = w.Siatka("tors", lista)
    talia = cechy.get("talia", 0.275)
    rura(s, [((0, 0, 1.050), talia, 0.195 * g), ((0, 0.002, 1.150), talia * 1.08, 0.205 * g),
             ((0, 0.008, 1.255), 0.335 * g, 0.240 * g), ((0, 0.010, 1.365), 0.372 * g, 0.258 * g),
             ((0, 0.002, 1.440), 0.368 * g, 0.235 * g), ((0, -0.004, 1.478), 0.300 * g, 0.190 * g),
             ((0, 0.000, 1.518), 0.125, 0.120)], c_tors)
    cechy.get("tors", lambda *_: None)(s, mat)
    seg["tors"] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["miednica"], poczatek=PAS)

    # głowa
    s = w.Siatka("glowa", lista)
    if not cechy.get("helm_pelny", False):
        rura(s, [((0, 0.000, 1.490), 0.108, 0.112), ((0, 0.008, 1.565), 0.100, 0.108)], skora, boki=8)                   # szyja
        rura(s, [((0, 0.030, 1.548), 0.085, 0.120), ((0, 0.022, 1.585), 0.128, 0.165), ((0, 0.022, 1.645), 0.150, 0.186),
                 ((0, 0.014, 1.705), 0.154, 0.198), ((0, 0.008, 1.760), 0.150, 0.192), ((0, 0.004, 1.800), 0.108, 0.140)], skora)
        s.segment((0, 0.104, 1.722), (0, 0.108, 1.700), 0.118, 0.014, 0.110, 0.012, skora, gora=(0, 1, 0))           # łuk brwiowy
        s.segment((0, 0.108, 1.705), (0, 0.128, 1.655), 0.022, 0.016, 0.034, 0.020, skora, gora=(0, 1, 0))           # nos
        for sx in (-1, 1):
            s.pudlo((sx * 0.020, 0.085, 1.690), (sx * 0.046, 0.1035, 1.708), mat["ciemny"])                           # oczodoły
            s.segment((sx * 0.077, 0.018, 1.665), (sx * 0.082, 0.010, 1.712), 0.012, 0.030, 0.010, 0.034, skora, gora=(0, 1, 0))   # uszy
    cechy.get("glowa", lambda *_: None)(s, mat)
    seg["glowa"] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["tors"], poczatek=SZYJA)

    for strona, lit in ((1, "p"), (-1, "l")):
        bark, lokiec = lustro(BARK, strona), lustro(LOKIEC, strona)
        nadg = lustro(NADGARSTEK, strona)
        nadg = (nadg[0], nadg[1] + dl_przedr * 0.1, nadg[2] - dl_przedr)
        # ramię: mięsień naramienny, dwugłowy, zwężenie do łokcia
        s = w.Siatka("ramie_" + lit, lista)
        s.segment((strona * 0.150, 0.0, 1.455), (bark[0] + strona * 0.030, 0.0, 1.420), 0.128 * g, 0.122 * g, 0.122 * g, 0.112 * g, c_reka, gora=(0, 1, 0), boki=8)
        rura(s, [((bark[0], bark[1], bark[2] + 0.040), 0.124 * g, 0.132 * g), (miedzy(bark, lokiec, 0.38, 0.006), 0.122 * g, 0.134 * g),
                 (miedzy(bark, lokiec, 0.80), 0.102 * g, 0.110 * g), (lokiec, 0.096 * g, 0.102 * g)], c_reka)
        cechy.get("ramie", lambda *_: None)(s, mat, strona)
        seg["ramie_" + lit] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["tors"], poczatek=bark)
        # przedramię: brzusiec pod łokciem, wąski nadgarstek
        s = w.Siatka("przedramie_" + lit, lista)
        c_prz = mat.get("przedramie", c_reka)
        rura(s, [((lokiec[0], lokiec[1], lokiec[2] + 0.022), 0.096 * g, 0.102 * g), (miedzy(lokiec, nadg, 0.28, 0.004), 0.102 * g, 0.110 * g),
                 (miedzy(lokiec, nadg, 0.70), 0.082 * g, 0.086 * g), (nadg, 0.064 * g, 0.068 * g)], c_prz)
        ob = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["ramie_" + lit], poczatek=lokiec)
        seg["przedramie_" + lit] = ob
        # dłoń: śródręcze, lekko zgięte palce, kciuk
        s = w.Siatka("dlon_" + lit, lista)
        knykcie = (nadg[0] + strona * 0.003, nadg[1] + 0.010, nadg[2] - 0.092)
        dlon_kon = (nadg[0] + strona * 0.002, nadg[1] + 0.034, nadg[2] - 0.170)
        s.segment(nadg, knykcie, 0.034, 0.066, 0.030, 0.086, c_dlon, gora=(0, 1, 0))
        for i in range(4):
            y = -0.031 + i * 0.0205
            dlg = (0.070, 0.080, 0.076, 0.060)[i]
            p0 = (knykcie[0], knykcie[1] + y, knykcie[2])
            p1 = (knykcie[0] - strona * 0.004, knykcie[1] + y + 0.004, knykcie[2] - dlg * 0.55)
            p2 = (knykcie[0] - strona * 0.016, knykcie[1] + y + 0.006, knykcie[2] - dlg)
            s.segment(p0, p1, 0.019, 0.0185, 0.017, 0.017, c_dlon, gora=(0, 1, 0))
            s.segment(p1, p2, 0.017, 0.017, 0.014, 0.014, c_dlon, gora=(0, 1, 0))
        s.segment((nadg[0] - strona * 0.010, nadg[1] + 0.034, nadg[2] - 0.022), (nadg[0] - strona * 0.020, nadg[1] + 0.058, nadg[2] - 0.062), 0.024, 0.026, 0.020, 0.021, c_dlon, gora=(0, 1, 0))
        s.segment((nadg[0] - strona * 0.020, nadg[1] + 0.058, nadg[2] - 0.062), (nadg[0] - strona * 0.024, nadg[1] + 0.066, nadg[2] - 0.100), 0.019, 0.020, 0.015, 0.016, c_dlon, gora=(0, 1, 0))
        cechy.get("przedramie_el", lambda *_: None)(s, mat, strona, nadg, dlon_kon)
        seg["dlon_" + lit] = s.obiekt(faza=0.002, gestosc=320, rodzic=ob, poczatek=nadg)
        w.pusty("chwyt_" + lit, (nadg[0], nadg[1] + 0.02, nadg[2] - 0.07), seg["dlon_" + lit])

        biodro, kolano, kostka = lustro(BIODRO, strona), lustro(KOLANO, strona), lustro(KOSTKA, strona)
        # udo: masa z przodu i z boku, zwężenie nad kolanem, rzepka
        s = w.Siatka("udo_" + lit, lista)
        rura(s, [((biodro[0], biodro[1], biodro[2] + 0.030), 0.186 * g, 0.200 * g), (miedzy(biodro, kolano, 0.30, 0.008), 0.188 * g, 0.206 * g),
                 (miedzy(biodro, kolano, 0.78, 0.004), 0.146 * g, 0.156 * g), (kolano, 0.128 * g, 0.136 * g)], c_noga)
        s.segment((kolano[0], kolano[1] + 0.050 * g, kolano[2] + 0.030), (kolano[0], kolano[1] + 0.054 * g, kolano[2] - 0.020), 0.070 * g, 0.030, 0.062 * g, 0.026, c_noga, gora=(0, 1, 0), boki=6)
        cechy.get("udo", lambda *_: None)(s, mat, strona)
        seg["udo_" + lit] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["miednica"], poczatek=biodro)
        # goleń: łydka wysunięta do tyłu, wąska kostka
        s = w.Siatka("golen_" + lit, lista)
        c_gol = mat.get("golen", c_noga)
        rura(s, [((kolano[0], kolano[1], kolano[2] + 0.022), 0.124 * g, 0.132 * g), (miedzy(kolano, kostka, 0.28, -0.016), 0.130 * g, 0.148 * g),
                 (miedzy(kolano, kostka, 0.72, -0.004), 0.096 * g, 0.106 * g), ((kostka[0], kostka[1], kostka[2] + 0.010), 0.082 * g, 0.092 * g)], c_gol)
        cechy.get("golen_el", lambda *_: None)(s, mat, strona, kolano, kostka)
        seg["golen_" + lit] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["udo_" + lit], poczatek=kolano)
        # stopa: pięta, podbicie, palce
        s = w.Siatka("stopa_" + lit, lista)
        but = mat.get("but", c_gol)
        s.profil([(-0.072, 0.0), (0.150, 0.0), (0.182, 0.010), (0.176, 0.034), (0.090, 0.066), (0.040, 0.094), (-0.050, 0.098), (-0.082, 0.046)], "x", kostka[0] - 0.050, kostka[0] + 0.050, but)
        s.pudlo((kostka[0] - 0.053, -0.078, 0.0), (kostka[0] + 0.053, 0.180, 0.012), mat.get("podeszwa", but))
        seg["stopa_" + lit] = s.obiekt(faza=0.003, gestosc=320, rodzic=seg["golen_" + lit], poczatek=kostka)

    cechy.get("dodatki", lambda *_: None)(seg, mat, lista)
    w.eksport(nazwa)


# =================================================================== GHUL
def mat_ghul():
    t = w.tekstura
    return {
        "skora": w.material("ghul_skora", t("ghul_skora", ["#3c4039", "#454940", "#4e5147", "#57584d", "#3b3032"], skala=7.0, ziarno=31, drobny=0.3, progi=[0.2, 0.5, 0.78, 0.94]), 0.85),
        "ubranie": w.material("ghul_skora2", t("ghul_skora2", ["#383c35", "#41453d", "#494d44", "#352d2e"], skala=6.0, ziarno=32, drobny=0.3, progi=[0.3, 0.7, 0.92]), 0.85),
        "biodra": w.material("lachman", t("lachman", ["#1f1b18", "#29231e", "#332b24"], skala=4.0, ziarno=33, drobny=0.5), 1.0),
        "ciemny": w.material("ciemny", t("ciemny", ["#040404", "#070707"], ziarno=5), 1.0),
        "krew": w.material("krew_stara", t("krew_stara", ["#2a0b0a", "#3a0f0d", "#4a1410"], skala=4.0, ziarno=34, drobny=0.5), 0.6),
        "kosc": w.material("pazur", t("pazur", ["#2b2822", "#3a352c", "#4a4438"], skala=4.0, ziarno=35), 0.6),
    }


def ghul_tors(s, m):
    # żebra i kręgosłup: wychudzone ciało
    for i in range(4):
        z = 1.27 + i * 0.045
        for sx in (-1, 1):
            s.segment((sx * 0.028, 0.098, z), (sx * 0.105, 0.078, z - 0.018), 0.014, 0.010, 0.012, 0.008, m["ubranie"], gora=(0, 0, 1))
    for i in range(6):
        s.pudlo((-0.012, -0.108, 1.10 + i * 0.058), (0.012, -0.088, 1.135 + i * 0.058), m["ubranie"])
    s.pudlo((-0.06, 0.080, 1.40), (0.04, 0.101, 1.455), m["krew"])


def ghul_glowa(s, m):
    s.pudlo((-0.046, 0.060, 1.578), (0.046, 0.0995, 1.622), m["ciemny"])          # rozwarta paszcza
    for i in range(5):
        x = -0.040 + i * 0.020
        s.segment((x, 0.097, 1.622), (x, 0.099, 1.606), 0.010, 0.008, 0.003, 0.003, m["kosc"], gora=(0, 1, 0))
        s.segment((x + 0.008, 0.094, 1.578), (x + 0.008, 0.096, 1.592), 0.010, 0.008, 0.003, 0.003, m["kosc"], gora=(0, 1, 0))
    s.pudlo((-0.050, 0.070, 1.562), (0.050, 0.0945, 1.578), m["krew"])
    for sx in (-1, 1):                                                            # szczątkowe uszy
        s.segment((sx * 0.076, 0.01, 1.69), (sx * 0.098, -0.01, 1.73), 0.012, 0.030, 0.006, 0.014, m["skora"], gora=(0, 1, 0))


def ghul_dlon(s, m, strona, nadg, kon):
    for i in range(3):                                                            # szpony
        y = kon[1] - 0.028 + i * 0.028
        s.segment((kon[0] - strona * 0.012, y, kon[2] + 0.012), (kon[0] - strona * 0.030, y + 0.010, kon[2] - 0.050), 0.014, 0.014, 0.004, 0.004, m["kosc"], gora=(0, 1, 0))
    s.pudlo((nadg[0] - 0.024, nadg[1] - 0.03, nadg[2] - 0.06), (nadg[0] + 0.024, nadg[1] + 0.05, nadg[2] - 0.02), m["krew"])


def ghul_miednica(s, m):
    s.segment((0, 0.095, 1.03), (0, 0.105, 0.74), 0.20, 0.012, 0.13, 0.008, m["biodra"], gora=(0, 1, 0))
    s.segment((0, -0.095, 1.03), (0, -0.100, 0.80), 0.22, 0.012, 0.16, 0.008, m["biodra"], gora=(0, 1, 0))


GHUL = {"grubosc": 0.80, "przedramie": 0.07, "talia": 0.205, "tors": ghul_tors, "glowa": ghul_glowa,
        "przedramie_el": ghul_dlon, "miednica": ghul_miednica}


# =================================================================== UMARŁY KNECHT
def mat_knecht():
    t = w.tekstura
    kolczuga = w.material("kolczuga", t("kolczuga", ["#34363a", "#44474b", "#55585c", "#2a2420"], skala=1.6, ziarno=41, drobny=0.8, progi=[0.3, 0.72, 0.95]), 0.55, 0.5)
    return {
        "skora": w.material("trup_skora", t("trup_skora", ["#5d5546", "#6a614f", "#776d58", "#4c4035"], skala=6.0, ziarno=42, drobny=0.3, progi=[0.3, 0.68, 0.92]), 0.9),
        "ubranie": w.material("przeszywanica", t("przeszywanica", ["#2f2a22", "#383228", "#423a2e"], skala=3.0, ziarno=43, drobny=0.5), 1.0),
        "tors": kolczuga, "reka": kolczuga, "biodra": kolczuga,
        "przedramie": w.material("skora_wyprawiona", t("skora_wyprawiona", ["#2c211a", "#372a20", "#423226"], skala=4.0, ziarno=44, drobny=0.4), 0.85),
        "but": w.material("but", t("but", ["#1c1815", "#231e1a", "#2b2520"], skala=4.0, ziarno=45, drobny=0.4), 0.9),
        "zelazo": w.material("zelazo", t("zelazo", ["#3b3c3d", "#47484a", "#545556", "#4a3526"], skala=5.0, ziarno=46, drobny=0.4, progi=[0.3, 0.7, 0.93]), 0.5, 0.6),
        "drewno": w.material("deska", t("deska", ["#33261a", "#402f20", "#4d3926"], skala=9.0, ziarno=47, drobny=0.2), 0.9),
        "barwa": w.material("barwa", t("barwa", ["#3a1512", "#471a16", "#55201a", "#2a211c"], skala=5.0, ziarno=48, drobny=0.3, progi=[0.3, 0.7, 0.92]), 0.95),
        "ciemny": w.material("ciemny", t("ciemny", ["#040404", "#070707"], ziarno=5), 1.0),
    }


def knecht_glowa(s, m):
    # kapalin: dzwon i szerokie rondo
    s.segment((0, 0.006, 1.738), (0, 0.004, 1.800), 0.185, 0.225, 0.150, 0.180, m["zelazo"], gora=(0, 1, 0), boki=8)
    s.segment((0, 0.004, 1.800), (0, 0.004, 1.835), 0.150, 0.180, 0.050, 0.060, m["zelazo"], gora=(0, 1, 0), boki=8)
    s.segment((0, 0.006, 1.728), (0, 0.006, 1.742), 0.330, 0.360, 0.200, 0.240, m["zelazo"], gora=(0, 1, 0), boki=8)
    # kaptur kolczy na szyi i barkach
    s.segment((0, 0.0, 1.49), (0, 0.004, 1.60), 0.200, 0.190, 0.165, 0.185, m["tors"], gora=(0, 1, 0), boki=8)
    s.pudlo((-0.036, 0.070, 1.588), (0.036, 0.0985, 1.606), m["ciemny"])            # zapadnięte usta


def knecht_miednica(s, m):
    # dół kolczugi do połowy uda
    s.segment((0, 0, 1.03), (0, 0, 0.70), 0.305, 0.215, 0.345, 0.245, m["tors"], gora=(0, 1, 0), boki=8)
    s.segment((0, 0, 1.075), (0, 0, 1.035), 0.300, 0.205, 0.300, 0.205, m["przedramie"], gora=(0, 1, 0), boki=8)   # pas


def knecht_tors(s, m):
    s.segment((0, 0.108, 1.44), (0, 0.118, 1.08), 0.20, 0.010, 0.17, 0.008, m["barwa"], gora=(0, 1, 0))     # resztki jaki
    s.segment((0, -0.110, 1.44), (0, -0.112, 1.10), 0.20, 0.010, 0.18, 0.008, m["barwa"], gora=(0, 1, 0))


def knecht_dodatki(seg, m, lista):
    # tarcza na lewym przedramieniu: osobny węzeł, bo ma własną klasę pancerza
    t = w.Siatka("tarcza", lista)
    x0 = -0.255
    t.profil([(-0.24, 1.36), (0.24, 1.36), (0.24, 1.02), (0.10, 0.76), (0.0, 0.70), (-0.10, 0.76), (-0.24, 1.02)], "y", 0.150, 0.172, m["drewno"])
    t.profil([(-0.25, 1.37), (0.25, 1.37), (0.25, 1.33), (-0.25, 1.33)], "y", 0.172, 0.180, m["zelazo"])
    t.pudlo((-0.012, 0.172, 0.74), (0.012, 0.180, 1.34), m["zelazo"])
    t.walec((0, 0.172, 1.10), (0, 0.205, 1.10), 0.055, m["zelazo"], n=8, r1=0.025)
    for p in t.bm.verts:
        p.co.x += x0 + 0.03
    seg["tarcza"] = t.obiekt(faza=0.002, gestosc=320, rodzic=seg["przedramie_l"], poczatek=(x0 + 0.03, 0.16, 1.10))
    # tasak w prawej dłoni: ostrze w dół w pozycji spoczynkowej, obracane w grze
    b = w.Siatka("bron", lista)
    cx, cy, cz = 0.236, 0.04, 0.805
    b.segment((cx, cy, cz + 0.07), (cx, cy, cz - 0.06), 0.026, 0.030, 0.024, 0.028, m["przedramie"], gora=(0, 1, 0), boki=6)
    b.pudlo((cx - 0.012, cy - 0.07, cz + 0.068), (cx + 0.012, cy + 0.07, cz + 0.084), m["zelazo"])
    b.profil([(cy - 0.022, cz + 0.084), (cy + 0.030, cz + 0.084), (cy + 0.048, cz + 0.62), (cy + 0.010, cz + 0.70), (cy - 0.022, cz + 0.66)], "x", cx - 0.004, cx + 0.004, m["zelazo"])
    seg["bron"] = b.obiekt(faza=0.001, gestosc=320, rodzic=seg["przedramie_p"], poczatek=(cx, cy, cz))


KNECHT = {"grubosc": 0.90, "glowa": knecht_glowa, "miednica": knecht_miednica, "tors": knecht_tors, "dodatki": knecht_dodatki}


# =================================================================== UPADŁY RYCERZ
def mat_rycerz():
    t = w.tekstura
    plyta = w.material("plyta", t("plyta", ["#2e3033", "#383b3e", "#43464a", "#3d2f24", "#565a5e"], skala=6.0, ziarno=51, drobny=0.35, progi=[0.25, 0.62, 0.88, 0.95]), 0.45, 0.7)
    plyta2 = w.material("plyta_ciemna", t("plyta_ciemna", ["#232528", "#2b2d30", "#333639", "#33281f"], skala=6.0, ziarno=52, drobny=0.35, progi=[0.3, 0.7, 0.93]), 0.5, 0.7)
    return {
        "skora": plyta, "ubranie": plyta, "dlon": plyta2, "golen": plyta, "but": plyta2, "biodra": plyta2,
        "plyta2": plyta2,
        "szczelina": w.material("przeszywanica_c", t("przeszywanica_c", ["#16130f", "#1c1813", "#221d17"], skala=3.0, ziarno=53, drobny=0.5), 1.0),
        "barwa": w.material("barwa_r", t("barwa_r", ["#2e0f0d", "#3b1411", "#481915", "#1d1714"], skala=5.0, ziarno=54, drobny=0.3, progi=[0.3, 0.68, 0.9]), 0.95),
        "ciemny": w.material("ciemny", t("ciemny", ["#040404", "#070707"], ziarno=5), 1.0),
        "zelazo": w.material("miecz", t("miecz", ["#4a4c4e", "#56585a", "#626466", "#473425"], skala=6.0, ziarno=55, drobny=0.3, progi=[0.3, 0.72, 0.95]), 0.4, 0.75),
        "rekojesc": w.material("rekojesc", t("rekojesc", ["#1d1611", "#261c15", "#2f231a"], skala=4.0, ziarno=56), 0.9),
    }


def rycerz_glowa(s, m):
    # hełm garnczkowy: walec zwężony ku górze, płaski szczyt, szczelina wzrokowa, otwory oddechowe
    s.segment((0, 0.0, 1.49), (0, 0.004, 1.575), 0.19, 0.19, 0.205, 0.235, m["szczelina"], gora=(0, 1, 0), boki=8)    # kołnierz
    s.segment((0, 0.008, 1.555), (0, 0.010, 1.700), 0.205, 0.245, 0.215, 0.250, m["skora"], gora=(0, 1, 0), boki=8)
    s.segment((0, 0.010, 1.700), (0, 0.006, 1.822), 0.215, 0.250, 0.185, 0.215, m["skora"], gora=(0, 1, 0), boki=8)
    s.segment((0, 0.006, 1.822), (0, 0.006, 1.836), 0.185, 0.215, 0.150, 0.180, m["plyta2"], gora=(0, 1, 0), boki=8)
    s.pudlo((-0.082, 0.118, 1.694), (0.082, 0.140, 1.712), m["ciemny"])            # wizjer
    s.pudlo((-0.006, 0.122, 1.58), (0.006, 0.142, 1.83), m["plyta2"])              # wzmocnienie pionowe
    s.pudlo((-0.090, 0.120, 1.716), (0.090, 0.139, 1.728), m["plyta2"])            # wzmocnienie poziome
    for sx in (-1, 1):
        for i in range(3):
            for j in range(2):
                x = sx * (0.030 + i * 0.020)
                s.pudlo((x - 0.004, 0.128, 1.615 + j * 0.026), (x + 0.004, 0.136, 1.625 + j * 0.026), m["ciemny"])


def rycerz_tors(s, m):
    # napierśnik z granią i ryflowany naplecznik
    s.segment((0, 0.085, 1.44), (0, 0.105, 1.12), 0.26, 0.070, 0.22, 0.050, m["skora"], gora=(0, 1, 0), boki=6)
    s.segment((0, 0.125, 1.43), (0, 0.140, 1.13), 0.030, 0.020, 0.024, 0.016, m["plyta2"], gora=(0, 1, 0))
    s.segment((0, -0.090, 1.44), (0, -0.095, 1.12), 0.27, 0.050, 0.23, 0.040, m["skora"], gora=(0, 1, 0), boki=6)
    # obojczyk
    s.segment((0, 0.0, 1.455), (0, 0.004, 1.50), 0.33, 0.24, 0.20, 0.20, m["plyta2"], gora=(0, 1, 0), boki=8)
    # szczeliny pod pachami (przeszywanica widoczna między napierśnikiem a naramiennikiem)
    for sx in (-1, 1):
        s.pudlo((sx * 0.168, -0.07, 1.34), (sx * 0.190, 0.07, 1.44), m["szczelina"])
    # resztki tuniki herbowej
    s.segment((0, 0.142, 1.36), (0, 0.150, 1.07), 0.17, 0.008, 0.15, 0.006, m["barwa"], gora=(0, 1, 0))


def rycerz_miednica(s, m):
    # fartuch z folg i taszki
    for i in range(3):
        z = 1.06 - i * 0.055
        s.segment((0, 0, z), (0, 0, z - 0.06), 0.31 + i * 0.022, 0.22 + i * 0.018, 0.325 + i * 0.022, 0.23 + i * 0.018, m["skora"] if i % 2 == 0 else m["plyta2"], gora=(0, 1, 0), boki=8)
    s.segment((0, 0.118, 1.05), (0, 0.128, 0.72), 0.15, 0.008, 0.11, 0.006, m["barwa"], gora=(0, 1, 0))


def rycerz_ramie(s, m, strona):
    # naramiennik: trzy folgi
    b = (0.205 * strona, 0.0, 1.43)
    for i in range(3):
        s.segment((b[0] + strona * (0.012 + i * 0.006), 0, b[2] + 0.055 - i * 0.050), (b[0] + strona * (0.018 + i * 0.006), 0, b[2] + 0.005 - i * 0.050),
                  0.150 - i * 0.012, 0.165 - i * 0.012, 0.158 - i * 0.012, 0.172 - i * 0.012, m["skora"] if i != 1 else m["plyta2"], gora=(0, 1, 0), boki=6)
    # nałokcica
    s.segment((0.228 * strona, -0.005, 1.175), (0.228 * strona, -0.012, 1.115), 0.105, 0.120, 0.100, 0.115, m["plyta2"], gora=(0, 1, 0), boki=6)


def rycerz_udo(s, m, strona):
    # nakolanek z przodu; tył kolana odsłonięty (przeszywanica)
    k = (0.097 * strona, 0.005, 0.50)
    s.segment((k[0], k[1] + 0.035, k[2] + 0.075), (k[0], k[1] + 0.042, k[2] - 0.02), 0.115, 0.075, 0.110, 0.070, m["plyta2"], gora=(0, 1, 0), boki=6)
    s.pudlo((k[0] - 0.045, k[1] - 0.068, k[2] + 0.005), (k[0] + 0.045, k[1] - 0.050, k[2] + 0.085), m["szczelina"])


def rycerz_dodatki(seg, m, lista):
    # miecz długi w prawej dłoni
    b = w.Siatka("bron", lista)
    cx, cy, cz = 0.236, 0.04, 0.805
    b.segment((cx, cy, cz + 0.11), (cx, cy, cz - 0.11), 0.028, 0.032, 0.026, 0.030, m["rekojesc"], gora=(0, 1, 0), boki=6)
    b.segment((cx, cy, cz - 0.11), (cx, cy, cz - 0.15), 0.045, 0.045, 0.030, 0.030, m["zelazo"], gora=(0, 1, 0), boki=6)       # głowica
    b.pudlo((cx - 0.012, cy - 0.115, cz + 0.108), (cx + 0.012, cy + 0.115, cz + 0.128), m["zelazo"])                           # jelec
    b.profil([(cy - 0.028, cz + 0.128), (cy + 0.028, cz + 0.128), (cy + 0.020, cz + 1.02), (cy, cz + 1.10), (cy - 0.020, cz + 1.02)], "x", cx - 0.0035, cx + 0.0035, m["zelazo"])
    b.pudlo((cx - 0.0045, cy - 0.006, cz + 0.128), (cx + 0.0045, cy + 0.006, cz + 0.80), m["zelazo"])                           # zbrocze
    seg["bron"] = b.obiekt(faza=0.001, gestosc=320, rodzic=seg["przedramie_p"], poczatek=(cx, cy, cz))


RYCERZ = {"grubosc": 1.10, "helm_pelny": True, "glowa": rycerz_glowa, "tors": rycerz_tors, "miednica": rycerz_miednica,
          "ramie": rycerz_ramie, "udo": rycerz_udo, "dodatki": rycerz_dodatki}

if __name__ == "__main__":
    ktore = sys.argv[1:] or ["ghul", "knecht", "rycerz"]
    if "ghul" in ktore:
        buduj("ghul", mat_ghul, GHUL)
    if "knecht" in ktore:
        buduj("knecht", mat_knecht, KNECHT)
    if "rycerz" in ktore:
        buduj("rycerz", mat_rycerz, RYCERZ)
