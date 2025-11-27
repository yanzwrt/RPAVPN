#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# (C) Hak Cipta 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
orange='\033[0;33m'
NC='\e[0m'

green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

clear

fun_bar() {
    local CMD="$1"
    (
        [[ -e /tmp/fim ]] && rm -f /tmp/fim
        $CMD >/dev/null 2>&1
        touch /tmp/fim
    ) >/dev/null 2>&1 &

    tput civis
    echo -ne "  \033[0;33mMohon Tunggu Memuat \033[1;37m- \033[0;33m["

    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        if [[ -e /tmp/fim ]]; then
            rm -f /tmp/fim
            break
        fi
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mMohon Tunggu Memuat \033[1;37m- \033[0;33m["
    done

    echo -e "\033[0;33m]\033[1;37m -\033[1;32m BERHASIL!\033[1;37m"
    tput cnorm
}

# === Fungsi restart layanan ===
res1()  { systemctl restart fail2ban       >/dev/null 2>&1; }
res2()  { systemctl restart cron.service   >/dev/null 2>&1; }
res3()  { systemctl restart nginx.service  >/dev/null 2>&1; }
res4()  { systemctl restart xray.service   >/dev/null 2>&1; }          # VMESS TLS
res5()  { systemctl restart xray@none.service   >/dev/null 2>&1; }     # VMESS Non-TLS
res6()  { systemctl restart xray@vless.service  >/dev/null 2>&1; }
res7()  { systemctl restart xray@vnone.service  >/dev/null 2>&1; }
res8()  { systemctl restart xray@trojanws.service  >/dev/null 2>&1; }
res9()  { systemctl restart xray@trnone.service    >/dev/null 2>&1; }
res10() { systemctl restart xray@xtrojan.service   >/dev/null 2>&1; }
res11() { systemctl restart xray@trojan.service    >/dev/null 2>&1; }

# Opsional: layanan SSH/Dropbear/L2TP (error disembunyikan kalau servicenya belum ada)
res12() { systemctl restart ssh >/dev/null 2>&1 || systemctl restart sshd >/dev/null 2>&1; }
res13() { systemctl restart dropbear >/dev/null 2>&1; }
res14() { systemctl restart strongswan >/dev/null 2>&1; }
res15() { systemctl restart xl2tpd >/dev/null 2>&1; }

clear
echo -e "\e[36m╒════════════════════════════════════════════╕\033[0m"
echo -e " \E[0;41;36m           RESTART LAYANAN SERVER           \E[0m"
echo -e "\e[36m╘════════════════════════════════════════════╛\033[0m"
echo -e ""

echo -e "  \033[1;91m Memulai ulang layanan Fail2ban\033[1;37m"
fun_bar 'res1'
echo -e "  \033[1;91m Memulai ulang layanan Cron\033[1;37m"
fun_bar 'res2'
echo -e "  \033[1;91m Memulai ulang layanan Nginx\033[1;37m"
fun_bar 'res3'
echo -e "  \033[1;91m Memulai ulang layanan Vmess TLS\033[1;37m"
fun_bar 'res4'
echo -e "  \033[1;91m Memulai ulang layanan Vmess Tanpa TLS\033[1;37m"
fun_bar 'res5'
echo -e "  \033[1;91m Memulai ulang layanan Vless TLS\033[1;37m"
fun_bar 'res6'
echo -e "  \033[1;91m Memulai ulang layanan Vless Tanpa TLS\033[1;37m"
fun_bar 'res7'
echo -e "  \033[1;91m Memulai ulang layanan Trojan WS\033[1;37m"
fun_bar 'res8'
echo -e "  \033[1;91m Memulai ulang layanan Trojan Tanpa TLS\033[1;37m"
fun_bar 'res9'
echo -e "  \033[1;91m Memulai ulang layanan Trojan TCP XTLS\033[1;37m"
fun_bar 'res10'
echo -e "  \033[1;91m Memulai ulang layanan Trojan TCP TLS\033[1;37m"
fun_bar 'res11'

# Tambahan (kalau mau, bisa di-comment kalau belum dipakai)
echo -e "  \033[1;91m Memulai ulang layanan SSH\033[1;37m"
fun_bar 'res12'
echo -e "  \033[1;91m Memulai ulang layanan Dropbear\033[1;37m"
fun_bar 'res13'
echo -e "  \033[1;91m Memulai ulang layanan StrongSwan (IPsec)\033[1;37m"
fun_bar 'res14'
echo -e "  \033[1;91m Memulai ulang layanan XL2TPD (L2TP)\033[1;37m"
fun_bar 'res15'

echo -e ""
echo -e "Script Mod Oleh RakhaVPN"
echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${orange}]${NC} untuk kembali ke menu . . .") " 
menu
