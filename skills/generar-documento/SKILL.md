---
name: generar-documento
description: |
  Skill para generar documentos Word (.docx) profesionales de consultor de alto nivel en contratación pública colombiana.
  
  Úsalo SIEMPRE que el usuario pida generar, crear, producir o exportar cualquier documento formal:
  oficios, respuestas a derechos de petición, informes de supervisión, memorandos, estudios previos,
  matrices de riesgo, fichas técnicas, respuestas a observaciones, actas, o cualquier escrito institucional.
  
  También úsalo cuando el usuario diga "queda feo", "parece de bachiller", "no se ve profesional",
  "ponle formato", "mejora la presentación" o cualquier queja sobre la calidad visual de un documento.
  
  El resultado SIEMPRE es un archivo .docx en ~/Downloads con formato de consultor senior:
  Arial Narrow 12pt, márgenes de oficio, jerarquía tipográfica clara, redacción directa y técnica.
---

# Generar Documento Profesional

## Objetivo

Producir documentos Word con el nivel de presentación de un ingeniero de sistemas con maestría y 30 años de experiencia en consultoría pública colombiana. No como un escrito de bachiller: como un oficio institucional que resiste revisión de entes de control.

## Paso 1 — Preguntar antes de generar

Antes de escribir una sola línea de código, resolver estas dos preguntas si no están claras en el contexto:

**a) ¿Incluir encabezado con colores de entidad o neutro?**
- Preguntar: *"¿Lo genero con colores neutros (grises/blancos — recomendado) o con los colores de la entidad?"*
- Default si el usuario no responde o dice "como quieras": **NEUTRO**
- Si elige colores de entidad, preguntar cuál entidad (UBPD, SNR, HABITAT, otra) y aplicar los colores del esquema correspondiente (ver sección Colores más abajo)

**b) ¿Qué tipo de documento es?**
Identificar el tipo para aplicar la estructura correcta:
- **Oficio / Respuesta** → estructura de carta con destinatario, asunto, cuerpo por puntos, firma
- **Informe** → portada implícita (título + entidad + fecha al inicio), secciones numeradas, conclusiones
- **Memorando** → cabezote Para/De/Asunto/Fecha, cuerpo directo
- **Acta** → número de acta, asistentes, orden del día, desarrollo, compromisos, firmas
- **Tabla / Matriz** → documento centrado en tabla con encabezados grises

## Paso 2 — Aplicar skills de calidad al TEXTO antes de generar el archivo

El documento debe pasar tres filtros antes de convertirse en .docx:

1. **`/critica`** — revisar coherencia legal, consistencia interna y posibles debilidades
2. **`/verificador-datos`** — verificar fechas, cifras, citas normativas y datos cruzados
3. **`/humanizar`** — redacción directa, activa, sin muletillas de IA; que suene a abogado/ingeniero colombiano experimentado

Solo cuando el texto esté validado, proceder con la generación del archivo.

## Paso 3 — Generar el .docx con python-docx

Usar **siempre** python-docx (no el MCP de Word). El MCP de Word no tiene control suficiente sobre estilos y produce documentos con formato de bachiller.

### Estándar de formato obligatorio

```
Fuente:          Arial Narrow, 12pt, negro (#000000)
Márgenes:        Superior 3cm | Inferior 2.5cm | Izquierdo 3cm | Derecho 2.5cm
Interlineado:    15pt (Pt(15) en paragraph_format.line_spacing)
Espacio después: 6pt por defecto entre párrafos del cuerpo
Alineación:      JUSTIFY para el cuerpo; LEFT para destinatario y firma; RIGHT para la fecha
Encabezados:     Bold + Underline, sin color de fondo
Tablas:          Bordes finos, encabezados con fondo gris claro (#D9D9D9), texto negro
```

### Script base — usar este patrón SIEMPRE

Escribir un script Python en `~/Downloads/gen_doc_temp.py`, ejecutarlo, luego borrarlo.
Ver el script de referencia en `scripts/plantilla_base.py` de este skill — copiarlo y adaptarlo al contenido específico.

El script debe:
1. Importar las librerías correctas (`docx`, `docx.shared`, `docx.enum`)
2. Definir helpers reutilizables: `set_font()`, `add_para()`, `add_mixed()`, `add_heading_section()`
3. Construir el documento sección por sección en el orden correcto
4. Guardar en `~/Downloads/NOMBRE_DOCUMENTO_v1.docx`
5. Imprimir confirmación al finalizar

### Estructura de oficio/carta (orden obligatorio)

```
1. Fecha                   → RIGHT, Arial Narrow 12pt
2. Espacio (14pt after)
3. Destinatario            → LEFT, NOMBRE en BOLD, cargo e institución normal
4. Asunto / Radicado       → etiqueta BOLD + texto normal, JUSTIFY
5. Espacio (14pt after)
6. Saludo                  → LEFT, "Respetado(a) señor(a):"
7. Párrafo introductorio   → JUSTIFY, cita la norma o el acto que motiva la respuesta
8. Cuerpo por secciones    → cada punto con título BOLD+UNDERLINE, párrafo JUSTIFY
9. Párrafo de cierre       → JUSTIFY
10. Despedida              → LEFT, "Atentamente," + 60pt de espacio after
11. Firma                  → BOLD para el nombre en MAYÚSCULAS, normal para el cargo
12. Elaboró / Revisó       → al pie, BOLD la etiqueta, normal los nombres
```

### Convención de nombre de archivo

```
TIPO_DESCRIPCION_ENTIDAD_v1.docx

Ejemplos:
  RTA_PETICION_ANONIMA_UBPD_v1.docx
  INFORME_SUPERVISION_CONTRATO_SNR_v1.docx
  MEMORANDO_SEGURIDAD_HABITAT_v1.docx
  OFICIO_TRASLADO_COMPETENCIA_v1.docx
```

## Paso 4 — Entregar y confirmar

Al terminar:
- Informar la ruta exacta del archivo generado
- Indicar qué skills se aplicaron: `/critica`, `/verificador-datos`, `/humanizar`
- Señalar los **placeholders pendientes** que el usuario debe completar (radicados, fechas por confirmar, números de resolución por verificar) — listarlos explícitamente
- Preguntar si aprueba para mover a iCloud o si hay ajustes

## Colores de entidad (solo si el usuario los solicita)

| Entidad | Color primario | Uso |
|---|---|---|
| UBPD | Preguntar al usuario | Encabezado de tabla o línea separadora |
| SNR | Preguntar al usuario | Encabezado de tabla o línea separadora |
| HABITAT | Preguntar al usuario | Encabezado de tabla o línea separadora |
| Neutro (default) | Gris claro `#D9D9D9` | Encabezados de tabla únicamente |

Nunca aplicar colores llamativos sin que el usuario los confirme. Ante la duda, neutro.

## Lo que NUNCA debe ocurrir

- No usar el MCP de Word (`mcp__Word__By_Anthropic__*`) para documentos que requieran formato preciso — solo sirve para texto plano
- No generar el .docx sin antes pasar por `/critica`, `/verificador-datos` y `/humanizar`
- No inventar datos (radicados, fechas, nombres de funcionarios) — dejar placeholder explícito
- No usar colores llamativos sin aprobación del usuario
- No omitir el bloque Elaboró/Revisó en documentos institucionales de UBPD, SNR o HABITAT
- No generar documentos extensos sin preguntar primero si falta información crítica

## Referencia rápida de helpers python-docx

```python
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

def set_font(run, bold=False, italic=False, size=12, name="Arial Narrow"):
    run.font.name  = name
    run.font.size  = Pt(size)
    run.font.bold  = bold
    run.font.italic = italic
    run.font.color.rgb = RGBColor(0, 0, 0)

def add_para(doc, text="", align=WD_ALIGN_PARAGRAPH.JUSTIFY,
             bold=False, size=12, space_before=0, space_after=6):
    p = doc.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_before = Pt(space_before)
    p.paragraph_format.space_after  = Pt(space_after)
    p.paragraph_format.line_spacing = Pt(15)
    if text:
        run = p.add_run(text)
        set_font(run, bold=bold, size=size)
    return p

def add_mixed(doc, parts, align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=6):
    """parts = [(texto, bold, italic), ...]"""
    p = doc.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_after  = Pt(space_after)
    p.paragraph_format.line_spacing = Pt(15)
    for text, bold, italic in parts:
        run = p.add_run(text)
        set_font(run, bold=bold, italic=italic)
    return p

def add_section_heading(doc, title):
    """Título de sección: Bold + Underline"""
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after  = Pt(4)
    p.paragraph_format.line_spacing = Pt(15)
    run = p.add_run(title)
    set_font(run, bold=True, size=12)
    run.font.underline = True
    return p
```
