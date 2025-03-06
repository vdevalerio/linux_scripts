#!/bin/bash

# Check if at least one extension is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <extension1> <extension2> ..."
    echo "Example: $0 mbstring xml curl"
    exit 1
fi

# Get all installed PHP versions
php_versions=$(ls /usr/bin/php* | grep -E 'php[0-9]+\.[0-9]+$' | sed 's|/usr/bin/php||')

# Check if any PHP versions are found
if [ -z "$php_versions" ]; then
    echo "No PHP versions found in /usr/bin."
    exit 1
fi

# Loop through each PHP version and install the extensions
for version in $php_versions; do
    echo "Installing extensions for PHP $version..."
    for extension in "$@"; do
        echo " - Installing $extension..."
        sudo apt install php$version-$extension -y
    done
    echo "Done with PHP $version."
    echo "-----------------------------"
done

echo "All extensions installed for all PHP versions."
