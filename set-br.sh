#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# (C) Hak Cipta 2025
# =========================================
export Server_URL="raw.githubusercontent.com/yanzwrt/RPAVPN/main"

clear
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
clear

red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
purple='\e[0;35m'
NC='\e[0m'

purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green()  { echo -e "\\033[32;1m${*}\\033[0m"; }
red()    { echo -e "\\033[31;1m${*}\\033[0m"; }

green "🔄 Memulai proses instalasi Backup & Restore..."
sleep 1

# Instal rclone
green "📦 Menginstal rclone..."
apt install rclone -y
printf "q\n" | rclone config

# Ambil konfigurasi rclone
green "🔑 Mengunduh konfigurasi rclone..."
wget -O /root/.config/rclone/rclone.conf "https://${Server_URL}/rclone.conf"

# Instal wondershaper untuk limit bandwidth
green "⚙️ Menginstal wondershaper untuk pengaturan bandwidth..."
git clone https://github.com/MrMan21/wondershaper.git
cd wondershaper
make install
cd
rm -rf wondershaper

# Download script backup, restore, dan cleaner
green "📥 Mengunduh skrip backup, restore, dan cleaner..."
cd /usr/bin
wget -O backup "https://${Server_URL}/backup.sh"
wget -O restore "https://${Server_URL}/restore.sh"
wget -O cleaner "https://${Server_URL}/logcleaner.sh"
chmod +x /usr/bin/backup
chmod +x /usr/bin/restore
chmod +x /usr/bin/cleaner

# Setup cron cleaner (tiap 2 menit)
green "🕓 Menjadwalkan pembersihan log otomatis via cron..."
cd
if [ ! -f "/etc/cron.d/cleaner" ]; then
cat> /etc/cron.d/cleaner << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/2 * * * * root /usr/bin/cleaner
END
fi

service cron restart > /dev/null 2>&1
rm -f /root/set-br.sh

green "✅ Instalasi selesai! Fitur backup, restore, dan cleaner siap digunakan."
