#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : RakhaVPN
# =========================================

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

clear
MYIP=$(curl -sS ipv4.icanhazip.com)

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m     CEK KONFIG VMESS WS          \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user yang terdaftar!"
    echo ""
    exit 1
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m     CEK KONFIG VMESS WS          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Pilih user yang ingin dilihat konfigurasinya:"
echo " Tekan CTRL+C untuk kembali ke menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     tidak ada pengguna kadaluwarsa"
grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

user=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
tls=$(grep -w "VMESS WS TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
none=$(grep -w "VMESS WS None TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
domain=$(cat /root/domain)
uuid=$(grep "},{" /usr/local/etc/xray/config.json | cut -b 11-46 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
hariini=$(date +"%Y-%m-%d")

vmesslink1="vmess://$(base64 -w 0 /usr/local/etc/xray/${user}-tls.json)"
vmesslink2="vmess://$(base64 -w 0 /usr/local/etc/xray/${user}-none.json)"

clear
echo -e ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "              ${green}XRAY VMESS - WEBSOCKET (WS)${NC}              "
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Username           : ${user}"
echo -e "➤ Domain             : ${domain}"
echo -e "➤ IP/Host            : ${MYIP}"
echo -e "➤ Port TLS           : 443"
echo -e "➤ Port Non-TLS       : 80, 8080, 8880"
echo -e "➤ UUID / ID          : ${user}"
echo -e "➤ AlterId            : 0"
echo -e "➤ Security           : Otomatis"
echo -e "➤ Protokol           : WebSocket (WS)"
echo -e "➤ Path TLS           : /vmess"
echo -e "➤ Path Non-TLS       : /vmess"
echo -e "➤ Multipath          : /yourpath"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link WS TLS        :"
echo -e "${green}${vmesslink1}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link WS Non-TLS    :"
echo -e "${green}${vmesslink2}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ YAML WS TLS        : http://${MYIP}:81/${user}-VMESSTLS.yaml"
echo -e "➤ YAML WS Non-TLS    : http://${MYIP}:81/${user}-VMESSNTLS.yaml"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Dibuat             : ${hariini}"
echo -e "➤ Berakhir Pada      : ${exp}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "          ${green}Autoscript by RakhaVPN${NC}"
echo -e ""
read -p "$( echo -e "Tekan ${green}[Enter]${NC} untuk kembali ke menu...") "
menu
