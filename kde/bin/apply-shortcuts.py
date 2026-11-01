#!/usr/bin/env python3
"""Set Hyprland-style shortcuts live through kglobalaccel (so it persists them itself)."""
import dbus

MODS = {"Meta": 0x10000000, "Shift": 0x02000000, "Ctrl": 0x04000000, "Alt": 0x08000000}
KEYS = {
    "Return": 0x01000004, "Tab": 0x01000001, "Esc": 0x01000000, "Print": 0x01000009, "Del": 0x01000007,
    "Left": 0x01000012, "Up": 0x01000013, "Right": 0x01000014, "Down": 0x01000015,
    "Space": 0x20, ".": 0x2E, ",": 0x2C, "[": 0x5B, "]": 0x5D, "\\": 0x5C, "|": 0x7C, "Backtab": 0x01000002,
    "!": 0x21, "@": 0x40, "#": 0x23, "$": 0x24, "%": 0x25, "^": 0x5E, "&": 0x26, "*": 0x2A, "(": 0x28, ")": 0x29,
    "{": 0x7B, "}": 0x7D,
}
# On Wayland, Shift+<key> arrives as the shifted symbol, so bind both spellings
SHIFTED = dict(zip("1234567890[]", "!@#$%^&*(){}"))


def with_shifted(*keys):
    """Meta+Shift+1 -> Meta+Shift+1, Meta+!, Meta+Shift+!"""
    out = []
    for k in keys:
        out.append(k)
        *mods, key = k.split("+")
        if "Shift" in mods and key in SHIFTED:
            rest = [m for m in mods if m != "Shift"]
            out += ["+".join(rest + [SHIFTED[key]]), "+".join(mods + [SHIFTED[key]])]
    return out
KEYS.update({f"F{i}": 0x01000030 + i - 1 for i in range(1, 13)})


def code(seq):
    *mods, key = seq.split("+")
    k = KEYS.get(key) or ord(key.upper())
    for m in mods:
        k |= MODS[m]
    return k


bus = dbus.SessionBus()
ka = dbus.Interface(bus.get_object("org.kde.kglobalaccel", "/kglobalaccel"), "org.kde.KGlobalAccel")


def keys_arg(keys):
    return dbus.Array([dbus.Struct([dbus.Array([dbus.Int32(code(k))], signature="i")], signature=None)
                       for k in keys], signature="(ai)")


def setk(component, action, *keys):
    ka.setForeignShortcutKeys(dbus.Array([component, action, "", ""], signature="s"), keys_arg(keys))


# 1) clear KDE defaults that clash
for i in range(1, 10):
    setk("plasmashell", f"activate task manager entry {i}")
setk("plasmashell", "manage activities")
for a in ("Show Desktop", "view_actual_size", "Window Quick Tile Left", "Window Quick Tile Right",
          "Window Quick Tile Top", "Window Quick Tile Bottom", "Switch One Desktop Up", "Switch One Desktop Down",
          "Switch One Desktop to the Left", "Switch One Desktop to the Right", "Window One Desktop Up",
          "Window One Desktop Down", "Window One Desktop to the Left", "Window One Desktop to the Right",
          "Window to Next Screen", "Window to Previous Screen", "Switch Window Left", "Switch Window Right",
          "Switch Window Up", "Switch Window Down", "Overview", "Walk Through Windows",
          "Walk Through Windows (Reverse)", "Window Maximize"):
    setk("kwin", a)
for i in range(1, 11):
    setk("kwin", f"Switch to Desktop {i}")
setk("org_kde_powerdevil", "powerProfile")
setk("KDE Keyboard Layout Switcher", "Switch to Last-Used Keyboard Layout")
setk("org.kde.dolphin.desktop", "_launch")

# 2) Hyprland-style bindings
setk("kwin", "Window Close", "Meta+Q", "Alt+F4")
setk("kwin", "Kill Window", "Meta+Shift+Q", "Meta+Ctrl+Esc")
setk("kwin", "Window Maximize", "Meta+F")
setk("kwin", "Window Fullscreen", "Meta+Shift+F")
for d in ("Left", "Right", "Up", "Down"):
    setk("kwin", f"Switch Window {d}", f"Meta+{d}")
setk("kwin", "Window to Previous Screen", "Meta+Ctrl+F9")
setk("kwin", "Window to Next Screen", "Meta+Ctrl+F10")
setk("kwin", "Overview", "Meta+A")
setk("kwin", "Grid View", "Meta+G")
setk("kwin", "Toggle Night Color", "Meta+N")
setk("kwin", "Walk Through Windows", "Alt+Tab")
setk("kwin", "Walk Through Windows (Reverse)", "Alt+Shift+Tab")
for i in range(1, 11):
    setk("kwin", f"Switch to Desktop {i}", f"Meta+{i % 10}")
setk("kwin", "Switch to Next Desktop", "Meta+Tab", "Meta+.")
setk("kwin", "Switch to Previous Desktop", "Meta+Shift+Tab", "Meta+Shift+Backtab", "Meta+Backtab", "Meta+,")
for i in range(1, 11):
    n = str(i % 10)
    setk("kwin", f"Hyprlike Move To Desktop {i}", *with_shifted(f"Meta+Shift+{n}"))
    setk("kwin", f"Hyprlike Move To Desktop Silent {i}", f"Meta+Ctrl+{n}")
setk("kwin", "Hyprlike Move Next", *with_shifted("Meta+Shift+]"))
setk("kwin", "Hyprlike Move Prev", *with_shifted("Meta+Shift+["))
setk("kwin", "Hyprlike Move Next Silent", "Meta+Ctrl+]")
setk("kwin", "Hyprlike Move Prev Silent", "Meta+Ctrl+[")
setk("plasmashell", "show-on-mouse-pos", "Meta+V", "Meta+Alt+V")
setk("ksmserver", "Lock Session", "Ctrl+Alt+L")
setk("ksmserver", "Log Out", "Ctrl+Alt+P", "Ctrl+Alt+Del")

K = {
    "KrohnkiteFocusNext": ["Meta+J"], "KrohnkiteFocusPrev": ["Meta+K"],
    "KrohnkiteFocusDown": [], "KrohnkiteFocusUp": [], "KrohnkiteFocusLeft": [], "KrohnkiteFocusRight": [],
    "KrohnkiteShiftDown": ["Meta+Ctrl+Down", "Meta+Alt+Down"], "KrohnkiteShiftUp": ["Meta+Ctrl+Up", "Meta+Alt+Up"],
    "KrohnkiteShiftLeft": ["Meta+Ctrl+Left", "Meta+Alt+Left"],
    "KrohnkiteShiftRight": ["Meta+Ctrl+Right", "Meta+Alt+Right"],
    "KrohnkiteGrowHeight": ["Meta+Shift+Down"], "KrohnkiteShrinkHeight": ["Meta+Shift+Up"],
    "KrohnkiteShrinkWidth": ["Meta+Shift+Left"], "KrohnkitegrowWidth": ["Meta+Shift+Right"],
    "KrohnkiteIncrease": ["Meta+I"], "KrohnkiteDecrease": ["Meta+Ctrl+D"],
    "KrohnkiteToggleFloat": ["Meta+Space"], "KrohnkiteFloatAll": ["Meta+Alt+Space"],
    "KrohnkiteNextLayout": ["Meta+Alt+L", "Meta+\\"], "KrohnkitePreviousLayout": ["Meta+|", "Meta+Shift+|"],
    "KrohnkiteRotate": ["Meta+Shift+I"], "KrohnkiteRotatePart": ["Meta+R"],
    "KrohnkiteSetMaster": ["Meta+Ctrl+Return"],
    "KrohnkiteBTreeLayout": ["Meta+Alt+1"], "KrohnkiteTileLayout": ["Meta+Alt+2"],
    "KrohnkiteColumnsLayout": ["Meta+Alt+3"], "KrohnkiteMonocleLayout": ["Meta+Alt+4"],
    "KrohnkiteFloatingLayout": ["Meta+Alt+5"],
}
for a in K:  # clear first so swaps between Krohnkite actions don't collide
    setk("kwin", a)
for a, keys in K.items():
    setk("kwin", a, *keys)

for desktop, key in (("hypr-terminal", "Meta+Return"), ("hypr-launcher", "Meta+D"), ("hypr-files", "Meta+E"),
                     ("hypr-browser", "Meta+B"), ("hypr-search", "Meta+S"), ("hypr-emoji", "Meta+Alt+E"),
                     ("hypr-calc", "Meta+Alt+C"), ("hypr-cheatsheet", "Meta+H"),
                     ("hypr-keybinds", "Meta+Shift+K")):
    ka.doRegister(dbus.Array([f"{desktop}.desktop", "_launch", desktop, desktop], signature="s"))
    setk(f"{desktop}.desktop", "_launch", *(key if isinstance(key, tuple) else (key,)))
setk("org.kde.spectacle.desktop", "RectangularRegionScreenShot", "Meta+Shift+S", "Alt+Shift+S", "Meta+Shift+Print")
setk("org.kde.spectacle.desktop", "FullScreenScreenShot", "Meta+Print")
setk("org.kde.spectacle.desktop", "ActiveWindowScreenShot", "Alt+Print")
print("done")
setk("kwin", "Hyprlike Toggle Tiling", "Meta+Alt+T")
setk("kwin", "Hyprlike Toggle Tiling Alt", "Meta+Shift+T")
