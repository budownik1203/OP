"""Pistolet „Jaspis” (wzorzec: VIS 100). Uruchom: python3 jaspis.py
Początek układu: tył zamka na osi lufy. Wylot w stronę +Y. Chwyt oburącz."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wspolne as w
import rece

w.reset()
zamek_m = w.material("zamek_pist", w.tekstura("zamek_pist", ["#2c2e31", "#2f3235", "#333639", "#50555a"], skala=7.0, ziarno=21, drobny=0.35, rysy=0.003), 0.45, 0.6)
szkielet = w.material("szkielet_pist", w.tekstura("szkielet_pist", ["#3c3e40", "#404244", "#444749", "#5c6064"], skala=7.0, ziarno=22, drobny=0.35, rysy=0.003), 0.55, 0.5)
okladka = w.material("okladka", w.tekstura("okladka", ["#1c1c1d", "#202021", "#252526"], skala=3.0, ziarno=23, drobny=0.7), 0.95)
ciemny = w.material("ciemny", w.tekstura("ciemny", ["#040404", "#070707"], ziarno=5), 1.0)
bialy = w.material("kropka", w.tekstura("kropka", ["#c9cdc4", "#d3d7ce"], ziarno=6), 0.8)
mr = rece.materialy()

korzen = w.pusty("jaspis", (0, 0, 0))
HW = 0.0135

# ------------------------------------------------------------------ zamek (cała ruchoma góra)
z = w.Siatka("zamek", [zamek_m, ciemny, bialy])
z.profil([(-HW, -0.012), (HW, -0.012), (HW, 0.008), (0.0105, 0.014), (-0.0105, 0.014), (-HW, 0.008)], "y", 0.0, 0.190, zamek_m)
for i in range(6):                      # nacięcia tylne
    y = 0.012 + i * 0.006
    z.pudlo((-HW - 0.0006, y, -0.010), (HW + 0.0006, y + 0.003, 0.007), zamek_m)
for i in range(4):                      # nacięcia przednie
    y = 0.150 + i * 0.006
    z.pudlo((-HW - 0.0006, y, -0.010), (HW + 0.0006, y + 0.003, 0.007), zamek_m)
z.pudlo((0.002, 0.098, 0.0138), (HW + 0.0004, 0.142, 0.0146), ciemny)      # okno wyrzutowe (góra)
z.pudlo((HW - 0.0004, 0.098, 0.002), (HW + 0.0004, 0.142, 0.013), ciemny)  # okno wyrzutowe (bok)
# szczerbinka z dwiema kropkami
z.pudlo((-0.0100, 0.006, 0.014), (-0.0022, 0.016, 0.0205), zamek_m)
z.pudlo((0.0022, 0.006, 0.014), (0.0100, 0.016, 0.0205), zamek_m)
z.pudlo((-0.0100, 0.006, 0.014), (0.0100, 0.016, 0.0165), zamek_m)
z.pudlo((-0.0072, 0.0056, 0.0170), (-0.0050, 0.0062, 0.0192), bialy)
z.pudlo((0.0050, 0.0056, 0.0170), (0.0072, 0.0062, 0.0192), bialy)
# muszka z kropką
z.pudlo((-0.0018, 0.174, 0.014), (0.0018, 0.184, 0.0203), zamek_m)
z.pudlo((-0.0011, 0.1736, 0.0172), (0.0011, 0.1742, 0.0194), bialy)
# lufa widoczna z przodu
z.walec((0, 0.186, 0.0), (0, 0.194, 0.0), 0.0072, zamek_m, n=8)
z.walec((0, 0.1935, 0.0), (0, 0.1945, 0.0), 0.0046, ciemny, n=8, gladki=False)
zamek = z.obiekt(faza=0.001, rodzic=korzen)

# ------------------------------------------------------------------ korpus (szkielet, chwyt)
k = w.Siatka("korpus", [szkielet, okladka, zamek_m, ciemny])
k.pudlo((-0.0125, 0.004, -0.030), (0.0125, 0.188, -0.012), szkielet)
# szyna pod lufą
k.pudlo((-0.0105, 0.118, -0.0365), (0.0105, 0.186, -0.030), szkielet)
for i in range(3):
    y = 0.130 + i * 0.016
    k.pudlo((-0.0112, y, -0.0372), (0.0112, y + 0.005, -0.033), ciemny)
# kabłąk
k.pudlo((-0.007, 0.064, -0.0725), (0.007, 0.123, -0.0675), szkielet)
k.segment((0, 0.1205, -0.071), (0, 0.129, -0.033), 0.014, 0.005, 0.014, 0.005, szkielet, gora=(0, 1, 0))
k.segment((0, 0.086, -0.032), (0, 0.091, -0.058), 0.006, 0.006, 0.005, 0.004, zamek_m, gora=(1, 0, 0))   # spust
# chwyt
k.profil([(0.004, -0.028), (-0.016, -0.024), (-0.011, -0.050), (-0.030, -0.128), (0.024, -0.134), (0.062, -0.034), (0.066, -0.028)], "x", -0.0135, 0.0135, szkielet)
k.profil([(0.000, -0.040), (-0.006, -0.052), (-0.022, -0.118), (0.020, -0.123), (0.050, -0.044)], "x", -0.0158, 0.0158, okladka)
# kurek
k.segment((0, 0.000, -0.010), (0, -0.011, 0.006), 0.007, 0.006, 0.007, 0.008, zamek_m, gora=(1, 0, 0))
# dźwignie: zwalniacz zamka i zrzut kurka
k.pudlo((-0.0148, 0.070, -0.016), (-0.0125, 0.104, -0.011), zamek_m)
k.pudlo((HW - 0.001, 0.020, -0.016), (HW + 0.0022, 0.044, -0.010), zamek_m)
k.pudlo((-HW - 0.0022, 0.020, -0.016), (-HW + 0.001, 0.044, -0.010), zamek_m)
korpus = k.obiekt(faza=0.001, rodzic=korzen)

# ------------------------------------------------------------------ magazynek
m = w.Siatka("magazynek", [zamek_m, okladka])
m.profil([(0.002, -0.036), (0.040, -0.036), (0.022, -0.130), (-0.022, -0.126)], "x", -0.0098, 0.0098, zamek_m)
m.profil([(-0.031, -0.128), (0.026, -0.134), (0.025, -0.143), (-0.033, -0.137)], "x", -0.0145, 0.0145, okladka)
magazynek = m.obiekt(faza=0.0008, rodzic=korzen)

# ------------------------------------------------------------------ prawa ręka
rp = w.Siatka("reka_p", [mr["rekawica"], mr["wzm"], mr["rekaw"]])
rece.srodrecze(rp, (0.030, -0.066, -0.086), (0.0295, 0.036, -0.062), mr)
for i, zz in enumerate((-0.062, -0.083, -0.103)):
    przes = i * 0.007
    rece.palec(rp, [(0.029, 0.040 - przes, zz), (-0.004, 0.068 - przes, zz - 0.003), (-0.019, 0.044 - przes, zz - 0.005)], 0.0185, mr["wzm"])
rece.palec(rp, [(0.028, 0.040, -0.040), (0.0195, 0.086, -0.031), (0.0165, 0.118, -0.028)], 0.0175, mr["rekawica"])
rece.palec(rp, [(0.012, -0.030, -0.030), (-0.0175, 0.006, -0.024), (-0.0185, 0.044, -0.020)], 0.021, mr["rekawica"])
rp.segment((0.020, -0.040, -0.040), (0.004, -0.016, -0.052), 0.034, 0.042, 0.030, 0.036, mr["rekawica"])
rece.przedramie(rp, (0.033, -0.062, -0.082), (0.115, -0.330, -0.150), mr)
reka_p = rp.obiekt(faza=0.0018, rodzic=korzen)

# ------------------------------------------------------------------ lewa ręka (podtrzymująca)
rl = w.Siatka("reka_l", [mr["rekawica"], mr["wzm"], mr["rekaw"]])
rece.srodrecze(rl, (-0.031, -0.060, -0.104), (-0.031, 0.040, -0.074), mr, strona=-1)
for i, zz in enumerate((-0.060, -0.081, -0.101, -0.119)):
    przes = i * 0.007
    rece.palec(rl, [(-0.030, 0.046 - przes, zz), (0.004, 0.086 - przes, zz - 0.003), (0.034, 0.062 - przes, zz - 0.005)], 0.0185 - (0.002 if i == 3 else 0.0), mr["wzm"])
rece.palec(rl, [(-0.022, -0.012, -0.040), (-0.0195, 0.040, -0.024), (-0.0185, 0.082, -0.020)], 0.021, mr["rekawica"])
rece.przedramie(rl, (-0.034, -0.058, -0.100), (-0.150, -0.310, -0.175), mr)
reka_l = rl.obiekt(faza=0.0018, rodzic=korzen)

w.pusty("wylot", (0, 0.196, 0.0), korzen)
w.pusty("celownik", (0, -0.40, 0.0203), korzen)
w.eksport("jaspis")
