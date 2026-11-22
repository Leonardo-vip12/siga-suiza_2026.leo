#!/bin/sh
set -e

if [ "$SKIP_MIGRATIONS" != "true" ]; then
    # Build DB URL for Alembic
    if [ -z "$DB_URL" ]; then
        if [ -n "$DATABASE_URL" ]; then
            export DB_URL="$DATABASE_URL"
        else
            export DB_URL="postgresql+asyncpg://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
        fi
    fi

    echo "Running database migrations..."
    if ! alembic upgrade head; then
        echo "ERROR: alembic upgrade head failed. Aborting startup."
        exit 1
    fi
    echo "Migrations applied successfully."
fi

if [ "$#" -eq 0 ]; then
    echo "Starting SIGA Core..."
    exec uvicorn app.main:app --host 0.0.0.0 --port $PORT
else
    echo "Starting Module with command: $@"
    exec "$@"
fi