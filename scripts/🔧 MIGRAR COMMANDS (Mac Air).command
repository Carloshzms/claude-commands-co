#!/bin/zsh
# 🔧 MIGRAR COMMANDS (Mac Air) — ejecutar UNA vez en el MacBook Air (doble clic).
# Convierte ~/.claude/commands de symlink→iCloud a carpeta real versionada en
# claude-config-co, y jala lo último del repo. Creado 2026-07-08 en el Mac mini.
GIT=/usr/bin/git
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/claude-commands"
echo "🔧 Migración de ~/.claude/commands (symlink iCloud → carpeta real del repo)"

# 1) Si quedó un rebase a medias por un pull fallido anterior, limpiarlo
cd "$HOME/.claude" && $GIT rebase --abort 2>/dev/null

# 2) Quitar el symlink viejo (si existe) y dejar carpeta real
if [ -L "$HOME/.claude/commands" ]; then
  rm "$HOME/.claude/commands"
  mkdir -p "$HOME/.claude/commands"
  cp -p "$ICLOUD"/*.md "$HOME/.claude/commands/" 2>/dev/null
  echo "  ✓ Symlink eliminado; carpeta real creada con copia provisional desde iCloud"
elif [ -d "$HOME/.claude/commands" ]; then
  echo "  — Ya era carpeta real, nada que quitar"
fi

# 3) Jalar lo último del repo (trae/actualiza commands/*.md versionados)
cd "$HOME/.claude" || exit 1
find .git -maxdepth 1 -name index.lock -mmin +1 -delete 2>/dev/null
if $GIT pull --rebase --autostash origin main; then
  echo "  ✓ Repo claude-config-co actualizado"
else
  echo "  ✗ El pull falló — revisar a mano (git status en ~/.claude)"
fi

N=$(ls "$HOME/.claude/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Resultado: $N comandos en ~/.claude/commands (se esperaban ~30)."
echo "Listo. Puede cerrar esta ventana."
