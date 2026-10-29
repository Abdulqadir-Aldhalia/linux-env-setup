#!/usr/bin/env bash
# SUPER+H — Hyprland/JaKooLit-style cheat sheet popup for KDE
pkill -x yad && exit 0
pkill -x rofi
mapfile -t rows < <(tr '\t' '\n' < "$HOME/.config/kde-hypr/keybinds.tsv")
GDK_BACKEND=wayland yad \
  --center --width=820 --height=720 \
  --title="KDE Hypr Cheat Sheet" \
  --no-buttons --list \
  --column="Key" --column="Action" --column="Note" \
  --timeout-indicator=bottom \
  "${rows[@]}"
