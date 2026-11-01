#!/usr/bin/env python3
"""Check that every key on the cheat sheet is bound to the right action.

Asks KDE's shortcut service what each key does, compares it with what the
cheat sheet promises, and checks that the programs behind the launchers exist.

    python3 ~/.config/kde-hypr/check-shortcuts.py
"""
import os
import shlex
import shutil
import subprocess
import sys

import dbus

MODS = {"Meta": 0x10000000, "Shift": 0x02000000, "Ctrl": 0x04000000, "Alt": 0x08000000}
KEYS = {
    "Return": 0x01000004, "Tab": 0x01000001, "Backtab": 0x01000002, "Esc": 0x01000000, "Print": 0x01000009,
    "Del": 0x01000007, "Left": 0x01000012, "Up": 0x01000013, "Right": 0x01000014, "Down": 0x01000015,
    "Space": 0x20, ".": 0x2E, ",": 0x2C, "[": 0x5B, "]": 0x5D, "\\": 0x5C, "|": 0x7C,
    "!": 0x21, "@": 0x40, "#": 0x23, "$": 0x24, "%": 0x25, "^": 0x5E, "&": 0x26, "*": 0x2A, "(": 0x28, ")": 0x29,
    "{": 0x7B, "}": 0x7D,
}
KEYS.update({f"F{i}": 0x01000030 + i - 1 for i in range(1, 13)})
SHIFTED = dict(zip("1234567890[]", "!@#$%^&*(){}"))


def code(seq):
    *mods, key = seq.split("+")
    k = KEYS.get(key) or ord(key.upper())
    for m in mods:
        k |= MODS[m]
    return k


# (keys, component, action) — what the cheat sheet promises
EXPECTED = [
    # help
    (["Meta+H"], "hypr-cheatsheet.desktop", "_launch"),
    (["Meta+Shift+K"], "hypr-keybinds.desktop", "_launch"),
    # apps
    (["Meta+Return"], "hypr-terminal.desktop", "_launch"),
    (["Meta+D"], "hypr-launcher.desktop", "_launch"),
    (["Meta+E"], "hypr-files.desktop", "_launch"),
    (["Meta+B"], "hypr-browser.desktop", "_launch"),
    (["Meta+S"], "hypr-search.desktop", "_launch"),
    (["Meta+Alt+E"], "hypr-emoji.desktop", "_launch"),
    (["Meta+Alt+C"], "hypr-calc.desktop", "_launch"),
    (["Meta+V", "Meta+Alt+V"], "plasmashell", "show-on-mouse-pos"),
    (["Alt+Space"], "org.kde.krunner.desktop", "_launch"),
    # windows
    (["Meta+Q"], "kwin", "Window Close"),
    (["Meta+Shift+Q", "Meta+Ctrl+Esc"], "kwin", "Kill Window"),
    (["Meta+F"], "kwin", "Window Maximize"),
    (["Meta+Shift+F"], "kwin", "Window Fullscreen"),
    (["Meta+Left"], "kwin", "Switch Window Left"),
    (["Meta+Right"], "kwin", "Switch Window Right"),
    (["Meta+Up"], "kwin", "Switch Window Up"),
    (["Meta+Down"], "kwin", "Switch Window Down"),
    (["Meta+J"], "kwin", "KrohnkiteFocusNext"),
    (["Meta+K"], "kwin", "KrohnkiteFocusPrev"),
    (["Alt+Tab"], "kwin", "Walk Through Windows"),
    (["Alt+Shift+Tab", "Alt+Shift+Backtab"], "kwin", "Walk Through Windows (Reverse)"),
    (["Meta+A"], "kwin", "Overview"),
    (["Meta+G"], "kwin", "Grid View"),
    (["Meta+Ctrl+F9"], "kwin", "Window to Previous Screen"),
    (["Meta+Ctrl+F10"], "kwin", "Window to Next Screen"),
    # tiling
    (["Meta+Alt+T"], "kwin", "Hyprlike Toggle Tiling"),
    (["Meta+Shift+T"], "kwin", "Hyprlike Toggle Tiling Alt"),
    (["Meta+Space"], "kwin", "KrohnkiteToggleFloat"),
    (["Meta+Alt+Space"], "kwin", "KrohnkiteFloatAll"),
    (["Meta+Ctrl+Left", "Meta+Alt+Left"], "kwin", "KrohnkiteShiftLeft"),
    (["Meta+Ctrl+Right", "Meta+Alt+Right"], "kwin", "KrohnkiteShiftRight"),
    (["Meta+Ctrl+Up", "Meta+Alt+Up"], "kwin", "KrohnkiteShiftUp"),
    (["Meta+Ctrl+Down", "Meta+Alt+Down"], "kwin", "KrohnkiteShiftDown"),
    (["Meta+Shift+Left"], "kwin", "KrohnkiteShrinkWidth"),
    (["Meta+Shift+Right"], "kwin", "KrohnkitegrowWidth"),
    (["Meta+Shift+Up"], "kwin", "KrohnkiteShrinkHeight"),
    (["Meta+Shift+Down"], "kwin", "KrohnkiteGrowHeight"),
    (["Meta+Ctrl+Return"], "kwin", "KrohnkiteSetMaster"),
    (["Meta+I"], "kwin", "KrohnkiteIncrease"),
    (["Meta+Ctrl+D"], "kwin", "KrohnkiteDecrease"),
    (["Meta+Shift+I"], "kwin", "KrohnkiteRotate"),
    (["Meta+R"], "kwin", "KrohnkiteRotatePart"),
    (["Meta+Alt+L", "Meta+\\"], "kwin", "KrohnkiteNextLayout"),
    (["Meta+|", "Meta+Shift+|"], "kwin", "KrohnkitePreviousLayout"),
    (["Meta+Alt+1"], "kwin", "KrohnkiteBTreeLayout"),
    (["Meta+Alt+2"], "kwin", "KrohnkiteTileLayout"),
    (["Meta+Alt+3"], "kwin", "KrohnkiteColumnsLayout"),
    (["Meta+Alt+4"], "kwin", "KrohnkiteMonocleLayout"),
    (["Meta+Alt+5"], "kwin", "KrohnkiteFloatingLayout"),
    (["Meta+T"], "kwin", "Edit Tiles"),
    # workspaces
    (["Meta+Tab", "Meta+."], "kwin", "Switch to Next Desktop"),
    (["Meta+Shift+Tab", "Meta+Shift+Backtab", "Meta+Backtab", "Meta+,"], "kwin", "Switch to Previous Desktop"),
    (["Meta+Shift+]", "Meta+}", "Meta+Shift+}"], "kwin", "Hyprlike Move Next"),
    (["Meta+Shift+[", "Meta+{", "Meta+Shift+{"], "kwin", "Hyprlike Move Prev"),
    (["Meta+Ctrl+]"], "kwin", "Hyprlike Move Next Silent"),
    (["Meta+Ctrl+["], "kwin", "Hyprlike Move Prev Silent"),
    # screenshots
    (["Meta+Shift+S", "Alt+Shift+S"], "org.kde.spectacle.desktop", "RectangularRegionScreenShot"),
    (["Meta+Print"], "org.kde.spectacle.desktop", "FullScreenScreenShot"),
    (["Alt+Print"], "org.kde.spectacle.desktop", "ActiveWindowScreenShot"),
    # system
    (["Meta+N"], "kwin", "Toggle Night Color"),
    (["Ctrl+Alt+L"], "ksmserver", "Lock Session"),
    (["Ctrl+Alt+P", "Ctrl+Alt+Del"], "ksmserver", "Log Out"),
]
for i in range(1, 11):
    n = str(i % 10)
    EXPECTED += [
        ([f"Meta+{n}"], "kwin", f"Switch to Desktop {i}"),
        ([f"Meta+Shift+{n}", f"Meta+{SHIFTED[n]}", f"Meta+Shift+{SHIFTED[n]}"], "kwin", f"Hyprlike Move To Desktop {i}"),
        ([f"Meta+Ctrl+{n}"], "kwin", f"Hyprlike Move To Desktop Silent {i}"),
    ]

LAUNCHERS = ["browser", "calc", "cheatsheet", "emoji", "files", "keybinds", "launcher", "search", "terminal"]


def main():
    ka = dbus.Interface(dbus.SessionBus().get_object("org.kde.kglobalaccel", "/kglobalaccel"), "org.kde.KGlobalAccel")
    failures = 0
    checked = 0

    print("Shortcuts")
    for keys, component, action in EXPECTED:
        for key in keys:
            checked += 1
            hits = ka.getGlobalShortcutsByKey(dbus.Int32(code(key)))
            got = [(str(h[2]), str(h[0])) for h in hits]  # (component, action)
            if (component, action) not in got:
                failures += 1
                actual = ", ".join(f"{c}/{a}" for c, a in got) or "nothing"
                print(f"  FAIL  {key:<22} expected {component}/{action}, got {actual}")

    print("Launchers")
    apps = os.path.expanduser("~/.local/share/applications")
    for name in LAUNCHERS:
        checked += 1
        path = os.path.join(apps, f"hypr-{name}.desktop")
        if not os.path.exists(path):
            failures += 1
            print(f"  FAIL  hypr-{name}.desktop is missing")
            continue
        exec_line = next(line[5:].strip() for line in open(path) if line.startswith("Exec="))
        program = shlex.split(exec_line)[0]
        if program == "sh":  # sh -c '...': check the real program instead
            program = {"launcher": "rofi", "browser": "gtk-launch"}[name]
        if not (shutil.which(program) or os.access(program, os.X_OK)):
            failures += 1
            print(f"  FAIL  hypr-{name}.desktop runs '{program}', which is not installed or not executable")

    print("Tiling toggle service")
    checked += 1
    if subprocess.run(["systemctl", "--user", "cat", "linux-env-toggle-tiling.service"],
                      capture_output=True).returncode != 0:
        failures += 1
        print("  FAIL  linux-env-toggle-tiling.service is not installed (run ./install.sh --kde)")

    print(f"\n{checked - failures}/{checked} checks passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
