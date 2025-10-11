#!/bin/bash
set -e

echo "🚀 Iniciando dbt runner..."

# Variables requeridas
: ${DBT_PROJECT_ID:?"DBT_PROJECT_ID no configurado"}
: ${DBT_BUCKET:?"DBT_BUCKET no configurado"}

echo "📋 Configuración:"
echo "   Proyecto: $DBT_PROJECT_ID"
echo "   Dataset: $DBT_DATASET"
echo "   Bucket: $DBT_BUCKET"
echo "   Location: $DBT_LOCATION"

# Descargar proyecto dbt desde GCS
echo "📥 Descargando proyecto dbt desde GCS..."
gsutil -m cp "gs://${DBT_BUCKET}/dbt-project.tar.gz" /tmp/dbt-project.tar.gz

# Verificar descarga
if [ ! -f /tmp/dbt-project.tar.gz ]; then
    echo "❌ Error: No se pudo descargar el proyecto dbt"
    exit 1
fi

echo "📦 Tamaño descargado: $(du -h /tmp/dbt-project.tar.gz | cut -f1)"

# Descomprimir
echo "📂 Descomprimiendo proyecto..."
tar -xzf /tmp/dbt-project.tar.gz -C /dbt

# Verificar estructura
echo "📁 Estructura del proyecto:"
ls -la /dbt/

# Instalar dependencias dbt
echo "📦 Instalando paquetes dbt..."
cd /dbt
dbt deps

# Compilar (verificar sintaxis)
echo "🔍 Compilando modelos..."
dbt compile

# Si los tests pasan, ejecutar transformaciones
echo "🔄 Ejecutando transformaciones dbt..."

echo "1️⃣ Staging models..."
dbt run --select staging.* --profiles-dir .

echo "✅ Ejecutando tests de calidad Staging..."
dbt test --select staging.* --profiles-dir .

echo "2️⃣ Dimension models..."
dbt run --select dimensions.* --profiles-dir .

echo "3️⃣ Fact models..."
dbt run --select facts.* --profiles-dir .

echo "✅ Ejecutando tests de calidad Dimension..."
dbt test --select dimensions.* --profiles-dir .

echo "✅ Ejecutando tests de calidad Fact..."
dbt test --select facts.* --profiles-dir .

echo "4️⃣ Marts models..."
dbt run --select marts.* --profiles-dir .

# Ejecutar tests finales
echo "✅ Ejecutando tests de calidad Marts..."
dbt test --select marts.* --profiles-dir .

echo "✅ dbt ejecutado exitosamente"