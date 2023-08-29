#!/bin/bash



# Set the generic vault password from environment variable
export ANSIBLE_VAULT_PASSWORD=$VAULT_PASSWORD


# Add group and user creation code (same as before)
groupadd --gid $ANSIBLE_GID $ANSIBLE_USERNAME && \
useradd --uid $ANSIBLE_UID --gid $ANSIBLE_USERNAME --home-dir $ANSIBLE_HOMEDIR --shell /bin/bash --comment "Ansible Account" $ANSIBLE_USERNAME


# Clone the Git repository initially
git clone $REPO_URL $ANSIBLE_HOMEDIR

# Create a cron job file for git pull
CRON_FILE="/etc/cron.d/git"
echo "*/$GIT_CLONE_DELAY * * * * root cd $ANSIBLE_HOMEDIR && git pull" > "$CRON_FILE"
chmod 0644 "$CRON_FILE"



# Add SSH private key to the agent
SSH_KEY_FILE="$ANSIBLE_HOMEDIR/id_rsa"  # Path to the SSH private key file

# Check if the key file exists
if [ -f "$SSH_KEY_FILE" ]; then
    # Make sure the SSH directory and key file have the correct permissions
    chmod 700 "$ANSIBLE_HOMEDIR/.ssh"
    chmod 600 "$SSH_KEY_FILE"

    # Start the SSH agent
    eval $(ssh-agent -s)
    
    # Add the SSH private key to the agent
    ssh-add "$SSH_KEY_FILE"

    # Print a message indicating that the key was added to the agent
    echo "SSH private key added to the SSH agent."
else
    echo "SSH private key file not found. Skipping SSH agent setup."
fi


# Start 
cron && tail -f /dev/null