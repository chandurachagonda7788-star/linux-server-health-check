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
