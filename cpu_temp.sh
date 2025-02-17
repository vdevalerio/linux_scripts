#!/bin/bash

# Define the policy (change this to your desired policy)
policy="${1:-package}"  # Default policy is 'package'

# Get temperature data from sensors
temp_data=$(sensors)

get_temperature() {
    case "$policy" in
        adapter)
            # Extract temperature from the adapter (e.g., acpitz)
            echo "$temp_data" | grep 'temp1' | awk '{print $2}' | sed 's/+//'
            ;;
        package)
            # Extract CPU package temperature
            echo "$temp_data" | grep 'Package id 0' | awk '{print $4}' | sed 's/+//'
            ;;
        core*)
            # Extract temperature for a specific core (e.g., core0, core1, etc.)
            core_num=${policy#core}  # Extract core number from policy
            echo "$temp_data" | grep "Core $core_num" | awk '{print $3}' | sed 's/+//'
            ;;
        max)
            # Extract maximum temperature across all cores
            echo "$temp_data" | grep 'Core' | awk '{print $3}' | sed 's/+//' | sort -nr | head -n1
            ;;
        min)
            # Extract minimum temperature across all cores
            echo "$temp_data" | grep 'Core' | awk '{print $3}' | sed 's/+//' | sort -n | head -n1
            ;;
        *)
            echo "Invalid policy. Available policies: adapter, package, coreX, average, max, min"
            exit 1
            ;;
    esac
}

# Get the temperature based on the policy
temp_c=$(get_temperature)

# Output the temperature with 1 decimal place and °C symbol
printf "%.0f°C\n" "$temp_c"
