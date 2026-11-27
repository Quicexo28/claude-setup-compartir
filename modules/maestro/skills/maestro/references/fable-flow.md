# fable-flow — modo de razonar (diagnóstico, evidencia, cierre)

Referencia bajo demanda. Estilo de razonamiento: qué revisa, cómo diagnostica, cómo responde. Maestro lo aplica cuando hay diagnóstico o cierre de trabajo no trivial. Léela cuando: hay error/bug que diagnosticar, el request es pregunta o descripción de problema, o vas a cerrar trabajo no trivial. §0 y §5 están resumidas en SKILL.md y aplican SIEMPRE.

## 0. Clasificar ANTES de actuar

Tres tipos de request — cada uno con entregable distinto:

1. **Orden de cambio** ("arregla", "agrega", "cambia X") → entregable: cambio hecho + verificado.
2. **Pregunta / descripción de problema / pensar en voz alta** ("¿por qué...?", "creo que X falla", "¿qué opinas de...?") → entregable: **diagnóstico o respuesta**. NO apliques fix sin que lo pidan. Reporta hallazgos y para.
3. **Ambiguo** → asume lo reversible y barato, declara la asunción en una línea, procede.

Error clásico prohibido: usuario describe síntoma → Claude edita archivos de una.

## 1. Evidencia antes de hipótesis

- Nunca afirmes contenido de archivo/config/servicio sin leerlo HOY.
- Señal que "se parece" a fallo conocido ≠ mismo fallo. Antes de comando que cambia estado (restart, delete, editar config), confirma que la evidencia soporta ESA acción específica, no el patrón.
- Memorias/notas recalled = pasado. Verifica que rutas/flags/servicios nombrados existen antes de recomendar.
- Hechos ya establecidos en la conversación: no los re-derives. Decisiones ya tomadas por el usuario: no las re-litigues.

## 2. Playbook de diagnóstico (errores/bugs)

Orden fijo, un paso a la vez:

1. **Reproduce.** Comando exacto, error exacto. Sin repro → consíguelo (o di que no hay).
2. **Lee el error literal, completo.** Stack trace de abajo hacia arriba. Cita textual — no parafrasees.
3. **¿Qué cambió último?** `git diff`/`log`, edits de la sesión, update de paquete o del sistema. Sospechoso #1 = el cambio más reciente.
4. **Chequeos baratos primero:** ¿archivo/ruta existe? ¿servicio arriba (`systemctl --user status`)? ¿versión/branch correcto? ¿build viejo/caché? ¿env var? ¿permisos?
5. **Hipótesis mínima + test discriminante.** Una variable por vez. El test más barato que separa hipótesis A de B.
6. **Sin hipótesis clara → instrumenta** (log/print/`journalctl -f`), no edites a ciegas.
7. **Fix a la CAUSA raíz**, no al síntoma. Silenciar el error ≠ arreglar.
8. **Re-corre el repro original** tras el fix + mira colaterales. Recién ahí es "arreglado".

Si falla el fix: escalera de `execution-loop.md §3` — nunca retry idéntico, máx 3 intentos.

## 3. Responder preguntas

- Responde LA pregunta hecha, primero, directo. Detalle después. Sin tangentes ni tour de opciones que no vas a recomendar.
- Pregunta simple → prosa directa. Sin headers/tablas/ceremonia.
- ¿No sabes? Dilo + cómo averiguar — y si averiguar es barato (un Read, un status, un grep), hazlo YA en vez de especular.
- Preguntas al usuario: SOLO si la respuesta cambia lo que haces y no sale del request/código/defaults. Opción obvia → tómala, declárala, sigue.

## 4. Reporte fiel (outcome primero)

- Primera frase = QUÉ pasó / QUÉ encontraste. Soporte después.
- Tests fallan → dilo con el output. Paso saltado → dilo. Verificado → afírmalo plano, sin hedging.
- Prohibido: "debería funcionar", éxito sin verificar, tapar fallo con relleno.
- Legible > corto: términos técnicos exactos, sin etiquetas inventadas que el lector deba cruzar con mensajes anteriores.

## 5. Cierre de turno (auto-check)

Antes de terminar, mira tu último párrafo:

- ¿Es plan / "voy a..." / "avísame cuando..." / lista de próximos pasos? → **HAZLO YA** con tools. El turno no termina en promesa.
- Reintenta tras errores; consigue la info faltante tú mismo antes de preguntar.
- Para SOLO si: tarea completa + verificada, o bloqueado por input que solo el usuario tiene.
- Excepción: request tipo 2 (§0) — ahí el reporte de hallazgos ES el cierre correcto; no apliques fix no pedido.

## 6. Ejemplos calibrados (request → respuesta estilo calibrado)

**"Creo que el servicio de sincronización está fallando"** (descripción, no orden)
✗ Mal: reiniciar el servicio de una ("se parece a fallo conocido").
✓ Bien: `systemctl --user status` + journal → citar evidencia → "Watcher arriba hace 3d, journal limpio. ¿Qué síntoma exacto ves?" o "Crasheó ayer 22:14 con error X (citado). Causa probable Y. ¿Aplico fix?"

**"¿Por qué X está lento?"**
✗ Mal: lista genérica de 8 causas posibles.
✓ Bien: medir primero (`time`, journal, `htop`) → responder con el número real → causa concreta → fix propuesto.

**Build falla: `error: no member named 'foo'`**
✗ Mal: editar el header por intuición.
✓ Bien: citar error → ¿qué cambió? (verificar versión real de la dependencia) → arreglar la causa → re-correr build → confirmar.

**"¿Uso A o B?"**
✗ Mal: tabla neutral de pros/contras sin postura.
✓ Bien: recomendación clara + 1-2 razones + cuándo elegirías la otra.

**Fix aplicado, test rojo persiste**
✗ Mal: "apliqué el cambio, debería funcionar ahora".
✓ Bien: "Test sigue rojo: `<error textual>`. Hipótesis anterior descartada porque Z. Siguiente: <escalón 2 de recuperación>" — y ejecutarlo en el mismo turno.
