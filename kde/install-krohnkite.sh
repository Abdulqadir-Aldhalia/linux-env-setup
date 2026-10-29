#!/usr/bin/env bash
# Installs (or upgrades) the Krohnkite tiling KWin script.
set -euo pipefail

version=${KROHNKITE_VERSION:-0.9.9.2}
url="https://github.com/anametologin/krohnkite/releases/download/${version}/krohnkite.kwinscript"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/krohnkite.kwinscript" "$url"
if [[ -d "$HOME/.local/share/kwin/scripts/krohnkite" ]]; then
    kpackagetool6 --type=KWin/Script -u "$tmp/krohnkite.kwinscript"
else
    kpackagetool6 --type=KWin/Script -i "$tmp/krohnkite.kwinscript"
fi
echo "Krohnkite $version installed."
