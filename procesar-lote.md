---
name: procesar-lote
description: Procesa en paralelo todos los ZIPs de contratistas que estén en la carpeta _ENTRADA de un paquete contractual. Extrae, valida contra GCO-FT-027, mueve docs a docs/{cedula}/ y archiva el ZIP en _TRAMITADOS/.
---

# procesar-lote — Procesamiento paralelo de ZIPs de contratistas

Invócalo cuando el usuario diga:
- "procesa los zips", "hay zips en entrada", "procesar lote"
- O cuando Claude detecte ZIPs en `_ENTRADA/` al escanear

---

## Rutas base (OTIC 2S2026 UBPD — ajustar por paquete)

```
ICLOUD    = ~/Library/Mobile Documents/com~apple~CloudDocs
BASE_PKG  = {ICLOUD}/appcontratistas/{entidad}/{paquete}/
ENTRADA   = {BASE_PKG}/_ENTRADA/
TRAMITADOS= {BASE_PKG}/_ENTRADA/_TRAMITADOS/
DOCS      = {BASE_PKG}/docs/
DATOS     = {BASE_PKG}/datos/
GCO_FT027 = {DATOS}/GCO-FT-027*.xlsx   (glob)
APP_HTML  = {BASE_PKG}/PROCESAR_LOTE.html
```

---

## Paso 1 — Identificar ZIPs pendientes

```bash
find "{ENTRADA}" -maxdepth 1 -name "*.zip" | sort
```

- Si no hay ZIPs → responder "No hay ZIPs pendientes en _ENTRADA. Coloque los archivos ZIP allí y vuelva a intentarlo."
- Si hay 1 ZIP → procesar directamente (sin overhead de agentes)
- Si hay 2 o más → lanzar agentes en paralelo (uno por ZIP)

---

## Paso 2 — Procesamiento por ZIP (ejecutar en agente independiente por cada ZIP)

Cada agente recibe: ruta absoluta del ZIP, rutas BASE_PKG, DOCS, GCO_FT027.

### 2a. Extraer el ZIP

```python
import zipfile, os, shutil
from pathlib import Path

zip_path = Path("{ZIP_ABSOLUTO}")
temp_dir = zip_path.parent / f"_tmp_{zip_path.stem}"
temp_dir.mkdir(exist_ok=True)

with zipfile.ZipFile(zip_path) as zf:
    for info in zf.infolist():
        # Decodificar nombre (algunos ZIPs usan cp437 o latin-1)
        try:
            fname = info.filename.encode('cp437').decode('utf-8')
        except:
            fname = info.filename
        fname = os.path.basename(fname)
        if not fname or fname.startswith('.'): continue
        dest = temp_dir / fname
        dest.write_bytes(zf.read(info.filename))
```

### 2b. Identificar la cédula del contratista

Buscar en los nombres de archivo un número de 7-10 dígitos que corresponda a una CC:

```python
import re

cedula = None
for f in temp_dir.iterdir():
    m = re.search(r'\b(\d{7,10})\b', f.name)
    if m:
        cedula = m.group(1)
        break

# Si no encontró por nombre, buscar en el PDF de cédula (ítem 10 o similar)
if not cedula:
    cedula = "SIN_CEDULA"  # Reportar como pendiente de identificación manual
```

### 2c. Mover docs a docs/{cedula}/ — ACUMULAR, no reemplazar

```python
dest_contratista = Path("{DOCS}") / cedula
dest_contratista.mkdir(exist_ok=True)

for archivo in temp_dir.iterdir():
    destino = dest_contratista / archivo.name
    if destino.exists():
        # Si ya existe: renombrar el nuevo con sufijo _v2, _v3, etc.
        base = destino.stem
        ext  = destino.suffix
        n = 2
        while destino.exists():
            destino = dest_contratista / f"{base}_v{n}{ext}"
            n += 1
    shutil.move(str(archivo), str(destino))

shutil.rmtree(temp_dir, ignore_errors=True)
```

### 2d. Validar documentos contra GCO-FT-027

Leer los archivos en `docs/{cedula}/` y cruzar contra los ítems esperados:

| Ítem | Clave | Documento esperado | Vigencia |
|---|---|---|---|
| cédula | cedula | Cédula de Ciudadanía | — |
| formacion | formacion | Formación Académica / Títulos | — |
| experiencia | experiencia | Soportes de Experiencia | — |
| tarjeta | tarjeta | Tarjeta / Matrícula Profesional | — |
| redam | redam | REDAM | ≤ 90 días desde expedición |
| antecedentes | antecedentes | Antecedentes Disciplinarios Profesión | Vigente |
| cert_medico | cert_medico | Certificado Médico Ocupacional | ≤ 3 años |
| bancaria | bancaria | Certificación Bancaria | — |
| rut | rut | RUT | — |
| eps | eps | EPS + Pensión | ≤ 30 días |
| arl | arl | GTH-FT-026 ARL | — |

Detección por palabras clave en nombre de archivo:

```python
import re
from datetime import datetime

HOY = datetime.today()

def detectar_doc(archivos):
    result = {}
    for f in archivos:
        fl = f.lower()
        if any(x in fl for x in ['cedula','cédula','cc']): result['cedula'] = 'ok'
        if any(x in fl for x in ['formacion','formación','titulo','académica']): result['formacion'] = 'ok'
        if any(x in fl for x in ['experiencia','soporte']): result['experiencia'] = 'ok'
        if any(x in fl for x in ['tarjeta','matricula','matrí','profesional']): result['tarjeta'] = 'ok'
        if 'redam' in fl: result['redam'] = 'ok'  # Vigencia: extraer fecha del PDF con fitz
        if any(x in fl for x in ['discipli','antecedente','vigencia']): result['antecedentes'] = 'ok'
        if any(x in fl for x in ['medico','médico','ocupacional','salud']): result['cert_medico'] = 'ok'  # Vigencia: extraer con fitz
        if any(x in fl for x in ['bancari','banco']): result['bancaria'] = 'ok'
        if 'rut' in fl: result['rut'] = 'ok'
        if any(x in fl for x in ['eps','pension','pensión','seguridad social']): result['eps'] = 'ok'
        if any(x in fl for x in ['arl','gth-ft-026','gth_ft']): result['arl'] = 'ok'
    # Marcar faltantes
    for k in ['cedula','formacion','experiencia','tarjeta','redam','antecedentes',
              'cert_medico','bancaria','rut','eps','arl']:
        if k not in result:
            result[k] = 'falta'
    return result
```

Para ítems con vigencia (redam, cert_medico, eps): intentar extraer fecha con PyMuPDF (`fitz`).
Si no se puede → marcar como `ok` (presente pero sin fecha verificada) y anotar en reporte.

### 2e. Generar resultado del agente

```
=== RESULTADO ZIP: {nombre_zip} ===
Cédula identificada: {cedula}
Archivos extraídos:  {N} documentos → docs/{cedula}/
Nuevos en esta entrega: {lista}
Documentos acumulados previamente: {N_previos}

VALIDACIÓN GCO-FT-027:
  ✅ Cédula
  ✅ Formación Académica
  ✅ Experiencia
  ✅ Tarjeta Profesional
  ⚠️ REDAM — presente, fecha no verificada
  ✅ Antecedentes Disciplinarios
  ⚠️ Cert. Médico — presente, fecha no verificada (se requiere PDF readable)
  ✅ Certificación Bancaria
  ✅ RUT
  ✅ EPS + Pensión
  ✅ ARL
FALTANTES: [lista o "Ninguno"]
```

---

## Paso 3 — Archivar ZIP en _TRAMITADOS/

Después de procesar exitosamente el ZIP (todos los docs movidos):

```python
from datetime import date

nombre_orig = zip_path.stem   # ej: "gonzalez_docs"
fecha_hoy   = date.today().strftime("%Y-%m-%d")
nuevo_nombre= f"{nombre_orig}_PROC_{fecha_hoy}.zip"
destino_tram= Path("{TRAMITADOS}") / nuevo_nombre

shutil.move(str(zip_path), str(destino_tram))
print(f"ZIP archivado: _TRAMITADOS/{nuevo_nombre}")
```

Si el procesamiento falló parcialmente → NO mover a _TRAMITADOS. Dejar en _ENTRADA para reprocesar.

---

## Paso 4 — Consolidar resultados (orquestador)

Cuando todos los agentes terminan, el orquestador:

1. Recoge los resultados de cada agente
2. Presenta tabla resumen:

```
═══════════════════════════════════════════
RESULTADO LOTE — {N} ZIP(s) procesados
═══════════════════════════════════════════
ZIP                      | Contratista          | Docs OK | Faltantes | Estado
gonzalez_PROC_2026-06-22 | C.M. GONZALEZ MEJIA  |  11/11  | Ninguno   | ✅ Completo
pedraza_PROC_2026-06-22  | D.C. PEDRAZA M.      |   9/11  | RUT, ARL  | ⚠️ Incompleto
═══════════════════════════════════════════
```

3. Actualiza el array ZIPS_TRAMITADOS en PROCESAR_LOTE.html con los ZIPs recién procesados
4. Actualiza el array CONTRATISTAS en PROCESAR_LOTE.html con el nuevo estado de docs
5. Limpia ZIPS_ENTRADA (ya están en _TRAMITADOS)

---

## Paso 5 — Actualizar PROCESAR_LOTE.html

Editar el bloque JS en `APP_HTML` (entre los comentarios `DATOS EMBEBIDOS`):

- Actualizar `ULTIMA_ACTUALIZACION` con fecha y hora actuales
- Actualizar `ZIPS_ENTRADA` → dejar vacío (se procesaron)
- Actualizar `ZIPS_TRAMITADOS` → agregar los ZIPs recién procesados
- Actualizar `CONTRATISTAS` → actualizar el campo `docs` de cada contratista afectado

---

## Notas

- Si PyMuPDF no está instalado: `pip3 install pymupdf`
- Si openpyxl no está instalado: `pip3 install openpyxl`
- ZIPs con error → quedan en _ENTRADA, se reportan como FALLIDOS para revisión manual
- Un ZIP puede contener docs de un solo contratista o de varios → el agente detecta por cédula
- Si el ZIP contiene docs de VARIOS contratistas → el agente distribuye a cada carpeta correspondiente
- La carpeta _TRAMITADOS/ es solo lectura — nunca reprocesar un ZIP que ya está ahí
