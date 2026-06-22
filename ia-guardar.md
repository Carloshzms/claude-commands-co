# ia-guardar — Validador de destino para archivos de configuración IA

Antes de crear o guardar cualquier archivo relacionado con IA, Claude Code o configuración del sistema, aplica este skill para determinar la ruta correcta en iCloud y garantizar que nada quede en carpetas locales.

---

## Regla absoluta

**Todo archivo de configuración IA va a iCloud.** Nunca a rutas locales (`~/.claude/`, `~/Downloads/`, `~/Desktop/`) salvo que sea un archivo que Claude Code gestiona directamente mediante symlink.

Base iCloud:
```
~/Library/Mobile Documents/com~apple~CloudDocs/
```

---

## Mapa de destinos

| Tipo de archivo | Ruta en iCloud | Notas |
|---|---|---|
| Nuevo skill/comando Claude (.md simple) | `claude-commands/{nombre}.md` | Va aquí porque `~/.claude/commands` es symlink a esta carpeta |
| Skill con subcarpeta o archivos múltiples | `claude-commands/skills/{nombre}/` | Ídem |
| Script de setup o instalación | `claude-commands/scripts/{nombre}.sh` | Scripts que instalan o configuran el entorno |
| Reporte de auditoría (skills, MCPs, config) | `IA_Carlos_Hernandez/13_Prompts/reports/` | Reportes generados por tareas programadas |
| Plantilla de documento institucional | `IA_Carlos_Hernandez/09_Plantillas/` | Plantillas Word, Excel, HTML reutilizables |
| Aprendizaje o lección registrada de IA | `IA_Carlos_Hernandez/99_Memoria_IA/Lecciones_Aprendidas/` | Notas de sesiones, patrones aprendidos |
| Documento de conocimiento / referencia IA | `IA_Carlos_Hernandez/00_Biblioteca_Conocimiento/` | Guías, manuales, referencias técnicas |
| App web de contratación (HTML/JS/CSS) | `appcontratistas/{entidad}/` | Apps tipo GENERADOR_EP, GENERADOR_IDONEIDAD |
| Documento contractual | `Trabajo/CONTRATACION/{ENTIDAD}/{SUBCARPETA}/` | Solo definitivos; borradores van a ~/Downloads primero |
| Backup Claude (automático) | `claude-backup/` | Solo via `sync-claude.sh` — nunca editar manualmente |

---

## Proceso de validación — ejecutar SIEMPRE antes de guardar

### Paso 1 — Clasificar el archivo
Determinar a cuál de estas categorías pertenece:
- **Skill nuevo** → `claude-commands/`
- **Reporte de sistema/auditoría** → `IA_Carlos_Hernandez/13_Prompts/reports/`
- **Plantilla** → `IA_Carlos_Hernandez/09_Plantillas/`
- **App web** → `appcontratistas/`
- **Documento contractual** → `Trabajo/CONTRATACION/`
- **Conocimiento/referencia** → `IA_Carlos_Hernandez/00_Biblioteca_Conocimiento/`

### Paso 2 — Verificar que la carpeta destino existe
```bash
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
mkdir -p "$ICLOUD/{RUTA_DESTINO}"
```

### Paso 3 — Verificar que no existe una carpeta equivalente ya
Antes de crear subcarpetas nuevas dentro de `IA_Carlos_Hernandez/`, revisar si el contenido encaja en alguna de las existentes:
```
00_Biblioteca_Conocimiento / 09_Plantillas / 10_SDHT / 11_SNR / 12_UBPD / 13_Prompts / 99_Memoria_IA
```
Si no encaja en ninguna → preguntar al usuario antes de crear una nueva.

### Paso 4 — Guardar en la ruta validada
Usar la ruta completa al guardar. Nunca usar rutas relativas o rutas locales para archivos permanentes.

### Paso 5 — Verificar sincronización (si aplica)
Si se agregó un skill nuevo a `claude-commands/`, confirmar que aparece disponible ejecutando:
```bash
ls ~/.claude/commands/ | grep {nombre}
```
Si se modificó `settings.json` o hooks, correr `sync-claude.sh` para actualizar el backup.

---

## Señales de alerta — detener y preguntar al usuario

- Se va a guardar en `~/Downloads/` un archivo que no es borrador temporal contractual
- Se va a crear una carpeta NUEVA a nivel raíz de iCloud
- Existe una carpeta con nombre similar al destino propuesto
- La ruta propuesta está fuera de iCloud (local únicamente)
- El archivo es un skill pero la ruta propuesta no es `claude-commands/`

---

## Estructura iCloud CAHZ — referencia actual

```
iCloud/
├── IA_Carlos_Hernandez/          ← Todo lo de IA organizado
│   ├── 00_Biblioteca_Conocimiento/
│   ├── 09_Plantillas/
│   ├── 10_SDHT/
│   ├── 11_SNR/
│   ├── 12_UBPD/
│   ├── 13_Prompts/
│   │   └── reports/              ← Reportes de auditoría y config
│   └── 99_Memoria_IA/
│       └── Lecciones_Aprendidas/
├── claude-commands/              ← Skills activos (symlink ← ~/.claude/commands)
│   ├── scripts/                  ← Scripts de setup
│   └── skills/                   ← Skills con múltiples archivos
├── claude-backup/                ← Backup automático (sync-claude.sh)
├── appcontratistas/              ← Apps web de contratación
│   ├── habitat/
│   └── ubpd/
└── Trabajo/
    └── CONTRATACION/
        ├── HABITAT/
        ├── SNR/
        ├── UBPD/
        └── PERSONAL/
```

---

## Notas importantes

- `claude-commands/` tiene un symlink desde `~/.claude/commands` — es la carpeta activa de Claude Code. **No mover ni renombrar.**
- `claude-backup/` se actualiza manualmente con `bash ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/claude-backup/sync-claude.sh`
- Los archivos de apps del sistema (Adobe, Codex, Raycast, Superwhisper) en `Documents/` son gestionados por las apps — no tocar.
- `CLAUDE.md` vive en `~/.claude/CLAUDE.md` (local) pero es el mismo archivo que está en `claude-commands/CLAUDE.md` (iCloud) porque la carpeta está symlinkada.
