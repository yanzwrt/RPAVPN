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
MYIP=$(curl -s ipv4.icanhazip.com)

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/trojanws.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m     CEK KONFIG TROJAN WS         \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user yang terdaftar!"
    echo ""
    exit 1
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m     CEK KONFIG TROJAN WS         \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Pilih user yang ingin dilihat konfigurasinya:"
echo " Tekan CTRL+C untuk kembali ke menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     Tidak Ada Nama Pengguna yang Kedaluwarsa"
grep -E "^### " "/usr/local/etc/xray/trojanws.json" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

clear
echo ""
read -p "Masukkan Bug Address (Contoh: www.google.com) : " address
read -p "Masukkan Bug SNI/Host (Contoh : m.facebook.com) : " hst

bug_addr=${address}.
bug_addr2=${address}
sts=$([ -z "$address" ] && echo "$bug_addr2" || echo "$bug_addr")

bug=${hst}
bug2=${domain}
sni=$([ -z "$hst" ] && echo "$bug2" || echo "$bug")

user=$(grep -E "^### " "/usr/local/etc/xray/trojanws.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
domain=$(cat /root/domain)
uuid=$(grep "},{" /usr/local/etc/xray/trojanws.json | cut -b 17-52 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/trojanws.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
hariini=$(date +"%Y-%m-%d")

trojanlink1="trojan://${user}@${sts}${domain}:443?type=ws&security=tls&host=${domain}&path=/trojan&sni=${sni}#XRAY_TROJAN_TLS_${user}"
trojanlink2="trojan://${user}@${sts}${domain}:80?type=ws&security=none&host=${domain}&path=/trojan#XRAY_TROJAN_NTLS_${user}"

clear
echo -e ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "             ${green}XRAY TROJAN - WEBSOCKET (WS)${NC}             "
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Username           : ${user}"
echo -e "➤ Domain             : ${domain}"
#echo -e "➤ IP/Host            : ${MYIP}"
echo -e "➤ Wildcard           : bug.com.${domain}"
echo -e "➤ Port TLS           : 443"
echo -e "➤ Port Non-TLS       : 80, 8080, 8880"
echo -e "➤ UUID / Password    : ${user}"
echo -e "➤ Security           : TLS / None"
echo -e "➤ Enkripsi           : None"
echo -e "➤ Protokol           : WebSocket (WS)"
echo -e "➤ Path TLS/Non-TLS   : /trojan"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Dibuat             : ${hariini}"
echo -e "➤ Berlaku Sampai     : ${exp}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link WS TLS        :"
echo -e "${green}${trojanlink1}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link WS Non-TLS    :"
echo -e "${green}${trojanlink2}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ YAML WS TLS        : http://${MYIP}:81/${user}-TRTLS.yaml"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "          ${green}Autoscript by RakhaVPN${NC}"
echo -e ""
read -p "$( echo -e "Tekan ${green}[Enter]${NC} untuk kembali ke menu...") "
menu
