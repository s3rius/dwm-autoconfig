#!/bin/bash

[ -f ~/.xprofile ] && . ~/.xprofile

while true; do
 xsetroot -name "$( date +"%F %R")"
 sleep 2s
done &

while true; do
    dwm >/dev/null 2>&1
done
