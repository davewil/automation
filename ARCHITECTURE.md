# Project Manager - Architecture Documentation

This document explains the design, architecture, and implementation details of the Project Manager automation toolkit.

**Last Updated:** November 27, 2025

---

## Table of Contents

1. [Overview](#overview)
2. [Design Philosophy](#design-philosophy)
3. [System Architecture](#system-architecture)
4. [Component Details](#component-details)
5. [Data Flow](#data-flow)
6. [Configuration System](#configuration-system)
7. [Command Resolution](#command-resolution)
8. [Integration Points](#integration-points)
9. [Design Decisions](#design-decisions)
10. [Future Considerations](#future-considerations)

---

## Overview

### What is Project Manager?

Project Manager is a comprehensive automation toolkit for managing multiple software projects across different languages and frameworks. It consists of four integrated components:

1. **Bash/Zsh CLI** - Command-line tool for Linux/macOS
2. **PowerShell Module** - Windows-native implementation
3. **MCP Server** - AI assistant integration via Model Context Protocol
4. **Claude Skills** - High-level workflow guidance for AI assistants

### Goals

- **Simplify** project management across multiple technologies
- **Automate** repetitive development tasks
- **Standardize** workflows across projects
- **Integrate** with AI assistants for intelligent guidance

### Non-Goals

- Replace build tools (Make, npm scripts, etc.)
- Be a project scaffolding tool
- Manage cloud deployments
- Replace IDEs or text editors

---

## Design Philosophy

### Core Principles

**1. Convention over Configuration**
- Detect project type automatically when possible
- Provide sensible defaults
- Allow customization when needed

**2. Composability**
- Small, focused tools that work together
- Unix philosophy: do one thing well
- Clear interfaces between components

**3. Cross-Platform**
- Same configuration works on Linux, macOS, Windows
- Platform-specific implementations with unified interface
- Leverage native tools (bash, PowerShell, Node.js)

**4. Human-Friendly**
- Simple, memorable commands
- Clear error messages
- Progressive disclosure of complexity

**5. Integration-Friendly**
- JSON configuration for easy parsing
- MCP server for AI integration
- Extensible command system

### Design Patterns

**Configuration-Driven**
- Central JSON configuration defines all projects
- Project types define command templates
- Custom commands override defaults

**Command Pattern**
- Each operation is a discrete command
- Commands can be composed
- Easy to add new commands

**Template Method**
- Project types provide command templates
- Projects can override specific commands
- Fallback to type defaults

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Interface Layer                 │
├─────────────────┬──────────────────┬────────────────────────┤
│  Bash/Zsh CLI   │  PowerShell CLI  │   AI Assistants       │
│  (Linux/macOS)  │    (Windows)     │   (via MCP/Skills)    │
└────────┬────────┴────────┬─────────┴──────────┬─────────────┘
         │                 │                     │
         ▼                 ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     Core Logic Layer                         │
├─────────────────┬──────────────────┬────────────────────────┤
│  Shell Scripts  │  PowerShell Fns  │    MCP Server         │
│  - Navigation   │  - Same Logic    │    - JSON-RPC API     │
│  - Commands     │  - PS Conventions│    - Tool Interface   │
│  - Completion   │  - Module System │                       │
└────────┬────────┴────────┬─────────┴──────────┬─────────────┘
         │                 │                     │
         ▼                 ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  Configuration Layer                         │
├─────────────────────────────────────────────────────────────┤
│  ~/.config/project-manager/                                 │
│  ├── projects.json       (project definitions)              │
│  └── project-types.json  (type templates)                  │
└────────┬────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                     Execution Layer                          │
├─────────────────────────────────────────────────────────────┤
│  Project-Specific Tools:                                    │
│  - mix (Elixir)    - dotnet (.NET)   - bun (Node.js)       │
│  - cargo (Rust)    - go (Go)         - pip (Python)        │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction

```
User Command
    │
    ▼
┌─────────────────┐
│ Shell/PS/MCP    │  Parse command & arguments
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Load Config     │  Read projects.json & project-types.json
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Resolve Command │  Find project-specific or type command
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Execute Command │  Run in project directory
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Display Output  │  Show results to user
└─────────────────┘
```

---

## Component Details

### 1. Bash/Zsh CLI

**File Structure:**
```
project-manager/
├── open-project.sh        # Main navigation logic
├── project-command.sh     # Command execution
├── goto-project.sh        # Directory switching
├── install.sh             # Installation script
├── completion.bash        # Bash completion
├── completion.zsh         # Zsh completion
├── projects.json          # Example configuration
└── project-types.json     # Type definitions
```

**Core Scripts:**

**open-project.sh**
- Purpose: Project navigation and setup
- Responsibilities:
  - Clone repositories
  - Navigate to project directory
  - Open project in editor
  - Run smart workflow (pull, check deps, build, test)
  - Add new projects to configuration

**project-command.sh**
- Purpose: Execute project-specific commands
- Responsibilities:
  - Build projects
  - Run tests
  - Start development servers
  - Check for outdated dependencies
  - Smart push workflow

**goto-project.sh**
- Purpose: Quick directory navigation
- Responsibilities:
  - Resolve project path from config
  - Return path for cd command
  - Handle non-existent projects

**Key Functions:**

```bash
# Configuration loading
load_config() {
    CONFIG="$HOME/.config/project-manager/projects.json"
    PROJECT_TYPES="$HOME/.config/project-manager/project-types.json"
    # Parse JSON with jq
}

# Command resolution
get_project_command() {
    local project_name="$1"
    local command_type="$2"

    # 1. Check project-specific custom command
    custom_cmd=$(jq -r ".\"$project_name\".commands.\"$command_type\"" "$CONFIG")

    # 2. Fall back to project type default
    if [ "$custom_cmd" = "null" ]; then
        project_type=$(jq -r ".\"$project_name\".project_type" "$CONFIG")
        custom_cmd=$(jq -r ".\"$project_type\".\"$command_type\"" "$PROJECT_TYPES")
    fi

    echo "$custom_cmd"
}

# Command execution
execute_command() {
    local project_name="$1"
    local command_type="$2"

    local_path=$(get_project_path "$project_name")
    cd "$local_path" || exit 1

    command=$(get_project_command "$project_name" "$command_type")
    eval "$command"
}
```

**Completion System:**

Bash and Zsh completion scripts provide:
- Command name completion
- Project name completion
- Subcommand completion
- Flag completion

```bash
# Bash completion example
_projects_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local commands="build test run watch push outdated goto open"

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    else
        # Complete project names
        local projects=$(jq -r 'keys[]' ~/.config/project-manager/projects.json)
        COMPREPLY=($(compgen -W "$projects" -- "$cur"))
    fi
}
```

### 2. PowerShell Module

**File Structure:**
```
project-manager-ps/
├── ProjectManager/
│   ├── ProjectManager.psd1   # Module manifest
│   └── ProjectManager.psm1   # Module implementation
├── Install.ps1               # Installation script
├── projects.json             # Example configuration
└── project-types.json        # Type definitions
```

**Module Architecture:**

```powershell
# Module structure
ProjectManager.psm1
├── Configuration Functions
│   ├── Get-ProjectConfig
│   ├── Get-ProjectTypeConfig
│   └── Get-ProjectCommand
│
├── Navigation Functions
│   ├── Set-ProjectLocation (goto)
│   └── Open-Project
│
├── Command Functions
│   ├── Invoke-ProjectBuild
│   ├── Invoke-ProjectTest
│   ├── Invoke-ProjectRun
│   ├── Invoke-ProjectWatch
│   └── Get-ProjectOutdated
│
├── Management Functions
│   ├── Get-Projects
│   ├── Add-Project
│   └── Publish-ProjectChanges (push)
│
└── Utility Functions
    ├── Test-GitRepository
    └── Get-ProjectPath
```

**Key Differences from Bash:**

1. **Naming Conventions:**
   - PowerShell uses Verb-Noun format
   - Approved verbs: Get, Set, New, Remove, Invoke

2. **Parameter Handling:**
   - Strongly typed parameters
   - Built-in validation
   - Parameter sets

3. **Object Pipeline:**
   - Return objects, not strings
   - Rich object properties
   - Pipeline-friendly design

4. **Error Handling:**
   - Try/catch blocks
   - Write-Error for errors
   - Terminating vs non-terminating errors

**Example Function:**

```powershell
function Invoke-ProjectBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ProjectName
    )

    try {
        $project = Get-ProjectConfig -ProjectName $ProjectName
        $buildCommand = Get-ProjectCommand -ProjectName $ProjectName -CommandType "build"

        if (-not $buildCommand) {
            Write-Error "No build command configured for $ProjectName"
            return
        }

        Push-Location $project.local_path
        Write-Host "Building $ProjectName..." -ForegroundColor Cyan

        Invoke-Expression $buildCommand

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build successful" -ForegroundColor Green
        }
        else {
            Write-Error "Build failed with exit code $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}
```

### 3. MCP Server

**File Structure:**
```
project-manager-mcp/
├── src/
│   └── index.ts          # Main server implementation
├── package.json          # Dependencies
├── tsconfig.json         # TypeScript configuration
└── README.md            # Setup instructions
```

**Architecture:**

```typescript
// Server initialization
const server = new Server({
  name: "project-manager",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

// Tool registration
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools: [/* 8 tools */] };
});

// Tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "list_projects":
      return await listProjects();
    case "build_project":
      return await buildProject(args.project_name);
    // ... other tools
  }
});

// Transport
const transport = new StdioServerTransport();
await server.connect(transport);
```

**Available Tools:**

1. **list_projects** - List all configured projects
2. **get_project_info** - Get details about a specific project
3. **build_project** - Build a project
4. **test_project** - Run tests
5. **run_project** - Start development server
6. **check_outdated_dependencies** - Check for outdated packages
7. **get_project_status** - Get git status
8. **execute_custom_command** - Run arbitrary project commands

**Tool Implementation Pattern:**

```typescript
async function buildProject(projectName: string): Promise<ToolResponse> {
  try {
    // 1. Load configuration
    const config = await loadProjectConfig();
    const project = config[projectName];

    if (!project) {
      return {
        content: [{ type: "text", text: `Project not found: ${projectName}` }],
        isError: true
      };
    }

    // 2. Get build command
    const buildCommand = getProjectCommand(project, "build");

    // 3. Execute command
    const output = executeCommand(buildCommand, project.local_path);

    // 4. Return structured response
    return {
      content: [{ type: "text", text: output }]
    };
  }
  catch (error) {
    return {
      content: [{ type: "text", text: `Error: ${error.message}` }],
      isError: true
    };
  }
}
```

**Error Handling:**

- All tools return structured responses
- Errors are returned with `isError: true`
- Error messages are user-friendly
- Stack traces logged server-side

### 4. Claude Skills

**File Structure:**
```
project-manager-skills/
├── skills/
│   ├── project-setup.md
│   ├── project-health-check.md
│   ├── project-workflow.md
│   ├── dependency-manager.md
│   ├── build-fixer.md
│   ├── project-switcher.md
│   ├── project-onboarding.md
│   ├── multi-project-sync.md
│   ├── release-helper.md
│   └── project-cleaner.md
├── examples/
│   ├── setup-new-project.md
│   ├── update-dependencies.md
│   └── monday-morning-sync.md
├── PLAN.md
├── TEST_RESULTS.md
├── PHASE2_TEST_RESULTS.md
├── PHASE3_TEST_RESULTS.md
└── README.md
```

**Skill Structure:**

Every skill follows this template:

```markdown
# Skill Name - Brief Description

## Description
[What the skill does]

## Prerequisites
[Requirements to use this skill]

## Instructions
[Step-by-step workflow for Claude to follow]
[Usually 10-13 steps]

## Context
[When to use this skill]

## Example Usage
[Real-world scenarios with dialogue]

## Error Handling
[Common issues and solutions]

## Success Criteria
[What defines successful completion]

## Tips
[Best practices and recommendations]

## Advanced Features (optional)
[Power user features]
```

**Skill Categories:**

**Phase 1 - Core (3 skills):**
- Setup and onboarding
- Health monitoring
- Development workflow

**Phase 2 - Daily Operations (3 skills):**
- Dependency management
- Build troubleshooting
- Project navigation

**Phase 3 - Team & Maintenance (4 skills):**
- Documentation generation
- Multi-project operations
- Release management
- Cleanup and optimization

**How Skills Work:**

1. AI assistant recognizes user intent
2. Loads appropriate skill markdown
3. Follows instructions step-by-step
4. Uses Project Manager commands
5. Provides guidance and explanations
6. Handles errors gracefully

**Example Skill Flow:**

```
User: "Check and update dependencies for my-project"

AI loads: dependency-manager.md
  ↓
Step 1: Analyze Current Dependencies
  → Runs: outdated my-project
  ↓
Step 2: Categorize by Risk
  → Parses output, categorizes as patch/minor/major
  ↓
Step 3: Present Update Plan
  → Shows plan with time estimates
  ↓
Step 4-10: Execute updates, test, commit
  → Runs commands, verifies, reports
```

---

## Data Flow

### Configuration Loading

```
Startup
  │
  ▼
Read ~/.config/project-manager/projects.json
  │
  ├─► Parse JSON (jq in bash, ConvertFrom-Json in PS, JSON.parse in TS)
  │
  ▼
Store in memory
  │
  ▼
Read ~/.config/project-manager/project-types.json
  │
  ├─► Parse JSON
  │
  ▼
Ready for commands
```

### Command Execution Flow

```
User: "build my-project"
  │
  ▼
Parse command
  ├─► Command: build
  └─► Project: my-project
  │
  ▼
Load project config
  ├─► projects.json["my-project"]
  │   ├─► local_path: /home/user/projects/my-project
  │   └─► project_type: node
  │
  ▼
Resolve build command
  ├─► Check: projects.json["my-project"].commands.build
  │   └─► Not found
  ├─► Check: project-types.json["node"].build
  │   └─► Found: "bun run build"
  │
  ▼
Execute command
  ├─► cd /home/user/projects/my-project
  ├─► run: bun run build
  │
  ▼
Capture output
  ├─► stdout → display to user
  ├─► stderr → display to user
  └─► exit code → determine success/failure
  │
  ▼
Report result
  └─► "✓ Build successful" or "✗ Build failed"
```

### Smart Push Workflow

```
User: "push my-project 'commit message'"
  │
  ▼
Step 1: Pull latest
  ├─► git fetch origin
  ├─► git pull origin <branch>
  └─► Check for conflicts
  │
  ▼
Step 2: Check dependencies
  ├─► outdated my-project
  ├─► If updates available: prompt user
  └─► Optionally run dependency update
  │
  ▼
Step 3: Build
  ├─► build my-project
  └─► If fails: abort
  │
  ▼
Step 4: Test
  ├─► test my-project
  └─► If fails: abort
  │
  ▼
Step 5: Commit
  ├─► git add .
  └─► git commit -m "message"
  │
  ▼
Step 6: Push
  └─► git push origin <branch>
```

---

## Configuration System

### projects.json Structure

```json
{
  "project-name": {
    "github": "git@github.com:user/repo.git",
    "local_path": "/path/to/project",
    "editor": "code",
    "auto_pull": true,
    "description": "Project description",
    "project_type": "node",
    "commands": {
      "build": "custom build command",
      "test": "custom test command"
    }
  }
}
```

**Field Descriptions:**

- **github**: Git remote URL (required)
- **local_path**: Absolute path to project directory (required)
- **editor**: Preferred editor command (required)
- **auto_pull**: Auto-pull on open (required, boolean)
- **description**: Human-readable description (required)
- **project_type**: Type from project-types.json (optional)
- **commands**: Custom command overrides (optional, object)

### project-types.json Structure

```json
{
  "type-name": {
    "name": "Display Name",
    "build": "build command",
    "test": "test command",
    "run": "run command",
    "watch": "watch command",
    "format": "format command",
    "deps": "dependency install command"
  }
}
```

**Supported Types:**

1. **elixir** - Mix-based projects
2. **dotnet** - .NET projects
3. **node** - JavaScript/TypeScript (uses bun)
4. **go** - Go projects
5. **python** - Python projects (uses pytest)
6. **rust** - Cargo projects

### Configuration Resolution

**Hierarchy:**

1. **Project-specific commands** (highest priority)
   - `projects.json[project].commands.build`
2. **Project type defaults**
   - `project-types.json[project.project_type].build`
3. **No command** (return empty/null)

**Example:**

```json
// projects.json
{
  "my-app": {
    "project_type": "node",
    "commands": {
      "build": "npm run custom-build"  // Override
    }
  }
}

// project-types.json
{
  "node": {
    "build": "bun run build",  // Default
    "test": "bun test"         // Will be used (no override)
  }
}

// Resolution:
// build my-app  → runs: npm run custom-build
// test my-app   → runs: bun test
```

---

## Command Resolution

### Resolution Algorithm

```bash
function get_project_command() {
    local project_name="$1"
    local command_type="$2"  # build, test, run, etc.

    # Step 1: Check project-specific custom command
    local custom_cmd=$(jq -r \
        ".\"$project_name\".commands.\"$command_type\"" \
        "$CONFIG")

    if [ "$custom_cmd" != "null" ] && [ -n "$custom_cmd" ]; then
        echo "$custom_cmd"
        return 0
    fi

    # Step 2: Get project type
    local project_type=$(jq -r \
        ".\"$project_name\".project_type" \
        "$CONFIG")

    if [ "$project_type" = "null" ] || [ -z "$project_type" ]; then
        return 1  # No type, no command
    fi

    # Step 3: Get type default command
    local type_cmd=$(jq -r \
        ".\"$project_type\".\"$command_type\"" \
        "$PROJECT_TYPES")

    if [ "$type_cmd" != "null" ] && [ -n "$type_cmd" ]; then
        echo "$type_cmd"
        return 0
    fi

    # Step 4: No command found
    return 1
}
```

### Command Types

**Core Commands:**
- **build** - Compile/build the project
- **test** - Run test suite
- **run** - Start development server
- **watch** - Start with auto-reload
- **format** - Format code
- **deps** - Install dependencies

**Management Commands:**
- **outdated** - Check for outdated dependencies
- **push** - Smart push workflow
- **goto** - Navigate to project directory
- **open** - Open project with smart workflow

---

## Integration Points

### Shell Integration

**Bash/Zsh:**
```bash
# Sourced in ~/.bashrc or ~/.zshrc
source ~/.local/share/project-manager/functions.sh

# Provides functions:
projects()   # List projects
goto()       # cd to project
build()      # Build project
test()       # Test project
# etc.
```

**PowerShell:**
```powershell
# Loaded in profile
Import-Module ProjectManager

# Provides cmdlets:
Get-Projects
Set-ProjectLocation
Invoke-ProjectBuild
# etc.
```

### AI Assistant Integration

**MCP Server:**
- Stdio transport (JSON-RPC 2.0)
- Claude Desktop/Code compatible
- Exposes 8 tools
- Structured responses

**Claude Skills:**
- Markdown-based prompts
- Loaded by AI assistant
- Provides step-by-step guidance
- Integrates with MCP tools or shell commands

**Integration Flow:**

```
AI Assistant
    │
    ├─► MCP Server (for commands)
    │   └─► Project Manager CLI
    │       └─► Project Tools
    │
    └─► Claude Skills (for guidance)
        └─► Instructions to AI
            └─► AI uses MCP tools
```

---

## Design Decisions

### Why JSON for Configuration?

**Pros:**
- Human-readable and editable
- Widely supported (jq, PowerShell, Node.js)
- Structured data
- Easy to parse

**Cons:**
- No comments (solved with description fields)
- Strict syntax
- Manual editing can introduce errors

**Decision:** JSON provides the best balance of readability and programmatic access across all platforms.

### Why Separate Bash and PowerShell?

**Alternatives Considered:**
1. Single bash version with WSL requirement on Windows
2. Node.js CLI for all platforms
3. Go binary for all platforms

**Decision:** Platform-native implementations provide:
- Better user experience (no dependencies)
- Native shell integration
- Familiar conventions per platform
- Optimal performance

### Why MCP Server?

**Alternatives:**
- Direct CLI integration in AI prompts
- Custom API server
- No AI integration

**Decision:** MCP provides:
- Standard protocol for AI assistants
- Growing ecosystem
- Better than raw shell execution
- Structured tool interface

### Why Markdown for Skills?

**Alternatives:**
- JSON schema
- YAML
- Custom DSL
- Python/JS code

**Decision:** Markdown is:
- Human-readable
- AI-friendly (Claude excels at markdown)
- Easy to write and maintain
- No execution security concerns
- Flexible structure

### Why bun for Node.js?

**Alternatives:**
- npm
- yarn
- pnpm

**Decision:** bun is:
- Significantly faster
- Drop-in replacement
- Modern features
- Single tool (replaces npm + bundler)

**Note:** Users can override with custom commands if they prefer npm/yarn/pnpm.

---

## Future Considerations

### Scalability

**Current Limits:**
- ~100 projects (tested, performs well)
- JSON parsing is fast enough
- No indexing needed

**Future:**
- For >1000 projects: Consider database (SQLite)
- Add caching layer
- Implement project search index

### Extensibility

**Plugin System:**
- Not currently implemented
- Future: Load custom commands from `~/.config/project-manager/plugins/`
- Allow community extensions

**Custom Project Types:**
- Currently hardcoded in project-types.json
- Future: User-defined types in separate file
- Type inheritance

### Security

**Current:**
- Executes commands in user context
- No privilege escalation
- User trusts their own configuration

**Considerations:**
- Validate configuration before execution
- Sandboxing for untrusted projects
- Signature verification for remote configs

### Performance

**Current:**
- Fast enough for typical use
- JSON parsing is bottleneck (negligible for <100 projects)
- Command execution time dominates

**Optimizations:**
- Lazy load configuration
- Cache parsed JSON
- Parallel execution for multi-project operations

### Monitoring

**Future Features:**
- Track command execution time
- Log project activity
- Generate usage statistics
- Performance profiling

---

## Technology Stack Summary

| Component | Language | Key Libraries | Platform |
|-----------|----------|---------------|----------|
| Bash CLI | Bash | jq, git, gh | Linux/macOS |
| PowerShell Module | PowerShell | .NET | Windows |
| MCP Server | TypeScript | @modelcontextprotocol/sdk | Cross-platform |
| Skills | Markdown | N/A | AI assistants |

---

## Contribution Areas

Areas where contributions would be valuable:

1. **Testing**
   - Add automated tests
   - CI/CD pipeline
   - Integration tests

2. **Documentation**
   - Video tutorials
   - More examples
   - Translations

3. **Features**
   - New project types
   - Additional commands
   - New skills

4. **Tooling**
   - VSCode extension
   - Vim plugin
   - Status bar integration

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

---

**Last Updated:** November 27, 2025
**Maintainer:** David Wilson
**License:** All rights reserved
