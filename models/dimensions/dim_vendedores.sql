{{
    config(
        materialized='table',
        unique_key='vendedor_key'
    )
}}

WITH vendedores_staging AS (
    SELECT DISTINCT
        vendedor_id,
        vendedor_nombre
    FROM {{ ref('stg_ventas') }}
),

dimension_vendedores AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['vendedor_id']) }} as vendedor_key,
        vendedor_id,
        vendedor_nombre,
        SPLIT(vendedor_nombre, ' ')[SAFE_OFFSET(0)] as nombre,
        SPLIT(vendedor_nombre, ' ')[SAFE_OFFSET(1)] as apellido,
        CURRENT_TIMESTAMP() as fecha_actualizacion
    FROM vendedores_staging
)

SELECT * FROM dimension_vendedores