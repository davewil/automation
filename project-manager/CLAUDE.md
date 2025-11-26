# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A shell-based automation tool for managing development projects across multiple languages and frameworks. Provides unified commands for building, testing, running, and deploying projects regardless of the underlying technology stack.

## Core Architecture

The system consists of two main shell scripts:

1. **open-project.sh** - Project navigation and cloning
   - Handles project opening, listing, and GitHub cloning
   - Manages auto-pull functionality
   - Opens configured editor in project directory

2. **project-command.sh** - Build automation
   - Dispatches build/test/run/watch/push commands
   - Resolves commands through project type system
   - Implements smart push workflow (pull → build → test → commit → push)

### Configuration System

Projects are configured in `~/.config/project-manager/projects.json` with the schema:

```json
{
  "project_name": {
    "github": "git@github.com:user/repo.git",
    "local_path": "/path/to/project",
    "editor": "code|vim|nvim|...",
    "auto_pull": true|false,
    "description": "Brief description",
    "project_type": "elixir|dotnet|node|go|python|rust",
    "commands": {
      "build": "custom build command",
      "test": "custom test command",
      "run": "custom run command"
    }
  }
}
```

Project types defined in `project-types.json` provide default commands for common language ecosystems. Custom `commands` in project config override type defaults.

## Command Reference

### Testing Commands
```bash
# Run in project directory, no need to specify project name
./install.sh        # Install to ~/.local/bin and configure shell
```

### Making Changes to Scripts

When modifying `open-project.sh` or `project-command.sh`:
- Scripts are installed to `~/.local/bin/` with executable permissions
- Config files go to `~/.config/project-manager/`
- Test changes locally before running install
- Users must `source ~/.bashrc` or `source ~/.zshrc` after install

## Key Implementation Details

### Command Resolution Logic
The `get_project_command()` function in project-command.sh:
1. First checks project's custom `commands` field
2. Falls back to project type defaults from project-types.json
3. Returns empty string if neither exists

### Editor Handling
In open-project.sh:
- Terminal editors (vim, nvim, nano, emacs) use `exec` to replace current shell
- GUI editors (code, etc.) run in background and spawn new shell in directory

### Path Expansion
Both scripts expand `~` to `$HOME` using bash substitution: `${local_path/#\~/$HOME}`

### Push Workflow
The `push` command in project-command.sh is atomic - it exits on any failure (pull conflicts, build errors, test failures) to prevent pushing broken code.

## Shell Completion

Completion scripts use `jq` to dynamically read project names from config:
- `completions.sh` - Bash completion
- `completions.zsh` - Zsh completion
- Both installed automatically by install.sh

## Dependencies

Required:
- `jq` - JSON parsing for config files
- `git` - Version control

Optional:
- `gh` - GitHub CLI (enhances clone functionality)
