#!/usr/bin/env bash
# Publica exatamente 9 capturas em assets/ (Linux / Cloud Agent).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
branch="cursor/landing-planos-por-dentro-8972"
assets="$root/assets"

declare -A expected=(
  ["CLIENTE_MENU_VERTICAL.png"]="CLIENTE_MENU_VERTICAL"
  ["CLIENTE_MEUS_AGENDAMENTOS.png"]="CLIENTE_MEUS_AGENDAMENTOS"
  ["CLIENTE_MEUS_PAGAMENTOS.png"]="CLIENTE_MEUS_PAGAMENTOS"
  ["CLIENTE_SERVICOS_CONCLUIDOS.png"]="CLIENTE_SERVICOS_CONCLUIDOS"
  ["PRESTADOR_LOGADO.png"]="PRESTADOR_LOGADO"
  ["PRESTADOR_SERVICOS_DISPONIVEIS.png"]="PRESTADOR_SERVICOS_DISPONIVEIS"
  ["PRESTADOR_CALENDARIO_DE_SERVICOS.png"]="PRESTADOR_CALENDARIO_DE_SERVICOS"
  ["PRESTADOR_MEUS_SERVICOS-MAPA.png"]="PRESTADOR_MEUS_SERVICOS-MAPA"
  ["PRESTADOR_MEUS_GANHOS.png"]="PRESTADOR_MEUS_GANHOS"
)

cd "$root"
git fetch origin
git switch "$branch" 2>/dev/null || git switch -c "$branch" "origin/$branch"
git merge --ff-only "origin/$branch" 2>/dev/null || git reset --mixed "origin/$branch"

while IFS= read -r path; do
  base=$(basename "$path")
  keep=0
  [[ "$base" == "logo.svg" || "$base" == "logo-icon.svg" ]] && keep=1
  for k in "${!expected[@]}"; do [[ "$base" == "$k" ]] && keep=1; done
  if [[ $keep -eq 0 && "$base" =~ \.(png|PNG)$ ]]; then
    git rm -f --ignore-unmatch "$path" || true
  fi
done < <(git ls-files 'assets/*' || true)

find_asset() {
  local base="$1"
  for f in "$assets"/*; do
    [[ -f "$f" ]] || continue
    stem=$(basename "${f%.*}")
    shopt -s nocasematch
    [[ "$stem" == "$base" ]] && { shopt -u nocasematch; echo "$f"; return 0; }
    shopt -u nocasematch
  done
  return 1
}

missing=()
for canonical in "${!expected[@]}"; do
  base="${expected[$canonical]}"
  if src=$(find_asset "$base"); then
    dest="$assets/$canonical"
    if [[ "$(readlink -f "$src")" != "$(readlink -f "$dest" 2>/dev/null || echo "")" ]]; then
      cp -f "$src" "$dest"
    fi
    git add -f "assets/$canonical"
  else
    missing+=("$canonical")
  fi
done

if ((${#missing[@]})); then
  echo "Faltam: ${missing[*]}"
  ls -la "$assets"
  exit 1
fi

for f in "$assets"/*; do
  [[ -f "$f" ]] || continue
  base=$(basename "$f")
  keep=0
  [[ "$base" == "logo.svg" || "$base" == "logo-icon.svg" ]] && keep=1
  for k in "${!expected[@]}"; do [[ "$base" == "$k" ]] && keep=1; done
  if [[ $keep -eq 0 && "$base" =~ \.(png|PNG)$ ]]; then
    rm -f "$f"
    git rm -f --ignore-unmatch "assets/$base" 2>/dev/null || true
  fi
done

git status
if git diff --cached --quiet; then
  echo "Nada novo para commitar."
  exit 0
fi

git commit -m "assets: publica 9 capturas da secao Por Dentro"
git push -u origin "$branch"
echo "OK - 9 imagens publicadas."
