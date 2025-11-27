#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# (C) Hak Cipta 2025
# =========================================

clear
red='\e[1;31m'
green='\e[0;32m'
orange='\033[0;33m'
cyan='\033[0;36m'
NC='\e[0m'

# Pastikan dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
    echo -e "${red}Script ini harus dijalankan sebagai root!${NC}"
    exit 1
fi

# Ambil list user SSH (UID >= 1000, exclude nobody)
mapfile -t CLIENT_LIST < <(awk -F: '$3>=1000 && $1!="nobody" {print $1}' /etc/passwd)
NUMBER_OF_CLIENTS=${#CLIENT_LIST[@]}

if [[ ${NUMBER_OF_CLIENTS} -eq 0 ]]; then
    echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${cyan}              🔑 PERPANJANG AKUN SSH 🔑               ${NC}"
    echo -e "${green}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "🚫 Tidak ada akun SSH yang terdeteksi!"
    echo ""
    exit 1
fi

echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${cyan}              🔑 PERPANJANG AKUN SSH 🔑               ${NC}"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"
echo -e "📌 Pilih akun SSH yang ingin diperpanjang masa aktifnya"
echo -e "❎ Tekan CTRL+C untuk kembali"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"

# Tampilkan daftar user + expired
i=1
for user in "${CLIENT_LIST[@]}"; do
    exp_info=$(chage -l "$user" 2>/dev/null | awk -F': ' '/Account expires/ {print $2}')
    [[ -z "$exp_info" ]] && exp_info="unknown"
    echo -e " $i) ${cyan}$user${NC}  (Expired: ${exp_info})"
    ((i++))
done

echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"

# Pilih user
CLIENT_NUMBER=0
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih salah satu akun [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

user="${CLIENT_LIST[$((CLIENT_NUMBER-1))]}"

read -p "📅 Perpanjang berapa hari dari hari ini?: " masaaktif

# Hitung tanggal expired baru (dari hari ini)
exp4=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Set expiry dengan chage
chage -E "$exp4" "$user"

clear
echo ""
echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
echo -e " ✅ Akun SSH Berhasil Diperpanjang"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"
echo -e " 👤 Nama Pengguna : ${cyan}$user${NC}"
echo -e " 📆 Berakhir Pada : ${cyan}$exp4${NC}"
echo -e "${green}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "🛠️  Script Mod By Rakha-VPN"
echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${orange}]${NC} untuk kembali ke menu...") "
menu
