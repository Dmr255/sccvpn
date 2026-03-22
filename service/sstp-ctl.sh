#!/bin/bash

set -u

SERVICE="sstpd"
CONFIG_FILE="/etc/sstpd.conf"

has_service() {
    systemctl list-unit-files "$SERVICE.service" --no-legend 2>/dev/null | awk '{ print $1 }' | grep -qx "$SERVICE.service"
}

require_service() {
    if ! has_service; then
        echo "SSTP service is not installed. Install package: sstpd"
        exit 1
    fi
}

show_config() {
    echo "SSTP service: $(has_service && echo installed || echo not installed)"
    echo "Config file : $CONFIG_FILE"
    echo ""
    if [ -f "$CONFIG_FILE" ]; then
        sed -n '1,160p' "$CONFIG_FILE"
    else
        echo "No SSTP config found."
    fi
    echo ""
    echo "Listening ports:"
    ss -tlnp 2>/dev/null | awk '/sstpd/ { print }' || true
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
        echo "Usage: sstp-ctl {start|stop|restart|reload|enable|disable|status|logs|config}"
        exit 1
        ;;
esac
