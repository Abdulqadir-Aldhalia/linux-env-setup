#!/usr/bin/env bash
# KWin / Plasma settings for the Hyprland-style setup. Safe to re-run.
set -euo pipefail

kw() { # kw <file> <group> <key> <value>
    kwriteconfig6 --file "$1" --group "$2" --key "$3" "$4"
}

# ── workspaces: 10 in a row, wrap around, smooth slide ─────
kw kwinrc Desktops Rows 1
kw kwinrc Windows RollOverDesktops true
kw kwinrc Plugins slideEnabled true
kw kwinrc Effect-slide SlideBackground false
kw kwinrc Effect-slide HorizontalGap 0
kw kdeglobals KDE AnimationDurationFactor 0.7

# ── SUPER + drag moves / resizes windows ───────────────────
kw kwinrc MouseBindings CommandAllKey Meta
kw kwinrc MouseBindings CommandAll1 Move
kw kwinrc MouseBindings CommandAll3 Resize

# ── KWin scripts: tiling, workspace helpers, focus border ──
kw kwinrc Plugins krohnkiteEnabled true
kw kwinrc Plugins hyprlikeEnabled true
kw kwinrc Plugins focusframeEnabled true

# ── Krohnkite tiling ───────────────────────────────────────
for k in screenGapLeft screenGapRight screenGapTop screenGapBottom screenGapBetween; do
    kw kwinrc Script-krohnkite "$k" 8
done
kw kwinrc Script-krohnkite noTileBorder true
kw kwinrc Script-krohnkite layoutPerDesktop true
kw kwinrc Script-krohnkite floatingClass "yad,org.kde.kcalc,pavucontrol,org.pulseaudio.pavucontrol,nm-connection-editor,blueman-manager,org.kde.plasma.emojier"

# ── dim unfocused windows ──────────────────────────────────
kw kwinrc Plugins diminactiveEnabled true
kw kwinrc Effect-diminactive Strength 30
for k in DimPanels DimDesktop DimKeepAbove DimByGroup DimFullScreen; do
    kw kwinrc Effect-diminactive "$k" false
done

# ── window rules (merged with any existing rules) ──────────
add_rule() { # add_rule <id> <key=value>...
    local id=$1; shift
    for kv in "$@"; do kw kwinrulesrc "$id" "${kv%%=*}" "${kv#*=}"; done
    local rules
    rules=$(kreadconfig6 --file kwinrulesrc --group General --key rules)
    if [[ ",$rules," != *",$id,"* ]]; then
        rules=${rules:+$rules,}$id
        kw kwinrulesrc General rules "$rules"
        kw kwinrulesrc General count "$(tr ',' '\n' <<<"$rules" | grep -c .)"
    fi
}
add_rule pip \
    "Description=Picture-in-picture: always on top, on all desktops" \
    'title=(?i)^picture[ -]in[ -]picture$' titlematch=3 \
    above=true aboverule=2 desktops= desktopsrule=2
add_rule no-initial-maximize \
    "Description=Tiling: never open windows maximized (Krohnkite skips maximized windows)" \
    types=1 maximizehoriz=false maximizehorizrule=3 maximizevert=false maximizevertrule=3

# ── kitty as the KDE terminal ──────────────────────────────
kw kdeglobals General TerminalApplication kitty
kw kdeglobals General TerminalService kitty.desktop

# ── apply live when Plasma is running ──────────────────────
if qdbus-qt6 org.kde.KWin /KWin >/dev/null 2>&1; then
    vdm=(qdbus-qt6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager)
    count=$("${vdm[@]}.count")
    while ((count < 10)); do
        "${vdm[@]}.createDesktop" "$count" "$((count + 1))" >/dev/null
        count=$((count + 1))
    done
    qdbus-qt6 org.kde.KWin /KWin reconfigure
else
    kw kwinrc Desktops Number 10
    echo "Plasma is not running: settings saved, they apply at next login."
fi
