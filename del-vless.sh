#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : RakhaVPN
# (C) Copyright 2025
# =========================================
clear
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/vless.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\\E[0;47;30m   Hapus Akun XRAY Vless WS    \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
		echo ""
		echo "Anda tidak memiliki pengguna!"
        echo ""
		exit 1
	fi
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m   Hapus Akun XRAY Vless WS    \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	
	echo " silahkan pilih pengguna untuk dihapus"
	echo " tekan CTRL+C untuk membatalkan"
	echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
	echo "     Tidak ada pengguna kadaluwarsa"
	grep -E "^### " "/usr/local/etc/xray/vless.json" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Pilih satu pengguna [1]: " CLIENT_NUMBER
		else
			read -rp "Pilih satu pengguna [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
user=$(grep -E "^### " "/usr/local/etc/xray/vless.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/vless.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/vless.json
sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/vnone.json
rm -f /home/vps/public_html/$user-VLESSTLS.yaml /home/vps/public_html/$user-VLESSNTLS.yaml
systemctl restart xray@vless.service
systemctl restart xray@vnone.service
clear
echo " Akun XRAY Vless WS Berhasil dihapus"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Nama Pengguna  : $user"
echo " Berakhir Pada  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e ""
echo -e "Script Mod By RakhaVPN"
echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
menu
