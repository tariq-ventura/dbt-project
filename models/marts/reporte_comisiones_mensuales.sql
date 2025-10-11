{{
    config(
        materialized='table',
        partition_by={
            'field': 'periodo_mes',
            'data_type': 'date'
        },
        cluster_by=['empleado_nombre', 'puesto']
    )
}}

SELECT
    -- Atributos descriptivos de la dimensión de empleados
    emp.empleado_nombre,
    emp.puesto,
    
    -- Período de la comisión
    f.periodo_mes,
    
    -- Métricas de comisiones y salario
    f.salario_base,
    f.comision_pct,
    f.ventas_mes,
    f.comision_monto,
    f.salario_total

FROM {{ ref('fact_comisiones') }} f

LEFT JOIN {{ ref('dim_empleados') }} emp
    ON f.empleado_key = emp.empleado_key