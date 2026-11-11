"""Wspólne narzędzia do budowania modeli skryptami w Blenderze.

Układ: X w prawo, Y do przodu (w stronę wylotu lufy), Z w górę, metry.
Styl: hybryda fasetowa. Płaskie ścianki, małe tekstury bez wygładzania,
gęstość tekstur stała dzięki rzutowaniu sześciennemu.
"""
import math
import os

import bpy  # musi być przed bmesh
import bmesh
import numpy as np
from mathutils import Matrix, Vector
from PIL import Image

KATALOG = os.path.dirname(os.path.abspath(__file__))
TEKSTURY = os.path.join(KATALOG, "..", "..", "zasoby", "tekstury")
MODELE = os.path.join(KATALOG, "..", "..", "zasoby", "modele")


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


# ---------------------------------------------------------------- tekstury

def _szum(rozmiar, skala, ziarno):
    """Szum kafelkowalny: biały szum przefiltrowany w dziedzinie częstotliwości."""
    los = np.random.default_rng(ziarno)
    bialy = los.standard_normal((rozmiar, rozmiar))
    f = np.fft.fft2(bialy)
    fx = np.fft.fftfreq(rozmiar)[:, None]
    fy = np.fft.fftfreq(rozmiar)[None, :]
    promien = np.sqrt(fx * fx + fy * fy)
    filtr = np.exp(-(promien * skala) ** 2)
    wynik = np.real(np.fft.ifft2(f * filtr))
    wynik -= wynik.min()
    wynik /= max(wynik.max(), 1e-9)
    return wynik


def tekstura(nazwa, paleta, rozmiar=64, skala=6.0, ziarno=1, drobny=0.25, progi=None, rysy=0.0):
    """Tworzy PNG: szum skwantowany do palety. paleta: lista kolorów '#rrggbb'.
    progi: granice udziału kolorów (rosnące, 0..1); domyślnie równe przedziały.
    rysy: udział jasnych przetarć (ostatni kolor palety) jako pojedyncze piksele."""
    os.makedirs(TEKSTURY, exist_ok=True)
    a = _szum(rozmiar, skala, ziarno)
    b = _szum(rozmiar, skala / 5.0, ziarno + 100)
    w = a * (1.0 - drobny) + b * drobny
    # wyrównanie histogramu, żeby progi oznaczały udział powierzchni
    kolejnosc = np.argsort(w.ravel())
    rangi = np.empty_like(kolejnosc)
    rangi[kolejnosc] = np.arange(w.size)
    w = (rangi / (w.size - 1)).reshape(w.shape)
    n = len(paleta) - (1 if rysy > 0 else 0)
    if progi is None:
        progi = [(i + 1) / n for i in range(n - 1)]
    indeks = np.zeros(w.shape, dtype=int)
    for p in progi:
        indeks += (w > p).astype(int)
    kolory = np.array([[int(c[i:i + 2], 16) for i in (1, 3, 5)] for c in paleta], dtype=np.uint8)
    obraz = kolory[indeks]
    if rysy > 0:
        los = np.random.default_rng(ziarno + 7)
        maska = los.random(w.shape) < rysy
        obraz[maska] = kolory[-1]
    sciezka = os.path.join(TEKSTURY, nazwa + ".png")
    Image.fromarray(obraz, "RGB").save(sciezka)
    return sciezka


def material(nazwa, sciezka_png, szorstkosc=0.8, metal=0.0):
    m = bpy.data.materials.new(nazwa)
    m.use_nodes = True
    wezly = m.node_tree.nodes
    bsdf = wezly["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = szorstkosc
    bsdf.inputs["Metallic"].default_value = metal
    tex = wezly.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(os.path.abspath(sciezka_png))
    tex.interpolation = "Closest"
    m.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    return m


# ---------------------------------------------------------------- geometria

class Siatka:
    """Zbiera bryły jednego obiektu. Każda bryła dostaje indeks materiału."""

    def __init__(self, nazwa, materialy):
        self.nazwa = nazwa
        self.materialy = materialy          # lista materiałów Blendera
        self.bm = bmesh.new()

    def _mat(self, m):
        return self.materialy.index(m)

    def _sciany(self, wierzcholki, sciany, m, gladkie=None):
        vs = [self.bm.verts.new(Vector(v)) for v in wierzcholki]
        for i, s in enumerate(sciany):
            try:
                f = self.bm.faces.new([vs[j] for j in s])
            except ValueError:
                continue
            f.material_index = self._mat(m)
            if gladkie and i in gladkie:
                f.smooth = True
        return vs

    def pudlo(self, a, b, m):
        """Prostopadłościan od narożnika a do b."""
        (x0, y0, z0), (x1, y1, z1) = a, b
        x0, x1 = min(x0, x1), max(x0, x1)
        y0, y1 = min(y0, y1), max(y0, y1)
        z0, z1 = min(z0, z1), max(z0, z1)
        v = [(x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0),
             (x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)]
        s = [(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]
        self._sciany(v, s, m)

    def segment(self, p0, p1, w0, h0, w1, h1, m, gora=(0, 0, 1), boki=4, gladki=False, skret=0.0):
        """Zwężający się odcinek od p0 do p1. Przekrój: prostokąt (boki=4)
        albo wielokąt wpisany w elipsę. w = szerokość, h = wysokość przekroju."""
        p0, p1 = Vector(p0), Vector(p1)
        os_ = (p1 - p0).normalized()
        g = Vector(gora)
        bok = os_.cross(g)
        if bok.length < 1e-5:
            bok = os_.cross(Vector((1, 0, 0)))
        bok.normalize()
        g = bok.cross(os_).normalized()
        v = []
        for (p, w, h) in ((p0, w0, h0), (p1, w1, h1)):
            for i in range(boki):
                if boki == 4:
                    kx = (-0.5, 0.5, 0.5, -0.5)[i]
                    ky = (-0.5, -0.5, 0.5, 0.5)[i]
                else:
                    kat = 2 * math.pi * (i + 0.5) / boki + skret
                    kx = 0.5 * math.cos(kat)
                    ky = 0.5 * math.sin(kat)
                v.append(p + bok * (kx * w) + g * (ky * h))
        s = []
        for i in range(boki):
            j = (i + 1) % boki
            s.append((i, j, boki + j, boki + i))
        n_bok = len(s)
        s.append(tuple(reversed(range(boki))))
        s.append(tuple(range(boki, 2 * boki)))
        self._sciany(v, s, m, gladkie=set(range(n_bok)) if gladki else None)

    def walec(self, p0, p1, r, m, n=10, r1=None, gladki=True):
        r1 = r if r1 is None else r1
        self.segment(p0, p1, 2 * r, 2 * r, 2 * r1, 2 * r1, m, boki=n, gladki=gladki)

    def profil(self, punkty, os_, a0, a1, m):
        """Wielokąt 2D wyciągnięty wzdłuż osi.
        os_='x': punkty to (y, z); os_='y': punkty to (x, z); os_='z': punkty to (x, y)."""
        def w3(p, a):
            if os_ == "x":
                return (a, p[0], p[1])
            if os_ == "y":
                return (p[0], a, p[1])
            return (p[0], p[1], a)
        n = len(punkty)
        v = [w3(p, a0) for p in punkty] + [w3(p, a1) for p in punkty]
        s = [(i, (i + 1) % n, n + (i + 1) % n, n + i) for i in range(n)]
        s.append(tuple(reversed(range(n))))
        s.append(tuple(range(n, 2 * n)))
        self._sciany(v, s, m)

    def obiekt(self, faza=0.0012, gestosc=640.0, rodzic=None, poczatek=None):
        """Zamyka siatkę: normalne, faza krawędzi, UV sześcienne, obiekt w scenie.
        poczatek: punkt obrotu segmentu (staw) we współrzędnych świata."""
        bm = self.bm
        if poczatek is not None:
            bmesh.ops.translate(bm, verts=bm.verts, vec=-Vector(poczatek))
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-6)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        mesh = bpy.data.meshes.new(self.nazwa)
        bm.to_mesh(mesh)
        bm.free()
        for m in self.materialy:
            mesh.materials.append(m)
        ob = bpy.data.objects.new(self.nazwa, mesh)
        bpy.context.scene.collection.objects.link(ob)
        if faza > 0:
            mod = ob.modifiers.new("faza", "BEVEL")
            mod.width = faza
            mod.segments = 1
            mod.limit_method = "ANGLE"
            mod.angle_limit = math.radians(50)
            mod.harden_normals = False
            bpy.context.view_layer.objects.active = ob
            ob.select_set(True)
            bpy.ops.object.modifier_apply(modifier="faza")
            ob.select_set(False)
        _uv_szescienne(ob.data, gestosc)
        swiat = Vector(poczatek) if poczatek is not None else Vector((0, 0, 0))
        ob["swiat"] = tuple(swiat)
        if rodzic is not None:
            ob.parent = rodzic
            swiat = swiat - Vector(rodzic.get("swiat", (0, 0, 0)))
        ob.location = swiat
        return ob


def _uv_szescienne(mesh, gestosc):
    """UV z rzutu na dominującą oś normalnej. gestosc = teksele na metr / 64."""
    uv = mesh.uv_layers.new(name="UVMap")
    skala = gestosc / 64.0
    for poly in mesh.polygons:
        n = poly.normal
        osie = (abs(n.x), abs(n.y), abs(n.z))
        dom = osie.index(max(osie))
        for li in poly.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            if dom == 0:
                u, v = co.y, co.z
            elif dom == 1:
                u, v = co.x, co.z
            else:
                u, v = co.x, co.y
            uv.data[li].uv = (u * skala, v * skala)


def pusty(nazwa, pozycja, rodzic=None):
    ob = bpy.data.objects.new(nazwa, None)
    ob["swiat"] = tuple(pozycja)
    ob.location = Vector(pozycja) - (Vector(rodzic.get("swiat", (0, 0, 0))) if rodzic is not None else Vector((0, 0, 0)))
    ob.empty_display_size = 0.02
    bpy.context.scene.collection.objects.link(ob)
    if rodzic is not None:
        ob.parent = rodzic
    return ob


def eksport(nazwa):
    os.makedirs(MODELE, exist_ok=True)
    sciezka = os.path.abspath(os.path.join(MODELE, nazwa + ".glb"))
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=sciezka, export_format="GLB", export_yup=True,
                              export_apply=True, export_normals=True, export_materials="EXPORT",
                              export_image_format="AUTO", use_selection=False)
    trojkaty = 0
    for ob in bpy.data.objects:
        if ob.type == "MESH":
            ob.data.calc_loop_triangles()
            trojkaty += len(ob.data.loop_triangles)
    print("EKSPORT", sciezka, "trojkaty:", trojkaty)
    return sciezka
