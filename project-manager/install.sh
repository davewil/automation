#!/bin/bash

# Installation script for Project Manager

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/project-manager"
SHELL_RC=""

echo "Project Manager Installation"
echo "============================"
echo ""

# Detect shell
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
else
    echo "Detected shell: $SHELL"
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
        SHELL_NAME="zsh"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="bash"
    else
        echo "Warning: Unsupported shell. Manual setup may be required."
        SHELL_RC="$HOME/.profile"
        SHELL_NAME="unknown"
    fi
fi

echo "Detected shell: $SHELL_NAME"
echo "Shell RC file: $SHELL_RC"
echo ""

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
fi

# Create config directory
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating $CONFIG_DIR..."
    mkdir -p "$CONFIG_DIR"
fi

# Copy scripts
echo "Installing scripts to $INSTALL_DIR..."
cp "$SCRIPT_DIR/open-project.sh" "$INSTALL_DIR/open-project"
cp "$SCRIPT_DIR/project-command.sh" "$INSTALL_DIR/project-command"
cp "$SCRIPT_DIR/goto-project.sh" "$INSTALL_DIR/goto-project"
chmod +x "$INSTALL_DIR/open-project"
chmod +x "$INSTALL_DIR/project-command"
chmod +x "$INSTALL_DIR/goto-project"

# Copy config files
if [ ! -f "$CONFIG_DIR/projects.json" ]; then
    echo "Installing default configuration to $CONFIG_DIR/projects.json..."
    cp "$SCRIPT_DIR/projects.json" "$CONFIG_DIR/projects.json"
    echo "Please edit $CONFIG_DIR/projects.json to add your projects"
else
    echo "Configuration already exists at $CONFIG_DIR/projects.json (not overwriting)"
fi

# Copy project types file
echo "Installing project types to $CONFIG_DIR/project-types.json..."
cp "$SCRIPT_DIR/project-types.json" "$CONFIG_DIR/project-types.json"

# Install completions
echo "Installing shell completions..."
if [ "$SHELL_NAME" = "zsh" ]; then
    # Install zsh completion
    mkdir -p "$HOME/.zsh/completion"
    cp "$SCRIPT_DIR/completions.zsh" "$HOME/.zsh/completion/_projects"
    echo "Zsh completions installed to ~/.zsh/completion/"
elif [ "$SHELL_NAME" = "bash" ]; then
    # Install bash completion
    mkdir -p "$HOME/.bash_completion.d"
    cp "$SCRIPT_DIR/completions.sh" "$HOME/.bash_completion.d/projects"
    echo "Bash completions installed to ~/.bash_completion.d/"
fi

# Create shell function based on shell type
if [ "$SHELL_NAME" = "zsh" ]; then
    FUNCTION_CODE="
# Project Manager - Quick project navigation
export OPEN_PROJECT_CONFIG=\"$CONFIG_DIR/projects.json\"
export OPEN_PROJECT_TYPES=\"$CONFIG_DIR/project-types.json\"

# Add completion directory to fpath
fpath=(\$HOME/.zsh/completion \$fpath)
autoload -Uz compinit && compinit

open() {
    $INSTALL_DIR/open-project \"\$@\"
}

projects() {
    if [ \"\$1\" = \"--help\" ] || [ \"\$1\" = \"-h\" ]; then
        $INSTALL_DIR/open-project --help
    elif [ \"\$1\" = \"--edit\" ] || [ \"\$1\" = \"-e\" ]; then
        \${EDITOR:-nvim} \"\$OPEN_PROJECT_CONFIG\"
    elif [ \"\$1\" = \"--clone\" ] || [ \"\$1\" = \"-c\" ]; then
        $INSTALL_DIR/open-project --clone \"\$2\"
    elif [ \"\$1\" = \"--add\" ] || [ \"\$1\" = \"-a\" ]; then
        $INSTALL_DIR/open-project --add
    else
        $INSTALL_DIR/open-project --list
    fi
}

build() {
    $INSTALL_DIR/project-command build \"\$@\"
}

test() {
    $INSTALL_DIR/project-command test \"\$@\"
}

run() {
    $INSTALL_DIR/project-command run \"\$@\"
}

watch() {
    $INSTALL_DIR/project-command watch \"\$@\"
}

push() {
    $INSTALL_DIR/project-command push \"\$@\"
}

outdated() {
    $INSTALL_DIR/project-command outdated \"\$@\"
}

goto() {
    local project_path=\$($INSTALL_DIR/goto-project \"\$1\")
    if [ \$? -eq 0 ]; then
        cd \"\$project_path\" || return 1
        echo \"Switched to: \$(pwd)\"
    fi
}
"
else
    FUNCTION_CODE="
# Project Manager - Quick project navigation
export OPEN_PROJECT_CONFIG=\"$CONFIG_DIR/projects.json\"
export OPEN_PROJECT_TYPES=\"$CONFIG_DIR/project-types.json\"

# Source bash completions
if [ -f \$HOME/.bash_completion.d/projects ]; then
    source \$HOME/.bash_completion.d/projects
fi

open() {
    $INSTALL_DIR/open-project \"\$@\"
}

projects() {
    if [ \"\$1\" = \"--help\" ] || [ \"\$1\" = \"-h\" ]; then
        $INSTALL_DIR/open-project --help
    elif [ \"\$1\" = \"--edit\" ] || [ \"\$1\" = \"-e\" ]; then
        \${EDITOR:-nvim} \"\$OPEN_PROJECT_CONFIG\"
    elif [ \"\$1\" = \"--clone\" ] || [ \"\$1\" = \"-c\" ]; then
        $INSTALL_DIR/open-project --clone \"\$2\"
    elif [ \"\$1\" = \"--add\" ] || [ \"\$1\" = \"-a\" ]; then
        $INSTALL_DIR/open-project --add
    else
        $INSTALL_DIR/open-project --list
    fi
}

build() {
    $INSTALL_DIR/project-command build \"\$@\"
}

test() {
    $INSTALL_DIR/project-command test \"\$@\"
}

run() {
    $INSTALL_DIR/project-command run \"\$@\"
}

watch() {
    $INSTALL_DIR/project-command watch \"\$@\"
}

push() {
    $INSTALL_DIR/project-command push \"\$@\"
}

outdated() {
    $INSTALL_DIR/project-command outdated \"\$@\"
}

goto() {
    local project_path=\$($INSTALL_DIR/goto-project \"\$1\")
    if [ \$? -eq 0 ]; then
        cd \"\$project_path\" || return 1
        echo \"Switched to: \$(pwd)\"
    fi
}
"
fi

# Check if function is already in shell RC
if grep -q "# Project Manager - Quick project navigation" "$SHELL_RC" 2>/dev/null; then
    echo ""
    echo "Shell function already exists in $SHELL_RC (not adding again)"
else
    echo ""
    echo "Adding 'open' function to $SHELL_RC..."
    echo "$FUNCTION_CODE" >> "$SHELL_RC"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Warning: $INSTALL_DIR is not in your PATH"
    echo "Adding it to $SHELL_RC..."

    PATH_CODE="
# Add ~/.local/bin to PATH
export PATH=\"\$HOME/.local/bin:\$PATH\"
"
    if ! grep -q "Add ~/.local/bin to PATH" "$SHELL_RC" 2>/dev/null; then
        echo "$PATH_CODE" >> "$SHELL_RC"
    fi
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit your projects: $CONFIG_DIR/projects.json"
echo "  2. Reload your shell: source $SHELL_RC"
echo "  3. Try it out: open grocery_planner"
echo ""
echo "Usage:"
echo "  open <project_name>      - Open a project"
echo "  projects                 - List all projects"
echo "  projects --clone <name>  - Clone a project from GitHub"
echo "  projects --edit          - Edit projects configuration"
echo "  projects --help          - Show help"
