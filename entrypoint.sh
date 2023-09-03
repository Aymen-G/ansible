#!/bin/bash

# Function to display error messages and exit
function display_error {
    echo "ERROR: $1"
}

# Default values
DEFAULT_ANSIBLE_USERNAME="ansible"
DEFAULT_ANSIBLE_VAULT_PASSWORD=supersecret

# Check if required environment variables are set
echo "######################"
echo "Checking docker environement values:"
[ -n "$ANSIBLE_VAULT_PASSWORD" ] || display_error "ANSIBLE_VAULT_PASSWORD is not set, Using default: $DEFAULT_ANSIBLE_VAULT_PASSWORD" || ANSIBLE_GID=$DEFAULT_ANSIBLE_VAULT_PASSWORD
[ -n "$ANSIBLE_USERNAME" ] ||  display_error "ANSIBLE_USERNAME is not set, Using default: $DEFAULT_ANSIBLE_USERNAME"  || ANSIBLE_USERNAME=$DEFAULT_ANSIBLE_USERNAME
if [ -e /id_rsa ]; then
    ANSIBLE_PRIV_KEY="/id_rsa"
    echo \$ANSIBLE_USERNAME = $ANSIBLE_USERNAME
    echo \$ANSIBLE_PRIV_KEY = $ANSIBLE_PRIV_KEY
    echo \$ANSIBLE_VAULT_PASSWORD = $ANSIBLE_VAULT_PASSWORD
else
    display_error "/id_rsa not found, deleting private_key_file arg in /etc/ansible/ansible.cfg"
    sed -i '/^private_key_file/d' /etc/ansible/ansible.cfg
fi
echo "######################"

echo ""

# Configuration Ansible
if [ -f /etc/ansible/ansible.cfg ]; then
    sed -i "s#^remote_user = .*#remote_user = $ANSIBLE_USERNAME#" /etc/ansible/ansible.cfg
    sed -i "s#^private_key_file = .*#private_key_file = $ANSIBLE_PRIV_KEY#" /etc/ansible/ansible.cfg
    echo "$ANSIBLE_VAULT_PASSWORD" > /etc/ansible/.vault_password
fi

echo "######################"
echo "ansible.cfg:"

cat /etc/ansible/ansible.cfg 

echo ""

tail -f /dev/null