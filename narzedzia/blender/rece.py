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
