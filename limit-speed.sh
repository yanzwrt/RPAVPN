#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Author  : RakhaVPN (mod RPAVPN)
# (C) Copyright 2025
# =========================================
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"

LIMIT_FILE="/home/limit"

# baca status limit (kalau file belum ada, anggap kosong)
if [[ -f "$LIMIT_FILE" ]]; then
  cek=$(cat "$LIMIT_FILE" 2>/dev/null)
else
  cek=""
fi

# deteksi interface utama
NIC=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)

# kalau NIC kosong, lebih baik keluar daripada bikin error
if [[ -z "$NIC" ]]; then
  echo -e "${red}Gagal mendeteksi interface jaringan utama.${NC}"
  echo "Pastikan VPS punya koneksi internet."
  sleep 2
  menu
fi

# cek wondershaper
if ! command -v wondershaper >/dev/null 2>&1; then
  echo -e "${red}wondershaper belum terinstall.${NC}"
  echo "Install dulu dengan: apt-get install wondershaper -y"
  sleep 2
  menu
fi

start() {
  clear
  echo -e "Batasi Kecepatan Semua Layanan"
  read -p "Tetapkan kecepatan pengunduhan maksimum (Kbps): " down
  read -p "Tetapkan kecepatan pengunggahan maksimum (Kbps): " up

  if [[ -z "$down" && -z "$up" ]]; then
    echo "Tidak ada perubahan, limit tidak diaktifkan."
    sleep 1
    menu
  fi

  echo "Mulai konfigurasi limit..."
  sleep 0.5
  wondershaper -a "$NIC" -d "$down" -u "$up" >/dev/null 2>&1
  systemctl enable --now wondershaper.service >/dev/null 2>&1 || true
  echo "start" > "$LIMIT_FILE"
  echo "Selesai."
  sleep 1
  clear
  menu
}

stop() {
  clear
  echo "Menghentikan limit bandwith..."
  wondershaper -c -a "$NIC" >/dev/null 2>&1 || true
  systemctl stop wondershaper.service >/dev/null 2>&1 || true
  : > "$LIMIT_FILE"
  echo "Selesai."
  sleep 1
  clear
  menu
}

if [[ "$cek" == "start" ]]; then
  sts="${Info}"
else
  sts="${Error}"
fi

clear
echo -e "\e[36m╒════════════════════════════════════════════╕\033[0m"
echo -e " \E[0;47;30m      BATASI KECEPATAN BANDWITH         \E[0m"
echo -e "\e[36m╘════════════════════════════════════════════╛\033[0m"
echo -e "\033[1;37mLimit Bandwith Speed By RakhaVPN\033[0m"
echo ""
echo -e "   Status : $sts"
echo -e "
 [\033[1;36m•1 \033[0m]  Mulai Batas
 [\033[1;36m•2 \033[0m]  Berhenti Batas
 [\033[1;36m•3 \033[0m]  Kembali ke menu"
echo ""
echo -e " \033[1;37mTekan [ Ctrl+C ] • Untuk Keluar Script\033[0m"
echo ""
read -rp "Pilih menu : " -e num

case "$num" in
  1) start ;;
  2) stop ;;
  3) menu ;;
  *) 
     clear
     echo " Silahkan masukkan nomor yang benar!"
     sleep 1
     menu
     ;;
esac
