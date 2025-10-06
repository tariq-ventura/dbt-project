# SunTech Solar Data Warehouse - dbt Project

## 📊 Descripción del Proyecto

Este es un proyecto dbt (Data Build Tool) diseñado para construir un Data Warehouse dimensional para **SunTech Solar**, una empresa de paneles solares en El Salvador. El proyecto implementa un modelo dimensional (Star Schema) optimizado para análisis de ventas, comisiones y rendimiento de empleados.

## 🏗️ Arquitectura del Proyecto

### Capas de Datos

1. **Staging Layer** (`models/staging/`)
   - `stg_ventas.sql`: Transacciones de ventas limpias y normalizadas
   - `stg_productos.sql`: Catálogo de productos con precios y costos
   - `stg_vendedores.sql`: Métricas de desempeño de vendedores
   - `stg_empleados.sql`: Salarios y comisiones de empleados

2. **Dimension Layer** (`models/dimensions/`)
   - `dim_productos.sql`: Dimensión de productos con métricas de margen
   - `dim_vendedores.sql`: Dimensión de vendedores con nombre/apellido
   - `dim_empleados.sql`: Dimensión de empleados con categorización por puesto
   - `dim_sucursales.sql`: Dimensión de sucursales
   - `dim_tiempo.sql`: Dimensión de tiempo con atributos calendario

3. **Fact Layer** (`models/facts/`)
   - `fact_ventas.sql`: Tabla de hechos de ventas (incremental, particionada)
   - `fact_comisiones.sql`: Tabla de hechos de comisiones (incremental, particionada)

## 🛠️ Tecnología

- **Plataforma**: Google BigQuery
- **Herramienta**: dbt Core
- **Paquetes**: 
  - `dbt_utils` v1.1.1

## ⚙️ Configuración

### Variables de Entorno Requeridas

```bash
export DBT_PROJECT_ID="your-gcp-project-id"
export DBT_DATASET="staging"  # o el nombre de tu dataset
export DBT_LOCATION="US"  # o tu región preferida
```

### Comprimir proyecto
```bash
tar -czf dbt-project.tar.gz \
    --exclude='dbt-project/.git' \
    --exclude='dbt-project/*.pyc' \
    --exclude='dbt-project/__pycache__' \
    --exclude='dbt-project/venv' \
    --exclude='dbt-project/target' \
    --exclude='dbt-project/dbt_packages' \
    --exclude='dbt-project/logs' \
    dbt-project/
```