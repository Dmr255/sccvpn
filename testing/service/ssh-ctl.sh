#!/bin/bash

set -u

SSH_SERVICE=""
unit_exists() {
    systemctl list-unit-files "$1" --no-legend 2>/dev/null | awk '{ print $1 }' | grep -qx "$1"
}

if unit_exists ssh.service; then
    SSH_SERVICE="ssh"
elif unit_exists sshd.service; then
    SSH_SERVICE="sshd"
fi

has_service() {
    [ -n "$1" ] && unit_exists "$1.service"
}

run_service() {
    local action=$1
    local service=$2

    if ! has_service "$service"; then
        echo "Service $service is not installed."
        return 0
    fi

    systemctl "$action" "$service"
}

show_status() {
    if [ -n "$SSH_SERVICE" ]; then
        systemctl --no-pager --full status "$SSH_SERVICE"
    else
        echo "OpenSSH service is not installed."
    fi

    if has_service dropbear; then
        echo ""
        systemctl --no-pager --full status dropbear
    fi
}

show_config() {
    echo "OpenSSH service : ${SSH_SERVICE:-not installed}"
    echo "Dropbear service: $(has_service dropbear && echo installed || echo not installed)"
    echo ""
    echo "Listening ports:"
    ss -tlnp 2>/dev/null | awk '/sshd|dropbear/ { print }' || true
    echo ""
    [ -f /etc/ssh/sshd_config ] && grep -E '^(Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)' /etc/ssh/sshd_config || true
    [ -f /etc/default/dropbear ] && grep -E '^(NO_START|DROPBEAR_PORT|DROPBEAR_EXTRA_ARGS)' /etc/default/dropbear || true
}

case "${1:-}" in
    start|stop|restart|reload|enable|disable)
        [ -n "$SSH_SERVICE" ] && run_service "$1" "$SSH_SERVICE" || echo "OpenSSH service is not installed."
        run_service "$1" dropbear
        ;;
    status)
        show_status
        ;;
    logs)
        if [ -n "$SSH_SERVICE" ]; then
            journalctl -u "$SSH_SERVICE" -u dropbear -n "${2:-80}" --no-pager
        else
            journalctl -u dropbear -n "${2:-80}" --no-pager
        fi
        ;;
    config)
        show_config
        ;;
    *)
        echo "Usage: ssh-ctl {start|stop|restart|reload|enable|disable|status|logs|config}"
        exit 1
        ;;
esac
