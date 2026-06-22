# monitor-contratos — Gestión de paquetes contractuales bajo seguimiento

Activa, desactiva o consulta el estado de los paquetes de contratación que están siendo monitoreados diariamente.

---

## Comandos disponibles

### Activar monitoreo de un paquete nuevo
El usuario dice algo como:
- "monitorea la carpeta OTIC 1S2026 de SNR"
- "agrega seguimiento a esta contratación"
- "monta el monitor para HABITAT 2S2026"

**Acción:**
1. Preguntar si no está claro: entidad, nombre del paquete, carpeta dentro de `appcontratistas/`, nombre del Excel de datos, fecha de inicio del contrato
2. Crear el archivo `monitor.json` en la carpeta indicada con esta estructura:
```json
{
  "entidad": "[UBPD/SNR/HABITAT]",
  "paquete": "[nombre del paquete]",
  "carpeta_relativa": "appcontratistas/[entidad]/[carpeta]",
  "excel_datos": "datos/[nombre_excel].xlsx",
  "fecha_inicio_contrato": "YYYY-MM-DD",
  "estado": "activo",
  "activado": "[fecha hoy]",
  "nota": "[descripción breve]"
}
```
3. Confirmar: "Monitor activado para [ENTIDAD] [PAQUETE]. La tarea diaria lo incluirá desde mañana a las 8:30 AM."

### Desactivar / cerrar un paquete
El usuario dice: "cierra el monitor de OTIC 2S2026", "ya terminó la contratación de SNR", "desactiva el seguimiento"

**Acción:**
1. Localizar el `monitor.json` del paquete indicado en `appcontratistas/`
2. Cambiar `"estado": "activo"` → `"estado": "cerrado"` y agregar `"cerrado_manual": "[fecha hoy]"`
3. Confirmar: "Monitor cerrado para [PAQUETE]. No recibirá más alertas."

### Ver paquetes activos
El usuario dice: "qué contratos están bajo monitoreo", "cuántos paquetes activos hay", "estado del monitor"

**Acción:**
Ejecutar:
```bash
find "$HOME/Library/Mobile Documents/com~apple~CloudDocs/appcontratistas" -name "monitor.json" | xargs grep -l '"estado": "activo"' 2>/dev/null | while read f; do
  echo "--- $f"
  cat "$f"
done
```
Mostrar resumen: entidad, paquete, fecha inicio, días restantes.

### Correr el monitor ahora (manual)
El usuario dice: "corre el monitor ahora", "revisa el estado hoy"

**Acción:** Ejecutar el mismo análisis que hace la tarea programada (leer todos los `monitor.json` activos, revisar Excel, reportar alertas) sin esperar a las 8:30 AM.

---

## Estructura de carpetas esperada por paquete

```
appcontratistas/
└── {entidad}/              ← ubpd / snr / habitat
    └── {paquete}/          ← ej: otic-2s2026
        ├── monitor.json    ← activa el seguimiento automático
        ├── datos/
        │   └── {Excel de contratistas con cols: FECHA INICIO, ESTADO CERT MÉDICO}
        └── docs/
            └── {cedula}/   ← documentos individuales
```

---

## Qué revisa el monitor diariamente (lunes a viernes 8:30 AM)

Por cada paquete activo:
- ✅ **Fecha de inicio del contrato** — ¿sigue siendo la misma en el Excel o cambió?
- 🔴 **Certificado médico vencido antes del inicio** — alerta crítica
- 🟡 **Certificado médico que vence en menos de 45 días** — alerta preventiva
- ⚠️ **Contratista sin cert médico válido** — pendiente
- 🏁 **Cierre automático** — cuando la fecha de inicio pasa, el paquete se marca cerrado

---

## Nota sobre el Excel de contratistas

El Excel debe tener en la hoja principal (primera hoja) desde la fila 4:
- Columna 5 (índice 4): Nombres y apellidos
- Columna 10 (índice 9): Fecha inicio
- Columna 14 (índice 13): Estado cert. médico (debe incluir "vence DD/MM/YYYY")

Este formato lo genera el skill `base-contratistas` automáticamente.
