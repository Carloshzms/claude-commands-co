---
name: versionar
description: Convención de versionado de documentos de trabajo — qué versión es la definitiva y cómo se registran los cambios
command: /versionar
---

Aplica la convención de versionado de documentos del usuario:

1. NOMBRES: `NombreBase_v1.docx`, `NombreBase_v2.docx`… El número solo crece.
   NUNCA sobrescribir una versión anterior.

2. DEFINITIVA: la versión vigente es siempre la de número mayor.
   Las anteriores son respaldo histórico y no se editan.

3. CUÁNDO SUBE LA VERSIÓN:
   - Cualquier cambio de contenido (corrección, cotejo, humanización, ajuste de fondo) → versión nueva
   - Cambios solo de formato menor pueden mantener la versión, anotándolo en la respuesta

4. REGISTRO DE CAMBIOS: al crear una versión nueva, indicar en la respuesta al usuario
   qué cambió frente a la anterior (lista breve y concreta).

5. UBICACIÓN:
   - Las versiones de trabajo viven juntas en la misma carpeta (normalmente Descargas)
   - Al archivar en iCloud (`CONTRATACION/{ENTIDAD}/{SUBCARPETA}/`), mover al menos la definitiva;
     confirmar con el usuario si las de respaldo también se archivan

6. CONSULTAS: si el usuario pregunta "¿cuál es la última versión?", responder con el nombre
   de archivo exacto, la ruta y una línea de qué la diferencia de la anterior.
