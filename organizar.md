# Organizador de Descargas

Revisa la carpeta ~/Downloads y clasifica los documentos nuevos en las carpetas de trabajo en iCloud.

## Instrucciones

1. Lista todos los archivos en ~/Downloads que sean documentos (pdf, docx, xlsx, pptx, txt, zip)
2. Para cada archivo, analiza el nombre e intenta deducir a qué entidad pertenece:
   - **UBPD** → Unidad de Búsqueda de Personas Dadas por Desaparecidas
   - **SNR** → Superintendencia de Notariado y Registro
   - **HABITAT** → Ministerio de Vivienda / Hábitat
   - **PERSONAL** → documentos personales (extractos, impuestos, personal)
3. También determina el tipo de documento para la subcarpeta:
   - Estudios previos → ESTUDIOS-PREVIOS
   - Pliegos, términos → PLIEGOS
   - Contratos, adendas → CONTRATOS
   - Informes de supervisión → SUPERVISION
   - Informes, reportes → INFORMES
   - Cualquier otro → DOCUMENTOS

4. **Si tienes dudas sobre un archivo, PREGUNTA al usuario antes de moverlo**
5. Muestra un resumen de lo que vas a mover y pide confirmación
6. Usa Bash para mover los archivos a:
   `/Users/carlosaugustohernandezzambrano/Library/Mobile Documents/com~apple~CloudDocs/Trabajo/CONTRATACION/{ENTIDAD}/{SUBCARPETA}/`

## Importante
- No mover archivos del sistema, imágenes de fondo, wallpapers
- Si el nombre no da pistas claras sobre la entidad, SIEMPRE preguntar
- Confirmar con el usuario antes de ejecutar los movimientos
