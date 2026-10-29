#!/usr/bin/env bash
# SUPER+S — type a query, open it in the default browser
pkill -x rofi && exit 0
query=$(rofi -dmenu -p "Search" -l 0 </dev/null) || exit 0
[ -n "$query" ] && xdg-open "https://www.google.com/search?q=$(printf '%s' "$query" | jq -sRr @uri)"
