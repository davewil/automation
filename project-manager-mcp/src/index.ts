#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import { execSync } from "child_process";
import { existsSync, readFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

// Get config path
const CONFIG_PATH =
  process.env.OPEN_PROJECT_CONFIG ||
  join(homedir(), ".config", "project-manager", "projects.json");

// Helper to read projects config
function getProjectConfig() {
  if (!existsSync(CONFIG_PATH)) {
    throw new Error(`Configuration file not found at ${CONFIG_PATH}`);
  }
  return JSON.parse(readFileSync(CONFIG_PATH, "utf-8"));
}

// Helper to execute shell commands
function executeCommand(command: string, cwd?: string): string {
  try {
    return execSync(command, {
      cwd,
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
    });
  } catch (error: any) {
    throw new Error(`Command failed: ${error.message}\n${error.stderr || ""}`);
  }
}

// Define available tools
const tools: Tool[] = [
  {
    name: "list_projects",
    description:
      "List all configured projects with their descriptions and types",
    inputSchema: {
      type: "object",
      properties: {},
    },
  },
  {
    name: "get_project_info",
    description: "Get detailed information about a specific project",
    inputSchema: {
      type: "object",
      properties: {
        project_name: {
          type: "string",
          description: "Name of the project",
        },
      },
      required: ["project_name"],
    },
  },
  {
    name: "build_project",
    description: "Build a project using its configured build command",
    inputSchema: {
      type: "object",
      properties: {
        project_name: {
          type: "string",
          description: "Name of the project to build",
        },
      },
      required: ["project_name"],
    },
  },
  {
    name: "test_project",
    description: "Run tests for a project using its configured test command",
    inputSchema: {
      type: "object",
      properties: {
        project_name: {
          type: "string",
          description: "Name of the project to test",
        },
      },
      required: ["project_name"],
    },
  },
  {
    name: "run_project",
    description: "Run a project using its configured run command",
    inputSchema: {
      type: "object",
      properties: {
        project_name: {
          type: "string",
          description: "Name of the project to run",
        },
      },
      required: ["project_name"],
    },
  },
  {
    name: "check_outdated_dependencies",
    description:
      "Check for outdated dependencies in a project based on its type",
    inputSchema: {
      type: "object",
      properties: {
        project_name: {
          type: "string",
          description: "Name of the project to check",
        },
      },
      required: ["project_name"],
    },
  },
  {
    name: "get_project_status",
    description: "Get git status for a project",
    inputSchema: {
      type: "object",
      properties: {
        project_name: {
          type: "string",
          description: "Name of the project",
        },
      },
      required: ["project_name"],
    },
  },
  {
    name: "execute_custom_command",
    description:
      "Execute a custom command in a project's directory. Use this for any project-specific operations not covered by other tools.",
    inputSchema: {
      type: "object",
      properties: {
        project_name: {
          type: "string",
          description: "Name of the project",
        },
        command: {
          type: "string",
          description: "Command to execute in the project directory",
        },
      },
      required: ["project_name", "command"],
    },
  },
];

// Create server instance
const server = new Server(
  {
    name: "project-manager-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Handle list tools request
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools };
});

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "list_projects": {
        const config = getProjectConfig();
        const projects = Object.entries(config).map(([name, proj]: [string, any]) => ({
          name,
          description: proj.description || "",
          type: proj.project_type || "unknown",
          path: proj.local_path,
        }));

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(projects, null, 2),
            },
          ],
        };
      }

      case "get_project_info": {
        const { project_name } = args as { project_name: string };
        const config = getProjectConfig();
        const project = config[project_name];

        if (!project) {
          throw new Error(`Project '${project_name}' not found`);
        }

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(project, null, 2),
            },
          ],
        };
      }

      case "build_project": {
        const { project_name } = args as { project_name: string };
        const config = getProjectConfig();
        const project = config[project_name];

        if (!project) {
          throw new Error(`Project '${project_name}' not found`);
        }

        const localPath = project.local_path.replace(/^~/, homedir());

        if (!existsSync(localPath)) {
          throw new Error(`Project directory not found at ${localPath}`);
        }

        // Use project-command script
        const output = executeCommand(`project-command build ${project_name}`);

        return {
          content: [
            {
              type: "text",
              text: `Build completed for ${project_name}:\n\n${output}`,
            },
          ],
        };
      }

      case "test_project": {
        const { project_name } = args as { project_name: string };
        const config = getProjectConfig();
        const project = config[project_name];

        if (!project) {
          throw new Error(`Project '${project_name}' not found`);
        }

        const localPath = project.local_path.replace(/^~/, homedir());

        if (!existsSync(localPath)) {
          throw new Error(`Project directory not found at ${localPath}`);
        }

        const output = executeCommand(`project-command test ${project_name}`);

        return {
          content: [
            {
              type: "text",
              text: `Tests completed for ${project_name}:\n\n${output}`,
            },
          ],
        };
      }

      case "run_project": {
        const { project_name } = args as { project_name: string };
        const config = getProjectConfig();
        const project = config[project_name];

        if (!project) {
          throw new Error(`Project '${project_name}' not found`);
        }

        const localPath = project.local_path.replace(/^~/, homedir());

        if (!existsSync(localPath)) {
          throw new Error(`Project directory not found at ${localPath}`);
        }

        const output = executeCommand(`project-command run ${project_name}`);

        return {
          content: [
            {
              type: "text",
              text: `Running ${project_name}:\n\n${output}`,
            },
          ],
        };
      }

      case "check_outdated_dependencies": {
        const { project_name } = args as { project_name: string };
        const config = getProjectConfig();
        const project = config[project_name];

        if (!project) {
          throw new Error(`Project '${project_name}' not found`);
        }

        const localPath = project.local_path.replace(/^~/, homedir());

        if (!existsSync(localPath)) {
          throw new Error(`Project directory not found at ${localPath}`);
        }

        const output = executeCommand(`project-command outdated ${project_name}`);

        return {
          content: [
            {
              type: "text",
              text: `Dependency check for ${project_name}:\n\n${output}`,
            },
          ],
        };
      }

      case "get_project_status": {
        const { project_name } = args as { project_name: string };
        const config = getProjectConfig();
        const project = config[project_name];

        if (!project) {
          throw new Error(`Project '${project_name}' not found`);
        }

        const localPath = project.local_path.replace(/^~/, homedir());

        if (!existsSync(localPath)) {
          throw new Error(`Project directory not found at ${localPath}`);
        }

        const status = executeCommand("git status", localPath);
        const branch = executeCommand(
          "git rev-parse --abbrev-ref HEAD",
          localPath
        ).trim();

        return {
          content: [
            {
              type: "text",
              text: `Git status for ${project_name} (branch: ${branch}):\n\n${status}`,
            },
          ],
        };
      }

      case "execute_custom_command": {
        const { project_name, command } = args as {
          project_name: string;
          command: string;
        };
        const config = getProjectConfig();
        const project = config[project_name];

        if (!project) {
          throw new Error(`Project '${project_name}' not found`);
        }

        const localPath = project.local_path.replace(/^~/, homedir());

        if (!existsSync(localPath)) {
          throw new Error(`Project directory not found at ${localPath}`);
        }

        const output = executeCommand(command, localPath);

        return {
          content: [
            {
              type: "text",
              text: `Command output for ${project_name}:\n\n${output}`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error: any) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Project Manager MCP server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
