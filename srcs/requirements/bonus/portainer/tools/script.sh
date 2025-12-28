#!/bin/bash
set -e

DATA_DIR="/data"
PORTAINER_DIR="/opt/portainer"
PORTAINER_VERSION="2.19.4"

# Read admin password from Docker secret
if [ -f /run/secrets/portainer_admin_pass ]; then
  PORTAINER_ADMIN_PASS_FILE="/run/secrets/portainer_admin_pass"
else
  echo "Error: Portainer admin password secret not found"
  exit 1
fi

# Create directories
mkdir -p "$DATA_DIR" "$PORTAINER_DIR"

# Download Portainer if not already present
if [ ! -f "$PORTAINER_DIR/portainer" ]; then
    echo "Downloading Portainer CE $PORTAINER_VERSION..."
    wget -O /tmp/portainer.tar.gz \
        "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz"
    
    tar xzf /tmp/portainer.tar.gz -C /tmp
    mv /tmp/portainer/* "$PORTAINER_DIR/"
    rm -rf /tmp/portainer.tar.gz /tmp/portainer
    chmod +x "$PORTAINER_DIR/portainer"
    echo "Portainer downloaded successfully"
fi

# Start Portainer with admin password from Docker secret
# Username will be 'admin' by default
exec "$PORTAINER_DIR/portainer" \
    --data="$DATA_DIR" \
    --tunnel-port=8000 \
    --admin-password-file="$PORTAINER_ADMIN_PASS_FILE"
