# BD_PROYECTO — Repositorio del Equipo
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

Este repositorio se utiliza para desarrollar el proyecto de Bases de Datos desde la Semana 4 hasta la Semana 16 del curso, cubriendo la Entrega 1, la Entrega 2 y la Entrega 3, usando Git como herramienta de seguimiento del progreso.

Este README es el documento principal de lineamientos. Existen dos documentos complementarios:

- **README_CRONOGRAMA.md** — detalle semana a semana de entregables, nombres de archivo, contenido esperado y estructura de carpetas.
- **README_SERVIDOR_ENTREGA1.md** — guía de conexión al servidor de base de datos dispuesto por el curso para la Entrega 1 (modelo inicial).

Lee los tres documentos antes de empezar a trabajar.

---

## Identificación del equipo

**Curso:** Bases de Datos — Pontificia Universidad Javeriana
**Docente:** Ing. Luis Gabriel Moreno Sandoval, PhD.
**Monitora:** Viviana Gómez — [gomezlv@javeriana.edu.co](mailto:gomezlv@javeriana.edu.co)
**Grupo:** G3 — repositorio `puj-course/BD_2630_1010_G3`

| Integrante | GitHub | Usuario Oracle |
|---|---|---|
| Nicolás Esteban Mamian Palacios | [@Nicolukazzz](https://github.com/Nicolukazzz) | `IS101009` |
| Santiago P. | [@hsantiagopf](https://github.com/hsantiagopf) | _(completar)_ |
| Nick_07 | [@Nivk-Debug](https://github.com/Nivk-Debug) | _(completar)_ |
| Laura Sofia Lesmes Ocampo | [@laulesmes04](https://github.com/laulesmes04) | is101007 |

---

## Información técnica de conexión al servidor

El modelo genérico inicial está montado en el servidor Oracle dispuesto por el curso. La guía
completa está en [`README_GUIA_SERVIDOR.md`](README_GUIA_SERVIDOR.md); lo esencial es:

| Parámetro | Valor |
|---|---|
| Motor | Oracle Database **19c** (19.3.0.0.0) |
| Host | `orion.javeriana.edu.co` |
| Puerto | `1521` |
| Service Name | `LAB` |
| Usuario | El usuario Oracle asignado individualmente (p. ej. `IS101009`) |
| Contraseña | La asignada individualmente — **nunca se versiona en este repositorio** |
| Juego de caracteres | `AL32UTF8` |
| Requisito de red | **VPN de la Universidad Javeriana** |

**Cadena de conexión (SQLcl / SQL Developer):**

```
usuario/contraseña@orion.javeriana.edu.co:1521/LAB
```

**Guardar la conexión en SQLcl:**

```bash
conn -save "BD Javeriana" -savepwd IS101009/<contraseña>@orion.javeriana.edu.co:1521/LAB
```

### Dos esquemas, dos propósitos

| Esquema | Contenido | Permisos | Para qué se usa |
|---|---|---|---|
| `MORENOLUIS` | Tablas de referencia `FIFA_*` | **Solo lectura** | Desarrollar y validar las consultas SQL sobre un dataset común |
| Esquema propio (p. ej. `IS101009`) | Tablas del proyecto + datos propios | Control total | DDL, DML, vistas, roles, índices y pruebas de la implementación propia |

Las tablas de `MORENOLUIS` **no se deben modificar** (`INSERT`/`UPDATE`/`DELETE`/`DROP`/`ALTER`/`TRUNCATE`).
Los datos de la implementación propia deben ser **distintos** de los de referencia.

**Prueba rápida de acceso:**

```sql
SELECT COUNT(*) FROM MORENOLUIS.FIFA_EDICION_MUNDIAL;   -- 3
SELECT COUNT(*) FROM MORENOLUIS.FIFA_ESTADIO;           -- 6
SELECT COUNT(*) FROM MORENOLUIS.FIFA_SELECCION;         -- 14
SELECT COUNT(*) FROM MORENOLUIS.FIFA_PARTIDO;           -- 23
SELECT COUNT(*) FROM MORENOLUIS.FIFA_PARTICIPACION_PARTIDO; -- 46
```

> **Nota sobre las columnas de referencia:** además de las listadas en `README_GUIA_SERVIDOR.md`,
> las tablas de referencia incluyen `FIFA_PARTIDO.ASISTENCIA_REGISTRADA` y `FIFA_SELECCION.GRUPO`,
> necesarias para las consultas de ocupación de estadio y de tabla de posiciones por grupo.

---

## Cronograma del equipo

Ventana de aporte semanal: **lunes 00:00 — domingo 23:59 (hora Colombia, UTC-5)**.

### Entrega 1 — Modelo Relacional, SQL e Integridad

| Semana | Fechas | Entregables principales |
|---|---|---|
| 1 | 24–30 ago 2026 | Estructura del repositorio; documento técnico (secc. 1–3) + diagrama ER; consultas 2 y 6; consultas 1, 3, 4, 5, 9, 12 y 13 |
| 2 | 31 ago – 6 sep 2026 | Consultas 7, 8, 10 y 11; vistas + justificación; consulta 15 sobre vista; DML del ciclo de vida del partido |
| 3 | 7–13 sep 2026 | DDL del modelo inicial; operaciones inválidas y pruebas `ON DELETE`; consulta 14; roles y privilegios |
| 4 | 14–20 sep 2026 | Álgebra relacional; evaluación crítica del modelo inicial + boceto ampliado; documento técnico (secc. 4–5) y diccionario de datos; merge de todas las ramas |

### Entrega 2 — Consultas Avanzadas, Perfección del Modelo y Roles

| Semana | Entregables principales |
|---|---|
| 1 | Modelo lógico ampliado (12–16 tablas) + diccionario de datos ampliado |
| 2 | DDL del modelo ampliado; modelo físico; carga de datos de prueba |
| 3 | Normalización (1FN–3FN); consultas avanzadas parte 1 |
| 4 | Consultas avanzadas parte 2; roles y privilegios diferenciados; casos de prueba |

### Entrega 3 — Programación en Base de Datos y Aplicación

| Semana | Entregables principales |
|---|---|
| 1 | Funciones, procedimientos y los 4 triggers obligatorios + pruebas |
| 2 | Aplicación funcional (base + catálogos) y arquitectura |
| 3 | Aplicación completa, módulo de reportes y cierre |

### Reparto de responsabilidades — Entrega 1

| Integrante | Bloque asignado |
|---|---|
| [@Nicolukazzz](https://github.com/Nicolukazzz) | DDL, restricciones de negocio e índices; coordinación e integración de ramas |
| [@hsantiagopf](https://github.com/hsantiagopf) | Las 15 consultas SQL |
| [@Nivk-Debug](https://github.com/Nivk-Debug) | Datos de prueba, vistas y modificadores de datos (DML) |
| [@laulesmes04](https://github.com/laulesmes04) | Documento técnico, diccionario de datos, evaluación crítica y álgebra relacional |

---

## Estado de la Entrega 1

| Entregable | Archivo | Estado |
|---|---|---|
| Documento técnico | `docs/entrega1/documento_tecnico.md` | ⬜ Pendiente |
| Diagrama ER del modelo inicial | `docs/entrega1/modelo_er_inicial.png` | ⬜ Pendiente |
| Diccionario de datos | `docs/entrega1/diccionario_datos.md` | ⬜ Pendiente |
| Justificación de vistas | `docs/entrega1/vistas.md` | ⬜ Pendiente |
| Evaluación crítica del modelo inicial | `docs/entrega1/evaluacion_critica_modelo_inicial.md` | ⬜ Pendiente |
| Boceto del modelo ampliado | `docs/entrega1/boceto_modelo_ampliado.png` | ⬜ Pendiente |
| DDL del modelo inicial | `sql/entrega1/ddl/ddl_modelo_inicial.sql` | ⬜ Pendiente |
| Datos de prueba | `sql/entrega1/dml/carga_datos_prueba.sql` | ⬜ Pendiente |
| DML — ciclo de vida del partido | `sql/entrega1/dml/dml_ciclo_vida_partido.sql` | ⬜ Pendiente |
| Vistas | `sql/entrega1/vistas/vistas.sql` | ⬜ Pendiente |
| Consultas — joins | `sql/entrega1/consultas/semana1_joins.sql` | ⬜ Pendiente |
| Consultas — agregaciones | `sql/entrega1/consultas/semana2_agregaciones.sql` | ⬜ Pendiente |
| Consultas — subconsultas | `sql/entrega1/consultas/semana3_subconsultas.sql` | ⬜ Pendiente |
| Consulta sobre vista | `sql/entrega1/consultas/semana3_consulta_vista.sql` | ⬜ Pendiente |
| Consulta de verificación de integridad | `sql/entrega1/consultas/semana4_verificacion_integridad.sql` | ⬜ Pendiente |
| Roles y privilegios | `sql/entrega1/roles/roles_privilegios.sql` | ⬜ Pendiente |
| Álgebra relacional | `sql/entrega1/algebra_relacional/algebra_relacional.md` | ⬜ Pendiente |
| Pruebas de DML | `tests/entrega1/pruebas_dml.md` | ⬜ Pendiente |
| Pruebas de privilegios | `tests/entrega1/pruebas_privilegios.md` | ⬜ Pendiente |

---

# Lineamientos del curso

> A partir de aquí, el contenido corresponde a los lineamientos entregados por el curso en la plantilla oficial del repositorio.

---

## Contexto académico

El proyecto se basa en el enunciado "Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA" (Ing. Luis Gabriel Moreno Sandoval, PhD. — Bases de Datos, PUJ). El trabajo se organiza según el siguiente cronograma académico del curso:

| Entrega | Semanas académicas | Semanas de trabajo | Cierre |
|---|---|---|---|
| Entrega 1 | Semana 4 a Semana 7 | 4 semanas | Semana 8 |
| Entrega 2 | Semana 9 a Semana 12 | 4 semanas | Semana 13 |
| Entrega 3 | Semana 14 a Semana 16 | 3 semanas | Semana 17 |

El detalle de qué se entrega cada semana específica está en README_CRONOGRAMA.md.

---

## Metodología de Trabajo

### 1. Trabajo por Ramas

Cada tarea/entregable debe realizarse en una rama diferente, creada a partir de `main`.

**Nombre sugerido:**
```
feature/<descripcion>
```

**Ejemplos:**
```
feature/consultas-joins-semana1
feature/modelo-logico
feature/triggers-auditoria
feature/documento-tecnico
```

#### Flujo recomendado:

**1. Crear la rama desde `main`**
```bash
git checkout main
git pull
git checkout -b feature/nombre-tarea
```

**2. Commits del progreso** (frecuentes, no solo uno al final de la semana)
```bash
git add .
git commit -m "Mensaje de commit descriptivo"
```

**3. Subir la rama al repositorio:**
```bash
git push origin feature/nombre-tarea
```

**4. Crear un Pull Request** para integrar los cambios en `main`, y fusionarlo antes del cierre de la semana correspondiente.

---

### 2. Registro del Progreso — CHANGELOG.md

Cada semana (de las 12 semanas de trabajo del proyecto) se debe actualizar el archivo `CHANGELOG.md` agregando una nueva entrada, sin borrar las anteriores. Formato sugerido por semana:

```markdown
## Semana X — Entrega Y — [rango de fechas]

Objetivos: metas de la semana según README_CRONOGRAMA.md

Tareas realizadas: lo que se completó (con referencia a los archivos/carpetas entregados)

Responsables: integrantes a cargo de cada tarea

Ramas utilizadas: nombres de las ramas creadas/fusionadas esta semana

Problemas: inconvenientes encontrados y cómo se resolvieron (o si siguen pendientes)
```

Este registro, junto con los commits y Pull Requests, es la evidencia principal de que todos los integrantes participaron de forma semanal.

---

## Ventana de tiempo válida para el aporte semanal

Cada semana de trabajo del proyecto se evalúa dentro de la ventana:

```
Lunes 12:00 a.m. (00:00) — Domingo 11:59 p.m. (23:59), hora Colombia (UTC-5)
```

Los commits, ramas, Pull Requests y la actualización del `CHANGELOG.md` deben quedar registrados dentro de esa ventana para contar como aporte de esa semana específica.

---

## Evaluación del progreso semanal

El progreso del repositorio se revisa de forma semanal, considerando la actividad registrada en el historial de Git (commits, ramas, Pull Requests), la actualización del `CHANGELOG.md`, y la revisión del contenido técnico entregado.

Es indispensable seguir exactamente los nombres de archivo, extensiones y rutas indicadas en README_CRONOGRAMA.md.

No seguir los nombres de archivo, formatos o ubicaciones especificadas en README_CRONOGRAMA.md baja la nota, incluso si el contenido técnico es correcto, porque dificulta tanto la revisión manual como la automática.

---

## Participación individual

Es requisito indispensable que todos los integrantes registren actividad semanal verificable en el repositorio (commits con su propio correo, contribuciones en ramas, participación en Pull Requests o registro en el CHANGELOG). Los integrantes que no demuestren avances semanales verificables no serán tenidos en cuenta en la calificación de la entrega correspondiente.

---

## Estructura General de Carpetas del Proyecto

```text
BD_PROYECTO/
│
├── app/                          ---> Entrega 3 (aplicación funcional)
│
├── docs/                         ---> Documentos, modelos, diagramas, diccionario de datos
│   ├── entrega1/
│   ├── entrega2/
│   └── entrega3/
│
├── sql/
│   ├── entrega1/
│   │   ├── consultas/
│   │   ├── ddl/
│   │   ├── dml/
│   │   ├── vistas/
│   │   ├── roles/
│   │   └── algebra_relacional/
│   │
│   ├── entrega2/
│   │   ├── consultas/
│   │   ├── ddl/
│   │   ├── dml/
│   │   └── roles/
│   │
│   └── entrega3/
│       ├── funciones/
│       ├── procedimientos/
│       └── triggers/
│
├── tests/
│   ├── entrega1/
│   ├── entrega2/
│   └── entrega3/
│
├── .gitignore
├── CHANGELOG.md
├── README.md
├── README_CRONOGRAMA.md
└── README_SERVIDOR_ENTREGA1.md
```

El detalle exacto de qué archivo va dentro de cada subcarpeta, semana a semana, está en README_CRONOGRAMA.md. Esa estructura es la que se debe seguir de forma precisa.

---

## Contacto

De presentar alguna inquietud con respecto al proyecto, uso de Git para este o los parámetros planteados, contactar a la monitora:

**Viviana Gómez**
Teams o Correo: [gomezlv@javeriana.edu.co](mailto:gomezlv@javeriana.edu.co)
