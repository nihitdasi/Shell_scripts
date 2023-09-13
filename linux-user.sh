#!/bin/bash

# Script should be executed with sudo/root access.
if [[ "${UID}" -ne 0 ]]
then
        echo "Please run with sudo or root."
        exit 1
fi

# User should provide at least one argument as user else guide him.
if [[ $# -lt 1 ]]
then
        echo "Usage: ${0} USER_NAME [COMMENT]..."  # Here ${0} prints the script name.
        echo "Creae a user with name USER_NAME and comments field of COMMENT by providing arguments."
        exit 1
fi
# Store 1st argument as username.
USER_NAME="${1}"

# In case of more than one argument, store it as account comments. (Shift Method)
shift
COMMENT="${@}"

# Create a passwd.
PASSWORD=$(date +%s%N)

# Create the user.
useradd -c  "${COMMENT}" -m $USER_NAME  # -c is comment, -m is home directory.

# Check if the user is successfully created or not.
if [[ $? -ne 0 ]]
then
        echo "The account could not be created."
        exit 1
fi

# Set the passwd for the user.
echo $PASSWORD | passwd --stdin $USER_NAME

# Check if the passwd is successfully set or not.
if [[ $? -ne 0 ]]
then
        echo "Password could not be set"
        exit 1
fi
# Force passwd change on first login.
passwd -e $USER_NAME   # Here, -e means expire the password on first login.

# Display the username, passwd and the host where the user was created.
echo
echo "Username: $USER_NAME"
echo
echo "Password: $PASSWORD"
echo
echo "Hostname: $(hostname)"
