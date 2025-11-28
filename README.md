<!-- BANNER -->
<p align="center">
  <img src="https://img.shields.io/badge/RakhaVPN-XRAY%20Multiprotocol-blue?style=for-the-badge&logo=cloudflare&logoColor=white">
</p>

<h1 align="center">🚀 XRAY Multiport Websocket Autoscript</h1>
<h3 align="center">⚡ Support WS • SNI • CustomPath • SSH Websocket • L2TP • XTLS • Trojan • IPv6 Mode ⚡</h3>

<p align="center">
  <img src="https://img.shields.io/github/v/release/yanzwrt/RPAVPN?style=for-the-badge&color=green">
  <img src="https://img.shields.io/github/last-commit/yanzwrt/RPAVPN?style=for-the-badge&logo=github&color=purple">
  <img src="https://img.shields.io/badge/Maintained-YES-blue?style=for-the-badge">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Debian-10/11/12-red?style=for-the-badge&logo=debian">
  <img src="https://img.shields.io/badge/Ubuntu-18.04/20.04-orange?style=for-the-badge&logo=ubuntu">
</p>

---

# ⚠️ **WAJIB DIBACA SEBELUM INSTALASI**

Jika menggunakan **Cloudflare**, wajib aktifkan/ubah:

| Pengaturan | Status |
|-----------|--------|
| SSL/TLS Mode | **Full** |
| Universal SSL | **ON** |
| Always Use HTTPS | **OFF** |
| TLS Recommender | **ON** |
| Edge Certificates | aktif |

Script mendukung:  
✔ CDN Cloudflare  
✔ Direct DNS  
✔ Wildcard domain  
✔ SNI Bug Host  

---

# 🧰 **FITUR LENGKAP AUTOSCRIPT**

### 🟦 **XRAY Services**
| Protocol | TLS | Non TLS | WS | XTLS | TCP | SNI | CustomPath |
|---------|:---:|:-------:|:--:|:----:|:---:|:---:|:-----------:|
| VMESS | ✔ | ✔ | ✔ | – | – | ✔ | ✔ |
| VLESS | ✔ | ✔ | ✔ | – | – | ✔ | ✔ |
| TROJAN WS | ✔ | ✔ | ✔ | – | – | ✔ | ✔ |
| TROJAN TCP | ✔ | – | – | – | ✔ | ✔ | – |
| TROJAN XTLS | ✔ | – | – | ✔ | ✔ | ✔ | – |

---

### 🟩 **SSH & VPN Services**
(Full version only — setup.sh)

| Service | Status |
|--------|--------|
| SSH Websocket (WS + Dropbear) | ✔ |
| Stunnel / OpenSSH | ✔ |
| L2TP/IPsec (PSK + UserPass) | ✔ |

---

### 🟨 **Fitur Tambahan**
✔ YAML Generator  
✔ Auto Delete Expired XRAY (xp.sh)  
✔ Auto Backup & Restore  
✔ Auto Clear Log  
✔ Auto Reboot 03.00 WIB  
✔ XRAY-Core Changer  
✔ Multipath Support  
✔ BBRPLUS Kernel Optimizer  
✔ Network speedtest  
✔ DNS Changer  
✔ Netflix Region Checker  
✔ Bandwidth Monitor (vnstat)  
✔ CPU & RAM Monitor  

---

# 📦 **PREMIUM INSTALLATION**

## 🅰️ **Full Version (Rekomendasi) – IPv6 OFF**
Termasuk SSH-WS, L2TP, XRAY lengkap.

  ```html
sysctl -w net.ipv6.conf.all.disable_ipv6=1 \
&& sysctl -w net.ipv6.conf.default.disable_ipv6=1 \
&& apt update \
&& apt install -y bzip2 gzip coreutils screen curl \
&& wget https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/setup.sh \
&& chmod +x setup.sh \
&& ./setup.sh

---

# 📦 **LITE INSTALLATION**

## 🅱️ **Lite Version – IPv6 ON**
XRAY only (WS + SNI). Tanpa SSH & L2TP. Lebih ringan untuk VPS kecil.

  ```html
apt update \
&& apt install -y bzip2 gzip coreutils screen curl \
&& wget https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/setup2.sh \
&& chmod +x setup2.sh \
&& ./setup2.sh


🔄 Update Script (Auto Pull from GitHub)
bash
Salin kode
curl -fsSL https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/update.sh -o update.sh \
&& bash update.sh
🧪 Detail Port & Struktur XRAY
Layanan	Port Public	Port Internal
VMESS WS TLS	443	1311
VMESS WS NTLS	80 / 8080 / 8880	23456
VLESS WS TLS	443	1312
VLESS WS NTLS	80	14016
TROJAN WS TLS	443	1313
TROJAN WS NTLS	80	25432
TROJAN TCP XTLS	443	–
TROJAN TCP TLS	443	1310

📁 Struktur Auto-Clean (xp.sh)
Akun yang expired otomatis dihapus dari:

config.json

none.json

vless.json

vnone.json

trojanws.json

trnone.json

trojan.json

xtrojan.json

YAML user file

🎯 Kelebihan Script Ini
✔ Stabil dipakai ribuan user
✔ Full auto maintenance
✔ Tidak berat seperti script lain
✔ Clean proxy structure
✔ Sangat cocok untuk provider bug / SNI
✔ Tidak bentrok port & service
✔ Full systemd multi-instance

📞 Developer
RakhaVPN
Autoscript by: yanzwrt / RakhaVPN Project

Support fork & modifikasi pribadi.
Dilarang menjual tanpa izin.
