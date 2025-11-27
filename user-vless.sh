#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : RakhaVPN
# (C) Copyright 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

clear
MYIP=$(curl -sS ifconfig.me)
MYIP2=$(curl -sS ipv4.icanhazip.com)
domain=$(cat /root/domain)

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/vless.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m     CEK KONFIG VLESS WS          \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user yang terdaftar!"
    echo ""
    exit 1
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m     CEK KONFIG VLESS WS          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Pilih user yang ingin dilihat konfigurasinya:"
echo " Tekan CTRL+C untuk kembali ke menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     Daftar akun tersedia:"
grep -E "^### " "/usr/local/etc/xray/vless.json" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

clear
echo ""
read -p "Masukkan Bug Address (Contoh: www.google.com) : " address
read -p "Masukkan Bug SNI/Host (Contoh : m.facebook.com) : " hst

# BUG ADDRESS
bug_addr="${address}."
bug_addr2="${address}"
if [[ -z "$address" ]]; then
    sts="$bug_addr2"
else
    sts="$bug_addr"
fi

# SNI / HOST
bug="${hst}"
bug2="${domain}"
if [[ -z "$hst" ]]; then
    sni="$bug2"
else
    sni="$bug"
fi

user=$(grep -E "^### " "/usr/local/etc/xray/vless.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/vless.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
hariini=$(date +"%Y-%m-%d")

# Di add-vless, uuid=$user, jadi pakai user sebagai ID
vlesslink1="vless://${user}@${sts}${domain}:443?type=ws&encryption=none&security=tls&host=${domain}&path=/vless&allowInsecure=1&sni=${sni}#XRAY_VLESS_TLS_${user}"
vlesslink2="vless://${user}@${sts}${domain}:80?type=ws&encryption=none&security=none&host=${domain}&path=/vless#XRAY_VLESS_NTLS_${user}"

clear
echo -e ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "              ${green}XRAY VLESS - WEBSOCKET (WS)${NC}              "
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Username           : ${user}"
echo -e "➤ Domain             : ${domain}"
#echo -e "➤ IP/Host            : ${MYIP}"
echo -e "➤ Wildcard           : bug.com.${domain}"
echo -e "➤ Port TLS           : 443"
echo -e "➤ Port Non-TLS       : 80, 8080, 8880"
echo -e "➤ UUID / ID          : ${user}"
echo -e "➤ Security           : TLS / None"
echo -e "➤ Enkripsi           : None"
echo -e "➤ Protokol           : WebSocket (WS)"
echo -e "➤ Path TLS/non-TLS   : /vless"
echo -e "➤ Multipath          : /yourpath"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Dibuat             : ${hariini}"
echo -e "➤ Expired            : ${exp}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link WS TLS        :"
echo -e "${green}${vlesslink1}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link WS Non-TLS    :"
echo -e "${green}${vlesslink2}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ YAML WS TLS        : http://${MYIP2}:81/${user}-${exp}-VLESSTLS.yaml"
echo -e "➤ YAML WS Non-TLS    : http://${MYIP2}:81/${user}-${exp}-VLESSNTLS.yaml"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "          ${green}Autoscript by RakhaVPN${NC}"
echo -e ""
read -p "$( echo -e "Tekan ${green}[Enter]${NC} untuk kembali ke menu...") " _
menu
