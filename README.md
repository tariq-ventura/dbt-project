# SunTech Solar Data Warehouse - dbt Project

## 📊 Descripción del Proyecto

Este es un proyecto dbt (Data Build Tool) diseñado para construir un Data Warehouse dimensional para **SunTech Solar**, una empresa de paneles solares en El Salvador. El proyecto implementa un modelo dimensional (Star Schema) optimizado para análisis de ventas, comisiones y rendimiento de empleados.

## 🏗️ Arquitectura del Proyecto

### Capas de Datos

El proyecto sigue una arquitectura de capas (layered architecture) que separa las responsabilidades y optimiza el flujo de datos desde el origen hasta el consumo final.

#### 1. **Staging Layer** (`models/staging/`)

**Propósito:** Capa de limpieza y estandarización de datos crudos.

**Características:**
- **Materialización:** `VIEW` (vistas, no se almacenan físicamente)
- **Responsabilidad:** Limpieza básica, conversión de tipos de datos, renombrado de columnas
- **Contenido:** Réplica 1:1 de las tablas de origen, pero con datos limpios y consistentes
- **No contiene:** Lógica de negocio compleja, joins, agregaciones

**Modelos:**
- `stg_ventas.sql`: Transacciones de ventas limpias y normalizadas
- `stg_productos.sql`: Catálogo de productos con precios y costos
- `stg_vendedores.sql`: Métricas de desempeño de vendedores
- `stg_empleados.sql`: Salarios y comisiones de empleados

**Ejemplo de transformación:** `TRIM(Nombre)`, `CAST(Precio AS FLOAT64)`, renombrar `VendedorID` a `vendedor_id`

---

#### 2. **Dimension Layer** (`models/dimensions/`)

**Propósito:** Tablas maestras que contienen los atributos descriptivos del negocio.

**Características:**
- **Materialización:** `TABLE` (tablas físicas almacenadas)
- **Responsabilidad:** Crear claves subrogadas (surrogate keys), consolidar atributos, agregar lógica de negocio
- **Contenido:** Entidades del negocio con sus atributos y métricas calculadas
- **Optimización:** Usa claves numéricas (`producto_key`, `vendedor_key`) para joins eficientes

**Modelos:**
- `dim_productos.sql`: Dimensión de productos con métricas de margen y categorización
- `dim_vendedores.sql`: Dimensión de vendedores con nombre/apellido separados
- `dim_empleados.sql`: Dimensión de empleados con categorización por puesto
- `dim_sucursales.sql`: Dimensión de sucursales con información geográfica
- `dim_tiempo.sql`: Dimensión de tiempo con atributos calendario (año, mes, trimestre, día de semana)

**Ventajas de usar claves numéricas:**
- Joins 10-100x más rápidos que usar strings
- Permite manejar cambios en atributos (SCD - Slowly Changing Dimensions)
- Facilita el mantenimiento histórico

---

#### 3. **Fact Layer** (`models/facts/`)

**Propósito:** Tablas de hechos que contienen las métricas y eventos del negocio.

**Características:**
- **Materialización:** `INCREMENTAL` (carga solo datos nuevos)
- **Responsabilidad:** Registrar transacciones, calcular métricas de negocio, unir dimensiones usando claves
- **Contenido:** Eventos medibles (ventas, comisiones) con referencias a dimensiones
- **Optimización:** Particionado por fecha, clusterizado por claves frecuentemente consultadas

**Modelos:**
- `fact_ventas.sql`: Tabla de hechos de ventas (incremental, particionada por mes, clusterizada por vendedor y producto)
- `fact_comisiones.sql`: Tabla de hechos de comisiones (incremental, particionada por período mensual)

**Métricas calculadas:** Utilidad, margen de utilidad, descuentos, comisiones

**Ventajas de la carga incremental:**
- Solo procesa datos nuevos (eficiente)
- Reduce tiempo de ejecución
- Minimiza costos de procesamiento en BigQuery

---

#### 4. **Marts Layer** (`models/marts/`)

**Propósito:** Capa de presentación optimizada para el consumo final (BI, reportes, analistas).

**Características:**
- **Materialización:** `TABLE` (tablas físicas, listas para consultar)
- **Responsabilidad:** Unir hechos con dimensiones, reemplazar claves por nombres legibles, crear vistas desnormalizadas
- **Contenido:** Tablas "anchas" y fáciles de entender, optimizadas para herramientas de BI (Looker Studio, Power BI, Tableau)
- **No contiene:** Claves técnicas, solo nombres y descripciones del negocio

**Modelos:**
- `reporte_ventas_detalle.sql`: Vista completa de ventas con nombres de productos, vendedores y sucursales
- `reporte_comisiones_mensuales.sql`: Reporte de comisiones con nombres de empleados y desglose de salarios

**Diferencia clave con Facts:** Las tablas Marts son para **humanos** (legibles), las Facts son para **máquinas** (eficientes).

---

### 📊 Comparación de Capas

| Aspecto | Staging | Dimensions | Facts | Marts |
|---------|---------|------------|-------|-------|
| **Materialización** | VIEW | TABLE | INCREMENTAL | TABLE |
| **Propósito** | Limpieza | Maestros | Transacciones | Reportes |
| **Joins** | ❌ No | ❌ No | ✅ Sí (para obtener keys) | ✅ Sí (para obtener nombres) |
| **Claves** | Natural keys (IDs originales) | Surrogate keys (generadas) | Foreign keys (referencias) | Sin keys (solo nombres) |
| **Audiencia** | Desarrolladores | Data Engineers | Data Engineers | Analistas/BI |
| **Rendimiento** | Rápido (es vista) | Moderado | Optimizado (particionado) | Rápido (pre-calculado) |
| **Actualización** | Cada ejecución | Cada ejecución | Solo nuevos datos | Cada ejecución |

---

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
    .
```

### visualizar datos dentro del tar.gz

```bash
tar -tvf dbt-project.tar.gz
```

### Subir cambios
```bash
gsutil cp dbt-project.tar.gz gs://dw-development-dbt-project/dbt-project.tar.gz
```