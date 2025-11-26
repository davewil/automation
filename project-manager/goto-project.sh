#!/bin/bash

# Goto Project Script
# Usage: goto <project_name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${OPEN_PROJECT_CONFIG:-$HOME/.config/project-manager/projects.json}"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it first:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  Arch: sudo pacman -S jq"
    echo "  macOS: brew install jq"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Function to get project path
get_project_path() {
    local project_name="$1"

    # Check if project exists in config
    if ! jq -e ".[\"$project_name\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "Error: Project '$project_name' not found in configuration"
        echo ""
        echo "Available projects:"
        jq -r 'to_entries[] | "  \(.key) - \(.value.description)"' "$CONFIG_FILE"
        exit 1
    fi

    # Get local path
    local local_path=$(jq -r ".[\"$project_name\"].local_path" "$CONFIG_FILE")

    # Expand ~ to home directory
    local_path="${local_path/#\~/$HOME}"

    # Check if directory exists
    if [ ! -d "$local_path" ]; then
        echo "Error: Project directory not found at $local_path"
        echo "Clone the project first with: projects --clone $project_name"
        exit 1
    fi

    echo "$local_path"
}

# Main logic
if [ -z "$1" ]; then
    echo "Error: No project name provided"
    echo ""
    echo "Usage: goto <project_name>"
    exit 1
fi

get_project_path "$1"
