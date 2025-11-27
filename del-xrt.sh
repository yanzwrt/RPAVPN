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

CONFIG_XTLS="/usr/local/etc/xray/xtrojan.json"

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$CONFIG_XTLS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m Delete XRAY TROJAN TCP XTLS Account \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "You have no existing clients!"
    echo ""
    read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} Back to menu . . .") "
    menu
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m Delete XRAY TROJAN TCP XTLS Account \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Select the existing client you want to remove"
echo " Press CTRL+C to cancel"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     No  Expired   User"
grep -E "^### " "$CONFIG_XTLS" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    if [[ ${CLIENT_NUMBER} == '1' ]]; then
        read -rp "Select one client [1]: " CLIENT_NUMBER
    else
        read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    fi
done

user=$(grep -E "^### " "$CONFIG_XTLS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "$CONFIG_XTLS" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

# Hapus blok user dari config XTLS
sed -i "/^### $user $exp/,/^},{/d" "$CONFIG_XTLS"

# Hapus file YAML (sesuai yang dibuat di add-xrt.sh)
rm -f /home/vps/public_html/$user-$exp-TRDIRECT.yaml
rm -f /home/vps/public_html/$user-$exp-TRSPLICE.yaml

# Restart service XTLS
systemctl restart xray@xtrojan.service

clear
echo ""
echo " XRAY TROJAN TCP XTLS Account Deleted"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Client Name : $user"
echo " Expired On  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "Script Mod By RakhaVPN"
echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} Back to menu . . .") "
menu
