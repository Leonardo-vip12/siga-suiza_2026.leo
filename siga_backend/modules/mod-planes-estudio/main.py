from routes import router

# Router del módulo mod-planes-estudio
# Este router se incluirá en la aplicación FastAPI principal
# Endpoints disponibles:
#   GET /health
#   GET /manifest
#   POST /planes/parse-minedu
#   POST /planes/importar-minedu
#   GET /planes
#   GET /planes/{plan_id}
#   GET /planes/{plan_id}/estructura
#   PUT /planes/{plan_id}
#   DELETE /planes/{plan_id}
#   POST /planes/{plan_id}/modulos
#   POST /modulos/{modulo_id}
#   DELETE /modulos/{modulo_id}
#   POST /modulos/{modulo_id}/unidades
#   PUT /unidades/{unidad_id}
#   DELETE /unidades/{unidad_id}

__all__ = ["router"]