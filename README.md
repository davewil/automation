# Automation Tools

A collection of automation tools for development workflow management.

## Project Manager

A comprehensive tool for managing, building, testing, and deploying your projects across different languages and frameworks. Available for both Linux/macOS (Bash/Zsh) and Windows (PowerShell).

### Features

- **Project Management**: Configure projects with GitHub repos, local paths, and project types
- **Multi-Language Support**: Built-in support for Elixir, .NET, Node.js, Go, Python, and Rust
- **Build Automation**: Run build, test, watch, and run commands for each project
- **Smart Push**: Automated workflow that pulls, builds, tests, commits, and pushes changes
- **Quick Navigation**: Open projects instantly with your preferred editor
- **Clone Integration**: Clone repositories using `gh` CLI or standard git
- **Dependency Management**: Check for outdated dependencies and update them
- **Tab Completion**: Full autocompletion for all commands and project names

### Supported Project Types

- **elixir** - Elixir/Phoenix projects using Mix
- **dotnet** - C#/F# projects using .NET CLI
- **node** - JavaScript/TypeScript projects using Bun
- **go** - Go projects
- **python** - Python projects using pytest
- **rust** - Rust projects using Cargo

## Installation

### Linux / macOS (Bash/Zsh)

```bash
cd project-manager
./install.sh
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc for zsh users
```

**Configuration location:** `~/.config/project-manager/projects.json`

### Windows (PowerShell)

```powershell
cd project-manager-ps
.\Install.ps1
```

Then reload your PowerShell session:
```powershell
Import-Module ProjectManager
```

**Configuration location:** `~/.config/project-manager/projects.json`

## Quick Start

### 1. Add a Project

Navigate to an existing git repository and add it:

**Linux/macOS:**
```bash
cd ~/projects/my-project
projects --add
```

**Windows:**
```powershell
cd C:\projects\my-project
Add-Project
```

Or manually edit the configuration file and add your project:

```json
{
  "my-project": {
    "github": "git@github.com:username/my-project.git",
    "local_path": "/home/user/projects/my-project",
    "editor": "code",
    "auto_pull": true,
    "description": "My awesome project",
    "project_type": "node"
  }
}
```

### 2. List Projects

**Linux/macOS:**
```bash
projects
```

**Windows:**
```powershell
projects
# or
Get-ProjectList
```

### 3. Navigate to a Project

**Linux/macOS:**
```bash
goto my-project
```

**Windows:**
```powershell
goto my-project
# or
Set-ProjectLocation my-project
```

### 4. Build, Test, and Run

**Linux/macOS:**
```bash
build my-project
test my-project
run my-project
watch my-project
```

**Windows:**
```powershell
build my-project
test my-project
run my-project
watch my-project
```

### 5. Check for Outdated Dependencies

**Linux/macOS:**
```bash
outdated my-project
```

**Windows:**
```powershell
outdated my-project
# or
Test-ProjectOutdated my-project
```

### 6. Push Changes with Quality Checks

**Linux/macOS:**
```bash
# Interactive mode - prompts to update dependencies
push my-project "Add new feature"

# Auto-update mode - automatically updates dependencies
push my-project "Add new feature" --update
```

**Windows:**
```powershell
# Interactive mode - prompts to update dependencies
push my-project "Add new feature"

# Auto-update mode - automatically updates dependencies
push my-project "Add new feature" -AutoUpdate
```

## Command Reference

### Project Navigation

| Linux/macOS | Windows | Description |
|-------------|---------|-------------|
| `open <project>` | `Open-Project <project>` | Open project in editor |
| `goto <project>` | `goto <project>` | Navigate to project directory |
| `projects` | `projects` | List all projects |
| `projects --clone <name>` | `New-ProjectClone <name>` | Clone a project from GitHub |
| `projects --add` | `Add-Project` | Add current directory as project |
| `projects --edit` | `Edit-ProjectConfig` | Edit configuration file |

### Build & Test

| Linux/macOS | Windows | Description |
|-------------|---------|-------------|
| `build <project>` | `build <project>` | Build the project |
| `test <project>` | `test <project>` | Run tests |
| `run <project>` | `run <project>` | Run the project |
| `watch <project>` | `watch <project>` | Run in watch/hot-reload mode |

### Dependency Management

| Linux/macOS | Windows | Description |
|-------------|---------|-------------|
| `outdated <project>` | `outdated <project>` | Check for outdated dependencies |

### Git Workflow

| Linux/macOS | Windows | Description |
|-------------|---------|-------------|
| `push <project> "msg"` | `push <project> "msg"` | Pull, build, test, commit, push |
| `push <project> "msg" --update` | `push <project> "msg" -AutoUpdate` | Same, with auto dependency updates |

## Configuration

Edit your projects configuration file:

**Linux/macOS:** `~/.config/project-manager/projects.json`
**Windows:** `~/.config/project-manager/projects.json`

Example configuration:

```json
{
  "grocery-planner": {
    "github": "git@github.com:username/grocery-planner.git",
    "local_path": "/home/user/projects/grocery-planner",
    "editor": "code",
    "auto_pull": true,
    "description": "Grocery planning application",
    "project_type": "elixir"
  },
  "api-server": {
    "github": "git@github.com:username/api-server.git",
    "local_path": "/home/user/projects/api-server",
    "editor": "nvim",
    "auto_pull": true,
    "description": "REST API server",
    "project_type": "dotnet",
    "commands": {
      "build": "dotnet build -c Release",
      "test": "dotnet test --no-build",
      "run": "dotnet run --project src/Api"
    }
  }
}
```

### Configuration Options

- **github**: The GitHub SSH or HTTPS clone URL
- **local_path**: Where the project is stored locally
- **editor**: Command to open the editor (`code`, `vim`, `nvim`, `notepad`, etc.)
- **auto_pull**: `true` to automatically pull latest changes, `false` to skip
- **description**: Brief description shown when listing projects
- **project_type**: Type of project (elixir, dotnet, node, go, python, rust)
- **commands**: (Optional) Override default commands for build, test, run, watch

## Smart Push Workflow

The `push` command runs a comprehensive workflow to ensure code quality:

1. **Pull latest changes** from remote
2. **Check for outdated dependencies** (with option to update)
3. **Run build** (if configured)
4. **Run tests** (if configured)
5. **Commit all changes** with your message
6. **Push to remote**

This prevents you from pushing broken code and keeps your dependencies up-to-date!

## Tab Completion

Both versions support full tab completion for all commands and project names.

**Linux/macOS:**
```bash
build <Tab>      # Shows all projects
goto <Tab>       # Shows all projects
outdated <Tab>   # Shows all projects
```

**Windows:**
```powershell
build <Tab>      # Shows all projects
goto <Tab>       # Shows all projects
outdated <Tab>   # Shows all projects
```

## Requirements

### Linux / macOS
- Bash or Zsh shell
- `jq` - JSON processor
  - Ubuntu/Debian: `sudo apt-get install jq`
  - Arch Linux: `sudo pacman -S jq`
  - macOS: `brew install jq`
- `git` - Version control
- `gh` - GitHub CLI (optional, recommended)

### Windows
- PowerShell 5.1 or later
- `git` - Version control
- `gh` - GitHub CLI (optional, recommended)

## Documentation

For detailed documentation, see:
- **Linux/macOS:** [project-manager/README.md](project-manager/README.md) and [project-manager/COMMANDS.md](project-manager/COMMANDS.md)
- **Windows:** [project-manager-ps/README.md](project-manager-ps/README.md) and [project-manager-ps/COMMANDS.md](project-manager-ps/COMMANDS.md)

## Examples

### Complete Workflow Example

```bash
# Add your current project
cd ~/projects/my-awesome-app
projects --add

# Clone a different project
projects --clone my-other-project

# Navigate and work
goto my-awesome-app
build my-awesome-app
test my-awesome-app

# Check dependencies
outdated my-awesome-app

# Run in watch mode while developing
watch my-awesome-app

# Push changes when done
push my-awesome-app "Implement user authentication feature"
```

### Cross-Platform Project Configuration

The same `projects.json` format works on both platforms (just adjust paths):

**Linux/macOS:**
```json
{
  "my-project": {
    "local_path": "/home/user/projects/my-project",
    ...
  }
}
```

**Windows:**
```json
{
  "my-project": {
    "local_path": "C:\\Users\\User\\projects\\my-project",
    ...
  }
}
```

## Contributing

This is a personal automation toolkit, but feel free to fork and adapt for your own needs!

## License

All rights reserved.
