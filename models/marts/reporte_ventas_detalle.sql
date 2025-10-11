{{
    config(
        materialized='table'
    )
}}

SELECT
    -- Hechos y métricas de la tabla de ventas
    f.subtotal,
    f.descuento_monto,
    f.total_venta,
    f.costo_total,
    f.utilidad,
    f.margen_utilidad_pct,
    f.fecha_venta,
    f.cantidad,

    -- Atributos de tiempo desde dim_tiempo
    t.anio,
    t.mes,
    t.mes_nombre,
    t.trimestre,
    t.dia_semana_nombre,

    -- Atributos descriptivos de las dimensiones
    p.producto_nombre,
    p.categoria as producto_categoria,
    vend.vendedor_nombre,
    s.sucursal_nombre

FROM {{ ref('fact_ventas') }} f

LEFT JOIN {{ ref('dim_productos') }} p
    ON f.producto_key = p.producto_key

LEFT JOIN {{ ref('dim_vendedores') }} vend
    ON f.vendedor_key = vend.vendedor_key

LEFT JOIN {{ ref('dim_sucursales') }} s
    ON f.sucursal_key = s.sucursal_key

LEFT JOIN {{ ref('dim_tiempo') }} t
    ON f.fecha_key = t.fecha_key