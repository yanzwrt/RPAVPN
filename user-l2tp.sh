#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : RakhaVPN
# =========================================

red='\e[1;31m'
green='\e[0;32m'
orange='\033[0;33m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red()   { echo -e "\\033[31;1m${*}\\033[0m"; }

clear
MYIP=$(curl -sS ipv4.icanhazip.com)
domain=$(cat /root/domain 2>/dev/null || echo "$MYIP")

CHAP="/etc/ppp/chap-secrets"
IPSEC_SECRETS="/etc/ipsec.secrets"

if [[ ! -f "$CHAP" ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m       CEK KONFIG L2TP/IPSEC      \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "File $CHAP tidak ditemukan."
    echo ""
    exit 1
fi

# Ambil daftar user L2TP (kolom 1, service l2tp-server)
mapfile -t USERS < <(awk '$1!="" && $2=="l2tp-server" {print $1}' "$CHAP")

NUMBER_OF_CLIENTS=${#USERS[@]}
if [[ ${NUMBER_OF_CLIENTS} -eq 0 ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m       CEK KONFIG L2TP/IPSEC      \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user L2TP yang terdaftar!"
    echo ""
    exit 1
fi

# Ambil PSK & Server ID
SERVER_ID=$(grep -m1 -v '^#' "$IPSEC_SECRETS" 2>/dev/null | awk '{print $1}')
PSK=$(grep -m1 -v '^#' "$IPSEC_SECRETS" 2>/dev/null | awk '{print $5}' | tr -d '"')

[[ -z "$SERVER_ID" ]] && SERVER_ID="$domain"
[[ -z "$PSK" ]] && PSK="(tidak terdeteksi, cek $IPSEC_SECRETS)"

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m       CEK KONFIG L2TP/IPSEC      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Pilih user yang ingin dilihat konfigurasinya:"
echo " Tekan CTRL+C untuk kembali ke menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

for i in "${!USERS[@]}"; do
    idx=$((i+1))
    echo " ${idx}) ${USERS[$i]}"
done

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

user="${USERS[$((CLIENT_NUMBER-1))]}"

# Ambil password dari chap-secrets
pass=$(awk -v u="$user" '$1==u && $2=="l2tp-server" {gsub("\"","",$3); print $3}' "$CHAP")

clear
echo -e ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "                ${green}AKUN L2TP/IPsec${NC}                     "
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Host / Server ID   : ${SERVER_ID}"
echo -e "➤ IP VPS             : ${MYIP}"
echo -e "➤ Domain             : ${domain}"
echo -e "➤ Pre-Shared Key     : ${PSK}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Username L2TP      : ${user}"
echo -e "➤ Password L2TP      : ${pass}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Port L2TP          : 1701/UDP"
echo -e "➤ Port IPsec IKE     : 500/UDP"
echo -e "➤ Port IPsec NAT-T   : 4500/UDP"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "          ${green}Autoscript by RakhaVPN${NC}"
echo -e ""
read -p "$( echo -e "Tekan ${green}[Enter]${NC} untuk kembali ke menu...") "
menu
