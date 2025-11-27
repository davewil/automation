# Project Manager Claude Skills

A collection of Claude Skills that provide high-level workflow guidance for the Project Manager automation toolkit. These skills complement the MCP server by offering intelligent, multi-step workflows and best practices.

## What are Claude Skills?

Claude Skills are reusable prompt templates that give AI assistants like Claude Code specialized capabilities for complex workflows. Unlike MCP tools which expose low-level operations (build, test, run), skills provide:

- **Workflow Guidance**: Multi-step procedures with decision points
- **Best Practices**: Encoded development patterns and conventions
- **Context Awareness**: Understanding of project types and states
- **Interactive Guidance**: Conversational help through complex tasks

## Available Skills

### Phase 1 - Core Skills (Ready to Use)

#### 1. **project-setup** - New Project Setup Wizard
Guides you through adding a new project to Project Manager with automatic type detection and configuration.

**Use when:**
- Adding a newly cloned repository
- Setting up an existing project
- Onboarding a project to your workflow

**Example:** "Set up this project in my project manager"

---

#### 2. **project-health-check** - Comprehensive Project Analysis
Performs a deep health check analyzing git status, dependencies, build health, tests, code quality, and provides a scored health report with actionable recommendations.

**Use when:**
- Returning to a project after time away
- Before starting major changes
- During code reviews or audits
- Checking project status

**Example:** "Check the health of my grocery-planner project"

---

#### 3. **project-workflow** - Smart Development Workflow Guide
Guides you through a complete professional development workflow from branching to deployment, including proper commit messages, testing, and code review.

**Use when:**
- Implementing a new feature
- Fixing a bug
- Making any code changes
- Learning proper git workflows

**Example:** "Help me implement a new feature in my project"

---

## Installation

### Prerequisites

- Claude Code or another Claude Skills-compatible AI assistant
- Project Manager installed (bash/zsh, PowerShell, or MCP server)
- Projects configured in `~/.config/project-manager/projects.json`

### Setup

1. **Copy skills to your skills directory:**

   For Claude Code, skills are typically loaded from:
   ```bash
   ~/.config/claude-code/skills/
   ```

   Copy the skills:
   ```bash
   cp -r project-manager-skills/skills/* ~/.config/claude-code/skills/
   ```

2. **Verify installation:**

   In Claude Code, skills should appear in your available skills. You can invoke them by describing what you want to do, and Claude will recognize when a skill should be used.

## Usage

Skills are invoked conversationally. You don't need to explicitly call a skill - Claude will recognize when a skill should be used based on your request.

### Example Interactions

**Setting up a new project:**
```
You: "I just cloned the grocery-planner repo, help me set it up"

Claude: [Uses project-setup skill]
I'll help you set up the grocery-planner project. Let me verify we're in a git repository...

[Guides through detection, configuration, and verification]
```

**Checking project health:**
```
You: "What's the status of my api-server project?"

Claude: [Uses project-health-check skill]
Let me run a comprehensive health check on api-server...

[Analyzes and provides scored health report]
```

**Implementing a feature:**
```
You: "Help me add user authentication to grocery-planner"

Claude: [Uses project-workflow skill]
I'll guide you through implementing user authentication. Let's start
by understanding what you want to build...

[Guides through branching, implementation, testing, committing, PR creation]
```

## How Skills Work

### Skill Structure

Each skill is a markdown file with:

1. **Description**: What the skill does
2. **Prerequisites**: What's needed to use the skill
3. **Instructions**: Step-by-step guidance for Claude to follow
4. **Context**: When to use the skill
5. **Examples**: Sample interactions
6. **Error Handling**: How to handle common issues

### Skill Invocation

Claude automatically invokes skills when:
- Your request matches the skill's purpose
- Prerequisites are met
- The skill can provide value

You can also explicitly request a skill:
- "Use the project-setup skill to add this project"
- "Run a health check using the project-health-check skill"

### Integration with Project Manager Tools

Skills use Project Manager commands:
- `projects --add` - Add new project
- `open <project>` - Open with smart workflow
- `goto <project>` - Navigate to project
- `build <project>` - Build project
- `test <project>` - Run tests
- `outdated <project>` - Check dependencies
- `push <project> "msg"` - Smart push workflow

Skills can also use MCP tools if the MCP server is configured:
- `list_projects` - Get project list
- `get_project_info` - Get project details
- `build_project` - Run build
- `test_project` - Run tests
- `execute_custom_command` - Run any command

## Skill Philosophy

### Opinionated but Flexible

Skills encode best practices but adapt to your needs:
- Conventional commits (but customizable)
- Feature branch workflow (but can work with trunk-based)
- Test-driven development (but not required)

### Teaching by Doing

Skills don't just execute commands - they explain:
- Why each step matters
- What could go wrong
- Best practices and alternatives
- How to customize for your needs

### Progressive Disclosure

Skills provide:
- Quick paths for experienced users
- Detailed guidance for learners
- Context-aware recommendations
- Options at decision points

## Examples

See the [examples/](examples/) directory for detailed walkthroughs:

- [Setting up a new project](examples/setup-new-project.md)
- [Complete feature implementation](examples/implement-feature.md)
- [Fixing a build issue](examples/fix-build-issue.md)

## Future Skills (Planned)

### Phase 2 - Developer Experience
- **dependency-manager**: Intelligent dependency updates with breaking change detection
- **build-fixer**: Automated build troubleshooting
- **project-switcher**: Smart project navigation with context switching

### Phase 3 - Team & Maintenance
- **project-onboarding**: Generate onboarding documentation
- **multi-project-sync**: Sync all projects at once
- **release-helper**: Guided release management
- **project-cleaner**: Clean up artifacts and optimize

## Contributing

Want to create your own skills? Follow this template:

1. Copy the structure from existing skills
2. Focus on multi-step workflows, not single commands
3. Provide clear context and examples
4. Include error handling
5. Test with Claude Code

## Compatibility

These skills are designed for:
- ✅ Claude Code
- ✅ Claude Desktop (with MCP server)
- ✅ Any Claude Skills-compatible AI assistant

They work with:
- ✅ Project Manager bash/zsh version
- ✅ Project Manager PowerShell version
- ✅ Project Manager MCP server

## Tips for Using Skills

1. **Be conversational**: Describe what you want, don't memorize commands
2. **Provide context**: Mention the project name and what you're trying to do
3. **Ask questions**: Skills are interactive - ask for clarification
4. **Review suggestions**: Skills provide recommendations, not mandates
5. **Learn from skills**: Pay attention to the explanations

## Troubleshooting

**Skill not being invoked:**
- Be explicit: "Use the project-setup skill"
- Check prerequisites are met
- Verify skill is in the skills directory

**Skill gives wrong guidance:**
- Provide more context about your project
- Mention specific constraints or requirements
- Override suggestions with your preferences

**Command failures:**
- Ensure Project Manager is installed
- Verify project is configured correctly
- Check that you're in the right directory

## Support

For issues with:
- **Skills themselves**: Check the skill's error handling section
- **Project Manager tools**: See main Project Manager documentation
- **Claude Code**: Refer to Claude Code documentation

## License

These skills are part of the Project Manager automation toolkit. All rights reserved.
