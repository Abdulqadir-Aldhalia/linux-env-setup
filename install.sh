#!/usr/bin/env bash
# linux-env-setup — Fedora + KDE Plasma with Hyprland-style keybinds and tiling.
#
# Usage: ./install.sh [parts] [extras] [--dry-run]
#
# Parts (default: all four):
#   --packages   dnf repos, dnf packages, Flatpaks
#   --shell      zsh, oh-my-zsh, plugins
#   --dotfiles   link configs from dotfiles/ into $HOME
#   --kde        Hyprland-style KDE: tiling, shortcuts, cheat sheet, focus border
#
# Extras (with --packages):
#   --gaming     Steam
#   --asus       asusctl, supergfxctl (ASUS laptops)
#
#   --uninstall  remove the links and restore the most recent backups
#   --dry-run    show what would happen, change nothing (works with --uninstall)
#   -h, --help   this help
#
# Configs are symlinked, so editing them in $HOME edits the repo. Anything the
# installer replaces is moved to ~/.local/state/linux-env-setup/backup-<date>/.
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP="$HOME/.local/state/linux-env-setup/backup-$(date +%Y%m%d-%H%M%S)"

DRY_RUN=false
DO_PACKAGES=false DO_SHELL=false DO_DOTFILES=false DO_KDE=false
WITH_GAMING=false WITH_ASUS=false

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m  ! \033[0m%s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# run <command...> — runs it, or only prints it in --dry-run mode
run() {
    if $DRY_RUN; then
        printf '    \033[2m[dry-run]\033[0m %s\n' "$*"
    else
        "$@"
    fi
}

# link <source in repo> <target in $HOME>
# Replaces the target with a symlink to the repo, backing up whatever was there.
link() {
    local src=$1 dst=$2 rel=${2#"$HOME"/}
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        info "ok      ~/$rel"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        info "backup  ~/$rel"
        run mkdir -p "$BACKUP/$(dirname "$rel")"
        run mv "$dst" "$BACKUP/$rel"
    fi
    info "link    ~/$rel -> ${src#"$REPO"/}"
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
}

# Package names from list files, without comments and blank lines.
pkg_list() {
    sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$@"
}

need() { # need <command> <hint>
    command -v "$1" >/dev/null || die "'$1' not found. $2"
}

plasma_running() {
    busctl --user status org.kde.kglobalaccel >/dev/null 2>&1
}

install_packages() {
    need dnf "This setup targets Fedora."

    say "Repositories (RPM Fusion, VS Code, Brave, COPR, Flathub)"
    run "$REPO/packages/repos.sh"

    local lists=("$REPO"/packages/{base,dev,desktop,fonts}.txt)
    if $WITH_GAMING; then
        lists+=("$REPO/packages/optional/gaming.txt")
    fi
    if $WITH_ASUS; then
        run sudo dnf copr enable -y lukenukem/asus-linux
        lists+=("$REPO/packages/optional/asus.txt")
    fi

    say "dnf packages ($(pkg_list "${lists[@]}" | wc -l) from ${#lists[@]} lists)"
    # --skip-unavailable: one renamed/missing package must not abort the rest
    mapfile -t pkgs < <(pkg_list "${lists[@]}")
    run sudo dnf install -y --skip-unavailable "${pkgs[@]}"

    if rpm -q moby-engine >/dev/null 2>&1 || $DRY_RUN; then
        say "Docker service (and docker group for $USER)"
        run sudo systemctl enable --now docker
        run sudo usermod -aG docker "$USER"
    fi

    say "Flatpaks"
    mapfile -t flatpaks < <(pkg_list "$REPO/packages/flatpak.txt")
    run flatpak install -y --noninteractive flathub "${flatpaks[@]}"
}

install_shell() {
    local custom="$HOME/.oh-my-zsh/custom"

    say "oh-my-zsh"
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        info "ok      already installed"
    else
        # KEEP_ZSHRC: our .zshrc comes from dotfiles/; RUNZSH/CHSH: don't take over the terminal
        run env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    say "zsh plugins"
    local plugin
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [[ -d "$custom/plugins/$plugin" ]]; then
            info "ok      $plugin"
        else
            run git clone -q "https://github.com/zsh-users/$plugin" "$custom/plugins/$plugin"
        fi
    done


    say "Default shell"
    if [[ "$(getent passwd "$USER" | cut -d: -f7)" == */zsh ]]; then
        info "ok      zsh"
    else
        run chsh -s "$(command -v zsh)"
    fi
}

install_dotfiles() {
    say "Dotfiles"
    link "$REPO/dotfiles/.zshrc" "$HOME/.zshrc"
    local dir
    for dir in "$REPO"/dotfiles/.config/*/; do
        dir=${dir%/}
        link "$dir" "$HOME/.config/$(basename "$dir")"
    done
}

install_kde() {
    need kwriteconfig6 "Install KDE Plasma 6 first (sudo dnf group install kde-desktop)."

    say "KDE scripts (cheat sheet, shortcuts, tiling toggle) -> ~/.config/kde-hypr"
    run chmod +x "$REPO"/kde/bin/*.sh "$REPO"/kde/*.sh
    link "$REPO/kde/bin" "$HOME/.config/kde-hypr"

    say "KWin scripts"
    local script
    for script in "$REPO"/kde/kwin-scripts/*/; do
        script=${script%/}
        link "$script" "$HOME/.local/share/kwin/scripts/$(basename "$script")"
    done
    run "$REPO/kde/install-krohnkite.sh"

    say "App launchers (bound to SUPER+Enter, SUPER+D, ...)"
    local tpl out
    for tpl in "$REPO"/kde/applications/*.desktop.in; do
        out="$HOME/.local/share/applications/$(basename "$tpl" .in)"
        info "write   ~/${out#"$HOME"/}"
        if ! $DRY_RUN; then
            mkdir -p "$(dirname "$out")"
            sed "s|@HOME@|$HOME|g" "$tpl" >"$out"
        fi
    done
    run kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

    say "KWin settings, window rules, effects"
    run "$REPO/kde/apply-settings.sh"

    say "Shortcuts"
    if plasma_running; then
        $DRY_RUN || sleep 3 # give KWin time to load the scripts, so their shortcuts exist
        run python3 "$REPO/kde/bin/apply-shortcuts.py"
    else
        warn "Plasma is not running here. After logging in to Plasma, run:"
        warn "  python3 ~/.config/kde-hypr/apply-shortcuts.py"
    fi
}

# Remove every symlink that points into this repo and put back the most recent
# backup of that path, if there is one. KDE settings and packages are left alone.
uninstall() {
    say "Removing links into $REPO"
    local backups="$HOME/.local/state/linux-env-setup" found=false dst rel latest
    while IFS= read -r -d '' dst; do
        [[ "$(readlink -f "$dst")" == "$REPO"/* ]] || continue
        found=true
        rel=${dst#"$HOME"/}
        info "unlink  ~/$rel"
        run rm "$dst"
        latest=$(find "$backups" -mindepth 1 -maxdepth 1 -type d -name 'backup-*' 2>/dev/null | sort -r |
            while read -r b; do [[ -e "$b/$rel" || -L "$b/$rel" ]] && { echo "$b"; break; }; done)
        if [[ -n "$latest" ]]; then
            info "restore ~/$rel  (from $(basename "$latest"))"
            run mv "$latest/$rel" "$dst"
        fi
    done < <(find "$HOME" "$HOME/.config" "$HOME/.local/share/kwin/scripts" -maxdepth 1 -type l -print0 2>/dev/null)
    $found || info "nothing linked"
    info "App launchers in ~/.local/share/applications/hypr-*.desktop and KDE settings were kept."
}

for arg in "$@"; do
    if [[ $arg == --uninstall ]]; then
        [[ " $* " == *" --dry-run "* ]] && DRY_RUN=true
        uninstall
        exit 0
    fi
done

for arg in "$@"; do
    case $arg in
        --packages) DO_PACKAGES=true ;;
        --shell) DO_SHELL=true ;;
        --dotfiles) DO_DOTFILES=true ;;
        --kde) DO_KDE=true ;;
        --gaming) WITH_GAMING=true ;;
        --asus) WITH_ASUS=true ;;
        --dry-run) DRY_RUN=true ;;
        -h | --help) sed -n '2,/^set -euo/{/^set -euo/d;s/^# \{0,1\}//;p}' "$0"; exit 0 ;;
        *) die "unknown option: $arg (see --help)" ;;
    esac
done
if ! $DO_PACKAGES && ! $DO_SHELL && ! $DO_DOTFILES && ! $DO_KDE; then
    DO_PACKAGES=true DO_SHELL=true DO_DOTFILES=true DO_KDE=true
fi
[[ $EUID -ne 0 ]] || die "run as your normal user; it asks for sudo when needed."
$DRY_RUN && say "Dry run: nothing will be changed"

if $DO_PACKAGES; then install_packages; fi
if $DO_SHELL; then install_shell; fi
if $DO_DOTFILES; then install_dotfiles; fi
if $DO_KDE; then install_kde; fi

say "Done."
if [[ -d "$BACKUP" ]]; then
    info "Replaced files were backed up to: $BACKUP"
fi
if $DO_KDE && ! $DRY_RUN; then
    info "Log out and back in once so KDE picks up every shortcut, then press SUPER+H."
fi
