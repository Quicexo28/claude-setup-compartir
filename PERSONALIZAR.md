# Personalización

Guía para Claude. El objetivo es que el setup quede al gusto de esta persona, no copia del de quien lo compartió.

## Cómo preguntar

- Haz pocas preguntas por vez. Usa preguntas con opciones si tienes la herramienta.
- Da una recomendación en cada una.
- No preguntes lo que puedes ver en la máquina. Confírmalo.
- Explica los términos técnicos en una frase.

## Ronda 1. Sobre ti

1. ¿En qué idioma quieres las respuestas?
2. ¿Qué experiencia tienes con la terminal y el código?
3. ¿Para qué vas a usar Claude Code? (programar, estudiar, arreglar el equipo, servidor en casa, 3D...)
4. ¿Qué lenguajes usas?

Con esto propón los módulos y las herramientas. Recomienda lo mínimo. Cada skill de más ocupa memoria de trabajo de Claude.

## Ronda 2. Cómo quieres que te hable

1. Muestra la misma respuesta de ejemplo en dos estilos: el reporte corto de la plantilla y uno normal. Pregunta cuál prefiere. Si no quiere el corto, quita ese bloque. Si no habla español, tradúcelo y adáptalo.
2. ¿Respuestas breves o con explicación? Si está aprendiendo, ofrece que expliques el porqué.
3. ¿Hay algo que te moleste de un asistente?

## Ronda 3. Cuánta libertad

1. ¿Cuándo debe pedirte permiso? Ajusta la sección "Acciones con riesgo" y la lista `ask` de `settings.json`.
2. No quites las protecciones sin explicar el riesgo y recibir un sí claro.

## Ronda 4. Gasto y modelos

1. ¿Qué plan tienes?
2. Quien compartió esto usa Sonnet como modelo principal, Sonnet para los agentes y Opus como consejero. Explícalo y ofrécelo solo si su plan lo permite.
3. Claves posibles en `settings.json`: `model`, `advisorModel` y `env.CLAUDE_CODE_SUBAGENT_MODEL`. Compruébalas en la documentación antes de escribirlas.
4. Algunos agentes traen su propio `model:` (`planner` y `architect` usan Opus). Si su plan no lo permite o quiere ahorrar, cámbialo.

## Después de instalar

Ofrece esto, una cosa a la vez:

- Una sección para cada proyecto, con un `CLAUDE.md` propio (comando `/init`).
- Permisos para los comandos que aprueba siempre (skill `fewer-permission-prompts`).
- Una skill propia para una tarea que repite.
- Quitar lo que no usó tras unas semanas (skill `context-budget`).

Dile que puede volver cuando quiera y pedir: "ajusta mi CLAUDE.md".

Cuando corrija tu forma de trabajar, ofrece guardar esa regla en su `CLAUDE.md` o en la memoria.
