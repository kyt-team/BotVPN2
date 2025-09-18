#!/bin/bash

# Daftar server (bisa kamu ganti sesuai list)
servers=(
  "sg1.alvicelll.net"
  "herza1.skynetvpn.web.id"
)

# Daftar port yang ingin dicek
ports=(22 80 443)

# Warna
green="\e[32m"
red="\e[31m"
nc="\e[0m"

echo "🔍 Cek status server pada port 22, 80, dan 443"
echo "-------------------------------------------"

# Loop setiap server
for server in "${servers[@]}"; do
  echo -e "\n🌐 Server: $server"
  for port in "${ports[@]}"; do
    timeout 2 bash -c "</dev/tcp/$server/$port" &>/dev/null
    if [[ $? -eq 0 ]]; then
      echo -e "  Port $port: ${green}OPEN${nc}"
    else
      echo -e "  Port $port: ${red}CLOSED${nc}"
    fi
  done
done

