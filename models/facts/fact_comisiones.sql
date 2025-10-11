{{
    config(
        materialized='incremental',
        unique_key='comision_key',
        partition_by={
            'field': 'periodo_mes',
            'data_type': 'date',
            'granularity': 'month'
        }
    )
}}

WITH empleados_staging AS (
    SELECT *
    FROM {{ ref('stg_empleados') }}
    
    {% if is_incremental() %}
    WHERE fecha_proceso > (SELECT MAX(fecha_proceso) FROM {{ this }})
    {% endif %}
),

facts_comisiones AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['e.empleado_id', 'e.fecha_proceso']) }} as comision_key,
        
        emp.empleado_key,
        
        -- Período (usar primer día del mes actual)
        DATE_TRUNC(CURRENT_DATE(), MONTH) as periodo_mes,
        FORMAT_DATE('%Y%m', CURRENT_DATE()) as periodo_key,
        
        -- Métricas
        e.salario_base,
        e.comision_pct,
        e.ventas_mes,
        e.comision_monto,
        e.salario_total,
        
        -- Metadata
        e.fecha_proceso
        
    FROM empleados_staging e
    
    LEFT JOIN {{ ref('dim_empleados') }} emp
        ON e.empleado_id = emp.empleado_id
    
    WHERE emp.empleado_key IS NOT NULL
)

SELECT * FROM facts_comisiones