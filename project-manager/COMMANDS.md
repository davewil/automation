# Project Manager - Command Reference

## Project Navigation

### `open <project>`
Opens a project in your configured editor and starts a shell in that directory.
```bash
open grocery_planner
```

### `projects`
Lists all configured projects.
```bash
projects
```

### `projects --clone <project>`
Clones a project from GitHub using SSH or gh CLI.
```bash
projects --clone grocery_planner
```

### `projects --edit`
Opens the projects.json configuration file in your editor.
```bash
projects --edit
```

### `projects --add`
Adds the current directory as a project. Must be run from the root of a git repository.
```bash
cd /path/to/my-project
projects --add
# Detects project type automatically
# Prompts for description
# Adds to projects.json
```

Auto-detects project type based on files present:
- **mix.exs** → elixir
- **\*.csproj, \*.fsproj, \*.sln** → dotnet
- **package.json** → node
- **go.mod** → go
- **requirements.txt, setup.py, pyproject.toml** → python
- **Cargo.toml** → rust

### `goto <project>`
Navigates directly to a project's root directory without opening an editor.
```bash
goto grocery_planner
# Output: Switched to: /home/user/projects/grocery_planner
```

## Build Commands

### `build <project>`
Runs the build command for the project based on its type.
```bash
build grocery_planner
# For Elixir: runs "mix compile"
# For .NET: runs "dotnet build"
# For Node: runs "bun run build"
```

### `test <project>`
Runs the test suite for the project.
```bash
test grocery_planner
# For Elixir: runs "mix test"
# For .NET: runs "dotnet test"
# For Node: runs "bun test"
```

### `run <project>`
Starts/runs the project.
```bash
run grocery_planner
# For Elixir: runs "mix phx.server"
# For .NET: runs "dotnet run"
# For Node: runs "bun run start"
```

### `watch <project>`
Runs the project in watch/hot-reload mode.
```bash
watch grocery_planner
# For Elixir: runs "mix phx.server"
# For .NET: runs "dotnet watch run"
# For Node: runs "bun run dev"
```

## Dependency Management

### `outdated <project>`
Checks for outdated dependencies without making any changes.
```bash
outdated grocery_planner
# For Elixir: runs "mix hex.outdated"
# For .NET: runs "dotnet list package --outdated"
# For Node: runs "bun outdated"
# For Go: runs "go list -u -m all"
# For Python: runs "pip list --outdated"
# For Rust: runs "cargo outdated"
```

This is a read-only command that reports available updates without modifying your project.

## Git Workflow

### `push <project> "commit message" [--update]`
Automated push workflow that ensures code quality:
1. Pulls latest changes
2. Checks for outdated dependencies (prompts to update)
3. Runs build (if configured)
4. Runs tests (if configured)
5. Commits all changes
6. Pushes to remote

```bash
# Interactive mode - prompts to update dependencies
push grocery_planner "Add user authentication feature"

# Auto-update mode - automatically updates dependencies without prompting
push grocery_planner "Add user authentication feature" --update
```

This prevents you from pushing broken code and keeps dependencies up-to-date!

## Supported Project Types

- **elixir** - Elixir/Phoenix projects using Mix
- **dotnet** - C#/F# projects using .NET CLI
- **node** - JavaScript/TypeScript projects using Bun
- **go** - Go projects
- **python** - Python projects using pytest
- **rust** - Rust projects using Cargo

## Configuration Files

- `~/.config/project-manager/projects.json` - Your projects
- `~/.config/project-manager/project-types.json` - Project type definitions
- `~/.local/bin/open-project` - Project navigation script
- `~/.local/bin/project-command` - Build/test/run script
- `~/.local/bin/goto-project` - Quick navigation script

## Tab Completion

All commands support tab completion for project names:
- `build <TAB>` - Shows all projects
- `test <TAB>` - Shows all projects
- `run <TAB>` - Shows all projects
- `watch <TAB>` - Shows all projects
- `outdated <TAB>` - Shows all projects
- `push <TAB>` - Shows all projects
- `open <TAB>` - Shows all projects
- `goto <TAB>` - Shows all projects

## Examples

```bash
# Navigate to a project and open editor
open grocery_planner

# Navigate to a project without opening editor
goto grocery_planner

# Build a project
build grocery_planner

# Run tests
test grocery_planner

# Start the server in watch mode
watch grocery_planner

# Check for outdated dependencies
outdated grocery_planner

# Push changes (with quality checks and dependency prompt)
push grocery_planner "Fix authentication bug"

# Push changes with automatic dependency updates
push grocery_planner "Fix authentication bug" --update

# Clone a new project
projects --clone my-new-project

# Add current directory as a project
cd /path/to/my-project
projects --add

# View all projects
projects

# Edit configuration
projects --edit
```
