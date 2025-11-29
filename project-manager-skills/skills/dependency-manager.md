---
name: dependency-manager
description: Safely update project dependencies with risk analysis and testing
---

# Dependency Manager - Intelligent Dependency Update Guide

## Description

Guide users through safely updating project dependencies with intelligent analysis of changes, breaking change detection, and risk assessment. This skill helps users understand what's changing, why it matters, and how to update safely.

## Prerequisites

- Project must be registered in Project Manager
- Project directory must exist locally
- Project must have dependency management (package.json, mix.exs, etc.)
- Working build and test suite (to verify updates)

## Instructions

When this skill is invoked, guide the user through dependency updates:

### 1. Analyze Current Dependencies

Start by checking what dependencies need updates:

```bash
cd <project_path>

# Run the outdated command for the project
outdated <project_name>
```

**Parse the output based on project type:**

**Elixir (mix hex.outdated):**
- Columns: Package, Current, Latest, Update Possible, Compatibility
- Red = major version change (breaking)
- Yellow = minor/patch (likely safe)

**Node (bun outdated):**
- Columns: Package, Current, Wanted, Latest
- Wanted = within semver range
- Latest = newest available

**Dotnet (dotnet list package --outdated):**
- Shows requested, resolved, and latest versions
- Indicates if major/minor/patch update

**Go (go list -u -m all):**
- Shows current and available versions
- Format: module [current] [latest]

**Python (pip list --outdated):**
- Shows package, version, latest, type

**Rust (cargo outdated):**
- Shows name, project version, latest, kind

### 2. Categorize Updates by Risk

Analyze each outdated dependency and categorize:

**Low Risk (Patch Updates):**
- Version change: x.y.Z (only patch number changes)
- Examples: 1.2.3 → 1.2.4, 2.5.1 → 2.5.2
- Usually bug fixes and security patches
- **Recommendation**: Safe to update immediately

**Medium Risk (Minor Updates):**
- Version change: x.Y.0 (minor version changes)
- Examples: 1.2.3 → 1.3.0, 2.5.1 → 2.6.0
- New features, possibly deprecated APIs
- **Recommendation**: Review changelog, test thoroughly

**High Risk (Major Updates):**
- Version change: X.0.0 (major version changes)
- Examples: 1.2.3 → 2.0.0, 2.5.1 → 3.0.0
- Breaking changes expected
- **Recommendation**: Review migration guide, extensive testing

**Critical Risk (Multiple Major Versions Behind):**
- Version change: Skipping multiple major versions
- Examples: 1.2.3 → 4.0.0, 2.5.1 → 7.0.0
- Multiple breaking changes, significant refactoring needed
- **Recommendation**: Step-by-step migration, consider alternatives

### 3. Present Update Plan

Create a structured update plan:

```
===========================================
Dependency Update Plan: <project_name>
===========================================

Total Outdated: <count>
  Low Risk (Patch):    <count>
  Medium Risk (Minor): <count>
  High Risk (Major):   <count>
  Critical Risk:       <count>

RECOMMENDED UPDATE ORDER
------------------------

Phase 1 - Safe Updates (Patch versions):
  ✓ package-a: 1.2.3 → 1.2.5 (security fix)
  ✓ package-b: 2.1.0 → 2.1.1 (bug fixes)

  Risk: LOW
  Time: 5-10 minutes
  Action: Update all, run tests

Phase 2 - Feature Updates (Minor versions):
  ⚠ package-c: 1.5.0 → 1.8.0 (new features, deprecated APIs)
  ⚠ package-d: 3.2.1 → 3.4.0 (performance improvements)

  Risk: MEDIUM
  Time: 30-60 minutes
  Action: Update individually, check changelog, test each

Phase 3 - Breaking Changes (Major versions):
  ⚠️ package-e: 2.5.0 → 3.0.0 (BREAKING: API changes)
  ⚠️ package-f: 1.9.5 → 2.0.0 (BREAKING: config format changed)

  Risk: HIGH
  Time: 2-4 hours
  Action: Review migration guide, update code, extensive testing

Skipped (Too Risky for Now):
  🚫 legacy-package: 1.2.0 → 5.0.0 (4 major versions behind)
     Recommendation: Schedule dedicated migration or find replacement
```

### 4. Fetch Changelogs and Breaking Changes

For each dependency that will be updated, fetch relevant information:

**Use web search or repository URLs to find:**
- CHANGELOG.md or RELEASES.md
- Migration guides
- Breaking changes documentation
- Known issues

**Focus on:**
- What's new in the target version
- Deprecated APIs being removed
- Configuration changes
- Behavioral changes
- Security fixes

**Summarize for user:**
```
package-e (2.5.0 → 3.0.0):
--------------------------
Breaking Changes:
  • Authentication API changed from auth.login() to auth.authenticate()
  • Config format now uses YAML instead of JSON
  • Removed deprecated helper functions (use new utils instead)

Migration Steps:
  1. Update auth calls: auth.login() → auth.authenticate()
  2. Convert config.json to config.yaml
  3. Replace helper.doThing() with utils.doThing()

New Features:
  • Better error messages
  • 50% faster authentication
  • TypeScript support improved

Estimated Effort: 30-45 minutes
```

### 5. Ask User for Update Strategy

Present options:

```
How would you like to proceed?

1. Conservative (Recommended for Production):
   - Update only patch versions now
   - Schedule minor/major updates separately
   - Minimize risk of breakage

2. Balanced (Good for Active Development):
   - Update patch and minor versions
   - Review major updates individually
   - Moderate risk, good improvements

3. Aggressive (Only if Time Permits):
   - Update everything including major versions
   - Requires significant testing time
   - Maximum improvements, highest risk

4. Custom:
   - Let me choose which packages to update
   - I'll specify exactly what to update

Which strategy do you prefer? (1/2/3/4):
```

### 6. Execute Updates (Phase-by-Phase)

Based on user choice, execute updates in phases:

**Phase 1 - Patch Updates:**

```bash
# Create a backup point
git stash  # If needed
git checkout -b deps/patch-updates

# Update dependencies based on project type
case "$project_type" in
    elixir)
        # Update specific patches in mix.exs
        # Or mix deps.update --all for all patches
        mix deps.update <package_name>
        ;;
    dotnet)
        # Update specific packages
        dotnet add package <PackageName>
        ;;
    node)
        # Update to wanted versions (within semver)
        bun update
        ;;
    go)
        # Update specific modules
        go get <module>@latest
        go mod tidy
        ;;
    python)
        # Update in requirements.txt and install
        pip install --upgrade <package>
        pip freeze > requirements.txt
        ;;
    rust)
        # Update in Cargo.toml
        cargo update
        ;;
esac
```

**After each phase:**

```bash
# 1. Run build
echo "==> Building with updated dependencies..."
build <project_name>

if [ $? -ne 0 ]; then
    echo "❌ Build failed after update!"
    echo "Reverting changes..."
    git checkout .
    exit 1
fi

# 2. Run tests
echo "==> Running tests..."
test <project_name>

if [ $? -ne 0 ]; then
    echo "❌ Tests failed after update!"
    echo "Review failures and fix, or revert."
    exit 1
fi

echo "✅ Phase complete - build and tests passing"
```

**Between phases:**

Ask user:
```
✅ Patch updates complete and verified!

Updated packages:
  • package-a: 1.2.3 → 1.2.5 ✓
  • package-b: 2.1.0 → 2.1.1 ✓

Build: ✅ Successful
Tests: ✅ All passing

Ready to proceed to Phase 2 (minor updates)? (Y/n):
```

### 7. Handle Breaking Changes

For major version updates with breaking changes:

**Step-by-step approach:**

1. **Update one package at a time**
   - Don't update multiple major versions simultaneously
   - Easier to identify what broke

2. **Follow migration guide**
   - Show user the specific migration steps
   - Update code to match new API

3. **Fix compilation errors**
   - Address errors one by one
   - Explain what changed and why

4. **Update tests**
   - Fix broken tests
   - Add tests for new behavior

5. **Verify behavior**
   - Run full test suite
   - Manual testing if needed

**Example workflow:**

```
Updating package-e: 2.5.0 → 3.0.0
-----------------------------------

Step 1: Update dependency
[Update mix.exs / package.json / etc.]

Step 2: Attempt build
[Run build - expect errors]

Step 3: Fix breaking changes
Found 3 compilation errors:

Error 1: auth.login() no longer exists
  File: lib/auth_controller.ex:45
  Fix: Replace with auth.authenticate()

  Old: user = Auth.login(credentials)
  New: user = Auth.authenticate(credentials)

Would you like me to help fix this? (Y/n):
```

### 8. Update Lock Files

After successful updates:

```bash
# Ensure lock files are updated
case "$project_type" in
    elixir)
        mix deps.get
        # Commits mix.lock
        ;;
    node)
        bun install
        # Commits bun.lockb
        ;;
    dotnet)
        dotnet restore
        # Updates packages.lock.json if exists
        ;;
    go)
        go mod tidy
        # Updates go.sum
        ;;
    python)
        pip freeze > requirements.txt
        # Updates requirements.txt
        ;;
    rust)
        cargo build
        # Updates Cargo.lock
        ;;
esac
```

### 9. Create Commit

Help create a proper commit message:

```
chore(deps): update dependencies to latest versions

Patch updates:
- package-a: 1.2.3 → 1.2.5 (security fixes)
- package-b: 2.1.0 → 2.1.1 (bug fixes)

Minor updates:
- package-c: 1.5.0 → 1.8.0 (new features)
- package-d: 3.2.1 → 3.4.0 (performance improvements)

Major updates:
- package-e: 2.5.0 → 3.0.0 (breaking changes)
  * Updated auth API calls
  * Migrated config format to YAML
  * Replaced deprecated helpers

All tests passing ✓
```

### 10. Provide Summary

Give user a clear summary:

```
===========================================
Dependency Update Complete! ✅
===========================================

Updates Applied:
  Patch versions:  2 packages
  Minor versions:  2 packages
  Major versions:  1 package
  Total updated:   5 packages

Build Status:    ✅ Successful
Test Status:     ✅ All passing (47/47)
Time Taken:      45 minutes

Changes Committed:
  Branch: deps/patch-updates
  Commit: chore(deps): update dependencies

Skipped Updates:
  • legacy-package (1.2.0 → 5.0.0)
    Reason: Too many major versions, requires dedicated effort

Recommendations:
  ✓ Ready to merge to main
  ✓ Consider scheduling migration for legacy-package
  ✓ Set reminder to check dependencies monthly

Next Steps:
  1. Push branch: git push -u origin deps/patch-updates
  2. Create PR for code review
  3. Merge after approval
  4. Monitor for any issues in production
```

## Context

Use this skill when:
- User wants to update dependencies
- Running `outdated <project>` shows updates available
- After security vulnerability notifications
- Monthly/quarterly maintenance
- Before major feature work
- After long period away from project

## Example Usage

**Scenario 1: Routine maintenance**
```
User: "Check and update dependencies for grocery-planner"

Claude: I'll help you update dependencies for grocery-planner. Let me start by
checking what's outdated...

[Runs: outdated grocery-planner]

I found 12 outdated packages. Let me analyze them by risk level...

[Categorizes and presents update plan]

I recommend starting with 5 safe patch updates, then reviewing 4 minor updates,
and scheduling the 3 major updates for a dedicated session.

Would you like to proceed with this plan?
```

**Scenario 2: After security alert**
```
User: "There's a security vulnerability in package-x, need to update it"

Claude: I'll help you safely update package-x to fix the security vulnerability.

[Checks current version and latest]

Current: package-x 2.3.1 (vulnerable)
Latest:  package-x 2.3.5 (security fix)
Update:  Patch version (LOW RISK)

This is a patch update with a security fix, safe to apply immediately.

[Updates package, builds, tests]

✅ Updated successfully! Security vulnerability resolved.
All tests passing. Ready to commit and deploy.
```

**Scenario 3: Major version upgrade**
```
User: "I want to upgrade phoenix from 1.6 to 1.7"

Claude: I'll guide you through upgrading Phoenix 1.6 → 1.7. This is a major
version update with breaking changes.

[Fetches Phoenix 1.7 changelog and migration guide]

Breaking Changes Found:
  • LiveView API changes
  • New directory structure for components
  • Updated authentication approach

This will require code changes. Estimated time: 2-3 hours.

Let me break this into steps:

Step 1: Update dependency in mix.exs
Step 2: Run mix deps.get (expect compilation errors)
Step 3: Fix LiveView API calls (I'll help with each one)
Step 4: Migrate component structure
Step 5: Update authentication code
Step 6: Run full test suite

Ready to start? We'll go step by step, testing after each change.
```

## Error Handling

Handle these scenarios:

### 1. Build Fails After Update

```
❌ Build failed after updating package-x

Error: undefined function package-x.old_function/2

This is a breaking change. Let me check the migration guide...

[Fetches changelog]

Found it! package-x.old_function/2 was renamed to package-x.new_function/2

Files affected:
  • lib/controller.ex:45
  • lib/helper.ex:23

Would you like me to help update these calls?
```

### 2. Tests Fail After Update

```
❌ 3 tests failing after update

Analyzing failures...

All 3 failures are in auth_test.exs and related to package-e changes.

The authentication response format changed:
  Old: {:ok, user}
  New: {:ok, %{user: user, token: token}}

Tests need to be updated to expect the new format.

Shall I help update the test expectations?
```

### 3. Dependency Conflict

```
❌ Dependency conflict detected

package-a requires package-c ^2.0
package-b requires package-c ^1.5

Cannot satisfy both requirements.

Options:
  1. Update package-b to version that supports package-c 2.0
  2. Don't update package-a (keep package-c at 1.5)
  3. Find alternative to package-a or package-b

Checking for compatible versions...
```

### 4. No Updates Available

```
✅ All dependencies are up to date!

No updates available for <project_name>.

Last checked: <timestamp>
Next check recommended: <date>

Your project is using current versions. Great job keeping dependencies fresh!
```

### 5. Lock File Conflicts

```
⚠️  Lock file conflict detected after update

The lock file has merge conflicts. This usually happens when:
  • Someone else updated dependencies
  • You have local changes

Resolution:
  1. Fetch latest changes: git pull
  2. Re-run dependency install
  3. Lock file will be regenerated

Shall I do this for you?
```

## Success Criteria

The skill is successful when:
- ✓ User understands what's being updated and why
- ✓ Updates are applied safely in appropriate order
- ✓ Build remains working after updates
- ✓ All tests pass after updates
- ✓ Breaking changes are properly migrated
- ✓ Changes are committed with clear message
- ✓ User knows what was skipped and why

## Tips

- **Batch wisely**: Group patch updates, handle majors individually
- **Test between phases**: Catch issues early
- **Read changelogs**: Always check what changed
- **One major at a time**: Don't update multiple major versions at once
- **Keep lock files**: Commit updated lock files
- **Document why**: Note why certain packages weren't updated
- **Set reminders**: Schedule regular dependency checks
- **Security first**: Always prioritize security updates
- **Know when to stop**: Some updates aren't worth the effort
- **Consider alternatives**: If migration is too costly, evaluate alternatives

## Advanced Features

### Semver Analysis

Automatically parse and explain semantic versioning:

```
Version: 2.5.3
         │ │ │
         │ │ └─ Patch (bug fixes, no breaking changes)
         │ └─── Minor (new features, backwards compatible)
         └───── Major (breaking changes)

Update to 2.5.4: ✅ Safe (patch)
Update to 2.6.0: ⚠️  Review (minor)
Update to 3.0.0: 🚨 Breaking (major)
```

### Dependency Graph Impact

Analyze which of your code depends on the package:

```
Updating package-x will affect:
  • 5 direct imports
  • 12 files total
  • 23 function calls

High impact areas:
  ✓ Authentication system (8 files)
  ✓ API controllers (4 files)
```

### Automated Changelog Fetching

Fetch and summarize changelogs automatically:

```
📋 Changelog Summary for package-x (2.0.0 → 3.0.0)

🚨 Breaking Changes:
  • API authentication now requires API key
  • Response format changed from XML to JSON
  • Deprecated endpoints removed

✨ New Features:
  • Rate limiting built-in
  • Better error messages
  • WebSocket support

🐛 Bug Fixes:
  • Fixed memory leak in long-polling
  • Resolved timeout issues

📚 Migration Guide: https://package-x.com/docs/v3-migration
```
