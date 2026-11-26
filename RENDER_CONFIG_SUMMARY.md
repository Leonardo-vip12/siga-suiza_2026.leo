=================================================================
  SIGA SUZIA 2026 - CONFIGURACIÓN RENDER SINGLE-CONTAINER
=================================================================

FUNCIONALIDAD: Todo en un solo contenedor Render (puerto 8000)
ANTERIOR: Configuración Railway (7 servicios en puertos 8001-8009)
ACTUAL: Configuración Render optimizada para un solo contenedor

=================================================================
PASO 1: Variables de Entorno OBLIGATORIAS en Render Dashboard
=================================================================

Ve a tu servicio Backend (SIGA Core) ▶ Settings ▶ Environment

Agrega ESTA variable exactamente:

  SIGA_MODULE_URL_BASE = https://siga-suiza-20-26.onrender.com

¿Para qué sirve?
- Transforma automáticamente http://localhost:${PORT:-8001} en los manifiestos
  a https://siga-suiza-20-26.onrender.com:8001
- Sin esto, los módulos quedan OFFLINE con URLs rotas
- Esta es la variable más importante después de agregar el código fix

Opcional (si tu dominio frontend es diferente):
  FRONTEND_ORIGIN = https://TU-FRONTEND.onrender.com

Opcional (Render lo inyecta automatico):
  DATABASE_URL = postgres://... (lo inyecta Render automatico)

=================================================================
PASO 2: Variables en el Frontend Render
=================================================================

Ve a tu servicio Frontend en Render ▶ Settings ▶ Environment

Agrega:

  VITE_API_URL = https://siga-suiza-20-26.onrender.com
  VITE_WS_URL = wss://siga-suiza-20-26.onrender.com

=================================================================
PASO 3: Desplegar
=================================================================

1. Haz clic en "Trigger deploy" ▶ "Start new deploy"
2. Espera 3-5 minutos
3. Verifica los logs

=================================================================
PASO 4: Verificar Resultado EXITOSO
================================================================ espero que veas en los logs:

  ✅ mod-usuarios v1.0.0 - healthy [Std: ✓]
  ✅ mod-admision v1.0.0 - healthy [Std: ✓]
  ✅ mod-programas-estudio v1.0.0 - healthy [Std: ✓]
  ✅ mod-gestion-academica v2.0.0 - healthy [Std: ✓]
  ✅ mod-evaluacion v1.0.0 - healthy [Std: ✓]
  ✅ mod-planes-estudio v1.0.0 - healthy [Std: ✓]
  ✅ mod-auditoria v1.0.0 - healthy [Std: ✓]

EN LUGAR DE:

  ⚠️ mod-usuarios v1.0.0 - offline [Std: ✓]
  ⚠️ mod-admision v1.0.0 - offline [Std: ✓]
  ⚠️ ... (todos offline)

=================================================================
PASO 4: ¿Por qué esta configuración es definitiva?

=================================================================
✅ Arquitectura Single-Container: Todo en un solo servicio Render puerto 8000
✅ Variable SIGA_MODULE_URL_BASE: Resuelve URLs automaticamente
✅ Código fix compliance->HEALTHY: Si validation pasa (5/5 steps), módulo ES healthy
✅ Sin configuracion Railway: Quitado start_railway.sh, variables railway
✅ .env.example actualizado: Solo variables Render obligatorias
✅ Sin multiples puertos 8001-8009: Ya no necesarios

=================================================================
ARCHIVOS MODIFICADOS RESUMEN:
=================================================================
✅ siga_backend/start_render.sh - Nuevo script Render single-container
✅ siga_backend/.env.example - Config Render obligatorias
✅ siga_backend/modules/.env.example - Simplificado single-container
✅ siga_backend/app/core/registry/runtime.py - Fix compliance->HEALTHY
✅ Código main commit c23c9a4 - Ya subido a GitHub

=================================================================
¿DUDAS? Lo mas común es olvidar agregar SIGA_MODULE_URL_BASE en el panel
de Render. Si despues del deploy sigues viendo modules offline, revisa
que esa variable este puesta exactamente asi:

  Name: SIGA_MODULE_URL_BASE
  Value: https://siga-suiza-20-26.onrender.com

=================================================================