#!/bin/bash
# Server Hardening Script for Ubuntu
# Usage: sudo ./server_hardening.sh

LOG_FILE="/var/log/server_hardening.log"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

REAL_USER="${SUDO_USER:-ubuntu}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

log "===== Starting server hardening ====="

# 1. Update system
log "Updating packages..."
apt-get update -y >> "$LOG_FILE" 2>&1
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y >> "$LOG_FILE" 2>&1

# 2. Install security tools
log "Installing ufw, fail2ban, unattended-upgrades..."
DEBIAN_FRONTEND=noninteractive apt-get install -y ufw fail2ban unattended-upgrades >> "$LOG_FILE" 2>&1

# 3. Firewall (allow SSH BEFORE enabling)
log "Configuring firewall..."
ufw default deny incoming >> "$LOG_FILE" 2>&1
ufw default allow outgoing >> "$LOG_FILE" 2>&1
ufw allow 22/tcp >> "$LOG_FILE" 2>&1
ufw --force enable >> "$LOG_FILE" 2>&1
log "Firewall enabled (only port 22 open)"

# 4. SSH hardening
SSH_DROPIN="/etc/ssh/sshd_config.d/01-hardening.conf"
mkdir -p /etc/ssh/sshd_config.d

{
    echo "PermitRootLogin no"
    echo "MaxAuthTries 3"
} > "$SSH_DROPIN"

if [ -s "$USER_HOME/.ssh/authorized_keys" ]; then
    echo "PasswordAuthentication no" >> "$SSH_DROPIN"
    log "SSH keys found for $REAL_USER: password login disabled"
else
    log "WARNING: no SSH keys for $REAL_USER, leaving password login ON to avoid lockout"
fi

if sshd -t; then
    systemctl reload ssh 2>/dev/null || systemctl reload sshd
    log "SSH configuration validated and reloaded"
else
    rm -f "$SSH_DROPIN"
    log "ERROR: SSH config test failed, hardening change removed"
    exit 1
fi

# 5. fail2ban
log "Configuring fail2ban..."
cat > /etc/fail2ban/jail.d/sshd-local.conf << JAIL
[sshd]
enabled = true
maxretry = 5
findtime = 10m
bantime = 1h
JAIL
systemctl enable fail2ban >> "$LOG_FILE" 2>&1
systemctl restart fail2ban
log "fail2ban enabled: 5 failed logins = 1 hour ban"

# 6. Automatic security updates
log "Enabling automatic security updates..."
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive unattended-upgrades >> "$LOG_FILE" 2>&1

# 7. Summary
echo
echo "========== Hardening Summary =========="
ufw status | head -n 8
echo
fail2ban-client status sshd 2>/dev/null
echo
sshd -T 2>/dev/null | grep -E "^(permitrootlogin|passwordauthentication|maxauthtries)"
echo "======================================="
log "===== Hardening complete ====="
echo "IMPORTANT: open a NEW terminal and test SSH login before closing this one."
