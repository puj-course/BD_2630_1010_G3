# Aplicacion de escritorio - Copa Mundial FIFA

Aplicacion en Java con Swing que se conecta por JDBC a la base Oracle del proyecto. Trabaja sobre
las tablas del modelo ampliado de la Entrega 2 (`sql/entrega2/ddl/ddl_modelo_ampliado.sql`).

## Requisitos

- JDK 21
- Maven 3.9 o superior
- VPN de la Universidad Javeriana activa (sin ella Oracle no responde y sale `ORA-12170`)
- Un esquema Oracle con el DDL y la carga de datos de la Entrega 2 ya ejecutados

El driver `ojdbc17` no hay que bajarlo a mano: Maven lo descarga la primera vez segun el `pom.xml`.

## Configurar la conexion

Los datos de conexion no van en el codigo. Se leen de `app/config.properties`, que esta en el
`.gitignore` para que nadie suba su contrasena.

```bash
cd app
cp config.example.properties config.properties
```

Luego se edita `config.properties` con el usuario propio:

```properties
db.url=jdbc:oracle:thin:@orion.javeriana.edu.co:1521/LAB
db.usuario=IS1010XX
db.contrasena=la_contrasena_propia
```

## Ejecutar

Desde la carpeta `app/`:

```bash
mvn compile exec:java
```

Hay que correrlo desde `app/` porque la clase `Conexion` busca `config.properties` en la carpeta
actual. Si no lo encuentra, la aplicacion muestra un mensaje y no abre la ventana.

Tambien se puede abrir la carpeta `app/` en IntelliJ como proyecto Maven y ejecutar `mundial.Main`.
En ese caso el directorio de trabajo de la configuracion de ejecucion debe ser `app/`.

## Que hace cada menu

| Menu | Opcion | Estado |
|---|---|---|
| Catalogos | Ediciones del Mundial | Listar, crear, editar y borrar |
| Catalogos | Sedes | Listar, crear, editar y borrar |
| Catalogos | Ciudades | Listar, crear, editar y borrar |
| Catalogos | Estadios | Listar, crear, editar y borrar |
| Catalogos | Selecciones y grupos | Listar, crear, editar y borrar selecciones, con su grupo de la misma edición |
| Catalogos | Jugadores y cuerpo tecnico | Ficha de jugadores, cuerpo técnico por selección y convocatorias con dorsal y capitanía |
| Partidos | Registro de partidos | Programar encuentros, registrar resultado con `pr_registrar_resultado`, cerrar fase con `pr_cierre_fase` y eliminar |
| Partidos | Estadísticas | Alineaciones, minutos jugados, goles, asistencias y tarjetas individuales por partido |
| Partidos | Incidencias | Registrar, modificar y eliminar incidencias por minuto (tarjetas, VAR, lesiones, etc.) |
| Consultas | Tabla de posiciones, resultados, incidencias | Consultas consolidadas con filtros por edición, grupo y fase |
| Reportes | Panel de reportes | Goleadores, rendimiento por selección, desglose por fase e incidencias por estadio |

Cuando Oracle rechaza una operacion, la aplicacion muestra el error tal como lo devuelve la base.
Por ejemplo, borrar una sede que todavia tiene ciudades da `ORA-02292`, y guardar un estadio con
capacidad fuera de rango da `ORA-02290` por `ck_estadio_capacidad`.

## Estructura del codigo

```text
app/
├── pom.xml
├── config.example.properties
└── src/main/java/mundial/
    ├── Main.java              abre la conexion de prueba y la ventana
    ├── Conexion.java          lee config.properties y entrega la Connection
    ├── datos/                 una clase entidad y un RepositoryXXX por tabla
    └── ui/                    VentanaPrincipal y un PanelXXX por pantalla
```

La arquitectura y las decisiones de diseno estan en `docs/entrega3/arquitectura_aplicacion.md`.

## Como agregar una pantalla

1. Crear la entidad en `datos/` con sus atributos privados, constructor, getters y setters.
2. Crear `RepositoryXXX` en `datos/` con los metodos de consulta y modificacion. El SQL se arma con
   `StringBuilder` y se ejecuta con `PreparedStatement` dentro de un try-with-resources.
3. Crear `PanelXXX` en `ui/`. `PanelEstadios` sirve de ejemplo de una tabla que depende de otra.
4. En `VentanaPrincipal`, agregarla con `agregar(menu, columna, "Titulo", PanelXXX::new)`. Queda en el menu y en la pantalla de inicio.
