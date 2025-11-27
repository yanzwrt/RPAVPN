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
red()   { echo -e "\\033[31;1m${*}\\033[0m"; }

clear
MYIP=$(curl -sS ipv4.icanhazip.com)
domain=$(cat /root/domain)

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/xtrojan.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m   CEK KONFIG TROJAN TCP XTLS     \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user yang terdaftar!"
    echo ""
    exit 1
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m   CEK KONFIG TROJAN TCP XTLS     \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Pilih user yang ingin dilihat konfigurasinya:"
echo " Tekan CTRL+C untuk kembali ke menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     Tidak ada pengguna kadaluwarsa"
grep -E "^### " "/usr/local/etc/xray/xtrojan.json" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

clear
echo ""
read -p "Masukkan Bug Address (Contoh: www.google.com)      : " address
read -p "Masukkan Bug SNI/Host (Contoh : m.facebook.com)    : " hst

bug_addr=${address}.
bug_addr2=${address}
if [[ -z "$address" ]]; then
  sts="$bug_addr2"
else
  sts="$bug_addr"
fi

bug=${hst}
bug2=${domain}
if [[ -z "$hst" ]]; then
  sni="$bug2"
else
  sni="$bug"
fi

user=$(grep -E "^### " "/usr/local/etc/xray/xtrojan.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/xtrojan.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
hariini=$(date +"%Y-%m-%d")

trojanlink1="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-direct&sni=${sni}#TROJAN_DIRECT_${user}"
trojanlink2="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-direct-udp443&sni=${sni}#TROJAN_DIRECTUDP443_${user}"
trojanlink3="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-splice&sni=${sni}#TROJAN_SPLICE_${user}"
trojanlink4="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-splice-udp443&sni=${sni}#TROJAN_SPLICEUDP443_${user}"

clear
echo -e ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "            ${green}XRAY TROJAN TCP XTLS (Direct/Splice)${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Username           : ${user}"
echo -e "➤ Domain             : ${domain}"
#echo -e "➤ IP/Host            : ${MYIP}"
echo -e "➤ Alamat Bug         : ${sts}${domain}"
echo -e "➤ SNI / Host         : ${sni}"
echo -e "➤ Port               : 443"
echo -e "➤ Security           : XTLS"
echo -e "➤ Network            : TCP"
echo -e "➤ Flow Support       : Direct / Splice"
echo -e "➤ Allow Insecure     : true"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Dibuat             : ${hariini}"
echo -e "➤ Berakhir Pada      : ${exp}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link DIRECT        :"
echo -e "${green}${trojanlink1}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link DIRECT UDP443 :"
echo -e "${green}${trojanlink2}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link SPLICE        :"
echo -e "${green}${trojanlink3}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link SPLICE UDP443 :"
echo -e "${green}${trojanlink4}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ YAML DIRECT        : http://${MYIP}:81/${user}-${exp}-TRDIRECT.yaml"
echo -e "➤ YAML SPLICE        : http://${MYIP}:81/${user}-${exp}-TRSPLICE.yaml"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "          ${green}Autoscript by RakhaVPN${NC}"
echo -e ""
read -p "$( echo -e "Tekan ${green}[Enter]${NC} untuk kembali ke menu...") " 
menu
