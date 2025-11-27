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

CONFIG_WS="/usr/local/etc/xray/trojanws.json"
CONFIG_NTLS="/usr/local/etc/xray/trnone.json"

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$CONFIG_WS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m   Hapus Akun XRAY Trojan WS   \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Anda tidak memiliki pengguna!"
    echo ""
    read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
    menu
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m   Hapus Akun XRAY Trojan WS   \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Silakan pilih pengguna untuk dihapus"
echo " Tekan CTRL+C untuk membatalkan"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     Daftar pengguna yang tersedia:"
grep -E "^### " "$CONFIG_WS" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    if [[ ${CLIENT_NUMBER} == '1' ]]; then
        read -rp "Pilih satu pengguna [1]: " CLIENT_NUMBER
    else
        read -rp "Pilih satu pengguna [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    fi
done

user=$(grep -E "^### " "$CONFIG_WS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "$CONFIG_WS" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

# Hapus blok user dari config
sed -i "/^### $user $exp/,/^},{/d" "$CONFIG_WS"
sed -i "/^### $user $exp/,/^},{/d" "$CONFIG_NTLS"

# Hapus YAML (sesuai nama yang dibuat di add-tr.sh: $user-$exp-TRTLS.yaml)
rm -f /home/vps/public_html/$user-$exp-TRTLS.yaml

# Restart service
systemctl restart xray@trojanws.service
systemctl restart xray@trnone.service

clear
echo " XRAY Trojan WS Dihapus"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Nama Pengguna  : $user"
echo " Berakhir Pada  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "Script Mod By RakhaVPN"
echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
menu
