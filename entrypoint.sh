#!/bin/bash


# Default values
DEFAULT_ANSIBLE_USERNAME="ansible"
DEFAULT_ANSIBLE_GID=100000
DEFAULT_ANSIBLE_UID=100000
DEFAULT_ANSIBLE_VAULT_PASSWORD=supersecret
SSH_KEY_FILE=/id_rsa
echo "######################"
# Check and assign default values if variables are not defined
if [ -z "$ANSIBLE_USERNAME" ]; then
    ANSIBLE_USERNAME=$DEFAULT_ANSIBLE_USERNAME
    echo "ANSIBLE_USERNAME not defined. Using default: $ANSIBLE_USERNAME"
fi

if [ -z "$ANSIBLE_GID" ]; then
    ANSIBLE_GID=$DEFAULT_ANSIBLE_GID
    echo "ANSIBLE_GID not defined. Using default: $ANSIBLE_GID"
fi

if [ -z "$ANSIBLE_UID" ]; then
    ANSIBLE_UID=$DEFAULT_ANSIBLE_UID
    echo "ANSIBLE_UID not defined. Using default: $ANSIBLE_UID"
fi

if [ -z "$SSH_KEY_FILE" ]; then
    SSH_KEY_FILE="/id_rsa"
    echo "SSH_KEY_FILE not found."
fi

if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    ANSIBLE_VAULT_PASSWORD=$DEFAULT_ANSIBLE_VAULT_PASSWORD
    echo "ANSIBLE_VAULT_PASSWORD not defined. Using default: $ANSIBLE_VAULT_PASSWORD"
fi
echo "######################"

echo "######################"
echo \$ANSIBLE_USERNAME = $ANSIBLE_USERNAME
echo \$ANSIBLE_UID = $ANSIBLE_UID
echo \$ANSIBLE_GID = $ANSIBLE_GID
echo \$SSH_KEY_FILE = $SSH_KEY_FILE
echo "######################"
echo "" 

echo "######################"
echo Définition des variables pour $ANSIBLE_USERNAME
ANSIBLE_HOMEDIR=/opt/$ANSIBLE_USERNAME
echo \$ANSIBLE_HOMEDIR = $ANSIBLE_HOMEDIR
ANSIBLE_BASHRC=$ANSIBLE_HOMEDIR/.bashrc
echo \$ANSIBLE_BASHRC = $ANSIBLE_BASHRC
ANSIBLE_SSHDIR=$ANSIBLE_HOMEDIR/.ssh
echo \$ANSIBLE_SSHDIR = $ANSIBLE_SSHDIR
ANSIBLE_PRIV_KEY=$ANSIBLE_SSHDIR/id_rsa
echo \$ANSIBLE_PRIV_KEY = $ANSIBLE_PRIV_KEY
echo "######################"
echo ""

echo "######################"
# Add group and user creation code (same as before)
groupadd --gid $ANSIBLE_GID $ANSIBLE_USERNAME &&
useradd --uid $ANSIBLE_UID --gid $ANSIBLE_USERNAME --home-dir $ANSIBLE_HOMEDIR= --shell /bin/bash --comment "Ansible Account" $ANSIBLE_USERNAME
echo "######################"
echo ""

echo "######################"
echo "ls /home et ls \$ANSIBLE_HOMEDIR"
ls /home
ls $ANSIBLE_HOMEDIR
echo "######################"
echo ""

# Create or append to the .bashrc file to set up Ansible aliases
touch $ANSIBLE_BASHRC
cat >> $ANSIBLE_BASHRC <<EOF
alias ansible='/opt/ansible/bin/ansible -i /opt/ansible/inventory/hosts.yml'
alias ansible-playbook='/opt/ansible/bin/ansible-playbook -i /opt/ansible/inventory/hosts.yml --vault-password-file=\$ANSIBLE_VAULT_PASSWORD'
EOF

# Check if the key file exists
if [ -f "$SSH_KEY_FILE" ]; then
    # Create SSH directory and copy key
    mkdir -p $ANSIBLE_SSHDIR
    cp "$SSH_PRIVATE_KEY" $ANSIBLE_SSHDIR/id_rsa
    chmod 600 $ANSIBLE_SSHDIR/id_rsa
    chown "$ANSIBLE_USERNAME":"$ANSIBLE_USERNAME" $ANSIBLE_HOMEDIR -R

    # Start the SSH agent
    runuser -l "$ANSIBLE_USERNAME" -c $ANSIBLE_USERNAME eval $(keychain --eval --agents ssh $ANSIBLE_SSH_KEY)

    # Print a message indicating that the key was added to the agent
    echo "SSH private key added to the SSH agent."
else
    echo "SSH private key file not found. Skipping SSH agent setup."
fi


tail -f /dev/null