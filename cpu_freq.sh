#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 [max|min|avg]"
  exit 1
fi

# Get the frequencies of all CPU cores
frequencies=$(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq)

# Convert frequencies to GHz
frequencies_ghz=$(echo "$frequencies" | awk '{print $1/1000000}')

# Calculate based on the argument
case "$1" in
  max)
    result=$(echo "$frequencies_ghz" | sort -nr | head -n1 | awk '{printf "%.2f", $1}')
    echo "$result"
    ;;
  min)
    result=$(echo "$frequencies_ghz" | sort -n | head -n1 | awk '{printf "%.2f", $1}')
    echo "$result"
    ;;
  avg)
    result=$(echo "$frequencies_ghz" | awk '{sum+=$1} END {printf "%.2f", sum/NR}')
    echo "$result"
    ;;
  *)
    echo "Invalid option. Usage: $0 [max|min|avg]"
    exit 1
    ;;
esac
