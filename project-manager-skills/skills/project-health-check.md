# Project Health Check - Comprehensive Project Analysis

## Description

Perform a comprehensive health check on a project, analyzing its current state and providing actionable recommendations for improvements. This skill checks git status, dependencies, build health, tests, code quality, and project configuration.

## Prerequisites

- Project must be registered in Project Manager
- Project directory must exist locally
- Project must be a git repository (for git-related checks)

## Instructions

When this skill is invoked, perform a comprehensive analysis following these steps:

### 1. Basic Project Information

Start by gathering basic project information:

```bash
# Get project info
project_name="<project>"
project_info=$(cat ~/.config/project-manager/projects.json | jq -r ".[\"$project_name\"]")
```

Display:
- Project name
- Project type
- Local path
- GitHub remote
- Last modified time

### 2. Git Status Analysis

Check the git repository status:

```bash
cd <project_path>

# Branch info
current_branch=$(git rev-parse --abbrev-ref HEAD)
upstream_branch=$(git rev-parse --abbrev-ref @{u} 2>/dev/null)

# Check for uncommitted changes
uncommitted=$(git status --porcelain)

# Check commits ahead/behind
git fetch origin
ahead=$(git rev-list --count HEAD..origin/$current_branch 2>/dev/null || echo 0)
behind=$(git rev-list --count origin/$current_branch..HEAD 2>/dev/null || echo 0)

# Recent commits
recent_commits=$(git log --oneline -5)
```

Report:
- ✓ Current branch
- ✓ Commits ahead/behind remote
- ⚠ Uncommitted changes (list files)
- ⚠ Untracked files
- ℹ Recent commit activity

### 3. Dependency Health

Check for outdated dependencies based on project type:

```bash
# Run the outdated command
outdated <project_name>
```

Analyze the output and categorize:
- **Critical**: Major version updates available
- **Minor**: Minor/patch updates available
- **Security**: Known vulnerabilities (if detectable)
- **Up-to-date**: All dependencies current

### 4. Build Health

Attempt to build the project:

```bash
build <project_name>
```

Report:
- ✓ Build successful
- ✗ Build failed (with error summary)
- ⚠ Build warnings (count and type)
- ℹ Build time

### 5. Test Health

Run the test suite:

```bash
test <project_name>
```

Analyze:
- ✓ All tests passing
- ✗ Failing tests (count and names)
- ⚠ Skipped tests
- ℹ Test coverage (if available)
- ℹ Test execution time

### 6. Code Quality Checks

Perform code quality analysis:

**For all project types:**
- Check for large files (>1MB)
- Check for sensitive files (.env, credentials, etc.)
- Count lines of code
- Check file organization

**Project-specific:**
- **Elixir**: Check for `mix format` compliance
- **.NET**: Check for compiler warnings
- **Node**: Check for `package-lock.json` or `bun.lockb`
- **Go**: Check for `go fmt` compliance
- **Python**: Check for `black` or `flake8` compliance
- **Rust**: Check for `cargo fmt` and `cargo clippy` issues

### 7. Project Configuration Analysis

Review project configuration:

**Check for:**
- README.md exists and is recent
- .gitignore is comprehensive
- License file exists
- CI/CD configuration (.github/workflows, etc.)
- Environment example files (.env.example)
- Proper .editorconfig

### 8. Performance Indicators

Calculate health metrics:

- **Commit Frequency**: Commits in last 7/30 days
- **Test-to-Code Ratio**: Test files vs source files
- **Documentation Coverage**: README, docs/, comments
- **Dependencies Risk**: Number of outdated dependencies

### 9. Generate Health Score

Calculate an overall health score (0-100) based on:

- Git status: 20 points
  - Clean working tree: 10
  - Up to date with remote: 10
- Dependencies: 20 points
  - All up to date: 20
  - Minor updates only: 15
  - Major updates needed: 10
  - Critical updates: 5
- Build status: 30 points
  - Builds successfully: 30
  - Build warnings: 20
  - Build fails: 0
- Test status: 20 points
  - All passing: 20
  - Some failing: 10
  - No tests: 5
- Code quality: 10 points
  - Formatted correctly: 5
  - No large/sensitive files: 5

### 10. Provide Recommendations

Based on the analysis, provide prioritized recommendations:

**Critical (Fix Immediately):**
- Build failures
- Failing tests
- Security vulnerabilities
- Sensitive files in repository

**High Priority (Fix Soon):**
- Major dependency updates
- Missing critical files (README, LICENSE)
- Uncommitted changes on main branch

**Medium Priority (Consider):**
- Minor dependency updates
- Code formatting issues
- Missing documentation
- Missing CI/CD

**Low Priority (Nice to Have):**
- Code organization improvements
- Additional testing
- Performance optimizations

## Output Format

Present the health check as a structured report:

```
===========================================
Project Health Check: <project_name>
===========================================

📊 Overall Health Score: <score>/100 - <rating>

🔍 ANALYSIS SUMMARY
-------------------

Git Status:           [✓/✗/⚠]
Dependencies:         [✓/✗/⚠]
Build:                [✓/✗/⚠]
Tests:                [✓/✗/⚠]
Code Quality:         [✓/✗/⚠]
Documentation:        [✓/✗/⚠]

📋 DETAILED FINDINGS
--------------------

[Detailed breakdown of each category]

🚨 CRITICAL ISSUES (0)
----------------------
[List critical issues]

⚠️  HIGH PRIORITY (2)
---------------------
1. 5 major dependency updates available
2. 3 uncommitted files in working directory

ℹ️  RECOMMENDATIONS
-------------------
1. Run `push <project> "commit message"` to commit changes
2. Run `outdated <project>` to review dependency updates
3. Consider adding CI/CD configuration
4. Update README.md with recent changes

✅ NEXT STEPS
-------------
Based on this analysis, I recommend:

1. Address critical issues first
2. Review and update dependencies
3. Commit or stash uncommitted changes
4. Consider setting up automated testing

Would you like me to help you fix any of these issues?
```

## Context

Use this skill when:
- Starting work on a project after time away
- Before making major changes
- During code reviews
- For project audits
- When onboarding to a new project

## Example Usage

**Scenario 1: Quick health check**
```
User: "Check the health of my grocery_planner project"

Claude: I'll perform a comprehensive health check on grocery_planner. This will take a moment...

===========================================
Project Health Check: grocery_planner
===========================================

📊 Overall Health Score: 85/100 - Good

🔍 ANALYSIS SUMMARY
-------------------

Git Status:           ✓ Clean, up to date
Dependencies:         ⚠ 3 minor updates available
Build:                ✓ Successful (2.3s)
Tests:                ✓ All 47 tests passing (1.8s)
Code Quality:         ✓ No issues found
Documentation:        ✓ Complete

📋 DETAILED FINDINGS
--------------------

Git Status:
  • Branch: main
  • Up to date with origin/main
  • No uncommitted changes
  • Last commit: 2 days ago

Dependencies:
  • phoenix: 1.7.10 → 1.7.12 (minor)
  • ecto: 3.11.0 → 3.11.2 (patch)
  • jason: 1.4.0 → 1.4.1 (patch)

Build:
  • Status: SUCCESS
  • Time: 2.3 seconds
  • Warnings: 0

Tests:
  • Total: 47 tests
  • Passed: 47
  • Failed: 0
  • Coverage: 89%
  • Time: 1.8 seconds

ℹ️  RECOMMENDATIONS
-------------------
1. Consider updating dependencies (all are minor/patch updates)
2. Add more tests to reach 90% coverage goal
3. Your project is in great shape!

Would you like me to update the dependencies for you?
```

**Scenario 2: Problematic project**
```
User: "My api-server project hasn't been touched in weeks, what's the status?"

Claude: Let me run a comprehensive health check on api-server...

===========================================
Project Health Check: api-server
===========================================

📊 Overall Health Score: 45/100 - Needs Attention

🔍 ANALYSIS SUMMARY
-------------------

Git Status:           ⚠ 12 uncommitted files
Dependencies:         ✗ 8 major updates, 2 security issues
Build:                ✗ FAILED
Tests:                ⚠ 4 of 32 tests failing
Code Quality:         ⚠ Multiple issues
Documentation:        ✗ README outdated

🚨 CRITICAL ISSUES (3)
----------------------
1. Build failing due to dependency conflicts
2. 2 dependencies with known security vulnerabilities
3. Tests failing in authentication module

⚠️  HIGH PRIORITY (4)
---------------------
1. 12 uncommitted files (including sensitive .env file)
2. 8 major dependency updates needed
3. README.md last updated 6 months ago
4. No CI/CD configuration

ℹ️  RECOMMENDATIONS
-------------------
Priority 1: Security
  • Remove .env file from git (add to .gitignore)
  • Update dependencies with security patches

Priority 2: Stability
  • Fix build by resolving dependency conflicts
  • Fix 4 failing tests

Priority 3: Maintenance
  • Commit or discard uncommitted changes
  • Update dependencies
  • Update documentation

✅ NEXT STEPS
-------------
This project needs immediate attention. I recommend:

1. First, let's remove that .env file from the repository
2. Then update dependencies to fix security issues
3. Resolve build failures
4. Fix failing tests
5. Clean up uncommitted changes

Would you like me to help you work through these issues step by step?
```

## Error Handling

Handle these scenarios:

1. **Project not found**
   - List available projects
   - Suggest checking spelling or adding project

2. **Project directory doesn't exist**
   - Suggest cloning with `projects --clone <name>`
   - Or update local_path in config

3. **Not a git repository**
   - Skip git-related checks
   - Warn that some features require git

4. **Build/test commands not configured**
   - Skip those checks
   - Suggest configuring project_type

5. **Network issues**
   - Skip remote checks
   - Note that some checks couldn't complete

## Success Criteria

The skill is successful when:
- ✓ Complete analysis is performed
- ✓ Clear health score is provided
- ✓ Issues are prioritized correctly
- ✓ Actionable recommendations are given
- ✓ User understands next steps

## Tips

- **Be thorough but concise**: Provide details without overwhelming
- **Prioritize correctly**: Critical issues first
- **Be actionable**: Every issue should have a suggested fix
- **Use visual indicators**: ✓ ✗ ⚠ ℹ make reports scannable
- **Offer help**: Always ask if they want assistance fixing issues
- **Context matters**: Adjust expectations based on project type
