#!/bin/bash

CONFIG_FILE="/usr/local/etc/xray/config/04_inbounds.json"
ACCOUNTS_FILE="/usr/local/etc/xray/accounts.tsv"

clear
now=$(date +"%Y-%m-%d")

[ -f "$ACCOUNTS_FILE" ] || exit 0

while IFS=$'\t' read -r user exp _; do
    [ -z "$user" ] && continue

    d1=$(date -d "$exp" +%s 2>/dev/null) || continue
    d2=$(date -d "$now" +%s)
    exp2=$(((d1 - d2) / 86400))

    if [[ "$exp2" -le 0 ]]; then
        tmp_file=$(mktemp)
        jq --arg user "$user" '.inbounds |= map(if (.settings.clients? | type) == "array" then .settings.clients |= map(select(.email != $user)) else . end)' "$CONFIG_FILE" > "$tmp_file" && mv "$tmp_file" "$CONFIG_FILE"
        grep -v -F "${user}	" "$ACCOUNTS_FILE" > "${ACCOUNTS_FILE}.tmp" || true
        mv "${ACCOUNTS_FILE}.tmp" "$ACCOUNTS_FILE"
        rm -rf /var/www/html/xray/xray-$user.html
        rm -rf /user/xray-$user.log
        systemctl restart xray
    fi
done < "$ACCOUNTS_FILE"
