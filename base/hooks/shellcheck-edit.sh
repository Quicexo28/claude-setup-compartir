#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): pasa shellcheck a scripts sh/bash recién editados.
# Si hay avisos, se los devuelve a Claude (exit 2) para que los corrija. No toca el archivo.
f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$f" ] && [ -f "$f" ] || exit 0
command -v shellcheck >/dev/null || exit 0

case "$f" in
  *.sh|*.bash) ;;
  *.*) exit 0 ;;   # otra extensión: no es script de shell
  *) head -n1 "$f" 2>/dev/null | grep -Eq '^#!.*([/ ](ba|da|k)?sh)([[:space:]]|$)' || exit 0 ;;
esac
# zsh/fish no los soporta shellcheck
head -n1 "$f" | grep -Eq '^#!.*(zsh|fish)' && exit 0

out=$(shellcheck -S warning -f gcc "$f" 2>&1)
[ -z "$out" ] && exit 0
{
  echo "shellcheck (warning+) en $f:"
  printf '%s\n' "$out" | head -30
} >&2
exit 2
