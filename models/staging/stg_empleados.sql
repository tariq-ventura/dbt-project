{{
    config(
        materialized='view'
    )
}}

WITH source_data AS (
    SELECT *
    FROM {{ source('staging', 'empleados_raw') }}
),

cleaned AS (
    SELECT
        CAST(EmpleadoID AS INT64) as empleado_id,
        TRIM(Nombre) as empleado_nombre,
        TRIM(Puesto) as puesto,
        CAST(SalarioBaseUSD AS FLOAT64) as salario_base,
        CAST(ComisionPct AS FLOAT64) as comision_pct,
        CAST(VentasMesUSD AS FLOAT64) as ventas_mes,
        CAST(ComisionUSD AS FLOAT64) as comision_monto,
        CAST(SalarioTotalUSD AS FLOAT64) as salario_total,
        CURRENT_TIMESTAMP() as fecha_proceso
    FROM source_data
    WHERE EmpleadoID IS NOT NULL
)

SELECT * FROM cleaned