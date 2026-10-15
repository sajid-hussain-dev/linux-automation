#!/bin/bash
# System Health Check - shows CPU, memory, disk, uptime and warns on high disk usage
# Usage: ./health_check.sh

THRESHOLD=80   # warn when disk usage is at or above this percentage

echo "========== System Health Report =========="
echo "Date:   $(date)"
echo "Host:   $(hostname)"
echo "Uptime: $(uptime -p)"
echo

echo "--- CPU Load Average (1, 5, 15 min) ---"
uptime | awk -F'load average:' '{print $2}'
echo

echo "--- Memory Usage ---"
free -h
echo

echo "--- Disk Usage ---"
df -h /
echo

DISK_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

if [ "$DISK_USAGE" -ge "$THRESHOLD" ]; then
    echo "WARNING: Disk usage is ${DISK_USAGE}% (threshold: ${THRESHOLD}%)"
else
    echo "OK: Disk usage is ${DISK_USAGE}%"
fi
echo "=========================================="
