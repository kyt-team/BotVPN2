#!/bin/bash
cat >/etc/systemd/system/sellvpn.service <<EOF
[Unit]
Description=SellVPN Bot Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/BotVPN
ExecStart=/usr/bin/node /root/BotVPN/app.js
Restart=always
User=root
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

cat >/usr/bin/backup_sellvpn <<'EOF'
#!/bin/bash
VARS_FILE="/root/BotVPN/.vars.json"
DB_FILE="/root/BotVPN/sellvpn.db"

if [ ! -f "$VARS_FILE" ]; then
    echo "❌ File $VARS_FILE tidak ditemukan"
    exit 1
fi

# Ambil nilai dari .vars.json
BOT_TOKEN=$(jq -r '.BOT_TOKEN' "$VARS_FILE")
USER_ID=$(jq -r '.USER_ID' "$VARS_FILE")

if [ -z "$BOT_TOKEN" ] || [ -z "$USER_ID" ]; then
    echo "❌ BOT_TOKEN atau USER_ID kosong di $VARS_FILE"
    exit 1
fi

# Kirim database ke Telegram
if [ -f "$DB_FILE" ]; then
    curl -s -F chat_id="$USER_ID" \
         -F document=@"$DB_FILE" \
         "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" >/dev/null 2>&1
    echo "✅ Backup terkirim ke Telegram"
else
    echo "❌ Database $DB_FILE tidak ditemukan"
fi
EOF

# bikin cron job tiap 1 jam
cat >/etc/cron.d/backup_sellvpn <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 */2 * * * root /usr/bin/backup_sellvpn
EOF

chmod +x /usr/bin/backup_sellvpn

systemctl daemon-reload >/dev/null 2>&1
systemctl enable sellvpn.service >/dev/null 2>&1
systemctl start sellvpn.service >/dev/null 2>&1
systemctl restart sellvpn.service >/dev/null 2>&1
service cron restart
