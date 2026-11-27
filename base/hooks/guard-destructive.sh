#!/usr/bin/env bash
# PreToolUse(Bash): bloquea lo irrecuperable. Lo demás (rm -rf normal, git push) lo gestionan las reglas `ask` de settings.json.
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
block() { echo "Bloqueado: $1. Si es intencional, que lo ejecute el usuario." >&2; exit 2; }
# rm recursivo sobre raíz, home o sus comodines
printf '%s' "$cmd" | grep -Eq 'rm +(-[a-zA-Z]*[rR][a-zA-Z]* +)+(--no-preserve-root +)?(/|/\*|~|~/|~/\*|\$HOME|\$HOME/|\$HOME/\*|"\$HOME"|/home|/home/\*)( |$)' && block "rm recursivo sobre raíz o home"
# force push sin lease
printf '%s' "$cmd" | grep -Eq 'git +push[^|;&]*( --force( |$)| -f( |$))' && ! printf '%s' "$cmd" | grep -q -- '--force-with-lease' && block "git push --force"
# formateo / sobrescritura de discos
printf '%s' "$cmd" | grep -Eq '(mkfs(\.[a-z0-9]+)? |dd +[^|;&]*of=/dev/(sd|nvme|mmcblk))' && block "escritura destructiva de disco"
exit 0
