# Multi-Project Sync - Synchronize All Projects at Once

## Description

Synchronize multiple projects in one operation by pulling latest changes, checking health, updating dependencies, and identifying issues across all configured projects. This skill is perfect for Monday mornings or after time away to get a complete overview of all your projects.

## Prerequisites

- Multiple projects registered in Project Manager
- Projects exist locally
- Git remotes are configured
- User wants to sync/update multiple projects

## Instructions

When this skill is invoked, help sync all projects efficiently:

### 1. List All Projects

Start by identifying all projects to sync:

```bash
echo "==> Gathering all configured projects..."

# Get all project names
projects=$(jq -r 'keys[]' ~/.config/project-manager/projects.json)
project_count=$(echo "$projects" | wc -l)

echo "Found $project_count projects:"
echo "$projects" | nl

echo ""
read -p "Sync all projects? Or enter numbers to sync specific ones (e.g., 1,3,5): " selection
```

**Handle selection:**
- **All**: Sync every project
- **Specific**: Sync selected projects only
- **Pattern**: Sync projects matching pattern (e.g., "api-*")

### 2. Check Project Accessibility

Verify all projects are accessible:

```bash
echo "==> Checking project accessibility..."

inaccessible=""
for project in $projects; do
    local_path=$(jq -r ".\"$project\".local_path" ~/.config/project-manager/projects.json)

    # Expand ~ to home directory
    local_path="${local_path/#\~/$HOME}"

    if [ ! -d "$local_path" ]; then
        echo "⚠️  $project: Directory not found at $local_path"
        inaccessible="$inaccessible\n  - $project"
    else
        echo "✓ $project: Accessible"
    fi
done

if [ -n "$inaccessible" ]; then
    echo ""
    echo "⚠️  Some projects are not accessible:$inaccessible"
    echo ""
    read -p "Continue with accessible projects only? (Y/n): " continue
    [ "$continue" = "n" ] && exit 1
fi
```

### 3. Gather Current State

Collect status for all projects:

```bash
echo ""
echo "===========================================
Scanning All Projects...
==========================================="
echo ""

declare -A project_states

for project in $projects; do
    echo "==> Analyzing $project..."

    local_path=$(jq -r ".\"$project\".local_path" ~/.config/project-manager/projects.json)
    local_path="${local_path/#\~/$HOME}"

    cd "$local_path" || continue

    # Git status
    if [ -d ".git" ]; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        uncommitted=$(git status --porcelain | wc -l)

        # Check remote
        git fetch origin --quiet 2>/dev/null
        ahead=$(git rev-list --count origin/$branch..HEAD 2>/dev/null || echo 0)
        behind=$(git rev-list --count HEAD..origin/$branch 2>/dev/null || echo 0)

        # Store state
        project_states[$project]="branch=$branch,uncommitted=$uncommitted,ahead=$ahead,behind=$behind"
    else
        project_states[$project]="no_git=true"
    fi

    echo "   Branch: $branch | Changes: $uncommitted | Behind: $behind | Ahead: $ahead"
done
```

### 4. Present Overview

Show a comprehensive status table:

```
===========================================
Multi-Project Status Overview
===========================================

Project                  Branch        Changes  Behind  Ahead  Status
─────────────────────────────────────────────────────────────────────
grocery-planner          main          0        0       0      ✅ Clean
api-server               feature/auth  3        5       2      ⚠️  Needs sync
mobile-app               main          0        12      0      ⚠️  Behind
automation               main          0        0       1      ⚠️  Ahead
data-pipeline            develop       1        0       0      ⚠️  Changes
legacy-app               main          0        0       0      ⏸️  Paused

Summary:
  Total Projects:   6
  Clean:            1 (17%)
  Need Sync:        3 (50%)
  Uncommitted:      2 (33%)
  Ahead of Remote:  1 (17%)

Recommendations:
  🔄 Pull updates: api-server, mobile-app
  💾 Commit changes: data-pipeline
  🚀 Push commits: automation
```

### 5. Categorize Actions Needed

Group projects by required action:

```bash
echo ""
echo "==> Categorizing required actions..."

needs_pull=""
needs_commit=""
needs_push=""
has_conflicts=""
up_to_date=""

for project in $projects; do
    state="${project_states[$project]}"

    # Parse state
    behind=$(echo "$state" | grep -oP 'behind=\K\d+')
    ahead=$(echo "$state" | grep -oP 'ahead=\K\d+')
    uncommitted=$(echo "$state" | grep -oP 'uncommitted=\K\d+')

    if [ "$uncommitted" -gt 0 ] && [ "$behind" -gt 0 ]; then
        has_conflicts="$has_conflicts $project"
    elif [ "$behind" -gt 0 ]; then
        needs_pull="$needs_pull $project"
    elif [ "$uncommitted" -gt 0 ]; then
        needs_commit="$needs_commit $project"
    elif [ "$ahead" -gt 0 ]; then
        needs_push="$needs_push $project"
    else
        up_to_date="$up_to_date $project"
    fi
done
```

### 6. Present Sync Strategy

Offer sync options:

```
How would you like to proceed?

1. Safe Sync (Recommended):
   - Pull projects that are behind (${pull_count} projects)
   - Skip projects with uncommitted changes
   - Review conflicts manually
   - Time: ~2-5 minutes

2. Aggressive Sync:
   - Stash uncommitted changes
   - Pull all projects
   - Pop stashes after
   - ⚠️  May cause merge conflicts
   - Time: ~5-10 minutes

3. Full Sync + Update:
   - Pull all projects
   - Update dependencies
   - Run health checks
   - Time: ~15-30 minutes

4. Custom:
   - I'll choose which projects to sync

5. Report Only:
   - Just show me the status, don't sync

Which strategy? (1-5):
```

### 7. Execute Safe Sync

Pull updates for projects behind remote:

```bash
echo ""
echo "===========================================
Executing Safe Sync
==========================================="
echo ""

sync_success=""
sync_failed=""

for project in $needs_pull; do
    echo "==> Syncing $project..."

    local_path=$(jq -r ".\"$project\".local_path" ~/.config/project-manager/projects.json)
    local_path="${local_path/#\~/$HOME}"

    cd "$local_path" || continue

    branch=$(git rev-parse --abbrev-ref HEAD)

    # Pull
    if git pull origin "$branch" --quiet; then
        echo "   ✅ Successfully pulled latest changes"
        sync_success="$sync_success\n  ✓ $project"
    else
        echo "   ❌ Failed to pull (possible conflicts)"
        sync_failed="$sync_failed\n  ✗ $project"
    fi

    echo ""
done

echo "===========================================
Sync Complete
==========================================="
echo "Successful:$sync_success"
[ -n "$sync_failed" ] && echo "Failed:$sync_failed"
```

### 8. Handle Projects with Uncommitted Changes

For projects with uncommitted work:

```
Projects with Uncommitted Changes:
───────────────────────────────────

data-pipeline:
  M  src/pipeline.py
  ?? src/new_feature.py

What would you like to do with uncommitted changes?

Per project:
  1. data-pipeline: (c)ommit, (s)tash, (s)kip, or (v)iew details?

Or for all:
  a. Stash all uncommitted changes
  b. Skip all (leave as-is)
  c. Review each individually

Choice:
```

### 9. Run Health Checks (Optional)

After syncing, optionally check health:

```bash
echo ""
read -p "Run health checks on synced projects? (y/N): " run_health

if [ "$run_health" = "y" ]; then
    echo ""
    echo "===========================================
    Running Health Checks
    ==========================================="
    echo ""

    for project in $sync_success; do
        echo "==> Checking $project..."

        # Quick health check
        cd "$local_path"

        # Check if builds
        if build "$project" >/dev/null 2>&1; then
            echo "   ✅ Build: Passing"
        else
            echo "   ❌ Build: Failing"
        fi

        # Check tests
        if test "$project" >/dev/null 2>&1; then
            echo "   ✅ Tests: Passing"
        else
            echo "   ⚠️  Tests: Failing or none"
        fi

        echo ""
    done
fi
```

### 10. Check for Dependency Updates

Optionally check all projects for outdated dependencies:

```bash
echo ""
read -p "Check for outdated dependencies across all projects? (y/N): " check_deps

if [ "$check_deps" = "y" ]; then
    echo ""
    echo "===========================================
    Checking Dependencies
    ==========================================="
    echo ""

    has_updates=""

    for project in $projects; do
        echo "==> Checking $project..."

        outdated_output=$(outdated "$project" 2>&1)

        if echo "$outdated_output" | grep -q "outdated\|available\|newer"; then
            outdated_count=$(echo "$outdated_output" | grep -c "outdated\|available" || echo "?")
            echo "   ⚠️  $outdated_count packages outdated"
            has_updates="$has_updates\n  - $project ($outdated_count)"
        else
            echo "   ✅ All dependencies up to date"
        fi

        echo ""
    done

    if [ -n "$has_updates" ]; then
        echo ""
        echo "Projects with outdated dependencies:$has_updates"
        echo ""
        read -p "Update dependencies now? (y/N): " update_deps

        if [ "$update_deps" = "y" ]; then
            echo "Use the dependency-manager skill for each project to safely update"
        fi
    fi
fi
```

### 11. Generate Sync Report

Create a summary report:

```
===========================================
Multi-Project Sync Report
===========================================

Date: $(date)
Projects Scanned: ${total_count}
Projects Synced: ${synced_count}

Actions Taken:
──────────────

Pulled Updates (${pull_count}):
  ✓ api-server (5 commits)
  ✓ mobile-app (12 commits)

Uncommitted Changes (${uncommitted_count}):
  ⚠️  data-pipeline (1 file)

Ahead of Remote (${ahead_count}):
  ℹ️  automation (1 commit) - consider pushing

Already Up to Date (${clean_count}):
  ✓ grocery-planner

Health Status:
──────────────

Builds Passing:  5/6 (83%)
Tests Passing:   4/6 (67%)

Failed:
  ❌ data-pipeline: Build failing

Dependencies:
─────────────

Projects with Updates Available:
  ⚠️  grocery-planner (3 packages)
  ⚠️  api-server (7 packages)

Issues Requiring Attention:
───────────────────────────

1. data-pipeline: Build is broken after pull
   → Use build-fixer skill to diagnose

2. api-server: 7 outdated dependencies
   → Use dependency-manager skill to update

3. automation: 1 unpushed commit
   → Review and push changes

Next Steps:
───────────

Priority 1 (Immediate):
  • Fix data-pipeline build

Priority 2 (This Week):
  • Update dependencies in grocery-planner and api-server
  • Push automation commits

Priority 3 (Monthly):
  • Review all projects for technical debt
  • Update documentation

────────────────────────────────────

Report saved to: ~/.config/project-manager/sync-report-$(date +%Y%m%d).txt
```

### 12. Save Report to File

Optionally save the report:

```bash
report_file="$HOME/.config/project-manager/sync-report-$(date +%Y%m%d-%H%M%S).txt"

echo "$sync_report" > "$report_file"

echo ""
echo "Report saved to: $report_file"
echo ""
read -p "Open report in editor? (y/N): " open_report

if [ "$open_report" = "y" ]; then
    ${EDITOR:-nvim} "$report_file"
fi
```

## Context

Use this skill when:
- Monday morning sync of all projects
- After vacation or time away
- Before starting a work session
- Weekly project maintenance
- Want overview of all projects
- Checking for security updates across projects

## Example Usage

**Scenario 1: Monday morning sync**

```
User: "Sync all my projects"

Claude: I'll sync all your projects and give you a complete overview.

[Scans 6 projects]

Multi-Project Status Overview:
──────────────────────────────

Project              Branch    Changes  Behind  Ahead
───────────────────────────────────────────────────
grocery-planner      main      0        0       0      ✅
api-server           main      0        5       0      ⚠️
mobile-app           main      0        12      0      ⚠️
automation           main      0        0       1      ⚠️
data-pipeline        dev       1        0       0      ⚠️
legacy-app           main      0        0       0      ✅

Summary:
  • 2 projects need updates (api-server, mobile-app)
  • 1 project has uncommitted changes (data-pipeline)
  • 1 project is ahead of remote (automation)

Recommended: Safe Sync
  - Pull api-server and mobile-app
  - Skip data-pipeline (has changes)
  - Leave automation (ahead is okay)

Proceed with safe sync? (Y/n):
```

**Scenario 2: After vacation**

```
User: "I've been away for 2 weeks, sync everything"

Claude: Welcome back! Let me sync all your projects and check their health.

[Scans and pulls all projects]

Sync Complete!
──────────────

Updated Projects:
  ✓ grocery-planner: 23 commits pulled
  ✓ api-server: 45 commits pulled
  ✓ mobile-app: 67 commits pulled

[Runs health checks]

Health Status:
  ✅ grocery-planner: Build ✓, Tests ✓
  ⚠️  api-server: Build ✓, Tests ✗ (3 failing)
  ✅ mobile-app: Build ✓, Tests ✓

[Checks dependencies]

Outdated Dependencies:
  ⚠️  grocery-planner: 12 packages (including security fixes)
  ⚠️  api-server: 8 packages
  ⚠️  mobile-app: 15 packages

Recommendations:
  1. Fix api-server tests (3 failures - likely from recent changes)
  2. Update dependencies with security fixes
  3. Review recent commits to understand what changed

Would you like me to:
  a. Help fix api-server tests
  b. Update dependencies
  c. Show recent commits

Your choice:
```

## Error Handling

Handle these scenarios:

### 1. Pull Conflicts

```
❌ Failed to pull api-server - merge conflicts

Conflicting files:
  • src/auth.ex
  • config/config.exs

This project has both local changes and remote changes that conflict.

Options:
  1. Open in editor to resolve conflicts manually
  2. Stash local changes and pull clean
  3. Skip this project for now

What would you like to do? (1-3):
```

### 2. Authentication Failures

```
❌ Authentication failed for mobile-app

Could not fetch from origin. This usually means:
  • Git credentials expired
  • SSH key not configured
  • Network connectivity issue

Troubleshooting:
  1. Check network: ping github.com
  2. Test SSH: ssh -T git@github.com
  3. Re-authenticate: gh auth login

Skip this project and continue? (Y/n):
```

### 3. Disk Space Issues

```
⚠️  Low disk space detected

Available: 2.3 GB
Required (estimated): 5 GB for all updates

Some projects may fail to pull due to insufficient space.

Recommendations:
  1. Clean build artifacts: Use project-cleaner skill
  2. Remove unused projects
  3. Free up disk space manually

Continue anyway? (y/N):
```

### 4. Project Directories Missing

```
⚠️  Some project directories are missing:

Missing:
  • old-project (configured but directory doesn't exist)
  • archived-project (path incorrect)

Options:
  1. Clone missing projects from GitHub
  2. Remove from Project Manager config
  3. Update paths in config

What would you like to do? (1-3):
```

## Success Criteria

The skill is successful when:
- ✓ All accessible projects are scanned
- ✓ Projects behind remote are pulled
- ✓ Uncommitted changes are safely handled
- ✓ Health status is checked
- ✓ Dependency updates are identified
- ✓ Comprehensive report is generated
- ✓ User knows next actions to take

## Tips

- **Run regularly**: Weekly syncs prevent drift
- **Monday mornings**: Perfect for week planning
- **After time away**: Get back up to speed quickly
- **Before releases**: Ensure all projects are current
- **Commit first**: Fewer conflicts if you commit regularly
- **Categorize actions**: Don't try to fix everything at once
- **Prioritize**: Focus on actively developed projects
- **Save reports**: Track project health over time

## Advanced Features

### Parallel Syncing

For faster syncs with many projects:

```bash
echo "==> Syncing projects in parallel..."

# Create temporary directory for logs
tmpdir=$(mktemp -d)

# Sync in background
for project in $needs_pull; do
    (
        local_path=$(jq -r ".\"$project\".local_path" ~/.config/project-manager/projects.json)
        cd "$local_path"
        git pull origin $(git rev-parse --abbrev-ref HEAD) > "$tmpdir/$project.log" 2>&1
        echo $? > "$tmpdir/$project.status"
    ) &
done

# Wait for all to complete
wait

# Collect results
for project in $needs_pull; do
    status=$(cat "$tmpdir/$project.status")
    if [ "$status" -eq 0 ]; then
        echo "✓ $project synced successfully"
    else
        echo "✗ $project failed"
        cat "$tmpdir/$project.log"
    fi
done
```

### Dependency Update All

Update dependencies across all projects:

```bash
echo "==> Batch updating dependencies..."

for project in $projects; do
    echo "Updating $project dependencies..."

    # Get project type
    project_type=$(jq -r ".\"$project\".project_type" ~/.config/project-manager/projects.json)

    cd "$local_path"

    case "$project_type" in
        node)
            bun update
            ;;
        elixir)
            mix deps.update --all
            ;;
        # ... other types
    esac

    if build "$project" && test "$project"; then
        echo "✅ $project updated successfully"
        git add .
        git commit -m "chore(deps): update all dependencies"
    else
        echo "❌ $project update failed - rolling back"
        git checkout .
    fi
done
```

### Team Sync Report

Generate report for team:

```markdown
# Team Sync Report - $(date +%Y-%m-%d)

## Projects Status

| Project | Branch | Status | Notes |
|---------|--------|--------|-------|
| grocery-planner | main | ✅ Healthy | Up to date |
| api-server | main | ⚠️ Attention | 3 failing tests |
| mobile-app | main | ✅ Healthy | All good |

## This Week's Activity

- **45 commits** across all projects
- **12 PRs merged**
- **3 releases** deployed

## Action Items

- [ ] Fix api-server tests (@team-lead)
- [ ] Update dependencies (@dev1)
- [ ] Review security alerts (@dev2)

---
*Auto-generated by multi-project-sync skill*
```

### Scheduled Syncing

Set up automatic syncing:

```bash
# Add to crontab for weekly Monday morning sync
0 9 * * 1 /path/to/multi-project-sync --auto --report-email team@example.com
```
