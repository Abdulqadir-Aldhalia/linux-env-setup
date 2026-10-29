#!/usr/bin/env bash
# linux-env-setup — Fedora + KDE Plasma with Hyprland-style keybinds and tiling.
#
#   ./install.sh                 everything below (except optional packages)
#   ./install.sh --packages      dnf repos + packages + flatpaks
#   ./install.sh --shell         zsh, oh-my-zsh, plugins, theme
#   ./install.sh --dotfiles      link configs into $HOME
#   ./install.sh --kde           Hyprland-style KDE: tiling, shortcuts, cheat sheet
#   ./install.sh --gaming --asus extra package groups (combine with the above)
#
# Configs are symlinked, so editing them in $HOME edits the repo: commit and
# pull on your other machines to stay in sync. Anything replaced is moved to
# ~/.local/state/linux-env-setup/backup-<date>/.
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP="$HOME/.local/state/linux-env-setup/backup-$(date +%Y%m%d-%H%M%S)"

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

# link <source in repo> <target in $HOME>
link() {
    local src=$1 dst=$2
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        local rel=${dst#"$HOME"/}
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$dst" "$BACKUP/$rel"
        warn "backed up ~/$rel"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  linked ~/${dst#"$HOME"/}"
}

pkg_list() { # strip comments / blank lines
    sed -e 's/#.*//' -e '/^\s*$/d' "$@"
}

install_packages() {
    say "Repositories"
    "$REPO/packages/repos.sh"

    local lists=("$REPO"/packages/{base,dev,desktop,fonts}.txt)
    $WITH_GAMING && lists+=("$REPO/packages/optional/gaming.txt")
    if $WITH_ASUS; then
        sudo dnf copr enable -y lukenukem/asus-linux
        lists+=("$REPO/packages/optional/asus.txt")
    fi

    say "dnf packages"
    # --skip-unavailable: one missing package should not abort the whole install
    sudo dnf install -y --skip-unavailable $(pkg_list "${lists[@]}")

    if rpm -q moby-engine >/dev/null 2>&1; then
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"
    fi

    say "Flatpaks"
    flatpak install -y --noninteractive flathub $(pkg_list "$REPO/packages/flatpak.txt")
}

install_shell() {
    say "zsh + oh-my-zsh"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    [[ -d "$custom/plugins/zsh-autosuggestions" ]] ||
        git clone -q https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
    [[ -d "$custom/plugins/zsh-syntax-highlighting" ]] ||
        git clone -q https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting"
    [[ -f "$custom/themes/agnosterzak.zsh-theme" ]] ||
        curl -fsSL -o "$custom/themes/agnosterzak.zsh-theme" \
            https://raw.githubusercontent.com/zakaziko99/agnosterzak-ohmyzsh-theme/master/agnosterzak.zsh-theme

    if ! command -v pokemon-colorscripts >/dev/null; then
        local tmp
        tmp=$(mktemp -d)
        git clone -q --depth 1 https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$tmp/pcs"
        (cd "$tmp/pcs" && sudo ./install.sh)
        rm -rf "$tmp"
    fi

    if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
        chsh -s "$(command -v zsh)"
    fi
}

install_dotfiles() {
    say "Dotfiles"
    link "$REPO/dotfiles/.zshrc" "$HOME/.zshrc"
    for dir in "$REPO"/dotfiles/.config/*; do
        link "$dir" "$HOME/.config/$(basename "$dir")"
    done
}

install_kde() {
    say "KDE: scripts, cheat sheet, KWin scripts"
    chmod +x "$REPO"/kde/bin/*.sh "$REPO"/kde/*.sh
    link "$REPO/kde/bin" "$HOME/.config/kde-hypr"
    for script in "$REPO"/kde/kwin-scripts/*; do
        link "$script" "$HOME/.local/share/kwin/scripts/$(basename "$script")"
    done
    "$REPO/kde/install-krohnkite.sh"

    say "KDE: app launchers"
    mkdir -p "$HOME/.local/share/applications"
    for tpl in "$REPO"/kde/applications/*.desktop.in; do
        sed "s|@HOME@|$HOME|g" "$tpl" > "$HOME/.local/share/applications/$(basename "$tpl" .in)"
    done
    kbuildsycoca6 >/dev/null 2>&1 || true

    say "KDE: settings"
    "$REPO/kde/apply-settings.sh"

    say "KDE: shortcuts"
    if busctl --user status org.kde.kglobalaccel >/dev/null 2>&1; then
        sleep 3 # let KWin load the scripts so their shortcuts exist
        python3 "$REPO/kde/bin/apply-shortcuts.py"
    else
        warn "Plasma is not running. After logging in to Plasma, run:"
        warn "  python3 ~/.config/kde-hypr/apply-shortcuts.py"
    fi
}

DO_PACKAGES=false DO_SHELL=false DO_DOTFILES=false DO_KDE=false
WITH_GAMING=false WITH_ASUS=false
for arg in "$@"; do
    case $arg in
        --packages) DO_PACKAGES=true ;;
        --shell) DO_SHELL=true ;;
        --dotfiles) DO_DOTFILES=true ;;
        --kde) DO_KDE=true ;;
        --gaming) WITH_GAMING=true ;;
        --asus) WITH_ASUS=true ;;
        -h | --help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown option: $arg (see --help)"; exit 1 ;;
    esac
done
if ! $DO_PACKAGES && ! $DO_SHELL && ! $DO_DOTFILES && ! $DO_KDE; then
    DO_PACKAGES=true DO_SHELL=true DO_DOTFILES=true DO_KDE=true
fi

$DO_PACKAGES && install_packages
$DO_SHELL && install_shell
$DO_DOTFILES && install_dotfiles
$DO_KDE && install_kde

say "Done."
[[ -d "$BACKUP" ]] && echo "Replaced files were backed up to: $BACKUP"
if $DO_KDE; then
    echo "Log out and back in once, so KDE picks up every shortcut. Then press SUPER+H."
fi
