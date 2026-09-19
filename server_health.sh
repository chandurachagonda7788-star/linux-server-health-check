#!/bin/bash

echo "================================="
echo "     Linux Server Health Check"
echo "================================="

echo "Hostname      : $(hostname)"
echo "IP Address    : $(hostname -I | awk '{print $1}')"
echo "Date & Time   : $(date)"
echo "Uptime        : $(uptime -p)"

echo
echo "CPU Usage:"

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')

echo "CPU Used: $CPU_USAGE%"

if awk "BEGIN {exit !($CPU_USAGE >= 80)}"
then
    echo "WARNING: CPU usage is above 80%"
else
    echo "CPU Status: NORMAL"
fi

echo
echo "Memory Usage:"
free -h

echo
echo "Disk Usage:"
df -h /

echo
echo "================================="
echo "Health Check Completed"
echo "================================="

echo
echo "Load Average:"
uptime

echo "Installing net-tools..."

yum install net-tools -y

if rpm -q net-tools >/dev/null 2>&1; then
    echo "net-tools is installed successfully."
else
    echo "net-tools installation failed."
fi


#!/bin/bash

echo "================================="
echo "     Samba Installation Script"
echo "================================="

# Check root user
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Install Samba based on package manager
if command -v yum >/dev/null 2>&1; then

    echo "YUM detected."
    echo "Installing Samba..."

    yum install -y samba samba-client samba-common

    if [ $? -eq 0 ]; then
        echo "Samba installation successful."
    else
        echo "Samba installation failed."
        exit 1
    fi

elif command -v dnf >/dev/null 2>&1; then

    echo "DNF detected."
    echo "Installing Samba..."

    dnf install -y samba samba-client samba-common

    if [ $? -eq 0 ]; then
        echo "Samba installation successful."
    else
        echo "Samba installation failed."
        exit 1
    fi

elif command -v apt-get >/dev/null 2>&1; then

    echo "APT detected."
    echo "Updating package repository..."

    apt-get update

    echo "Installing Samba..."

    apt-get install -y samba samba-client

    if [ $? -eq 0 ]; then
        echo "Samba installation successful."
    else
        echo "Samba installation failed."
        exit 1
    fi

else

    echo "Unsupported Linux distribution."
    exit 1

fi

# Start Samba service
echo "Starting Samba service..."

if systemctl list-unit-files | grep -q '^smb.service'; then
    systemctl enable --now smb
elif systemctl list-unit-files | grep -q '^smbd.service'; then
    systemctl enable --now smbd
fi

echo "================================="
echo " Samba installation completed"
echo "================================="

# Show Samba version
smbd --version
=======


#!/bin/bash

# ==========================================
# Linux Server Health Monitor v2
# ==========================================

LOG_DIR="/var/log/server_health"
LOG_FILE="$LOG_DIR/health_$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

# ------------------------------------------
# Logging Function
# ------------------------------------------

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}


echo "=========================================="
echo "       LINUX SERVER HEALTH MONITOR"
echo "=========================================="

log_message "Health check started"

# ------------------------------------------
# Host Information
# ------------------------------------------

echo
echo "HOST INFORMATION"
echo "------------------------------------------"

HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)

echo "Hostname    : $HOSTNAME"
echo "IP Address  : $IP_ADDRESS"
echo "Uptime      : $UPTIME"

log_message "Hostname: $HOSTNAME"
log_message "IP Address: $IP_ADDRESS"
log_message "Uptime: $UPTIME"

# ------------------------------------------
# Load Average
# ------------------------------------------

echo
echo "LOAD AVERAGE"
echo "------------------------------------------"

LOAD_1=$(awk '{print $1}' /proc/loadavg)
LOAD_5=$(awk '{print $2}' /proc/loadavg)
LOAD_15=$(awk '{print $3}' /proc/loadavg)

echo "1 Minute  : $LOAD_1"
echo "5 Minutes : $LOAD_5"
echo "15 Minutes: $LOAD_15"

# ------------------------------------------
# CPU Usage
# ------------------------------------------

echo
echo "CPU USAGE"
echo "------------------------------------------"

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")

echo "CPU Usage: ${CPU_USAGE}%"

# ------------------------------------------
# Memory Usage
# ------------------------------------------

echo
echo "MEMORY USAGE"
echo "------------------------------------------"

MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_FREE=$(free -m | awk '/Mem:/ {print $4}')

MEM_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($MEM_USED/$MEM_TOTAL)*100}")

echo "Total Memory : ${MEM_TOTAL} MB"
echo "Used Memory  : ${MEM_USED} MB"
echo "Free Memory  : ${MEM_FREE} MB"
echo "Usage        : ${MEM_PERCENT}%"

# ------------------------------------------
# Disk Usage
# ------------------------------------------

echo
echo "DISK USAGE"
echo "------------------------------------------"

df -hP | awk 'NR==1 || $5+0 >= 80 {
    print
}'

# ------------------------------------------
# Inode Usage
# ------------------------------------------

echo
echo "INODE USAGE"
echo "------------------------------------------"

df -iP | awk 'NR==1 || $5+0 >= 80 {
    print
}'

# ------------------------------------------
# Important Services
# ------------------------------------------

echo
echo "SERVICE STATUS"
echo "------------------------------------------"

SERVICES=("sshd" "crond")

for SERVICE in "${SERVICES[@]}"
do
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE : RUNNING"
        log_message "$SERVICE is running"
    else
        echo "$SERVICE : NOT RUNNING"
        log_message "$SERVICE is not running"
    fi
done

# ------------------------------------------
# Network Connectivity
# ------------------------------------------

echo
echo "NETWORK CHECK"
echo "------------------------------------------"

if ping -c 2 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "Internet Connectivity : OK"
    log_message "Internet connectivity OK"
else
    echo "Internet Connectivity : FAILED"
    log_message "Internet connectivity FAILED"
fi

# ------------------------------------------
# Important Ports
# ------------------------------------------

echo
echo "LISTENING PORTS"
echo "------------------------------------------"

if command -v ss >/dev/null 2>&1; then
    ss -tuln
elif command -v netstat >/dev/null 2>&1; then
    netstat -tuln
else
    echo "Neither ss nor netstat is available."
fi

echo
echo "=========================================="
echo "       HEALTH CHECK COMPLETED"
echo "=========================================="

log_message "Health check completed"
log_message "Log file: $LOG_FILE"
