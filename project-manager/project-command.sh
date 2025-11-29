#!/bin/bash

# Project Command Script
# Handles build, test, run, watch, and push commands

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${OPEN_PROJECT_CONFIG:-$HOME/.config/project-manager/projects.json}"
TYPES_FILE="${OPEN_PROJECT_TYPES:-$SCRIPT_DIR/project-types.json}"

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

# Check if types file exists
if [ ! -f "$TYPES_FILE" ]; then
    echo "Error: Project types file not found at $TYPES_FILE"
    exit 1
fi

# Function to get project configuration
get_project_config() {
    local project_name="$1"
    local key="$2"

    jq -r ".[\"$project_name\"].$key // empty" "$CONFIG_FILE"
}

# Function to get project type command
get_type_command() {
    local project_type="$1"
    local command="$2"

    jq -r ".[\"$project_type\"].$command // empty" "$TYPES_FILE"
}

# Function to get command for a project
get_project_command() {
    local project_name="$1"
    local command_type="$2"

    # First check if project has custom command
    local custom_cmd=$(jq -r ".[\"$project_name\"].commands.$command_type // empty" "$CONFIG_FILE")
    if [ -n "$custom_cmd" ]; then
        echo "$custom_cmd"
        return
    fi

    # Otherwise, get from project type
    local project_type=$(get_project_config "$project_name" "project_type")
    if [ -z "$project_type" ]; then
        echo ""
        return
    fi

    get_type_command "$project_type" "$command_type"
}

# Function to run a command for a project
run_project_command() {
    local project_name="$1"
    local command_type="$2"

    # Check if project exists in config
    if ! jq -e ".[\"$project_name\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "Error: Project '$project_name' not found in configuration"
        exit 1
    fi

    # Get local path
    local local_path=$(get_project_config "$project_name" "local_path")
    local_path="${local_path/#\~/$HOME}"

    # Check if directory exists
    if [ ! -d "$local_path" ]; then
        echo "Error: Project directory not found at $local_path"
        echo "Clone the project first with: projects --clone $project_name"
        exit 1
    fi

    # Get command to run
    local cmd=$(get_project_command "$project_name" "$command_type")

    if [ -z "$cmd" ]; then
        local project_type=$(get_project_config "$project_name" "project_type")
        echo "Error: No $command_type command defined for project '$project_name'"
        if [ -n "$project_type" ]; then
            echo "Project type: $project_type"
        else
            echo "No project_type set. Add 'project_type' field to your project configuration."
        fi
        exit 1
    fi

    echo "Running $command_type for $project_name..."
    echo "Command: $cmd"
    echo "Directory: $local_path"
    echo ""

    # Change to project directory and run command
    cd "$local_path" || exit 1
    eval "$cmd"
}

# Function to check for outdated dependencies
check_outdated() {
    local project_name="$1"

    # Check if project exists in config
    if ! jq -e ".[\"$project_name\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "Error: Project '$project_name' not found in configuration"
        exit 1
    fi

    # Get local path
    local local_path=$(get_project_config "$project_name" "local_path")
    local_path="${local_path/#\~/$HOME}"

    # Check if directory exists
    if [ ! -d "$local_path" ]; then
        echo "Error: Project directory not found at $local_path"
        echo "Clone the project first with: projects --clone $project_name"
        exit 1
    fi

    cd "$local_path" || exit 1

    local project_type=$(get_project_config "$project_name" "project_type")

    if [ -z "$project_type" ]; then
        echo "Error: No project type configured for '$project_name'"
        echo "Add 'project_type' field to your project configuration."
        exit 1
    fi

    echo "Checking for outdated dependencies in $project_name..."
    echo ""

    case "$project_type" in
        elixir)
            if [ -f "mix.exs" ]; then
                mix hex.outdated || true
            else
                echo "No mix.exs file found"
            fi
            ;;
        dotnet)
            if command -v dotnet &> /dev/null; then
                dotnet list package --outdated || true
            else
                echo "dotnet command not found"
            fi
            ;;
        node)
            if [ -f "package.json" ]; then
                bun outdated || true
            else
                echo "No package.json file found"
            fi
            ;;
        go)
            if [ -f "go.mod" ]; then
                go list -u -m all 2>/dev/null | grep '\[' || echo "All dependencies up to date"
            else
                echo "No go.mod file found"
            fi
            ;;
        python)
            if [ -f "requirements.txt" ]; then
                pip list --outdated || true
            else
                echo "No requirements.txt file found"
            fi
            ;;
        rust)
            if [ -f "Cargo.toml" ]; then
                if command -v cargo-outdated &> /dev/null; then
                    cargo outdated
                else
                    echo "cargo-outdated not installed"
                    echo "Install with: cargo install cargo-outdated"
                fi
            else
                echo "No Cargo.toml file found"
            fi
            ;;
        *)
            echo "Unknown project type: $project_type"
            exit 1
            ;;
    esac
}

# Function to push changes (pull, build, test, commit, push)
push_project() {
    local project_name="$1"
    local commit_message="$2"
    local auto_update="$3"

    if [ -z "$commit_message" ]; then
        echo "Error: Commit message required"
        echo "Usage: push <project_name> \"commit message\" [--update]"
        exit 1
    fi

    # Check if project exists in config
    if ! jq -e ".[\"$project_name\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "Error: Project '$project_name' not found in configuration"
        exit 1
    fi

    # Get local path
    local local_path=$(get_project_config "$project_name" "local_path")
    local_path="${local_path/#\~/$HOME}"

    # Check if directory exists
    if [ ! -d "$local_path" ]; then
        echo "Error: Project directory not found at $local_path"
        exit 1
    fi

    cd "$local_path" || exit 1

    # Check if it's a git repository
    if [ ! -d .git ]; then
        echo "Error: Not a git repository"
        exit 1
    fi

    echo "==> Step 1/7: Staging local changes..."
    # Stage changes first so pull doesn't fail on unstaged files
    git add . || exit 1

    echo ""
    echo "==> Step 2/7: Pulling latest changes..."
    git pull || {
        echo "Error: Failed to pull changes. Please resolve conflicts manually."
        exit 1
    }

    echo ""
    echo "==> Step 3/7: Checking for dependency updates..."
    local deps_cmd=$(get_project_command "$project_name" "deps")
    local project_type=$(get_project_config "$project_name" "project_type")

    if [ -n "$project_type" ]; then
        case "$project_type" in
            elixir)
                if [ -f "mix.exs" ]; then
                    echo "Checking for outdated Elixir dependencies..."
                    mix hex.outdated || true
                fi
                ;;
            dotnet)
                if command -v dotnet &> /dev/null; then
                    echo "Checking for outdated .NET packages..."
                    dotnet list package --outdated || true
                fi
                ;;
            node)
                if [ -f "package.json" ]; then
                    echo "Checking for outdated Node packages..."
                    bun outdated || true
                fi
                ;;
            go)
                if [ -f "go.mod" ]; then
                    echo "Checking for outdated Go modules..."
                    go list -u -m all 2>/dev/null | grep '\[' || echo "All dependencies up to date"
                fi
                ;;
            python)
                if [ -f "requirements.txt" ]; then
                    echo "Checking for outdated Python packages..."
                    pip list --outdated || true
                fi
                ;;
            rust)
                if [ -f "Cargo.toml" ]; then
                    echo "Checking for outdated Rust crates..."
                    cargo outdated || echo "Note: Install cargo-outdated for this feature (cargo install cargo-outdated)"
                fi
                ;;
        esac

        echo ""

        # Check if auto-update flag is set
        if [ "$auto_update" = "--update" ]; then
            if [ -n "$deps_cmd" ]; then
                echo "Auto-updating dependencies..."
                eval "$deps_cmd" || {
                    echo "Warning: Dependency update failed"
                }
            else
                echo "No deps command configured for this project type"
            fi
        else
            read -p "Would you like to update dependencies? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [ -n "$deps_cmd" ]; then
                    echo "Updating dependencies..."
                    eval "$deps_cmd" || {
                        echo "Warning: Dependency update failed"
                    }
                else
                    echo "No deps command configured for this project type"
                fi
            else
                echo "Skipping dependency updates..."
            fi
        fi
    else
        echo "No project type configured, skipping dependency check..."
    fi

    echo ""
    echo "==> Step 4/7: Running build..."
    local build_cmd=$(get_project_command "$project_name" "build")
    if [ -n "$build_cmd" ]; then
        eval "$build_cmd" || {
            echo "Error: Build failed"
            exit 1
        }
    else
        echo "No build command configured, skipping..."
    fi

    echo ""
    echo "==> Step 5/7: Running tests..."
    local test_cmd=$(get_project_command "$project_name" "test")
    if [ -n "$test_cmd" ]; then
        eval "$test_cmd" || {
            echo "Error: Tests failed"
            exit 1
        }
    else
        echo "No test command configured, skipping..."
    fi

    echo ""
    echo "==> Step 6/7: Committing changes..."
    # Changes already staged in step 1

    # Check if there are changes to commit
    if git diff --staged --quiet; then
        echo "No changes to commit"
    else
        git commit -m "$commit_message" || exit 1
    fi

    echo ""
    echo "==> Step 7/7: Pushing to remote..."
    git push || {
        echo "Error: Failed to push changes"
        exit 1
    }

    echo ""
    echo "✓ Successfully pushed $project_name!"
}

# Main logic
COMMAND="$1"
PROJECT="$2"

case "$COMMAND" in
    build|test|run|watch)
        if [ -z "$PROJECT" ]; then
            echo "Error: No project name provided"
            echo "Usage: $COMMAND <project_name>"
            exit 1
        fi
        run_project_command "$PROJECT" "$COMMAND"
        ;;
    outdated)
        if [ -z "$PROJECT" ]; then
            echo "Error: No project name provided"
            echo "Usage: outdated <project_name>"
            exit 1
        fi
        check_outdated "$PROJECT"
        ;;
    push)
        if [ -z "$PROJECT" ]; then
            echo "Error: No project name provided"
            echo "Usage: push <project_name> \"commit message\" [--update]"
            exit 1
        fi
        COMMIT_MSG="$3"
        UPDATE_FLAG="$4"
        push_project "$PROJECT" "$COMMIT_MSG" "$UPDATE_FLAG"
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        echo "Available commands: build, test, run, watch, outdated, push"
        exit 1
        ;;
esac
