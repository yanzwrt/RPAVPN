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

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/xtrojan.json")

if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${cyan}           🔐 PERPANJANG TROJAN TCP XTLS 🔐           ${NC}"
    echo -e "${green}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "🚫 Tidak ada client yang terdaftar!"
    echo ""
    exit 1
fi

echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${cyan}           🔐 PERPANJANG TROJAN TCP XTLS 🔐           ${NC}"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"
echo -e "📌 Pilih client yang ingin diperpanjang masa aktifnya"
echo -e "❎ Tekan CTRL+C untuk kembali"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"

# Tampilkan daftar client
grep -E "^### " "/usr/local/etc/xray/xtrojan.json" | cut -d ' ' -f 2-3 | nl -s ') '

# Input pilihan (inisialisasi dulu)
CLIENT_NUMBER=0
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
	if [[ ${CLIENT_NUMBER} == '1' ]]; then
		read -rp "Pilih salah satu client [1]: " CLIENT_NUMBER
	else
		read -rp "Pilih salah satu client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
	fi
done

read -p "📅 Perpanjang berapa hari?: " masaaktif

user=$(grep -E "^### " "/usr/local/etc/xray/xtrojan.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/xtrojan.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))

# Kalau sudah kadaluarsa, hitung dari hari ini
if [[ ${exp2} -lt 0 ]]; then
    exp2=0
fi

exp3=$((exp2 + masaaktif))
exp4=$(date -d "$exp3 days" +"%Y-%m-%d")

# Update data
sed -i "s/### $user $exp/### $user $exp4/g" /usr/local/etc/xray/xtrojan.json

# Restart layanan
systemctl restart xray@xtrojan.service
service cron restart

clear
echo ""
echo -e "${green}╔════════════════════════════════════════════════════╗${NC}"
echo -e " ✅ Akun XRAY TROJAN TCP XTLS Berhasil Diperpanjang"
echo -e "${green}╠════════════════════════════════════════════════════╣${NC}"
echo -e " 👤 Nama Pengguna : ${cyan}$user${NC}"
echo -e " 📆 Berakhir Pada : ${cyan}$exp4${NC}"
echo -e "${green}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "🛠️  Script Mod By Rakha-VPN"
echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${orange}]${NC} untuk kembali ke menu...") "
menu
