#!/usr/bin/env bash
# SUPER+SHIFT+K — searchable keybind list
pkill -x rofi && exit 0
awk -F'\t' '/^──/ { next } { printf "%-28s %s%s\n", $1, $2, ($3 != "" ? "  (" $3 ")" : "") }' \
  "$HOME/.config/kde-hypr/keybinds.tsv" | rofi -dmenu -i -p "Keybinds" >/dev/null
