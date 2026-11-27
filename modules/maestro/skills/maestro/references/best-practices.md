# best-practices — Vibe coding + programación

Referencia bajo demanda. Léela en Paso 3/6 SIEMPRE que la subtarea genere o edite código. Maestro debe **inyectar la guardarraíl relevante dentro del prompt mejorado** y hacerla cumplir al ejecutar — no es decorado, es contrato.

## A. Vibe coding (código asistido por IA)

Regla base 2026: no es "escribe prompt y despacha". Generación IA + **supervisión humana estructurada**. Review + Refine = la parte de mayor valor, consume gran parte del esfuerzo.

1. **Spec primero, no vibe a ciegas.** Antes de generar: objetivo, entradas, criterios de éxito verificables, restricciones. Un prompt vago → código vago. (Esto es el Paso 3 de maestro.)
2. **Frontera híbrida — QUÉ vibe-codear vs QUÉ escribir a mano.**
   - Vibe OK: partes repetitivas y bien entendidas — CRUD, validación de formularios, boilerplate, scaffolding, tests obvios.
   - A mano + review estricto: lo novedoso, complejo o **sensible a seguridad** — auth, criptografía, pagos, permisos, manejo de secretos, migraciones destructivas.
3. **Cambios pequeños y acotados.** Un entregable por iteración. Diffs chicos → revisables, reversibles. Nada de mega-cambios de una.
4. **Verifica todo, no confíes.** Corre el código, no solo lo leas. Tests + ejecución real end-to-end (skill `verify`). La IA alucina APIs, firmas, imports.
5. **No aceptes código que no entiendes** en rutas críticas. Si no lo entiendes, no lo puedes mantener ni depurar.
6. **Rigor tradicional antes de producción.** Prototipo/MVP puede ser vibe; antes de shippear: code review, tests, security scan. (skills `code-review`, `security-review`, `review`.)
7. **Control de versiones frecuente.** Commit por cambio coherente y verde. Rama, nunca directo a main. Facilita rollback si la IA rompe algo.
8. **Contexto persistente.** Da a la IA el estado real (archivos, convenciones, CLAUDE.md). Reglas del proyecto explícitas > adivinar.
9. **Itera rápido pero cierra el loop.** Genera → ejecuta → observa → corrige. No apiles cambios sin verificar en medio.

## B. Programación (fundamentos, agnóstico de IA)

**Principios:**
- **KISS** — la solución más simple que funcione. Complejidad solo cuando se gana algo real.
- **YAGNI** — no construyas lo que no se necesita AÚN. Sin abstracción especulativa.
- **DRY** — cada pieza de lógica, una representación única. Pero no DRY prematuro que acople de más (regla de tres).
- **SOLID** — Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion. Para módulos/clases mantenibles y extensibles.

**Prácticas:**
- **Nombres descriptivos** — la intención sale del nombre. `calculate_total()` no `calc()`. Sin abreviaturas crípticas.
- **Funciones pequeñas, una responsabilidad.** Parte las grandes. Pocos parámetros.
- **Manejo de errores robusto y explícito.** No tragues excepciones. Falla ruidoso donde importa; degrada elegante donde el usuario mira (p.ej. try/catch envolviendo fórmulas LLM → objeto vacío, no crash).
- **Comentarios que explican el PORQUÉ**, no el qué. El código dice qué hace; el comentario dice por qué así.
- **Formato consistente** con el código de alrededor. El diff debe leerse como el archivo.
- **Tests** de la lógica, no del framework. Cobertura donde el riesgo vive. Lógica pura testeable sin setup frágil (mantén el core sin dependencias de render/IO).
- **Seguridad por defecto** — nunca hardcodees secretos; valida entradas; menor privilegio; no loguees datos sensibles.

**Metas de código limpio:** legible (intención obvia), cambiable (features sin caos), testeable (lógica validable), revisable (diffs chicos y razonables).

## C. Igualar el código existente (regla de oro)

Escribe código que se lea como el de alrededor: iguala densidad de comentarios, nombres, idioma y patrones del archivo. Respeta las reglas del `CLAUDE.md` del proyecto.

## D. Cómo maestro APLICA esto (obligatorio en tareas de código)

En el **prompt mejorado** de toda subtarea de código, inyecta lo que aplique:
- frontera híbrida (marca lo sensible-a-seguridad como a-mano + review),
- diff pequeño y criterios de éxito verificables,
- "verifica ejecutando" (nombra `verify` / correr tests),
- "iguala el estilo del archivo",
- para pre-producción: encadena `code-review` / `security-review`.

En **Paso 6**, al ejecutar: cambios chicos → verificar → (si toca) revisar → commit en rama, nunca a main sin permiso. Lo sensible-a-seguridad o irreversible → pausa y confirma en lenguaje claro.
