#!/usr/bin/env bash
# Baixa a pasta FEIRA-LABACE do GitHub (branch main).
# Uso:
#   ./scripts/baixar-FEIRA-LABACE.sh
#   ./scripts/baixar-FEIRA-LABACE.sh /caminho/destino
set -euo pipefail

DESTINO="${1:-$HOME/FEIRA-LABACE}"
REPO="jvtechy/agendaservice-landing"
BRANCH="main"
ZIP_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.zip"
TEMP_ROOT="$(mktemp -d)"
ZIP_PATH="${TEMP_ROOT}/repo.zip"
EXTRACT_ROOT="${TEMP_ROOT}/extract"
REPO_DIR="${EXTRACT_ROOT}/${REPO##*/}-${BRANCH}"
SOURCE="${REPO_DIR}/FEIRA-LABACE"

echo ">> Destino: ${DESTINO}"
echo ">> Baixando ${ZIP_URL}"
curl -fsSL "${ZIP_URL}" -o "${ZIP_PATH}"

echo ">> Extraindo ZIP..."
mkdir -p "${EXTRACT_ROOT}"
unzip -q "${ZIP_PATH}" -d "${EXTRACT_ROOT}"

if [[ ! -d "${SOURCE}" ]]; then
  echo "Erro: pasta FEIRA-LABACE nao encontrada na branch ${BRANCH}." >&2
  exit 1
fi

echo ">> Copiando arquivos..."
mkdir -p "${DESTINO}"
cp -a "${SOURCE}/." "${DESTINO}/"

rm -rf "${TEMP_ROOT}"

echo
echo "Concluido! Pasta disponivel em: ${DESTINO}"
echo "Subpastas: originais, restauradas, restauradas_ia, videos, videos_restaurados"
