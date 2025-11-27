#!/bin/bash
# L2TP/IPsec installer for RPAVPN
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# ============================
# Default values (bisa di-override via env)
# ============================
L2TP_USER=${L2TP_USER:-l2tpuser}
L2TP_PASSWORD=${L2TP_PASSWORD:-$(openssl rand -base64 12)}
IPSEC_PSK=${IPSEC_PSK:-$(openssl rand -hex 16)}
DOMAIN_FILE="/root/domain"
SERVER_IP=${SERVER_IP:-$(curl -sS ipv4.icanhazip.com || hostname -I | awk '{print $1}')}
SERVER_ID=${SERVER_ID:-$(cat "$DOMAIN_FILE" 2>/dev/null || echo "$SERVER_IP")}

echo "==> Install paket L2TP/IPsec..."
apt-get update -y
apt-get install -y strongswan xl2tpd ppp lsof fail2ban

# ============================
# Konfigurasi strongSwan (IPsec)
# ============================
cat > /etc/ipsec.conf <<IPSEC
config setup
  uniqueids=never

conn L2TP-PSK
  keyexchange=ikev1
  authby=secret
  type=transport
  left=%defaultroute
  leftid=$SERVER_ID
  leftprotoport=17/1701
  right=%any
  rightprotoport=17/%any
  auto=add
IPSEC

cat > /etc/ipsec.secrets <<SECRETS
$SERVER_ID %any : PSK "$IPSEC_PSK"
SECRETS
chmod 600 /etc/ipsec.secrets

# ============================
# Konfigurasi xl2tpd
# ============================
cat > /etc/xl2tpd/xl2tpd.conf <<XL2TPD
[global]
ipsec saref = yes

[lns default]
ip range = 10.10.10.2-10.10.10.254
local ip = 10.10.10.1
require chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
XL2TPD

# ============================
# Konfigurasi PPP (options.xl2tpd)
# ============================
cat > /etc/ppp/options.xl2tpd <<PPP
require-mschap-v2
ms-dns 1.1.1.1
ms-dns 8.8.8.8
asyncmap 0
hide-password
ipcp-accept-local
ipcp-accept-remote
noccp
idle 1800
mtu 1410
mru 1410
nodefaultroute
proxyarp
lcp-echo-failure 4
lcp-echo-interval 30
name l2tpd
PPP

# ============================
# Konfigurasi chap-secrets (L2TP user DB)
# ============================
CHAP_SECRETS="/etc/ppp/chap-secrets"
DEFAULT_USER_CREATED=0

# Jika file belum ada, buat kosong dulu
if [ ! -f "$CHAP_SECRETS" ]; then
  touch "$CHAP_SECRETS"
  chmod 600 "$CHAP_SECRETS"
fi

# Jika file masih kosong (tidak ada baris ###), buat 1 user default
if ! grep -q '^### ' "$CHAP_SECRETS"; then
  # Format disamakan dengan skema RPAVPN:
  # ### user exp
  # "user" l2tpd "password" *
  echo "### $L2TP_USER default" >> "$CHAP_SECRETS"
  echo "\"$L2TP_USER\" l2tpd \"$L2TP_PASSWORD\" *" >> "$CHAP_SECRETS"
  chmod 600 "$CHAP_SECRETS"
  DEFAULT_USER_CREATED=1
fi

# ============================
# Firewall & IP Forward
# ============================
PUBLIC_IFACE=${PUBLIC_IFACE:-$(ip route get 1.1.1.1 | awk '{print $5; exit}')}
if [ -z "$PUBLIC_IFACE" ]; then
  echo "Gagal menemukan interface publik" >&2
  exit 1
fi

iptables -I INPUT -p udp --dport 500 -j ACCEPT
iptables -I INPUT -p udp --dport 4500 -j ACCEPT
iptables -I INPUT -p udp --dport 1701 -j ACCEPT
iptables -t nat -I POSTROUTING -s 10.10.10.0/24 -o "$PUBLIC_IFACE" -j MASQUERADE

# IP forward
sysctl -w net.ipv4.ip_forward=1 >/dev/null
if ! grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf; then
  echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
fi

# ============================
# Enable service
# ============================
systemctl enable strongswan --now
systemctl enable xl2tpd --now

echo ""
echo "========================================="
echo "   L2TP/IPSec sudah diaktifkan di VPS"
echo "========================================="
echo " • Host/ID Server : $SERVER_ID"
echo " • PSK (IPSec)    : $IPSEC_PSK"

if [ "$DEFAULT_USER_CREATED" -eq 1 ]; then
  echo " • User Default   : $L2TP_USER"
  echo " • Password       : $L2TP_PASSWORD"
  echo " • Exp (tag)      : default"
  echo ""
  echo "User L2TP default ini ditulis dengan format:"
  echo "  ### $L2TP_USER default"
  echo "  \"$L2TP_USER\" l2tpd \"$L2TP_PASSWORD\" *"
else
  echo ""
  echo "chap-secrets sudah berisi user sebelumnya."
  echo "Tidak membuat user default baru."
fi

echo ""
echo "Untuk menambah / menghapus user L2TP:"
echo " • Tambah user : jalankan add-l2tp"
echo " • Hapus user  : jalankan del-l2tp"
echo "========================================="
