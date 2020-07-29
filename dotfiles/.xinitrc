while true; do
 xsetroot -name "$( date +"%F %R")"
 sleep 2s
done &

nitrogen --restore
picom --config ~/.picom.conf -b

exec dwm
