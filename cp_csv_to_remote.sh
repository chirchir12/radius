#!/bin/bash

source ./export_env.sh

# Check if SERVER_IP environment variable is set
if [ -z "$SERVER_IP" ]; then
    echo "Error: SERVER_IP environment variable is not set"
    exit 1
fi

# Source directory
SOURCE_DIR="$HOME/work/diralink_systems/migrations/radius"

# Remote directory
REMOTE_DIR="/tmp/radius"

# SSH key path
SSH_KEY="$HOME/.ssh/netcup"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found at $SSH_KEY"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Create remote directory if it doesn't exist
ssh -i "$SSH_KEY" "$SERVER_IP" "mkdir -p $REMOTE_DIR"

# Copy all CSV files from source to remote directory
scp -i "$SSH_KEY" "$SOURCE_DIR"/*.csv "$SERVER_IP:$REMOTE_DIR/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "Files successfully copied to $SERVER_IP:$REMOTE_DIR/"
else
    echo "Error: Failed to copy files"
    exit 1
fi
