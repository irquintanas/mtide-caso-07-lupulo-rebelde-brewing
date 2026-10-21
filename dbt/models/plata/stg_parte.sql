-- PLATA · el parte diario limpio: la limpieza que hiciste en la J3, ahora como modelo dbt.
-- Cada entrega del parte es una carpeta fecha_carga=… en bronce: aquí se leen todas juntas.
with bruto as (
    select *, parse_filename(filename) as archivo
    from {{ source('bronce', 'parte') }}
),
sin_dup as (
    -- una fila por lote
    select * from bruto
    qualify row_number() over (partition by lote order by fecha_carga desc) = 1
),
mediana_estilo as (
    select estilo, median(litros::integer) as litros_mediana
    from sin_dup
    where litros::integer between 1 and 3000
    group by estilo
)
select
    s.lote,
    s.fecha::date                                              as fecha,
    upper(trim(s.cervecero))                                         as cervecero,
    s.fermentador,
    s.estilo,
    case when s.litros::integer between 1 and 3000 then s.litros::integer
         else round(m.litros_mediana)::integer end               as litros,
    not (s.litros::integer between 1 and 3000)                   as litros_corregido,
    s.kg_malta::double                                              as kg_malta,
    s.importe_eur::double                                      as importe_eur,
    s.incidencia,
    s.archivo,
    s.fecha_carga
from sin_dup s
join mediana_estilo m using (estilo)
