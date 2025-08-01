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

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/trojan.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m        CEK KONFIG TROJAN TCP          \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user yang terdaftar!"
    exit 1
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m        CEK KONFIG TROJAN TCP          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Pilih user yang ingin dilihat konfigurasinya:"
echo " Tekan CTRL+C untuk membatalkan"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     No  Expired   Username"
grep -E "^### " "/usr/local/etc/xray/trojan.json" | cut -d ' ' -f 2-3 | nl -s ') '

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

clear
read -p "Alamat Bug (contoh: www.google.com) : " address
read -p "SNI/Host Bug (contoh: m.facebook.com) : " hst

bug_addr=${address}.
bug_addr2=${address}
sts=${bug_addr2}
[[ -n $address ]] && sts=$bug_addr

bug=${hst}
bug2=${domain}
sni=${bug2}
[[ -n $hst ]] && sni=$bug

user=$(grep -E "^### " "/usr/local/etc/xray/trojan.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
domain=$(cat /root/domain)
uuid=$(grep "},{" /usr/local/etc/xray/trojan.json | cut -b 17-52 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/trojan.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
hariini=$(date +"%Y-%m-%d")

trojanlink="trojan://${user}@${sts}${domain}:443?security=tls&type=tcp&allowInsecure=1&sni=${sni}#XRAY_TROJAN_TCP_${user}"

clear
echo -e ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "               ${green}XRAY TROJAN TCP CONFIG${NC}               "
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Username           : ${user}"
echo -e "➤ Domain             : ${domain}"
echo -e "➤ IP/Host            : ${MYIP}"
echo -e "➤ Port               : 443"
echo -e "➤ Key (Password)     : ${user}"
echo -e "➤ Jaringan           : TCP"
echo -e "➤ Security           : TLS"
echo -e "➤ Allow Insecure     : True (Diizinkan)"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Link Trojan        :"
echo -e "${green}${trojanlink}${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ YAML Config        : http://${MYIP}:81/$user-TRTCP.yaml"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Dibuat Pada        : $hariini"
echo -e "➤ Kadaluarsa         : $exp"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "         ${green}Autoscript by RakhaVPN${NC}"
echo -e ""

read -p "$( echo -e "Tekan ${red}[ ${NC}${green}Enter${NC} ${red}]${NC} untuk kembali ke menu . . .") "
menu
