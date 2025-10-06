{{
    config(
        materialized='table',
        unique_key='producto_key'
    )
}}

WITH productos_staging AS (
    SELECT DISTINCT
        producto_codigo,
        producto_nombre,
        categoria,
        precio_lista,
        costo,
        descuento_maximo
    FROM {{ ref('stg_productos') }}
),

dimension_productos AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['producto_codigo']) }} as producto_key,
        producto_codigo,
        producto_nombre,
        categoria,
        precio_lista,
        costo,
        descuento_maximo,
        -- Métricas calculadas
        ROUND((precio_lista - costo) / NULLIF(precio_lista, 0) * 100, 2) as margen_pct,
        CASE
            WHEN categoria = 'Paneles' THEN 'Solar Panels'
            WHEN categoria = 'Inversores' THEN 'Inverters'
            WHEN categoria = 'Baterías' THEN 'Batteries'
            ELSE categoria
        END as categoria_en,
        CURRENT_TIMESTAMP() as fecha_actualizacion
    FROM productos_staging
)

SELECT * FROM dimension_productos