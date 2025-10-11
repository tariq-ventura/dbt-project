{{
    config(
        materialized='table',
        unique_key='sucursal_key'
    )
}}

WITH sucursales_staging AS (
    SELECT DISTINCT
        sucursal
    FROM {{ ref('stg_ventas') }}
    WHERE sucursal IS NOT NULL
),

dimension_sucursales AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['sucursal']) }} as sucursal_key,
        sucursal as sucursal_nombre,
        'El Salvador' as pais,
        CURRENT_TIMESTAMP() as fecha_actualizacion
    FROM sucursales_staging
)

SELECT * FROM dimension_sucursales