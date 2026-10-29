#!/usr/bin/env bash
# Extra repositories needed by the package lists. Safe to re-run.
set -euo pipefail
fedora=$(rpm -E %fedora)

# RPM Fusion (codecs, steam, ...)
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora}.noarch.rpm" || true

# VS Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
printf '%s\n' '[code]' 'name=Visual Studio Code' 'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
    'enabled=1' 'gpgcheck=1' 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' |
    sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

# Brave
sudo dnf config-manager addrepo --overwrite \
    --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

# COPR
for copr in dejan/lazygit lihaohong/yazi; do
    sudo dnf copr enable -y "$copr"
done

# Flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
