#!/bin/bash

echo "Installing Interactive ZIP Brute Force Tool..."

# Make main script executable
chmod +x zipbrute-tool.sh

# Copy to /usr/local/bin
sudo cp zipbrute-tool.sh /usr/local/bin/zipbrute-tool

echo "Installation complete!"
echo "You can now run: zipbrute-tool"
echo "Or directly: ./zipbrute-tool.sh"
