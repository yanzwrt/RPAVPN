#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Author  : RakhaVPN (mod RPAVPN)
# (C) Copyright 2025
# =========================================

clear
red='\e[1;31m'
green='\e[0;32m'
orange='\e[1;33m'
CYAN='\e[0;36m'
NC='\e[0m'

CONFIG_TLS="/usr/local/etc/xray/vless.json"
CONFIG_NTLS="/usr/local/etc/xray/vnone.json"

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$CONFIG_TLS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m   Hapus Akun XRAY VLESS WS   \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Anda tidak memiliki pengguna!"
    echo ""
    read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
    menu
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m   Hapus Akun XRAY VLESS WS   \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

echo " Silakan pilih pengguna untuk dihapus"
echo " Tekan CTRL+C untuk membatalkan"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     Daftar pengguna yang tersedia:"
grep -E "^### " "$CONFIG_TLS" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    if [[ ${CLIENT_NUMBER} == '1' ]]; then
        read -rp "Pilih satu pengguna [1]: " CLIENT_NUMBER
    else
        read -rp "Pilih satu pengguna [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    fi
done

user=$(grep -E "^### " "$CONFIG_TLS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "$CONFIG_TLS" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

# Hapus blok user dari config
sed -i "/^### $user $exp/,/^},{/d" "$CONFIG_TLS"
sed -i "/^### $user $exp/,/^},{/d" "$CONFIG_NTLS"

# Hapus YAML (sesuai yang dibuat di add-vless.sh)
rm -f /home/vps/public_html/$user-$exp-VLESSTLS.yaml
rm -f /home/vps/public_html/$user-$exp-VLESSNTLS.yaml

# Restart service
systemctl restart xray@vless.service
systemctl restart xray@vnone.service

clear
echo " Akun XRAY VLESS WS Berhasil dihapus"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Nama Pengguna  : $user"
echo " Berakhir Pada  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "Script Mod By RakhaVPN"
echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
menu
