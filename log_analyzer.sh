#!/bin/bash
# SSH Log Analyzer - usage: sudo ./log_analyzer.sh [log_file] [top_n]

LOG_FILE="${1:-/var/log/auth.log}"
TOP="${2:-5}"

if [ ! -r "$LOG_FILE" ]; then
    echo "Error: cannot read '$LOG_FILE'. Try running with sudo."
    exit 1
fi

FAILED=$(grep -c "Failed password" "$LOG_FILE")
INVALID=$(grep -c "Invalid user" "$LOG_FILE")
SUCCESS=$(grep -c "Accepted " "$LOG_FILE")

echo "========== SSH Log Analysis =========="
echo "Log file:  $LOG_FILE"
echo "Generated: $(date)"
echo
echo "--- Summary ---"
echo "Failed password attempts: $FAILED"
echo "Invalid user attempts:    $INVALID"
echo "Successful logins:        $SUCCESS"
echo

echo "--- Top $TOP IPs with failed logins ---"
grep "Failed password" "$LOG_FILE" \
    | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' \
    | sort | uniq -c | sort -rn | head -n "$TOP"
echo

echo "--- Top $TOP usernames tried ---"
grep "Failed password" "$LOG_FILE" \
    | sed -E 's/.*Failed password for (invalid user )?([^ ]+) from.*/\2/' \
    | sort | uniq -c | sort -rn | head -n "$TOP"
echo

echo "--- Successful logins (user and IP) ---"
grep "Accepted " "$LOG_FILE" \
    | sed -E 's/.*Accepted [a-z]+ for ([^ ]+) from ([0-9.]+).*/\1 from \2/' \
    | sort | uniq -c | sort -rn | head -n "$TOP"
echo "======================================="
