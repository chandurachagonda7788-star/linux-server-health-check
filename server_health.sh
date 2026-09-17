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
top -bn1 | grep "Cpu(s)" | awk '{print "CPU Used: " $2 "%"}'

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
