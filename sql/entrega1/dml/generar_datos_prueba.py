#!/usr/bin/env python3
# =============================================================================
#  Generador del dataset sintetico de prueba - Entrega 1
#  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
#
#  Produce sql/entrega1/dml/carga_datos_prueba.sql
#
#  Por que un generador y no INSERTs escritos a mano:
#  el enunciado exige un minimo de 100 registros por tabla principal Y
#  coherencia logica plena entre edicion, estadio, seleccion, partido y
#  participacion. Escribir a mano ~2.000 filas que respeten simultaneamente
#  todas las restricciones del DDL (rango de fechas de la edicion, unicidad de
#  agenda por estadio, exactamente dos participaciones por partido, un unico
#  local y un unico visitante, coincidencia de edicion entre partido, estadio y
#  seleccion) es inviable y practicamente garantiza errores.
#
#  La semilla esta fijada, de modo que el script es reproducible: ejecutarlo dos
#  veces produce exactamente el mismo archivo SQL.
#
#  Uso:  python3 generar_datos_prueba.py
# =============================================================================

import random
from datetime import date, timedelta

SEMILLA = 20260828
random.seed(SEMILLA)

SALIDA = "carga_datos_prueba.sql"

# -----------------------------------------------------------------------------
#  Catalogos base
# -----------------------------------------------------------------------------

# Paises con su confederacion FIFA. Los nombres de pais son informacion publica;
# los resultados que se generan mas abajo son enteramente sinteticos.
PAISES = [
    ("Brasil", "CONMEBOL"), ("Argentina", "CONMEBOL"), ("Uruguay", "CONMEBOL"),
    ("Colombia", "CONMEBOL"), ("Chile", "CONMEBOL"), ("Peru", "CONMEBOL"),
    ("Ecuador", "CONMEBOL"), ("Paraguay", "CONMEBOL"), ("Bolivia", "CONMEBOL"),
    ("Venezuela", "CONMEBOL"),
    ("Alemania", "UEFA"), ("Francia", "UEFA"), ("Espana", "UEFA"),
    ("Italia", "UEFA"), ("Inglaterra", "UEFA"), ("Portugal", "UEFA"),
    ("Paises Bajos", "UEFA"), ("Belgica", "UEFA"), ("Croacia", "UEFA"),
    ("Suiza", "UEFA"), ("Dinamarca", "UEFA"), ("Polonia", "UEFA"),
    ("Suecia", "UEFA"), ("Serbia", "UEFA"), ("Austria", "UEFA"),
    ("Escocia", "UEFA"), ("Noruega", "UEFA"), ("Chequia", "UEFA"),
    ("Marruecos", "CAF"), ("Senegal", "CAF"), ("Nigeria", "CAF"),
    ("Egipto", "CAF"), ("Camerun", "CAF"), ("Ghana", "CAF"),
    ("Tunez", "CAF"), ("Argelia", "CAF"), ("Costa de Marfil", "CAF"),
    ("Mali", "CAF"),
    ("Japon", "AFC"), ("Corea del Sur", "AFC"), ("Iran", "AFC"),
    ("Australia", "AFC"), ("Arabia Saudita", "AFC"), ("Catar", "AFC"),
    ("Irak", "AFC"), ("Uzbekistan", "AFC"),
    ("Mexico", "CONCACAF"), ("Estados Unidos", "CONCACAF"),
    ("Canada", "CONCACAF"), ("Costa Rica", "CONCACAF"),
    ("Panama", "CONCACAF"), ("Honduras", "CONCACAF"), ("Jamaica", "CONCACAF"),
    ("Nueva Zelanda", "OFC"), ("Islas Salomon", "OFC"), ("Fiyi", "OFC"),
]

# Nombres de estadio y ciudad. Se combinan con el anio de la edicion para
# garantizar la unicidad exigida por UQ_ESTADIO_EDICION_NOMBRE.
ESTADIOS_BASE = [
    ("Arena Amazonia", "Manaos"), ("Arena Boreal", "Reikiavik"),
    ("Arena Cascada", "Iguazu"), ("Arena Central", "Bratislava"),
    ("Arena Costera", "Valparaiso"), ("Arena del Delta", "Rosario"),
    ("Arena del Golfo", "Doha"), ("Arena del Istmo", "Colon"),
    ("Arena del Norte", "Trondheim"), ("Arena del Puerto", "Hamburgo"),
    ("Arena del Valle", "Cochabamba"), ("Arena Meridiana", "Cordoba"),
    ("Campo de las Naciones", "Lisboa"), ("Coliseo Andino", "Quito"),
    ("Coliseo del Sur", "Punta Arenas"), ("Coliseo Ecuatorial", "Kampala"),
    ("Estadio Altamar", "Vigo"), ("Estadio Amanecer", "Osaka"),
    ("Estadio Bicentenario", "Asuncion"), ("Estadio Cordillera", "La Paz"),
    ("Estadio de la Bahia", "Cartagena"), ("Estadio de la Sabana", "Tunja"),
    ("Estadio del Bosque", "Helsinki"), ("Estadio del Lago", "Ginebra"),
    ("Estadio del Meridiano", "Greenwich"), ("Estadio Esmeralda", "Muzo"),
    ("Estadio Horizonte", "Perth"), ("Estadio Kalahari", "Gaborone"),
    ("Estadio Litoral", "Montevideo"), ("Estadio Llanero", "Villavicencio"),
    ("Estadio Monsoon", "Bombay"), ("Estadio Nevado", "Zermatt"),
    ("Estadio Pampa", "Bahia Blanca"), ("Estadio Sahariano", "Uarzazate"),
    ("Estadio Solar", "Antofagasta"), ("Estadio Tundra", "Yakutsk"),
]

# Ediciones a generar. Ocho ediciones permiten superar holgadamente el minimo de
# 100 registros en ESTADIO, SELECCION, PARTIDO y PARTICIPACION_PARTIDO.
# EDICION_MUNDIAL se queda en 8 filas por la propia naturaleza de la tabla: la
# Copa Mundial se ha disputado 22 veces en toda su historia, de modo que exigirle
# 100 registros seria inventar ediciones inexistentes. El enunciado contempla
# esta salvedad ("cuando aplique segun la naturaleza de la tabla").
EDICIONES = [
    (1, 1994, "Estados Unidos",              "El futbol conquista un continente"),
    (2, 1998, "Francia",                     "La fiesta de la diversidad"),
    (3, 2002, "Corea del Sur y Japon",       "Dos naciones, un solo sueno"),
    (4, 2006, "Alemania",                    "El mundo entre amigos"),
    (5, 2010, "Sudafrica",                   "El eco del continente"),
    (6, 2014, "Brasil",                      "Late el corazon del futbol"),
    (7, 2018, "Rusia",                       "Del este nace la pasion"),
    (8, 2022, "Catar",                       "Ahora es el momento"),
]

LETRAS_GRUPO = "ABCDEFGH"          # 8 grupos de 4 selecciones = 32 por edicion
HORAS = [13, 16, 19, 22]           # franjas horarias de programacion

# -----------------------------------------------------------------------------
#  Acumuladores
# -----------------------------------------------------------------------------
filas_edicion, filas_estadio, filas_seleccion = [], [], []
filas_partido, filas_participacion = [], []

id_estadio = id_seleccion = id_partido = id_participacion = 0


def escapar(txt):
    """Duplica la comilla simple, que es como Oracle escapa dentro de un literal."""
    return txt.replace("'", "''")


def marcador(favorito):
    """Marcador sintetico. 'favorito' inclina la distribucion sin determinarla."""
    base = [0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 4, 5]
    a = random.choice(base) + (1 if favorito and random.random() < 0.45 else 0)
    b = random.choice(base)
    return min(a, 7), min(b, 7)


for id_edicion, anio, pais_sede, lema in EDICIONES:
    # --- Edicion -------------------------------------------------------------
    # Ventana de 33 dias: dentro del rango 13-60 que exige CK_EDICION_DURACION.
    inicio = date(anio, 6, 10)
    fin = inicio + timedelta(days=33)
    filas_edicion.append(
        f"INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin) "
        f"VALUES ({id_edicion}, {anio}, '{escapar(pais_sede)}', '{escapar(lema)}', "
        f"DATE '{inicio}', DATE '{fin}');"
    )

    # --- Estadios ------------------------------------------------------------
    # 32 estadios por edicion. El anio se anade al nombre para respetar
    # UQ_ESTADIO_EDICION_NOMBRE y, a la vez, dejar claro que la fila representa
    # "el estadio tal como fue inscrito en esta edicion".
    estadios_edicion = []
    for nombre, ciudad in ESTADIOS_BASE[:32]:
        id_estadio += 1
        # Capacidad dentro del rango 20.000-150.000 de CK_ESTADIO_CAPACIDAD.
        capacidad = random.choice([32000, 38000, 41000, 45000, 48000, 52000,
                                   56000, 61000, 65000, 68000, 72000, 78000,
                                   84000, 88000, 92000])
        estadios_edicion.append((id_estadio, capacidad))
        filas_estadio.append(
            f"INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) "
            f"VALUES ({id_estadio}, {id_edicion}, '{escapar(nombre)} {anio}', "
            f"'{escapar(ciudad)}', {capacidad});"
        )

    # --- Selecciones ---------------------------------------------------------
    # 32 paises distintos por edicion, repartidos en 8 grupos de 4.
    # UQ_SELECCION_EDICION_PAIS obliga a que no se repita ningun pais.
    elegidos = random.sample(PAISES, 32)
    grupos = {g: [] for g in LETRAS_GRUPO}
    for i, (pais, conf) in enumerate(elegidos):
        id_seleccion += 1
        grupo = LETRAS_GRUPO[i // 4]
        grupos[grupo].append(id_seleccion)
        filas_seleccion.append(
            f"INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) "
            f"VALUES ({id_seleccion}, {id_edicion}, '{escapar(pais)}', '{conf}', '{grupo}');"
        )

    # Agenda: se lleva registro de (estadio, fecha_hora) ya usados para no
    # violar UQ_PARTIDO_ESTADIO_FECHA.
    agenda_ocupada = set()
    turno_estadio = 0

    def programar(dia_offset, fase, id_local, id_visitante, permitir_empate):
        """Crea un partido y sus dos participaciones respetando el DDL."""
        global id_partido, id_participacion, turno_estadio

        # Busca una combinacion estadio/hora libre en el dia indicado.
        for _ in range(len(estadios_edicion) * len(HORAS)):
            est, capacidad = estadios_edicion[turno_estadio % len(estadios_edicion)]
            turno_estadio += 1
            hora = HORAS[turno_estadio % len(HORAS)]
            momento = inicio + timedelta(days=dia_offset)
            clave = (est, momento, hora)
            if clave not in agenda_ocupada:
                agenda_ocupada.add(clave)
                break
        else:
            raise RuntimeError("Sin franja libre: agenda saturada")

        id_partido += 1
        # La asistencia nunca supera el aforo; el 60-99 % es un rango realista.
        asistencia = int(capacidad * random.uniform(0.60, 0.99))
        filas_partido.append(
            f"INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada) "
            f"VALUES ({id_partido}, {id_edicion}, {est}, "
            f"TIMESTAMP '{momento} {hora:02d}:00:00', '{fase}', {asistencia});"
        )

        gl, gv = marcador(favorito=True)
        # En fase eliminatoria no puede haber empate: se resuelve el marcador.
        while not permitir_empate and gl == gv:
            gl, gv = marcador(favorito=True)

        for id_sel, cond, goles in ((id_local, "LOCAL", gl),
                                    (id_visitante, "VISITANTE", gv)):
            id_participacion += 1
            filas_participacion.append(
                f"INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados) "
                f"VALUES ({id_participacion}, {id_partido}, {id_sel}, '{cond}', {goles});"
            )
        return gl, gv

    # --- Fase de grupos: todos contra todos dentro de cada grupo -------------
    puntos = {}
    difgol = {}
    dia = 0
    for g in LETRAS_GRUPO:
        eq = grupos[g]
        for x in range(4):
            for y in range(x + 1, 4):
                gl, gv = programar(dia % 14, "Fase de Grupos", eq[x], eq[y], True)
                for sid, gf, gc in ((eq[x], gl, gv), (eq[y], gv, gl)):
                    puntos[sid] = puntos.get(sid, 0) + (3 if gf > gc else 1 if gf == gc else 0)
                    difgol[sid] = difgol.get(sid, 0) + (gf - gc)
                dia += 1

    # --- Eliminatorias: clasifican los dos primeros de cada grupo ------------
    clasificados = []
    for g in LETRAS_GRUPO:
        orden = sorted(grupos[g], key=lambda s: (-puntos.get(s, 0), -difgol.get(s, 0)))
        clasificados.extend(orden[:2])

    def ronda(equipos, fase, dia_base):
        ganadores, perdedores = [], []
        for i in range(0, len(equipos), 2):
            gl, gv = programar(dia_base, fase, equipos[i], equipos[i + 1], False)
            if gl > gv:
                ganadores.append(equipos[i]);   perdedores.append(equipos[i + 1])
            else:
                ganadores.append(equipos[i + 1]); perdedores.append(equipos[i])
        return ganadores, perdedores

    octavos, _   = ronda(clasificados, "Octavos",   17)
    cuartos, _   = ronda(octavos,      "Cuartos",   21)
    finalistas, eliminados = ronda(cuartos, "Semifinal", 25)
    ronda(eliminados,  "Tercer Puesto", 29)
    ronda(finalistas,  "Final",         31)


# -----------------------------------------------------------------------------
#  Emision del script SQL
# -----------------------------------------------------------------------------
with open(SALIDA, "w", encoding="utf-8") as f:
    w = f.write
    w("-- " + "=" * 76 + "\n")
    w("--  Entrega 1 - Datos de prueba del modelo inicial\n")
    w("--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana\n")
    w("--  Motor: Oracle Database 19c\n")
    w("-- " + "=" * 76 + "\n--\n")
    w("--  ARCHIVO GENERADO AUTOMATICAMENTE - NO EDITAR A MANO.\n")
    w(f"--  Generador: generar_datos_prueba.py  (semilla {SEMILLA}, reproducible)\n--\n")
    w("--  Los nombres de paises, ciudades y confederaciones son informacion\n")
    w("--  publica del futbol mundial. Los estadios, las fechas, los marcadores y\n")
    w("--  las asistencias son SINTETICOS: no reproducen ningun resultado real,\n")
    w("--  tal como exige la Seccion 4 del enunciado.\n--\n")
    w("--  Volumen generado:\n")
    w(f"--    EDICION_MUNDIAL        {len(filas_edicion):>6} filas\n")
    w(f"--    ESTADIO                {len(filas_estadio):>6} filas\n")
    w(f"--    SELECCION              {len(filas_seleccion):>6} filas\n")
    w(f"--    PARTIDO                {len(filas_partido):>6} filas\n")
    w(f"--    PARTICIPACION_PARTIDO  {len(filas_participacion):>6} filas\n--\n")
    w("--  EDICION_MUNDIAL es la unica tabla que no alcanza 100 filas, por su\n")
    w("--  propia naturaleza: la Copa Mundial se ha disputado 22 veces en toda su\n")
    w("--  historia. El enunciado contempla la salvedad ('cuando aplique segun la\n")
    w("--  naturaleza de la tabla').\n")
    w("-- " + "=" * 76 + "\n\n")
    w("SET DEFINE OFF;\n\n")

    for titulo, filas in (("EDICION_MUNDIAL", filas_edicion),
                          ("ESTADIO", filas_estadio),
                          ("SELECCION", filas_seleccion),
                          ("PARTIDO", filas_partido),
                          ("PARTICIPACION_PARTIDO", filas_participacion)):
        w("-- " + "-" * 74 + "\n")
        w(f"--  {titulo}  ({len(filas)} filas)\n")
        w("-- " + "-" * 74 + "\n")
        w("\n".join(filas))
        w("\n\n")

    w("COMMIT;\n\n")
    w("-- " + "-" * 74 + "\n")
    w("--  Verificacion rapida del volumen cargado\n")
    w("-- " + "-" * 74 + "\n")
    w("SELECT 'EDICION_MUNDIAL' AS tabla, COUNT(*) AS filas FROM edicion_mundial\n")
    w("UNION ALL SELECT 'ESTADIO',               COUNT(*) FROM estadio\n")
    w("UNION ALL SELECT 'SELECCION',             COUNT(*) FROM seleccion\n")
    w("UNION ALL SELECT 'PARTIDO',               COUNT(*) FROM partido\n")
    w("UNION ALL SELECT 'PARTICIPACION_PARTIDO', COUNT(*) FROM participacion_partido;\n")

print(f"Generado {SALIDA}")
print(f"  EDICION_MUNDIAL        {len(filas_edicion):>6}")
print(f"  ESTADIO                {len(filas_estadio):>6}")
print(f"  SELECCION              {len(filas_seleccion):>6}")
print(f"  PARTIDO                {len(filas_partido):>6}")
print(f"  PARTICIPACION_PARTIDO  {len(filas_participacion):>6}")
