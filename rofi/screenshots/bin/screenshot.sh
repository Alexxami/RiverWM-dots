#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Quick Links

# Import Current Theme
source "$HOME"/.config/rofi/quicklinks/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Screenshots'

if [[ "$theme" == *'type-1'* ]]; then
	list_col='1'; list_row='5'; win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
	list_col='1'; list_row='5'; win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'; list_row='5'; win_width='520px'
elif [[ "$theme" == *'type-2'* || "$theme" == *'type-4'* ]]; then
	list_col='5'; list_row='1'; win_width='670px'
fi

# Options
layout=$(grep 'USE_ICON' ${theme} | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	option_1=" Capturar Escritorio"
	option_2=" Capturar Área"
	option_3=" Capturar Ventana"
	option_4=" Capturar en 5s"
	option_5=" Capturar en 10s"
else
	option_1=""
	option_2=""
	option_3=""
	option_4="5s"
	option_5="10s"
fi

# Comando rofi
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Nombre de archivo
time=$(date +%Y-%m-%d-%H-%M-%S)
file="Screenshot_${time}.png"
path="${dir}/${file}"

# Make dir
mkdir -p "$dir"

# Notification
notify_view() {
	dunstify -u low --replace=699 "Captura copiada al portapapeles."
	if [[ -e "$path" ]]; then
		dunstify -u low --replace=699 "Captura guardada: $file"
	else
		dunstify -u low --replace=699 "Error al guardar captura."
	fi
}

# Copy
copy_clipboard() {
	wl-copy < "$path"
}

# Capture
shotnow() {
	grim "$path" && copy_clipboard && notify_view
}

# Delayed
shotdelayed() {
	delay=$1
	for ((i=delay; i>0; i--)); do
		dunstify -t 1000 --replace=699 "Captura en: $i..."
		sleep 1
	done
	grim "$path" && copy_clipboard && notify_view
}

# Capture window
shotwindow() {
	slurp_output=$(slurp)
	[ -n "$slurp_output" ] && grim -g "$slurp_output" "$path" && copy_clipboard && notify_view
}

# Capture region
shotarea() {
	slurp_output=$(slurp)
	[ -n "$slurp_output" ] && grim -g "$slurp_output" "$path" && copy_clipboard && notify_view
}

# Exec
run_cmd() {
	case "$1" in
		'--opt1') shotnow ;;
		'--opt2') shotarea ;;
		'--opt3') shotwindow ;;
		'--opt4') shotdelayed 5 ;;
		'--opt5') shotdelayed 10 ;;
	esac
}

# Rofi
chosen="$(run_rofi)"
case "$chosen" in
	"$option_1") run_cmd --opt1 ;;
	"$option_2") run_cmd --opt2 ;;
	"$option_3") run_cmd --opt3 ;;
	"$option_4") run_cmd --opt4 ;;
	"$option_5") run_cmd --opt5 ;;
esac
