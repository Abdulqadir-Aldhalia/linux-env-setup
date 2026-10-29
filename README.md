# linux-env-setup

My Fedora + KDE Plasma setup: **Hyprland-style keybinds, dynamic tiling and smooth workspaces on top of a stable KDE**, plus my shell, terminal, editor and the packages I use. One command sets up a new machine, and the same repo keeps all my devices in sync.

Built after moving from Hyprland ([JaKooLit / KoolDots](https://github.com/LinuxBeginnings)) to KDE Plasma 6 for stability, while keeping the Hyprland workflow.

## Features

- **Hyprland keybinds in KDE**: `SUPER+Enter` terminal, `SUPER+D` launcher, `SUPER+Q` close, `SUPER+1…0` workspaces, `SUPER+SHIFT+1…0` move window and follow, and more
- **Dynamic tiling** with [Krohnkite](https://github.com/anametologin/krohnkite): dwindle, master/stack, columns, monocle and floating layouts, chosen per workspace, with 8px gaps
- **Tiling on/off** with `SUPER+SHIFT+T` for a plain KDE experience when you need it
- **Focus border**: a thin accent-colored frame around the focused window, with unfocused windows dimmed
- **Cheat sheet popup** (`SUPER+H`) and searchable keybinds (`SUPER+SHIFT+K`)
- **10 workspaces** with a smooth slide; the wallpaper stays still
- **Apps never open maximized**, so they always join the tiling layout; `SUPER+F` still maximizes
- Picture-in-picture videos stay on top on every workspace
- zsh + oh-my-zsh, kitty, LazyVim, rofi, fastfetch, btop, yazi and cava configs

## Requirements

- Fedora (tested on Fedora 44)
- KDE Plasma 6 on Wayland (tested on 6.7)

## Install

```bash
git clone https://github.com/Abdulqadir-Aldhalia/linux-env-setup.git ~/linux-env-setup
cd ~/linux-env-setup
./install.sh            # everything
```

Then **log out and back in once** so KDE picks up every shortcut, and press `SUPER+H`.

Or pick parts:

| Command | Does |
|---|---|
| `./install.sh --packages` | Repos (RPM Fusion, VS Code, Brave, COPR, Flathub), dnf packages, Flatpaks |
| `./install.sh --shell` | zsh, oh-my-zsh, plugins, agnosterzak theme, pokemon-colorscripts |
| `./install.sh --dotfiles` | Links configs into `$HOME` |
| `./install.sh --kde` | The Hyprland-style KDE layer: tiling, shortcuts, cheat sheet, focus border |
| `--gaming` / `--asus` | Extra package groups (Steam / ASUS laptop tools), combine with `--packages` |

Everything is safe to re-run. Any file the installer replaces is moved to `~/.local/state/linux-env-setup/backup-<date>/` first.

## Keeping devices in sync

Configs are **symlinked** into the repo, so editing `~/.config/kitty/kitty.conf` edits the repo copy.

```bash
cd ~/linux-env-setup
git add -A && git commit -m "tweak kitty" && git push   # on the machine you changed
git pull                                               # on your other machines
```

For settings that should stay on one machine only, use `~/.zshrc.local`, which `.zshrc` loads if it exists and is not in the repo.

## Customising keybinds

1. Edit `kde/bin/apply-shortcuts.py` and run it: `python3 ~/.config/kde-hypr/apply-shortcuts.py`. Changes apply instantly.
2. Update `kde/bin/keybinds.tsv` (Key, Action, Note, tab-separated) so the cheat sheet matches.

> Don't edit `~/.config/kglobalshortcutsrc` by hand: KDE overwrites it from memory at logout. The script sets shortcuts through KDE's shortcut service instead.

## Keybinds

**HELP**

| Key | Action | Note |
|---|---|---|
| `SUPER H` | Cheat sheet (press again to close) |  |
| `SUPER SHIFT K` | Search keybinds | rofi |

**APPS**

| Key | Action | Note |
|---|---|---|
| `SUPER Enter` | Terminal | kitty |
| `SUPER D` | App launcher | rofi |
| `SUPER E` | File manager | thunar |
| `SUPER B` | Browser | default browser |
| `SUPER S` | Web search | rofi |
| `SUPER ALT E` | Emoji picker | rofi |
| `SUPER ALT C` | Calculator | rofi |
| `SUPER V / SUPER ALT V` | Clipboard history | Klipper |
| `ALT Space` | KRunner | search everything |

**WINDOWS**

| Key | Action | Note |
|---|---|---|
| `SUPER Q` | Close window |  |
| `SUPER SHIFT Q / SUPER CTRL Esc` | Kill window | click to kill |
| `SUPER F` | Maximize | press again to restore |
| `SUPER SHIFT F` | Fullscreen |  |
| `SUPER ← → ↑ ↓` | Focus window in direction |  |
| `SUPER J / K` | Focus next / previous window | tiling |
| `ALT Tab / ALT SHIFT Tab` | Window switcher |  |
| `SUPER A` | Overview | all windows + workspaces |
| `SUPER G` | Grid view | all workspaces |
| `SUPER drag LMB / RMB` | Move / resize window |  |
| `SUPER CTRL F9 / F10` | Window to prev / next monitor |  |

**TILING**

| Key | Action | Note |
|---|---|---|
| `SUPER SHIFT T / SUPER ALT T` | Tiling on / off | off = normal KDE |
| `SUPER Space` | Float / tile this window |  |
| `SUPER ALT Space` | Float / tile all windows |  |
| `SUPER CTRL ← → ↑ ↓` | Move window |  |
| `SUPER ALT ← → ↑ ↓` | Swap window |  |
| `SUPER SHIFT ← → ↑ ↓` | Resize window |  |
| `SUPER CTRL Enter` | Make master |  |
| `SUPER I` | Add master |  |
| `SUPER CTRL D` | Remove master |  |
| `SUPER SHIFT I` | Rotate layout |  |
| `SUPER R` | Rotate part |  |
| `SUPER ALT L / SUPER \` | Next layout |  |
| `SUPER SHIFT \` | Previous layout |  |
| `SUPER ALT 1` | Layout: dwindle | binary tree |
| `SUPER ALT 2` | Layout: master / stack |  |
| `SUPER ALT 3` | Layout: columns |  |
| `SUPER ALT 4` | Layout: monocle | one window at a time |
| `SUPER ALT 5` | Layout: floating | this workspace only |
| `SUPER T` | KDE tile editor | only when tiling is off |

**WORKSPACES**

| Key | Action | Note |
|---|---|---|
| `SUPER 1-0` | Go to workspace 1-10 |  |
| `SUPER SHIFT 1-0` | Move window to workspace + follow |  |
| `SUPER CTRL 1-0` | Move window to workspace silently |  |
| `SUPER Tab / .` | Next workspace |  |
| `SUPER SHIFT Tab / ,` | Previous workspace |  |
| `SUPER SHIFT ] / [` | Move window to next / prev workspace + follow |  |
| `SUPER CTRL ] / [` | Move window to next / prev workspace silently |  |
| `4-finger swipe ← →` | Switch workspace | touchpad |
| `4-finger swipe ↑` | Overview | touchpad |

**SCREENSHOTS**

| Key | Action | Note |
|---|---|---|
| `SUPER SHIFT S / ALT SHIFT S` | Region | Spectacle |
| `SUPER Print` | Full screen | Spectacle |
| `ALT Print` | Active window | Spectacle |

**SYSTEM**

| Key | Action | Note |
|---|---|---|
| `SUPER N` | Night light on / off |  |
| `CTRL ALT L` | Lock screen |  |
| `CTRL ALT P / CTRL ALT Del` | Power / logout menu |  |
| `ALT SHIFT` | Switch keyboard layout | EN / AR |

## Repo layout

```
install.sh                 entry point
packages/                  dnf lists (base, dev, desktop, fonts), flatpaks, repos.sh, optional/
dotfiles/                  linked into $HOME (.zshrc, .config/*)
kde/
  bin/                     linked to ~/.config/kde-hypr: shortcuts, cheat sheet, tiling toggle, rofi helpers
  kwin-scripts/hyprlike    move-window-and-follow, tiling toggle keys, no-maximize guard
  kwin-scripts/focusframe  border around the focused window
  applications/            launcher templates bound to shortcuts
  apply-settings.sh        KWin settings, window rules, effects
  install-krohnkite.sh     downloads the Krohnkite tiling script
```

## Troubleshooting

- **A shortcut does nothing:** log out and back in once after installing, then re-run `python3 ~/.config/kde-hypr/apply-shortcuts.py`.
- **An app won't tile:** dialogs and fixed-size windows float on purpose. `SUPER+Space` toggles any window between floating and tiled.
- **SHIFT shortcuts on Wayland:** KDE receives `SHIFT+1` as `!`, so the script binds both forms. Keep that in mind when adding your own.

## Credits

- [JaKooLit / KoolDots](https://github.com/LinuxBeginnings): origin of the kitty, rofi and fastfetch configs (GPL-3.0)
- [Krohnkite](https://github.com/anametologin/krohnkite): tiling for KWin (MIT), downloaded at install time
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), [agnosterzak](https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme), [pokemon-colorscripts](https://gitlab.com/phoneybadger/pokemon-colorscripts), [LazyVim](https://github.com/LazyVim/LazyVim)

## License

[GPL-3.0](LICENSE)
