#!/bin/sh
set -e

echo "=========================================="
echo "🚀 Iniciando SIGA Backend (Render)"
echo "=========================================="

PORT="${PORT:-8000}"
export PORT
echo "📡 Puerto principal: $PORT"

cleanup() {
    echo "🛑 Deteniendo servicios internos..."
    kill 0 2>/dev/null || true
    exit 0
}
trap cleanup EXIT INT TERM

if [ -n "$DATABASE_URL" ]; then
    echo "📦 DATABASE_URL detectada de Render."
    export DB_URL="$DATABASE_URL"
fi

if [ "$SKIP_MIGRATIONS" != "true" ]; then
    echo "🔄 Ejecutando migraciones de base de datos..."
    alembic upgrade head || echo "⚠️ Alembic upgrade head falló o fue omitido — continuando..."
fi

# 🎯 CONFIGURACIÓN RENDER SINGLE-CONTAINER
# En Render todo está en un solo contenedor, por lo que:
# - Los módulos no están en puertos separados 8001-8009
# - Las URLs de los módulos se resuelven usando SIGA_MODULE_URL_BASE
# - La validation compliance (5/5 steps) garantiza que los módulos sean HEALTHY
# 
# Variable obligatoria en Render Dashboard:
#   SIGA_MODULE_URL_BASE=https://TU-SUBDOMAIN.onrender.com
#
# Con esta variable, la función _resolve_endpoints() en runtime.py
# transformará automáticamente http://localhost:${PORT:-8001}
# a https://TU-SUBDOMAIN.onrender.com:8001

echo "⚙️ Iniciando Core Gateway en 0.0.0.0:$PORT..."
exec python -m uvicorn app.main:app --host 0.0.0.0 --port "$PORT"