#!/usr/bin/env bash
# Statusline: modelo + % contexto + directorio. Entrada: JSON de Claude Code por stdin.
in=$(cat)
model=$(printf '%s' "$in" | jq -r '.model.display_name // .model.id // empty')
pct=$(printf '%s' "$in" | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)
dir=$(printf '%s' "$in" | jq -r '.workspace.current_dir // .cwd // empty')
dir=${dir/#$HOME/\~}
out=""
[ -n "$model" ] && out="$out \033[38;5;110m$model\033[0m"
if [ -n "$pct" ]; then
  col=114; [ "$pct" -ge 60 ] && col=179; [ "$pct" -ge 80 ] && col=167
  out="$out \033[38;5;${col}mctx ${pct}%\033[0m"
fi
[ -n "$dir" ] && out="$out \033[2m$dir\033[0m"
printf '%b' "$out"
