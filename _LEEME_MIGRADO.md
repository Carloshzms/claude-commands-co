# ⚠️ CARPETA MIGRADA — NO EDITAR LOS COMANDOS AQUÍ

**Fecha de migración:** 2026-07-08 (Mac mini)

Los comandos de Claude Code (`*.md` de esta carpeta) se migraron a la carpeta **real**
`~/.claude/commands/`, versionada en el repo **claude-config-co** (GitHub), conforme a la
lección #6 del `CLAUDE.md` global: la configuración sincroniza entre el Mac mini y el
MacBook Air **por Git, no por iCloud**.

## Qué queda en esta carpeta
- Los `*.md` de la raíz son un **espejo histórico congelado** al 2026-07-08. Cualquier
  edición hecha aquí **NO tendrá efecto** en Claude Code.
- La config de otras herramientas (`.codex/`, `.cursor/`, `.gemini/`, `.vscode/`, `.zed/`)
  y `scripts/` siguen vivas aquí (repo `claude-commands-co`).

## Dónde se editan los comandos ahora
`~/.claude/commands/*.md` — los cambios se versionan y suben solos al cerrar sesión
(`versionar-claude.sh`) y bajan al otro equipo al abrir (`cahz-sync-start.sh`).

## En el MacBook Air (una sola vez)
Doble clic en `scripts/🔧 MIGRAR COMMANDS (Mac Air).command` para quitar el symlink
viejo y jalar los comandos del repo. Si no se ejecuta, el propio `cahz-sync-start.sh`
intentará auto-repararlo al arrancar una sesión.
