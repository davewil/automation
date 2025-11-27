# Contributing to Project Manager

Thank you for your interest in contributing to Project Manager! This document provides guidelines and information for contributors.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Project Structure](#project-structure)
5. [How to Contribute](#how-to-contribute)
6. [Coding Standards](#coding-standards)
7. [Testing](#testing)
8. [Documentation](#documentation)
9. [Pull Request Process](#pull-request-process)
10. [Release Process](#release-process)

---

## Code of Conduct

### Our Standards

- **Be respectful**: Treat all contributors with respect and consideration
- **Be constructive**: Provide helpful feedback and suggestions
- **Be collaborative**: Work together to improve the project
- **Be inclusive**: Welcome contributors of all skill levels

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling or inflammatory remarks
- Personal attacks or insults
- Publishing others' private information

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Git** installed and configured
- **Bash** (for Linux/macOS contributions) or **PowerShell** (for Windows contributions)
- **Node.js 18+** (for MCP server contributions)
- **jq** (for JSON parsing in bash scripts)
- **gh CLI** (optional, for GitHub integration)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/automation.git
   cd automation
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/davewil/automation.git
   ```

---

## Development Setup

### Bash/Zsh Version

```bash
cd project-manager
./install.sh
source ~/.bashrc  # or ~/.zshrc
```

Test that it works:
```bash
projects
goto automation
```

### PowerShell Version

```powershell
cd project-manager-ps
.\Install.ps1
Import-Module ProjectManager
```

Test that it works:
```powershell
Get-Projects
Set-ProjectLocation automation
```

### MCP Server

```bash
cd project-manager-mcp
npm install
npm run build
```

Test that it works:
```bash
# Method 1: Use MCP Inspector (recommended for development)
npx @modelcontextprotocol/inspector node dist/index.js

# Method 2: Manual test via stdin
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | node dist/index.js
```

To use with Claude Code, add to `~/.config/claude-code/mcp_settings.json`:
```json
{
  "mcpServers": {
    "project-manager": {
      "command": "node",
      "args": ["/absolute/path/to/automation/project-manager-mcp/dist/index.js"]
    }
  }
}
```

See [project-manager-mcp/README.md](project-manager-mcp/README.md) for complete setup instructions.

### Claude Skills

Skills don't require installation for development. Simply edit the `.md` files in `project-manager-skills/skills/`.

---

## Project Structure

```
automation/
├── project-manager/           # Bash/Zsh version
│   ├── open-project.sh        # Project navigation and cloning
│   ├── project-command.sh     # Build, test, run commands
│   ├── goto-project.sh        # Directory navigation
│   ├── install.sh             # Installation script
│   ├── completion.bash        # Bash tab completion
│   ├── completion.zsh         # Zsh tab completion
│   ├── projects.json          # Configuration (example)
│   └── project-types.json     # Project type definitions
│
├── project-manager-ps/        # PowerShell version
│   ├── ProjectManager/
│   │   ├── ProjectManager.psd1   # Module manifest
│   │   └── ProjectManager.psm1   # Module implementation
│   ├── Install.ps1               # Installation script
│   ├── projects.json             # Configuration (example)
│   └── project-types.json        # Project type definitions
│
├── project-manager-mcp/       # MCP server
│   ├── src/
│   │   └── index.ts           # Main server implementation
│   ├── package.json           # Dependencies
│   └── tsconfig.json          # TypeScript config
│
├── project-manager-skills/    # Claude Skills
│   ├── skills/                # Skill definitions
│   │   ├── project-setup.md
│   │   ├── project-health-check.md
│   │   └── ... (10 skills total)
│   ├── examples/              # Example walkthroughs
│   ├── PLAN.md               # Development plan
│   └── README.md             # Skills documentation
│
├── README.md                  # Main documentation
├── CONTRIBUTING.md           # This file
├── FUTURE_IDEAS.md           # Roadmap
└── ARCHITECTURE.md           # Architecture documentation
```

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## How to Contribute

### Finding Issues to Work On

- Check [GitHub Issues](https://github.com/davewil/automation/issues)
- Look for issues labeled `good first issue` or `help wanted`
- Comment on an issue to let others know you're working on it

### Types of Contributions

**Code Contributions:**
- New features
- Bug fixes
- Performance improvements
- Refactoring

**Documentation:**
- Improve README or other docs
- Add examples
- Fix typos
- Write tutorials

**Skills:**
- New Claude Skills
- Improve existing skills
- Add skill examples

**Testing:**
- Write tests
- Report bugs
- Verify fixes

**Ideas:**
- Suggest features
- Provide use cases
- Review pull requests

---

## Coding Standards

### Bash Scripts

**Style:**
- Use 4 spaces for indentation (not tabs)
- Use lowercase for variable names: `project_name`
- Use UPPERCASE for constants: `CONFIG_DIR`
- Quote variables: `"$variable"`
- Use `[[` instead of `[` for conditions
- Check command success: `if command; then`

**Example:**
```bash
# Good
get_project_info() {
    local project_name="$1"
    local config_file="$HOME/.config/project-manager/projects.json"

    if [[ -f "$config_file" ]]; then
        jq -r ".\"$project_name\"" "$config_file"
    else
        echo "Error: Configuration not found" >&2
        return 1
    fi
}

# Bad
get_project_info(){
	PROJECT=$1
	CONFIG=~/.config/project-manager/projects.json
	jq -r ".$PROJECT" $CONFIG
}
```

**Best Practices:**
- Always quote variables to prevent word splitting
- Use `local` for function variables
- Check for errors and provide meaningful messages
- Use functions to organize code
- Add comments for complex logic

### PowerShell Scripts

**Style:**
- Use PascalCase for function names: `Get-ProjectInfo`
- Use camelCase for variables: `$projectName`
- Use approved verbs: Get, Set, New, Remove, etc.
- Follow [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)

**Example:**
```powershell
# Good
function Get-ProjectInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectName
    )

    $configPath = "~/.config/project-manager/projects.json"

    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        return $config.$ProjectName
    }
    else {
        Write-Error "Configuration not found: $configPath"
        return $null
    }
}
```

**Best Practices:**
- Use `[CmdletBinding()]` for advanced functions
- Define parameter types
- Use `Mandatory` for required parameters
- Handle errors with `Write-Error`
- Return meaningful values

### TypeScript (MCP Server)

**Style:**
- Use 2 spaces for indentation
- Use camelCase for variables: `projectName`
- Use PascalCase for types/interfaces: `ProjectConfig`
- Use async/await for asynchronous operations
- Follow [TypeScript Best Practices](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)

**Example:**
```typescript
// Good
interface ProjectConfig {
  github: string;
  local_path: string;
  editor: string;
  auto_pull: boolean;
  description: string;
}

async function getProjectInfo(projectName: string): Promise<ProjectConfig | null> {
  const configPath = path.join(os.homedir(), '.config', 'project-manager', 'projects.json');

  try {
    const data = await fs.readFile(configPath, 'utf-8');
    const config = JSON.parse(data);
    return config[projectName] || null;
  } catch (error) {
    console.error(`Error reading config: ${error}`);
    return null;
  }
}
```

**Best Practices:**
- Define interfaces for data structures
- Use async/await instead of callbacks
- Handle errors properly
- Add JSDoc comments for public functions
- Use strict TypeScript settings

### Claude Skills

**Style:**
- Use clear, descriptive headings
- Follow existing skill structure
- Write in active voice
- Use code blocks for commands
- Include error handling sections

**Structure:**
```markdown
# Skill Name - Brief Description

## Description
[What the skill does]

## Prerequisites
[What's needed to use this skill]

## Instructions
[Step-by-step workflow]

## Context
[When to use this skill]

## Example Usage
[Real-world scenarios]

## Error Handling
[Common issues and solutions]

## Success Criteria
[What defines success]

## Tips
[Best practices]
```

**Best Practices:**
- Write for clarity, not brevity
- Include command examples with expected output
- Explain the "why" behind steps
- Provide multiple examples
- Cover edge cases in error handling

---

## Testing

### Manual Testing

Before submitting a pull request, test your changes:

**Bash Version:**
```bash
# Test basic commands
projects
goto automation
build automation
test automation
outdated automation

# Test edge cases
projects --add  # In a non-git directory
goto nonexistent-project
```

**PowerShell Version:**
```powershell
# Test basic commands
Get-Projects
Set-ProjectLocation automation
Invoke-ProjectBuild automation
Invoke-ProjectTest automation

# Test edge cases
Add-Project  # In a non-git directory
Set-ProjectLocation nonexistent-project
```

**MCP Server:**
```bash
npm run build
npm run dev

# Test with MCP inspector
npx @modelcontextprotocol/inspector dist/index.js
```

**Skills:**
- Read through the skill carefully
- Check all code blocks are valid
- Verify workflow steps are logical
- Test commands if possible

### Automated Tests

*Coming soon: Automated test suite*

When adding tests:
- Place bash tests in `project-manager/tests/`
- Place PowerShell tests in `project-manager-ps/tests/`
- Place TypeScript tests in `project-manager-mcp/tests/`
- Use descriptive test names
- Test both success and failure cases

---

## Documentation

### Updating README

When adding features:
- Update the main README.md
- Add examples if applicable
- Update command tables
- Keep it concise

### Updating Skills Documentation

When modifying skills:
- Update project-manager-skills/README.md
- Update relevant examples
- Add new examples if needed
- Keep TEST_RESULTS.md current

### Writing Good Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**
```
feat(bash): add project tagging support

Allow projects to be tagged for better organization.
Users can filter projects by tag using --tag flag.

Closes #42

---

fix(mcp): handle missing config file gracefully

Previously crashed when projects.json didn't exist.
Now returns empty array and logs warning.

Fixes #38

---

docs(skills): add example for multi-project-sync

Create comprehensive walkthrough showing Monday morning
sync workflow with 6 projects.
```

**Guidelines:**
- Keep subject line under 72 characters
- Use present tense: "add" not "added"
- Reference issues/PRs in footer
- Explain "why" in body, not just "what"

---

## Pull Request Process

### Before Submitting

1. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```

2. **Make your changes:**
   - Write clean, documented code
   - Follow coding standards
   - Test thoroughly

3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat(component): description"
   ```

4. **Update documentation:**
   - Update README if needed
   - Add comments to code
   - Update CHANGELOG (if exists)

5. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

### Submitting the PR

1. **Go to GitHub** and create a pull request

2. **Fill out the PR template:**
   - Description of changes
   - Related issues
   - How to test
   - Screenshots (if UI changes)

3. **Request review** from maintainers

4. **Address feedback:**
   - Make requested changes
   - Push updates to the same branch
   - Respond to comments

### PR Review Criteria

Your PR will be reviewed for:
- **Functionality**: Does it work as intended?
- **Code quality**: Is it clean and maintainable?
- **Tests**: Are there tests (when applicable)?
- **Documentation**: Is it documented?
- **Style**: Does it follow coding standards?
- **Breaking changes**: Are they necessary and documented?

### After Merge

1. **Delete your branch:**
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

2. **Update your fork:**
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

---

## Release Process

*For maintainers only*

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **Major (X.0.0)**: Breaking changes
- **Minor (x.Y.0)**: New features, backwards compatible
- **Patch (x.y.Z)**: Bug fixes

### Creating a Release

1. **Update version numbers:**
   - package.json (MCP server)
   - Any version constants

2. **Update CHANGELOG:**
   - Document all changes since last release
   - Categorize: Features, Bug Fixes, Breaking Changes

3. **Create git tag:**
   ```bash
   git tag -a v1.2.3 -m "Release 1.2.3"
   git push origin v1.2.3
   ```

4. **Create GitHub release:**
   - Use tag v1.2.3
   - Copy CHANGELOG entry
   - Upload any release artifacts

5. **Announce:**
   - Update README with new version
   - Notify users (if applicable)

---

## Getting Help

### Questions?

- **GitHub Discussions**: Ask questions
- **GitHub Issues**: Report bugs or request features
- **Documentation**: Check README and ARCHITECTURE.md

### Communication

- Be patient and respectful
- Provide context and details
- Share relevant logs or screenshots
- Follow up on responses

---

## Recognition

Contributors will be recognized in:
- Git commit history
- GitHub contributors page
- Release notes (for significant contributions)

Thank you for contributing to Project Manager! 🎉

---

## Quick Reference

### Common Commands

```bash
# Fork and clone
gh repo fork davewil/automation --clone

# Create feature branch
git checkout -b feature/my-feature

# Make changes, test, commit
git add .
git commit -m "feat: description"

# Push and create PR
git push origin feature/my-feature
gh pr create

# Keep fork updated
git fetch upstream
git rebase upstream/main
```

### Helpful Links

- [GitHub Issues](https://github.com/davewil/automation/issues)
- [Pull Requests](https://github.com/davewil/automation/pulls)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Architecture Documentation](ARCHITECTURE.md)

---

**Last Updated:** November 27, 2025
