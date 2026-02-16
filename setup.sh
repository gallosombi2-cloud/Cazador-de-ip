#!/bin/bash
echo "Instalando dependencias de WiFi Expert Suite..."
sudo apt update
sudo apt install mdk4 zenity aircrack-ng gnuplot viewnior netdiscover libnotify-bin -y
chmod +x wifi_expert_suite.sh
echo "Configuración terminada. Ejecuta ./wifi_expert_suite.sh"
