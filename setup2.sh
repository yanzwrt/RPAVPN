#!/bin/bash
# =========================================
# Penyiapan Cepat | Manajer Setup Skrip
# Edisi  : Edisi Stabil V1.1
# Pembuat: RakhaVPN
# (C) Hak Cipta 2025
# =========================================

clear

# Warna
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
CYAN='\e[0;36m'
NC='\e[0m'

export Server_URL="raw.githubusercontent.com/yanzwrt/RPAVPN/main"

# Ambil tanggal dari Google
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# IP VPS (satu kali saja)
MYIP=$(curl -sS ifconfig.me)

echo "Memeriksa VPS..."
sleep 1
clear

purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green_txt()  { echo -e "\\033[32;1m${*}\\033[0m"; }
red_txt()    { echo -e "\\033[31;1m${*}\\033[0m"; }

# Cek root dan OpenVZ
if [ "${EUID}" -ne 0 ]; then
 echo "Skrip ini harus dijalankan sebagai root."
 exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
 echo "OpenVZ tidak didukung."
 exit 1
fi

secs_to_human() {
 echo "Waktu instalasi : $(( ${1} / 3600 )) jam $(( (${1} / 60) % 60 )) menit $(( ${1} % 60 )) detik"
}

start=$(date +%s)

echo -e "[ ${green}INFO${NC} ] Menyiapkan proses instalasi autoscript..."
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] File instalasi siap! Memulai proses..."
sleep 1

# =========================================
# ENABLE IP FORWARD + IPTABLES UNTUK VPN
# =========================================
echo -e "[ ${green}INFO${NC} ] Mengaktifkan IPv4 forwarding..."
sed -i 's/^#\?net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p >/dev/null 2>&1

# Deteksi interface publik (eth0 / ens3 / ens18, dll)
WAN_IF=$(ip route show default 2>/dev/null | awk '{print $5}' | head -n1)
if [ -z "$WAN_IF" ]; then
  WAN_IF="eth0"
fi
echo -e "[ ${green}INFO${NC} ] Interface publik terdeteksi: ${WAN_IF}"

echo -e "[ ${green}INFO${NC} ] Mengatur iptables NAT & FORWARD untuk klien VPN (ppp+/L2TP)..."

# NAT semua trafik keluar via interface publik
iptables -t nat -A POSTROUTING -o "${WAN_IF}" -j MASQUERADE

# Izinkan trafik dari klien L2TP/PPP (ppp+) ke internet
iptables -A FORWARD -i ppp+ -o "${WAN_IF}" -j ACCEPT

# Izinkan trafik balik dari internet ke klien L2TP/PPP
iptables -A FORWARD -i "${WAN_IF}" -o ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT

# Install & simpan iptables-persistent agar rules tidak hilang saat reboot
apt-get install -y iptables-persistent >/dev/null 2>&1
netfilter-persistent save >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Aturan iptables tersimpan (iptables-persistent)."

# Cek apakah sudah pernah terinstall
if [ -f "/usr/local/etc/xray/config.json" ] && [ -f "/root/domain" ]; then
 echo "Script sudah terpasang sebelumnya. Jika ingin install ulang, hapus /usr/local/etc/xray dan /root/domain dulu."
 exit 0
fi

# Direktori data
mkdir -p /var/lib/premium-script
mkdir -p /var/lib/crot-script

clear
echo -e "${red}    ♦️${NC} ${green} PENGATURAN DOMAIN VPS     ${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo "1. Gunakan Domain dari Script"
echo "2. Gunakan Domain Milik Sendiri"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
read -rp "Pilih Metode Instalasi Domain [1/2] : " dom

host=""

case "$dom" in
1)
 clear
 wget -q -O /root/cf.sh "https://${Server_URL}/cf.sh"
 chmod +x /root/cf.sh
 /root/cf.sh
 # cf.sh seharusnya menulis domain ke /root/domain
 if [ -f /root/domain ]; then
   host=$(cat /root/domain)
 else
   echo "Gagal mendapatkan domain dari cf.sh"
   exit 1
 fi
 ;;
2)
 read -rp "Masukkan Nama Domain Anda : " domen
 if [ -z "$domen" ]; then
   echo "Domain tidak boleh kosong!"
   exit 1
 fi
 echo "$domen" > /root/domain
 host="$domen"
 ;;
*)
 echo "Pilihan tidak ditemukan."
 exit 1
 ;;
esac

echo -e "${green}Berhasil!${NC}"
sleep 2
clear

# Simpan IP/host ke file config
echo "IP=$host" > /var/lib/premium-script/ipvps.conf
echo "IP=$host" > /var/lib/crot-script/ipvps.conf
echo "$host" > /root/domain

# =================================
# Install SSH-VPN (versi 2)
# =================================
echo -e "\e[0;32mINSTALLING SSH-VPN...\e[0m"
sleep 1
wget -q -O /root/ssh-vpn2.sh "https://${Server_URL}/ssh-vpn2.sh"
chmod +x /root/ssh-vpn2.sh
/root/ssh-vpn2.sh
sleep 3
clear

# =================================
# Install XRAY CORE (versi 2)
# =================================
echo -e "\e[0;32mINSTALLING XRAY CORE...\e[0m"
sleep 1
wget -q -O /root/xray2.sh "https://${Server_URL}/xray2.sh"
chmod +x /root/xray2.sh
/root/xray2.sh
echo -e "${green}Done!${NC}"
sleep 2
clear

# =================================
# Install SET-BR
# =================================
echo -e "\e[0;32mINSTALLING SET-BR...\e[0m"
sleep 1
wget -q -O /root/set-br.sh "https://${Server_URL}/set-br.sh"
chmod +x /root/set-br.sh
/root/set-br.sh
echo -e "${green}Done!${NC}"
sleep 2
clear

# Bersihkan file installer
rm -f /root/xray2.sh
rm -f /root/set-br.sh
rm -f /root/ssh-vpn2.sh
rm -f /root/cf.sh 2>/dev/null

# Version
echo "1.0" > /home/ver

clear
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

rm -f setup2.sh

echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} untuk memulai ulang...") "
reboot
