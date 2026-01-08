#!/bin/bash

# idaho.sh - Core bash script for The Danger
# This script builds on the ralph plugin functionality

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the agents file
AGENTS_FILE="${SCRIPT_DIR}/agents/cho-cho-choose.md"

# Check if the agents file exists
if [ ! -f "${AGENTS_FILE}" ]; then
    echo "Error: Agent file not found at ${AGENTS_FILE}"
    exit 1
fi

echo "The Danger - Idaho Script"
echo "========================="
echo ""
echo "Using agent file: ${AGENTS_FILE}"
echo ""

# Read and display the agent file
cat "${AGENTS_FILE}"

echo ""
echo "========================="
echo "Script execution complete."
