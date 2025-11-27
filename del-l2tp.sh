#!/bin/bash
# =========================================
# RPAVPN | Hapus Akun L2TP/IPSec
# Edition : Stable Edition V1.0
# Author  : yanzwrt (base RakhaVPN)
# =========================================

clear
red='\e[1;31m'
green='\e[0;32m'
orange='\e[1;33m'
CYAN='\e[0;36m'
NC='\e[0m'

CHAP_SECRETS="/etc/ppp/chap-secrets"

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m         Hapus Akun L2TP/IPSec        \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

if [[ ! -f "$CHAP_SECRETS" ]]; then
    echo "File $CHAP_SECRETS tidak ditemukan."
    echo ""
    read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
    menu
fi

mapfile -t DATA < <(grep '^### ' "$CHAP_SECRETS" 2>/dev/null)

NUMBER_OF_CLIENTS=${#DATA[@]}
if [[ ${NUMBER_OF_CLIENTS} -eq 0 ]]; then
    echo "Tidak ada user L2TP yang terdaftar lewat script (### user exp)."
    echo ""
    read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
    menu
fi

echo " Pilih akun L2TP yang ingin dihapus:"
echo " Tekan CTRL+C untuk membatalkan."
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     No  User         Expired"
i=0
for line in "${DATA[@]}"; do
    ((i++))
    user=$(echo "$line" | awk '{print $2}')
    exp=$(echo "$line"  | awk '{print $3}')
    printf " %2s) %-12s %s\n" "$i" "$user" "$exp"
done
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

CLIENT_NUMBER=0
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    if [[ ${CLIENT_NUMBER} == '1' ]]; then
        read -rp "Select one client [1]: " CLIENT_NUMBER
    else
        read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    fi
done

selected_line="${DATA[$((CLIENT_NUMBER-1))]}"
user=$(echo "$selected_line" | awk '{print $2}')
exp=$(echo "$selected_line"  | awk '{print $3}')

# Hapus baris ### user exp dan baris kredensial di bawahnya
# Format di chap-secrets:
# ### user exp
# "user" l2tpd "pass" *
sed -i "/^### $user $exp$/,+1d" "$CHAP_SECRETS"

# Optional: hapus dari /etc/ipsec.d/passwd jika sebelumnya dipakai
if [[ -f /etc/ipsec.d/passwd ]]; then
    sed -i "/^$user:/d" /etc/ipsec.d/passwd
fi

clear
echo " Akun L2TP/IPSec Berhasil Dihapus"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Nama Pengguna : $user"
echo " Expired Pada  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "Script Mod By RPAVPN"
echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
menu
