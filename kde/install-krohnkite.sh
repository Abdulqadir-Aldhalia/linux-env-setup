#!/usr/bin/env bash
# Installs or upgrades the Krohnkite tiling KWin script. Never downgrades.
#
# Source: the KDE Store (latest release), falling back to GitHub releases.
# Pin a version with KROHNKITE_VERSION=x.y.z (downloads from GitHub).
set -euo pipefail

STORE_ID=2144146 # https://store.kde.org/p/2144146 (Krohnkite for Plasma 6)
GITHUB_FALLBACK=0.9.9.2
dir="$HOME/.local/share/kwin/scripts/krohnkite"

json_get() { # json_get <python expression on d> — reads JSON from stdin
    python3 -c "import json,sys; d=json.load(sys.stdin); print($1)"
}

installed=""
if [[ -f "$dir/metadata.json" ]]; then
    installed=$(json_get 'd["KPlugin"]["Version"]' <"$dir/metadata.json" 2>/dev/null || true)
fi

if [[ -n "${KROHNKITE_VERSION:-}" ]]; then
    version=$KROHNKITE_VERSION
    url="https://github.com/anametologin/krohnkite/releases/download/${version}/krohnkite.kwinscript"
else
    store=$(curl -fsSL "https://api.kde-look.org/ocs/v1/content/data/${STORE_ID}?format=json" 2>/dev/null || true)
    version=$(json_get 'd["data"][0]["version"]' <<<"$store" 2>/dev/null || true)
    url=$(json_get 'd["data"][0]["downloadlink1"]' <<<"$store" 2>/dev/null || true)
    if [[ -z "$version" || -z "$url" ]]; then
        version=$GITHUB_FALLBACK
        url="https://github.com/anametologin/krohnkite/releases/download/${version}/krohnkite.kwinscript"
    fi
fi

# newest of the two, by version order
newest=$(printf '%s\n%s\n' "$installed" "$version" | sort -V | tail -1)
if [[ -n "$installed" && "$newest" == "$installed" ]]; then
    echo "    ok      Krohnkite $installed installed (available: $version)"
    exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/krohnkite.kwinscript" "$url"

if [[ -n "$installed" ]]; then
    kpackagetool6 --type=KWin/Script --upgrade "$tmp/krohnkite.kwinscript" >/dev/null
    echo "    Krohnkite upgraded $installed -> $version"
else
    kpackagetool6 --type=KWin/Script --install "$tmp/krohnkite.kwinscript" >/dev/null
    echo "    Krohnkite $version installed"
fi
