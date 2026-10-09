#!/usr/bin/env bash
# Instala glpi-agent en un host Linux y lo enruta a la Entidad del cliente por tag.
# Usa el instalador oficial de glpi-project (GitHub releases). La tabla de tags
# por cliente es documentación interna, no está en este repo.
#
# Uso (como root):  ./install-glpi-agent.sh <TAG> [VERSION] [SERVER]
#   ./install-glpi-agent.sh CLIENTE01
set -euo pipefail

TAG="${1:?Uso: $0 <TAG> [VERSION] [SERVER]}"
VERSION="${2:-1.19}"
SERVER="${3:-https://cop.openmind.com.ar/}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Ejecutar como root (sudo)." >&2
  exit 1
fi

installer="glpi-agent-${VERSION}-linux-installer.pl"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Descargando ${installer}..."
curl -fsSL -o "$tmp/$installer" \
  "https://github.com/glpi-project/glpi-agent/releases/download/${VERSION}/${installer}"

echo "Instalando glpi-agent ${VERSION} con TAG=${TAG} hacia ${SERVER}..."
perl "$tmp/$installer" --install --server="$SERVER" --tag="$TAG" --runnow

systemctl --no-pager status glpi-agent || true
echo "Listo. Verificar en GLPI que $(hostname) aparezca en la entidad del tag ${TAG}."
