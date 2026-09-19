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
