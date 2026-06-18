#!/bin/zsh
REPOS=(
  "/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/claude-commands"
  "/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/IA_Carlos_Hernandez"
  "/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/Entidades"
)

FECHA=$(date '+%Y-%m-%d %H:%M')

echo "⬆ Guardando repos..."
for repo in "${REPOS[@]}"; do
  name=$(basename "$repo")
  cd "$repo"
  if [[ -n $(git status --porcelain) ]]; then
    git add -A && git commit -m "Trabajo $FECHA" --quiet && git push origin main --quiet && echo "  ✓ $name — guardado"
  else
    echo "  — $name (sin cambios)"
  fi
done
echo "Listo."
