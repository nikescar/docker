#!/bin/bash
# Apply filtermail GCP patch to running container
set -e

CONTAINER_NAME="chatmail"

echo "=== Applying filtermail GCP patch to $CONTAINER_NAME ==="

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: Container $CONTAINER_NAME is not running"
    exit 1
fi

# Copy patch script into container
echo "Copying patch script to container..."
docker cp scripts/patch-filtermail-gcp.sh $CONTAINER_NAME:/tmp/

# Execute patch script
echo "Executing patch script..."
docker exec $CONTAINER_NAME bash /tmp/patch-filtermail-gcp.sh

echo ""
echo "=== Patch applied successfully! ==="
echo ""
echo "Test by sending an email and monitoring logs:"
echo "  docker exec $CONTAINER_NAME journalctl -u filtermail-transport -f"
echo ""
echo "You should see: 'Trying SMTP port 587 for <hostname>'"
