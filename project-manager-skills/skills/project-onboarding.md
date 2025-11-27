# Project Onboarding - Generate Comprehensive Onboarding Documentation

## Description

Automatically generate comprehensive onboarding documentation for new team members or contributors. This skill analyzes your project structure, dependencies, configuration, and creates tailored documentation that helps developers get up and running quickly.

## Prerequisites

- Project must be registered in Project Manager
- Project directory must exist locally
- Project should have a README (or skill will create one)
- User wants to create or improve onboarding documentation

## Instructions

When this skill is invoked, help the user create comprehensive onboarding documentation:

### 1. Analyze Project Structure

Start by understanding the project:

```bash
cd <project_path>

# Analyze project structure
echo "Analyzing project structure..."

# Get project info from Project Manager
project_info=$(jq -r ".\"$project_name\"" ~/.config/project-manager/projects.json)
project_type=$(echo "$project_info" | jq -r '.project_type // empty')
github_url=$(echo "$project_info" | jq -r '.github // empty')

# Analyze directory structure
find . -maxdepth 2 -type d ! -path '*/.*' ! -path './node_modules' ! -path './deps' ! -path './_build' | sort

# Check for common files
files_found=""
[ -f "README.md" ] && files_found="$files_found README.md"
[ -f "CONTRIBUTING.md" ] && files_found="$files_found CONTRIBUTING.md"
[ -f "LICENSE" ] && files_found="$files_found LICENSE"
[ -f ".env.example" ] && files_found="$files_found .env.example"
[ -f "docker-compose.yml" ] && files_found="$files_found docker-compose.yml"
[ -f "Makefile" ] && files_found="$files_found Makefile"

# Check for CI/CD
ci_found=""
[ -d ".github/workflows" ] && ci_found="GitHub Actions"
[ -f ".gitlab-ci.yml" ] && ci_found="GitLab CI"
[ -f ".circleci/config.yml" ] && ci_found="CircleCI"

# Check for tests
test_dirs=$(find . -maxdepth 2 -type d -name 'test*' -o -name '*test*' -o -name 'spec' 2>/dev/null | head -5)
```

### 2. Identify Key Information Needed

Determine what should be included in onboarding docs:

**Project Basics:**
- Project name and description
- Tech stack and dependencies
- Repository structure
- Purpose and goals

**Getting Started:**
- Prerequisites (languages, tools, versions)
- Installation steps
- Configuration required
- First-time setup

**Development Workflow:**
- How to run the project locally
- How to run tests
- How to build
- Code style and formatting

**Contributing:**
- Branch strategy
- Commit message format
- Pull request process
- Code review guidelines

**Architecture:**
- High-level architecture
- Key directories and their purpose
- Important files
- External services/APIs

**Troubleshooting:**
- Common issues and solutions
- FAQ
- Where to get help

### 3. Gather Prerequisites Information

Collect prerequisite details:

```bash
echo "==> Gathering Prerequisites..."

# Detect required versions
case "$project_type" in
    elixir)
        elixir_version=$(grep 'elixir:' mix.exs 2>/dev/null | grep -oP '~>\s*\K[\d.]+' || cat .tool-versions 2>/dev/null | grep elixir | awk '{print $2}')
        erlang_version=$(cat .tool-versions 2>/dev/null | grep erlang | awk '{print $2}')
        database=$(grep 'adapter:' config/*.exs 2>/dev/null | head -1 | grep -oP 'Ecto\.\w+\.\K\w+')
        ;;
    dotnet)
        dotnet_version=$(grep 'TargetFramework' *.csproj 2>/dev/null | grep -oP 'net\K[\d.]+' | head -1)
        ;;
    node)
        node_version=$(cat .nvmrc 2>/dev/null || grep '"node":' package.json 2>/dev/null | grep -oP '\d+')
        package_manager=$([ -f "bun.lockb" ] && echo "bun" || [ -f "pnpm-lock.yaml" ] && echo "pnpm" || [ -f "yarn.lock" ] && echo "yarn" || echo "npm")
        ;;
    go)
        go_version=$(grep '^go ' go.mod 2>/dev/null | awk '{print $2}')
        ;;
    python)
        python_version=$(cat .python-version 2>/dev/null || grep 'python_version' Pipfile 2>/dev/null | grep -oP '\d+\.\d+')
        ;;
    rust)
        rust_version=$(grep 'rust-version' Cargo.toml 2>/dev/null | grep -oP '\d+\.\d+')
        ;;
esac

# Check for Docker
has_docker=$([ -f "Dockerfile" ] && echo "yes" || echo "no")

# Check for database
has_db=$(grep -r "DATABASE" .env.example config/ 2>/dev/null | head -1)
```

### 4. Generate Prerequisites Section

Create the prerequisites documentation:

````markdown
## Prerequisites

Before you begin, ensure you have the following installed:

### Required

- **${language}** ${version}
  - Installation: [Link to installation guide]
  - Verify: `${verify_command}`

- **${package_manager}** (for dependencies)
  - Installation: [Link]
  - Verify: `${verify_command}`

${if database}
- **${database}** ${db_version}
  - Installation: [Link]
  - Verify: `${verify_command}`
${endif}

### Optional but Recommended

- **Git** (version control)
- **${editor}** (recommended IDE/editor)
${if docker}
- **Docker** (for containerized development)
${endif}
${if has_ci}
- GitHub account (for contributing)
${endif}

### Version Management (Recommended)

We recommend using version managers to handle multiple ${language} versions:

${version_manager_instructions}
````

### 5. Generate Installation Steps

Create step-by-step installation guide:

````markdown
## Getting Started

### 1. Clone the Repository

\`\`\`bash
git clone ${github_url}
cd ${project_name}
\`\`\`

### 2. Install Dependencies

\`\`\`bash
${install_deps_command}
\`\`\`

This will install all required packages listed in ${deps_file}.

${if has_env_example}
### 3. Configure Environment

Copy the example environment file and configure it:

\`\`\`bash
cp .env.example .env
\`\`\`

Edit \`.env\` and set the following required variables:

\`\`\`bash
# Database connection
DATABASE_URL=postgresql://user:password@localhost:5432/${project_name}_dev

# Application settings
SECRET_KEY_BASE=your-secret-key-here
PORT=4000

# External services (if applicable)
API_KEY=your-api-key
\`\`\`

**Note:** Never commit \`.env\` to version control. It's already in \`.gitignore\`.
${endif}

${if has_database}
### 4. Set Up Database

Create and migrate the database:

\`\`\`bash
${db_create_command}
${db_migrate_command}
\`\`\`

Optionally, seed with test data:

\`\`\`bash
${db_seed_command}
\`\`\`
${endif}

### 5. Verify Installation

Run the test suite to ensure everything is set up correctly:

\`\`\`bash
${test_command}
\`\`\`

If all tests pass, you're ready to go! ✅
````

### 6. Generate Project Structure Documentation

Document the repository organization:

````markdown
## Project Structure

\`\`\`
${project_name}/
├── ${main_dirs_with_descriptions}
│   ├── ${subdirs}
│   └── ...
├── ${config_dirs}
├── ${test_dirs}
└── ${important_files}
\`\`\`

### Key Directories

${for each directory}
- **\`${dir_name}/\`** - ${description}
${endfor}

### Important Files

${for each file}
- **\`${file_name}\`** - ${purpose}
${endfor}
````

Example structure generation:

```bash
echo "### Key Directories"
echo ""

case "$project_type" in
    elixir)
        cat <<EOF
- **\`lib/\`** - Application source code
  - \`lib/${project_name}/\` - Core business logic
  - \`lib/${project_name}_web/\` - Web layer (controllers, views, templates)
- **\`test/\`** - Test files (mirrors lib/ structure)
- **\`config/\`** - Configuration files
  - \`config.exs\` - Shared configuration
  - \`dev.exs\` - Development environment
  - \`test.exs\` - Test environment
  - \`prod.exs\` - Production environment
- **\`priv/\`** - Static assets and database migrations
  - \`priv/repo/migrations/\` - Database migration files
  - \`priv/static/\` - Static assets
- **\`deps/\`** - Downloaded dependencies (gitignored)
- **\`_build/\`** - Compiled artifacts (gitignored)
EOF
        ;;
    node)
        cat <<EOF
- **\`src/\`** - Application source code
- **\`tests/\` or \`__tests__/\`** - Test files
- **\`public/\`** - Static assets
- **\`dist/\` or \`build/\`** - Compiled output (gitignored)
- **\`node_modules/\`** - Dependencies (gitignored)
EOF
        ;;
esac
```

### 7. Generate Development Workflow Guide

Create workflow documentation:

````markdown
## Development Workflow

### Running the Application

Start the development server:

\`\`\`bash
${run_dev_command}
\`\`\`

The application will be available at: \`http://localhost:${port}\`

${if has_hot_reload}
**Note:** Changes to source files will automatically reload. No need to restart!
${endif}

### Running Tests

Run the full test suite:

\`\`\`bash
${test_command}
\`\`\`

Run specific tests:

\`\`\`bash
${test_specific_command}
\`\`\`

${if has_coverage}
Run tests with coverage:

\`\`\`bash
${coverage_command}
\`\`\`
${endif}

### Code Formatting

Format your code before committing:

\`\`\`bash
${format_command}
\`\`\`

${if has_linter}
### Linting

Check code quality:

\`\`\`bash
${lint_command}
\`\`\`

Auto-fix issues:

\`\`\`bash
${lint_fix_command}
\`\`\`
${endif}

### Building for Production

Create a production build:

\`\`\`bash
${build_command}
\`\`\`
````

### 8. Generate Contributing Guidelines

Create contribution documentation:

````markdown
## Contributing

We welcome contributions! Here's how to get started:

### Branch Strategy

We use ${branch_strategy}:

- **\`main\`** - Production-ready code
${if has_develop}
- **\`develop\`** - Integration branch for features
${endif}
- **\`feature/*\`** - New features
- **\`fix/*\`** - Bug fixes
- **\`docs/*\`** - Documentation changes

### Making Changes

1. **Create a branch:**
   \`\`\`bash
   git checkout -b feature/your-feature-name
   \`\`\`

2. **Make your changes:**
   - Write code
   - Add tests
   - Update documentation

3. **Test your changes:**
   \`\`\`bash
   ${test_command}
   \`\`\`

4. **Format your code:**
   \`\`\`bash
   ${format_command}
   \`\`\`

5. **Commit your changes:**

   We use [Conventional Commits](https://www.conventionalcommits.org/):

   \`\`\`bash
   git commit -m "feat: add user authentication"
   git commit -m "fix: resolve login timeout issue"
   git commit -m "docs: update installation guide"
   \`\`\`

6. **Push to your fork:**
   \`\`\`bash
   git push -u origin feature/your-feature-name
   \`\`\`

7. **Create a Pull Request:**
   - Go to GitHub
   - Click "New Pull Request"
   - Fill in the PR template
   - Request review

### Code Review Process

- All PRs require at least ${min_reviews} review(s)
- CI must pass (tests, linting, builds)
- Changes should include tests
- Documentation should be updated

### Commit Message Format

\`\`\`
<type>(<scope>): <subject>

<body>

<footer>
\`\`\`

**Types:**
- \`feat\`: New feature
- \`fix\`: Bug fix
- \`docs\`: Documentation only
- \`style\`: Code style (formatting, etc.)
- \`refactor\`: Code refactoring
- \`test\`: Adding/updating tests
- \`chore\`: Maintenance tasks

**Example:**
\`\`\`
feat(auth): add JWT token refresh

Implement automatic token refresh to improve user experience.
Tokens now refresh 5 minutes before expiry.

Closes #123
\`\`\`
````

### 9. Generate Troubleshooting Guide

Create common issues documentation:

````markdown
## Troubleshooting

### Common Issues

#### Build Fails with "Dependencies Not Found"

**Problem:** Fresh clone or after pulling changes
**Solution:**
\`\`\`bash
${install_deps_command}
\`\`\`

---

#### Tests Fail with Database Connection Error

**Problem:** Database not running or misconfigured
**Solution:**
1. Ensure database is running: \`${db_check_command}\`
2. Check DATABASE_URL in \`.env\`
3. Reset database: \`${db_reset_command}\`

---

${if project_type == "elixir"}
#### Port Already in Use Error

**Problem:** Port ${port} is already in use
**Solution:**
\`\`\`bash
# Find process using port
lsof -i :${port}

# Kill the process
kill -9 <PID>

# Or use a different port
PORT=4001 ${run_command}
\`\`\`
${endif}

---

#### Permission Denied Errors

**Problem:** File permissions issue
**Solution:**
\`\`\`bash
# Fix ownership
sudo chown -R $USER:$USER .

# Fix permissions
chmod -R u+rw .
\`\`\`

### Getting Help

If you encounter issues not listed here:

1. **Check existing issues:** [GitHub Issues](${github_url}/issues)
2. **Search documentation:** Look in docs/ folder
3. **Ask the team:**
   - Slack: #${project_name}
   - Email: team@example.com
4. **Create an issue:** [New Issue](${github_url}/issues/new)

### Useful Commands

\`\`\`bash
# Clean build artifacts
${clean_command}

# Reset database
${db_reset_command}

# Check project health
# (requires Project Manager)
health-check ${project_name}

# Check for outdated dependencies
outdated ${project_name}
\`\`\`
````

### 10. Generate Complete ONBOARDING.md

Assemble all sections into comprehensive document:

```bash
echo "==> Generating ONBOARDING.md..."

cat > ONBOARDING.md <<EOF
# ${project_name} - Developer Onboarding Guide

Welcome to ${project_name}! This guide will help you get up and running quickly.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Getting Started](#getting-started)
3. [Project Structure](#project-structure)
4. [Development Workflow](#development-workflow)
5. [Contributing](#contributing)
6. [Troubleshooting](#troubleshooting)
7. [Additional Resources](#additional-resources)

---

${prerequisites_section}

${getting_started_section}

${project_structure_section}

${development_workflow_section}

${contributing_section}

${troubleshooting_section}

## Additional Resources

- [README.md](README.md) - Project overview
${if has_contributing}
- [CONTRIBUTING.md](CONTRIBUTING.md) - Detailed contribution guidelines
${endif}
${if has_architecture}
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
${endif}
- [GitHub Issues](${github_url}/issues) - Bug reports and feature requests
- [Pull Requests](${github_url}/pulls) - Ongoing development

---

**Last Updated:** $(date +%Y-%m-%d)
**Maintainer:** ${maintainer_name}

EOF

echo "✅ ONBOARDING.md created successfully!"
```

### 11. Optionally Update README.md

If README needs improvement:

```markdown
Should I also update your README.md to include a link to the onboarding guide?

I can add a section like:

## For New Contributors

If you're new to this project, start with our comprehensive [Onboarding Guide](ONBOARDING.md) which includes:
- Prerequisites and installation
- Project structure overview
- Development workflow
- Contributing guidelines
- Troubleshooting common issues

Update README.md? (Y/n):
```

### 12. Provide Summary

Give user a summary of what was created:

```
===========================================
Onboarding Documentation Generated! ✅
===========================================

Created: ONBOARDING.md (${line_count} lines)

Sections Included:
  ✅ Prerequisites (${language}, ${tools})
  ✅ Getting Started (5 steps)
  ✅ Project Structure (${dir_count} directories documented)
  ✅ Development Workflow (run, test, build, lint)
  ✅ Contributing Guidelines (branch strategy, commits, PRs)
  ✅ Troubleshooting (${issue_count} common issues)

Key Information Captured:
  • Required ${language} version: ${version}
  • Package manager: ${package_manager}
  ${if has_database}• Database: ${database}${endif}
  ${if has_docker}• Docker support: Yes${endif}
  • Port: ${port}

Next Steps:
  1. Review ONBOARDING.md and customize as needed
  2. Add project-specific information
  3. Test the guide with a new team member
  4. Commit and push:
     git add ONBOARDING.md
     git commit -m "docs: add comprehensive onboarding guide"
     git push

Your new developers will thank you! 🎉
```

## Context

Use this skill when:
- Onboarding new team members
- Project lacks documentation
- Want to improve contributor experience
- Open-sourcing a project
- Creating documentation for handoff
- Starting a new team initiative

## Example Usage

**Scenario 1: New open-source project**

```
User: "I want to open-source my grocery-planner project, help me create onboarding docs"

Claude: I'll help you create comprehensive onboarding documentation for grocery-planner.

[Analyzes project structure]

Found:
  • Project type: Node.js (React + TypeScript)
  • Package manager: bun
  • Database: PostgreSQL
  • Docker: Yes
  • CI/CD: GitHub Actions

Generating onboarding guide with:
  ✓ Prerequisites (Node 18+, bun, PostgreSQL)
  ✓ Installation steps
  ✓ Project structure explanation
  ✓ Development workflow
  ✓ Contributing guidelines
  ✓ Troubleshooting

[Creates ONBOARDING.md]

✅ Created comprehensive onboarding guide (487 lines)

The guide includes everything a new contributor needs to get started!
Would you also like me to create a CONTRIBUTING.md for detailed contribution guidelines?
```

**Scenario 2: Improving existing documentation**

```
User: "Our current README is too basic, can you create better onboarding docs?"

Claude: I'll analyze your project and create detailed onboarding documentation.

[Checks existing README.md]

Your current README covers:
  ✓ Basic description
  ✓ Installation command
  ✗ Prerequisites missing
  ✗ Project structure not explained
  ✗ Development workflow not documented
  ✗ Contributing guidelines missing

I'll create a comprehensive ONBOARDING.md that covers all these areas.

[Generates documentation]

✅ ONBOARDING.md created with:
  • Detailed prerequisites with version requirements
  • Step-by-step installation (5 steps)
  • Project structure with descriptions
  • Complete development workflow
  • Contributing guidelines with examples
  • Troubleshooting for 6 common issues

Should I update your README.md to link to the new onboarding guide?
```

## Error Handling

Handle these scenarios:

### 1. Cannot Detect Project Type

```
⚠️  Could not automatically detect project type

I can see files but couldn't determine the primary language/framework.

Found files:
  • package.json (Node.js?)
  • requirements.txt (Python?)
  • Makefile

Is this a multi-language project, or should I focus on one stack?

Please specify:
  1. Primary language/framework
  2. Or mark as "polyglot" project

Which approach? (1/2):
```

### 2. Missing Key Information

```
⚠️  Some information is missing for complete onboarding docs

Could not find:
  • .env.example (environment variables)
  • Database configuration
  • Test examples

I can still create the guide, but it will have placeholders like:

  "Configure environment variables (see your team lead for required values)"

Options:
  1. Create guide with placeholders (you can fill in later)
  2. Help me create .env.example first
  3. Skip environment section

What would you like? (1/2/3):
```

### 3. Very Large Project

```
ℹ️  This is a large project with many directories

Found 47 top-level directories and 234 source files.

For readability, I'll:
  • Document only key directories (not all 47)
  • Focus on main entry points
  • Create simplified structure diagram

Alternatively, I can create separate docs for each major component.

Approach:
  1. Single comprehensive guide (may be long)
  2. Multiple guides (ONBOARDING.md + per-component docs)

Which approach? (1/2):
```

### 4. Existing ONBOARDING.md

```
⚠️  ONBOARDING.md already exists

Options:
  1. Overwrite with new version (backup old one)
  2. Create ONBOARDING_NEW.md for comparison
  3. Update/merge with existing content
  4. Cancel

What would you like to do? (1-4):
```

## Success Criteria

The skill is successful when:
- ✓ ONBOARDING.md is created with all key sections
- ✓ Prerequisites are clearly documented with versions
- ✓ Installation steps are complete and tested
- ✓ Project structure is explained
- ✓ Development workflow is documented
- ✓ Contributing guidelines are clear
- ✓ Common issues have solutions
- ✓ New developers can onboard independently

## Tips

- **Be comprehensive but concise**: Cover everything, but keep it scannable
- **Use actual commands**: Show exact commands, not pseudocode
- **Include versions**: Specify required versions for tools
- **Visual aids**: Use directory trees and code blocks
- **Test it**: Have someone new try following the guide
- **Keep updated**: Note last updated date
- **Link resources**: Reference external docs where appropriate
- **Troubleshoot common issues**: Anticipate problems
- **Make it welcoming**: Friendly tone for new contributors

## Advanced Features

### Multi-Language Projects

For polyglot projects:

```markdown
## Tech Stack

This project uses multiple languages:

### Backend (Elixir)
- **Location:** `backend/`
- **Setup:** See [Backend Setup](backend/README.md)
- **Prerequisites:** Elixir 1.14+, PostgreSQL

### Frontend (TypeScript + React)
- **Location:** `frontend/`
- **Setup:** See [Frontend Setup](frontend/README.md)
- **Prerequisites:** Node 18+, bun

### Mobile (React Native)
- **Location:** `mobile/`
- **Setup:** See [Mobile Setup](mobile/README.md)
- **Prerequisites:** Node 18+, Xcode/Android Studio
```

### Docker-First Setup

For projects with Docker:

```markdown
## Quick Start with Docker (Recommended)

The fastest way to get started:

\`\`\`bash
# Clone and start
git clone ${github_url}
cd ${project_name}
docker-compose up
\`\`\`

That's it! The application will be available at http://localhost:${port}

### What Docker Compose Does

- Builds the application image
- Starts PostgreSQL database
- Runs database migrations
- Seeds test data
- Starts the dev server with hot reload

### Manual Setup (Without Docker)

If you prefer not to use Docker, see [Manual Setup](#manual-setup) below.
```

### Onboarding Checklist

Include an interactive checklist:

```markdown
## Onboarding Checklist

Copy this checklist and check off as you complete each step:

- [ ] Clone repository
- [ ] Install prerequisites (${language}, ${tools})
- [ ] Install dependencies
- [ ] Configure environment (.env)
- [ ] Set up database
- [ ] Run tests (verify setup)
- [ ] Start dev server
- [ ] Make a small change and see it reload
- [ ] Read contributing guidelines
- [ ] Join team Slack/Discord
- [ ] Introduce yourself to the team
- [ ] Pick up your first issue

When complete, you're fully onboarded! 🎉
```

### Video Walkthrough

Include multimedia:

```markdown
## Video Walkthrough

Prefer video? Watch our setup walkthrough:

[![Setup Walkthrough](thumbnail.png)](https://youtu.be/example)

Topics covered:
- Prerequisites installation (5:00)
- Project setup (10:00)
- Running your first feature (15:00)
- Common troubleshooting (20:00)
```

### Architecture Diagram

Include visual architecture:

```markdown
## Architecture Overview

\`\`\`
┌─────────────┐      ┌──────────────┐      ┌───────────┐
│   Browser   │─────▶│   Phoenix    │─────▶│ PostgreSQL│
│  (Frontend) │◀─────│   (Backend)  │◀─────│ (Database)│
└─────────────┘      └──────────────┘      └───────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │ External API │
                     │   (Stripe)   │
                     └──────────────┘
\`\`\`

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design.
```
