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

L2TP_FILE="/etc/ppp/chap-secrets"

if [[ ! -f "$L2TP_FILE" ]]; then
    echo -e "${red}File $L2TP_FILE tidak ditemukan!${NC}"
    exit 1
fi

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$L2TP_FILE")

if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${cyan}           🌐 PERPANJANG AKUN L2TP/IPsec 🌐           ${NC}"
    echo -e "${green}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "🚫 Tidak ada client L2TP yang terdaftar!"
    echo ""
    exit 1
fi

echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${cyan}           🌐 PERPANJANG AKUN L2TP/IPsec 🌐           ${NC}"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"
echo -e "📌 Pilih client yang ingin diperpanjang masa aktifnya"
echo -e "❎ Tekan CTRL+C untuk kembali"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"

grep -E "^### " "$L2TP_FILE" | cut -d ' ' -f 2-3 | nl -s ') '

# Pilih client
CLIENT_NUMBER=0
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih salah satu client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

read -p "📅 Perpanjang berapa hari?: " masaaktif

user=$(grep -E "^### " "$L2TP_FILE" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "$L2TP_FILE" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s 2>/dev/null || echo 0)
d2=$(date -d "$now" +%s)
if [[ "$d1" -eq 0 ]]; then
    exp2=0
else
    exp2=$(( (d1 - d2) / 86400 ))
    [[ ${exp2} -lt 0 ]] && exp2=0
fi

exp3=$((exp2 + masaaktif))
exp4=$(date -d "$exp3 days" +"%Y-%m-%d")

# Update tanggal expired di komentar
sed -i "s/^### $user $exp$/### $user $exp4/" "$L2TP_FILE"

# Restart layanan L2TP/IPsec (opsional tapi aman)
systemctl restart strongswan 2>/dev/null
systemctl restart xl2tpd 2>/dev/null
service cron restart 2>/dev/null

clear
echo ""
echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
echo -e " ✅ Akun L2TP/IPsec Berhasil Diperpanjang"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"
echo -e " 👤 Nama Pengguna : ${cyan}$user${NC}"
echo -e " 📆 Berakhir Pada : ${cyan}$exp4${NC}"
echo -e "${green}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "🛠️  Script Mod By Rakha-VPN"
echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${orange}]${NC} untuk kembali ke menu...") "
menu
