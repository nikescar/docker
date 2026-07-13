#!/bin/bash
# Patch chatmail container to use custom filtermail from nikescar/filtermail
set -e

FILTERMAIL_VERSION="v0.7.5-gcp2"
FILTERMAIL_REPO="nikescar/filtermail"
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        FILTERMAIL_BINARY="filtermail-x86_64"
        ;;
    aarch64)
        FILTERMAIL_BINARY="filtermail-aarch64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/${FILTERMAIL_REPO}/releases/download/${FILTERMAIL_VERSION}/${FILTERMAIL_BINARY}"

echo "=== Patching filtermail to use GCP-compatible version ==="
echo "Architecture: $ARCH"
echo "Download URL: $DOWNLOAD_URL"

# Backup existing filtermail
echo "Backing up existing filtermail..."
if [ -f /usr/local/bin/filtermail ]; then
    cp /usr/local/bin/filtermail /usr/local/bin/filtermail.upstream.bak
fi

# Download new filtermail
echo "Downloading patched filtermail..."
curl -L -o /tmp/filtermail "$DOWNLOAD_URL"
chmod +x /tmp/filtermail

# Verify it's a valid binary
if ! /tmp/filtermail --help >/dev/null 2>&1; then
    echo "Error: Downloaded binary is not valid"
    exit 1
fi

# Install new filtermail
echo "Installing patched filtermail..."
mv /tmp/filtermail /usr/local/bin/filtermail

# Restart services
echo "Restarting filtermail services..."
systemctl restart filtermail-transport
systemctl restart filtermail-incoming
systemctl restart filtermail

echo ""
echo "=== Filtermail patched successfully! ==="
echo ""
echo "Monitor logs with:"
echo "  journalctl -u filtermail-transport -f"
echo ""
echo "Look for: 'Trying SMTP port 587' messages"
