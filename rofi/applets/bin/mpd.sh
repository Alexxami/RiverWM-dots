#!/usr/bin/env bash

## Adaptado por ChatGPT (basado en el script de Aditya Shakya)
## Usando playerctl (MPRIS) en lugar de mpc (MPD)

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$HOME/.config/rofi/applets/type-4/style-2.rasi"

# Obtener estado de playerctl
status="$(playerctl status 2>/dev/null)"
if [[ -z "$status" ]]; then
	prompt='Offline'
	mesg="Ningún reproductor detectado"
else
	artist="$(playerctl metadata artist 2>/dev/null)"
	title="$(playerctl metadata title 2>/dev/null)"
	playback_status="$status"
	prompt="$artist"
	mesg="$title :: $playback_status"
fi

# Configurar columnas según el tema
if [[ ( "$theme" == *'type-1'* ) || ( "$theme" == *'type-3'* ) || ( "$theme" == *'type-5'* ) ]]; then
	list_col='1'
	list_row='6'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='6'
	list_row='1'
fi

# Layout y opciones
layout=$(grep 'USE_ICON' ${theme} | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	if [[ ${status} == "Playing" ]]; then
		option_1=" Pause"
	else
		option_1=" Play"
	fi
	option_2=" Stop"
	option_3=" Previous"
	option_4=" Next"
	option_5=" Loop"
	option_6=" Shuffle"
else
	if [[ ${status} == "Playing" ]]; then
		option_1=""
	else
		option_1=""
	fi
	option_2=""
	option_3=""
	option_4=""
	option_5=""
	option_6=""
fi

# Estado Loop y Shuffle
loop_status="$(playerctl loop 2>/dev/null)"
shuffle_status="$(playerctl shuffle 2>/dev/null)"

active=''
urgent=''

# Loop
if [[ $loop_status == "Playlist" ]]; then
	active="-a 4"
elif [[ $loop_status == "None" ]]; then
	urgent="-u 4"
else
	option_5=" Parsing Error"
fi

# Shuffle
if [[ $shuffle_status == "On" ]]; then
	[ -n "$active" ] && active+=",5" || active="-a 5"
elif [[ $shuffle_status == "Off" ]]; then
	[ -n "$urgent" ] && urgent+=",5" || urgent="-u 5"
else
	option_6=" Parsing Error"
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		${active} ${urgent} \
		-markup-rows \
		-theme ${theme} \
		-selected-row 1
}

# Mostrar opciones en rofi
run_rofi() {
	echo -e "$option_3\n$option_1\n$option_4" | rofi_cmd
}

# Ejecutar acciones
run_cmd() {
	case "$1" in
		'--opt1')
			playerctl play-pause && notify-send -u low -t 1000 " $(playerctl metadata title)"
			;;
		'--opt2')
			playerctl stop && notify-send -u low -t 1000 " $(playerctl metadata title)"
			;;
		'--opt3')
			playerctl previous && notify-send -u low -t 1000 " $(playerctl metadata title)"
			;;
		'--opt4')
			playerctl next 
			;;
		'--opt5')
			current_loop="$(playerctl loop)"
			if [[ "$current_loop" == "Playlist" ]]; then
				playerctl loop None
			else
				playerctl loop Playlist
			fi
			;;
		'--opt6')
			current_shuffle="$(playerctl shuffle)"
			if [[ "$current_shuffle" == "On" ]]; then
				playerctl shuffle Off
			else
				playerctl shuffle On
			fi
			;;
	esac
}

# Acciones
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac
