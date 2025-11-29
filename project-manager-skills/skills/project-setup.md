---
name: project-setup
description: Add a new project to Project Manager using the projects --add command
---

# Project Setup - New Project Setup Wizard

## Description

Guide the user through setting up a new project in the Project Manager system. This skill automates the process of registering a project, detecting its type, and configuring it for use with all Project Manager tools.

## Prerequisites

- User must be in the root directory of the project they want to add
- Project must be a git repository with a remote origin
- Project Manager must be installed (bash/zsh or PowerShell version)
- `jq` must be installed (for bash version)

## Instructions

When this skill is invoked, follow these steps:

### 1. Verify Environment

First, check if the user is in a git repository:

```bash
# Check for .git directory
if [ ! -d .git ]; then
    echo "Error: Not in a git repository. Please run this from the root of a git repository."
    exit 1
fi
```

### 2. Detect Project Information

Gather information about the project:

**Project Name:**
```bash
PROJECT_NAME=$(basename $(pwd))
```

**Git Remote URL:**
```bash
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
```

**Project Type Detection:**
- Check for `mix.exs` → Elixir
- Check for `*.csproj`, `*.fsproj`, `*.sln` → .NET
- Check for `package.json` → Node.js
- Check for `go.mod` → Go
- Check for `requirements.txt`, `setup.py`, `pyproject.toml` → Python
- Check for `Cargo.toml` → Rust

### 3. Prompt for Additional Information

Ask the user:

1. **Description**: "Please provide a brief description of this project:"
   - This will be shown when listing projects

2. **Editor**: "Which editor would you like to use? (default: $EDITOR or nvim)"
   - Common options: `code`, `vim`, `nvim`, `nano`, `emacs`

3. **Auto-pull**: "Should this project auto-pull latest changes when opened? (y/N)"
   - Default to `true` for active projects, `false` for stable ones

### 4. Show Configuration Preview

Display what will be added to the configuration:

```
Project Configuration Preview:
==============================
Name:        <project_name>
Path:        <current_directory>
GitHub:      <remote_url>
Type:        <detected_type>
Description: <user_description>
Editor:      <editor>
Auto-pull:   <true/false>

Is this correct? (Y/n)
```

### 5. Add to Configuration

Run the appropriate command:

**Bash/Zsh:**
```bash
projects --add
```

**PowerShell:**
```powershell
Add-Project
```

### 6. Verify Success

Check that the project was added successfully:

```bash
# List projects and grep for the new one
projects | grep "$PROJECT_NAME"
```

### 7. Suggest Next Steps

Provide personalized next steps based on project type:

**For all projects:**
- "Run `goto <project>` to navigate to the project"
- "Run `open <project>` to open with the smart workflow"

**If project type was detected:**
- "Run `outdated <project>` to check for dependency updates"
- "Run `build <project>` to build the project"
- "Run `test <project>` to run tests"

**If dependencies need installation:**
- Elixir: "Run `mix deps.get` to install dependencies"
- .NET: "Run `dotnet restore` to restore packages"
- Node: "Run `bun install` to install dependencies"
- Go: "Run `go mod download` to download modules"
- Python: "Run `pip install -r requirements.txt` to install packages"
- Rust: "Run `cargo fetch` to fetch dependencies"

### 8. Optional: Run First Build

Ask: "Would you like to run an initial build to verify everything works? (y/N)"

If yes:
```bash
build <project_name>
```

## Context

This skill should be used when:
- A user has cloned a new repository and wants to add it to Project Manager
- A user has created a new project and wants to start using Project Manager tools
- A user wants to onboard an existing project into their workflow

## Example Usage

**Scenario 1: Adding a newly cloned project**
```
User: "I just cloned the grocery-planner repo, help me set it up in project manager"

Claude: I'll help you set up the grocery-planner project. Let me verify we're in a git repository...

[Checks for .git directory]

Great! I can see this is a git repository. Let me gather some information...

I've detected this is an Elixir project (found mix.exs).
- Project name: grocery-planner
- Git remote: git@github.com:user/grocery-planner.git
- Detected type: elixir
- Current path: /home/user/projects/grocery-planner

Please provide a brief description of this project:
> A grocery planning and shopping list application

Which editor would you like to use? (default: code)
> code

Should this project auto-pull latest changes when opened? (y/N)
> y

Configuration Preview:
Name:        grocery-planner
Path:        /home/user/projects/grocery-planner
GitHub:      git@github.com:user/grocery-planner.git
Type:        elixir
Description: A grocery planning and shopping list application
Editor:      code
Auto-pull:   true

Is this correct? (Y/n)
> y

[Runs: projects --add]

✓ Successfully added grocery-planner to Project Manager!

Next steps:
- Run `goto grocery-planner` to navigate to the project
- Run `open grocery-planner` to open with the smart workflow (pull, check deps, build, test)
- Run `mix deps.get` to install Elixir dependencies
- Run `build grocery-planner` to compile the project
- Run `test grocery-planner` to run the test suite

Would you like to run an initial build to verify everything works? (y/N)
> y

[Runs: build grocery-planner]

Build completed successfully! Your project is ready to use.
```

**Scenario 2: Adding an existing project**
```
User: "Set up this project in my project manager"

Claude: I'll help you add this project to Project Manager. Let me check the setup...

[Checks environment, detects project info]

I've detected this is a Node.js project (found package.json).
- Project name: api-server
- Git remote: git@github.com:user/api-server.git
- Detected type: node
- Current path: /home/user/code/api-server

[Continues with prompts...]
```

## Error Handling

Handle these common errors gracefully:

1. **Not in a git repository**
   - Explain that Project Manager requires git repositories
   - Suggest running `git init` and `git remote add origin <url>`

2. **No remote origin**
   - Explain that a remote URL is needed
   - Suggest adding one with `git remote add origin <url>`

3. **Project already exists**
   - Show the existing configuration
   - Ask if they want to update it
   - Provide command to edit: `projects --edit`

4. **Unknown project type**
   - Explain that no project type was auto-detected
   - User can manually add it later by editing config
   - Show supported types: elixir, dotnet, node, go, python, rust

5. **Permission issues**
   - Check if config directory is writable
   - Suggest checking permissions on `~/.config/project-manager/`

## Success Criteria

The skill is successful when:
- ✓ Project is added to `~/.config/project-manager/projects.json`
- ✓ Configuration is valid JSON
- ✓ User can run `projects` and see the new project listed
- ✓ User understands next steps for working with the project

## Tips

- **Be conversational**: Guide the user through each step
- **Provide context**: Explain why each piece of information is needed
- **Validate input**: Check that paths exist, URLs are valid, etc.
- **Show examples**: Provide example answers for prompts
- **Be helpful**: Suggest good defaults based on detected information
