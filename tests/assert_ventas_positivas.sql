SELECT *
FROM {{ ref('fact_ventas') }}
WHERE total_venta <= 0