#!/bin/zsh
# Instala sincronización de repos en cualquier Mac de CAHZ
# Uso: ejecutar UNA SOLA VEZ en cada equipo nuevo

REPO_DIR="/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/claude-commands"
SCRIPTS_DIR="$REPO_DIR/scripts"

echo "Instalando sincronización de repos CAHZ..."

# 1. Copiar scripts al home
cp "$SCRIPTS_DIR/jalar-repos.sh"  ~/jalar-repos.sh
cp "$SCRIPTS_DIR/guardar-repos.sh" ~/guardar-repos.sh
chmod +x ~/jalar-repos.sh ~/guardar-repos.sh
echo "  ✓ Scripts copiados"

# 2. Agregar aliases al .zshrc (solo si no existen ya)
if ! grep -q "jalar-repos" ~/.zshrc; then
  cat >> ~/.zshrc << 'ALIASES'

# --- Sincronización repos Claude (CAHZ) ---
alias jalar='~/jalar-repos.sh'
alias guardar='~/guardar-repos.sh'
ALIASES
  echo "  ✓ Aliases agregados al .zshrc"
else
  echo "  — Aliases ya existían en .zshrc"
fi

# 3. LaunchAgent: auto-pull al iniciar sesión
PLIST=~/Library/LaunchAgents/com.cahz.jalarepos.plist
mkdir -p ~/Library/LaunchAgents
cat > "$PLIST" << 'PLIST_CONTENT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.cahz.jalarepos</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>/Users/carlosaugustohernandezzambrano/jalar-repos.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/cahz-jalarepos.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/cahz-jalarepos.log</string>
</dict>
</plist>
PLIST_CONTENT

launchctl unload "$PLIST" 2>/dev/null
launchctl load "$PLIST"
echo "  ✓ Auto-pull al iniciar sesión activado"

# 4. LaunchAgent: auto-guardar cada hora
PLIST2=~/Library/LaunchAgents/com.cahz.guardarrepos.plist
cat > "$PLIST2" << 'PLIST2_CONTENT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.cahz.guardarrepos</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>/Users/carlosaugustohernandezzambrano/guardar-repos.sh</string>
  </array>
  <key>StartInterval</key>
  <integer>3600</integer>
  <key>StandardOutPath</key>
  <string>/tmp/cahz-guardarrepos.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/cahz-guardarrepos.log</string>
</dict>
</plist>
PLIST2_CONTENT
launchctl unload "$PLIST2" 2>/dev/null
launchctl load "$PLIST2"
echo "  ✓ Auto-guardar cada hora activado"

# 5. Ícono GUARDAR TRABAJO en el Escritorio
ICONO=~/Desktop/"📤 GUARDAR TRABAJO.command"
cat > "$ICONO" << 'DESKTOP'
#!/bin/zsh
~/guardar-repos.sh
echo ""
echo "Presione cualquier tecla para cerrar..."
read -k 1
DESKTOP
chmod +x "$ICONO"
echo "  ✓ Ícono 📤 GUARDAR TRABAJO creado en el Escritorio"

echo ""
echo "Instalación completa."
echo "  → Al encender el Mac: repos se actualizan solos"
echo "  → Al terminar el trabajo: doble clic en 📤 GUARDAR TRABAJO del Escritorio"
