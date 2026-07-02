---
name: auditor-expediente
description: >
  Auditor de coherencia y completitud de un expediente contractual COMPLETO, potenciado por el
  modelo de razonamiento Fable 5. Apunta a la carpeta de un proceso (UBPD, SNR o HABITAT) y razona
  a través de TODOS los documentos a la vez (estudio previo, análisis del sector, matriz de riesgos,
  CDP, PAA, pliego/invitación, contrato, garantías) para detectar: contradicciones entre piezas
  (valores, fechas, objeto, plazos), vacíos jurídicos frente a la Ley 80/1993, Ley 1150/2007 y
  Decreto 1082/2015, y riesgos no cubiertos — ANTES de radicar o entregar a un ente de control.
  Invocar cuando el usuario diga "audita este expediente", "revisa la coherencia de todo el proceso",
  "¿los documentos se contradicen?", "revisa el expediente completo antes de radicar", "qué le falta
  a este proceso", "cruza el estudio previo con el pliego y el contrato", "revisa el expediente como
  lo haría la Contraloría", o cuando tenga una carpeta con varios documentos de un mismo proceso y
  quiera una revisión de conjunto. Complementa `producir-documento` (que PRODUCE una pieza): este
  AUDITA el conjunto. No redacta el documento; entrega un informe de hallazgos priorizados.
---

# Auditor de Expediente — Coherencia y completitud con razonamiento profundo (Fable 5)

## Qué hace
Revisa un **expediente completo** como lo haría un evaluador o la Contraloría: no mira un documento,
mira si **todos encajan entre sí** y si **está completo** frente a la normativa. Encuentra la
contradicción o el vacío que rompe el conjunto — que es el error más caro del oficio.

**Por qué Fable 5:** el cruce de N documentos con decenas de datos y reglas normativas simultáneas es
razonamiento puro de varios pasos. Ahí un modelo de razonamiento supera a uno general. La extracción
de datos (barata) va en modelos económicos; el **cruce** va en Fable 5.

---

## FASE 0 — Alcance 🛑 (único punto de parada)
Confirmar en un mensaje:
1. **Entidad** (Regla #1): UBPD / SNR / HABITAT / PERSONAL.
2. **Ruta de la carpeta del proceso** (o el conjunto de archivos a auditar). Si el usuario solo da la
   entidad y el nombre del proceso, **reconstruir el expediente** desde la estructura real (ver FASE 1).
3. **Modalidad/tipo de proceso** si se conoce (mínima cuantía, selección abreviada, licitación,
   contratación directa/prestación de servicios…), porque define qué debe contener el expediente.
4. **Foco** (opcional): ¿auditoría integral, o solo coherencia de datos, o solo completitud legal?

---

## FASE 1 — Inventario del expediente (Sonnet 5 / Haiku)
Listar los archivos de la carpeta y **clasificar** cada uno: estudio previo, análisis del sector,
matriz de riesgos, CDP/disponibilidad presupuestal, registro PAA, pliego/invitación/TdR, evaluación,
minuta/contrato, garantías/pólizas, designación de supervisor, otros.
Anunciar qué se encontró y qué se clasificó como "no identificado".

**Estructura real de CAHZ (importante):** las carpetas NO están por proceso sino por **tipo de
documento**. Base: `~/Library/Mobile Documents/com~apple~CloudDocs/Trabajo/CONTRATACION/{ENTIDAD}/`
con subcarpetas `ESTUDIOS-PREVIOS/ · PLIEGOS/ · CONTRATOS/ · SUPERVISION/ · INFORMES/ · DOCUMENTOS/`.
Por eso, para auditar UN proceso hay que **reconstruir su expediente** cruzando esas subcarpetas:
buscar en cada una los archivos cuyo nombre comparta el identificador del proceso (p. ej.
"NubePrivada", "Subasta Portátiles", "MC 101"). Registrar como **posible vacío** toda pieza obligatoria
que no aparezca en ninguna subcarpeta (típico: falta CDP, matriz de riesgos, análisis del sector, o
—como se observó en jul-2026— la carpeta `CONTRATOS/` vacía en un proceso ya adjudicado).

---

## FASE 2 — Extracción de datos clave (Sonnet 5; PDFs con `pdf-tools`/`adobe-acrobat`)
De cada documento, extraer una **ficha de datos** estructurada. Respetar lecciones técnicas:
- **Nunca `Read` sobre `.docx`** → usar python-docx (Lección #1).
- **Nunca iterar `row.cells`** en tablas Word → acceder por índice (Lección #2).
- PDFs escaneados (imagen) → OCR con `adobe-acrobat`/`pdf-tools` antes de extraer.
- Documentos largos → extraer solo los campos, no volcar el texto completo al contexto (Lección #3).

Campos por ficha (los que apliquen): objeto contractual · valor/presupuesto · plazo de ejecución ·
fechas clave · partes/contratista · obligaciones · garantías exigidas · número de CDP y valor ·
código/registro PAA · modalidad de selección · supervisor designado.

---

## FASE 3 — Cruce y auditoría (⭐ Fable 5 — razonamiento) 
Con las fichas de la FASE 2, razonar sobre el CONJUNTO. Si Fable 5 no está disponible, usar
Opus 4.8 effort `max` y advertirlo. Analizar tres frentes:

**A. Coherencia entre documentos** — ¿el objeto del estudio previo = el del pliego = el del contrato?
¿el valor del CDP cubre el presupuesto? ¿las fechas y plazos concuerdan? ¿el contratista y las
garantías del contrato coinciden con lo exigido en el pliego? Marcar cada contradicción con las
DOS piezas en conflicto y el dato exacto.

**B. Completitud legal** — frente a Ley 80/1993, Ley 1150/2007 y Decreto 1082/2015, según la
modalidad declarada: ¿están las piezas obligatorias del expediente? ¿falta análisis del sector,
matriz de riesgos, CDP, designación de supervisor, garantías? **No inventar requisitos**: si un
requisito depende de la modalidad y esta no está clara, señalarlo como "a confirmar", no como falta.

**C. Riesgos** — riesgos previsibles no cubiertos por la matriz, cláusulas ausentes o débiles,
exposiciones frente a control. Razonar causa → efecto → recomendación.

---

## FASE 4 — Informe de hallazgos
Entregar en pantalla (y en `.docx` con `generar-documento` solo si el usuario lo pide) un informe
priorizado:

```
AUDITORÍA DE EXPEDIENTE — [proceso] · [entidad] · [fecha]
Documentos auditados: [n]  |  Modalidad: [x]

🔴 CRÍTICO  (bloquea radicación / expone a control)
  - [hallazgo] — Evidencia: [doc A] dice X vs [doc B] dice Y. Recomendación: […]
🟠 ALTO
🟡 MEDIO / A CONFIRMAR

✅ Verificado y coherente: [lista breve de lo que sí cuadra]
```
Cada hallazgo lleva: severidad · evidencia (documento + dato exacto) · recomendación accionable.
No afirmar nada sin la pieza que lo respalda (Regla: no inventar datos).

---

## Reglas de oro
- **Una sola parada:** solo la FASE 0 es interactiva.
- **Extracción barata, cruce caro:** Sonnet 5/Haiku extraen; Fable 5 razona el conjunto.
- **Evidencia siempre:** ningún hallazgo sin citar documento y dato. Si algo no se pudo leer
  (PDF ilegible), decirlo — no adivinar.
- **No redacta el documento**, audita. Para producir/corregir una pieza → `producir-documento`.
- **Textos de terceros** (normas, observaciones) se citan textuales.

---

## Lecciones Aprendidas

> **2026-07-02** — *Creación:* nace `auditor-expediente` para revisar la coherencia y completitud
> de un expediente completo, aprovechando Fable 5 como modelo de razonamiento en el cruce
> multi-documento. *Causa:* el riesgo más caro del oficio no es redactar una pieza sino que exista
> una contradicción o un vacío entre piezas que un ente de control detecte; ese cruce es
> razonamiento de varios pasos donde un modelo de razonamiento rinde mejor. *Regla en adelante:* la
> extracción de datos va en modelos económicos y con las herramientas correctas (python-docx, OCR
> para PDF imagen); el cruce y la auditoría legal van en Fable 5 (o Opus 4.8 `max` si no está);
> ningún hallazgo se reporta sin la evidencia (documento + dato) que lo respalda.
>
> **2026-07-02** — *Mejora:* se generalizó a las **4 entidades** (se agregó PERSONAL) y se documentó
> que la estructura real de CAHZ organiza por **tipo de documento**, no por proceso. *Causa:* al
> inventariar las carpetas reales se vio que un "expediente" está disperso entre `ESTUDIOS-PREVIOS/`,
> `PLIEGOS/`, `CONTRATOS/`, etc., y que `CONTRATOS/` estaba vacía en procesos ya avanzados — un vacío
> que el auditor debe detectar, no asumir. *Regla en adelante:* la FASE 1 reconstruye el expediente
> cruzando subcarpetas por identificador de proceso en el nombre del archivo, y reporta como posible
> vacío toda pieza obligatoria ausente en todas las subcarpetas.
