---
title: Modelo Entidad-Relación - Mundial FIFA (Entrega 1)
---

# Modelo Entidad-Relación — Modelo Inicial

## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

El modelo inicial está compuesto por cinco entidades principales:

- `EDICION_MUNDIAL`
- `ESTADIO`
- `SELECCION`
- `PARTIDO`
- `PARTICIPACION_PARTIDO`

El siguiente diagrama representa las entidades, sus atributos principales, llaves primarias y llaves foráneas, así como las relaciones entre ellas.

```mermaid
erDiagram
    EDICION_MUNDIAL ||--o{ ESTADIO : "tiene"
    EDICION_MUNDIAL ||--o{ SELECCION : "convoca"
    EDICION_MUNDIAL ||--o{ PARTIDO : "programa"
    ESTADIO ||--o{ PARTIDO : "aloja"
    PARTIDO ||--o{ PARTICIPACION_PARTIDO : "registra"
    SELECCION ||--o{ PARTICIPACION_PARTIDO : "participa en"

    EDICION_MUNDIAL {
        NUMBER id_edicion PK
        NUMBER anio UK
        VARCHAR2 pais_sede
        VARCHAR2 lema
        DATE fecha_inicio
        DATE fecha_fin
    }

    ESTADIO {
        NUMBER id_estadio PK
        NUMBER id_edicion FK
        VARCHAR2 nombre
        VARCHAR2 ciudad
        NUMBER capacidad
    }

    SELECCION {
        NUMBER id_seleccion PK
        NUMBER id_edicion FK
        VARCHAR2 pais
        VARCHAR2 confederacion
        VARCHAR2 grupo
    }

    PARTIDO {
        NUMBER id_partido PK
        NUMBER id_edicion FK
        NUMBER id_estadio FK
        TIMESTAMP fecha_hora
        VARCHAR2 fase
        NUMBER asistencia_registrada
    }

    PARTICIPACION_PARTIDO {
        NUMBER id_participacion PK
        NUMBER id_partido FK
        NUMBER id_seleccion FK
        VARCHAR2 condicion
        NUMBER goles_marcados
    }
