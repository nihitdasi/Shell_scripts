#!/bin/bash

# Script to create a local user on an Ubuntu EC2 instance

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo'."
    exit 1
fi

# Prompt for the new username
read -p "Enter the new username: " new_username

# Check if the username is not empty
if [ -z "$new_username" ]; then
    echo "Username cannot be empty."
    exit 1
fi
# Prompt for the new user's password
read -s -p "Enter the password for $new_username: " new_password
echo

# Check if the password is not empty
if [ -z "$new_password" ]; then
    echo "Password cannot be empty."
    exit 1
fi

# Create the new user
useradd -m "$new_username" -s /bin/bash

# Set the password for the new user
echo "$new_username:$new_password" | chpasswd

# Give the new user sudo privileges
usermod -aG sudo "$new_username"

echo "User '$new_username' has been created with sudo privileges and the provided password."
