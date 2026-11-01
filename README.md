# linux-env-setup

My Fedora + KDE Plasma setup: **Hyprland-style keybinds, dynamic tiling and smooth workspaces on top of a stable KDE desktop**, plus my shell, terminal, editor and the packages I use.

One command sets up a fresh machine, and the same repo keeps all my devices in sync. It's also a backup: if a machine dies, clone, run, log in, and everything is back.

I built this after moving from Hyprland ([JaKooLit / KoolDots](https://github.com/LinuxBeginnings)) to KDE Plasma 6 for stability and its built-in tools, while keeping the Hyprland workflow I was used to.

---

## Contents

- [What you get](#what-you-get)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [What the installer does](#what-the-installer-does)
- [How the KDE layer works](#how-the-kde-layer-works)
- [Using it day to day](#using-it-day-to-day)
- [Keybinds](#keybinds)
- [Keeping devices in sync](#keeping-devices-in-sync)
- [Customising](#customising)
- [Backups, uninstalling and restoring](#backups-uninstalling-and-restoring)
- [Troubleshooting](#troubleshooting)
- [Repo layout](#repo-layout)
- [Credits](#credits) · [License](#license)

---

## What you get

| | |
|---|---|
| **Hyprland keybinds in KDE** | `SUPER+Enter` terminal, `SUPER+D` launcher, `SUPER+Q` close, `SUPER+1…0` workspaces, `SUPER+SHIFT+1…0` move the window and follow it, and more. [Full list](#keybinds) |
| **Dynamic tiling** | [Krohnkite](https://github.com/anametologin/krohnkite) with dwindle, master/stack, columns, monocle and floating layouts. Each workspace keeps its own layout. 8px gaps, no title bars on tiled windows |
| **Tiling on/off** | `SUPER+SHIFT+T` switches every workspace between tiling and floating windows with title bars, like plain KDE |
| **Focus border** | A thin accent-colored frame around the focused window. Unfocused windows are dimmed |
| **Cheat sheet** | `SUPER+H` opens a popup of every key, grouped by section. `SUPER+SHIFT+K` opens a searchable list |
| **10 smooth workspaces** | Slide animation (the wallpaper stays still), wrap-around, 4-finger swipes on the touchpad |
| **Sensible window rules** | Apps never open maximized (they would skip tiling). Picture-in-picture videos stay on top on every workspace |
| **Shell & terminal** | zsh with a clean, readable prompt (directory, git branch and status, time), kitty with the [Catppuccin Mocha](https://github.com/catppuccin/kitty) theme, and fastfetch system info on start |
| **Apps** | LazyVim, rofi, btop, yazi and cava configs, plus my package list |

## Requirements

- **Fedora** (tested on Fedora 44). The package step uses `dnf` and COPR.
- **KDE Plasma 6 on Wayland** (tested on 6.7) for the KDE part. On another desktop, install Plasma first: `sudo dnf group install kde-desktop`.
- A normal user account with `sudo`. Don't run the installer as root.

## Quick start

```bash
git clone https://github.com/Abdulqadir-Aldhalia/linux-env-setup.git ~/linux-env-setup
cd ~/linux-env-setup
./install.sh --dry-run     # optional: see exactly what it will do
./install.sh               # do it
```

When it finishes, **log out and back in once**, then press `SUPER+H`.

Keep the repo where you cloned it. Your configs are linked to it, so deleting or moving the folder breaks them.

### Running only some parts

```bash
./install.sh --dotfiles --kde          # just configs + KDE layer (no packages)
./install.sh --packages --gaming       # packages, including Steam
./install.sh --packages --asus         # packages, including ASUS laptop tools
```

| Option | Does |
|---|---|
| `--packages` | Repos (RPM Fusion, VS Code, Brave, COPR, Flathub), dnf packages, Flatpaks |
| `--shell` | zsh, oh-my-zsh, plugins, default shell |
| `--dotfiles` | Links configs from `dotfiles/` into `$HOME` |
| `--kde` | The Hyprland-style KDE layer: tiling, shortcuts, cheat sheet, focus border |
| `--gaming`, `--asus` | Extra package groups, used together with `--packages` |
| `--dry-run` | Prints every action without changing anything |
| `--uninstall` | Removes the links and restores your backups ([details](#backups-uninstalling-and-restoring)) |

With no part given, it runs all four. Every step is **safe to re-run**: finished steps print `ok` and are skipped.

---

## What the installer does

### `--packages`

1. **`packages/repos.sh`** enables the extra repositories:
   - **RPM Fusion** free and nonfree: codecs, Steam
   - **VS Code** (Microsoft) and **Brave**
   - **COPR**: `dejan/lazygit` and `lihaohong/yazi`, which aren't in Fedora
   - **Flathub**, for Flatpaks
2. **Installs dnf packages** from these lists (one name per line, `#` for comments):

   | List | What's in it |
   |---|---|
   | `packages/base.txt` | zsh, git, fzf, ripgrep, fd, bat, lsd, btop, nvtop, fastfetch, yazi, lazygit, neovim, `python3-dbus` (needed by the shortcut script) |
   | `packages/dev.txt` | gcc, make, VS Code, Docker (`moby-engine` + compose) |
   | `packages/desktop.txt` | kitty, rofi, yad (cheat sheet), clipboard tools, qalculate, Spectacle, Thunar, mpv, pavucontrol, KDE Connect, Brave, OBS, Syncthing |
   | `packages/fonts.txt` | JetBrains Mono, Fira Code, Font Awesome, Noto CJK, Source Code Pro |
   | `packages/optional/gaming.txt` | Steam (`--gaming`) |
   | `packages/optional/asus.txt` | asusctl, supergfxctl, ROG GUI (`--asus`, enables the `lukenukem/asus-linux` COPR) |

   It installs with `--skip-unavailable`, so one renamed package doesn't stop the rest.
3. **Docker**: enables the service and adds you to the `docker` group, so you can run `docker` without `sudo` (after your next login).
4. **Flatpaks** from `packages/flatpak.txt`: Zen Browser, Free Download Manager, Zoom.

### `--shell`

- Installs **oh-my-zsh** without letting it replace `.zshrc` (that comes from `dotfiles/`) or take over the terminal.
- Adds the **zsh-autosuggestions** (grey suggestions from your history; press → to accept) and **zsh-syntax-highlighting** (valid commands turn green, typos red) plugins.
- Makes **zsh your default shell**. It asks for your password.

### `--dotfiles`

Each config in `dotfiles/` is **symlinked** into place, replacing what was there:

| Repo | Becomes |
|---|---|
| `dotfiles/.zshrc` | `~/.zshrc` |
| `dotfiles/.config/kitty` | `~/.config/kitty` (the same applies to `nvim`, `rofi`, `fastfetch`, `btop`, `yazi` and `cava`) |

A symlink means the file lives in the repo, and `~/.config/kitty` just points to it. Editing your config is editing the repo, which is what makes [syncing](#keeping-devices-in-sync) work. Anything that was already there is moved to a backup first.

**The terminal look:**
- **Prompt** (in `.zshrc`, no theme to install): the current folder in blue, then the git branch in magenta with `*` for unstaged and `+` for staged changes. The `❯` on the next line turns red when the last command failed, and the time is on the right. It uses plain colored text, so it stays readable with any color scheme.
- **kitty theme:** Catppuccin Mocha (`kitty-themes/Catppuccin-Mocha.conf`), at 95% opacity. Pick another with the `include` line in `kitty.conf`; `kitty-themes/` has many.
- **Greeting:** fastfetch prints system info with a small Fedora logo when a terminal opens. Configured in `.config/fastfetch/config.jsonc`; remove the `fastfetch` line in `.zshrc` to turn it off.

`.zshrc` only sets up tools that exist: sdkman, bun and opencode are skipped if they aren't installed, so the same file works on every machine.

### `--kde`

1. **Links `kde/bin` to `~/.config/kde-hypr`**: the cheat sheet, keybind search, tiling toggle, web search, calculator and the shortcut script.
2. **Links the two KWin scripts** from `kde/kwin-scripts/` (explained [below](#how-the-kde-layer-works)) into `~/.local/share/kwin/scripts/`.
3. **Installs Krohnkite** (`kde/install-krohnkite.sh`), the latest release from the [KDE Store](https://store.kde.org/p/2144146), with GitHub as a fallback. It never downgrades a newer version you already have.
4. **Writes app launchers** to `~/.local/share/applications/hypr-*.desktop`. These are hidden menu entries that the shortcuts start (terminal, rofi, Thunar, ...).
5. **Applies KDE settings** (`kde/apply-settings.sh`): 10 workspaces, slide animation, faster animations, SUPER+drag to move and resize, Krohnkite gaps and floating apps, dimming of unfocused windows, window rules, and kitty as KDE's terminal.
6. **Sets every shortcut** (`kde/bin/apply-shortcuts.py`) through KDE's shortcut service, and removes KDE defaults that clash, such as `SUPER+1…9` opening taskbar entries.

---

## How the KDE layer works

KDE can already do most of what Hyprland does. This layer adds the missing parts and remaps the keys.

| Piece | What it is | Why it's needed |
|---|---|---|
| **Krohnkite** | A third-party KWin script for dynamic tiling | KDE's built-in tiling is manual, with no automatic layouts |
| **`hyprlike`** (`kde/kwin-scripts/hyprlike`) | My KWin script | KDE has no "move window to workspace *and follow it*". It also adds the tiling toggle keys and un-maximizes apps as they open |
| **`focusframe`** (`kde/kwin-scripts/focusframe`) | My KWin script, written in QML | KDE can't draw a colored border around the focused window. This draws a click-through frame that follows it |
| **`apply-shortcuts.py`** | Sets all shortcuts through KDE's shortcut service (`kglobalaccel`) | Editing `kglobalshortcutsrc` directly doesn't stick: KDE overwrites it at logout |
| **App launchers** | `hypr-*.desktop` files | KDE shortcuts start apps through desktop entries |
| **Window rules** | `no-initial-maximize`, `pip` | Krohnkite deliberately ignores maximized windows, and many apps remember being maximized, so without this they would never tile |
| **Tiling toggle** | `SUPER+SHIFT+T` → `hyprlike` visits each workspace and switches Krohnkite between its tile and floating layouts, then returns you to where you were | Krohnkite can't be unloaded while you're logged in: its handlers keep running and re-tile windows. Switching layouts keeps one Krohnkite running and just changes what it does |
| **`check-shortcuts.py`** | Asks KDE what every cheat-sheet key is bound to and compares it with the sheet | One command to confirm everything works after an install, update or reboot |
| **Cheat sheet** | `cheatsheet.sh` (yad popup) and `keybinds-search.sh` (rofi), both reading `keybinds.tsv` | One file feeds both |

---

## Using it day to day

- **Tiling** is on by default. New windows join the layout automatically.
- **Change the layout** of the current workspace with `SUPER+ALT+1` (dwindle), `2` (master/stack), `3` (columns), `4` (monocle) or `5` (floating). `SUPER+ALT+L` cycles through them.
- **Plain KDE for one workspace:** `SUPER+ALT+5` (floating layout). The others keep tiling.
- **Plain KDE everywhere:** `SUPER+SHIFT+T` (or `SUPER+ALT+T`) switches every workspace to floating, and back to tiling. Krohnkite's popup shows "Floating" or "Tile". Each login starts with tiling on.
- **One window floats instead of tiling:** `SUPER+Space` toggles it. Dialogs, popups and fixed-size windows float on purpose.
- **Move a window to another workspace:** `SUPER+SHIFT+number` (you follow it) or `SUPER+CTRL+number` (it goes without you).
- **Forgot a key?** `SUPER+H`.

---

## Keybinds

`SUPER` is the Windows key. The same list is in the `SUPER+H` popup.

#### HELP

| Key | Action | Note |
|---|---|---|
| `SUPER H` | Cheat sheet (press again to close) |  |
| `SUPER SHIFT K` | Search keybinds | rofi |

#### APPS

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

#### WINDOWS

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

#### TILING

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

#### WORKSPACES

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

#### SCREENSHOTS

| Key | Action | Note |
|---|---|---|
| `SUPER SHIFT S / ALT SHIFT S` | Region | Spectacle |
| `SUPER Print` | Full screen | Spectacle |
| `ALT Print` | Active window | Spectacle |

#### SYSTEM

| Key | Action | Note |
|---|---|---|
| `SUPER N` | Night light on / off |  |
| `CTRL ALT L` | Lock screen |  |
| `CTRL ALT P / CTRL ALT Del` | Power / logout menu |  |
| `ALT SHIFT` | Switch keyboard layout | EN / AR |

---

## Keeping devices in sync

Your configs are symlinks into this repo, so the workflow is plain git:

```bash
# on the machine where you changed something
cd ~/linux-env-setup
git status                       # see what changed
git add -A && git commit -m "kitty: bigger font"
git push

# on your other machines
cd ~/linux-env-setup && git pull
```

After pulling:
- **Config changes** (kitty, nvim, zsh, rofi, ...) apply right away, or the next time you open that app.
- **Shortcut changes:** run `python3 ~/.config/kde-hypr/apply-shortcuts.py`.
- **KDE setting changes:** run `~/linux-env-setup/kde/apply-settings.sh`.
- **New packages:** run `./install.sh --packages`.
- **Changes to the KWin scripts** (`hyprlike`, `focusframe`): log out and back in. KWin only reloads them at login.

**Machine-specific settings** go in `~/.zshrc.local`. `.zshrc` loads it if it exists, and it's not part of the repo. Use it for aliases with local paths, work-only variables, and so on.

Some apps write into their config folder (nvim updates `lazy-lock.json`, btop saves its settings). That shows up in `git status`; commit it or discard it with `git checkout -- <file>`.

---

## Customising

| I want to… | Do this |
|---|---|
| Change or add a shortcut | Edit `kde/bin/apply-shortcuts.py`, run it (it applies instantly), and update `kde/bin/keybinds.tsv` so the cheat sheet matches |
| Add a package | Add the name to the right file in `packages/`, run `./install.sh --packages` |
| Change tiling gaps | Edit the `screenGap*` lines in `kde/apply-settings.sh`, run it |
| Make an app always float | Add its window class to `floatingClass` in `kde/apply-settings.sh` |
| Change dimming | `Strength` under `Effect-diminactive` in `kde/apply-settings.sh` (0 turns it off) |
| Change the focus border | `borderWidth`, `radius` and `border.color` in `kde/kwin-scripts/focusframe/contents/ui/main.qml`, then log out and in |
| Faster or slower animations | `AnimationDurationFactor` in `kde/apply-settings.sh` (1.0 is KDE's default, lower is faster) |

**Shortcut format** in `apply-shortcuts.py`: `"Meta+Shift+Return"`, `"Meta+Alt+Space"`, `"Ctrl+Alt+L"`. `Meta` is SUPER.

> **SHIFT on Wayland:** KDE receives `SHIFT+1` as `!` and `SHIFT+[` as `{`. The script's `with_shifted()` helper binds both forms. Use it for any new SHIFT+number or SHIFT+symbol shortcut.

> **Don't edit `~/.config/kglobalshortcutsrc` by hand.** KDE keeps shortcuts in memory and writes them back at logout, overwriting your edits. Always use the script.

---

## Backups, uninstalling and restoring

- **Backups:** before replacing anything, the installer moves it to `~/.local/state/linux-env-setup/backup-<date>-<time>/`, keeping its path. Each run gets its own folder.
- **Undo the links:** run `./install.sh --uninstall`. It removes every symlink that points into the repo and puts back the most recent backup of each path. Preview it with `./install.sh --uninstall --dry-run`.
- **What `--uninstall` leaves alone:** installed packages, KDE settings and the `hypr-*.desktop` launchers. To return KDE shortcuts to the defaults, use System Settings → Keyboard → Shortcuts → "Reset to Defaults". To switch tiling off, press `SUPER+SHIFT+T`.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Not sure what's broken | Run `python3 ~/.config/kde-hypr/check-shortcuts.py`. It checks all ~140 key bindings and the launchers, and prints a FAIL line for anything wrong |
| A shortcut does nothing | Log out and back in once after installing: KDE only wires up launcher shortcuts at login. Then run `python3 ~/.config/kde-hypr/apply-shortcuts.py` again |
| A shortcut opens the wrong thing | Another app or KDE default has the key. Run the shortcut script again; it clears known clashes |
| An app won't tile | Is it maximized? Press `SUPER+F` to un-maximize. Is it a dialog or fixed-size window? Those float on purpose; `SUPER+Space` tiles it anyway |
| Tiling toggle has no effect | Log out and back in. Older versions of this setup unloaded Krohnkite, which leaves hidden copies running until the next login |
| No border around the focused window | Fullscreen and minimized windows have none. Otherwise log out and in; KWin loads `focusframe` at login |
| Krohnkite was updated from the KDE Store | Fine. The installer never downgrades it |
| `SHIFT+number` shortcuts don't fire | See the SHIFT-on-Wayland note in [Customising](#customising) |

---

## Repo layout

```
install.sh                    entry point (run with --help)
packages/
  repos.sh                    RPM Fusion, VS Code, Brave, COPR, Flathub
  base.txt dev.txt desktop.txt fonts.txt flatpak.txt
  optional/gaming.txt asus.txt
dotfiles/                     linked into $HOME
  .zshrc
  .config/{kitty,nvim,rofi,fastfetch,btop,yazi,cava}
kde/
  bin/                        linked to ~/.config/kde-hypr
    apply-shortcuts.py        every shortcut, set through KDE's shortcut service
    keybinds.tsv              the cheat sheet's contents (Key, Action, Note)
    cheatsheet.sh             SUPER+H popup
    keybinds-search.sh        SUPER+SHIFT+K rofi search
    check-shortcuts.py        verifies every cheat-sheet key, launcher and the toggle service
    web-search.sh calc.sh     SUPER+S, SUPER+ALT+C
  kwin-scripts/
    hyprlike/                 move-window-and-follow, tiling on/off, un-maximize on open (while tiling)
    focusframe/               border around the focused window
  applications/*.desktop.in   launcher templates (@HOME@ is replaced at install)
  apply-settings.sh           KWin settings, effects, window rules
  install-krohnkite.sh        installs or upgrades Krohnkite, never downgrades
```

---

## Credits

- [JaKooLit / KoolDots](https://github.com/LinuxBeginnings): the kitty, rofi and fastfetch configs started there (GPL-3.0)
- [Krohnkite](https://github.com/anametologin/krohnkite): tiling for KWin (MIT). Not stored in this repo; downloaded at install time
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), [Catppuccin](https://github.com/catppuccin/kitty) (kitty theme, MIT), [LazyVim](https://github.com/LazyVim/LazyVim)

## License

[GPL-3.0](LICENSE). Use it, fork it, adapt it. If you share a modified version, share it under the same license.
