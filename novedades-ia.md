---
name: novedades-ia
description: Busca, filtra y reporta novedades recientes de Claude Code, Anthropic y herramientas IA relevantes para consultoría y contratación pública colombiana. Sin videos, sin relleno — solo lo que aplica directamente al flujo de trabajo de CAHZ. Puede invocarse manualmente o desde la tarea programada semanal.
---

# novedades-ia — Digest semanal de novedades IA

Invocar cuando el usuario diga:
- "qué hay de nuevo en claude", "novedades ia", "algo nuevo esta semana"
- "qué salió?", "hay actualizaciones?", "revisa novedades"
- O desde la tarea programada semanal (lunes 9am)

---

## Paso 1 — Buscar en fuentes primarias (lanzar en paralelo)

```
# Changelog y docs de Claude Code
firecrawl_scrape("https://code.claude.com/docs/en/")
firecrawl_scrape("https://www.anthropic.com/news")

# Búsquedas recientes (últimos 7 días: tbs="qdr:w")
firecrawl_search("Claude Code new feature release 2026", limit=5, tbs="qdr:w")
firecrawl_search("Anthropic release announcement June 2026", limit=5, tbs="qdr:w")
firecrawl_search("Claude Code /goal /routines /loop update", limit=3, tbs="qdr:w")
firecrawl_search("new MCP server document automation 2026", limit=3, tbs="qdr:w")
firecrawl_search("Claude Code model config pricing update 2026", limit=3, tbs="qdr:w")
```

No buscar en YouTube ni en blogs de terceros como fuente primaria.
Si un video menciona algo nuevo, buscar la fuente oficial (docs.anthropic.com, code.claude.com) y citar esa, no el video.

---

## Paso 2 — Filtrar con criterio de relevancia para CAHZ

### Mantener (aplica directamente):
- ✅ Claude Code: nuevos comandos (/goal, /loop, /routines, otros), settings, hooks, flags
- ✅ Modelos nuevos o cambios de precios (afecta estrategia de costo)
- ✅ MCPs nuevos: documentos, PDF, correo, calendario, planillas, búsqueda web
- ✅ Automatización de flujos: routines locales y remotas, agentes, loops
- ✅ Generación y procesamiento de documentos Word / PDF / Excel
- ✅ Integraciones con Gmail, Google Calendar, Drive, Teams, Notion
- ✅ Capacidades de agentes y orquestación multi-tarea
- ✅ Actualizaciones de herramientas que CAHZ ya usa (Firecrawl, claude-mem, etc.)
- ✅ Cualquier cosa que reduzca el tiempo o el costo en las tareas de contratación pública

### Descartar sin mencionar:
- ❌ Gaming, entretenimiento, redes sociales
- ❌ Herramientas de desarrollo de software (salvo si impactan Claude Code directamente)
- ❌ Finanzas personales, trading, criptomonedas
- ❌ Herramientas de imagen, video, audio
- ❌ Integraciones con apps que CAHZ no usa
- ❌ Novedades de OpenAI, Gemini, Llama u otros competidores (salvo que ofrezcan algo muy concreto y superior)

---

## Paso 3 — Generar reporte estructurado

```
══════════════════════════════════════════════════════════
NOVEDADES IA — [FECHA_INICIO] al [FECHA_FIN]
Relevantes para: consultoría TIC · contratación pública · Claude Code
══════════════════════════════════════════════════════════

🔴 IMPACTO ALTO — Úselo ya
  [N]. [NOMBRE CONCRETO DE LA NOVEDAD]
       Qué es: [máximo 1 oración]
       Para su trabajo: [aplicación concreta al flujo de CAHZ]
       Cómo activarlo: [comando, setting, URL exacta o instrucción]

🟠 IMPACTO MEDIO — Vale la pena explorar
  ...

🟡 PARA SABER — Sin acción inmediata
  ...

Sin novedades relevantes esta semana: [si no hay nada que pase el filtro]
══════════════════════════════════════════════════════════
Fuentes revisadas: [lista de URLs oficiales consultadas]
Novedades descartadas por irrelevancia: [número] (no se detallan)
```

---

## Reglas editoriales (no negociables)

1. **Nunca mencionar un video** sin haber extraído primero el contenido técnico real de la fuente oficial. Si la única fuente es YouTube → buscar la documentación oficial o descartar.
2. **Máximo 2 líneas por novedad.** Si no cabe en 2 líneas, es demasiado abstracto para ser accionable.
3. **Nunca decir "hay un video sobre X".** Decir directamente qué cambió y cómo usarlo.
4. **Citar siempre la URL oficial**, no la del video ni la del blog.
5. Si algo requiere leer 30 páginas de docs para ser aplicable → marcarlo como 🟡 con un link, no como 🔴.
6. **Comparar con lo que CAHZ ya tiene.** Si la novedad ya está cubierta por un skill existente → no incluirla o indicar "ya cubierto por [skill]".

---

## Paso 4 — Registrar en memoria

Al terminar, guardar en claude-mem:
```
observation_add({
  title: "Novedades IA semana [FECHA]",
  content: [resumen de lo reportado],
  tags: ["novedades-ia", "semanal"]
})
```

Esto evita repetir la misma novedad en el reporte de la semana siguiente.

---

## Paso 5 — Guardar reporte

Si el usuario pide guardarlo:
- Borrador → `~/Downloads/NOVEDADES_IA_[YYYY-MM-DD].md`
- Solo si el usuario aprueba → mover a `iCloud/Trabajo/CONTRATACION/PERSONAL/DOCUMENTOS/`
