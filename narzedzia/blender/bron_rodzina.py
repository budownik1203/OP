"""Pozostała broń wersji 0.1. Uruchom: python3 bron_rodzina.py [granit gabro lupek krzemien weteran]
Układ jak w kwarc.py: początek na osi lufy z tyłu komory, wylot w stronę +Y, Z w górę."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wspolne as w
import rece


def materialy():
    t = w.tekstura
    return {
        "stal": w.material("stal_bron", t("stal_bron", ["#383b3f", "#3b3e42", "#3f4347", "#565b60"], skala=7.0, ziarno=1, drobny=0.35, rysy=0.003), 0.5, 0.6),
        "stal_jasna": w.material("stal_jasna", t("stal_jasna", ["#4a4d51", "#505357", "#56595d", "#6c7075"], skala=7.0, ziarno=71, drobny=0.35, rysy=0.003), 0.45, 0.65),
        "polimer": w.material("polimer", t("polimer", ["#232427", "#26272a", "#292b2e"], skala=6.0, ziarno=2, drobny=0.4), 0.9),
        "drewno": w.material("drewno_bron", t("drewno_bron", ["#4a2c19", "#55331d", "#5f3a21", "#3d2414"], skala=10.0, ziarno=72, drobny=0.15, progi=[0.3, 0.62, 0.9]), 0.75),
        "bakelit": w.material("bakelit", t("bakelit", ["#3a1d12", "#432215", "#4d2818"], skala=5.0, ziarno=73, drobny=0.4), 0.6),
        "guma": w.material("guma", t("guma", ["#0f0f10", "#141415"], skala=4.0, ziarno=3, drobny=0.6), 1.0),
        "magazynek": w.material("magazynek", t("magazynek", ["#38322a", "#3c352c", "#413a30", "#5c5348"], skala=6.0, ziarno=4, drobny=0.4, rysy=0.004), 0.6),
        "ciemny": w.material("ciemny", t("ciemny", ["#040404", "#070707"], ziarno=5), 1.0),
        "szklo": w.material("szklo", t("szklo", ["#0b1418", "#10202a", "#16303e"], skala=3.0, ziarno=74), 0.1, 0.3),
        "olive": w.material("chassis", t("chassis", ["#3a3d2e", "#3f4232", "#444736", "#57594a"], skala=6.0, ziarno=75, drobny=0.4, rysy=0.003), 0.7, 0.2),
        "kropka": w.material("kropka", t("kropka", ["#c9cdc4", "#d3d7ce"], ziarno=6), 0.8),
    }


def zaczep(nazwa):
    w.reset()
    m = materialy()
    mr = rece.materialy()
    return m, mr, w.pusty(nazwa, (0, 0, 0))


# ====================================================================== GRANIT (wzorzec: AKMS, 7,62×39)
def granit():
    m, mr, korzen = zaczep("granit")
    st, dr, ciem = m["stal"], m["drewno"], m["ciemny"]
    k = w.Siatka("korpus", [st, dr, m["bakelit"], ciem])
    HW = 0.0165
    k.pudlo((-HW, 0.0, -0.045), (HW, 0.255, 0.018), st)
    k.profil([(-0.0155, 0.018), (0.0155, 0.018), (0.0155, 0.028), (0.008, 0.036), (-0.008, 0.036), (-0.0155, 0.028)], "y", 0.004, 0.250, st)
    for y in (0.04, 0.08, 0.12, 0.16, 0.20):            # przetłoczenia pokrywy
        k.pudlo((-0.0158, y, 0.024), (0.0158, y + 0.004, 0.027), st)
    k.pudlo((HW - 0.0006, 0.115, 0.001), (HW + 0.0004, 0.205, 0.0185), ciem)       # okno wyrzutowe
    for (y, z) in ((0.04, -0.02), (0.08, -0.03), (0.205, -0.012), (0.235, -0.032), (0.165, -0.035)):
        k.walec((-HW - 0.001, y, z), (HW + 0.001, y, z), 0.0028, st, n=6, gladki=False)
    k.pudlo((-HW - 0.0008, 0.172, -0.045), (HW + 0.0008, 0.240, -0.022), st)      # gniazdo magazynka
    k.pudlo((-0.0155, 0.255, -0.014), (0.0155, 0.322, 0.030), st)                  # podstawa celownika
    k.pudlo((-0.010, 0.262, 0.030), (0.010, 0.320, 0.036), st)                     # celownik krzywkowy
    k.pudlo((-0.009, 0.262, 0.036), (-0.002, 0.267, 0.046), st)
    k.pudlo((0.002, 0.262, 0.036), (0.009, 0.267, 0.046), st)
    k.walec((0, 0.30, 0.0), (0, 0.630, 0.0), 0.0080, st, n=10)                     # lufa 415 mm
    k.walec((0, 0.32, 0.031), (0, 0.505, 0.031), 0.0090, st, n=8)                  # rura gazowa
    k.pudlo((-0.0105, 0.490, -0.012), (0.0105, 0.528, 0.042), st)                  # blok gazowy
    # łoże dolne i nakładka z drewna
    k.profil([(-0.0215, 0.012), (0.0215, 0.012), (0.024, -0.006), (0.019, -0.034), (-0.019, -0.034), (-0.024, -0.006)], "y", 0.330, 0.487, dr)
    for i in range(3):
        y = 0.355 + i * 0.045
        k.pudlo((-0.0245, y, -0.026), (-0.0235, y + 0.026, -0.006), ciem)          # wycięcia na palce
        k.pudlo((0.0235, y, -0.026), (0.0245, y + 0.026, -0.006), ciem)
    k.profil([(-0.0175, 0.022), (0.0175, 0.022), (0.0175, 0.034), (0.010, 0.0445), (-0.010, 0.0445), (-0.0175, 0.034)], "y", 0.330, 0.487, dr)
    k.pudlo((-0.022, 0.485, -0.030), (0.022, 0.493, 0.030), st)
    # muszka w osłonie
    k.pudlo((-0.010, 0.585, -0.012), (0.010, 0.610, 0.014), st)
    k.pudlo((-0.004, 0.588, 0.014), (0.004, 0.606, 0.040), st)
    k.pudlo((-0.011, 0.590, 0.034), (-0.008, 0.605, 0.060), st)
    k.pudlo((0.008, 0.590, 0.034), (0.011, 0.605, 0.060), st)
    k.pudlo((-0.0016, 0.596, 0.040), (0.0016, 0.600, 0.0515), st)
    # hamulec skośny
    k.walec((0, 0.628, 0.0), (0, 0.672, 0.0), 0.0118, st, n=10)
    k.pudlo((-0.0125, 0.656, 0.002), (0.0125, 0.672, 0.014), st)
    k.walec((0, 0.6715, 0.0), (0, 0.6725, 0.0), 0.0048, ciem, n=8, gladki=False)
    # kabłąk, spust, zatrzask
    k.pudlo((-0.0085, 0.100, -0.0805), (0.0085, 0.172, -0.0765), st)
    k.pudlo((-0.0085, 0.169, -0.0805), (0.0085, 0.172, -0.045), st)
    k.segment((0, 0.128, -0.045), (0, 0.134, -0.068), 0.006, 0.006, 0.005, 0.004, st, gora=(1, 0, 0))
    k.pudlo((-0.006, 0.172, -0.068), (0.006, 0.178, -0.045), st)
    # chwyt z bakelitu
    k.profil([(0.104, -0.045), (0.052, -0.045), (0.016, -0.148), (0.060, -0.154), (0.084, -0.090)], "x", -0.0145, 0.0145, m["bakelit"])
    # przełącznik rodzaju ognia: duża dźwignia z prawej
    k.pudlo((HW, 0.020, -0.012), (HW + 0.002, 0.190, -0.004), st)
    k.pudlo((HW + 0.002, 0.176, -0.016), (HW + 0.006, 0.190, -0.002), st)
    # kolba składana pod spód (złożona do przodu nie, rozłożona do tyłu)
    k.pudlo((-0.014, -0.020, -0.040), (0.014, 0.0, 0.010), st)
    for sx in (-1, 1):
        k.segment((sx * 0.011, -0.01, -0.006), (sx * 0.011, -0.235, -0.030), 0.005, 0.016, 0.005, 0.016, st, gora=(0, 0, 1))
        k.segment((sx * 0.011, -0.01, -0.030), (sx * 0.011, -0.235, -0.096), 0.005, 0.014, 0.005, 0.014, st, gora=(0, 0, 1))
    k.pudlo((-0.017, -0.250, -0.110), (0.017, -0.232, 0.004), st)
    k.pudlo((-0.010, -0.150, -0.072), (0.010, -0.138, -0.010), st)
    korpus = k.obiekt(rodzic=korzen)

    z = w.Siatka("zamek", [st])
    z.pudlo((HW - 0.004, 0.106, 0.003), (HW + 0.0008, 0.200, 0.0165), st)
    z.walec((HW, 0.186, 0.010), (HW + 0.026, 0.186, 0.010), 0.0055, st, n=8)
    z.obiekt(rodzic=korzen)

    mg = w.Siatka("magazynek", [m["magazynek"]])
    # magazynek 7,62×39: silniej zakrzywiony niż 5,56
    mg.profil([(0.176, -0.030), (0.236, -0.030), (0.238, -0.055), (0.252, -0.110), (0.276, -0.170), (0.310, -0.226),
               (0.258, -0.252), (0.226, -0.196), (0.204, -0.130), (0.186, -0.065)], "x", -0.0135, 0.0135, m["magazynek"])
    for (ya, za, yb, zb) in ((0.198, -0.07, 0.212, -0.13), (0.218, -0.07, 0.234, -0.13), (0.222, -0.150, 0.250, -0.21), (0.244, -0.145, 0.272, -0.205)):
        mg.segment((0.0138, ya, za), (0.0138, yb, zb), 0.0016, 0.008, 0.0016, 0.008, m["magazynek"], gora=(0, 1, 0))
        mg.segment((-0.0138, ya, za), (-0.0138, yb, zb), 0.0016, 0.008, 0.0016, 0.008, m["magazynek"], gora=(0, 1, 0))
    mg.obiekt(rodzic=korzen)

    rece.prawa_karabin(w, mr, (0.0, -0.004, 0.0)).obiekt(faza=0.0018, rodzic=korzen)
    rece.lewa_loze(w, mr, (0.0, -0.010, 0.0)).obiekt(faza=0.0018, rodzic=korzen)
    w.pusty("wylot", (0, 0.674, 0.0), korzen)
    w.pusty("celownik", (0, -0.110, 0.0515), korzen)
    w.eksport("granit")


# ====================================================================== GABRO (wzorzec: PM-84P, 9×19)
def gabro():
    m, mr, korzen = zaczep("gabro")
    st, pol, ciem = m["stal"], m["polimer"], m["ciemny"]
    k = w.Siatka("korpus", [st, pol, ciem, m["guma"]])
    # komora: prostopadłościan z zaokrągloną górą, magazynek w chwycie
    k.profil([(-0.019, -0.038), (0.019, -0.038), (0.020, 0.012), (0.014, 0.024), (-0.014, 0.024), (-0.020, 0.012)], "y", 0.0, 0.250, st)
    k.pudlo((0.0195, 0.070, -0.006), (0.0205, 0.140, 0.014), ciem)               # okno wyrzutowe
    k.walec((0, 0.250, 0.0), (0, 0.300, 0.0), 0.0085, st, n=10)                   # lufa
    k.walec((0, 0.292, 0.0), (0, 0.312, 0.0), 0.0110, st, n=10)                   # nakrętka
    k.walec((0, 0.3115, 0.0), (0, 0.3125, 0.0), 0.0048, ciem, n=8, gladki=False)
    # przyrządy: przeziernik przerzutowy i muszka w osłonie
    k.pudlo((-0.010, 0.012, 0.024), (0.010, 0.026, 0.034), st)
    k.pudlo((-0.010, 0.012, 0.034), (-0.003, 0.018, 0.046), st)
    k.pudlo((0.003, 0.012, 0.034), (0.010, 0.018, 0.046), st)
    k.pudlo((-0.010, 0.012, 0.034), (0.010, 0.018, 0.038), st)
    k.pudlo((-0.008, 0.226, 0.024), (0.008, 0.248, 0.030), st)
    k.pudlo((-0.0015, 0.234, 0.030), (0.0015, 0.238, 0.0455), st)
    k.pudlo((-0.009, 0.230, 0.030), (-0.007, 0.244, 0.048), st)
    k.pudlo((0.007, 0.230, 0.030), (0.009, 0.244, 0.048), st)
    # rączka napinająca z lewej, przełącznik z prawej
    k.walec((-0.019, 0.180, 0.004), (-0.034, 0.180, 0.004), 0.0045, st, n=6)
    k.pudlo((0.020, 0.030, -0.020), (0.023, 0.060, -0.010), st)
    # chwyt pistoletowy z magazynkiem
    k.profil([(0.116, -0.038), (0.074, -0.038), (0.062, -0.148), (0.104, -0.152), (0.110, -0.090)], "x", -0.0150, 0.0150, pol)
    k.pudlo((-0.0085, 0.050, -0.072), (0.0085, 0.110, -0.068), st)                # kabłąk
    k.pudlo((-0.0085, 0.050, -0.072), (0.0085, 0.054, -0.038), st)
    k.segment((0, 0.074, -0.038), (0, 0.078, -0.058), 0.006, 0.006, 0.005, 0.004, st, gora=(1, 0, 0))
    # chwyt przedni rozłożony
    k.pudlo((-0.010, 0.190, -0.050), (0.010, 0.214, -0.038), st)
    k.segment((0, 0.202, -0.048), (0, 0.206, -0.128), 0.022, 0.024, 0.020, 0.022, pol, gora=(0, 1, 0), boki=6)
    # kolba wysuwana: dwa pręty i stopka
    for sx in (-1, 1):
        k.walec((sx * 0.016, 0.02, -0.012), (sx * 0.016, -0.215, -0.012), 0.0042, st, n=6)
    k.pudlo((-0.022, -0.228, -0.070), (0.022, -0.212, 0.012), st)
    k.pudlo((-0.022, -0.234, -0.066), (0.022, -0.228, 0.008), m["guma"])
    k.obiekt(rodzic=korzen)
    z = w.Siatka("zamek", [st])
    z.pudlo((0.017, 0.072, -0.004), (0.0195, 0.138, 0.012), st)
    z.obiekt(rodzic=korzen)
    mg = w.Siatka("magazynek", [m["magazynek"]])
    mg.profil([(0.104, -0.150), (0.076, -0.148), (0.071, -0.208), (0.099, -0.212)], "x", -0.0105, 0.0105, m["magazynek"])
    mg.profil([(0.110, -0.212), (0.067, -0.208), (0.066, -0.218), (0.111, -0.222)], "x", -0.013, 0.013, m["magazynek"])
    mg.obiekt(rodzic=korzen)
    # prawa dłoń na chwycie z magazynkiem; lewa zaciśnięta na chwycie przednim
    rece.prawa_pistolet(w, mr, (0.004, 0.078, -0.030), lokiec=(0.115, -0.24, -0.20)).obiekt(faza=0.0018, rodzic=korzen)
    rece.prawa_pistolet(w, mr, (-0.0035, 0.206, -0.068), nazwa="reka_l", lustro=True, lokiec=(0.17, -0.12, -0.25)).obiekt(faza=0.0018, rodzic=korzen)
    w.pusty("wylot", (0, 0.314, 0.0), korzen)
    w.pusty("celownik", (0, -0.12, 0.0455), korzen)
    w.eksport("gabro")


# ====================================================================== ŁUPEK (wzorzec: Mossberg 590, 12/70)
def lupek():
    m, mr, korzen = zaczep("lupek")
    st, pol, ciem = m["stal"], m["polimer"], m["ciemny"]
    k = w.Siatka("korpus", [st, pol, ciem, m["guma"], m["kropka"]])
    k.profil([(-0.0175, -0.040), (0.0175, -0.040), (0.0175, 0.012), (0.011, 0.020), (-0.011, 0.020), (-0.0175, 0.012)], "y", 0.0, 0.190, st)
    k.pudlo((0.0172, 0.050, -0.016), (0.0182, 0.135, 0.008), ciem)                # okno wyrzutowe
    k.pudlo((-0.0182, 0.060, -0.040), (-0.0172, 0.150, -0.028), ciem)             # okno podajnika (spód boku)
    k.walec((0, 0.185, 0.0), (0, 0.660, 0.0), 0.0118, st, n=12)                   # lufa
    k.walec((0, 0.6595, 0.0), (0, 0.6605, 0.0), 0.0090, ciem, n=10, gladki=False)
    k.pudlo((-0.0035, 0.190, 0.0105), (0.0035, 0.656, 0.0215), st)                # szyna celownicza
    k.pudlo((-0.0016, 0.646, 0.0215), (0.0016, 0.652, 0.0255), m["kropka"])      # muszka
    k.walec((0, 0.150, -0.026), (0, 0.585, -0.026), 0.0118, st, n=12)             # magazynek rurowy
    k.pudlo((-0.011, 0.570, -0.040), (0.011, 0.598, 0.004), st)                   # obejma lufy i rury
    k.walec((0, 0.598, -0.026), (0, 0.606, -0.026), 0.0085, st, n=10)             # zakrętka rury
    # bezpiecznik na górze, zwalniacz czółenka przy kabłąku
    k.pudlo((-0.005, 0.010, 0.020), (0.005, 0.026, 0.0235), st)
    k.pudlo((-0.008, 0.035, -0.072), (0.008, 0.100, -0.068), st)
    k.pudlo((-0.008, 0.096, -0.072), (0.008, 0.100, -0.040), st)
    k.segment((0, 0.060, -0.040), (0, 0.064, -0.060), 0.006, 0.006, 0.005, 0.004, st, gora=(1, 0, 0))
    # chwyt pistoletowy i kolba stała
    k.profil([(0.030, -0.040), (-0.016, -0.040), (-0.048, -0.140), (-0.008, -0.150), (0.012, -0.090)], "x", -0.0145, 0.0145, pol)
    k.profil([(0.0, 0.012), (0.0, -0.040), (-0.030, -0.062), (-0.330, -0.150), (-0.345, -0.150), (-0.345, -0.030), (-0.330, -0.026), (-0.040, 0.004)], "x", -0.019, 0.019, pol)
    k.pudlo((-0.020, -0.360, -0.154), (0.020, -0.345, -0.024), m["guma"])
    k.obiekt(rodzic=korzen)
    # zamek: tylko widoczny element w oknie
    z = w.Siatka("zamek", [st])
    z.pudlo((0.0150, 0.060, -0.012), (0.0172, 0.125, 0.006), st)
    z.obiekt(rodzic=korzen)
    # czółenko na rurze magazynka, ruchome
    c = w.Siatka("czolenko", [pol])
    c.walec((0, 0.255, -0.026), (0, 0.430, -0.026), 0.0240, pol, n=10, gladki=False)
    for i in range(8):
        y = 0.275 + i * 0.019
        c.walec((0, y, -0.026), (0, y + 0.008, -0.026), 0.0255, pol, n=10, gladki=False)
    czolenko = c.obiekt(rodzic=korzen)
    mg = w.Siatka("magazynek", [st])                                              # pusty węzeł zastępczy (broń bez magazynka)
    mg.pudlo((-0.001, 0.10, -0.035), (0.001, 0.102, -0.034), st)
    mg.obiekt(rodzic=korzen)
    rece.prawa_karabin(w, mr, (0.0, -0.075, 0.005)).obiekt(faza=0.0018, rodzic=korzen)
    rl = rece.lewa_loze(w, mr, (0.0, -0.080, 0.006), szer=1.08)
    rl.obiekt(faza=0.0018, rodzic=korzen)
    w.pusty("wylot", (0, 0.662, 0.0), korzen)
    w.pusty("celownik", (0, -0.095, 0.0258), korzen)
    w.eksport("lupek")


# ====================================================================== KRZEMIEŃ (wzorzec: Bor, 7,62×51)
def krzemien():
    m, mr, korzen = zaczep("krzemien")
    st, ol, ciem = m["stal"], m["olive"], m["ciemny"]
    k = w.Siatka("korpus", [st, ol, ciem, m["guma"], m["szklo"], m["polimer"]])
    k.walec((0, -0.005, 0.0), (0, 0.215, 0.0), 0.0175, st, n=12)                  # komora zamkowa
    k.pudlo((0.0150, 0.050, -0.004), (0.0185, 0.130, 0.012), ciem)               # okno wyrzutowe
    k.walec((0, 0.215, 0.0), (0, 0.300, 0.0), 0.0140, st, n=12)                   # lufa ciężka
    k.walec((0, 0.300, 0.0), (0, 0.835, 0.0), 0.0110, st, n=12, r1=0.0095)
    k.walec((0, 0.828, 0.0), (0, 0.900, 0.0), 0.0150, st, n=8, gladki=False)      # hamulec wylotowy
    for y in (0.845, 0.865, 0.885):
        k.pudlo((-0.0155, y, -0.006), (0.0155, y + 0.010, 0.006), ciem)
    k.walec((0, 0.8995, 0.0), (0, 0.9005, 0.0), 0.0050, ciem, n=8, gladki=False)
    # łoże-szkielet: korpus komory, łoże pływające, szyna
    k.pudlo((-0.022, -0.020, -0.048), (0.022, 0.215, -0.012), ol)
    k.profil([(-0.026, -0.012), (0.026, -0.012), (0.028, -0.040), (0.020, -0.056), (-0.020, -0.056), (-0.028, -0.040)], "y", 0.215, 0.560, ol)
    for i in range(6):
        k.pudlo((0.0282, 0.240 + i * 0.050, -0.040), (0.0292, 0.270 + i * 0.050, -0.022), ciem)
        k.pudlo((-0.0292, 0.240 + i * 0.050, -0.040), (-0.0282, 0.270 + i * 0.050, -0.022), ciem)
    k.pudlo((-0.010, -0.010, 0.016), (0.010, 0.260, 0.024), st)                   # szyna montażowa
    # luneta
    for y in (0.035, 0.175):
        k.pudlo((-0.014, y, 0.022), (0.014, y + 0.020, 0.042), st)                # obejmy
    k.walec((0, 0.000, 0.058), (0, 0.065, 0.058), 0.0205, st, n=12)               # okular
    k.walec((0, 0.065, 0.058), (0, 0.240, 0.058), 0.0150, st, n=12)               # tubus
    k.pudlo((-0.008, 0.115, 0.072), (0.008, 0.140, 0.082), st)                    # pokrętło wysokości
    k.walec((0.015, 0.128, 0.058), (0.026, 0.128, 0.058), 0.007, st, n=8)         # pokrętło boczne
    k.walec((0, 0.240, 0.058), (0, 0.290, 0.058), 0.0150, st, n=12, r1=0.0255)    # obiektyw
    k.walec((0, 0.290, 0.058), (0, 0.325, 0.058), 0.0255, st, n=12)
    k.walec((0, 0.3245, 0.058), (0, 0.3255, 0.058), 0.0225, m["szklo"], n=12, gladki=False)
    k.walec((0, -0.0005, 0.058), (0, 0.0005, 0.058), 0.0170, m["szklo"], n=12, gladki=False)
    # kabłąk, spust, chwyt
    k.pudlo((-0.009, 0.040, -0.088), (0.009, 0.110, -0.084), ol)
    k.pudlo((-0.009, 0.106, -0.088), (0.009, 0.110, -0.048), ol)
    k.segment((0, 0.070, -0.048), (0, 0.074, -0.068), 0.006, 0.006, 0.005, 0.004, st, gora=(1, 0, 0))
    k.profil([(0.040, -0.048), (-0.006, -0.048), (-0.034, -0.156), (0.008, -0.162), (0.022, -0.100)], "x", -0.0155, 0.0155, m["polimer"])
    # kolba szkieletowa z podpórką policzkową
    k.profil([(-0.020, 0.010), (-0.020, -0.046), (-0.120, -0.050), (-0.360, -0.060), (-0.360, 0.022), (-0.120, 0.016)], "x", -0.016, 0.016, ol)
    k.profil([(-0.140, -0.050), (-0.180, -0.050), (-0.340, -0.150), (-0.360, -0.150), (-0.360, -0.060)], "x", -0.014, 0.014, ol)
    k.pudlo((-0.020, -0.300, 0.016), (0.020, -0.120, 0.040), ol)                  # podpórka policzkowa
    k.pudlo((-0.022, -0.376, -0.156), (0.022, -0.360, 0.026), m["guma"])
    # dwójnóg złożony pod łożem
    for sx in (-1, 1):
        k.segment((sx * 0.012, 0.520, -0.060), (sx * 0.014, 0.330, -0.066), 0.008, 0.010, 0.007, 0.009, st, gora=(0, 0, 1))
    k.pudlo((-0.020, 0.505, -0.066), (0.020, 0.540, -0.054), st)
    k.obiekt(rodzic=korzen)
    # zamek ślizgowo-obrotowy: rączka po prawej
    z = w.Siatka("zamek", [st])
    z.walec((0.0, 0.030, 0.0), (0.0, 0.050, 0.0), 0.0180, st, n=10)
    z.segment((0.012, 0.040, 0.004), (0.050, 0.030, -0.014), 0.008, 0.008, 0.007, 0.007, st, gora=(0, 0, 1))
    z.walec((0.050, 0.030, -0.014), (0.058, 0.030, -0.018), 0.0105, st, n=10)
    z.obiekt(rodzic=korzen)
    mg = w.Siatka("magazynek", [m["magazynek"]])
    mg.pudlo((-0.0145, 0.070, -0.110), (0.0145, 0.150, -0.046), m["magazynek"])
    mg.pudlo((-0.0165, 0.066, -0.118), (0.0165, 0.154, -0.108), m["magazynek"])
    mg.obiekt(rodzic=korzen)
    rece.prawa_karabin(w, mr, (0.0, -0.016, -0.003)).obiekt(faza=0.0018, rodzic=korzen)
    rece.lewa_loze(w, mr, (0.0, -0.040, -0.012), szer=1.25).obiekt(faza=0.0018, rodzic=korzen)
    w.pusty("wylot", (0, 0.902, 0.0), korzen)
    w.pusty("celownik", (0, -0.075, 0.058), korzen)
    w.eksport("krzemien")


# ====================================================================== WETERAN (wzorzec: typ 1911, .45 ACP)
def weteran():
    m, mr, korzen = zaczep("weteran")
    st, sj, ciem = m["stal"], m["stal_jasna"], m["ciemny"]
    HW = 0.0118
    z = w.Siatka("zamek", [st, ciem])
    z.profil([(-HW, -0.012), (HW, -0.012), (HW, 0.010), (0.009, 0.0145), (-0.009, 0.0145), (-HW, 0.010)], "y", 0.0, 0.212, st)
    for i in range(8):                                        # pionowe nacięcia tylne
        y = 0.010 + i * 0.005
        z.pudlo((-HW - 0.0006, y, -0.010), (HW + 0.0006, y + 0.0025, 0.008), st)
    z.pudlo((HW - 0.0004, 0.098, 0.0), (HW + 0.0004, 0.138, 0.0125), ciem)       # okno wyrzutowe
    z.pudlo((-0.0085, 0.004, 0.0145), (-0.0020, 0.014, 0.0200), st)              # szczerbinka
    z.pudlo((0.0020, 0.004, 0.0145), (0.0085, 0.014, 0.0200), st)
    z.pudlo((-0.0085, 0.004, 0.0145), (0.0085, 0.014, 0.0160), st)
    z.pudlo((-0.0015, 0.196, 0.0145), (0.0015, 0.206, 0.0200), st)               # muszka
    z.walec((0, 0.208, -0.001), (0, 0.216, -0.001), 0.0070, st, n=8)              # tuleja lufy
    z.walec((0, 0.2155, -0.001), (0, 0.2165, -0.001), 0.0058, ciem, n=8, gladki=False)
    z.obiekt(faza=0.001, rodzic=korzen)
    k = w.Siatka("korpus", [sj, m["drewno"], st, ciem])
    k.pudlo((-0.0112, 0.004, -0.030), (0.0112, 0.210, -0.012), sj)               # szkielet
    k.pudlo((-0.0095, 0.150, -0.036), (0.0095, 0.205, -0.030), sj)               # prowadnica sprężyny
    k.pudlo((-0.006, 0.040, -0.072), (0.006, 0.116, -0.068), sj)                 # kabłąk
    k.segment((0, 0.114, -0.070), (0, 0.120, -0.031), 0.012, 0.004, 0.012, 0.004, sj, gora=(0, 1, 0))
    k.segment((0, 0.084, -0.030), (0, 0.088, -0.054), 0.0075, 0.006, 0.0065, 0.005, st, gora=(1, 0, 0))   # spust
    # chwyt bardziej pionowy niż w „Jaspisie”
    k.profil([(0.004, -0.028), (-0.010, -0.026), (-0.008, -0.044), (-0.020, -0.130), (0.026, -0.134), (0.046, -0.034), (0.050, -0.028)], "x", -0.0122, 0.0122, sj)
    k.profil([(0.000, -0.040), (-0.005, -0.050), (-0.014, -0.120), (0.020, -0.124), (0.039, -0.042)], "x", -0.0150, 0.0150, m["drewno"])
    k.segment((0, -0.004, -0.024), (0, -0.026, -0.030), 0.018, 0.010, 0.016, 0.008, sj, gora=(0, 0, 1))   # bezpiecznik chwytowy
    k.segment((0, 0.000, -0.010), (0, -0.010, 0.003), 0.006, 0.007, 0.006, 0.006, st, gora=(1, 0, 0))     # kurek z ostrogą
    k.pudlo((-0.0138, 0.075, -0.016), (-0.0112, 0.112, -0.010), st)             # zatrzask zamka
    k.pudlo((-0.0135, 0.016, -0.014), (-0.0112, 0.036, -0.008), st)             # bezpiecznik nastawny
    k.obiekt(faza=0.001, rodzic=korzen)
    mg = w.Siatka("magazynek", [st])
    mg.profil([(0.002, -0.034), (0.032, -0.034), (0.020, -0.132), (-0.016, -0.128)], "x", -0.0085, 0.0085, st)
    mg.profil([(-0.019, -0.130), (0.025, -0.134), (0.025, -0.140), (-0.020, -0.136)], "x", -0.0115, 0.0115, st)
    mg.obiekt(faza=0.0008, rodzic=korzen)
    rece.prawa_pistolet(w, mr, (-0.001, 0.002, -0.002)).obiekt(faza=0.0018, rodzic=korzen)
    rece.lewa_pistolet(w, mr, (0.001, 0.002, -0.002)).obiekt(faza=0.0018, rodzic=korzen)
    w.pusty("wylot", (0, 0.218, -0.001), korzen)
    w.pusty("celownik", (0, -0.40, 0.0200), korzen)
    w.eksport("weteran")


if __name__ == "__main__":
    for n in (sys.argv[1:] or ["granit", "gabro", "lupek", "krzemien", "weteran"]):
        globals()[n]()
