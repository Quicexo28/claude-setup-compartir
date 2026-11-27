#!/usr/bin/env bash
# Prueba los hooks instalados con entradas falsas. No ejecuta ningún comando peligroso:
# cada hook solo recibe el texto por la entrada estándar.
DEST=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
fail=0

check() {  # $1 hook, $2 comando simulado, $3 código esperado
  jq -n --arg c "$2" '{tool_input:{command:$c}, cwd:"."}' | bash "$DEST/hooks/$1" >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "$3" ]; then echo "OK    $1: $2"; else echo "FALLA $1: $2 (salió $rc, se esperaba $3)"; fail=1; fi
}

check guard-destructive.sh   'rm -rf ~'                   2
check guard-destructive.sh   'git push --force'           2
check guard-destructive.sh   'ls -la'                     0
check guard-credentials.sh   'cat x/.credentials.json'    2
check guard-credentials.sh   'ls -la'                     0
check guard-secrets-commit.sh 'ls -la'                    0

jq -e . "$DEST/settings.json" >/dev/null && echo "OK    settings.json es JSON válido" || fail=1
for h in guard-credentials guard-destructive guard-secrets-commit shellcheck-edit; do
  if jq -e --arg h "$h.sh" '[.hooks[]?[].hooks[]?.command | select(contains($h))] | length > 0' "$DEST/settings.json" >/dev/null; then
    echo "OK    $h conectado en settings.json"
  else echo "FALLA $h no está en settings.json"; fail=1; fi
done
echo "skills: $(ls "$DEST/skills" | wc -l)   agentes: $(ls "$DEST/agents" | wc -l)"
exit $fail
