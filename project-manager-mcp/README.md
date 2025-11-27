# Project Manager MCP Server

A Model Context Protocol (MCP) server that exposes Project Manager functionality to agentic coding tools like Claude Code, Cline, and other MCP-compatible AI assistants.

## Features

The MCP server provides the following tools:

- **list_projects** - List all configured projects with descriptions and types
- **get_project_info** - Get detailed information about a specific project
- **build_project** - Build a project using its configured build command
- **test_project** - Run tests for a project
- **run_project** - Run a project
- **check_outdated_dependencies** - Check for outdated dependencies
- **get_project_status** - Get git status for a project
- **execute_custom_command** - Execute any custom command in a project's directory

## Cross-Platform Support

✅ **Fully standalone and cross-platform!**

- Works on **Windows, Linux, and macOS**
- **No bash scripts required** - the MCP server reads configuration directly
- Only requires Node.js 18+
- Implements the same command resolution logic as the bash version

## Installation

### Prerequisites

- Node.js 18 or later
- Projects configured in `~/.config/project-manager/projects.json`
- Project types defined in `~/.config/project-manager/project-types.json`

**Note:** You can use the MCP server without installing the bash/PowerShell versions. Just create the configuration files manually or run the installation scripts to generate them.

### Install the MCP Server

```bash
cd project-manager-mcp
npm install
npm run build
```

## Configuration

### For Claude Desktop

Add to your Claude Desktop configuration file:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%/Claude/claude_desktop_config.json`
**Linux:** `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "project-manager": {
      "command": "node",
      "args": ["/path/to/automation/project-manager-mcp/dist/index.js"]
    }
  }
}
```

### For Claude Code

Add to your MCP settings file:

**Location:** `~/.config/claude-code/mcp_settings.json`

```json
{
  "mcpServers": {
    "project-manager": {
      "command": "node",
      "args": ["/path/to/automation/project-manager-mcp/dist/index.js"]
    }
  }
}
```

### For Cline (VSCode Extension)

Add to Cline's MCP settings:

1. Open VSCode Settings
2. Search for "Cline: MCP Settings"
3. Add the server configuration:

```json
{
  "mcpServers": {
    "project-manager": {
      "command": "node",
      "args": ["/path/to/automation/project-manager-mcp/dist/index.js"]
    }
  }
}
```

## Usage

Once configured, the AI assistant can use these tools automatically. Here are some example prompts:

### List all projects
> "What projects do I have configured?"

The assistant will use the `list_projects` tool to show all your projects.

### Build a project
> "Build the grocery_planner project"

The assistant will use the `build_project` tool.

### Run tests
> "Run tests for my api-server project"

The assistant will use the `test_project` tool.

### Check dependencies
> "Check if grocery_planner has any outdated dependencies"

The assistant will use the `check_outdated_dependencies` tool.

### Get project status
> "What's the git status of my grocery_planner project?"

The assistant will use the `get_project_status` tool.

### Custom commands
> "Run 'npm audit' in the grocery_planner project"

The assistant will use the `execute_custom_command` tool.

## Tools Reference

### list_projects

Lists all configured projects.

**Arguments:** None

**Returns:** JSON array of projects with name, description, type, and path

**Example:**
```json
[
  {
    "name": "grocery_planner",
    "description": "Grocery planning application",
    "type": "elixir",
    "path": "/home/user/projects/grocery_planner"
  }
]
```

### get_project_info

Get detailed information about a specific project.

**Arguments:**
- `project_name` (string): Name of the project

**Returns:** Full project configuration

### build_project

Build a project using its configured build command.

**Arguments:**
- `project_name` (string): Name of the project to build

**Returns:** Build output

### test_project

Run tests for a project.

**Arguments:**
- `project_name` (string): Name of the project to test

**Returns:** Test output

### run_project

Run a project.

**Arguments:**
- `project_name` (string): Name of the project to run

**Returns:** Run output

### check_outdated_dependencies

Check for outdated dependencies based on project type.

**Arguments:**
- `project_name` (string): Name of the project

**Returns:** List of outdated dependencies

### get_project_status

Get git status for a project.

**Arguments:**
- `project_name` (string): Name of the project

**Returns:** Git status and current branch

### execute_custom_command

Execute a custom command in a project's directory.

**Arguments:**
- `project_name` (string): Name of the project
- `command` (string): Command to execute

**Returns:** Command output

## Development

### Build

```bash
npm run build
```

### Watch mode

```bash
npm run watch
```

### Testing the server

You can test the MCP server using the MCP inspector:

```bash
npx @modelcontextprotocol/inspector node dist/index.js
```

## Architecture

The MCP server acts as a bridge between agentic coding tools and the Project Manager bash scripts:

```
┌─────────────────┐
│  AI Assistant   │
│ (Claude/Cline)  │
└────────┬────────┘
         │ MCP Protocol
         │
┌────────▼────────┐
│   MCP Server    │
│  (TypeScript)   │
└────────┬────────┘
         │ Shell Commands
         │
┌────────▼────────┐
│ project-command │
│  bash scripts   │
└─────────────────┘
```

The server:
1. Reads project configuration from `~/.config/project-manager/projects.json`
2. Executes project-command bash scripts to perform operations
3. Returns results to the AI assistant via MCP protocol

## Environment Variables

- `OPEN_PROJECT_CONFIG` - Override the default config file location

## Troubleshooting

### Server not appearing in Claude Desktop

1. Check the logs at:
   - macOS: `~/Library/Logs/Claude/mcp*.log`
   - Windows: `%APPDATA%/Claude/logs/mcp*.log`
2. Verify the path to `dist/index.js` is correct
3. Ensure the server was built (`npm run build`)
4. Restart Claude Desktop

### Commands failing

1. Verify Project Manager is installed: `which project-command`
2. Check that projects.json exists and is valid JSON
3. Ensure the project exists and local_path is correct

### Permission issues

Ensure the MCP server has execute permissions:

```bash
chmod +x dist/index.js
```

## Contributing

This MCP server is part of the Project Manager automation toolkit.

## License

MIT
