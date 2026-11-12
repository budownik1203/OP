"""Karabinek „Kwarc” wz. 96 (wzorzec: Beryl). Uruchom: python3 kwarc.py
Początek układu: tył komory zamkowej na osi lufy. Wylot lufy w stronę +Y."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wspolne as w
import rece

w.reset()
stal = w.material("stal_bron", w.tekstura("stal_bron", ["#383b3f", "#3b3e42", "#3f4347", "#565b60"], skala=7.0, ziarno=1, drobny=0.35, rysy=0.003), 0.5, 0.6)
polimer = w.material("polimer", w.tekstura("polimer", ["#232427", "#26272a", "#292b2e"], skala=6.0, ziarno=2, drobny=0.4), 0.9)
guma = w.material("guma", w.tekstura("guma", ["#0f0f10", "#141415"], skala=4.0, ziarno=3, drobny=0.6), 1.0)
magm = w.material("magazynek", w.tekstura("magazynek", ["#4a4a38", "#525240", "#5b5a46", "#6a6952", "#3c3c2e"], skala=6.0, ziarno=4, drobny=0.4, rysy=0.004, progi=[0.2, 0.55, 0.82, 0.95]), 0.45)
naboje_m = w.material("naboje_w_mag", w.tekstura("naboje_w_mag", ["#6e5a2a", "#7a6430", "#866e36"], skala=14.0, ziarno=6, drobny=0.6), 0.5, 0.4)
ciemny = w.material("ciemny", w.tekstura("ciemny", ["#040404", "#070707"], ziarno=5), 1.0)
mr = rece.materialy()

korzen = w.pusty("kwarc", (0, 0, 0))

# ------------------------------------------------------------------ korpus
k = w.Siatka("korpus", [stal, polimer, guma, ciemny])
HW = 0.0165
# komora zamkowa
k.pudlo((-HW, 0.0, -0.045), (HW, 0.262, 0.018), stal)
# pokrywa komory: przekrój ośmiokątny
k.profil([(-0.0155, 0.018), (0.0155, 0.018), (0.0155, 0.029), (0.009, 0.0375), (-0.009, 0.0375), (-0.0155, 0.029)], "y", 0.004, 0.258, stal)
# szyna montażowa na wsporniku nad pokrywą (jak w wz. 96C): niska listwa z zębami
k.pudlo((-0.0105, 0.018, 0.0375), (0.0105, 0.250, 0.0405), stal)
for i in range(19):
    y = 0.022 + i * 0.012
    k.pudlo((-0.0105, y, 0.0405), (0.0105, y + 0.0062, 0.0438), stal)
# wspornik szyny: ramię schodzące do osi zawiasu z tyłu i do podstawy celownika z przodu
k.profil([(0.004, 0.018), (0.030, 0.018), (0.040, 0.0375), (0.004, 0.0375)], "x", -0.0125, -0.0105, stal)
k.profil([(0.004, 0.018), (0.030, 0.018), (0.040, 0.0375), (0.004, 0.0375)], "x", 0.0105, 0.0125, stal)
k.pudlo((-0.0125, 0.236, 0.022), (0.0125, 0.262, 0.0405), stal)
# okno wyrzutowe (ciemne wgłębienie po prawej)
k.pudlo((HW - 0.0006, 0.118, 0.001), (HW + 0.0004, 0.215, 0.0185), ciemny)
# nity i oś spustu na boku komory
for (y, z) in ((0.045, -0.02), (0.085, -0.03), (0.215, -0.012), (0.24, -0.03)):
    k.walec((-HW - 0.001, y, z), (HW + 0.001, y, z), 0.0028, stal, n=6, gladki=False)
# gniazdo magazynka: lekkie przetłoczenie
k.pudlo((-HW - 0.0008, 0.178, -0.045), (HW + 0.0008, 0.245, -0.022), stal)
# podstawa celownika
k.pudlo((-0.0155, 0.262, -0.014), (0.0155, 0.332, 0.030), stal)
k.pudlo((-0.011, 0.270, 0.030), (0.011, 0.330, 0.0385), stal)
# szczerbinka: płytka z wycięciem U
k.pudlo((-0.0095, 0.266, 0.0385), (0.0095, 0.271, 0.0475), stal)
k.pudlo((-0.0095, 0.266, 0.0475), (-0.0021, 0.271, 0.0565), stal)
k.pudlo((0.0021, 0.266, 0.0475), (0.0095, 0.271, 0.0565), stal)
# lufa
k.walec((0, 0.30, 0.0), (0, 0.652, 0.0), 0.0078, stal, n=10)
# rura gazowa i komora gazowa
k.walec((0, 0.33, 0.029), (0, 0.515, 0.029), 0.0082, stal, n=8)
k.pudlo((-0.0105, 0.500, -0.012), (0.0105, 0.536, 0.040), stal)
k.pudlo((-0.006, 0.536, -0.016), (0.006, 0.548, -0.004), stal)   # zaczep pasa
# łoże dolne
k.profil([(-0.0215, 0.012), (0.0215, 0.012), (0.0235, -0.008), (0.0165, -0.035), (-0.0165, -0.035), (-0.0235, -0.008)], "y", 0.336, 0.497, polimer)
# szyny boczne i dolna na łożu: listwa z zębami, pod nią rząd okrągłych otworów
for sx in (-1, 1):
    k.pudlo((sx * 0.0232, 0.342, -0.006), (sx * 0.0262, 0.492, 0.008), stal)
    for i in range(12):
        y = 0.345 + i * 0.0122
        k.pudlo((sx * 0.0262, y, -0.006), (sx * 0.0284, y + 0.0064, 0.008), stal)
    for i in range(6):
        y = 0.356 + i * 0.024
        k.walec((sx * 0.0200, y, -0.021), (sx * 0.0222, y, -0.021), 0.0052, ciemny, n=8, gladki=False)
k.pudlo((-0.008, 0.342, -0.0385), (0.008, 0.492, -0.035), stal)
for i in range(12):
    y = 0.345 + i * 0.0122
    k.pudlo((-0.008, y, -0.0408), (0.008, y + 0.0064, -0.0385), stal)
# nakładka górna
k.profil([(-0.019, 0.012), (0.019, 0.012), (0.019, 0.034), (0.011, 0.0465), (-0.011, 0.0465), (-0.019, 0.034)], "y", 0.336, 0.497, polimer)
for i in range(5):
    y = 0.360 + i * 0.027
    for sx in (-1, 1):
        k.walec((sx * 0.0172, y, 0.026), (sx * 0.0196, y, 0.026), 0.0048, ciemny, n=8, gladki=False)
k.pudlo((-0.0095, 0.340, 0.0465), (0.0095, 0.494, 0.049), stal)
for i in range(12):
    y = 0.343 + i * 0.0124
    k.pudlo((-0.0095, y, 0.049), (0.0095, y + 0.0064, 0.0518), stal)
# okucie łoża
k.pudlo((-0.022, 0.495, -0.030), (0.022, 0.503, 0.036), stal)
# podstawa muszki z osłonami
k.pudlo((-0.011, 0.586, -0.012), (0.011, 0.612, 0.014), stal)
k.pudlo((-0.0045, 0.588, 0.014), (0.0045, 0.610, 0.040), stal)
k.pudlo((-0.0125, 0.590, 0.036), (-0.0095, 0.608, 0.066), stal)
k.pudlo((0.0095, 0.590, 0.036), (0.0125, 0.608, 0.066), stal)
k.pudlo((-0.0125, 0.590, 0.034), (0.0125, 0.608, 0.040), stal)
k.pudlo((-0.0017, 0.597, 0.040), (0.0017, 0.601, 0.0535), stal)  # muszka
# tłumik płomieni z pierścieniami
k.walec((0, 0.640, 0.0), (0, 0.722, 0.0), 0.0108, stal, n=10)
k.walec((0, 0.650, 0.0), (0, 0.657, 0.0), 0.0128, stal, n=10)
k.walec((0, 0.676, 0.0), (0, 0.683, 0.0), 0.0128, stal, n=10)
for kat_x, kat_z in ((0.0109, 0.0), (-0.0109, 0.0), (0.0, 0.0109), (0.0077, 0.0077), (-0.0077, 0.0077)):
    k.pudlo((kat_x - 0.0021, 0.688, kat_z - 0.0021), (kat_x + 0.0021, 0.700, kat_z + 0.0021), ciemny)
    k.pudlo((kat_x - 0.0021, 0.704, kat_z - 0.0021), (kat_x + 0.0021, 0.716, kat_z + 0.0021), ciemny)
# zaczep bagnetu i wycior pod lufą
k.pudlo((-0.004, 0.560, -0.020), (0.004, 0.584, -0.008), stal)
k.walec((0, 0.500, -0.0165), (0, 0.640, -0.0165), 0.0026, stal, n=6)
k.walec((0, 0.7215, 0.0), (0, 0.7225, 0.0), 0.0045, ciemny, n=8, gladki=False)  # otwór lufy
# kabłąk i język spustowy
k.pudlo((-0.0085, 0.104, -0.0805), (0.0085, 0.177, -0.0765), stal)
k.pudlo((-0.0085, 0.173, -0.0805), (0.0085, 0.177, -0.045), stal)
k.segment((0, 0.132, -0.045), (0, 0.138, -0.068), 0.006, 0.006, 0.005, 0.004, stal, gora=(1, 0, 0))
# zatrzask magazynka
k.pudlo((-0.006, 0.176, -0.066), (0.006, 0.182, -0.045), stal)
# chwyt pistoletowy
# chwyt ergonomiczny: wybrzuszenie pod dłoń z tyłu, podcięcie pod palce z przodu, stopka
k.profil([(0.112, -0.045), (0.052, -0.045), (0.040, -0.072), (0.026, -0.112), (0.014, -0.150), (0.022, -0.160),
          (0.066, -0.164), (0.074, -0.150), (0.080, -0.118), (0.090, -0.086), (0.104, -0.066)], "x", -0.0150, 0.0150, polimer)
for i in range(4):
    zz = -0.084 - i * 0.017
    yy = 0.050 - i * 0.0075
    for sx in (-1, 1):
        k.pudlo((sx * 0.0150, yy, zz), (sx * 0.0162, yy + 0.030, zz + 0.006), polimer)
# dźwignia zwalniania magazynka (łopatka przed kabłąkiem) i selektor po lewej
k.profil([(0.176, -0.045), (0.184, -0.045), (0.190, -0.074), (0.181, -0.076)], "x", -0.007, 0.007, stal)
k.pudlo((-HW - 0.0045, 0.086, -0.030), (-HW, 0.100, -0.016), stal)
# dźwignia bezpiecznika (prawa strona)
k.pudlo((HW, 0.030, -0.014), (HW + 0.002, 0.150, -0.005), stal)
k.pudlo((HW + 0.002, 0.136, -0.016), (HW + 0.006, 0.150, -0.003), stal)
# zawias, rura i kolba teleskopowa z poduszką policzkową (wz. 96C)
k.pudlo((-0.015, -0.022, -0.034), (0.015, 0.0, 0.016), stal)
k.walec((0, -0.016, -0.004), (0, -0.196, -0.004), 0.0135, stal, n=10)
k.profil([(-0.060, 0.018), (-0.205, 0.022), (-0.232, 0.016), (-0.232, -0.030), (-0.212, -0.096), (-0.186, -0.100),
          (-0.150, -0.046), (-0.060, -0.024)], "x", -0.0165, 0.0165, polimer)
# wybranie w kolbie (lżejsza sylwetka) i żebra regulacji
k.profil([(-0.172, -0.036), (-0.206, -0.036), (-0.200, -0.074), (-0.186, -0.074)], "x", -0.0170, 0.0170, ciemny)
for i in range(4):
    y = -0.078 - i * 0.022
    k.pudlo((-0.0172, y, -0.022), (0.0172, y + 0.006, -0.016), ciemny)
# stopka gumowa, lekko skośna
k.profil([(-0.232, 0.022), (-0.250, 0.018), (-0.246, -0.100), (-0.212, -0.100), (-0.232, -0.030)], "x", -0.0175, 0.0175, guma)
korpus = k.obiekt(rodzic=korzen)

# ------------------------------------------------------------------ zamek
z = w.Siatka("zamek", [stal])
z.pudlo((HW - 0.004, 0.110, 0.003), (HW + 0.0008, 0.212, 0.0165), stal)
z.walec((HW, 0.196, 0.010), (HW + 0.024, 0.196, 0.010), 0.0052, stal, n=8)
z.walec((HW + 0.020, 0.196, 0.010), (HW + 0.030, 0.199, 0.010), 0.0062, stal, n=8)
zamek = z.obiekt(rodzic=korzen)

# ------------------------------------------------------------------ magazynek
m = w.Siatka("magazynek", [magm, stal, naboje_m])
# łukowy magazynek z dymnego polimeru: szeroki, z żebrami usztywniającymi i widocznym słupkiem naboi
m.profil([(0.180, -0.030), (0.244, -0.030), (0.245, -0.052), (0.252, -0.100), (0.266, -0.150), (0.288, -0.200), (0.304, -0.228),
          (0.244, -0.258), (0.226, -0.222), (0.208, -0.170), (0.194, -0.112), (0.181, -0.052)], "x", -0.0130, 0.0130, magm)
for i in range(9):
    t0 = i / 9.0
    ya = 0.192 + t0 * 0.050 + t0 * t0 * 0.012
    za = -0.062 - t0 * 0.165
    for sx in (-1, 1):
        m.segment((sx * 0.0134, ya, za), (sx * 0.0134, ya + 0.050 + t0 * 0.004, za - 0.012), 0.0014, 0.0042, 0.0014, 0.0042, magm, gora=(0, 0, 1))
# słupek naboi prześwitujący przez ściankę (tylna krawędź)
for sx in (-1, 1):
    m.segment((sx * 0.0132, 0.190, -0.060), (sx * 0.0132, 0.232, -0.212), 0.0010, 0.010, 0.0010, 0.010, naboje_m, gora=(0, 1, 0))
m.segment((0, 0.243, -0.2605), (0, 0.305, -0.2295), 0.030, 0.007, 0.030, 0.007, magm)
m.pudlo((-0.0115, 0.184, -0.030), (0.0115, 0.240, -0.024), stal)
magazynek = m.obiekt(rodzic=korzen)

# ------------------------------------------------------------------ prawa ręka (chwyt)
rp = w.Siatka("reka_p", [mr["rekawica"], mr["wzm"], mr["rekaw"]])
# śródręcze: grzbiet dłoni po prawej stronie chwytu
rece.srodrecze(rp, (0.031, 0.000, -0.108), (0.031, 0.092, -0.084), mr)
# trzy palce owinięte wokół chwytu
for i, zz in enumerate((-0.082, -0.103, -0.123)):
    przes = i * 0.006
    rece.palec(rp, [(0.030, 0.094 - przes, zz), (-0.006, 0.108 - przes, zz - 0.002), (-0.021, 0.080 - przes, zz - 0.004)], 0.0185, mr["wzm"])
# palec wskazujący wyprostowany wzdłuż komory (poza spustem)
rece.palec(rp, [(0.029, 0.094, -0.060), (0.0245, 0.140, -0.052), (0.0225, 0.172, -0.049)], 0.0175, mr["rekawica"])
# kciuk po lewej stronie
rece.palec(rp, [(0.014, 0.020, -0.056), (-0.019, 0.050, -0.058), (-0.0215, 0.086, -0.060)], 0.021, mr["rekawica"])
# kłąb kciuka za chwytem
rp.segment((0.020, 0.004, -0.060), (0.004, 0.040, -0.070), 0.034, 0.040, 0.030, 0.036, mr["rekawica"])
rece.przedramie(rp, (0.034, 0.004, -0.104), (0.105, -0.235, -0.215), mr)
reka_p = rp.obiekt(faza=0.0018, rodzic=korzen)

# ------------------------------------------------------------------ lewa ręka (pod łożem)
rl = w.Siatka("reka_l", [mr["rekawica"], mr["wzm"], mr["rekaw"]])
rl.segment((-0.040, 0.418, -0.050), (0.030, 0.418, -0.047), 0.094, 0.026, 0.090, 0.024, mr["rekawica"], gora=(0, 0, 1))
for i in range(4):
    y = 0.383 + i * 0.0225
    rece.palec(rl, [(0.027, y, -0.046), (0.0345, y, -0.006), (0.027, y, 0.019)], 0.0185 - (0.002 if i == 3 else 0.0), mr["rekawica"], gora=(0, 1, 0))
rece.palec(rl, [(-0.030, 0.392, -0.044), (-0.0345, 0.424, -0.010), (-0.029, 0.452, 0.008)], 0.021, mr["rekawica"], gora=(1, 0, 0))
rece.przedramie(rl, (-0.046, 0.404, -0.060), (-0.170, 0.215, -0.235), mr)
reka_l = rl.obiekt(faza=0.0018, rodzic=korzen)

# ------------------------------------------------------------------ punkty
w.pusty("wylot", (0, 0.724, 0.0), korzen)
# oko 11 cm za szczerbinką... linia celowania: szczerbinka z=0.0535, muszka z=0.0535
w.pusty("celownik", (0, -0.105, 0.0535), korzen)
w.eksport("kwarc")
