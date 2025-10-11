{{
    config(
        materialized='incremental',
        unique_key='venta_key',
        partition_by={
            'field': 'fecha_venta',
            'data_type': 'date',
            'granularity': 'month'
        },
        cluster_by=['vendedor_key', 'producto_key']
    )
}}

WITH ventas_staging AS (
    SELECT *
    FROM {{ ref('stg_ventas') }}
    
    {% if is_incremental() %}
    -- Solo cargar datos nuevos en modo incremental
    WHERE fecha_proceso > (SELECT MAX(fecha_proceso) FROM {{ this }})
    {% endif %}
),

facts_ventas AS (
    SELECT
        -- Clave única
        {{ dbt_utils.generate_surrogate_key(['v.factura_id', 'v.producto_codigo']) }} as venta_key,
        
        -- Claves foráneas
        p.producto_key,
        vend.vendedor_key,
        s.sucursal_key,
        FORMAT_DATE('%Y%m%d', v.fecha_venta) as fecha_key,
        
        -- Dimensiones degeneradas
        v.factura_id,
        
        -- Fechas
        v.fecha_venta,
        v.anio,
        v.mes,
        
        -- Métricas
        v.cantidad,
        v.precio_unitario,
        v.descuento_pct,
        v.total_venta,
        
        -- Métricas calculadas
        ROUND(v.precio_unitario * v.cantidad, 2) as subtotal,
        ROUND(v.precio_unitario * v.cantidad * v.descuento_pct, 2) as descuento_monto,
        p.costo * v.cantidad as costo_total,
        v.total_venta - (p.costo * v.cantidad) as utilidad,
        ROUND((v.total_venta - (p.costo * v.cantidad)) / NULLIF(v.total_venta, 0) * 100, 2) as margen_utilidad_pct,
        
        -- Metadata
        v.fecha_proceso
        
    FROM ventas_staging v
    
    LEFT JOIN {{ ref('dim_productos') }} p
        ON v.producto_codigo = p.producto_codigo
    
    LEFT JOIN {{ ref('dim_vendedores') }} vend
        ON v.vendedor_id = vend.vendedor_id
    
    LEFT JOIN {{ ref('dim_sucursales') }} s
        ON v.sucursal = s.sucursal_nombre
    
    WHERE p.producto_key IS NOT NULL
        AND vend.vendedor_key IS NOT NULL
)

SELECT * FROM facts_ventas