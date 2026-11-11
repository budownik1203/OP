"""Ręce żołnierza: rękawice taktyczne i rękaw munduru w kamuflażu.
Dłonie budowane są ze sztywnych segmentów: śródręcze, palce po dwa człony, kciuk."""
from mathutils import Vector

import wspolne as w


def materialy():
    rekawica = w.material("rekawica", w.tekstura("rekawica", ["#4b4331", "#574d38", "#63583f"], skala=5.0, ziarno=11, drobny=0.5), 0.95)
    wzmocnienie = w.material("rekawica_wzm", w.tekstura("rekawica_wzm", ["#24231f", "#2c2a25", "#34312b"], skala=4.0, ziarno=12, drobny=0.5), 0.9)
    rekaw = w.material("rekaw", w.tekstura("rekaw_pantera", ["#1e201a", "#39452f", "#4e4832", "#5c6142"], skala=9.0, ziarno=13, drobny=0.08, progi=[0.13, 0.50, 0.76]), 1.0)
    return {"rekawica": rekawica, "wzm": wzmocnienie, "rekaw": rekaw}


def palec(s, punkty, grubosc, m, gora=(0, 0, 1), zwezenie=0.85):
    """Łańcuch członów palca przez podane punkty."""
    g = grubosc
    for a, b in zip(punkty[:-1], punkty[1:]):
        s.segment(a, b, g, g * 0.92, g * zwezenie, g * 0.92 * zwezenie, m, gora=gora)
        g *= zwezenie


def przedramie(s, nadgarstek, lokiec, mat, gora=(0, 0, 1)):
    """Mankiet rękawicy, potem rękaw rozszerzający się do łokcia."""
    n, l = Vector(nadgarstek), Vector(lokiec)
    kier = (l - n).normalized()
    mankiet = n + kier * 0.055
    s.segment(n - kier * 0.012, mankiet, 0.066, 0.052, 0.072, 0.058, mat["wzm"], gora=gora, boki=6)
    s.segment(mankiet - kier * 0.004, l, 0.078, 0.066, 0.108, 0.100, mat["rekaw"], gora=gora, boki=6)


def srodrecze(s, nadgarstek, knykcie, mat, strona=1):
    """Grzbiet dłoni: węższy przy nadgarstku, szerszy przy knykciach,
    z ochraniaczem wzdłuż linii knykci. strona: 1 = prawa ręka, -1 = lewa."""
    a, b = Vector(nadgarstek), Vector(knykcie)
    s.segment(a, b, 0.024, 0.066, 0.025, 0.086, mat["rekawica"], gora=(0, 0, 1))
    os_ = (b - a).normalized()
    bok = os_.cross(Vector((0, 0, 1))).normalized()
    g = bok.cross(os_).normalized()
    c = a.lerp(b, 0.88) + bok * strona * 0.0125
    s.segment(c - g * 0.037, c + g * 0.037, 0.024, 0.007, 0.024, 0.007, mat["wzm"], gora=tuple(bok))
    # szew przez grzbiet dłoni
    c2 = a.lerp(b, 0.35) + bok * strona * 0.0122
    s.segment(c2 - g * 0.028, c2 + g * 0.028, 0.006, 0.003, 0.006, 0.003, mat["wzm"], gora=tuple(bok))


def _przesun(s, o, lustro_x=False, skala=(1.0, 1.0, 1.0)):
    """Przesuwa (i ewentualnie odbija w X lub skaluje) całą zawartość siatki."""
    for v in s.bm.verts:
        x, y, z = v.co.x * skala[0], v.co.y * skala[1], v.co.z * skala[2]
        if lustro_x:
            x = -x
        v.co = Vector((x + o[0], y + o[1], z + o[2]))


def prawa_karabin(w_mod, mr, o=(0, 0, 0), lokiec=None):
    """Prawa dłoń na chwycie pistoletowym karabinka. Wzorzec: „Kwarc”, chwyt
    z przodu u góry w (0, 0.056, -0.045); o = przesunięcie względem wzorca."""
    rp = w_mod.Siatka("reka_p", [mr["rekawica"], mr["wzm"], mr["rekaw"]])
    srodrecze(rp, (0.031, 0.000, -0.108), (0.031, 0.092, -0.084), mr)
    for i, zz in enumerate((-0.082, -0.103, -0.123)):
        przes = i * 0.006
        palec(rp, [(0.030, 0.094 - przes, zz), (-0.006, 0.108 - przes, zz - 0.002), (-0.021, 0.080 - przes, zz - 0.004)], 0.0185, mr["wzm"])
    palec(rp, [(0.029, 0.094, -0.060), (0.0245, 0.140, -0.052), (0.0225, 0.172, -0.049)], 0.0175, mr["rekawica"])
    palec(rp, [(0.014, 0.020, -0.056), (-0.019, 0.050, -0.058), (-0.0215, 0.086, -0.060)], 0.021, mr["rekawica"])
    rp.segment((0.020, 0.004, -0.060), (0.004, 0.040, -0.070), 0.034, 0.040, 0.030, 0.036, mr["rekawica"])
    lk = lokiec if lokiec is not None else (0.105 - o[0], -0.235 - o[1], -0.215 - o[2])
    przedramie(rp, (0.034, 0.004, -0.104), lk, mr)
    _przesun(rp, o)
    return rp


def lewa_loze(w_mod, mr, o=(0, 0, 0), szer=1.0, lokiec=None):
    """Lewa dłoń pod łożem. Wzorzec: łoże „Kwarca” szerokości 0,047 m, dłoń w y = 0.418.
    szer skaluje rozstaw dłoni w osi X dla grubszych łóż."""
    rl = w_mod.Siatka("reka_l", [mr["rekawica"], mr["wzm"], mr["rekaw"]])
    rl.segment((-0.040, 0.418, -0.050), (0.030, 0.418, -0.047), 0.094, 0.026, 0.090, 0.024, mr["rekawica"], gora=(0, 0, 1))
    for i in range(4):
        y = 0.383 + i * 0.0225
        palec(rl, [(0.027, y, -0.046), (0.0345, y, -0.006), (0.027, y, 0.019)], 0.0185 - (0.002 if i == 3 else 0.0), mr["rekawica"], gora=(0, 1, 0))
    palec(rl, [(-0.030, 0.392, -0.044), (-0.0345, 0.424, -0.010), (-0.029, 0.452, 0.008)], 0.021, mr["rekawica"], gora=(1, 0, 0))
    lk = lokiec if lokiec is not None else ((-0.170 - o[0]) / szer, 0.215 - o[1], -0.235 - o[2])
    przedramie(rl, (-0.046, 0.404, -0.060), lk, mr)
    _przesun(rl, o, skala=(szer, 1.0, 1.0))
    return rl


def prawa_pistolet(w_mod, mr, o=(0, 0, 0), nazwa="reka_p", lustro=False, lokiec=None):
    """Dłoń na chwycie pistoletu. Wzorzec: „Jaspis”, tył zamka w y = 0.
    lustro=True daje lewą dłoń zaciśniętą na chwycie przednim."""
    rp = w_mod.Siatka(nazwa, [mr["rekawica"], mr["wzm"], mr["rekaw"]])
    srodrecze(rp, (0.030, -0.066, -0.086), (0.0295, 0.036, -0.062), mr)
    for i, zz in enumerate((-0.062, -0.083, -0.103)):
        przes = i * 0.007
        palec(rp, [(0.029, 0.040 - przes, zz), (-0.004, 0.068 - przes, zz - 0.003), (-0.019, 0.044 - przes, zz - 0.005)], 0.0185, mr["wzm"])
    palec(rp, [(0.028, 0.040, -0.040), (0.0195, 0.086, -0.031), (0.0165, 0.118, -0.028)], 0.0175, mr["rekawica"])
    palec(rp, [(0.012, -0.030, -0.030), (-0.0175, 0.006, -0.024), (-0.0185, 0.044, -0.020)], 0.021, mr["rekawica"])
    rp.segment((0.020, -0.040, -0.040), (0.004, -0.016, -0.052), 0.034, 0.042, 0.030, 0.036, mr["rekawica"])
    lk = lokiec if lokiec is not None else (0.115, -0.330, -0.150)
    przedramie(rp, (0.033, -0.062, -0.082), lk, mr)
    _przesun(rp, o, lustro_x=lustro)
    return rp


def lewa_pistolet(w_mod, mr, o=(0, 0, 0)):
    """Lewa dłoń podtrzymująca przy chwycie oburącz. Wzorzec: „Jaspis”."""
    rl = w_mod.Siatka("reka_l", [mr["rekawica"], mr["wzm"], mr["rekaw"]])
    srodrecze(rl, (-0.031, -0.060, -0.104), (-0.031, 0.040, -0.074), mr, strona=-1)
    for i, zz in enumerate((-0.060, -0.081, -0.101, -0.119)):
        przes = i * 0.007
        palec(rl, [(-0.030, 0.046 - przes, zz), (0.004, 0.086 - przes, zz - 0.003), (0.034, 0.062 - przes, zz - 0.005)], 0.0185 - (0.002 if i == 3 else 0.0), mr["wzm"])
    palec(rl, [(-0.022, -0.012, -0.040), (-0.0195, 0.040, -0.024), (-0.0185, 0.082, -0.020)], 0.021, mr["rekawica"])
    przedramie(rl, (-0.034, -0.058, -0.100), (-0.150, -0.310, -0.175), mr)
    _przesun(rl, o)
    return rl
