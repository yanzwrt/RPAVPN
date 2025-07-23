#!/bin/bash
# =========================================
# Penyiapan Cepat | Manajer Setup Skrip
# Edisi  : Edisi Stabil V1.0
# Pembuat: RakhaVPN
# (C) Hak Cipta 2025
# =========================================
clear
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
red='\e[1;31m'
green='\e[0;32m'
purple='\e[0;35m'
orange='\e[0;33m'
NC='\e[0m'
export Server_URL="raw.githubusercontent.com/yanzwrt/RPAVPN/main"
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
##########################
MYIP=$(wget -qO- ipv4.icanhazip.com)
MYIP=$(curl -s ipinfo.io/ip)
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me)
echo "Memeriksa VPS..."
clear

purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green()  { echo -e "\\033[32;1m${*}\\033[0m"; }
red()    { echo -e "\\033[31;1m${*}\\033[0m"; }

# Cek root dan OpenVZ
if [ "${EUID}" -ne 0 ]; then
    echo "Skrip ini harus dijalankan sebagai root."
    exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ tidak didukung."
    exit 1
fi
MYIP=$(wget -qO- icanhazip.com/ip);
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
secs_to_human() {
    echo "Waktu instalasi : $(( ${1} / 3600 )) jam $(( (${1} / 60) % 60 )) menit $(( ${1} % 60 )) detik"
}
start=$(date +%s)

echo -e "[ ${green}INFO${NC} ] Menyiapkan proses instalasi autoscript..."
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] File instalasi siap! Memulai proses..."
sleep 1

if [ -f "/usr/local/etc/xray/domain" ]; then
    echo "Script sudah terpasang sebelumnya."
    exit 0
fi

mkdir /var/lib/premium-script
mkdir /var/lib/crot-script
clear
echo -e "${red}    ♦️${NC} ${green} PENGATURAN DOMAIN VPS     ${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo "1. Gunakan Domain dari Script"
echo "2. Gunakan Domain Milik Sendiri"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
read -rp "Pilih Metode Instalasi Domain : " dom 

if test $dom -eq 1; then
    clear
    wget -q -O /root/cf.sh "https://${Server_URL}/cf.sh"
    chmod +x /root/cf.sh
    ./cf.sh
elif test $dom -eq 2; then
    read -rp "Masukkan Nama Domain Anda : " domen 
    echo $domen > /root/domain
else 
    echo "Pilihan tidak ditemukan."
    exit 1
fi

echo -e "${GREEN}Berhasil!${NC}"
sleep 2
clear

echo "IP=$host" >> /var/lib/premium-script/ipvps.conf
echo "IP=$host" >> /var/lib/crot-script/ipvps.conf
echo "$host" >> /root/domain
#clear
#echo -e "\e[0;32mSIAP MENGINSTALL SCRIPT...\e[0m"
#echo -e ""
#sleep 1
#Install SSH-VPN
echo -e "\e[0;32mINSTALLING SSH-VPN...\e[0m"
sleep 1
wget https://${Server_URL}/ssh-vpn2.sh && chmod +x ssh-vpn2.sh && ./ssh-vpn2.sh
sleep 3
clear
echo -e "\e[0;32mINSTALLING XRAY CORE...\e[0m"
sleep 3
wget -q -O /root/xray2.sh "https://${Server_URL}/xray2.sh"
chmod +x /root/xray2.sh
./xray2.sh
echo -e "${GREEN}Done!${NC}"
sleep 2
clear
#Install SET-BR
echo -e "\e[0;32mINSTALLING SET-BR...\e[0m"
sleep 1
wget -q -O /root/set-br.sh "https://${Server_URL}/set-br.sh"
chmod +x /root/set-br.sh
./set-br.sh
echo -e "${GREEN}Done!${NC}"
sleep 2
clear

#rm -rf /usr/share/nginx/html/index.html
#wget -q -O /usr/share/nginx/html/index.html "https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/OTHERS/index.html"

# Finish
rm -f /root/ins-xray.sh
rm -f /root/set-br.sh
rm -f /root/ssh-vpn.sh

# Version
echo "1.0" > /home/ver
clear
# OUTPUT AKHIR
echo ""
echo -e "${RB}      .-------------------------------------------.${NC}"
echo -e "${RB}      |${NC}      ${CB}Instalasi Telah Selesai${NC}           ${RB}|${NC}"
echo -e "${RB}      '-------------------------------------------'${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "      ${WB}Autoscript Multiport Websocket oleh RakhaVPN${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${WB}»»» Layanan Protokol «««  |  »»» Protokol Jaringan «««${NC}  "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Vmess Websocket${NC}         ${WB}|${NC}  ${YB}- WebSocket (CDN) TLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Vless Websocket${NC}         ${WB}|${NC}  ${YB}- WebSocket (CDN) NTLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Trojan Websocket${NC}        ${WB}|${NC}  ${YB}- TCP XTLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Trojan TCP XTLS${NC}         ${WB}|${NC}  ${YB}- TCP TLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Trojan TCP${NC}              ${WB}|${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "           ${WB}»»» Informasi YAML «««${NC}          "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY VMESS WS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY VLESS WS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY TROJAN WS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY TROJAN XTLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY TROJAN TCP${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "             ${WB}»»» Informasi Server «««${NC}                 "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Zona Waktu            : Asia/Jakarta (GMT +7)${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Fail2Ban              : [AKTIF]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Dflate                : [AKTIF]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}IPtables              : [AKTIF]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Reboot Otomatis       : [AKTIF]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}IPV6                  : [NONAKTIF]${NC}"
echo ""
echo -e "  ${RB}♦️${NC} ${YB}Otomatis Reboot Setiap 03.00 WIB${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Backup & Restore Data VPS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Penghapusan Otomatis Akun Kadaluarsa${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Monitor Bandwidth VPS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Monitor RAM & CPU${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Cek Login Pengguna${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Cek Konfigurasi Dibuat${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Hapus Log Otomatis${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Pemeriksa Media${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Pengubah DNS (DNS Changer)${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "              ${WB}»»» Layanan Port Jaringan «««${NC}             "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}HTTP                    : 80, 8080, 8880${NC}"
echo -e "  ${RB}♦️${NC} ${YB}HTTPS                   : 443${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo ""
secs_to_human "$(($(date +%s) - ${start}))"
echo ""
rm -r setup2.sh
echo ""
echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} untuk memulai ulang...") "
reboot
