{{
    config(
        materialized='table',
        unique_key='empleado_key'
    )
}}

WITH empleados_staging AS (
    SELECT DISTINCT
        empleado_id,
        empleado_nombre,
        puesto,
        salario_base,
        comision_pct
    FROM {{ ref('stg_empleados') }}
),

dimension_empleados AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['empleado_id']) }} as empleado_key,
        empleado_id,
        empleado_nombre,
        puesto,
        salario_base,
        comision_pct,
        CASE
            WHEN puesto LIKE '%Gerente%' THEN 'Management'
            WHEN puesto LIKE '%Vendedor%' THEN 'Sales'
            WHEN puesto LIKE '%Técnico%' THEN 'Technical'
            WHEN puesto LIKE '%Asistente%' THEN 'Assistant'
            ELSE 'Other'
        END as categoria_puesto,
        CURRENT_TIMESTAMP() as fecha_actualizacion
    FROM empleados_staging
)

SELECT * FROM dimension_empleados