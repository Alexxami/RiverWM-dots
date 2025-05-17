#!/bin/bash

DEST="$HOME/Imágenes/Capturas"
mkdir -p "$DEST"
FILE="$DEST/Captura-$(date +%F-%H%M%S).png"

grim -g "$(slurp)" - | tee "$FILE" | wl-copy

notify-send -a "Captura" -u low -i "$FILE" "Screenshooted" "See it in $FILE"
