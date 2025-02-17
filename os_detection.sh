#!/bin/bash

# Function to capitalize the first letter of a word
capitalize() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}'
}

# Detect OS information
if command -v lsb_release >/dev/null 2>&1; then
    OS_NAME=$(lsb_release -si)           # Get distribution name
    OS_VERSION=$(lsb_release -sr)        # Get version number
    OS_CODENAME=$(lsb_release -sc)       # Get codename
elif [[ -f /etc/os-release ]]; then
    # Read from os-release file (works on most modern distros)
    source /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
    OS_CODENAME=${VERSION_CODENAME:-$(echo "$VERSION" | awk '{print $NF}')}
elif [[ -f /etc/debian_version ]]; then
    OS_NAME="Debian"
    OS_VERSION=$(cat /etc/debian_version)
    OS_CODENAME=$(awk '{print $NF}' /etc/os-release)
elif [[ -f /etc/redhat-release ]]; then
    OS_NAME=$(awk '{print $1}' /etc/redhat-release)
    OS_VERSION=$(awk '{print $3}' /etc/redhat-release)
    OS_CODENAME=""
elif [[ -f /etc/arch-release ]]; then
    OS_NAME="Arch Linux"
    OS_VERSION=""
    OS_CODENAME=""
else
    OS_NAME="Unknown"
    OS_VERSION=""
    OS_CODENAME=""
fi

# Format output
OS_NAME=$(capitalize "$OS_NAME")
OS_CODENAME=$(capitalize "$OS_CODENAME")

# Print formatted output
if [[ -n "$OS_CODENAME" && "$OS_CODENAME" != "N/a" ]]; then
    echo "$OS_NAME $OS_VERSION $OS_CODENAME"
else
    echo "$OS_NAME $OS_VERSION"
fi
