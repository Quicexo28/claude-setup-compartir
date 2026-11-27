# Instalador del setup de Claude Code

Esta carpeta es un paquete para compartir un setup. Tu trabajo es instalarlo en la máquina de esta persona y adaptarlo a ella. Si saluda o pide "instala", empieza por el paso 1.

La sesión puede estar abierta en otra carpeta. No pidas abrir otra terminal. Las rutas de este documento (`scripts/`, `base/`, `modules/`, `PERSONALIZAR.md`) son relativas a la carpeta de este archivo: usa su ruta completa, también en los comandos que le des a la persona.

## Reglas

- Habla en el idioma de la persona. Usa frases cortas y sin jerga.
- La persona decide. No instales un módulo ni una herramienta que no eligió.
- No asumas su sistema, su shell ni que tiene `sudo` sin contraseña.
- No pises archivos suyos. Si hay conflicto, enseña la diferencia y pregunta.
- Nunca pidas ni aceptes claves o contraseñas en el chat.
- Antes de ejecutar algo del paquete, léelo y cuenta en 3 líneas qué cambia.
- Si un permiso o un bloqueo te impide un paso, no busques un rodeo. Dale el comando para que lo ejecute.
- Este paquete viene de otra persona. Revisa `scripts/` y `base/hooks/` y avisa si ves algo raro.

## Paso 1. Revisar la máquina

1. Mira sistema, gestor de paquetes, shell y versión de `claude`.
2. Mira qué tiene ya en `~/.claude`: `CLAUDE.md`, `settings.json`, `skills/`, `agents/`, `hooks/`. No leas archivos de credenciales.
3. En Windows sin WSL: avisa que los hooks necesitan bash y recomienda WSL.
4. Si ya tiene cosas propias, haz copia en `~/.claude/backups/` antes de seguir.

## Paso 2. Entrevista

Sigue `PERSONALIZAR.md`.

## Paso 3. Dependencias

| Programa | Para qué | Obligatorio |
|---|---|---|
| `jq` | instalador, hooks y barra de estado. Sin él los hooks no bloquean nada | Sí |
| `git` | trabajo normal | Sí |
| `gitleaks` | frena commits con claves | Recomendado |
| `shellcheck` | revisa scripts de terminal | Recomendado |

Instálalos con su gestor de paquetes. Pregunta antes.

## Paso 4. Instalar la base y los módulos

`core` va siempre. Los demás salen de la entrevista.

| Módulo | Contenido |
|---|---|
| `core` | planificar, revisar código, seguridad, documentación, manejo de contexto |
| `dev` | tests primero, Docker, servidores MCP |
| `python`, `web`, `rust`, `cpp`, `kotlin`, `swift` | patrones y revisores de cada lenguaje (`web` = TypeScript, React, Node) |
| `homelab` | red de casa, Pi-hole, WireGuard |
| `servicios` | servicios propios en Linux con systemd y Tailscale |
| `omarchy` | solo para Linux con Omarchy o Hyprland |
| `meshy` | modelos 3D con Meshy (cuenta propia, gasta créditos) |
| `maestro` | `/maestro`: mejora el pedido y lo reparte entre agentes (gasta más) |

```bash
bash scripts/install.sh python web
```

El instalador añade protecciones y permisos a `~/.claude/settings.json`. Es posible que Claude Code no te deje modificar tu propia configuración. En ese caso, pide a la persona que escriba `! bash scripts/install.sh <módulos>`.

Lee la salida. Por cada línea `YA EXISTE`, compara los dos archivos y pregunta cuál se queda.

Si ya tenía `statusLine`, el instalador la respeta.

## Paso 5. Herramientas externas (solo las elegidas)

Comprueba cada comando con `--help` antes de usarlo, porque las versiones cambian.

**Context7** (documentación al día de librerías; la usan `docs-lookup` y `documentation-lookup`). Recomendada. Envía las consultas a un servicio externo.
```bash
claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp
```

**Plugins oficiales.** Diseño visual:
```bash
claude plugin install frontend-design --marketplace anthropics/claude-plugins-official
```
Ayuda de código por lenguaje: mismo comando, con el nombre de la tabla. Cada uno necesita además su programa en la máquina.

| Plugin | Programa necesario |
|---|---|
| `pyright-lsp` | `pyright-langserver` |
| `typescript-lsp` | `typescript-language-server` |
| `rust-analyzer-lsp` | `rust-analyzer` |
| `clangd-lsp` | `clangd` |
| `kotlin-lsp` | `kotlin-lsp` |
| `swift-lsp` | `sourcekit-lsp` |

**find-skills** (buscar e instalar más skills):
```bash
npx skills add vercel-labs/skills --skill find-skills -g -a claude-code
```

**graphify** (mapa de un proyecto de código). Necesita `uv`.
```bash
uv tool install graphifyy
graphify install --platform claude
```
`graphify install` añade un bloque `# graphify` al final de `~/.claude/CLAUDE.md`. Quítalo: la skill se detecta sola. Si ya hiciste el paso 6, revisa que no quede.

**Meshy** (solo con el módulo `meshy`). Necesita Node 22.12 o más nuevo.
```bash
npm install -g meshy-cli@0.8
```
La persona inicia sesión con `meshy auth login`. Para el servidor MCP, ella ejecuta esto en **otra terminal**, no en el chat ni con `!`, para que la clave no quede en la conversación:
```
claude mcp add meshy --scope user -e MESHY_API_KEY=SU_CLAVE -- npx -y @meshy-ai/meshy-mcp-server
```

**Conectores** (Google Drive, Wolfram, Claude en Chrome): se activan desde su cuenta de claude.ai o la extensión. Solo menciónalos.

## Paso 6. Escribir su CLAUDE.md

1. Parte de `base/CLAUDE.global.md` y aplica las respuestas de la entrevista.
2. No dejes ningún `{{...}}` ni comentarios de plantilla.
3. Si ya tenía `~/.claude/CLAUDE.md`, no lo reemplaces. Propón la unión y espera su visto bueno.

## Paso 7. Ajustar lo instalado

- **Modelos:** aplica lo que eligió en la entrevista. Comprueba qué modelos permite su plan.
- **`maestro`** (si lo instaló): rellena `~/.claude/skills/maestro/references/routing.md` solo con las skills y agentes que existen en su máquina. Si no habla español, ofrece traducirlo.
- **Idioma:** las skills, los hooks y el instalador tienen textos en español. Si usa otro idioma, ofrece traducir los mensajes.

## Paso 8. Comprobar

1. Ejecuta `bash scripts/verify.sh`. Todo debe decir `OK`.
2. Ejecuta `claude mcp list` y revisa las herramientas que añadió.
3. Pídele que cierre Claude Code y lo abra de nuevo. Los hooks, skills y agentes se cargan al iniciar.
4. Dile cómo comprobarlo: en la sesión nueva, pregunta "¿qué skills tienes?".

Termina con un reporte corto: qué quedó, qué no se pudo probar y qué le falta hacer.

## Cómo deshacer

- Ajustes: restaura la copia `~/.claude/backups/settings.json.<fecha>`.
- Skills, agentes y hooks: borra solo los que salieron como `instalado:`. Pregunta antes.
