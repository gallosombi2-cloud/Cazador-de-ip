#!/bin/bash
echo "[+] Instalando Interfaz Gráfica y Dependencias..."
sudo apt update
sudo apt install mdk4 zenity aircrack-ng xterm gnome-terminal libnotify-bin -y
chmod +x wifi_expert_suite.sh
echo "[+] Todo listo. Inicia la herramienta con: sudo ./wifi_expert_suite.sh"
