---
name: revisar-sesion
description: Revisión de cierre de sesión — detecta patrones repetibles, sugiere nuevos skills o agentes, verifica consistencia de carpetas y genera lista de pendientes para la próxima sesión. Invocar al final de cada jornada de trabajo.
---

# revisar-sesion — Revisión inteligente de cierre de sesión

Invocar cuando el usuario diga:
- "revisa la sesión de hoy"
- "qué podríamos sistematizar?"
- "qué quedó pendiente?"
- "sugiere automatizaciones"
- O al detectar que se está cerrando una sesión larga (>30 min de trabajo)

---

## Paso 1 — Recuperar contexto de la sesión

Usar `claude-mem` para revisar observaciones recientes:

```
mcp__plugin_claude-mem_mcp-search__observation_search("sesión hoy")
mcp__plugin_claude-mem_mcp-search__timeline({limit: 20})
```

Si no hay memoria disponible, usar el historial de la conversación actual.

---

## Paso 2 — Identificar patrones repetibles

Analizar qué tareas se realizaron y clasificar cada una:

| Categoría | Señal | Acción sugerida |
|---|---|---|
| **Repetición manual** | Se hizo la misma tarea 2+ veces en la sesión | Proponer skill nuevo |
| **Proceso multi-paso** | Se siguieron >3 pasos para completar algo | Proponer agente |
| **Búsqueda de archivos** | Se buscó un archivo más de 1 vez | Proponer índice o script |
| **Formato repetido** | Se usó el mismo template varias veces | Proponer generador |
| **Validación manual** | Se verificó manualmente algo que Claude podría verificar | Proponer skill de verificación |
| **Corrección de errores** | Se corrigió algo que un skill debería prevenir | Proponer mejora al skill existente |

---

## Paso 3 — Verificar consistencia de carpetas

Revisar que las carpetas clave existan y no tengan anomalías:

```bash
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs"

# Carpetas que siempre deben existir
echo "=== CARPETAS CLAVE ==="
for ruta in \
  "$ICLOUD/appcontratistas/ubpd/otic-2s2026/_ENTRADA" \
  "$ICLOUD/appcontratistas/ubpd/otic-2s2026/docs" \
  "$ICLOUD/appcontratistas/ubpd/otic-2s2026/datos" \
  "$ICLOUD/appcontratistas/habitat" \
  "$ICLOUD/claude-commands" \
  "$ICLOUD/Trabajo/CONTRATACION/UBPD" \
  "$ICLOUD/Trabajo/CONTRATACION/HABITAT" \
  "$ICLOUD/Trabajo/CONTRATACION/SNR"; do
  [ -d "$ruta" ] && echo "  ✅ $(basename $ruta)" || echo "  ❌ FALTA: $ruta"
done

# Archivos en _ENTRADA sin procesar
echo ""
echo "=== ZIPs PENDIENTES EN _ENTRADA ==="
find "$ICLOUD/appcontratistas/ubpd/otic-2s2026/_ENTRADA" -maxdepth 1 -name "*.zip" 2>/dev/null | wc -l | xargs echo "  ZIPs pendientes:"

# Archivos grandes en Downloads
echo ""
echo "=== DESCARGAS PENDIENTES DE CLASIFICAR ==="
find "$HOME/Downloads" -maxdepth 1 -newer "$HOME/Downloads" -not -name ".*" 2>/dev/null | wc -l | xargs echo "  Archivos en Downloads:"

# Último backup
echo ""
echo "=== ÚLTIMO BACKUP ==="
cd "$ICLOUD/claude-commands" && git log --oneline -1 2>/dev/null || echo "  Sin información de git"
```

---

## Paso 4 — Detectar discrepancias entre sistemas

Verificar que no haya inconsistencias entre:
- **CLAUDE.md** y los archivos `.md` reales en `claude-commands/` (skills documentados pero inexistentes, o existentes pero no documentados)
- **Dashboard PROCESAR_LOTE.html** y el estado real de `docs/{cedula}/` (contratistas con docs pero marcados como faltantes)
- **MONITOR_CONTRATOS.html** y contratos que vencen pronto no registrados

```bash
CLAUDE_COMMANDS="$HOME/Library/Mobile Documents/com~apple~CloudDocs/claude-commands"

echo "=== SKILLS EN DISCO vs CLAUDE.md ==="
ls "$CLAUDE_COMMANDS"/*.md 2>/dev/null | grep -v CLAUDE.md | xargs -I{} basename {} .md | sort > /tmp/skills_disco.txt
echo "  Skills en disco: $(wc -l < /tmp/skills_disco.txt | tr -d ' ')"
```

---

## Paso 5 — Generar reporte de cierre

Producir un reporte estructurado con:

```
═══════════════════════════════════════════════════
REVISIÓN DE SESIÓN — [FECHA HOY]
═══════════════════════════════════════════════════

📋 LO QUE SE HIZO HOY
  • [lista de tareas completadas por entidad]

⚡ PATRONES DETECTADOS — Candidatos a automatización
  1. [patrón] → [sugerencia concreta: nuevo skill / mejorar skill / crear agente]
  2. ...

📁 ESTADO DE CARPETAS
  ✅ / ❌ por carpeta clave
  ZIPs pendientes en _ENTRADA: N
  Archivos en Downloads: N

⚠️ INCONSISTENCIAS DETECTADAS
  [lista o "Ninguna detectada"]

📌 PENDIENTES PARA LA PRÓXIMA SESIÓN
  • [entidad] — [tarea pendiente] — [prioridad: ALTA/MEDIA/BAJA]

🔧 ACCIONES RECOMENDADAS ANTES DE CERRAR
  □ Ejecutar 📋 Clasificar Pendientes (si hay archivos en Downloads)
  □ Ejecutar 📤 GUARDAR TRABAJO (siempre)
  □ [acción específica si se detectó inconsistencia]
═══════════════════════════════════════════════════
```

---

## Paso 6 — Registrar en memoria

Guardar observación en claude-mem con los campos:
- **Entidad:** [entidad(es) trabajadas]
- **Fecha:** [hoy]
- **Tipo:** revisión de sesión
- **Descripción:** resumen de 1-2 líneas de lo que se hizo
- **Producto entregado:** lista de archivos generados (si aplica)

```
mcp__plugin_claude-mem_mcp-search__observation_add({
  "title": "Sesión [FECHA] — [ENTIDAD]",
  "content": "[resumen]",
  "tags": ["sesion", "entidad", "cierre"]
})
```

---

## Notas de uso

- Este skill es **rápido** (2-3 minutos) — no genera documentos, solo análisis y recomendaciones
- Si detecta un patrón con alta frecuencia, preguntar: *"¿Quiere que cree el skill [nombre] ahora o lo dejo para la próxima sesión?"*
- No tomar acción automática sobre archivos — solo reportar y sugerir
- Los pendientes identificados aquí son el insumo para el siguiente `productivity:start`
