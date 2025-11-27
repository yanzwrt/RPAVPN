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

DB_SSH="/etc/ssh/.sshdb"

clear
MYIP=$(curl -sS ipv4.icanhazip.com)
domain=$(cat /root/domain 2>/dev/null || echo "$MYIP")

if [[ ! -f "$DB_SSH" ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m     CEK KONFIG AKUN SSH/WS       \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Database SSH ($DB_SSH) belum ada."
    echo "Pastikan add-ssh.sh menyimpan data ke file ini."
    echo ""
    exit 1
fi

NUMBER_OF_CLIENTS=$(grep -c -E "^[a-zA-Z0-9_]" "$DB_SSH")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m     CEK KONFIG AKUN SSH/WS       \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user yang terdaftar!"
    echo ""
    exit 1
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m     CEK KONFIG AKUN SSH/WS       \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Pilih user yang ingin dilihat informasinya:"
echo " Tekan CTRL+C untuk kembali ke menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

nl -s') ' "$DB_SSH"

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

user=$(awk "NR==${CLIENT_NUMBER} {print \$1}" "$DB_SSH")
exp=$(awk  "NR==${CLIENT_NUMBER} {print \$2}" "$DB_SSH")

# Ambil port dari config (fallback ke default jika gagal)
ssh_port=$(grep -iE '^Port ' /etc/ssh/sshd_config 2>/dev/null | head -n1 | awk '{print $2}')
[[ -z "$ssh_port" ]] && ssh_port="22"

dropbear_port=$(grep -i '^DROPBEAR_PORT=' /etc/default/dropbear 2>/dev/null | cut -d= -f2)
[[ -z "$dropbear_port" ]] && dropbear_port="143"

extra_ports=$(grep -i '^DROPBEAR_EXTRA_ARGS=' /etc/default/dropbear 2>/dev/null | sed 's/.*-p //; s/"//g')
ws_port="80"

hariini=$(date +"%Y-%m-%d")

clear
echo -e ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "              ${green}AKUN SSH / DROPBEAR / WS${NC}               "
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Username           : ${user}"
echo -e "➤ Domain / Host      : ${domain}"
echo -e "➤ IP VPS             : ${MYIP}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Port OpenSSH       : ${ssh_port}"
echo -e "➤ Port Dropbear      : ${dropbear_port} ${extra_ports}"
echo -e "➤ Port SSH WebSocket : ${ws_port}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Dibuat             : ${hariini}"
echo -e "➤ Berakhir Pada      : ${exp}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "➤ Login SSH          :"
echo -e "  ssh ${user}@${domain} -p ${ssh_port}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "Catatan: Password sesuai yang dibuat saat pembuatan akun."
echo -e ""
echo -e "          ${green}Autoscript by RakhaVPN${NC}"
echo -e ""
read -p "$( echo -e "Tekan ${green}[Enter]${NC} untuk kembali ke menu...") "
menu
