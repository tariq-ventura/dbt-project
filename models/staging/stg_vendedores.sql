{{
    config(
        materialized='view'
    )
}}

WITH source_data AS (
    SELECT *
    FROM {{ source('staging', 'vendedores_raw') }}
),

cleaned AS (
    SELECT
        CAST(VendedorID AS INT64) as vendedor_id,
        TRIM(Vendedor) as vendedor_nombre,
        CAST(VentasTotalesUSD AS FLOAT64) as ventas_totales,
        CAST(CantidadItems AS INT64) as items_vendidos,
        CAST(Transacciones AS INT64) as num_transacciones,
        CAST(PromedioPorTransaccionUSD AS FLOAT64) as promedio_transaccion,
        CURRENT_TIMESTAMP() as fecha_proceso
    FROM source_data
    WHERE VendedorID IS NOT NULL
)

SELECT * FROM cleaned