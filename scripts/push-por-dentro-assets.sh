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
  ["CLIENTE_SERVIÇOS_CONCLUIDOS.png"]="CLIENTE_SERVIÇOS_CONCLUIDOS"
  ["PRESTADOR_LOGADO.png"]="PRESTADOR_LOGADO"
  ["PRESTADOR_SERVIÇOS_DISPONIVEIS.png"]="PRESTADOR_SERVIÇOS_DISPONIVEIS"
  ["PRESTADOR_CALENDARIO_DE_SERVIÇOS.png"]="PRESTADOR_CALENDARIO_DE_SERVIÇOS"
  ["PRESTADOR_MEUS_SERVICOS-MAPA.png"]="PRESTADOR_MEUS_SERVICOS-MAPA|PRESTADOR_MEUS_SERVIÇOS-MAPA"
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
  local patterns="$1"
  IFS='|' read -ra bases <<< "$patterns"
  for base in "${bases[@]}"; do
    for f in "$assets"/*; do
      [[ -f "$f" ]] || continue
      name=$(basename "$f")
      stem="${name%.*}"
      [[ "$stem" == "$base" ]] && { echo "$f"; return 0; }
    done
  done
  return 1
}

missing=()
for canonical in "${!expected[@]}"; do
  if src=$(find_asset "${expected[$canonical]}"); then
    cp -f "$src" "$assets/$canonical"
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
