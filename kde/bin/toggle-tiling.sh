#!/usr/bin/env bash
# SUPER+ALT+T — switch between Krohnkite tiling and the normal KDE floating experience
reconfigure() { qdbus-qt6 org.kde.KWin /KWin reconfigure; }

if [ "$(kreadconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled)" = "true" ]; then
    kwriteconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled false
    reconfigure
    id=$(qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$HOME/.config/kde-hypr/restore-borders.js" restoreborders)
    qdbus-qt6 org.kde.KWin "/Scripting/Script$id" org.kde.kwin.Script.run
    qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript restoreborders >/dev/null
    notify-send -a "Tiling" -i window -t 1500 "Tiling off" "Normal KDE floating windows"
else
    kwriteconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled true
    reconfigure
    notify-send -a "Tiling" -i view-grid -t 1500 "Tiling on" "Krohnkite is managing windows"
fi
