#!/usr/bin/env bash
# SUPER+ALT+C — quick calculator (qalc); Enter on a result copies it
pkill -x rofi && exit 0
result=""
while :; do
    expr=$(printf '%s' "$result" | rofi -dmenu -p "Calc" -mesg "${result:+= $result}") || break
    [ -z "$expr" ] && break
    if [ "$expr" = "$result" ]; then
        printf '%s' "$result" | wl-copy
        break
    fi
    result=$(qalc -t -- "$expr" 2>/dev/null)
done
