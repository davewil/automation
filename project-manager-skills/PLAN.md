# Claude Skills for Project Manager - Implementation Plan

## Overview

Create a set of Claude Skills that provide project management capabilities to Claude Code and other AI assistants, complementing the MCP server with skill-based workflows.

## What are Claude Skills?

Claude Skills are reusable prompt templates that give AI assistants specialized capabilities. Unlike MCP servers which expose tools, skills provide:
- Contextual prompts and instructions
- Workflow guidance
- Best practices and patterns
- Multi-step procedures

## Proposed Skills

### 1. **project-setup** - New Project Setup Wizard
**Purpose:** Guide through setting up a new project in the project manager

**Workflow:**
1. Check if in a git repository
2. Detect project type automatically
3. Prompt for project details (description, editor preference)
4. Run `projects --add` to register the project
5. Verify configuration
6. Suggest next steps (install dependencies, first build)

**Use Case:** "Set up this project in my project manager"

---

### 2. **project-health-check** - Comprehensive Project Analysis
**Purpose:** Analyze a project's health and suggest improvements

**Workflow:**
1. Check git status (uncommitted changes, branch info)
2. Check for outdated dependencies
3. Run build and tests
4. Analyze recent commit history
5. Check for common issues (missing .gitignore, outdated README, etc.)
6. Provide actionable recommendations

**Use Case:** "Check the health of my grocery_planner project"

---

### 3. **project-workflow** - Smart Development Workflow
**Purpose:** Guide through a complete development workflow for a feature

**Workflow:**
1. Pull latest changes
2. Create feature branch (optional)
3. Check dependencies and update if needed
4. Run build and tests to ensure clean slate
5. Guide user through implementation
6. Run tests after changes
7. Format code
8. Commit with conventional commit message
9. Push or create PR

**Use Case:** "Help me implement a new feature in my project"

---

### 4. **dependency-manager** - Intelligent Dependency Management
**Purpose:** Help manage project dependencies across different project types

**Workflow:**
1. Detect project type
2. Check for outdated dependencies
3. Show dependency vulnerability information (if available)
4. Suggest updates with breaking change warnings
5. Guide through update process
6. Verify build/tests after updates
7. Suggest lockfile updates if needed

**Use Case:** "Update dependencies for my project"

---

### 5. **project-switcher** - Intelligent Project Navigation
**Purpose:** Help switch between projects intelligently

**Workflow:**
1. List available projects
2. Show recent activity/last modified
3. Check for uncommitted changes in current project
4. Suggest committing/stashing if needed
5. Run `open` command with smart workflow
6. Provide project-specific context (recent commits, open issues, etc.)

**Use Case:** "Switch to my api-server project"

---

### 6. **build-fixer** - Build Troubleshooting Assistant
**Purpose:** Help diagnose and fix build/test failures

**Workflow:**
1. Run build/tests and capture output
2. Analyze error messages
3. Search for common solutions
4. Suggest fixes based on project type
5. Guide through applying fixes
6. Verify fix works
7. Document the solution

**Use Case:** "My build is failing, help me fix it"

---

### 7. **project-onboarding** - New Developer Onboarding
**Purpose:** Generate comprehensive project onboarding documentation

**Workflow:**
1. Analyze project structure
2. Detect technology stack
3. Identify setup requirements
4. Create step-by-step setup guide
5. Document common commands
6. List key files and their purposes
7. Suggest first tasks for new developers

**Use Case:** "Generate onboarding docs for this project"

---

### 8. **multi-project-sync** - Sync Multiple Projects
**Purpose:** Pull latest changes and check status across multiple projects

**Workflow:**
1. List all configured projects
2. For each project:
   - Check if directory exists
   - Pull latest changes
   - Report any uncommitted changes
   - Check for outdated dependencies
3. Provide summary report
4. Suggest which projects need attention

**Use Case:** "Sync all my projects"

---

### 9. **release-helper** - Release Management Assistant
**Purpose:** Guide through creating a release

**Workflow:**
1. Check current version
2. Verify all tests pass
3. Check for uncommitted changes
4. Suggest version bump (semantic versioning)
5. Generate changelog from commits
6. Create release commit and tag
7. Guide through publishing (if applicable)
8. Push tags to remote

**Use Case:** "Help me create a release for version 2.0"

---

### 10. **project-cleaner** - Project Cleanup Assistant
**Purpose:** Clean up project artifacts and optimize

**Workflow:**
1. Identify build artifacts to clean
2. Check for unused dependencies
3. Find large files that shouldn't be committed
4. Suggest .gitignore improvements
5. Clean node_modules, target, dist, etc.
6. Clear caches
7. Report space saved

**Use Case:** "Clean up my project"

---

## Skill Structure

Each skill would be a markdown file with:

```markdown
# Skill Name

## Description
Brief description of what the skill does

## Prerequisites
- List of requirements
- Tools needed
- Configuration needed

## Instructions
Detailed step-by-step instructions for Claude to follow

## Context
Additional context about when to use this skill

## Examples
Example interactions and expected outcomes
```

## Implementation Priority

### Phase 1 - Core Skills (Most Valuable)
1. **project-setup** - Essential for getting started
2. **project-health-check** - High value diagnostic tool
3. **project-workflow** - Guides daily development

### Phase 2 - Developer Experience
4. **dependency-manager** - Common pain point
5. **build-fixer** - Debugging assistance
6. **project-switcher** - Quality of life

### Phase 3 - Team & Maintenance
7. **project-onboarding** - Documentation automation
8. **multi-project-sync** - Managing multiple projects
9. **release-helper** - Release automation
10. **project-cleaner** - Maintenance tasks

## Integration Points

### With MCP Server
Skills can call MCP tools for:
- `list_projects` - Get project list
- `get_project_info` - Get project details
- `build_project` - Run builds
- `test_project` - Run tests
- `check_outdated_dependencies` - Check deps
- `execute_custom_command` - Run any command

### With Bash/PowerShell Scripts
Skills can guide users to run:
- `open <project>` - Open with smart workflow
- `goto <project>` - Navigate to project
- `build <project>` - Build project
- `test <project>` - Run tests
- `push <project> "message"` - Smart push workflow

## Benefits

1. **Workflow Guidance** - Multi-step processes made simple
2. **Best Practices** - Encode good practices in skills
3. **Context Aware** - Skills understand project types
4. **Reusable** - Same skills work across all projects
5. **Learning** - Skills teach good development practices
6. **Automation** - Reduce repetitive tasks

## File Structure

```
project-manager-skills/
├── README.md                 # Overview and installation
├── PLAN.md                   # This file
├── skills/
│   ├── project-setup.md
│   ├── project-health-check.md
│   ├── project-workflow.md
│   ├── dependency-manager.md
│   ├── project-switcher.md
│   ├── build-fixer.md
│   ├── project-onboarding.md
│   ├── multi-project-sync.md
│   ├── release-helper.md
│   └── project-cleaner.md
└── examples/
    ├── setup-new-project.md
    ├── fix-build-issue.md
    └── create-release.md
```

## Success Metrics

Skills are successful if they:
- Reduce time to complete common tasks
- Provide clear, actionable guidance
- Work consistently across project types
- Integrate seamlessly with existing tools
- Are actually used by developers

## Next Steps

1. ✅ Create skills directory structure
2. ✅ Write this plan
3. Create Phase 1 skills (project-setup, health-check, workflow)
4. Test skills with Claude Code
5. Gather feedback and iterate
6. Create Phase 2 and 3 skills
7. Document best practices for skill usage

## Questions to Consider

- Should skills be opinionated about workflows?
- How to handle different project types gracefully?
- Should skills suggest automation opportunities?
- How to keep skills updated with tool changes?
- Should skills work standalone or require MCP server?

## Conclusion

Claude Skills for Project Manager will bridge the gap between low-level MCP tools and high-level developer workflows, making project management more intuitive and efficient.
