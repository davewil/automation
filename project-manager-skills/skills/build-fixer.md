# Build Fixer - Automated Build Troubleshooting

## Description

Intelligent build troubleshooting that analyzes build failures, identifies root causes, and provides step-by-step fixes. This skill helps users quickly diagnose and resolve common build issues across different project types.

## Prerequisites

- Project must be registered in Project Manager
- Project directory must exist locally
- Build command must be configured for project type
- User is experiencing build failures or errors

## Instructions

When this skill is invoked, help the user diagnose and fix build issues:

### 1. Capture Build Error

Start by running the build and capturing the full error output:

```bash
cd <project_path>

# Run build and capture output
build <project_name> 2>&1 | tee /tmp/build-error.log

# Get exit code
build_status=$?
```

**If build succeeds:**
```
✅ Build successful!

There doesn't appear to be any build issues. The project builds cleanly.

Build time: X.X seconds
Output size: X MB

Is there a specific issue you're experiencing?
```

**If build fails, proceed with diagnosis.**

### 2. Categorize Error Type

Analyze the error output to identify the category:

**Dependency Errors:**
- Missing packages/modules
- Version conflicts
- Unresolved dependencies
- Keywords: "not found", "missing", "unresolved", "conflict"

**Compilation Errors:**
- Syntax errors
- Type errors
- Import/namespace errors
- Keywords: "syntax error", "type mismatch", "undefined", "cannot find"

**Configuration Errors:**
- Missing config files
- Invalid configuration
- Environment variables not set
- Keywords: "config", "environment", "not configured"

**Resource Errors:**
- Out of memory
- Disk space
- File permissions
- Keywords: "out of memory", "disk full", "permission denied"

**Toolchain Errors:**
- Wrong compiler version
- Missing build tools
- Incompatible SDKs
- Keywords: "requires version", "not installed", "incompatible"

### 3. Parse and Highlight Key Errors

Extract the most important error messages:

```
===========================================
Build Error Analysis: <project_name>
===========================================

Build Command: <build_command>
Exit Code: <code>
Error Category: <category>

KEY ERRORS
----------

Error 1: [COMPILATION]
  File: lib/user_controller.ex:45:12
  Message: undefined function authenticate/2

  Code:
    44 │   def login(conn, params) do
    45 │     case Auth.authenticate(params) do
       │              ^^^^^^^^^^^^ undefined
    46 │       {:ok, user} -> render_success(user)

Error 2: [DEPENDENCY]
  Package: phoenix_live_view
  Message: dependency not found in mix.lock

  Cause: Missing dependency in project

Error 3: [TYPE]
  File: lib/helpers.ex:23:5
  Message: type mismatch - expected String.t(), got Integer
```

### 4. Identify Root Cause

Analyze errors to find the root cause:

**Use pattern matching:**

**Pattern: "dependency not found"**
- Root cause: Missing dependency installation
- Likely fix: Run dependency install command

**Pattern: "undefined function/variable"**
- Root cause: Missing import, typo, or API change
- Likely fix: Add import or check API docs

**Pattern: "type mismatch"**
- Root cause: Wrong data type being passed
- Likely fix: Convert type or fix function signature

**Pattern: "file not found"**
- Root cause: Missing file or wrong path
- Likely fix: Create file or fix path

**Pattern: "version conflict"**
- Root cause: Incompatible dependency versions
- Likely fix: Update dependencies or resolve conflict

**Explain to user:**
```
ROOT CAUSE ANALYSIS
-------------------

Primary Issue: Missing dependencies

The build is failing because dependencies aren't installed. This typically
happens when:
  • You just cloned the repository
  • Someone else updated dependencies
  • You switched branches
  • Lock file was deleted

The error "dependency not found in mix.lock" confirms this.

Secondary Issues: 2 compilation errors

These are likely caused by the missing dependencies. Once we install
dependencies, these should resolve automatically.

Recommended Fix: Install dependencies first, then rebuild
```

### 5. Provide Fix Steps

Create a step-by-step fix plan:

```
===========================================
Fix Plan: <project_name>
===========================================

I've identified the issue and created a fix plan. We'll fix this in 3 steps:

STEP 1: Install Dependencies
----------------------------
Command: mix deps.get
Why: Build is failing due to missing dependencies
Time: ~30 seconds

STEP 2: Rebuild Project
-----------------------
Command: build <project_name>
Why: Verify dependencies are resolved
Time: ~1 minute

STEP 3: Verify Fix
------------------
Command: test <project_name>
Why: Ensure everything works correctly
Time: ~30 seconds

Total estimated time: 2 minutes

Shall I execute this fix plan? (Y/n):
```

### 6. Execute Fixes

Based on user approval, execute each step:

**Step 1: Environment Fixes**

If environment issues detected:

```bash
# Check for required environment variables
if [ -z "$DATABASE_URL" ]; then
    echo "⚠️  DATABASE_URL not set"
    echo "Add to .env or export: export DATABASE_URL=..."
fi

# Check for config files
if [ ! -f "config/dev.exs" ]; then
    echo "⚠️  Missing config/dev.exs"
    echo "Copy from template: cp config/dev.exs.example config/dev.exs"
fi
```

**Step 2: Dependency Fixes**

```bash
echo "==> Step 1/3: Installing dependencies..."

case "$project_type" in
    elixir)
        mix deps.get
        mix deps.compile
        ;;
    dotnet)
        dotnet restore
        ;;
    node)
        bun install
        ;;
    go)
        go mod download
        go mod tidy
        ;;
    python)
        pip install -r requirements.txt
        ;;
    rust)
        cargo fetch
        ;;
esac

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Dependency installation failed"
    echo "Check error above for details"
    exit 1
fi
```

**Step 3: Rebuild**

```bash
echo "==> Step 2/3: Rebuilding project..."

build <project_name>

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build still failing"
    echo "Analyzing remaining errors..."
    # Continue to next diagnosis
fi
```

**Step 4: Verify**

```bash
echo "==> Step 3/3: Running tests to verify fix..."

test <project_name>

if [ $? -eq 0 ]; then
    echo "✅ All tests passing - fix complete!"
else
    echo "⚠️  Build works but some tests failing"
    echo "This may be unrelated to the build issue"
fi
```

### 7. Handle Compilation Errors

For code-level compilation errors:

**Undefined Function/Variable:**

```
Error: undefined function authenticate/2
File: lib/user_controller.ex:45

Diagnosis:
  The function Auth.authenticate/2 doesn't exist or isn't imported.

Possible causes:
  1. Missing import statement
  2. Function was renamed/removed in library update
  3. Typo in function name

Let me check...

[Search codebase for authenticate function]

Found it! The function exists in lib/auth.ex but isn't imported.

Fix:
  Add to the top of lib/user_controller.ex:

  alias MyApp.Auth

Or use fully qualified name:

  MyApp.Auth.authenticate(params)

Would you like me to add the alias? (Y/n):
```

**Type Mismatch:**

```
Error: type mismatch - expected String.t(), got Integer
File: lib/helpers.ex:23

Code:
  22 │ def format_id(id) do
  23 │   String.upcase(id)
     │                 ^^^ Integer provided, String expected
  24 │ end

Diagnosis:
  The function expects a String but received an Integer.

Fix options:
  1. Convert to string: String.upcase(Integer.to_string(id))
  2. Accept both types: String.upcase(to_string(id))
  3. Fix caller to pass string

Checking function usage...

This function is called 3 times:
  • lib/controller.ex:45 - passes Integer (user.id)
  • lib/view.ex:12 - passes Integer (post.id)
  • lib/helper.ex:67 - passes String (uuid) ✓

Recommended fix: Update format_id to accept integers:

  def format_id(id) when is_integer(id) do
    String.upcase(Integer.to_string(id))
  end

  def format_id(id) when is_binary(id) do
    String.upcase(id)
  end

Shall I apply this fix? (Y/n):
```

**Import/Namespace Error:**

```
Error: module not found - :jason
File: lib/api.ex:12

Diagnosis:
  The Jason module isn't available. This usually means:
  1. Dependency not in mix.exs
  2. Dependency not installed
  3. Wrong module name

Checking mix.exs...

Jason is NOT in dependencies!

Fix:
  1. Add to mix.exs dependencies:
     {:jason, "~> 1.4"}

  2. Install dependency:
     mix deps.get

  3. Rebuild:
     mix compile

Shall I add this dependency and rebuild? (Y/n):
```

### 8. Handle Toolchain Issues

For build tool or version issues:

**Wrong Version:**

```
Error: This project requires Elixir ~> 1.14

Current version: Elixir 1.13.4

Diagnosis:
  Your Elixir version is too old for this project.

Fix options:
  1. Update Elixir to 1.14 or later
  2. Downgrade project requirements (not recommended)

How to update Elixir:

  Using asdf (recommended):
    asdf install elixir 1.14.5
    asdf local elixir 1.14.5

  Using package manager:
    # Ubuntu/Debian
    sudo apt update && sudo apt install elixir

    # macOS
    brew update && brew upgrade elixir

    # Arch Linux
    sudo pacman -Syu elixir

After updating, restart your terminal and run:
  elixir --version

Would you like guidance on updating Elixir?
```

**Missing Build Tool:**

```
Error: mix: command not found

Diagnosis:
  Elixir is not installed or not in PATH.

This is required to build Elixir projects.

Installation:

  macOS:
    brew install elixir

  Ubuntu/Debian:
    sudo apt install elixir

  Arch Linux:
    sudo pacman -S elixir

  Windows:
    Download from: https://elixir-lang.org/install.html

  Using asdf (recommended for version management):
    asdf plugin add elixir
    asdf install elixir latest
    asdf global elixir latest

After installation, verify with:
  elixir --version
  mix --version

Need help with installation?
```

### 9. Clean Build Artifacts

If errors persist, try cleaning:

```
Build still failing after fixes? Let's try a clean rebuild.

This removes all compiled artifacts and rebuilds from scratch.

==> Cleaning build artifacts...

case "$project_type" in
    elixir)
        mix clean
        rm -rf _build deps
        mix deps.get
        ;;
    dotnet)
        dotnet clean
        rm -rf bin obj
        dotnet restore
        ;;
    node)
        rm -rf node_modules .next dist build
        bun install
        ;;
    go)
        go clean -cache -modcache
        go mod download
        ;;
    python)
        find . -type d -name __pycache__ -delete
        find . -type f -name "*.pyc" -delete
        pip install -r requirements.txt
        ;;
    rust)
        cargo clean
        cargo fetch
        ;;
esac

==> Rebuilding from scratch...
build <project_name>
```

### 10. Provide Summary

After successful fix:

```
===========================================
Build Fixed! ✅
===========================================

Original Error: Missing dependencies
Fix Applied: Installed dependencies with mix deps.get

Build Status: ✅ Successful
Test Status:  ✅ All passing
Time to Fix:  2 minutes

What was done:
  1. ✅ Analyzed build error output
  2. ✅ Identified missing dependencies as root cause
  3. ✅ Installed dependencies (mix deps.get)
  4. ✅ Rebuilt project successfully
  5. ✅ Verified with test suite

Recommendations:
  • Commit lock file changes (mix.lock)
  • Run `outdated <project>` to check for updates
  • Set up pre-commit hooks to catch this early

Your project is now building successfully!
```

## Context

Use this skill when:
- Build command fails
- User reports compilation errors
- After pulling changes from remote
- After updating dependencies
- After switching branches
- After modifying build configuration
- User says "build is broken" or similar

## Example Usage

**Scenario 1: Fresh clone dependency issue**

```
User: "I just cloned the project and the build is failing"

Claude: I'll help you fix the build issue. Let me run the build and analyze
the error...

[Runs: build grocery-planner]

I found the issue! The build is failing because dependencies aren't installed.
This is normal for a fresh clone.

Error: dependency phoenix_live_view not found

Fix: Install dependencies first

I'll install the dependencies and rebuild:

==> Step 1/2: Installing dependencies...
[Runs: mix deps.get]
✅ Dependencies installed (23 packages)

==> Step 2/2: Building project...
[Runs: build grocery-planner]
✅ Build successful!

All fixed! Your project is now building correctly.
```

**Scenario 2: Type error after refactoring**

```
User: "Build is broken after I refactored the authentication code"

Claude: Let me analyze the build error...

[Runs build, captures error]

Found the issue! Type mismatch in lib/user_controller.ex:45

Error: expected String.t(), got Integer

You're passing user.id (Integer) to Auth.authenticate/2 which expects a String.

This likely broke when you changed the authentication function signature.

Fix options:
  1. Convert id to string: Auth.authenticate(Integer.to_string(user.id))
  2. Update authenticate/2 to accept both Integer and String
  3. Change user.id to be a String in the database

Which approach fits your refactoring goals?
```

**Scenario 3: Version incompatibility**

```
User: "Build fails with 'requires Elixir ~> 1.14' error"

Claude: The build is failing due to an Elixir version mismatch.

Your version: Elixir 1.13.4
Required:     Elixir 1.14+

This project requires a newer version of Elixir.

I recommend updating Elixir using asdf for version management:

  asdf install elixir 1.14.5
  asdf local elixir 1.14.5

This will:
  • Install Elixir 1.14.5
  • Set it as the version for this project only
  • Keep other projects on their existing versions

Would you like me to create the .tool-versions file for you?
```

## Error Handling

Handle these scenarios:

### 1. Multiple Cascading Errors

```
⚠️  Multiple errors detected (15 errors)

These appear to be cascading from a root cause.

Primary error (first):
  Missing dependency: phoenix_live_view

Subsequent errors (14):
  All related to missing LiveView module

Fix strategy:
  Fix the primary error first. This should resolve most subsequent errors.

Proceeding with dependency installation...
```

### 2. Ambiguous Error Messages

```
❌ Build failed with unclear error

Error message: "compilation failed"

This error doesn't provide specific details. Let me gather more information...

Running with verbose output:
[Runs: build with --verbose flag]

Now I can see the issue: missing config file

Error was hidden in verbose output.
```

### 3. Permission Issues

```
❌ Permission denied writing to _build directory

This is a file permissions issue, not a code issue.

Diagnosis: Build directory is owned by different user/sudo

Fix:
  sudo chown -R $USER:$USER _build deps

Or rebuild:
  sudo rm -rf _build deps
  mix deps.get
  mix compile

Would you like me to fix the permissions?
```

### 4. Resource Exhaustion

```
❌ Build failed: Out of memory

The build process ran out of RAM. This can happen with large projects.

Solutions:
  1. Close other applications to free memory
  2. Increase swap space
  3. Build with fewer parallel jobs:
     mix compile --max-jobs 2

  4. Use cloud build if local resources insufficient

Which approach would you like to try?
```

### 5. Network Issues

```
❌ Dependency download failed: Connection timeout

This is a network connectivity issue.

Possible causes:
  • Firewall blocking dependency server
  • VPN interfering with connection
  • Dependency server temporarily down
  • DNS resolution issue

Troubleshooting:
  1. Check internet connection
  2. Try disabling VPN
  3. Check if hex.pm is accessible: ping hex.pm
  4. Try again in a few minutes

Shall I retry the dependency download?
```

## Success Criteria

The skill is successful when:
- ✓ Root cause is identified correctly
- ✓ Clear fix steps are provided
- ✓ Fixes are applied successfully
- ✓ Build completes without errors
- ✓ Tests pass after fix
- ✓ User understands what was wrong and how it was fixed
- ✓ Recommendations prevent future occurrences

## Tips

- **Read errors carefully**: First error is often the root cause
- **Check dependencies first**: Most build issues are dependency-related
- **Clean when stuck**: Clean rebuild often resolves mysterious issues
- **Version matters**: Many issues are version incompatibilities
- **Environment counts**: Missing env vars cause cryptic errors
- **Incremental fixes**: Fix one error at a time
- **Verify each fix**: Build after each change
- **Explain why**: Help user understand, not just fix
- **Document**: Note what fixed it for future reference
- **Prevent**: Suggest ways to avoid the issue recurring

## Advanced Troubleshooting

### Circular Dependency Detection

```
Analyzing dependency graph...

❌ Circular dependency detected!

module_a depends on module_b
module_b depends on module_c
module_c depends on module_a

This creates an infinite loop in compilation.

Fix: Break the circular reference by:
  1. Moving shared code to a new module
  2. Using dependency injection
  3. Restructuring module relationships

Recommended approach: [specific suggestion based on code]
```

### Build Performance Analysis

```
Build successful but slow (5 minutes)

Analyzing build performance...

Bottlenecks:
  • Heavy dependency: phoenix (90 seconds)
  • Large module: lib/schema.ex (45 seconds)
  • Many files: 234 source files

Optimization suggestions:
  1. Enable incremental compilation (already on ✓)
  2. Use protocol consolidation: MIX_ENV=prod mix compile
  3. Consider splitting large modules
  4. Cache dependencies in CI/CD

Expected improvement: 40-60% faster builds
```

### Dependency Conflict Resolution

```
❌ Dependency conflict cannot be automatically resolved

package_a requires jason ~> 1.2
package_b requires jason ~> 1.4

These requirements are incompatible.

Resolution strategies:
  1. Update package_a to version that supports jason 1.4
  2. Downgrade package_b to version that works with jason 1.2
  3. Override with specific version (risky)
  4. Find alternative to one package

Checking for compatible versions...

✅ Found solution: Update package_a to 2.0.0 (supports jason 1.4)

Shall I apply this fix?
```
