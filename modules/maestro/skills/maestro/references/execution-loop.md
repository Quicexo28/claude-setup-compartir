# execution-loop — grounding, aceptación, recuperación, right-sizing

Referencia bajo demanda. El núcleo que cierra el ciclo **generar → verificar → recuperar** sin desperdicio. Léela cuando vayas a ejecutar algo no trivial (Paso 6), o antes de reescribir un prompt de código (Paso 1).

## 1. Grounding (anti-alucinación) — ANTES de reescribir

Regla dura: **nunca reescribas un prompt de código sin leer el estado REAL.** La IA alucina firmas, imports, rutas y APIs. Antes del Paso 3, para toda subtarea de código:

- **Lee** los archivos que se van a tocar (Read) — no asumas su contenido.
- **Localiza** con `grep`/`Glob` o el agente `Explore` dónde vive lo que cambias y qué lo llama.
- **Verifica** que funciones/rutas/flags nombrados EXISTEN hoy (recuerda: las memorias recalled reflejan el pasado — confírmalas).
- Mete los hechos confirmados (rutas, firmas, líneas) DENTRO del prompt mejorado. Un prompt aterrizado no inventa.

Barato: para 1-2 archivos, Read directo. Amplio/desconocido: `Explore`. No spawnees para leer un archivo que puedes abrir tú.

## 2. Gate de aceptación — DESPUÉS de ejecutar

No sueltes el trabajo sin comprobar que cumplió los **criterios de éxito verificables** que definiste en Paso 3. Cierra el loop:

1. Ejecuta la subtarea.
2. **Verifica contra el criterio** — no contra "parece bien":
   - código → corre tests / `verify` / ejercita el flujo real (no solo typecheck).
   - sistema → confirma el efecto (servicio arriba, archivo creado).
   - texto/análisis → relee contra los requisitos que fijaste.
3. **¿Cumple?** → cierra y reporta.
4. **¿No cumple?** → **itera automáticamente** (ver recuperación). Máx **3 intentos**; al 3º fallo, para y escala al usuario con el diagnóstico concreto.

Sin gate = open-loop = "lo hice" sin saber si sirvió. Prohibido reportar éxito sin verificar.

## 3. Escalera de recuperación de errores

Cuando un paso falla, devuelve basura, o el gate no pasa — **no repitas el mismo prompt**. Sube un escalón por intento:

1. **Retry aterrizado** — releé el error EXACTO + estado real, corrige la causa, reintenta con prompt más específico.
2. **Refina el prompt** — si el enfoque era ambiguo, especifícalo más (más contexto, restricción que faltó).
3. **Cambia de herramienta/modelo** — otra skill/agente más apto, o sube el modelo (mecánico falló → razonamiento con opus).
4. **Escala al usuario** — tras 3 intentos o ante bloqueo real (falta permiso/credencial/decisión suya): para, reporta el error citado textual + qué intentaste + qué necesitas. No sigas a ciegas.

Nunca: tragar el error y reportar éxito; reintentar idéntico; inventar para tapar un fallo.

## 4. Right-sizing esfuerzo/costo/modelo

Iguala el peso de la herramienta a la tarea. Inline = modelo principal. Subagente = arranca en frío y re-deriva contexto, pero corre en un modelo más barato y devuelve solo la conclusión. Delega cuando el trabajo es grande en lectura/tokens y no necesita esta conversación; inline cuando es chico o depende del contexto actual.

| Tarea | Ejecución | Modelo |
|-------|-----------|--------|
| Trivial (leer 1-2 archivos conocidos, typo, respuesta directa) | inline | principal |
| Localizar / leer mucho (>3 archivos, grep exploratorio) | `Explore` | haiku (parámetro `model`) |
| Edit mecánico 1-2 archivos | `general-purpose` | haiku (parámetro `model`) |
| Implementación acotada, diagnóstico, review | reviewer/resolver del stack, `general-purpose` | sonnet (definición del agente o parámetro `model`) |
| Crítica, ambigua, alto riesgo, arquitectura | `planner`/`architect`, o `general-purpose` con `model: "opus"`; `code-review ultra` (solo usuario) | opus |

Agentes con `model:` propio: no les pases `model`, porque pisa su definición. Revisa el `model:` en `~/.claude/agents/*.md`.

Reglas:
- No spawnees subagente para lo que resuelves inline (leer un archivo, un edit chico).
- Paraleliza SOLO subtareas independientes (Paso 0); si dependen, secuencial.
- Sube modelo por dificultad de RAZONAMIENTO, no por tamaño de output. Parámetro `model` solo para agentes sin `model:` propio.
- Un solo pase de verificación proporcional: no lances `ultra` para un typo; no cierres auth con solo typecheck.
