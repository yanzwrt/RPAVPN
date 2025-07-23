#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# (C) Hak Cipta 2025
# =========================================
red='\e[1;31m'
green='\e[0;32m'
purple='\e[0;35m'
orange='\e[0;33m'
NC='\e[0m'
clear
echo ""
echo " Fitur ini hanya dapat digunakan sesuai data VPS dari autoscript ini"
echo " Silakan masukkan link backup data VPS untuk memulihkan data"
echo ""
#read -rp " Password File: " -e InputPass
read -rp " Link File: " -e url
wget -O backup.zip "$url"
#unzip -P $InputPass /root/backup.zip &> /dev/null
unzip backup.zip
rm -f backup.zip
sleep 1
echo -e "[ ${green}INFO${NC} ] Memulai proses pemulihan data . . . "
#cp -r /root/backup/.acme.sh /root/ &> /dev/null
#cp -r /root/backup/premium-script /var/lib/ &> /dev/null
#cp -r /root/backup/xray /usr/local/etc/ &> /dev/null
cp -r /root/backup/*.json /usr/local/etc/xray/ >/dev/null
cp -r /root/backup/public_html /home/vps/ &> /dev/null
cp -r /root/backup/crontab /etc/ &> /dev/null
cp -r /root/backup/cron.d /etc/ &> /dev/null
rm -rf /root/backup
rm -f backup.zip
echo ""
echo -e "[ ${green}INFO${NC} ] Pemulihan data VPS selesai!"
echo ""
echo -e "[ ${green}INFO${NC} ] Memulai ulang semua layanan"
systemctl restart nginx
systemctl restart xray.service
systemctl restart xray@none.service
systemctl restart xray@vless.service
systemctl restart xray@vnone.service
systemctl restart xray@trojanws.service
systemctl restart xray@trnone.service
systemctl restart xray@xtrojan.service
systemctl restart xray@trojan.service
service cron restart
echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${orange}]${NC} untuk kembali ke menu . . .") "
menu
