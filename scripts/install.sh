#!/usr/bin/env bash
# Instala la base (hooks, barra de estado, ajustes) y los módulos pedidos.
# Uso: bash scripts/install.sh [módulo...]     "core" va siempre.
# Nunca pisa un archivo existente. Guarda copia de settings.json antes de unirlo.
set -euo pipefail

SRC=$(cd "$(dirname "$0")/.." && pwd)
DEST=${CLAUDE_CONFIG_DIR:-$HOME/.claude}

command -v jq >/dev/null || { echo "Falta jq. Instálalo y vuelve a ejecutar." >&2; exit 1; }
for m in "$@"; do
  [ -d "$SRC/modules/$m" ] || { echo "No existe el módulo: $m. Hay: $(cd "$SRC/modules" && echo *)" >&2; exit 1; }
done

mkdir -p "$DEST/skills" "$DEST/agents" "$DEST/hooks" "$DEST/backups"

settings=$DEST/settings.json
[ -f "$settings" ] || echo '{}' > "$settings"
jq empty "$settings" || { echo "$settings no es JSON válido. No se tocó nada más." >&2; exit 1; }

copy_new() {  # $1 origen, $2 destino
  if [ -e "$2" ] || [ -L "$2" ]; then
    diff -rq "$1" "$2" >/dev/null 2>&1 || echo "YA EXISTE (no se tocó): $2"
  else
    cp -R "$1" "$2"
    echo "instalado: $2"
  fi
}

for f in "$SRC"/base/hooks/*.sh; do copy_new "$f" "$DEST/hooks/$(basename "$f")"; done
copy_new "$SRC/base/statusline.sh" "$DEST/statusline.sh"

for m in core "$@"; do
  for item in "$SRC/modules/$m/skills"/* "$SRC/modules/$m/agents"/*; do
    [ -e "$item" ] || continue
    kind=$(basename "$(dirname "$item")")
    copy_new "$item" "$DEST/$kind/$(basename "$item")"
  done
  if [ "$m" = omarchy ]; then
    om=$HOME/.local/share/omarchy/default/omarchy-skill
    if [ -d "$om" ] && [ ! -e "$DEST/skills/omarchy" ]; then
      ln -s "$om" "$DEST/skills/omarchy"
      echo "enlazado: skill omarchy"
    fi
  fi
done

backup=$(mktemp "$DEST/backups/settings.json.$(date +%Y%m%d-%H%M%S).XXXXXX")
cp "$settings" "$backup"

base=$(mktemp)
tmp=$(mktemp)
trap 'rm -f "$base" "$tmp"' EXIT
jq --arg dir "$DEST" 'walk(if type == "string" then gsub("__CLAUDE_DIR__"; $dir) else . end)' \
  "$SRC/base/settings.base.json" > "$base"

# Las listas se unen sin duplicar. Lo que el usuario ya tiene gana.
jq --slurpfile b "$base" '
  def script: (.command // "") | (capture("(?<n>[^/\"]+\\.sh)").n // .);
  $b[0] as $base
  | reduce ("deny", "ask") as $k (.;
      .permissions[$k] = ((.permissions[$k] // []) as $cur | $cur + ($base.permissions[$k] - $cur)))
  | reduce ($base.hooks | keys[]) as $ev (.;
      reduce $base.hooks[$ev][] as $entry (.;
        ([.hooks[$ev][]?.hooks[]? | script]) as $have
        | ($entry.hooks | map(select(script as $s | $have | index([$s]) | not))) as $new
        | if ($new | length) > 0 then .hooks[$ev] += [$entry + {hooks: $new}] else . end))
  | if has("statusLine") then . else .statusLine = $base.statusLine end
' "$settings" > "$tmp"
cat "$tmp" > "$settings"

echo "settings.json unido. Copia anterior: $backup"
for t in gitleaks shellcheck; do
  command -v "$t" >/dev/null || echo "AVISO: falta $t. Su protección no funciona hasta instalarlo."
done
