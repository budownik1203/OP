"""Synteza dźwięków zastępczych do builda 1. Uruchom: python3 generuj.py
Wystrzały z syntezy są zadowalające najwyżej jako tymczasowe; docelowo
zastąpią je nagrania (CC0 lub kupiona paczka) o tych samych nazwach plików."""
import os
import wave

import numpy as np
from scipy import signal

SR = 44100
WYJ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "zasoby", "dzwiek")
los = np.random.default_rng(1203)


def t(sek):
    return np.arange(int(SR * sek)) / SR


def szum(sek):
    return los.standard_normal(int(SR * sek))


def filtr(x, dol=None, gora=None, rzad=2):
    if dol and gora:
        sos = signal.butter(rzad, [dol, gora], "bandpass", fs=SR, output="sos")
    elif dol:
        sos = signal.butter(rzad, dol, "highpass", fs=SR, output="sos")
    else:
        sos = signal.butter(rzad, gora, "lowpass", fs=SR, output="sos")
    return signal.sosfilt(sos, x)


def wygas(sek, tau):
    return np.exp(-t(sek) / tau)


def przesun(x, sek, dlugosc):
    out = np.zeros(int(SR * dlugosc))
    i = int(SR * sek)
    n = min(len(x), len(out) - i)
    out[i:i + n] += x[:n]
    return out


def zapisz(nazwa, x, szczyt=0.9):
    x = np.asarray(x, dtype=np.float64)
    zanik = int(SR * 0.004)
    x[-zanik:] *= np.linspace(1, 0, zanik)
    x = x / max(np.abs(x).max(), 1e-9) * szczyt
    os.makedirs(WYJ, exist_ok=True)
    with wave.open(os.path.join(WYJ, nazwa + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype("<i2").tobytes())
    rms = np.sqrt(np.mean(x ** 2))
    print(f"{nazwa:14s} {len(x) / SR:5.2f} s  szczyt {np.abs(x).max():.2f}  rms {rms:.3f}")


def strzal(dl, tau_ciala, f_dol, f_gora, dud0, dud1, tau_dud, ogon, echa):
    x = np.zeros(int(SR * dl))
    trzask = filtr(szum(0.004), dol=1800) * np.linspace(1, 0, int(SR * 0.004)) ** 0.5
    x += przesun(trzask * 1.6, 0.0, dl)
    cialo = filtr(szum(dl), f_dol, f_gora) * wygas(dl, tau_ciala)
    x += cialo * 1.3
    czas = t(dl)
    faza = 2 * np.pi * np.cumsum(dud1 + (dud0 - dud1) * np.exp(-czas / 0.03)) / SR
    x += np.sin(faza) * np.exp(-czas / tau_dud) * 1.1
    pogl = filtr(szum(dl), gora=1400) * wygas(dl, ogon) * 0.16
    pogl[: int(SR * 0.02)] *= np.linspace(0, 1, int(SR * 0.02))
    x += pogl
    for (op, moc) in echa:                       # odbicia od murów strzelnicy
        e = filtr(cialo[: int(SR * 0.12)], gora=2200) * moc
        x += przesun(e, op, dl)
    return np.tanh(x * 2.2)


def stuk(f, tau, dl=0.06, szum_moc=0.5):
    czas = t(dl)
    s = sum(np.sin(2 * np.pi * f * k * czas + los.random() * 6) / k for k in (1.0, 2.3, 3.7))
    return (s + filtr(szum(dl), dol=1500) * szum_moc) * np.exp(-czas / tau)


zapisz("strzal_556", strzal(0.95, 0.045, 250, 3800, 210, 55, 0.07, 0.28, [(0.07, 0.30), (0.13, 0.20), (0.21, 0.12)]))
zapisz("strzal_9", strzal(0.70, 0.030, 350, 3200, 260, 85, 0.045, 0.20, [(0.07, 0.24), (0.14, 0.14)]), 0.8)
zapisz("suchy", przesun(stuk(2100, 0.008, 0.05, 0.8), 0.0, 0.08), 0.5)
zapisz("klik", przesun(stuk(3200, 0.005, 0.04, 0.6), 0.0, 0.06), 0.4)

x = przesun(stuk(1500, 0.012, 0.06), 0.0, 0.35) + przesun(filtr(szum(0.16), 800, 3500) * np.hanning(int(SR * 0.16)) * 0.35, 0.05, 0.35) + przesun(stuk(900, 0.02, 0.07) * 0.7, 0.2, 0.35)
zapisz("mag_wyj", x, 0.6)
x = przesun(filtr(szum(0.14), 700, 3000) * np.linspace(0.2, 1, int(SR * 0.14)) * 0.3, 0.0, 0.34) + przesun(stuk(1100, 0.018, 0.08) * 1.2, 0.14, 0.34) + przesun(stuk(2600, 0.008, 0.04) * 0.6, 0.165, 0.34)
zapisz("mag_wl", x, 0.7)
x = przesun(stuk(1300, 0.014, 0.07), 0.0, 0.36) + przesun(filtr(szum(0.09), 1000, 4000) * 0.3 * np.hanning(int(SR * 0.09)), 0.02, 0.36) + przesun(stuk(1700, 0.016, 0.08) * 1.3, 0.13, 0.36)
zapisz("zamek", x, 0.75)
x = filtr(szum(0.3), 300, 2500) * np.hanning(int(SR * 0.3)) * 0.5 + przesun(stuk(700, 0.03, 0.08) * 0.5, 0.2, 0.3)
zapisz("bron_wyjmij", x, 0.4)

czas = t(0.9)                                    # trafienie w stal: nieharmoniczne składowe
dzwon = sum(a * np.sin(2 * np.pi * f * czas + los.random() * 6) * np.exp(-czas / tau)
            for f, a, tau in ((1180, 1.0, 0.22), (2950, 0.6, 0.14), (4710, 0.45, 0.09), (6890, 0.3, 0.05), (640, 0.4, 0.10)))
dzwon += przesun(filtr(szum(0.012), dol=2500) * 2.5 * np.linspace(1, 0, int(SR * 0.012)), 0.0, 0.9)
zapisz("stal", dzwon, 0.8)
x = filtr(szum(0.16), gora=700) * wygas(0.16, 0.03) + filtr(szum(0.16), 1500, 5000) * wygas(0.16, 0.012) * 0.4
zapisz("uderzenie", x, 0.6)
czas = t(0.42)
f = 3400 * np.exp(-czas / 0.33) + 500 + 60 * np.sin(2 * np.pi * 31 * czas)
x = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-czas / 0.16) + filtr(szum(0.42), dol=3000) * np.exp(-czas / 0.03) * 0.5
zapisz("rykoszet", x, 0.55)
x = filtr(szum(0.2), gora=260) * wygas(0.2, 0.035) * 1.6
ziarna = np.zeros(int(SR * 0.2))
for i in range(22):
    p = int(los.uniform(0.005, 0.13) * SR)
    ziarna[p:p + 90] += filtr(szum(0.01), dol=2200)[:90] * los.uniform(0.1, 0.45)
zapisz("krok", x + ziarna * wygas(0.2, 0.06), 0.55)
x = sum(przesun(stuk(los.uniform(500, 900), 0.012, 0.05) * m, o, 0.4) for o, m in ((0.0, 1.0), (0.11, 0.6), (0.19, 0.35), (0.24, 0.2)))
zapisz("mag_ziemia", x, 0.5)

# ---------------------------------------------------------------- build 2: wrogowie i rany
czas = t(0.9)
f0 = 78 + 26 * np.sin(2 * np.pi * 2.3 * czas) + 14 * np.sin(2 * np.pi * 7.1 * czas)
zrodlo = signal.sawtooth(2 * np.pi * np.cumsum(f0) / SR) + szum(0.9) * 0.6
ryk = filtr(zrodlo, 280, 900) * 1.2 + filtr(zrodlo, 1100, 2100) * 0.5 + filtr(szum(0.9), 2500, 5000) * 0.12
zapisz("ghul_ryk", ryk * np.hanning(len(czas)) ** 0.6 * (1 + 0.5 * np.sin(2 * np.pi * 19 * czas)), 0.7)
czas = t(1.3)
f0 = 62 + 8 * np.sin(2 * np.pi * 0.9 * czas)
zrodlo = signal.sawtooth(2 * np.pi * np.cumsum(f0) / SR) * 0.7 + szum(1.3) * 0.5
zapisz("trup_jek", (filtr(zrodlo, 180, 620) + filtr(zrodlo, 800, 1300) * 0.3) * np.hanning(len(czas)), 0.55)
x = filtr(szum(0.18), gora=420) * wygas(0.18, 0.04) * 1.5 + filtr(szum(0.18), 900, 3200) * wygas(0.18, 0.02) * 0.7
zapisz("cialo", x, 0.6)
x = filtr(szum(0.45), gora=220) * wygas(0.45, 0.07) * 2.0 + przesun(filtr(szum(0.2), 500, 2500) * wygas(0.2, 0.05) * 0.4, 0.05, 0.45)
zapisz("cialo_upadek", x, 0.7)
x = filtr(szum(0.22), gora=350) * wygas(0.22, 0.05) * 2.0 + filtr(szum(0.22), 1200, 4500) * wygas(0.22, 0.025)
zapisz("cios", x, 0.85)
czas = t(0.28)
x = filtr(szum(0.28), 600, 5000) * np.hanning(len(czas)) ** 2
zapisz("swist", x * (0.5 + 0.5 * np.sin(2 * np.pi * 3 * czas)), 0.45)
x = sum(przesun(stuk(los.uniform(1400, 3200), 0.02, 0.07) * m, o, 0.3) for o, m in ((0.0, 1.0), (0.05, 0.6), (0.12, 0.4))) + filtr(szum(0.3), gora=200) * wygas(0.3, 0.05)
zapisz("zbroja", x, 0.5)
x = filtr(szum(0.8), 1500, 6000) * (0.3 + 0.7 * np.abs(np.sin(2 * np.pi * 2.2 * t(0.8)))) * np.hanning(int(SR * 0.8))
zapisz("lek", x, 0.3)

# ---------------- build 4
czas = t(2.4)
x = (np.sin(2 * np.pi * 38 * czas) + 0.6 * np.sin(2 * np.pi * 51 * czas + 1.0)) * (0.6 + 0.4 * np.sin(2 * np.pi * 0.9 * czas)) + filtr(szum(2.4), gora=120) * 1.5
zapisz("dudnienie", x * np.hanning(len(czas)), 0.8)

# ---------------- build 5: nowa broń i narzędzia
zapisz("strzal_45", strzal(0.75, 0.034, 250, 2600, 200, 70, 0.055, 0.22, [(0.07, 0.24), (0.14, 0.14)]), 0.85)
zapisz("strzal_762", strzal(1.0, 0.050, 200, 3200, 180, 48, 0.08, 0.30, [(0.07, 0.30), (0.13, 0.20), (0.21, 0.12)]))
zapisz("strzal_76251", strzal(1.25, 0.060, 160, 3000, 160, 40, 0.10, 0.40, [(0.08, 0.34), (0.15, 0.24), (0.24, 0.16), (0.36, 0.08)]))
zapisz("strzal_12", strzal(1.1, 0.070, 120, 2200, 150, 38, 0.11, 0.34, [(0.07, 0.30), (0.14, 0.2), (0.22, 0.12)]))
x = przesun(filtr(szum(0.12), 500, 2500) * np.linspace(0.3, 1, int(SR * 0.12)) * 0.5, 0.0, 0.42) + przesun(stuk(800, 0.02, 0.08) * 1.2, 0.11, 0.42) + przesun(filtr(szum(0.1), 500, 2500) * 0.4 * np.hanning(int(SR * 0.1)), 0.2, 0.42) + przesun(stuk(1000, 0.02, 0.08) * 1.3, 0.29, 0.42)
zapisz("czolenko", x, 0.75)
czas = t(0.5)
x = sum(a * np.sin(2 * np.pi * f * czas + los.random() * 6) * np.exp(-czas / tau) for f, a, tau in ((2300, 1.0, 0.05), (3900, 0.6, 0.03), (5600, 0.4, 0.02), (700, 0.5, 0.03)))
x += przesun(filtr(szum(0.25), gora=500) * wygas(0.25, 0.05), 0.0, 0.5) + przesun(filtr(szum(0.3), 800, 3000) * wygas(0.3, 0.08) * 0.3, 0.05, 0.5)
zapisz("kilof", x, 0.8)
