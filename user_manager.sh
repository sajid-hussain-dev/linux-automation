#!/bin/bash
# User & Group Management Script
# Usage: sudo ./user_manager.sh

LOG_FILE="/var/log/user_manager.log"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

create_user() {
    read -p "Enter new username: " username
    if [ -z "$username" ]; then
        echo "Username cannot be empty."; return
    fi
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists."; return
    fi
    useradd -m -s /bin/bash "$username"
    passwd "$username"
    echo "User '$username' created."
    log_action "Created user: $username"
}

delete_user() {
    read -p "Enter username to delete: " username
    if ! id "$username" &>/dev/null; then
        echo "User '$username' does not exist."; return
    fi
    read -p "Delete '$username' and their home directory? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        userdel -r "$username"
        echo "User '$username' deleted."
        log_action "Deleted user: $username"
    else
        echo "Cancelled."
    fi
}

list_users() {
    echo "--- Regular users ---"
    awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
    log_action "Listed users"
}

create_group() {
    read -p "Enter new group name: " groupname
    if getent group "$groupname" &>/dev/null; then
        echo "Group '$groupname' already exists."; return
    fi
    groupadd "$groupname"
    echo "Group '$groupname' created."
    log_action "Created group: $groupname"
}

add_user_to_group() {
    read -p "Enter username: " username
    read -p "Enter group name: " groupname
    if ! id "$username" &>/dev/null; then
        echo "User does not exist."; return
    fi
    if ! getent group "$groupname" &>/dev/null; then
        echo "Group does not exist."; return
    fi
    usermod -aG "$groupname" "$username"
    echo "Added '$username' to '$groupname'."
    log_action "Added $username to group $groupname"
}

list_groups() {
    echo "--- Groups ---"
    cut -d: -f1 /etc/group
    log_action "Listed groups"
}

show_log() {
    echo "--- Last 20 log entries ---"
    tail -n 20 "$LOG_FILE" 2>/dev/null || echo "No log yet."
}

while true; do
    echo
    echo "====== User Management Menu ======"
    echo "1) Create user"
    echo "2) Delete user"
    echo "3) List users"
    echo "4) Create group"
    echo "5) Add user to group"
    echo "6) List groups"
    echo "7) View log"
    echo "8) Exit"
    read -p "Choose an option [1-8]: " choice

    case "$choice" in
        1) create_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) create_group ;;
        5) add_user_to_group ;;
        6) list_groups ;;
        7) show_log ;;
        8) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option. Choose 1-8." ;;
    esac
done

