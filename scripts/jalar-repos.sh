#!/bin/zsh
REPOS=(
  "/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/claude-commands"
  "/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/IA_Carlos_Hernandez"
  "/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/Entidades"
)

echo "⬇ Jalando repos..."
for repo in "${REPOS[@]}"; do
  name=$(basename "$repo")
  cd "$repo" && git pull origin main --quiet && echo "  ✓ $name" || echo "  ✗ $name — revise conexión"
done
echo "Listo."
