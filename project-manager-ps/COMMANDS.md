# Project Manager PowerShell - Command Reference

## Project Navigation

### `Open-Project <project>`
Opens a project in your configured editor and navigates to that directory.
```powershell
Open-Project grocery_planner
```

### `Get-ProjectList` (alias: `projects`)
Lists all configured projects.
```powershell
Get-ProjectList
# or
projects
```

### `New-ProjectClone <project>`
Clones a project from GitHub using SSH or gh CLI.
```powershell
New-ProjectClone grocery_planner
```

### `Edit-ProjectConfig`
Opens the projects.json configuration file in your editor.
```powershell
Edit-ProjectConfig
```

### `Add-Project`
Adds the current directory as a project. Must be run from the root of a git repository.
```powershell
cd C:\projects\my-project
Add-Project
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

### `Set-ProjectLocation <project>` (alias: `goto`)
Navigates directly to a project's root directory without opening an editor.
```powershell
Set-ProjectLocation grocery_planner
# or
goto grocery_planner
# Output: Switched to: C:\projects\grocery_planner
```

## Build Commands

### `Invoke-ProjectBuild <project>` (alias: `build`)
Runs the build command for the project based on its type.
```powershell
Invoke-ProjectBuild grocery_planner
# or
build grocery_planner
# For Elixir: runs "mix compile"
# For .NET: runs "dotnet build"
# For Node: runs "bun run build"
```

### `Invoke-ProjectTest <project>` (alias: `test`)
Runs the test suite for the project.
```powershell
Invoke-ProjectTest grocery_planner
# or
test grocery_planner
# For Elixir: runs "mix test"
# For .NET: runs "dotnet test"
# For Node: runs "bun test"
```

### `Invoke-ProjectRun <project>` (alias: `run`)
Starts/runs the project.
```powershell
Invoke-ProjectRun grocery_planner
# or
run grocery_planner
# For Elixir: runs "mix phx.server"
# For .NET: runs "dotnet run"
# For Node: runs "bun run start"
```

### `Invoke-ProjectWatch <project>` (alias: `watch`)
Runs the project in watch/hot-reload mode.
```powershell
Invoke-ProjectWatch grocery_planner
# or
watch grocery_planner
# For Elixir: runs "mix phx.server"
# For .NET: runs "dotnet watch run"
# For Node: runs "bun run dev"
```

## Dependency Management

### `Test-ProjectOutdated <project>` (alias: `outdated`)
Checks for outdated dependencies without making any changes.
```powershell
Test-ProjectOutdated grocery_planner
# or
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

### `Publish-ProjectChanges <project> "commit message" [-AutoUpdate]` (alias: `push`)
Automated push workflow that ensures code quality:
1. Pulls latest changes
2. Checks for outdated dependencies (prompts to update)
3. Runs build (if configured)
4. Runs tests (if configured)
5. Commits all changes
6. Pushes to remote

```powershell
# Interactive mode - prompts to update dependencies
Publish-ProjectChanges grocery_planner "Add user authentication feature"
# or
push grocery_planner "Add user authentication feature"

# Auto-update mode - automatically updates dependencies without prompting
push grocery_planner "Add user authentication feature" -AutoUpdate
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
- Module installation directory contains `project-types.json` - Project type definitions

## Tab Completion

All commands support tab completion for project names:
- `build <Tab>` - Shows all projects
- `test <Tab>` - Shows all projects
- `run <Tab>` - Shows all projects
- `watch <Tab>` - Shows all projects
- `outdated <Tab>` - Shows all projects
- `push <Tab>` - Shows all projects
- `Open-Project <Tab>` - Shows all projects
- `goto <Tab>` - Shows all projects

## Examples

```powershell
# Navigate to a project and open editor
Open-Project grocery_planner

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
push grocery_planner "Fix authentication bug" -AutoUpdate

# Clone a new project
New-ProjectClone my-new-project

# Add current directory as a project
cd C:\projects\my-project
Add-Project

# View all projects
projects

# Edit configuration
Edit-ProjectConfig
```

## PowerShell-Specific Features

### Pipeline Support

Many functions support PowerShell pipeline:

```powershell
# Get all projects and filter
Get-ProjectConfig | Select-Object -ExpandProperty PSObject.Properties | Where-Object { $_.Value.project_type -eq 'dotnet' }
```

### Parameter Validation

Tab completion works with parameter names:

```powershell
Publish-ProjectChanges -ProjectName <Tab> -CommitMessage "message" -AutoUpdate
```

### Help System

Access built-in help for any function:

```powershell
Get-Help Open-Project -Full
Get-Help Publish-ProjectChanges -Examples
```
