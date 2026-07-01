#!/bin/zsh
# Doble clic en el Mac Air para verificar que los skills y la config
# de Claude estén sincronizados desde iCloud. No modifica nada: solo revisa.

SCRIPT="$HOME/Library/Mobile Documents/com~apple~CloudDocs/.claude/scripts/verificar-sync.sh"

echo ""
echo "Verificando sincronización de Claude en este equipo..."
echo ""

if [ -f "$SCRIPT" ]; then
  bash "$SCRIPT"
else
  echo "  ✗ No se encontró verificar-sync.sh en iCloud."
  echo "    Revise que iCloud Drive esté activo y ya haya sincronizado."
fi

echo ""
echo "── Skills nuevos esperados (deben aparecer arriba en el conteo) ──"
SKILLS_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/.claude/skills"
for s in indexar-documento arquitectura-empresarial gobierno-digital; do
  if [ -f "$SKILLS_DIR/$s/SKILL.md" ]; then
    echo "  ✓ $s"
  else
    echo "  ⏳ $s — aún no sincronizado (espere a que iCloud termine)"
  fi
done

echo ""
echo "Presione cualquier tecla para cerrar..."
read -k 1
