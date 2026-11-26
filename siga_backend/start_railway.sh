#!/bin/sh
set -e

echo "=========================================="
echo "🚀 Iniciando SIGA Backend (Railway)"
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
    echo "📦 DATABASE_URL detectada de Railway."
    export DB_URL="$DATABASE_URL"
fi

if [ "$SKIP_MIGRATIONS" != "true" ]; then
    echo "🔄 Ejecutando migraciones de base de datos..."
    alembic upgrade head || echo "⚠️ Alembic upgrade head falló o fue omitido — continuando..."
fi

# Módulos: usar las URLs desde variables de entorno si están definidas,
# sino caer back a localhost para deployments donde todos los servicios
# corren en el mismo host (Render, Railway desarrollo).
# La variable SIGA_MODULE_URL_BASE se puede setear para sobreescribir el prefijo base.
MODULE_URL_BASE="${SIGA_MODULE_URL_BASE:-http://localhost}"

# Si vienen definidas las URLs individuales, úsalas; si no, construir con localhost
SIGA_MODULE_USUARIOS_URL="${SIGA_MODULE_USUARIOS_URL:-${MODULE_URL_BASE}:8001}"
SIGA_MODULE_PLANES_ESTUDIO_URL="${SIGA_MODULE_PLANES_ESTUDIO_URL:-${MODULE_URL_BASE}:8002}"
SIGA_MODULE_PROGRAMAS_ESTUDIO_URL="${SIGA_MODULE_PROGRAMAS_ESTUDIO_URL:-${MODULE_URL_BASE}:8005}"
SIGA_MODULE_GESTION_ACADEMICA_URL="${SIGA_MODULE_GESTION_ACADEMICA_URL:-${MODULE_URL_BASE}:8006}"
SIGA_MODULE_AUDITORIA_URL="${SIGA_MODULE_AUDITORIA_URL:-${MODULE_URL_BASE}:8007}"
SIGA_MODULE_EVALUACION_URL="${SIGA_MODULE_EVALUACION_URL:-${MODULE_URL_BASE}:8008}"
SIGA_MODULE_ADMISION_URL="${SIGA_MODULE_ADMISION_URL:-${MODULE_URL_BASE}:8009}"

echo "⚙️ Levantando 7 microservicios internos..."
python -m uvicorn main:app --host 127.0.0.1 --port 8001 --app-dir modules/mod-usuarios &
python -m uvicorn main:app --host 127.0.0.1 --port 8002 --app-dir modules/mod-planes-estudio &
python -m uvicorn main:app --host 127.0.0.1 --port 8005 --app-dir modules/mod-programas-estudio &
python -m uvicorn main:app --host 127.0.0.1 --port 8006 --app-dir modules/mod-gestion-academica &
python -m uvicorn main:app --host 127.0.0.1 --port 8007 --app-dir modules/mod-auditoria &
python -m uvicorn main:app --host 127.0.0.1 --port 8008 --app-dir modules/mod-evaluacion &
python -m uvicorn main:app --host 127.0.0.1 --port 8009 --app-dir modules/mod-admision &

sleep 2

echo "🌐 Iniciando Core Gateway en 0.0.0.0:$PORT..."
exec python -m uvicorn app.main:app --host 0.0.0.0 --port "$PORT"
