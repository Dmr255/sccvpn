#!/bin/bash

set -u

SERVICE="zivpn"
CONFIG_FILE="/etc/zivpn.conf"
SECRET_FILE="/etc/zivpn.secret"
BIN="/usr/local/bin/zivpn"

has_service() {
    systemctl list-unit-files "$SERVICE.service" --no-legend 2>/dev/null | awk '{ print $1 }' | grep -qx "$SERVICE.service"
}

require_service() {
    if ! has_service; then
        echo "ZIVPN service is not installed."
        exit 1
    fi
}

show_config() {
    echo "ZIVPN binary : $([ -x "$BIN" ] && echo "$BIN" || echo missing)"
    echo "ZIVPN service: $(has_service && echo installed || echo not installed)"
    echo "Config file  : $CONFIG_FILE"
    echo "Secret file  : $([ -f "$SECRET_FILE" ] && echo present || echo missing)"
    echo ""
    if [ -f "$CONFIG_FILE" ]; then
        sed -n '1,160p' "$CONFIG_FILE"
    else
        echo "No ZIVPN config found."
    fi
    echo ""
    echo "Listening ports:"
    ss -ulnp 2>/dev/null | awk '/zivpn/ { print }' || true
}

case "${1:-}" in
    start|stop|restart|reload|enable|disable)
        require_service
        systemctl "$1" "$SERVICE"
        ;;
    status)
        require_service
        systemctl --no-pager --full status "$SERVICE"
        ;;
    logs)
        require_service
        journalctl -u "$SERVICE" -n "${2:-80}" --no-pager
        ;;
    config)
        show_config
        ;;
    *)
        echo "Usage: zivpn-ctl {start|stop|restart|reload|enable|disable|status|logs|config}"
        exit 1
        ;;
esac
