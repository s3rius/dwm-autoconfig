while true; do
 xsetroot -name "$( date +"%F %R")"
 sleep 2s
done &
nitrogen --restore
exec dwm
