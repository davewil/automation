---
name: project-workflow
description: Guide through complete development workflow from branching to deployment
---

# Project Workflow - Smart Development Workflow Guide

## Description

Guide the user through a complete, professional development workflow for implementing a new feature or fixing a bug. This skill ensures best practices are followed from start to finish, including branching, testing, committing with proper messages, and deploying changes.

## Prerequisites

- Project must be registered in Project Manager
- Project directory must exist locally
- Project must be a git repository
- User should have a clear understanding of what they want to implement

## Instructions

When this skill is invoked, guide the user through these workflow steps:

### 1. Understand the Task

Start by clarifying what needs to be done:

**Ask the user:**
- "What feature are you implementing or what bug are you fixing?"
- "Is this related to an existing issue or ticket?"
- "What's the expected outcome?"

**Categorize the work:**
- **Feature**: New functionality
- **Bug Fix**: Fixing broken behavior
- **Refactor**: Code improvement without behavior change
- **Docs**: Documentation updates
- **Chore**: Maintenance tasks

This determines the commit message prefix and workflow variations.

### 2. Ensure Clean Starting State

Check the project's current state:

```bash
cd <project_path>

# Check current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check for uncommitted changes
uncommitted=$(git status --porcelain)

# Check if up to date with remote
git fetch origin
behind=$(git rev-list --count HEAD..origin/$current_branch 2>/dev/null || echo 0)
```

**Handle scenarios:**

**If on feature branch with uncommitted changes:**
- Ask: "You have uncommitted changes. Would you like to (c)ommit, (s)tash, or (a)bort?"

**If behind remote:**
- Pull latest changes: `git pull origin $current_branch`

**If on main/master with uncommitted changes:**
- Recommend: "You're on the main branch with changes. Let's create a feature branch first."

### 3. Create Feature Branch (Optional but Recommended)

For features and bug fixes, recommend creating a branch:

**Branch naming conventions:**
- Features: `feature/<feature-name>`
- Bug fixes: `fix/<bug-name>`
- Refactors: `refactor/<scope>`
- Docs: `docs/<topic>`
- Chores: `chore/<task>`

```bash
# Create and switch to new branch
git checkout -b <branch-type>/<descriptive-name>
```

**Example:**
- `feature/user-authentication`
- `fix/login-validation-error`
- `refactor/database-queries`

### 4. Check Dependencies and Environment

Before starting work, ensure everything is up to date:

```bash
# Check for outdated dependencies
outdated <project_name>
```

**If critical updates available:**
- Recommend updating before starting work
- Run: `<deps_command>` based on project type

**Run initial build and tests:**
```bash
# Ensure clean slate
build <project_name>
test <project_name>
```

If tests fail, stop and fix before continuing.

### 5. Implement the Changes

Guide the implementation:

**For features:**
1. Identify files that need changes
2. Recommend test-driven development (write tests first)
3. Implement feature incrementally
4. Run tests frequently

**For bug fixes:**
1. Write a failing test that reproduces the bug
2. Fix the bug
3. Verify test now passes
4. Ensure no regressions

**Best practices to remind:**
- Keep changes focused and atomic
- Follow project coding standards
- Add comments for complex logic
- Update documentation as needed

### 6. Format Code

After implementation, format the code:

```bash
# Based on project type
case "$project_type" in
    elixir) mix format ;;
    dotnet) dotnet format ;;
    node) bun run format ;;
    go) go fmt ./... ;;
    python) black . ;;
    rust) cargo fmt ;;
esac
```

### 7. Run Build and Tests

Verify everything works:

```bash
# Build the project
build <project_name>

# Run all tests
test <project_name>

# If available, check test coverage
```

**If build fails:**
- Review error messages
- Fix issues
- Re-run build

**If tests fail:**
- Identify failing tests
- Determine if they're related to changes
- Fix broken tests or update expectations
- Re-run tests

### 8. Review Changes

Show the user what's changed:

```bash
# Show modified files
git status

# Show detailed diff
git diff

# Show stat summary
git diff --stat
```

Ask the user to review:
- Are all changes intentional?
- Any debug code or comments to remove?
- Any files that shouldn't be committed?

### 9. Commit Changes

Help create a proper commit message:

**Conventional Commit Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add user registration with email validation

- Implement user registration form
- Add email validation
- Create user model with password hashing
- Add registration tests

Closes #123
```

```
fix(api): resolve timeout error in product search

The search endpoint was timing out for queries with >100 results.
Added pagination and optimized the database query.

Fixes #456
```

**Commit the changes:**
```bash
git add .
git commit -m "<commit-message>"
```

### 10. Push Changes

Push the branch to remote:

```bash
git push -u origin <branch-name>
```

### 11. Create Pull Request (if applicable)

If using PR workflow:

**Generate PR description:**
- Title: Brief summary
- Description: What changed and why
- Testing: How to test the changes
- Screenshots: If UI changes
- Checklist: What was completed

**Using gh CLI:**
```bash
gh pr create --title "<title>" --body "<description>"
```

**Manual:**
- Provide GitHub URL
- Guide through PR creation

### 12. Deployment (if applicable)

For projects with deployment:

**Ask:**
- "Is this ready to deploy to production?"
- "Should this be deployed to staging first?"

**Use push command for direct deployment:**
```bash
# This will pull, build, test, commit, and push
push <project_name> "<commit-message>"
```

### 13. Summary and Next Steps

Provide a summary of what was accomplished:

```
✅ Workflow Complete!

Summary:
- Created branch: feature/user-authentication
- Implemented: User registration with validation
- Tests: All 15 tests passing (including 5 new tests)
- Commit: feat(auth): add user registration
- Pushed to: origin/feature/user-authentication
- PR created: #123

Next steps:
1. Wait for code review
2. Address review comments if any
3. Merge PR when approved
4. Delete feature branch: git branch -d feature/user-authentication

Great work! 🎉
```

## Context

Use this skill when:
- Starting work on a new feature
- Fixing a bug
- Making any code changes to a project
- User wants guidance on proper git workflow
- User is new to the project or git workflows

## Example Usage

**Scenario 1: New feature implementation**
```
User: "Help me implement a new feature in my grocery-planner project"

Claude: I'll guide you through implementing a new feature in grocery-planner.
Let's start by understanding what you want to build.

What feature are you implementing?
> User authentication with email/password

Great! Is this related to an existing issue or ticket?
> Yes, issue #42

Perfect. Let me check the current state of your project...

[Checks git status]

You're currently on the main branch, which is up to date with origin/main.
I recommend creating a feature branch for this work.

I'll create a branch called "feature/user-authentication". Sound good?
> Yes

[Creates branch: git checkout -b feature/user-authentication]

Now let's check dependencies and run initial tests to ensure we have a clean slate...

[Runs: outdated grocery-planner]

Good news - all dependencies are up to date!

[Runs: build grocery-planner && test grocery-planner]

✓ Build successful
✓ All 47 tests passing

You're ready to start implementing! Here's what I recommend:

1. Start with tests - write failing tests for the authentication feature
2. Implement the feature to make tests pass
3. Run tests frequently during development

For user authentication, you'll likely need:
- User model (email, hashed password)
- Registration endpoint/form
- Login endpoint/form
- Password hashing (use bcrypt or argon2)
- Session management

Would you like me to help you plan out the implementation steps in detail?
```

**Scenario 2: Quick bug fix**
```
User: "I need to fix a bug where the search times out"

Claude: I'll help you fix the search timeout bug. Let me guide you through the proper workflow.

First, let me check your project status...

[Checks git status]

You're on main with uncommitted changes to src/search.ex.
These changes look related to the bug fix you're working on.

Let's create a bug fix branch and commit this properly:

[Creates branch: git checkout -b fix/search-timeout]

Now, have you written a test that reproduces the timeout issue?
> No, not yet

I recommend writing a test first that demonstrates the timeout. This ensures:
1. We can verify the bug exists
2. We know when it's fixed
3. We prevent regression

Here's a suggested test structure for Elixir:
[Provides test example]

Once you've added the test and verified it fails, go ahead and implement your fix.
Then we'll run the full test suite and commit everything properly.

Let me know when you're ready to test and commit!
```

**Scenario 3: Guided commit**
```
User: "I've made changes and want to commit them"

Claude: Great! Let's commit your changes properly. First, let me see what you've changed...

[Shows: git status and git diff --stat]

I can see you've modified:
- src/auth/register.ex (authentication logic)
- lib/router.ex (added routes)
- test/auth_test.exs (added tests)
- README.md (updated docs)

Let me run the build and tests to make sure everything works...

[Runs: build && test]

✓ Build successful
✓ All 52 tests passing (5 new tests added!)

Perfect! Now let's create a proper commit message. Based on your changes,
this looks like a new feature. I'll help you write a conventional commit message.

Type: feat (new feature)
Scope: auth (authentication module)
Subject: add user registration with email validation

Here's what I suggest:

---
feat(auth): add user registration with email validation

- Implement user registration form
- Add email validation and password requirements
- Create User model with secure password hashing
- Add registration routes and controller
- Update README with authentication docs

Closes #42
---

Does this accurately describe your changes? (Y/n)
> y

[Commits the changes]

✓ Changes committed successfully!

Now, would you like to push this to remote and create a pull request?
```

## Error Handling

Handle these scenarios:

1. **Merge conflicts**
   - Explain what happened
   - Guide through conflict resolution
   - Recommend using editor or git mergetool

2. **Failing tests**
   - Don't allow commit if tests fail (without explicit override)
   - Help debug failing tests
   - Suggest running tests in isolation

3. **Large changesets**
   - Recommend breaking into smaller commits
   - Suggest atomic commits for easier review

4. **Diverged branches**
   - Explain situation (local vs remote)
   - Guide through rebase or merge

5. **Missing branch protection**
   - Warn if committing directly to main/master
   - Recommend feature branch workflow

## Success Criteria

The skill is successful when:
- ✓ Changes are properly tested
- ✓ Code is formatted correctly
- ✓ Commit message follows conventions
- ✓ Changes are pushed to remote
- ✓ PR is created (if applicable)
- ✓ User understands the workflow

## Tips

- **Be encouraging**: Positive reinforcement for good practices
- **Explain why**: Help users understand the reasons behind best practices
- **Be flexible**: Adapt to project-specific workflows
- **Check frequently**: Run tests after each significant change
- **Document**: Encourage updating documentation with code changes
- **Review together**: Walk through changes before committing
- **Teach git**: Use this as an opportunity to explain git concepts
