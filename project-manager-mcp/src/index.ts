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

// Get config paths
const CONFIG_PATH =
  process.env.OPEN_PROJECT_CONFIG ||
  join(homedir(), ".config", "project-manager", "projects.json");

const PROJECT_TYPES_PATH =
  process.env.OPEN_PROJECT_TYPES ||
  join(homedir(), ".config", "project-manager", "project-types.json");

// Type definitions
interface ProjectConfig {
  github?: string;
  local_path: string;
  editor?: string;
  auto_pull?: boolean;
  description?: string;
  project_type?: string;
  commands?: {
    build?: string;
    test?: string;
    run?: string;
    watch?: string;
    format?: string;
    deps?: string;
    outdated?: string;
  };
}

interface ProjectTypeDefinition {
  name: string;
  build?: string;
  test?: string;
  run?: string;
  watch?: string;
  format?: string;
  deps?: string;
  outdated?: string;
}

interface ProjectsConfig {
  [projectName: string]: ProjectConfig;
}

interface ProjectTypesConfig {
  [typeName: string]: ProjectTypeDefinition;
}

// Helper to read projects config
function getProjectConfig(): ProjectsConfig {
  if (!existsSync(CONFIG_PATH)) {
    throw new Error(
      `Configuration file not found at ${CONFIG_PATH}\n\n` +
        `Please set up Project Manager:\n` +
        `  1. Install bash version: cd project-manager && ./install.sh\n` +
        `  2. Or create config manually at ${CONFIG_PATH}\n` +
        `  3. See README for setup instructions`
    );
  }
  return JSON.parse(readFileSync(CONFIG_PATH, "utf-8"));
}

// Helper to read project types config
function getProjectTypesConfig(): ProjectTypesConfig {
  if (!existsSync(PROJECT_TYPES_PATH)) {
    // Return empty config if types file doesn't exist
    console.error(`Warning: Project types file not found at ${PROJECT_TYPES_PATH}`);
    return {};
  }
  return JSON.parse(readFileSync(PROJECT_TYPES_PATH, "utf-8"));
}

// Helper to resolve command for a project (mimics bash script logic)
function getProjectCommand(
  projectName: string,
  commandType: "build" | "test" | "run" | "outdated"
): string {
  const config = getProjectConfig();
  const project = config[projectName];

  if (!project) {
    throw new Error(`Project '${projectName}' not found`);
  }

  // Step 1: Check project-specific custom command
  if (project.commands && project.commands[commandType]) {
    return project.commands[commandType]!;
  }

  // Step 2: Get project type default
  if (project.project_type) {
    const projectTypes = getProjectTypesConfig();
    const typeConfig = projectTypes[project.project_type];

    if (typeConfig && typeConfig[commandType]) {
      return typeConfig[commandType]!;
    }
  }

  // Step 3: Handle outdated command specially (type-specific logic)
  if (commandType === "outdated" && project.project_type) {
    const outdatedCommands: { [key: string]: string } = {
      elixir: "mix hex.outdated",
      dotnet: "dotnet list package --outdated",
      node: "npm outdated",
      go: "go list -u -m all",
      python: "pip list --outdated",
      rust: "cargo outdated",
    };

    if (outdatedCommands[project.project_type]) {
      return outdatedCommands[project.project_type];
    }
  }

  throw new Error(
    `No ${commandType} command configured for project '${projectName}'.\n` +
      `Either add a custom command in projects.json or ensure project_type is set correctly.`
  );
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
        const projects = Object.entries(config).map(([name, proj]) => ({
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

        // Get build command using standalone resolution
        const buildCommand = getProjectCommand(project_name, "build");
        const output = executeCommand(buildCommand, localPath);

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

        // Get test command using standalone resolution
        const testCommand = getProjectCommand(project_name, "test");
        const output = executeCommand(testCommand, localPath);

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

        // Get run command using standalone resolution
        const runCommand = getProjectCommand(project_name, "run");
        const output = executeCommand(runCommand, localPath);

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

        // Get outdated command using standalone resolution
        const outdatedCommand = getProjectCommand(project_name, "outdated");
        const output = executeCommand(outdatedCommand, localPath);

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
