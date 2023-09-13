#!/bin/bash

# Function to display an error message and exit
display_error() {
    echo "Error: $1"
    exit 1
}

# Check if Node.js is already installed
if command -v node &>/dev/null; then
    echo "Node.js is already installed. Exiting."
    exit 0
fi

# Check if the package manager is available
if ! command -v apt &>/dev/null && ! command -v yum &>/dev/null && ! command -v dnf &>/dev/null; then
    display_error "This script supports Debian/Ubuntu, CentOS/RHEL, and Fedora distributions only."
fi

# Determine the package manager
if command -v apt &>/dev/null; then
    PKG_MANAGER="apt"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
fi

# Ask the user for the Node.js version
read -p "Enter the desired Node.js version (e.g., 14, 16, LTS): " NODE_VERSION

# Install Node.js and npm with the specified version
if [ "$PKG_MANAGER" == "apt" ]; then
    curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
    sudo apt-get install -y nodejs
elif [ "$PKG_MANAGER" == "yum" ]; then
    curl -sL https://rpm.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
    sudo yum install -y nodejs
elif [ "$PKG_MANAGER" == "dnf" ]; then
    curl -sL https://rpm.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
    sudo dnf install -y nodejs
fi

# Check if Node.js and npm were successfully installed
if command -v node &>/dev/null && command -v npm &>/dev/null; then
    echo "Node.js and npm have been successfully installed."
    node -v
    npm -v
else
    display_error "Node.js and/or npm installation failed."
fi
