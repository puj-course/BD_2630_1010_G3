# Modelo Físico - Entrega 2
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

Implementado en Oracle Database 19c (script: `sql/entrega2/ddl/ddl_modelo_ampliado.sql`).

---

## 1. Diagrama físico

```mermaid
erDiagram
  EDICION_MUNDIAL ||--o{ SEDE : tiene
  SEDE ||--o{ CIUDAD : contiene
  CIUDAD ||--o{ ESTADIO : alberga
  EDICION_MUNDIAL ||--o{ FASE : define
  FASE ||--o{ GRUPO : agrupa
  EDICION_MUNDIAL ||--o{ SELECCION : convoca
  GRUPO |o--o{ SELECCION : incluye
  EDICION_MUNDIAL ||--o{ PARTIDO : programa
  FASE ||--o{ PARTIDO : clasifica
  ESTADIO ||--o{ PARTIDO : aloja
  PARTIDO |o--o{ PARTIDO : alimenta
  PARTIDO ||--|{ PARTICIPACION_PARTIDO : registra
  SELECCION ||--o{ PARTICIPACION_PARTIDO : participa_en
  JUGADOR ||--o{ CONVOCATORIA_JUGADOR : es_convocado
  SELECCION ||--o{ CONVOCATORIA_JUGADOR : convoca
  SELECCION ||--o{ CUERPO_TECNICO : tiene
  ARBITRO ||--o{ ASIGNACION_ARBITRAL : es_asignado
  PARTIDO ||--o{ ASIGNACION_ARBITRAL : requiere
  PARTIDO ||--o{ ESTADISTICA_JUGADOR_PARTIDO : genera
  JUGADOR ||--o{ ESTADISTICA_JUGADOR_PARTIDO : registra
  PARTIDO ||--o{ INCIDENCIA : presenta

  EDICION_MUNDIAL {
    NUMBER(10) id_edicion PK
    NUMBER(4) anio UK
    VARCHAR2(200) lema
    DATE fecha_inicio
    DATE fecha_fin
  }
  SEDE {
    NUMBER(10) id_sede PK
    NUMBER(10) id_edicion FK
    VARCHAR2(100) pais
  }
  CIUDAD {
    NUMBER(10) id_ciudad PK
    NUMBER(10) id_sede FK
    VARCHAR2(100) nombre
  }
  ESTADIO {
    NUMBER(10) id_estadio PK
    NUMBER(10) id_ciudad FK
    VARCHAR2(150) nombre
    NUMBER(10) capacidad
  }
  FASE {
    NUMBER(10) id_fase PK
    NUMBER(10) id_edicion FK
    VARCHAR2(50) nombre
    NUMBER(2) orden_fase
    VARCHAR2(20) tipo
  }
  GRUPO {
    NUMBER(10) id_grupo PK
    NUMBER(10) id_fase FK
    VARCHAR2(1) nombre
  }
  SELECCION {
    NUMBER(10) id_seleccion PK
    NUMBER(10) id_edicion FK
    NUMBER(10) id_grupo FK
    VARCHAR2(100) pais
    VARCHAR2(50) confederacion
  }
  PARTIDO {
    NUMBER(10) id_partido PK
    NUMBER(10) id_edicion FK
    NUMBER(10) id_fase FK
    NUMBER(10) id_estadio FK
    NUMBER(10) id_partido_siguiente FK
    TIMESTAMP fecha_hora
    NUMBER(10) asistencia_registrada
  }
  PARTICIPACION_PARTIDO {
    NUMBER(10) id_participacion PK
    NUMBER(10) id_partido FK
    NUMBER(10) id_seleccion FK
    VARCHAR2(20) condicion
    NUMBER(3) goles_marcados
  }
  JUGADOR {
    NUMBER(10) id_jugador PK
    VARCHAR2(150) nombre
    VARCHAR2(20) posicion
    VARCHAR2(150) club
  }
  CONVOCATORIA_JUGADOR {
    NUMBER(10) id_convocatoria PK
    NUMBER(10) id_jugador FK
    NUMBER(10) id_seleccion FK
    NUMBER(3) numero_camiseta
    NUMBER(1) es_capitan
  }
  CUERPO_TECNICO {
    NUMBER(10) id_cuerpo_tecnico PK
    NUMBER(10) id_seleccion FK
    VARCHAR2(150) nombre
    VARCHAR2(50) cargo
  }
  ARBITRO {
    NUMBER(10) id_arbitro PK
    VARCHAR2(150) nombre
    VARCHAR2(100) nacionalidad
  }
  ASIGNACION_ARBITRAL {
    NUMBER(10) id_asignacion PK
    NUMBER(10) id_partido FK
    NUMBER(10) id_arbitro FK
    VARCHAR2(30) rol
  }
  ESTADISTICA_JUGADOR_PARTIDO {
    NUMBER(10) id_estadistica PK
    NUMBER(10) id_partido FK
    NUMBER(10) id_jugador FK
    NUMBER(1) titular
    NUMBER(3) minuto_entrada
    NUMBER(3) minuto_salida
    NUMBER(3) minutos_jugados
    NUMBER(3) goles
    NUMBER(3) asistencias
    NUMBER(2) tarjetas_amarillas
    NUMBER(2) tarjetas_rojas
  }
  INCIDENCIA {
    NUMBER(10) id_incidencia PK
    NUMBER(10) id_partido FK
    VARCHAR2(20) tipo
    NUMBER(3) minuto
    VARCHAR2(300) descripcion
  }
```

---

## 2. Convenciones de nombres

| Prefijo | Objeto | Ejemplo |
|---|---|---|
| `pk_` | Llave primaria | `pk_partido` |
| `fk_` | Llave foránea | `fk_partido_estadio` |
| `uq_` | Restricción UNIQUE | `uq_partido_agenda` |
| `ck_` | Restricción CHECK | `ck_participacion_goles` |
| `ix_` | Índice | `ix_partido_fase` |

Tipos de dato: `NUMBER` para identificadores, cantidades y banderas (0/1), `VARCHAR2` para texto, `DATE` para fechas del torneo y `TIMESTAMP` para la fecha y hora de cada partido.

---

## 3. Índices automáticos

Oracle crea un índice único por cada llave primaria y por cada restricción UNIQUE. No se declaran en el script.

| Origen | Cantidad |
|---|---|
| Llaves primarias | 16 |
| Restricciones UNIQUE | 15 |

---

## 4. Índices creados explícitamente

Oracle no indexa las llaves foráneas por sí solo. Se crearon 9 índices sobre las columnas que más se usan en los `JOIN` y filtros de las consultas. Las llaves foráneas que ya son la primera columna de un UNIQUE no necesitan índice aparte.

| Índice | Tabla (columna) | Justificación |
|---|---|---|
| `ix_partido_edicion` | `partido` (`id_edicion`) | Filtrar y agrupar partidos por edición |
| `ix_partido_fase` | `partido` (`id_fase`) | Resultados y conteos por fase |
| `ix_partido_siguiente` | `partido` (`id_partido_siguiente`) | Recorrer el cuadro eliminatorio |
| `ix_participacion_seleccion` | `participacion_partido` (`id_seleccion`) | Partidos y goles por selección |
| `ix_estadistica_jugador` | `estadistica_jugador_partido` (`id_jugador`) | Goleadores y rendimiento por jugador |
| `ix_asignacion_arbitro` | `asignacion_arbitral` (`id_arbitro`) | Historial de partidos de un árbitro |
| `ix_incidencia_partido` | `incidencia` (`id_partido`) | Incidencias de un partido |
| `ix_seleccion_grupo` | `seleccion` (`id_grupo`) | Selecciones de un grupo y tabla de posiciones |
| `ix_cuerpo_tecnico_seleccion` | `cuerpo_tecnico` (`id_seleccion`) | Cuerpo técnico de una selección |

Total de índices en el modelo: 16 + 15 + 9 = 40.
