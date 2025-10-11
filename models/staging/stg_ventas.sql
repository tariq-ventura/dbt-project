{{
    config(
        materialized='view'
    )
}}

WITH source_data AS (
    SELECT *
    FROM {{ source('staging', 'ventas_raw') }}
),

cleaned AS (
    SELECT
        -- IDs
        TRIM(Factura) as factura_id,
        TRIM(CodigoProducto) as producto_codigo,
        CAST(VendedorID AS INT64) as vendedor_id,
        
        -- Fechas
        Fecha as fecha_venta,
        EXTRACT(YEAR FROM Fecha) as anio,
        EXTRACT(MONTH FROM Fecha) as mes,
        
        -- Textos
        TRIM(Producto) as producto_nombre,
        TRIM(Vendedor) as vendedor_nombre,
        TRIM(Sucursal) as sucursal,
        
        -- Números
        CAST(Cantidad AS INT64) as cantidad,
        CAST(PrecioUnitUSD AS FLOAT64) as precio_unitario,
        CAST(DescuentoAplicado AS FLOAT64) as descuento_pct,
        CAST(TotalUSD AS FLOAT64) as total_venta,
        
        -- Metadata
        CURRENT_TIMESTAMP() as fecha_proceso
        
    FROM source_data
    WHERE 
        Factura IS NOT NULL
        AND Fecha IS NOT NULL
        AND CAST(TotalUSD AS FLOAT64) > 0
)

SELECT * FROM cleaned