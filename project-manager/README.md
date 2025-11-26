# Project Manager

A comprehensive shell automation tool for managing, building, testing, and deploying your projects across different languages and frameworks.

## Features

- **Project Management**: Configure projects with GitHub repos, local paths, and project types
- **Multi-Language Support**: Built-in support for Elixir, .NET, Node.js, Go, Python, and Rust
- **Build Automation**: Run build, test, watch, and run commands for each project
- **Smart Push**: Automated workflow that pulls, builds, tests, commits, and pushes changes
- **Quick Navigation**: Open projects instantly with your preferred editor
- **Clone Integration**: Clone repositories using `gh` CLI or standard git
- **Tab Completion**: Full autocompletion for all commands and project names (bash and zsh)

## Installation

```bash
cd project-manager
./install.sh
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc for zsh users
```

The installer will automatically set up tab completion for your shell.

## Configuration

Edit `~/.config/project-manager/projects.json` to add your projects:

```json
{
  "project_name": {
    "github": "git@github.com:username/repo.git",
    "local_path": "/home/user/projects/project_name",
    "editor": "code",
    "auto_pull": true,
    "description": "Brief description",
    "project_type": "elixir"
  }
}
```

### Configuration Options

- **github**: The GitHub SSH clone URL for the repository (format: `git@github.com:username/repo.git`)
- **local_path**: Where the project should be stored locally (supports `~` for home directory)
- **editor**: Command to open the editor (`code`, `vim`, `nvim`, `nano`, `emacs`, etc.)
- **auto_pull**: `true` to automatically pull latest changes, `false` to skip
- **description**: Brief description shown when listing projects
- **project_type**: The type of project - determines build/test/run commands (optional)
  - Supported types: `elixir`, `dotnet`, `node`, `go`, `python`, `rust`

### Project Types

The system comes with predefined commands for common project types:

- **elixir**: Mix commands (mix compile, mix test, mix phx.server)
- **dotnet**: .NET commands (dotnet build, dotnet test, dotnet run)
- **node**: npm commands (npm run build, npm test, npm start)
- **go**: Go commands (go build, go test, go run)
- **python**: Python commands (pytest, python main.py)
- **rust**: Cargo commands (cargo build, cargo test, cargo run)

You can customize commands per project by adding a `commands` section:

```json
{
  "my_project": {
    "github": "git@github.com:username/my_project.git",
    "local_path": "~/projects/my_project",
    "project_type": "node",
    "commands": {
      "build": "pnpm build",
      "test": "pnpm test",
      "run": "pnpm dev"
    }
  }
}
```

## Usage

### Open a project
```bash
open grocery_planner
```

This will:
1. Navigate to the project directory
2. Pull latest changes (if `auto_pull` is `true`)
3. Open with your specified editor
4. Start a new shell in that directory

Note: If the project doesn't exist locally, you'll need to clone it first.

### List available projects
```bash
projects
```

You can also use `open --list` if you prefer.

### Clone a project
```bash
projects --clone grocery_planner
```

This clones the project from GitHub to your configured local path.

- If `gh` CLI is installed, it will use `gh repo clone` for better integration
- Falls back to `git clone` if `gh` is not available
- If the repository doesn't exist, it will suggest creating it with `gh repo create` (if gh CLI is available)

### Edit projects configuration
```bash
projects --edit
```

This opens the projects.json file with your system editor (`$EDITOR` environment variable, defaults to `nvim`).

### Show help
```bash
projects --help
```

## Build, Test, and Run Commands

### Build a project
```bash
build grocery_planner
```

Runs the build command configured for the project type (e.g., `mix compile` for Elixir, `dotnet build` for .NET).

### Test a project
```bash
test grocery_planner
```

Runs the test command for the project (e.g., `mix test`, `cargo test`, `npm test`).

### Run a project
```bash
run grocery_planner
```

Starts the project using the configured run command (e.g., `mix phx.server`, `dotnet run`, `npm start`).

### Watch mode
```bash
watch grocery_planner
```

Runs the project in watch/hot-reload mode (e.g., `mix phx.server`, `dotnet watch run`, `npm run dev`).

### Push changes
```bash
push grocery_planner "Add new feature"
```

Automated workflow that:
1. Pulls latest changes from remote
2. Runs build command (if configured)
3. Runs test command (if configured)
4. Commits all changes with your message
5. Pushes to remote

This ensures you never push broken code!

## Examples

```json
{
  "grocery_planner": {
    "github": "git@github.com:yourusername/grocery_planner.git",
    "local_path": "~/projects/grocery_planner",
    "editor": "code",
    "auto_pull": true,
    "description": "Grocery planning application",
    "project_type": "elixir"
  },
  "dotfiles": {
    "github": "git@github.com:yourusername/dotfiles.git",
    "local_path": "~/dotfiles",
    "editor": "vim",
    "auto_pull": false,
    "description": "My configuration files"
  },
  "api_server": {
    "github": "git@github.com:yourusername/api-server.git",
    "local_path": "~/code/api-server",
    "editor": "code",
    "auto_pull": true,
    "description": "REST API server",
    "project_type": "dotnet"
  },
  "website": {
    "github": "git@github.com:yourusername/website.git",
    "local_path": "~/code/website",
    "editor": "code",
    "auto_pull": true,
    "description": "Personal website",
    "project_type": "node"
  }
}
```

## Requirements

- `jq` - JSON processor
  - Ubuntu/Debian: `sudo apt-get install jq`
  - Arch Linux: `sudo pacman -S jq`
  - macOS: `brew install jq`
- `git` - Version control
- `gh` - GitHub CLI (optional, recommended for better GitHub integration)
  - Ubuntu/Debian: Follow instructions at https://cli.github.com/
  - Arch Linux: `sudo pacman -S github-cli`
  - macOS: `brew install gh`

## Customization

### Using a different config file location

Set the `OPEN_PROJECT_CONFIG` environment variable:

```bash
export OPEN_PROJECT_CONFIG="/path/to/custom/projects.json"
```

### Editor-specific notes

- **VS Code** (`code`): Opens the directory and returns to shell
- **Terminal editors** (`vim`, `nvim`, `nano`, `emacs`): Replaces current shell with editor
- **Custom editors**: Just specify the command that opens a directory

## Troubleshooting

**Error: jq is not installed**
- Install jq using your package manager

**Project not found**
- Check that the project name matches exactly (case-sensitive)
- Run `projects` to see available projects

**Cannot change to directory**
- Verify the `local_path` in your config is correct
- Check directory permissions

**Git pull fails**
- Check your internet connection
- Verify you have access to the repository
- You may have uncommitted changes preventing the pull
