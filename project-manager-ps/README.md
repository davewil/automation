# Project Manager - PowerShell Edition

A comprehensive PowerShell module for managing, building, testing, and deploying your projects across different languages and frameworks.

## Features

- **Project Management**: Configure projects with GitHub repos, local paths, and project types
- **Multi-Language Support**: Built-in support for Elixir, .NET, Node.js, Go, Python, and Rust
- **Build Automation**: Run build, test, watch, and run commands for each project
- **Smart Push**: Automated workflow that pulls, builds, tests, commits, and pushes changes
- **Quick Navigation**: Open projects instantly with your preferred editor
- **Clone Integration**: Clone repositories using `gh` CLI or standard git
- **Tab Completion**: Full autocompletion for all commands and project names

## Requirements

- PowerShell 5.1 or later
- Git
- `gh` CLI (optional, recommended for better GitHub integration)

## Installation

```powershell
cd project-manager-ps
.\Install.ps1
```

Then reload your PowerShell session:
```powershell
Import-Module ProjectManager
```

The installer will automatically:
- Copy the module to your PowerShell modules directory
- Create the config directory at `~/.config/project-manager/`
- Add the module import to your PowerShell profile

## Configuration

Edit `~/.config/project-manager/projects.json` to add your projects:

```json
{
  "project_name": {
    "github": "git@github.com:username/repo.git",
    "local_path": "C:\\Users\\YourName\\projects\\project_name",
    "editor": "code",
    "auto_pull": true,
    "description": "Brief description",
    "project_type": "dotnet"
  }
}
```

### Configuration Options

- **github**: The GitHub SSH clone URL for the repository
- **local_path**: Where the project should be stored locally
- **editor**: Command to open the editor (`code`, `vim`, `nvim`, `notepad`, etc.)
- **auto_pull**: `$true` to automatically pull latest changes, `$false` to skip
- **description**: Brief description shown when listing projects
- **project_type**: The type of project - determines build/test/run commands (optional)
  - Supported types: `elixir`, `dotnet`, `node`, `go`, `python`, `rust`

### Project Types

The system comes with predefined commands for common project types:

- **elixir**: Mix commands (mix compile, mix test, mix phx.server)
- **dotnet**: .NET commands (dotnet build, dotnet test, dotnet run)
- **node**: Bun commands (bun run build, bun test, bun run start)
- **go**: Go commands (go build, go test, go run)
- **python**: Python commands (pytest, python main.py)
- **rust**: Cargo commands (cargo build, cargo test, cargo run)

You can customize commands per project by adding a `commands` section:

```json
{
  "my_project": {
    "github": "git@github.com:username/my_project.git",
    "local_path": "C:\\projects\\my_project",
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

### Project Navigation

```powershell
# Open a project
Open-Project grocery_planner

# Navigate to a project without opening editor
Set-ProjectLocation grocery_planner
# or use the alias
goto grocery_planner

# List available projects
Get-ProjectList
# or use the alias
projects

# Clone a project
New-ProjectClone grocery_planner

# Add current directory as a project
cd C:\projects\my-project
Add-Project

# Edit projects configuration
Edit-ProjectConfig
```

### Build, Test, and Run Commands

```powershell
# Build a project
Invoke-ProjectBuild grocery_planner
# or use the alias
build grocery_planner

# Test a project
Invoke-ProjectTest grocery_planner
# or use the alias
test grocery_planner

# Run a project
Invoke-ProjectRun grocery_planner
# or use the alias
run grocery_planner

# Watch mode
Invoke-ProjectWatch grocery_planner
# or use the alias
watch grocery_planner

# Check for outdated dependencies
Test-ProjectOutdated grocery_planner
# or use the alias
outdated grocery_planner
```

### Push Changes

```powershell
# Interactive mode - prompts to update dependencies
Publish-ProjectChanges grocery_planner "Add new feature"
# or use the alias
push grocery_planner "Add new feature"

# Auto-update mode - automatically updates dependencies without prompting
push grocery_planner "Add new feature" -AutoUpdate
```

Automated workflow that:
1. Pulls latest changes from remote
2. Checks for outdated dependencies (prompts to update)
3. Runs build command (if configured)
4. Runs test command (if configured)
5. Commits all changes with your message
6. Pushes to remote

This ensures you never push broken code!

## Command Reference

### Project Management Functions

| Function | Alias | Description |
|----------|-------|-------------|
| `Get-ProjectList` | `projects` | List all configured projects |
| `Open-Project <name>` | - | Open a project in your configured editor |
| `Set-ProjectLocation <name>` | `goto` | Navigate to project directory |
| `Add-Project` | - | Add current directory as a project |
| `New-ProjectClone <name>` | - | Clone a project from GitHub |
| `Edit-ProjectConfig` | - | Edit projects.json configuration |

### Build Automation Functions

| Function | Alias | Description |
|----------|-------|-------------|
| `Invoke-ProjectBuild <name>` | `build` | Run build command |
| `Invoke-ProjectTest <name>` | `test` | Run test command |
| `Invoke-ProjectRun <name>` | `run` | Run start command |
| `Invoke-ProjectWatch <name>` | `watch` | Run in watch/hot-reload mode |
| `Test-ProjectOutdated <name>` | `outdated` | Check for outdated dependencies |
| `Publish-ProjectChanges <name> "msg"` | `push` | Pull, build, test, commit, push |

## Tab Completion

The module includes full tab completion support for all commands and project names. Simply type a command and press Tab to see available options.

```powershell
build <Tab>        # Shows all projects
goto <Tab>         # Shows all projects
Open-Project <Tab> # Shows all projects
```

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

## Differences from Bash Version

This PowerShell version maintains feature parity with the bash version while following PowerShell conventions:

- **Function names**: Use PowerShell verb-noun naming (e.g., `Get-ProjectList` instead of `list_projects`)
- **Aliases**: Provided for bash-like experience (`goto`, `build`, `test`, etc.)
- **Paths**: Uses Windows-style paths (e.g., `C:\Users\...`)
- **Configuration**: Same JSON format, stored in `~/.config/project-manager/`
- **Tab completion**: Built-in PowerShell tab completion support

## Troubleshooting

**Module not found after installation**
- Run: `Import-Module ProjectManager`
- Or restart your PowerShell session

**Project not found**
- Check that the project name matches exactly (case-insensitive in PowerShell)
- Run `Get-ProjectList` to see available projects

**Cannot change to directory**
- Verify the `local_path` in your config is correct
- Check directory permissions

**Git pull fails**
- Check your internet connection
- Verify you have access to the repository
- You may have uncommitted changes preventing the pull

## Customization

### Using a different config file location

Set the `$env:PROJECT_MANAGER_CONFIG` environment variable:

```powershell
$env:PROJECT_MANAGER_CONFIG = "C:\path\to\custom\projects.json"
```

### Editor-specific notes

- **VS Code** (`code`): Opens the directory and returns to shell
- **Terminal editors** (`vim`, `nvim`): Opens in current console
- **Custom editors**: Just specify the command that opens a directory
