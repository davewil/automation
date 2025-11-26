#!/bin/bash

# Project Manager Script
# Usage: open <project_name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${OPEN_PROJECT_CONFIG:-$SCRIPT_DIR/projects.json}"

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

# Function to list all projects
list_projects() {
    echo "Available projects:"
    jq -r 'to_entries[] | "  \(.key) - \(.value.description)"' "$CONFIG_FILE"
}

# Function to clone a project
clone_project() {
    local project_name="$1"

    # Check if project exists in config
    if ! jq -e ".[\"$project_name\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "Error: Project '$project_name' not found in configuration"
        echo ""
        list_projects
        exit 1
    fi

    # Read project configuration
    local github_url=$(jq -r ".[\"$project_name\"].github" "$CONFIG_FILE")
    local local_path=$(jq -r ".[\"$project_name\"].local_path" "$CONFIG_FILE")

    # Expand ~ to home directory
    local_path="${local_path/#\~/$HOME}"

    # Check if directory already exists
    if [ -d "$local_path" ]; then
        echo "Error: Project already exists at $local_path"
        exit 1
    fi

    # Extract owner/repo from SSH URL (git@github.com:owner/repo.git)
    local repo_path=$(echo "$github_url" | sed 's/git@github.com://;s/.git$//')

    echo "Cloning $project_name from $github_url..."
    local parent_dir=$(dirname "$local_path")
    mkdir -p "$parent_dir"

    # Use gh CLI if available, otherwise fall back to git
    if command -v gh &> /dev/null; then
        echo "Using gh CLI to clone..."
        gh repo clone "$repo_path" "$local_path" 2>&1 | tee /tmp/git_clone_output.tmp
        local clone_status=${PIPESTATUS[0]}
    else
        git clone "$github_url" "$local_path" 2>&1 | tee /tmp/git_clone_output.tmp
        local clone_status=${PIPESTATUS[0]}
    fi

    if [ $clone_status -ne 0 ]; then
        echo ""
        echo "Error: Failed to clone repository from $github_url"

        # Check if it's a repository not found error
        if grep -q "Repository not found\|Could not read from remote repository\|does not exist\|not found" /tmp/git_clone_output.tmp; then
            echo ""
            echo "The repository was not found on GitHub."

            # Offer to create the repo if gh CLI is available
            if command -v gh &> /dev/null; then
                echo ""
                echo "Would you like to create this repository on GitHub?"
                echo "Run: gh repo create $repo_path --private"
                echo "Or visit: https://github.com/new"
            else
                echo "Please make sure:"
                echo "  1. The repository exists on GitHub"
                echo "  2. You have access to the repository"
                echo "  3. Your SSH key is properly configured with GitHub"
                echo ""
                echo "To create this repository:"
                echo "  Visit: https://github.com/new"
            fi
        fi

        rm -f /tmp/git_clone_output.tmp
        exit 1
    fi
    rm -f /tmp/git_clone_output.tmp

    echo ""
    echo "Successfully cloned $project_name to $local_path"
    echo "You can now open it with: open $project_name"
}

# Function to detect project type
detect_project_type() {
    if [ -f "mix.exs" ]; then
        echo "elixir"
    elif ls *.csproj >/dev/null 2>&1 || ls *.fsproj >/dev/null 2>&1 || ls *.sln >/dev/null 2>&1; then
        echo "dotnet"
    elif [ -f "package.json" ]; then
        echo "node"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo ""
    fi
}

# Function to add current directory as a project
add_project() {
    # Check if we're in a git repository
    if [ ! -d .git ]; then
        echo "Error: Not in a git repository"
        echo "Please run this command from the root of a git repository"
        exit 1
    fi

    # Get current directory path and name
    local current_dir=$(pwd)
    local project_name=$(basename "$current_dir")

    # Get git remote URL
    local github_url=$(git remote get-url origin 2>/dev/null)

    if [ -z "$github_url" ]; then
        echo "Error: No git remote 'origin' found"
        echo "Please add a remote with: git remote add origin <url>"
        exit 1
    fi

    # Check if project already exists in config
    if jq -e ".[\"$project_name\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "Error: Project '$project_name' already exists in configuration"
        echo ""
        echo "Current configuration:"
        jq ".[\"$project_name\"]" "$CONFIG_FILE"
        exit 1
    fi

    # Detect project type
    local project_type=$(detect_project_type)

    if [ -z "$project_type" ]; then
        echo "Warning: Could not automatically detect project type"
        echo "You can manually set it later by editing the configuration"
        echo ""
        echo "Supported types: elixir, dotnet, node, go, python, rust"
    else
        echo "Detected project type: $project_type"
    fi

    # Get default editor from environment or use nvim
    local editor="${EDITOR:-nvim}"

    # Prompt for description
    echo ""
    read -p "Enter project description (optional): " description

    # Build new project entry
    local new_entry=$(jq -n \
        --arg github "$github_url" \
        --arg path "$current_dir" \
        --arg editor "$editor" \
        --arg desc "$description" \
        --arg type "$project_type" \
        '{
            github: $github,
            local_path: $path,
            editor: $editor,
            auto_pull: true,
            description: $desc,
            project_type: $type
        }' | jq 'if .project_type == "" then del(.project_type) else . end')

    # Add to config file
    local temp_file=$(mktemp)
    jq --arg name "$project_name" --argjson entry "$new_entry" \
        '. + {($name): $entry}' "$CONFIG_FILE" > "$temp_file"

    if [ $? -eq 0 ]; then
        mv "$temp_file" "$CONFIG_FILE"
        echo ""
        echo "✓ Successfully added project '$project_name' to configuration"
        echo ""
        echo "Configuration:"
        jq ".[\"$project_name\"]" "$CONFIG_FILE"
        echo ""
        echo "You can now use: open $project_name"
    else
        rm -f "$temp_file"
        echo "Error: Failed to update configuration file"
        exit 1
    fi
}

# Function to open a project
open_project() {
    local project_name="$1"

    # Check if project exists in config
    if ! jq -e ".[\"$project_name\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "Error: Project '$project_name' not found in configuration"
        echo ""
        list_projects
        exit 1
    fi

    # Read project configuration
    local github_url=$(jq -r ".[\"$project_name\"].github" "$CONFIG_FILE")
    local local_path=$(jq -r ".[\"$project_name\"].local_path" "$CONFIG_FILE")
    local editor=$(jq -r ".[\"$project_name\"].editor" "$CONFIG_FILE")
    local auto_pull=$(jq -r ".[\"$project_name\"].auto_pull" "$CONFIG_FILE")

    # Expand ~ to home directory
    local_path="${local_path/#\~/$HOME}"

    echo "Opening project: $project_name"

    # Check if directory exists
    if [ ! -d "$local_path" ]; then
        echo "Error: Project directory not found at $local_path"
        echo ""
        echo "Please clone the repository first using:"
        echo "  projects --clone $project_name"
        exit 1
    fi

    # Change to project directory
    cd "$local_path" || {
        echo "Error: Cannot change to directory $local_path"
        exit 1
    }

    echo "Changed to: $(pwd)"

    # Pull latest changes if auto_pull is enabled
    if [ "$auto_pull" = "true" ]; then
        if [ -d .git ]; then
            echo ""
            echo "==> Step 1/4: Pulling latest changes..."
            git pull

            if [ $? -ne 0 ]; then
                echo "Warning: Failed to pull latest changes"
            fi
        else
            echo "Warning: Not a git repository, skipping pull"
        fi
    fi

    # Get project type for workflow steps
    local project_type=$(jq -r ".[\"$project_name\"].project_type // empty" "$CONFIG_FILE")

    if [ -n "$project_type" ]; then
        # Step 2: Check dependencies
        echo ""
        echo "==> Step 2/4: Checking for dependency updates..."

        TYPES_FILE="${OPEN_PROJECT_TYPES:-$(dirname "$0")/project-types.json}"

        case "$project_type" in
            elixir)
                if [ -f "mix.exs" ]; then
                    mix hex.outdated || true
                fi
                ;;
            dotnet)
                if command -v dotnet &> /dev/null; then
                    dotnet list package --outdated || true
                fi
                ;;
            node)
                if [ -f "package.json" ]; then
                    bun outdated || true
                fi
                ;;
            go)
                if [ -f "go.mod" ]; then
                    go list -u -m all 2>/dev/null | grep '\[' || echo "All dependencies up to date"
                fi
                ;;
            python)
                if [ -f "requirements.txt" ]; then
                    pip list --outdated || true
                fi
                ;;
            rust)
                if [ -f "Cargo.toml" ]; then
                    cargo outdated || echo "Note: Install cargo-outdated for this feature (cargo install cargo-outdated)"
                fi
                ;;
        esac

        # Step 3: Build
        echo ""
        echo "==> Step 3/4: Running build..."
        local build_cmd=$(jq -r ".[\"$project_name\"].commands.build // empty" "$CONFIG_FILE")
        if [ -z "$build_cmd" ]; then
            build_cmd=$(jq -r ".[\"$project_type\"].build // empty" "$TYPES_FILE")
        fi

        if [ -n "$build_cmd" ]; then
            eval "$build_cmd" || {
                echo "Warning: Build failed"
            }
        else
            echo "No build command configured, skipping..."
        fi

        # Step 4: Test
        echo ""
        echo "==> Step 4/4: Running tests..."
        local test_cmd=$(jq -r ".[\"$project_name\"].commands.test // empty" "$CONFIG_FILE")
        if [ -z "$test_cmd" ]; then
            test_cmd=$(jq -r ".[\"$project_type\"].test // empty" "$TYPES_FILE")
        fi

        if [ -n "$test_cmd" ]; then
            eval "$test_cmd" || {
                echo "Warning: Tests failed"
            }
        else
            echo "No test command configured, skipping..."
        fi

        echo ""
        echo "✓ Project ready!"
    fi

    # Open with specified editor
    echo ""
    if [ -n "$editor" ] && [ "$editor" != "null" ]; then
        echo "Opening with $editor..."

        # Handle different editors
        case "$editor" in
            code|"code .")
                code .
                ;;
            vim|nvim|nano|emacs)
                exec $editor .
                ;;
            *)
                $editor .
                ;;
        esac
    fi

    # If we're not exec'ing into an editor, start a new shell in the directory
    if [[ "$editor" != "vim" && "$editor" != "nvim" && "$editor" != "nano" && "$editor" != "emacs" ]]; then
        exec $SHELL
    fi
}

# Main logic
case "${1:-}" in
    --list|-l|list)
        list_projects
        ;;
    --clone|-c|clone)
        if [ -z "$2" ]; then
            echo "Error: No project name provided"
            echo ""
            echo "Usage: projects --clone <project_name>"
            exit 1
        fi
        clone_project "$2"
        ;;
    --add|-a|add)
        add_project
        ;;
    --help|-h|help)
        echo "Project Manager - Quick project navigation and setup"
        echo ""
        echo "Usage:"
        echo "  open <project_name>     Open and setup a project"
        echo "  projects --clone <name> Clone a project from GitHub"
        echo "  projects --add          Add current directory as a project"
        echo "  projects                List all available projects"
        echo "  projects --help         Show this help message"
        echo ""
        echo "Configuration file: $CONFIG_FILE"
        echo "Set OPEN_PROJECT_CONFIG environment variable to use a different config file"
        ;;
    "")
        echo "Error: No project name provided"
        echo ""
        list_projects
        echo ""
        echo "Usage: open <project_name>"
        exit 1
        ;;
    *)
        open_project "$1"
        ;;
esac
