#!/bin/bash

# Set default values if not provided
USERNAME=${USERNAME:-ansible}
PASSWORD=${PASSWORD:-${USERNAME}}
ROOTPASS=${ROOTPASS:-toor}


# Ensure the script runs as root
if [ "${EUID}" -ne 0 ]
then
    echo "This script must be run as root. Exiting."
    exit 1
fi

# Check if the user already exists
if ! id "${USERNAME}" &>/dev/null
then
    echo "Creating user: ${USERNAME}"
    useradd -ms /bin/bash "${USERNAME}" || adduser -D -s /bin/bash "${USERNAME}"
    echo "${USERNAME}:${PASSWORD}" | chpasswd
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

    # Setup SSH key for ansible user
    mkdir -p "/home/${USERNAME}/.ssh"
    ssh-keygen -t rsa -b 4096 -N "" -f "/home/${USERNAME}/.ssh/id_rsa"
    chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.ssh"
    chmod 700 "/home/${USERNAME}/.ssh"
    chmod 600 "/home/${USERNAME}/.ssh/authorized_keys"
else
    echo "User ${USERNAME} already exists, skipping creation."
fi

# Set root password
echo "root:${ROOTPASS}" | chpasswd

# Ensure SSH is running
echo "Starting SSH..."
exec /usr/sbin/sshd -D
