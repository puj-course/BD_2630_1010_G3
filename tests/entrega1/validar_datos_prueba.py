#!/usr/bin/env python3
# =============================================================================
#  Validacion offline del dataset de prueba - Entrega 1
#  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
#
#  Lee sql/entrega1/dml/carga_datos_prueba.sql y comprueba que los datos
#  respetan TODAS las restricciones del DDL antes de intentar cargarlos, sin
#  necesidad de conexion al servidor.
#
#  Incluye tambien las reglas que Oracle NO puede declarar (Seccion 7 del DDL):
#  exactamente dos participaciones por partido, partido dentro del rango de
#  fechas de su edicion, y coincidencia de edicion entre partido, estadio y
#  seleccion. Esas son justamente las que un CHECK no puede vigilar, asi que
#  validarlas aqui es la unica red de seguridad previa a la carga.
#
#  Uso:  python3 tests/entrega1/validar_datos_prueba.py
#  Salida esperada: "TODAS LAS RESTRICCIONES DEL DDL SE CUMPLEN"
# =============================================================================

import re, sys, collections, datetime, pathlib

RUTA = pathlib.Path(__file__).resolve().parents[2] / "sql" / "entrega1" / "dml" / "carga_datos_prueba.sql"
sql = RUTA.read_text(encoding="utf-8")

ed, est, sel, par = {}, {}, {}, {}
pp = collections.defaultdict(list)

for m in re.finditer(r"INSERT INTO edicion_mundial .*?VALUES \((\d+), (\d+), '(.*?)', '(.*?)', DATE '(.*?)', DATE '(.*?)'\);", sql):
    i, a, _, _, fi, ff = m.groups()
    ed[int(i)] = (int(a), datetime.date.fromisoformat(fi), datetime.date.fromisoformat(ff))
for m in re.finditer(r"INSERT INTO estadio .*?VALUES \((\d+), (\d+), '(.*?)', '(.*?)', (\d+)\);", sql):
    i, e, n, c, cap = m.groups(); est[int(i)] = (int(e), n, c, int(cap))
for m in re.finditer(r"INSERT INTO seleccion .*?VALUES \((\d+), (\d+), '(.*?)', '(.*?)', '(.*?)'\);", sql):
    i, e, p, cf, g = m.groups(); sel[int(i)] = (int(e), p, cf, g)
for m in re.finditer(r"INSERT INTO partido .*?VALUES \((\d+), (\d+), (\d+), TIMESTAMP '(.*?)', '(.*?)', (\d+)\);", sql):
    i, e, s, t, f, asi = m.groups(); par[int(i)] = (int(e), int(s), t, f, int(asi))
for m in re.finditer(r"INSERT INTO participacion_partido .*?VALUES \((\d+), (\d+), (\d+), '(.*?)', (\d+)\);", sql):
    i, p, s, c, g = m.groups(); pp[int(p)].append((int(s), c, int(g)))

FASES = {"Fase de Grupos", "Dieciseisavos", "Octavos", "Cuartos",
         "Semifinal", "Tercer Puesto", "Final"}
CONFEDERACIONES = {"CONMEBOL", "UEFA", "CAF", "AFC", "CONCACAF", "OFC"}

err = []
def chk(cond, msg):
    if not cond:
        err.append(msg)

# --- Volumen minimo exigido por el enunciado --------------------------------
for tabla, d in (("ESTADIO", est), ("SELECCION", sel), ("PARTIDO", par)):
    chk(len(d) >= 100, f"{tabla} tiene {len(d)} filas, se exigen 100")
chk(sum(len(v) for v in pp.values()) >= 100, "PARTICIPACION_PARTIDO por debajo de 100 filas")

# --- R1: exactamente dos participaciones, un local y un visitante -----------
for pid in par:
    v = pp.get(pid, [])
    if len(v) != 2:
        err.append(f"partido {pid}: {len(v)} participaciones, se esperan 2"); continue
    if sorted(x[1] for x in v) != ["LOCAL", "VISITANTE"]:
        err.append(f"partido {pid}: condiciones {[x[1] for x in v]}")
    if v[0][0] == v[1][0]:
        err.append(f"partido {pid}: una seleccion se enfrenta a si misma")

# --- UQ_PARTIDO_ESTADIO_FECHA: sin cruce de agenda --------------------------
for k, c in collections.Counter((p[1], p[2]) for p in par.values()).items():
    chk(c == 1, f"cruce de agenda en estadio/fecha {k} ({c} partidos)")

# --- R2 y R3, y coherencia de asistencia ------------------------------------
for pid, (e, s, t, f, asi) in par.items():
    d = datetime.date.fromisoformat(t.split()[0])
    chk(ed[e][1] <= d <= ed[e][2], f"partido {pid} fuera del rango de su edicion ({d})")
    chk(est[s][0] == e, f"partido {pid}: el estadio pertenece a otra edicion")
    chk(asi <= est[s][3], f"partido {pid}: asistencia {asi} supera el aforo {est[s][3]}")
    chk(f in FASES, f"partido {pid}: fase invalida '{f}'")
    for sid, cond, goles in pp[pid]:
        chk(sel[sid][0] == e, f"partido {pid}: la seleccion {sid} pertenece a otra edicion")
        chk(0 <= goles <= 30, f"partido {pid}: goles fuera de rango ({goles})")
    if f != "Fase de Grupos":
        g = [x[2] for x in pp[pid]]
        chk(g[0] != g[1], f"partido {pid}: empate en fase eliminatoria ({f})")

# --- Unicidad y dominios ----------------------------------------------------
for k, n in collections.Counter((v[0], v[1]) for v in sel.values()).items():
    chk(n == 1, f"pais duplicado dentro de la edicion: {k}")
for k, n in collections.Counter((v[0], v[1]) for v in est.values()).items():
    chk(n == 1, f"nombre de estadio duplicado dentro de la edicion: {k}")
chk(all(v[2] in CONFEDERACIONES for v in sel.values()), "confederacion fuera del dominio")
chk(all("A" <= v[3] <= "L" for v in sel.values()), "grupo fuera del rango A-L")
chk(all(20000 <= v[3] <= 150000 for v in est.values()), "capacidad fuera del rango permitido")
chk(len({v[0] for v in ed.values()}) == len(ed), "anio de edicion duplicado")
chk(all(13 <= (v[2] - v[1]).days <= 60 for v in ed.values()), "duracion de edicion fuera de rango")

# --- Informe ----------------------------------------------------------------
print(f"EDICION_MUNDIAL        {len(ed):>6}")
print(f"ESTADIO                {len(est):>6}")
print(f"SELECCION              {len(sel):>6}")
print(f"PARTIDO                {len(par):>6}")
print(f"PARTICIPACION_PARTIDO  {sum(len(v) for v in pp.values()):>6}")
print()
if err:
    print(f"FALLOS DETECTADOS: {len(err)}")
    for e in err[:30]:
        print("  -", e)
    sys.exit(1)
print("TODAS LAS RESTRICCIONES DEL DDL SE CUMPLEN")
