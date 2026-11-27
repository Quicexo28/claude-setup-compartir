#!/usr/bin/env bash
# PreToolUse(Bash): antes de un `git commit`, escanea con gitleaks lo que se va a commitear.
# Bloquea (exit 2) si encuentra secretos. Los secretos salen redactados.
in=$(cat)
cmd=$(printf '%s' "$in" | jq -r '.tool_input.command // empty' 2>/dev/null)
cwd=$(printf '%s' "$in" | jq -r '.cwd // empty' 2>/dev/null)

printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)' || exit 0
command -v gitleaks >/dev/null || exit 0

# Directorio del repo: `git -C dir`, o `cd dir &&` al inicio, o el cwd de la sesión.
dir=$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:]]+).*/\1/p')
[ -z "$dir" ] && dir=$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+([^[:space:];&]+).*/\1/p')
[ -z "$dir" ] && dir="$cwd"
dir="${dir/#\~/$HOME}"; dir="${dir%\"}"; dir="${dir#\"}"; dir="${dir%\'}"; dir="${dir#\'}"
case "$dir" in /*) ;; *) dir="$cwd/$dir" ;; esac
git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

scan() {  # $@ = flags extra de gitleaks git
  local rep; rep=$(mktemp)
  gitleaks git --pre-commit "$@" --no-banner --redact --log-level error \
    --report-format json --report-path "$rep" "$dir" >/dev/null 2>&1
  local rc=$?
  [ $rc -eq 1 ] && jq -r '.[] | "  \(.RuleID)  \(.File):\(.StartLine)"' "$rep" 2>/dev/null
  rm -f "$rep"
  return $rc
}

found=$(scan --staged)
# `commit -a/--all/-am` añade cambios no staged en el momento del commit.
if printf '%s' "$cmd" | grep -Eq 'commit([^;&|]*[[:space:]])(-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|$)'; then
  found="$found$(scan)"
fi

if [ -n "$found" ]; then
  {
    echo "Bloqueado: gitleaks encontró posibles secretos en lo que se va a commitear:"
    printf '%s\n' "$found" | sort -u | head -20
    echo "Quítalos del commit (o añade un allowlist en .gitleaks.toml si es falso positivo) y vuelve a intentar."
  } >&2
  exit 2
fi
exit 0
