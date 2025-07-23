#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# (C) Hak Cipta 2025
# =========================================
P='\e[0;35m'
B='\033[0;36m'
N='\e[0m'
clear
echo -e "\e[36m╒════════════════════════════════════════════╕\033[0m"
echo -e " \E[0;47;30m               MENU TROJAN GO               \E[0m"
echo -e "\e[36m╘════════════════════════════════════════════╛\033[0m

 [\033[1;36m•1 \033[0m]  Tambah Akun Trojan GO WS
 [\033[1;36m•2 \033[0m]  Cek Pengguna Login Trojan GO WS
 [\033[1;36m•3 \033[0m]  Hapus Akun Trojan GO WS
 [\033[1;36m•4 \033[0m]  Perpanjang Akun Trojan GO WS
 [\033[1;36m•5 \033[0m]  Cek Konfigurasi Trojan GO
 [\033[1;36m•6 \033[0m]  Ganti Port Trojan GO WS
 [\033[1;36m•0 \033[0m]  Kembali ke Menu Utama"
echo ""
echo -e " \033[1;37mTekan [ Ctrl+C ] • Untuk Keluar Dari Script\033[0m"
echo ""
read -p " Pilih Menu : " opt
echo -e ""
case $opt in
1) clear ; add-trgo ;;
2) clear ; cek-trgo ;;
3) clear ; del-trgo ;;
4) clear ; renew-trgo ;;
5) clear ; user-trgo ;;
6) clear ; port-trgo ;;
0) clear ; menu ;;
x) exit ;;
*) echo "Pilihan Salah" ; sleep 1 ; menu-trgo ;;
esac
