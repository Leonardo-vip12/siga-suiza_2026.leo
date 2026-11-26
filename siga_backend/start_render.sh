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

# DATABASE_URL de Render
if [ -n "$DATABASE_URL" ]; then
    export DB_URL="$DATABASE_URL"
fi

# Configuración obligatoria
export DB_URL="$DATABASE_URL"
unset SIGA_MODULE_URL_BASE    # importante: anula la variable base global
export ENABLE_NATS=False       # evita ERROR "conectando a NATS" en logs

# Overrides de URLs de módulos (127.0.0.1) — toman precedencia sobre SIGA_MODULE_URL_BASE
export SIGA_MODULE_USUARIOS_URL=http://127.0.0.1:8001
export SIGA_MODULE_PLANES_ESTUDIO_URL=http://127.0.0.1:8002
export SIGA_MODULE_PROGRAMAS_ESTUDIO_URL=http://127.0.0.1:8005
export SIGA_MODULE_GESTION_ACADEMICA_URL=http://127.0.0.1:8006
export SIGA_MODULE_AUDITORIA_URL=http://127.0.0.1:8007
export SIGA_MODULE_EVALUACION_URL=http://127.0.0.1:8008
export SIGA_MODULE_ADMISION_URL=http://127.0.0.1:8009

# Función de espera de salud usando Python (urllib, sin necesidad de curl)
wait_health() {
    local url="$1"
    python -c "import sys,urllib.request,time; [exit(0) if __import__('urllib.request').urlopen(sys.argv[1],timeout=2).status==200 else exit(1)]" "$url"
}

# Migraciones
if [ -n "$DB_URL" ]; then
    echo "🔄 Ejecutando migraciones de base de datos..."
    alembic upgrade head || echo "⚠️ Alembic upgrade head falló o fue omitido — continuando..."
fi

echo "🔄 Arrancando módulos (saludable en serie)..."

# Módulo: mod-usuarios (puerto 8001)
( cd /app && python -m uvicorn main:app --host 127.0.0.1 --port 8001 --app-dir /app/modules/mod-usuarios ) &
wait_health "http://127.0.0.1:8001/health" || echo "⚠️  mod-usuarios no respondió health check a tiempo"

# Módulo: mod-planes-estudio (puerto 8002)
( cd /app && python -m uvicorn main:app --host 127.0.0.1 --port 8002 --app-dir /app/modules/mod-planes-estudio ) &
wait_health "http://127.0.0.1:8002/health" || echo "⚠️  mod-planes-estudio no respondió health check a tiempo"

# Módulo: mod-programas-estudio (puerto 8005)
( cd /app && python -m uvicorn main:app --host 127.0.0.1 --port 8005 --app-dir /app/modules/mod-programas-estudio ) &
wait_health "http://127.0.0.1:8005/health" || echo "⚠️  mod-programas-estudio no respondió health check a tiempo"

# Módulo: mod-gestion-academica (puerto 8006)
( cd /app && python -m uvicorn main:app --host 127.0.0.1 --port 8006 --app-dir /app/modules/mod-gestion-academica ) &
wait_health "http://127.0.0.1:8006/health" || echo "⚠️  mod-gestion-academica no respondió health check a tiempo"

# Módulo: mod-auditoria (puerto 8007)
( cd /app && python -m uvicorn main:app --host 127.0.0.1 --port 8007 --app-dir /app/modules/mod-auditoria ) &
wait_health "http://127.0.0.1:8007/health" || echo "⚠️  mod-auditoria no respondió health check a tiempo"

# Módulo: mod-evaluacion (puerto 8008)
( cd /app && python -m uvicorn main:app --host 127.0.0.1 --port 8008 --app-dir /app/modules/mod-evaluacion ) &
wait_health "http://127.0.0.1:8008/health" || echo "⚠️  mod-evaluacion no respondió health check a tiempo"

# Módulo: mod-admision (puerto 8009)
( cd /app && python -m uvicorn main:app --host 127.0.0.1 --port 8009 --app-dir /app/modules/mod-admision ) &
wait_health "http://127.0.0.1:8009/health" || echo "⚠️  mod-admision no respondió health check a tiempo"

echo "🐘 Iniciando Core Gateway en 0.0.0.0:$PORT..."
exec python -m uvicorn app.main:app --host 0.0.0.0 --port "$PORT"