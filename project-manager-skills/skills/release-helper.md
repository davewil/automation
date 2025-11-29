---
name: release-helper
description: Create production releases with version bumping and changelog generation
---

# Release Helper - Guided Release Management

## Description

Guide users through creating production releases with automated version bumping, changelog generation, testing, tagging, and deployment. This skill ensures releases follow best practices and nothing is forgotten.

## Prerequisites

- Project must be registered in Project Manager
- Project must have git repository
- Working build and test suite
- User is ready to create a release
- Semantic versioning preferred (but not required)

## Instructions

When this skill is invoked, guide the user through the release process:

### 1. Understand Release Type

Determine what kind of release this is:

```
What type of release are you creating?

1. Patch (x.y.Z) - Bug fixes, no new features
   Example: 1.2.3 → 1.2.4
   Use for: Security fixes, bug fixes, minor improvements

2. Minor (x.Y.0) - New features, backwards compatible
   Example: 1.2.3 → 1.3.0
   Use for: New features, deprecations (with backwards compatibility)

3. Major (X.0.0) - Breaking changes
   Example: 1.2.3 → 2.0.0
   Use for: Breaking API changes, major rewrites

4. Pre-release - Alpha, beta, or RC
   Example: 1.3.0-beta.1
   Use for: Testing before stable release

5. Custom - Specify version manually

Which type? (1-5):
```

### 2. Determine Current Version

Find the current version:

```bash
echo "==> Detecting current version..."

current_version=""

# Check common version files
if [ -f "package.json" ]; then
    current_version=$(jq -r '.version' package.json)
    version_file="package.json"
elif [ -f "mix.exs" ]; then
    current_version=$(grep 'version:' mix.exs | grep -oP '"\K[^"]+' | head -1)
    version_file="mix.exs"
elif [ -f "Cargo.toml" ]; then
    current_version=$(grep '^version = ' Cargo.toml | grep -oP '"\K[^"]+' | head -1)
    version_file="Cargo.toml"
elif [ -f "pyproject.toml" ]; then
    current_version=$(grep '^version = ' pyproject.toml | grep -oP '"\K[^"]+' | head -1)
    version_file="pyproject.toml"
elif [ -f "*.csproj" ]; then
    current_version=$(grep '<Version>' *.csproj | grep -oP '>\K[^<]+' | head -1)
    version_file="*.csproj"
fi

# Fallback to git tags
if [ -z "$current_version" ]; then
    current_version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
    version_file="git tags"
fi

# Parse version components
if [[ "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
fi
```

**Present current version:**

```
Current Version: ${current_version}
Source: ${version_file}

Parsed as:
  Major: ${major}
  Minor: ${minor}
  Patch: ${patch}
```

### 3. Calculate Next Version

Based on release type:

```bash
case "$release_type" in
    1) # Patch
        next_version="$major.$minor.$((patch + 1))"
        ;;
    2) # Minor
        next_version="$major.$((minor + 1)).0"
        ;;
    3) # Major
        next_version="$((major + 1)).0.0"
        ;;
    4) # Pre-release
        read -p "Enter pre-release identifier (e.g., beta.1, rc.2): " prerelease
        next_version="$major.$((minor + 1)).0-$prerelease"
        ;;
    5) # Custom
        read -p "Enter version number: " next_version
        ;;
esac

echo ""
echo "Next Version: $next_version"
echo ""
read -p "Is this correct? (Y/n): " confirm
```

### 4. Check Repository State

Ensure clean state before release:

```bash
echo "==> Checking repository state..."

# Ensure on correct branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
    echo "⚠️  You're on branch '$current_branch', not main/master"
    read -p "Continue anyway? (y/N): " continue
    [ "$continue" != "y" ] && exit 1
fi

# Check for uncommitted changes
uncommitted=$(git status --porcelain)
if [ -n "$uncommitted" ]; then
    echo "❌ You have uncommitted changes:"
    git status --short
    echo ""
    echo "Please commit or stash changes before releasing."
    exit 1
fi

# Check if up to date with remote
git fetch origin --quiet
ahead=$(git rev-list --count origin/$current_branch..HEAD 2>/dev/null || echo 0)
behind=$(git rev-list --count HEAD..origin/$current_branch 2>/dev/null || echo 0)

if [ "$behind" -gt 0 ]; then
    echo "❌ You are $behind commits behind origin/$current_branch"
    echo "Pull latest changes first: git pull"
    exit 1
fi

echo "✅ Repository is clean and up to date"
```

### 5. Run Pre-Release Checks

Verify everything works:

```bash
echo ""
echo "===========================================
Pre-Release Checks
==========================================="
echo ""

# Build
echo "==> Running build..."
if ! build "$project_name"; then
    echo "❌ Build failed - fix before releasing"
    exit 1
fi
echo "✅ Build passing"

# Tests
echo ""
echo "==> Running tests..."
if ! test "$project_name"; then
    echo "❌ Tests failed - fix before releasing"
    exit 1
fi
echo "✅ Tests passing"

# Lint/Format check
echo ""
echo "==> Checking code quality..."
case "$project_type" in
    elixir)
        mix format --check-formatted && mix credo
        ;;
    node)
        bun run lint
        ;;
    # ... other types
esac

if [ $? -eq 0 ]; then
    echo "✅ Code quality checks passing"
else
    echo "⚠️  Code quality issues found"
    read -p "Continue anyway? (y/N): " continue
    [ "$continue" != "y" ] && exit 1
fi

echo ""
echo "✅ All pre-release checks passed!"
```

### 6. Generate Changelog

Create or update CHANGELOG.md:

```bash
echo ""
echo "==> Generating changelog..."

# Get commits since last release
last_tag=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)

# Categorize commits by type
commits=$(git log $last_tag..HEAD --pretty=format:"%s" --no-merges)

features=$(echo "$commits" | grep "^feat" | sed 's/^feat[:(].*[):]/•/')
fixes=$(echo "$commits" | grep "^fix" | sed 's/^fix[:(].*[):]/•/')
breaking=$(echo "$commits" | grep "BREAKING CHANGE")
chores=$(echo "$commits" | grep "^chore" | sed 's/^chore[:(].*[):]/•/')

# Generate changelog entry
changelog_entry="## [$next_version] - $(date +%Y-%m-%d)

"

if [ -n "$breaking" ]; then
    changelog_entry+="### ⚠️ BREAKING CHANGES

$breaking

"
fi

if [ -n "$features" ]; then
    changelog_entry+="### ✨ Features

$features

"
fi

if [ -n "$fixes" ]; then
    changelog_entry+="### 🐛 Bug Fixes

$fixes

"
fi

if [ -n "$chores" ]; then
    changelog_entry+="### 🔧 Chores

$chores

"
fi
```

**Present changelog:**

```
Generated Changelog Entry:
──────────────────────────

## [${next_version}] - $(date +%Y-%m-%d)

### ✨ Features
• Add user authentication with JWT
• Implement password reset flow
• Add email verification

### 🐛 Bug Fixes
• Fix login timeout issue
• Resolve memory leak in background jobs

### 🔧 Chores
• Update dependencies
• Improve test coverage

────────────────────────────

Edit changelog before continuing? (y/N):
```

### 7. Update Version Numbers

Bump version in all relevant files:

```bash
echo ""
echo "==> Updating version numbers..."

case "$project_type" in
    node)
        # Update package.json
        jq ".version = \"$next_version\"" package.json > package.json.tmp
        mv package.json.tmp package.json
        echo "✅ Updated package.json"

        # Update package-lock.json if exists
        if [ -f "package-lock.json" ]; then
            jq ".version = \"$next_version\"" package-lock.json > package-lock.json.tmp
            mv package-lock.json.tmp package-lock.json
            echo "✅ Updated package-lock.json"
        fi
        ;;

    elixir)
        # Update mix.exs
        sed -i "s/version: \".*\"/version: \"$next_version\"/" mix.exs
        echo "✅ Updated mix.exs"
        ;;

    rust)
        # Update Cargo.toml
        sed -i "s/^version = \".*\"/version = \"$next_version\"/" Cargo.toml
        echo "✅ Updated Cargo.toml"

        # Update Cargo.lock
        cargo update --workspace
        echo "✅ Updated Cargo.lock"
        ;;

    python)
        # Update pyproject.toml or setup.py
        if [ -f "pyproject.toml" ]; then
            sed -i "s/^version = \".*\"/version = \"$next_version\"/" pyproject.toml
            echo "✅ Updated pyproject.toml"
        fi
        ;;

    dotnet)
        # Update .csproj files
        for csproj in *.csproj; do
            sed -i "s|<Version>.*</Version>|<Version>$next_version</Version>|" "$csproj"
            echo "✅ Updated $csproj"
        done
        ;;
esac

# Update CHANGELOG.md
if [ -f "CHANGELOG.md" ]; then
    # Insert new entry after header
    sed -i "/# Changelog/a\\
\\
$changelog_entry" CHANGELOG.md
    echo "✅ Updated CHANGELOG.md"
else
    # Create new CHANGELOG.md
    cat > CHANGELOG.md <<EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

$changelog_entry
EOF
    echo "✅ Created CHANGELOG.md"
fi
```

### 8. Build Release Artifacts

Create production build:

```bash
echo ""
echo "==> Building release artifacts..."

# Clean previous builds
case "$project_type" in
    node)
        rm -rf dist build
        ;;
    elixir)
        rm -rf _build/prod
        ;;
    rust)
        cargo clean --release
        ;;
esac

# Build for production
case "$project_type" in
    node)
        NODE_ENV=production bun run build
        ;;
    elixir)
        MIX_ENV=prod mix release
        ;;
    rust)
        cargo build --release
        ;;
    dotnet)
        dotnet publish -c Release
        ;;
esac

if [ $? -eq 0 ]; then
    echo "✅ Release build successful"
else
    echo "❌ Release build failed"
    exit 1
fi
```

### 9. Create Git Commit and Tag

Commit version changes and create tag:

```bash
echo ""
echo "==> Creating release commit and tag..."

# Commit version bump and changelog
git add .
git commit -m "chore(release): bump version to $next_version

Release $next_version

$changelog_entry

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "✅ Created release commit"

# Create annotated tag
git tag -a "v$next_version" -m "Release $next_version

$changelog_entry"

echo "✅ Created tag v$next_version"

# Show the tag
git show "v$next_version" --quiet
```

### 10. Push to Remote

Push commits and tags:

```bash
echo ""
read -p "Push release to origin? (Y/n): " push_release

if [ "$push_release" != "n" ]; then
    echo "==> Pushing to origin..."

    # Push commits
    git push origin "$current_branch"
    echo "✅ Pushed commits"

    # Push tags
    git push origin "v$next_version"
    echo "✅ Pushed tag v$next_version"
fi
```

### 11. Create GitHub Release (Optional)

Create GitHub release with notes:

```bash
echo ""
read -p "Create GitHub release? (Y/n): " create_gh_release

if [ "$create_gh_release" != "n" ]; then
    if command -v gh &> /dev/null; then
        echo "==> Creating GitHub release..."

        # Create release with gh CLI
        gh release create "v$next_version" \
            --title "Release $next_version" \
            --notes "$changelog_entry"

        if [ $? -eq 0 ]; then
            echo "✅ GitHub release created"
            gh release view "v$next_version" --web
        else
            echo "❌ Failed to create GitHub release"
        fi
    else
        echo "⚠️  gh CLI not installed"
        echo "Install: brew install gh"
        echo "Or create release manually: $github_url/releases/new"
    fi
fi
```

### 12. Deploy (Optional)

Optionally deploy the release:

```bash
echo ""
read -p "Deploy this release? (y/N): " deploy_release

if [ "$deploy_release" = "y" ]; then
    echo ""
    echo "Deployment options:"
    echo "1. Deploy to staging"
    echo "2. Deploy to production"
    echo "3. Both (staging first, then production)"
    echo "4. Skip deployment"
    echo ""
    read -p "Choose deployment target (1-4): " deploy_target

    case "$deploy_target" in
        1)
            echo "==> Deploying to staging..."
            # Project-specific deployment
            ;;
        2)
            echo "==> Deploying to production..."
            echo "⚠️  This will deploy to PRODUCTION"
            read -p "Are you sure? Type 'YES' to confirm: " confirm
            if [ "$confirm" = "YES" ]; then
                # Production deployment
                echo "Deploying..."
            else
                echo "Deployment cancelled"
            fi
            ;;
        3)
            echo "==> Deploying to staging first..."
            # Staging deployment
            echo "✅ Staging deployed"
            echo ""
            read -p "Staging looks good? Deploy to production? (y/N): " prod_confirm
            if [ "$prod_confirm" = "y" ]; then
                # Production deployment
                echo "✅ Production deployed"
            fi
            ;;
    esac
fi
```

### 13. Provide Release Summary

Give comprehensive summary:

```
===========================================
Release Complete! 🎉
===========================================

Version: $next_version
Type: ${release_type_name}
Date: $(date)

What Was Done:
──────────────

✅ Pre-release checks (build, tests, lint)
✅ Generated changelog
✅ Updated version in ${version_files}
✅ Built release artifacts
✅ Created release commit
✅ Created git tag v$next_version
✅ Pushed to origin
${if github_release}✅ Created GitHub release${endif}
${if deployed}✅ Deployed to ${deploy_target}${endif}

Changelog Highlights:
────────────────────

${changelog_summary}

Links:
──────

• GitHub Release: ${github_url}/releases/tag/v${next_version}
• Changelog: ${github_url}/blob/main/CHANGELOG.md
${if deployed}• Production: ${production_url}${endif}

Next Steps:
───────────

1. ✅ Announce release to team
2. ✅ Update documentation if needed
3. ✅ Monitor for issues
4. ⏳ Start next development cycle

Announcement Template:
─────────────────────

🚀 ${project_name} v${next_version} Released!

${changelog_summary}

Full changelog: ${github_url}/releases/tag/v${next_version}

────────────────────────────────────

Great work on this release! 🎉
```

## Context

Use this skill when:
- Ready to create a new release
- Want to ensure nothing is forgotten
- Need to generate changelogs
- Creating first release
- Following semantic versioning
- Want automated version bumping

## Example Usage

**Scenario 1: Patch release for bug fixes**

```
User: "Create a patch release for grocery-planner"

Claude: I'll guide you through creating a patch release.

Current version: 1.2.3 (from package.json)

Creating patch release: 1.2.3 → 1.2.4

[Runs pre-release checks]
✅ Build passing
✅ Tests passing (47/47)
✅ Code quality checks passing

[Generates changelog]

Changelog for v1.2.4:
─────────────────────

### 🐛 Bug Fixes
• Fix login timeout after 30 minutes
• Resolve shopping list sync issue
• Fix recipe search crash

Is this accurate? (Y/n): y

[Updates version, builds, commits, tags]

✅ Release v1.2.4 complete!

Push to GitHub? (Y/n): y

[Pushes and creates GitHub release]

🎉 Release published!
View at: https://github.com/user/grocery-planner/releases/tag/v1.2.4
```

**Scenario 2: Major release with breaking changes**

```
User: "Create a major release for api-server, we have breaking changes"

Claude: Creating a major release with breaking changes.

Current version: 1.5.3
Next version: 2.0.0

⚠️  This is a MAJOR version bump (breaking changes expected)

[Runs pre-release checks]

[Generates changelog]

Changelog for v2.0.0:
────────────────────

### ⚠️  BREAKING CHANGES

• Authentication now requires API keys (username/password removed)
• Response format changed from XML to JSON
• Minimum supported Node version: 18 (was 16)

### ✨ Features
• New JWT-based authentication
• GraphQL API support
• Rate limiting built-in

### 🐛 Bug Fixes
• Fixed memory leak in WebSocket connections

Migration guide needed? (Y/n): y

I'll create MIGRATION.md with upgrade instructions...

[Creates comprehensive migration guide]

✅ Created MIGRATION.md with:
  • Authentication migration steps
  • Code examples for new API
  • Breaking change details

Continue with release? (Y/n): y

[Completes release process]

✅ Major release v2.0.0 complete!

This is a breaking change release. Recommendations:
  1. ✅ Announce to users with advance notice
  2. ✅ Share migration guide
  3. ✅ Support v1.x for transition period
  4. ✅ Monitor closely after release
```

## Error Handling

Handle these scenarios:

### 1. Tests Failing

```
❌ Tests failed - cannot release

3 tests failing:
  • test_authentication_flow
  • test_api_response_format
  • test_database_migration

Fix these tests before creating a release.

Would you like me to help debug the failing tests?
```

### 2. Uncommitted Changes

```
❌ You have uncommitted changes

M  src/api.ts
M  src/auth.ts
?? src/new_feature.ts

Cannot create release with uncommitted changes.

Options:
  1. Commit changes and include in release
  2. Stash changes and release without them
  3. Cancel release

What would you like to do? (1-3):
```

### 3. Behind Remote

```
❌ Your branch is 3 commits behind origin/main

You need to pull latest changes before releasing.

Pull now? (Y/n): y

[Pulls changes]

⚠️  After pulling, please verify everything still works:
  • Run tests
  • Review pulled commits

Then run release again.
```

### 4. Version Exists

```
❌ Tag v1.2.4 already exists

This version has already been released.

Options:
  1. Create v1.2.5 instead (patch)
  2. Create v1.3.0 instead (minor)
  3. Delete existing tag (dangerous!)
  4. Cancel

What would you like to do? (1-4):
```

## Success Criteria

The skill is successful when:
- ✓ All pre-release checks pass
- ✓ Version is correctly bumped
- ✓ Changelog is generated and accurate
- ✓ Release artifacts are built
- ✓ Git commit and tag are created
- ✓ Changes are pushed to remote
- ✓ GitHub release is created (if requested)
- ✓ User has clear summary and next steps

## Tips

- **Test before release**: Always run full test suite
- **Clean state**: Ensure no uncommitted changes
- **Changelog accuracy**: Review generated changelog
- **Semantic versioning**: Follow semver for predictability
- **Announce breaking changes**: Advance notice for major versions
- **Migration guides**: Provide for breaking changes
- **Monitor after release**: Watch for issues
- **Document process**: Keep release notes clear

## Advanced Features

### Automated Release Notes

Generate comprehensive release notes:

```markdown
# Release Notes - v${next_version}

## Overview

This ${release_type} release includes ${feature_count} new features, ${fix_count} bug fixes, and ${improvement_count} improvements.

## Highlights

🌟 **Top Features**
${top_features}

🐛 **Critical Fixes**
${critical_fixes}

## Installation

\`\`\`bash
# npm
npm install ${package_name}@${next_version}

# bun
bun add ${package_name}@${next_version}
\`\`\`

## Upgrade Guide

${upgrade_instructions}

## Full Changelog

${full_changelog}

## Contributors

Thanks to all contributors who made this release possible:
${contributors_list}
```

### Release Checklist

Interactive checklist:

```
Pre-Release Checklist:
─────────────────────

Code Quality:
  ✅ All tests passing
  ✅ No lint errors
  ✅ Code coverage > 80%
  ✅ Dependencies up to date

Documentation:
  ✅ README updated
  ✅ API docs current
  ✅ Migration guide (if breaking)
  ✅ Changelog generated

Security:
  ✅ No known vulnerabilities
  ✅ Security scan passed
  ✅ Secrets not exposed

Release:
  ⏳ Version bumped
  ⏳ Built successfully
  ⏳ Tagged and pushed
  ⏳ GitHub release created
  ⏳ Deployed to production

Post-Release:
  ⏳ Team notified
  ⏳ Users notified
  ⏳ Documentation published
  ⏳ Monitoring enabled
```

### Multi-Environment Releases

Handle complex deployments:

```
Release Pipeline:
────────────────

1. Development (auto-deploy on push)
   ✅ Deployed v1.2.4-dev.123

2. Staging (manual trigger)
   ⏳ Deploy v1.2.4-rc.1? (Y/n):

3. Production (after approval)
   ⏳ Requires 2 approvals
   ⏳ Current: 0/2

Deployment Strategy:
  • Blue-green deployment
  • Canary: 10% → 50% → 100%
  • Rollback: Automatic on error
```