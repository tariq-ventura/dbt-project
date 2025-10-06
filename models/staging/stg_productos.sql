{{
    config(
        materialized='view'
    )
}}

WITH source_data AS (
    SELECT *
    FROM {{ source('staging', 'productos_raw') }}
),

cleaned AS (
    SELECT
        TRIM(Codigo) as producto_codigo,
        TRIM(Producto) as producto_nombre,
        TRIM(Categoria) as categoria,
        CAST(PrecioUSD AS FLOAT64) as precio_lista,
        CAST(CostoUSD AS FLOAT64) as costo,
        CAST(DescuentoMax AS FLOAT64) as descuento_maximo,
        CURRENT_TIMESTAMP() as fecha_proceso
    FROM source_data
    WHERE Codigo IS NOT NULL
)

SELECT * FROM cleaned