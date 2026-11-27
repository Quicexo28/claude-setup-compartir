#!/usr/bin/env bash
# PreToolUse(Bash): bloquea leer archivos de credenciales vía shell (complementa permissions.deny, que solo cubre la herramienta Read).
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
if printf '%s' "$cmd" | grep -Eq '\.credentials\.json'; then
  echo "Bloqueado: el comando toca un archivo de credenciales. Pídelo al usuario explícitamente." >&2
  exit 2
fi
exit 0
