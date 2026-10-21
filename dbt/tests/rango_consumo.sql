-- kg_malta tiene que estar en un rango creíble para este negocio (36.95 a 591.2).
select lote, kg_malta from {{ ref('stg_parte') }}
where kg_malta not between 36.95 and 591.2
