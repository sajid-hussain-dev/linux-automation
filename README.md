# Linux Automation Scripts

Bash projects I built while learning Linux for DevOps.

## Scripts

### health_check.sh
Shows CPU load, memory, disk usage and uptime, and warns when disk usage is 80% or more.
```bash
./health_check.sh
```

### backup.sh
Creates a compressed, date-stamped backup of a folder and deletes backups older than 7 days.
```bash
./backup.sh ~/Documents ~/backups
```

### user_manager.sh
Menu-driven script to create and delete users, manage groups, and log every action.
```bash
sudo ./user_manager.sh
```

## What I learned
- Bash variables, conditions, functions and menus
- User and group management on Linux
- Backups with tar, find and cron
- Logging and error handling

### server_hardening.sh
Hardens an Ubuntu server: UFW firewall, SSH hardening, fail2ban and automatic security updates.
```bash
sudo ./server_hardening.sh
```

### log_analyzer.sh
Analyzes SSH logs: failed logins, top attacker IPs, usernames tried and successful logins.
```bash
sudo ./log_analyzer.sh /var/log/auth.log 5
```

## Screenshots
Add screenshots here.

   ## Screenshots

   ### Health check
   ![Health check output](health_check.png)

   ### User manager menu
   ![User manager menu](user_manager.png)
