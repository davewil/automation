# Project Switcher - Smart Project Navigation and Context Switching

## Description

Intelligent project switching that helps users navigate between projects while managing context, uncommitted changes, and ensuring clean transitions. This skill makes it easy to jump between multiple projects without losing work or leaving projects in inconsistent states.

## Prerequisites

- Multiple projects must be registered in Project Manager
- Projects must exist locally
- User wants to switch between projects

## Instructions

When this skill is invoked, help the user safely switch projects:

### 1. Understand Current Context

Start by checking the current project state:

```bash
# Determine current project
current_dir=$(pwd)
current_project=""

# Check if in a project directory
for project in $(projects | awk '{print $1}'); do
    project_path=$(goto "$project" 2>&1 | grep -o '/.*')
    if [[ "$current_dir" == "$project_path"* ]]; then
        current_project="$project"
        break
    fi
done

if [ -n "$current_project" ]; then
    echo "Currently in: $current_project"

    # Check for uncommitted changes
    if [ -d ".git" ]; then
        uncommitted=$(git status --porcelain)
        branch=$(git rev-parse --abbrev-ref HEAD)
        echo "Branch: $branch"

        if [ -n "$uncommitted" ]; then
            echo "⚠️  Uncommitted changes detected"
        fi
    fi
else
    echo "Not currently in a registered project"
fi
```

### 2. List Available Projects

Show user all available projects:

```
===========================================
Available Projects
===========================================

Your Projects:
--------------

1. grocery-planner     [Node.js]    ~/projects/grocery-planner
   Status: ✓ Clean, on main branch
   Last active: 2 hours ago

2. api-server          [Elixir]     ~/projects/api-server
   Status: ⚠️  Uncommitted changes, on feature/auth branch
   Last active: 3 days ago

3. mobile-app          [Rust]       ~/projects/mobile-app
   Status: ✓ Clean, on main branch
   Last active: 1 week ago

4. automation          [Multi]      ~/Development/automation
   Status: ✓ Clean, on main branch
   Last active: 5 minutes ago (current)

Currently in: automation (project 4)

Which project would you like to switch to? (1-4 or name):
```

### 3. Get User's Destination

Ask where they want to go:

```
Where would you like to go?

Options:
  • Enter project number (1-4)
  • Enter project name (e.g., "grocery-planner")
  • Enter "list" to see projects again
  • Enter "recent" to see recently used projects

>
```

**Handle different inputs:**

```bash
case "$input" in
    [0-9]*)
        # Numeric selection
        target_project=$(projects | sed -n "${input}p" | awk '{print $1}')
        ;;
    list)
        # Show list again
        ;;
    recent)
        # Show recently accessed projects
        ;;
    *)
        # Treat as project name
        target_project="$input"
        ;;
esac
```

### 4. Check Current Project for Uncommitted Changes

Before switching, handle current project state:

```bash
if [ -n "$current_project" ] && [ -d ".git" ]; then
    uncommitted=$(git status --porcelain)

    if [ -n "$uncommitted" ]; then
        echo ""
        echo "⚠️  You have uncommitted changes in $current_project:"
        git status --short
        echo ""
        echo "What would you like to do?"
        echo "  1. Commit changes now"
        echo "  2. Stash changes (save for later)"
        echo "  3. Discard changes (⚠️  DANGER)"
        echo "  4. Cancel switch (stay here)"
        echo ""
        read -p "Choose option (1-4): " option

        case "$option" in
            1)
                # Guide through commit
                echo "Let's commit your changes..."
                git add -A
                read -p "Commit message: " msg
                git commit -m "$msg"
                echo "✅ Changes committed"
                ;;
            2)
                # Stash changes
                echo "Stashing changes..."
                git stash push -m "Auto-stash before switching to $target_project"
                echo "✅ Changes stashed"
                echo "ℹ️  To restore later: git stash pop"
                ;;
            3)
                # Discard (with confirmation)
                read -p "⚠️  Really discard all changes? (yes/NO): " confirm
                if [ "$confirm" = "yes" ]; then
                    git checkout .
                    git clean -fd
                    echo "✅ Changes discarded"
                else
                    echo "Cancelled"
                    exit 0
                fi
                ;;
            4)
                echo "Switch cancelled"
                exit 0
                ;;
        esac
    fi
fi
```

### 5. Check Target Project Status

Before switching, check target project health:

```bash
# Get target project info
target_path=$(goto "$target_project" 2>&1 | grep -o '/.*')

if [ ! -d "$target_path" ]; then
    echo "❌ Project directory not found: $target_path"
    echo "Would you like to clone it? (Y/n): "
    # Handle cloning if needed
    exit 1
fi

# Check git status of target
cd "$target_path"

if [ -d ".git" ]; then
    # Check if behind remote
    git fetch origin
    branch=$(git rev-parse --abbrev-ref HEAD)
    behind=$(git rev-list --count HEAD..origin/$branch 2>/dev/null || echo 0)

    if [ "$behind" -gt 0 ]; then
        echo ""
        echo "ℹ️  $target_project is $behind commits behind origin/$branch"
        read -p "Pull latest changes before switching? (Y/n): " pull

        if [ "$pull" != "n" ]; then
            git pull origin "$branch"
            echo "✅ Updated to latest"
        fi
    fi

    # Check for uncommitted changes in target
    uncommitted=$(git status --porcelain)
    if [ -n "$uncommitted" ]; then
        echo ""
        echo "⚠️  Target project has uncommitted changes:"
        git status --short
    fi
fi
```

### 6. Switch to Target Project

Execute the switch:

```bash
echo ""
echo "==> Switching to $target_project..."

# Navigate to project
goto "$target_project"

# Verify switch
if [ $? -eq 0 ]; then
    echo "✅ Switched to: $(pwd)"
else
    echo "❌ Failed to switch to $target_project"
    exit 1
fi
```

### 7. Set Up Target Project Context

After switching, set up the environment:

```bash
echo ""
echo "==> Setting up project context..."

# Source project-specific environment
if [ -f ".envrc" ]; then
    echo "Loading .envrc..."
    # Use direnv if available
    if command -v direnv &> /dev/null; then
        direnv allow
    fi
fi

if [ -f ".env" ]; then
    echo "Loading .env..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check project health
echo ""
echo "Quick health check:"

# Git status
if [ -d ".git" ]; then
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "  Branch: $branch"

    uncommitted=$(git status --porcelain | wc -l)
    if [ "$uncommitted" -gt 0 ]; then
        echo "  Changes: $uncommitted files modified"
    else
        echo "  Changes: Clean working tree ✓"
    fi
fi

# Check dependencies
echo ""
read -p "Check dependencies? (y/N): " check_deps

if [ "$check_deps" = "y" ]; then
    outdated "$target_project"
fi

# Offer to build
echo ""
read -p "Build project? (y/N): " do_build

if [ "$do_build" = "y" ]; then
    build "$target_project"
fi

# Offer to run tests
echo ""
read -p "Run tests? (y/N): " do_test

if [ "$do_test" = "y" ]; then
    test "$target_project"
fi
```

### 8. Open Editor (Optional)

Offer to open in editor:

```bash
echo ""
read -p "Open in editor? (Y/n): " open_editor

if [ "$open_editor" != "n" ]; then
    # Get configured editor for project
    editor=$(jq -r ".\"$target_project\".editor // \"nvim\"" ~/.config/project-manager/projects.json)

    echo "Opening $target_project in $editor..."
    $editor .
fi
```

### 9. Show Context Summary

Provide a summary of the switch:

```
===========================================
Switched to: grocery-planner ✅
===========================================

Project Details:
  Type: Node.js
  Path: ~/projects/grocery-planner
  Branch: main
  Status: Clean working tree ✓

Recent Activity:
  • Last commit: 2 hours ago
  • Message: "Add shopping list feature"
  • Author: You

Quick Commands:
  build grocery-planner       Build the project
  test grocery-planner        Run tests
  run grocery-planner         Start dev server
  watch grocery-planner       Start in watch mode
  outdated grocery-planner    Check dependencies

You're all set! Start coding 🚀
```

### 10. Track Recent Projects

Maintain a list of recently accessed projects:

```bash
# Update recent projects list
recent_file="$HOME/.config/project-manager/recent.json"

# Add current project to recent list
jq --arg project "$target_project" --arg time "$(date -Iseconds)" \
    '.recent |= [{"name": $project, "timestamp": $time}] + . | .recent |= unique_by(.name) | .recent |= .[0:10]' \
    "$recent_file" > "$recent_file.tmp" && mv "$recent_file.tmp" "$recent_file"
```

## Context

Use this skill when:
- User wants to switch between projects
- User says "switch to", "work on", "go to"
- User needs to check multiple projects
- User is context-switching between tasks
- User asks "what projects do I have?"

## Example Usage

**Scenario 1: Simple switch with no changes**

```
User: "Switch to grocery-planner"

Claude: I'll help you switch to grocery-planner.

Currently in: automation
Status: Clean working tree ✓

==> Switching to grocery-planner...
✅ Switched to: ~/projects/grocery-planner

Quick health check:
  Branch: main
  Changes: Clean working tree ✓
  Dependencies: Up to date

You're all set! Start coding 🚀
```

**Scenario 2: Switch with uncommitted changes**

```
User: "Switch to api-server"

Claude: Before switching, I noticed you have uncommitted changes in automation:

M  project-manager/install.sh
M  README.md

What would you like to do?
  1. Commit changes now
  2. Stash changes (save for later)
  3. Discard changes (⚠️  DANGER)
  4. Cancel switch (stay here)

Choose option (1-4): 2

Stashing changes...
✅ Changes stashed
ℹ️  To restore later: git stash pop

==> Switching to api-server...
✅ Switched to: ~/projects/api-server

Target project has uncommitted changes:
M  lib/auth.ex
?? lib/new_feature.ex

Quick health check:
  Branch: feature/auth
  Changes: 2 files modified

You're working on the auth feature. Continue where you left off!
```

**Scenario 3: Switch to project behind remote**

```
User: "Go to mobile-app"

Claude: Switching to mobile-app...

ℹ️  mobile-app is 5 commits behind origin/main
Pull latest changes before switching? (Y/n): y

Updating main...
remote: Counting objects: 15
Receiving objects: 100% (15/15), done.
✅ Updated to latest

==> Switching to mobile-app...
✅ Switched to: ~/projects/mobile-app

Quick health check:
  Branch: main
  Changes: Clean working tree ✓

Recent commits (pulled):
  • feat: Add biometric authentication
  • fix: Resolve camera permissions issue
  • chore: Update dependencies

Your project is up to date! Ready to work.
```

**Scenario 4: Interactive project selection**

```
User: "I want to work on a different project"

Claude: I'll help you switch projects. Here are your available projects:

1. grocery-planner     [Node.js]    Clean, main branch
2. api-server          [Elixir]     Uncommitted changes, feature/auth
3. mobile-app          [Rust]       Clean, main branch
4. automation          [Multi]      Clean, main branch (current)

Which project would you like to switch to? (1-4 or name): 1

==> Switching to grocery-planner...
✅ Switched to: ~/projects/grocery-planner

Build project? (y/N): y

Building grocery-planner...
✅ Build successful

Run tests? (y/N): y

Running tests...
✅ All 47 tests passing

Open in editor? (Y/n): y
Opening grocery-planner in code...

You're all set! Happy coding 🚀
```

## Error Handling

Handle these scenarios:

### 1. Project Not Found

```
❌ Project 'unknown-project' not found

Available projects:
  • grocery-planner
  • api-server
  • mobile-app
  • automation

Did you mean one of these? Or would you like to add a new project?
```

### 2. Project Directory Missing

```
❌ Project directory not found: ~/projects/grocery-planner

The project is configured but the directory doesn't exist.

Options:
  1. Clone from GitHub: https://github.com/user/grocery-planner
  2. Update project path in configuration
  3. Remove project from configuration

What would you like to do? (1-3):
```

### 3. Conflicting Changes (Both Projects Dirty)

```
⚠️  Both projects have uncommitted changes

Current project (automation):
  M  README.md
  M  install.sh

Target project (api-server):
  M  lib/auth.ex
  ?? lib/new_feature.ex

Recommendation: Commit or stash changes in automation first, then switch.

Would you like to:
  1. Commit changes in automation, then switch
  2. Stash changes in automation, then switch
  3. Cancel switch
```

### 4. Merge Conflicts in Target

```
⚠️  Target project (api-server) has merge conflicts

Files with conflicts:
  • lib/auth.ex
  • config/config.exs

You'll need to resolve these conflicts before working on this project.

Continue with switch? (y/N):
```

### 5. Build Broken in Target

```
⚠️  Last build of api-server failed

The target project has build issues. You may want to fix these before starting
new work.

Continue with switch anyway? (y/N): y

==> Switching to api-server...
✅ Switched

ℹ️  Reminder: Build is currently broken. Run build-fixer to diagnose.
```

## Success Criteria

The skill is successful when:
- ✓ Current project state is preserved (committed/stashed)
- ✓ Successfully navigated to target project
- ✓ Target project is up to date (if requested)
- ✓ User understands target project state
- ✓ Environment is properly configured
- ✓ User is ready to start working
- ✓ Recent projects list is updated

## Tips

- **Always save work**: Commit or stash before switching
- **Check target state**: Know what you're switching into
- **Update often**: Pull latest before starting work
- **Clean transitions**: Leave projects in good state
- **Track context**: Use branch names, stash messages
- **Quick checks**: Run quick health check on arrival
- **Recent list**: Track frequently used projects
- **Batch switches**: If checking multiple, list first
- **Document state**: Note WIP in commits/stashes

## Advanced Features

### Smart Project Recommendations

```
Based on your recent activity, you might want to:

Recommended:
  • api-server (you were working on this earlier today)
  • grocery-planner (has uncommitted work from yesterday)

Related Projects:
  • mobile-app (shares code with api-server)

Haven't touched in a while:
  • automation (last active 2 weeks ago)
```

### Multi-Project Operations

```
Would you like to check the status of all projects?

Checking all 4 projects...

✅ grocery-planner - Clean, up to date
⚠️  api-server - 3 uncommitted files
⚠️  mobile-app - 5 commits behind remote
✅ automation - Clean, up to date

Would you like to:
  1. Update all projects to latest
  2. Switch to a project that needs attention
  3. View detailed status of a specific project
```

### Context Preservation

```
Saving current context for later...

Context saved:
  • Working directory: ~/automation/project-manager
  • Branch: main
  • Last command: vim install.sh
  • Terminal position: Line 234

When you return, I can restore:
  • Same directory
  • Same file open (if using supported editor)
  • Same terminal state
```

### Project Workspaces

```
You have multiple related projects. Create a workspace?

Workspace: "E-commerce Stack"
  • api-server (backend)
  • mobile-app (frontend)
  • admin-dashboard (admin UI)

With workspaces you can:
  • Switch between related projects quickly
  • Update all projects at once
  • Run commands across all projects
  • See combined status

Create workspace? (Y/n):
```

### Time Tracking Integration

```
Switching from automation to grocery-planner...

Time spent on automation this session: 1 hour 23 minutes

Would you like to log this time? (y/N):
  Project: automation
  Duration: 1h 23m
  Activity: [What were you working on?]
```
