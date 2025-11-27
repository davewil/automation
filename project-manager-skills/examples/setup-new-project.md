# Example: Setting Up a New Project

This example demonstrates using the **project-setup** skill to add a newly cloned repository to Project Manager.

## Scenario

You've just cloned the `grocery-planner` repository and want to set it up in your Project Manager for easy access to build, test, and deployment commands.

## Walkthrough

### Starting the Interaction

```
You: I just cloned the grocery-planner repo, help me set it up in project manager

Claude: I'll help you set up the grocery-planner project in Project Manager.
Let me verify we're in a git repository...
```

At this point, Claude invokes the **project-setup** skill and begins the workflow.

### Step 1: Environment Verification

```
Claude: ✓ Confirmed this is a git repository

Let me gather some information about your project...
```

Claude checks for:
- `.git` directory exists
- Git remote origin is configured
- Current directory path

### Step 2: Project Detection

```
Claude: I've detected the following:

Project Details:
- Name: grocery-planner
- Path: /home/user/projects/grocery-planner
- Git Remote: git@github.com:user/grocery-planner.git
- Type: Elixir (detected mix.exs)

This looks like an Elixir Phoenix application!
```

Claude automatically detects:
- Project name from directory
- Full path
- Git remote URL
- Project type (found mix.exs file)

### Step 3: Configuration Prompts

```
Claude: Now I need a few details to complete the setup.

Please provide a brief description of this project:
```

```
You: A grocery planning and shopping list application
```

```
Claude: Great! Which editor would you like to use?

Common options: code, vim, nvim, nano, emacs
Your current $EDITOR: code

Press Enter to use 'code' or specify another:
```

```
You: [Enter]
```

```
Claude: Should this project auto-pull latest changes when opened?

This ensures you're always working with the latest code. Recommended for
active projects.

Auto-pull on open? (Y/n):
```

```
You: y
```

### Step 4: Configuration Preview

```
Claude: Perfect! Here's what will be added to your Project Manager configuration:

=================================
Configuration Preview
=================================

Name:        grocery-planner
Path:        /home/user/projects/grocery-planner
GitHub:      git@github.com:user/grocery-planner.git
Type:        elixir
Description: A grocery planning and shopping list application
Editor:      code
Auto-pull:   true

Project Type Settings (elixir):
- Build: mix compile
- Test: mix test
- Run: mix phx.server
- Format: mix format
- Deps: mix deps.get

Is this correct? (Y/n):
```

```
You: y
```

### Step 5: Adding to Configuration

```
Claude: Adding grocery-planner to Project Manager...

[Executing: projects --add]

✓ Successfully added grocery-planner to Project Manager!

The project has been added to: ~/.config/project-manager/projects.json
```

### Step 6: Verification

```
Claude: Let me verify the project was added successfully...

[Executing: projects | grep grocery-planner]

✓ Confirmed: grocery-planner appears in your project list
```

### Step 7: Next Steps

```
Claude: Perfect! Your project is now set up. Here's what you can do next:

Quick Start Commands:
====================

Navigation:
  goto grocery-planner          Navigate to project directory
  open grocery-planner          Open with smart workflow (pull, check deps, build, test)

Build & Test:
  build grocery-planner         Compile the project
  test grocery-planner          Run test suite
  run grocery-planner           Start Phoenix server
  watch grocery-planner         Start in watch mode

Dependencies:
  outdated grocery-planner      Check for outdated packages

Git Workflow:
  push grocery-planner "msg"    Smart push (pull, build, test, commit, push)

Project-Specific Setup:
=======================

Since this is an Elixir project, you'll need to:

1. Install dependencies:
   cd /home/user/projects/grocery-planner
   mix deps.get

2. Set up database (if applicable):
   mix ecto.create
   mix ecto.migrate

3. Install Node dependencies (for Phoenix):
   cd assets && npm install

Would you like me to help you with the initial setup? I can:
- Run dependency installation
- Perform an initial build
- Run the test suite to verify everything works

What would you like to do next?
```

### User Chooses Initial Build

```
You: Yes, let's do an initial build
```

```
Claude: Great! I'll help you get everything set up and verified.

Step 1: Installing dependencies...
[Executing: cd /home/user/projects/grocery-planner && mix deps.get]

Resolving Hex dependencies...
Resolution completed in 0.8s
All dependencies are up to date

✓ Dependencies installed

Step 2: Building project...
[Executing: build grocery-planner]

Compiling 47 files (.ex)
Generated grocery_planner app

✓ Build successful (2.3 seconds)

Step 3: Running tests...
[Executing: test grocery-planner]

..............................................

Finished in 1.8 seconds
47 tests, 0 failures

Randomized with seed 123456

✓ All tests passing!

====================
Setup Complete! ✓
====================

Your grocery-planner project is fully configured and verified:
- ✓ Added to Project Manager
- ✓ Dependencies installed
- ✓ Build successful
- ✓ All tests passing

You're ready to start developing!

Try these commands:
  goto grocery-planner       # Navigate to the project
  open grocery-planner       # Open in VS Code with full workflow
  watch grocery-planner      # Start Phoenix server in watch mode

Happy coding! 🎉
```

## Key Takeaways

### What the Skill Did

1. **Verified environment** - Checked git repository status
2. **Detected project type** - Automatically identified Elixir/Phoenix
3. **Gathered configuration** - Asked for description, editor, auto-pull preference
4. **Showed preview** - Let you verify before committing changes
5. **Added to config** - Registered project in Project Manager
6. **Verified success** - Confirmed project was added
7. **Provided guidance** - Suggested next steps and commands
8. **Offered setup** - Helped with initial build and verification

### Benefits

- **No manual JSON editing** - Skill handled configuration file
- **Automatic detection** - Project type identified automatically
- **Best practices** - Recommended settings based on project type
- **Verification** - Ensured everything works before finishing
- **Learning** - Explained what each command does
- **Time saved** - Complete setup in under a minute

### Commands Used

The skill executed these Project Manager commands:
```bash
projects --add              # Added project to configuration
projects | grep <name>      # Verified addition
build <name>               # Built the project
test <name>                # Ran tests
```

## Variations

### Different Project Types

**Node.js project:**
```
Claude: I've detected this is a Node.js project (found package.json).

Type: node
Build: bun run build
Test: bun test
Run: bun run start

Would you like me to run 'bun install' to install dependencies?
```

**.NET project:**
```
Claude: I've detected this is a .NET project (found *.csproj).

Type: dotnet
Build: dotnet build
Test: dotnet test
Run: dotnet run

Would you like me to run 'dotnet restore' to restore packages?
```

### Project Already Exists

```
Claude: I found that grocery-planner already exists in your Project Manager configuration.

Current configuration:
{
  "github": "git@github.com:user/grocery-planner.git",
  "local_path": "/home/user/projects/grocery-planner",
  "editor": "code",
  "auto_pull": true,
  "description": "Grocery planning app",
  "project_type": "elixir"
}

Would you like to:
1. Update the existing configuration
2. View the current configuration
3. Cancel

What would you like to do?
```

### No Project Type Detected

```
Claude: I couldn't automatically detect the project type.

No characteristic files found (mix.exs, package.json, Cargo.toml, etc.)

Supported types: elixir, dotnet, node, go, python, rust

You can:
1. Continue without a project type (commands won't work until type is set)
2. Manually specify a type now
3. Edit the configuration later with: projects --edit

What would you like to do?
```

## Next Steps

After setup, you might want to:

1. **Check project health**: Use the **project-health-check** skill
2. **Start a feature**: Use the **project-workflow** skill
3. **Update dependencies**: Use the **dependency-manager** skill (Phase 2)

## Related Skills

- **project-health-check**: Analyze project status after setup
- **project-workflow**: Start implementing features
- **project-switcher**: Navigate between projects (Phase 2)
