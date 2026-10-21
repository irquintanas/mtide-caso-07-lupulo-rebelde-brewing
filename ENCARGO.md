# Caso 07 · Lúpulo Rebelde Brewing — el encargo

> Negocio y datos **ficticios**, creados para la asignatura. Es tu mismo caso de la J3.

## Qué ha pasado desde la J3

En la J3 limpiaste el parte en un cuaderno y contestaste tres preguntas. Lúpulo Rebelde quiere su parte de producción cargado solo. Y ha puesto **sondas de temperatura** en los fermentadores: cada estilo tiene su rango y salirse de él estropea el lote.

Ahora conviertes aquel cuaderno en un **lakehouse** de verdad, en tu propio repositorio, y publicas un **portal** que
cuenta lo que has hecho. Cómo preparar el repositorio y el ciclo de trabajo de cada bloque: [README.md](README.md).

## Lo que tienes al empezar

- En bronce, el parte de la J3: `lakehouse/bronce/parte/fecha_carga=2026-02-23/`.
- En `dbt/models/plata/stg_parte.sql`, la limpieza que hiciste en la J3, con unos tests básicos (`_plata.yml`, `dbt/tests/`).
- `dbt build` en verde. La capa oro, vacía: la construyes tú.
- En `paginas/`, las cuatro páginas del portal que escribirás, cada una con un guion de lo que debe contar.

**Bronce no se toca nunca**: todo arreglo va en plata.

---

## Bloque 1 · La remesa nueva · rama `remesa`

1. `python herramientas/sistema_simulado.py remesa`: llega una entrega nueva del parte en `bronce/parte/fecha_carga=2026-03-05/` (unos diez días más de lotes).
2. `dbt build --project-dir dbt --profiles-dir dbt`. El programa de producción nuevo escribe a las personas de otra manera. **Ningún test básico se pone rojo.** Pista: cuenta cuántos cerveceros distintos hay en plata. Deberían ser 6.
3. Arregla `dbt/models/plata/stg_parte.sql` hasta que `dbt build` quede en verde y el problema esté resuelto (no siempre hay un test que lo grite: a veces tienes que escribirlo tú). Deja un comentario en el SQL: **qué** venía mal y **por qué** lo arreglas así.
4. Escribe `paginas/1-remesa.md`.
5. Pull request en tu repositorio, Actions en verde y lo fusionas.

## Bloque 2 · El oro · rama `oro`

Crea en `dbt/models/oro/` estos modelos, **con estos nombres exactos** (el portal y la jornada de Visualización los leen así):

| Modelo | Qué tiene |
|---|---|
| `dim_cervecero` | una fila por cada valor distinto de `cervecero` |
| `dim_fermentador` | una fila por cada valor distinto de `fermentador` |
| `dim_estilo` | una fila por cada valor distinto de `estilo` |
| `fact_lotes` | un lote por fila: `lote`, `fecha`, `cervecero`, `fermentador`, `estilo`, `litros`, `kg_malta`, `importe_eur`, `con_incidencia` |
| `pregunta_1` | ¿Qué **estilo** deja menos ingreso por litro? Una fila por `estilo`, con `estilo` en la primera columna y `ingreso_litro` (€/l), de menor a mayor |
| `pregunta_2` | ¿Qué **cervecero** gasta más malta por litro? Una fila por `cervecero`, con `cervecero` en la primera columna y `kg_malta_100l` (kg de malta por 100 l), de mayor a menor |
| `pregunta_3` | ¿Qué **fermentador** acumula más incidencias por cada 10.000 litros? Una fila por `fermentador`, con `fermentador` en la primera columna y `incidencias_10000l` (incidencias por 10.000 l), de mayor a menor |

En un `_oro.yml`, sus tests: en las dimensiones, `unique` y `not_null`; en el hecho, `unique` en `lote` y `relationships` con cada dimensión.

Escribe `paginas/2-oro.md`: tu estrella y las tres respuestas. Con la remesa nueva (un 25 % más de datos), ¿siguen saliendo las mismas que en la J3? Pull request, verde, fusionas.

## Bloque 3 · Fuentes nuevas · rama `fuentes`

1. `python herramientas/sistema_simulado.py fuentes`: llegan estos ficheros a bronce y quedan declarados en `dbt/models/plata/_fuentes.yml`.

| Fichero | Qué es | Columnas |
|---|---|---|
| `bronce/estilos/estilos.csv` | rango de temperatura de fermentación de cada estilo (°C) | estilo, temp_min_c, temp_max_c |
| `bronce/estilos/fermentaciones.csv` | qué lote, de qué estilo y cuántos litros hay ahora en cada fermentador | fermentador, lote, estilo, litros |
| `bronce/eventos/lecturas_sondas_2026-03-07.json` | El sistema de las sondas exporta un registro con una lectura de temperatura por fermentador y hora. | lectura_id, fermentador, ts, temperatura |

2. **El giro.** Las sondas no son todas iguales: hay una que **no mide en grados Celsius** y otra que **se ha quedado muda** un rato. Antes de calcular nada, mira las lecturas por fermentador.
3. Modelos de plata: `stg_estilos`, `stg_fermentaciones` y `stg_eventos` (el registro lo lees con `source('bronce', 'eventos')`).
4. **Test protagonista.** **Una fermentación está entre 0 y 35 °C.** Escribe un test singular sobre `stg_eventos` que devuelva las lecturas fuera de ese rango. Rojo con los datos tal cual; verde cuando las unidades estén bien.
5. **Pregunta 4** (`dbt/models/oro/pregunta_4.sql`): ¿Qué **lote** ha pasado más tiempo fuera del rango de temperatura de su estilo, y **cuántos litros** arriesga? Ojo con la sonda rara: no confundas un problema de unidades con un problema de fermentación.
6. Escribe `paginas/3-fuentes.md`. Pull request, verde, fusionas.

## Bloque 4 · El memo · rama `memo`

Escribe `paginas/memo.md`: el memo para la dirección de Lúpulo Rebelde Brewing, con las cuatro respuestas citadas con marcas. La comprobación exige que existan `pregunta_1` a `pregunta_4`. Repasa el portal entero antes de fusionar.

---

## Lo que se entrega

- Tu repositorio en tu cuenta, con los cuatro pull requests fusionados y la última ejecución de `main` en verde.
- Tu portal publicado, con sus cuatro páginas escritas, y tu `dbt-docs`.
- La presentación oral (5 minutos): con tu portal en pantalla, el problema de calidad, tu test protagonista, las cuatro respuestas y tu recomendación.
