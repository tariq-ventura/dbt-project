{{
    config(
        materialized='incremental',
        unique_key='fecha_key'
    )
}}

WITH fechas_ventas AS (
    SELECT DISTINCT fecha_venta as fecha
    FROM {{ ref('stg_ventas') }}
),

dimension_tiempo AS (
    SELECT
        FORMAT_DATE('%Y%m%d', fecha) as fecha_key,
        fecha,
        EXTRACT(YEAR FROM fecha) as anio,
        EXTRACT(QUARTER FROM fecha) as trimestre,
        EXTRACT(MONTH FROM fecha) as mes,
        FORMAT_DATE('%B', fecha) as mes_nombre,
        EXTRACT(WEEK FROM fecha) as semana,
        EXTRACT(DAY FROM fecha) as dia,
        EXTRACT(DAYOFWEEK FROM fecha) as dia_semana_num,
        FORMAT_DATE('%A', fecha) as dia_semana_nombre,
        CASE 
            WHEN EXTRACT(DAYOFWEEK FROM fecha) IN (1, 7) THEN TRUE 
            ELSE FALSE 
        END as es_fin_semana,
        CASE
            WHEN EXTRACT(MONTH FROM fecha) IN (1, 2, 3) THEN 'Q1'
            WHEN EXTRACT(MONTH FROM fecha) IN (4, 5, 6) THEN 'Q2'
            WHEN EXTRACT(MONTH FROM fecha) IN (7, 8, 9) THEN 'Q3'
            ELSE 'Q4'
        END as trimestre_nombre
    FROM fechas_ventas
)

SELECT * FROM dimension_tiempo
ORDER BY fecha