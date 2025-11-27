# Example: Monday Morning Multi-Project Sync

This example demonstrates using the **multi-project-sync** skill to synchronize all projects at the start of the work week.

## Scenario

It's Monday morning and you have 6 configured projects. Over the weekend, your team pushed updates to several projects. You want to sync everything, check health status, and plan your week based on what needs attention.

## Walkthrough

### Starting the Interaction

```
You: Sync all my projects for Monday morning

Claude: Good morning! I'll sync all your projects and give you a complete overview for the week.
```

At this point, Claude invokes the **multi-project-sync** skill.

### Step 1: Gather Project List

```
Claude: Gathering all configured projects...

Found 6 projects:
  1. grocery-planner
  2. api-server
  3. mobile-app
  4. automation
  5. data-pipeline
  6. legacy-app

Sync all projects? Or enter numbers for specific ones (e.g., 1,2,4):
```

```
You: all
```

### Step 2: Check Accessibility

```
Claude: Checking project accessibility...

  ✓ grocery-planner: Accessible
  ✓ api-server: Accessible
  ✓ mobile-app: Accessible
  ✓ automation: Accessible
  ✓ data-pipeline: Accessible
  ⚠️  legacy-app: Directory not found at ~/old-projects/legacy-app

Warning: legacy-app is not accessible.

Continue with 5 accessible projects only? (Y/n):
```

```
You: y
```

### Step 3: Scan Current State

```
Claude: Scanning all projects... This may take a moment.

==> Analyzing grocery-planner...
   Branch: main | Changes: 0 | Behind: 0 | Ahead: 0

==> Analyzing api-server...
   Branch: main | Changes: 0 | Behind: 23 | Ahead: 0

==> Analyzing mobile-app...
   Branch: main | Changes: 0 | Behind: 45 | Ahead: 0

==> Analyzing automation...
   Branch: main | Changes: 0 | Behind: 0 | Ahead: 2

==> Analyzing data-pipeline...
   Branch: develop | Changes: 3 | Behind: 0 | Ahead: 1

Done scanning.
```

### Step 4: Status Overview

```
Claude:
===========================================
Multi-Project Status Overview
===========================================

Project            Branch      Changes  Behind  Ahead  Status
─────────────────────────────────────────────────────────────
grocery-planner    main        0        0       0      ✅ Clean
api-server         main        0        23      0      ⚠️  Behind
mobile-app         main        0        45      0      ⚠️  Behind
automation         main        0        0       2      ⚠️  Ahead
data-pipeline      develop     3        0       1      ⚠️  Changes
legacy-app         -           -        -       -      ❌ Missing

Summary:
────────
  Total Projects:     6
  Clean:              1 (17%)
  Behind Remote:      2 (33%)
  Uncommitted:        1 (17%)
  Ahead of Remote:    1 (17%)
  Inaccessible:       1 (17%)

Recommendations:
────────────────
  🔄 Pull updates: api-server (23 commits), mobile-app (45 commits)
  💾 Review changes: data-pipeline (3 files modified)
  🚀 Consider pushing: automation (2 commits ahead)
```

### Step 5: Choose Sync Strategy

```
Claude: How would you like to proceed?

1. Safe Sync (Recommended):
   - Pull api-server and mobile-app
   - Skip data-pipeline (has uncommitted changes)
   - Leave automation (ahead is okay)
   - Time: ~2-3 minutes

2. Aggressive Sync:
   - Stash changes in data-pipeline
   - Pull all projects
   - Pop stashes after
   - ⚠️  May cause merge conflicts
   - Time: ~5-10 minutes

3. Full Sync + Update:
   - Pull all projects
   - Check for outdated dependencies
   - Run health checks
   - Time: ~15-30 minutes

4. Custom:
   - I'll choose which projects to sync

5. Report Only:
   - Just show me the status, don't sync

Which strategy? (1-5):
```

```
You: 3 (full sync with updates)
```

### Step 6: Handle Uncommitted Changes

```
Claude:
Projects with Uncommitted Changes:
───────────────────────────────────

data-pipeline (develop):
  M  src/pipeline.py
  M  config/settings.yml
  ?? src/new_transform.py

What would you like to do?

  (c)ommit - Commit these changes with message
  (s)tash  - Stash for later
  (v)iew   - View diffs first
  (s)kip   - Leave as-is, don't sync this project

Choice:
```

```
You: v
```

```
Claude: Showing changes in data-pipeline...

[Shows git diff output]

Modified pipeline.py:
  + Added new data validation step
  + Fixed timezone handling bug

Modified settings.yml:
  + Increased batch size from 100 to 500

New file new_transform.py:
  + Customer data transformation module

These look like work in progress on a new feature.

What would you like to do?
  (c)ommit, (s)tash, or (s)kip:
```

```
You: c
```

```
Claude: Great! Let's commit these changes.

Suggested commit message:
  "feat(pipeline): add customer data transformation

   - Add new data validation step
   - Fix timezone handling in pipeline
   - Increase batch size to 500 for better performance
   - Add customer data transformation module"

Use this message? Or provide your own:
```

```
You: [Enter to accept]
```

```
Claude:
[Executing: git add . && git commit -m "..."]
✅ Changes committed in data-pipeline

Now ready to sync this project too.
```

### Step 7: Execute Sync

```
Claude:
===========================================
Executing Full Sync
===========================================

Project 1/5: grocery-planner
─────────────────────────────
  ✅ Already up to date

Project 2/5: api-server
───────────────────────
  Pulling 23 commits...
  remote: Counting objects: 67, done.
  remote: Compressing objects: 100%, done.
  Receiving objects: 100% (67/67), done.

  ✅ Pulled 23 commits
  📝 Changes:
    • feat: Add GraphQL API support
    • feat: Implement rate limiting
    • fix: Resolve authentication timeout
    • chore: Update dependencies
    ... (19 more)

Project 3/5: mobile-app
───────────────────────
  Pulling 45 commits...
  remote: Counting objects: 134, done.
  Receiving objects: 100% (134/134), done.

  ✅ Pulled 45 commits
  📝 Major changes:
    • feat: Complete redesign of user profile
    • feat: Add biometric authentication
    • feat: Implement offline mode
    • fix: Crash on low memory devices
    ... (41 more)

Project 4/5: automation
───────────────────────
  ⏭️  Ahead of remote by 2 commits (skipping pull)
  ℹ️  Your unpushed commits:
    • chore(deps): update all dependencies
    • docs: add comprehensive onboarding guide

Project 5/5: data-pipeline
───────────────────────────
  ✅ Already up to date (just committed local changes)

Sync Summary:
─────────────
  ✅ Synced: 5/5 projects
  ✅ Pulled: 68 total commits
  ✅ No conflicts

All projects successfully synced!
```

### Step 8: Check Dependencies

```
Claude: Now checking for outdated dependencies across all projects...

==> Checking grocery-planner...
   ✅ All dependencies up to date

==> Checking api-server...
   ⚠️  7 packages outdated
   Includes security fixes: yes
   Details:
     • phoenix: 1.6.16 → 1.7.2 (major - breaking changes)
     • plug: 1.14.0 → 1.14.2 (patch - bug fixes)
     • jason: 1.4.0 → 1.4.1 (patch - security fix)
     ... (4 more)

==> Checking mobile-app...
   ⚠️  15 packages outdated
   Includes security fixes: yes
   Details:
     • react-native: 0.71.0 → 0.72.3 (minor - new features)
     • expo: 48.0.0 → 49.0.0 (major - breaking changes)
     ... (13 more)

==> Checking automation...
   ✅ All dependencies up to date (just updated)

==> Checking data-pipeline...
   ⚠️  3 packages outdated
   Details:
     • pandas: 2.0.0 → 2.0.3 (patch - bug fixes)
     • numpy: 1.24.0 → 1.24.3 (patch - performance)
     • sqlalchemy: 2.0.15 → 2.0.18 (patch - bug fixes)

Dependency Summary:
───────────────────
  Projects with updates: 3/5 (60%)
  Total outdated: 25 packages
  Security fixes: 2 packages

Projects needing attention:
  ⚠️  api-server: 7 updates (including security)
  ⚠️  mobile-app: 15 updates (including security)
  ⚠️  data-pipeline: 3 updates
```

### Step 9: Health Checks

```
Claude: Running health checks on all synced projects...

==> Checking grocery-planner...
   Building... ✅ (12.3s)
   Testing... ✅ (8.7s - 47/47 passing)

==> Checking api-server...
   Building... ✅ (45.2s)
   Testing... ⚠️  (23.1s - 3 failing)
   Failed tests:
     • test_graphql_authentication
     • test_rate_limiting_headers
     • test_websocket_connection

==> Checking mobile-app...
   Building... ✅ (67.4s)
   Testing... ⚠️  (43.8s - 5 failing)
   Failed tests:
     • test_biometric_auth_flow
     • test_offline_data_sync
     • test_profile_image_upload
     • test_notification_permissions
     • test_deep_linking

==> Checking automation...
   Building... ✅ (3.2s)
   Testing... ✅ (2.1s - 6/6 passing)

==> Checking data-pipeline...
   Building... ✅ (8.9s)
   Testing... ✅ (15.3s - 34/34 passing)

Health Summary:
───────────────
  Builds Passing:  5/5 (100%) ✅
  Tests Passing:   3/5 (60%)
  Total Tests:     95 tests
  Failing Tests:   8 tests

Issues Requiring Attention:
  ❌ api-server: 3 failing tests (likely from new GraphQL features)
  ❌ mobile-app: 5 failing tests (from weekend's major updates)
```

### Step 10: Generate Report

```
Claude:
===========================================
Multi-Project Sync Report
===========================================

Date: Monday, November 27, 2025, 9:15 AM
Projects Scanned: 6 (5 accessible)
Projects Synced: 5

Actions Taken:
──────────────

Pulled Updates:
  ✅ api-server (23 commits)
  ✅ mobile-app (45 commits)

Committed Locally:
  ✅ data-pipeline (1 commit)
     feat(pipeline): add customer data transformation

Ahead of Remote:
  ℹ️  automation (2 commits unpushed)

Already Current:
  ✅ grocery-planner

Health Status:
──────────────

Builds:  5/5 passing ✅
Tests:   3/5 passing ⚠️

Issues Found:
  ❌ api-server: 3 failing tests
  ❌ mobile-app: 5 failing tests

Root causes:
  • api-server: Tests not updated for new GraphQL features
  • mobile-app: Tests broken by biometric auth and offline changes

Dependencies:
─────────────

Projects Needing Updates:
  ⚠️  api-server (7 packages, includes security fixes)
  ⚠️  mobile-app (15 packages, includes security fixes)
  ⚠️  data-pipeline (3 packages)

Security Fixes Available: 2 critical

Issues Requiring Attention:
───────────────────────────

Priority 1 (Today):
  1. Fix api-server tests (3 failures)
     → Likely need to update GraphQL test expectations
     → Use build-fixer skill if needed

  2. Fix mobile-app tests (5 failures)
     → Update tests for new biometric auth
     → Fix offline sync test mocks

  3. Update security dependencies
     → api-server: jason 1.4.0 → 1.4.1 (security)
     → mobile-app: react-native patch (security)
     → Use dependency-manager skill

Priority 2 (This Week):
  1. Review and push automation commits
  2. Update remaining dependencies (non-security)
  3. Fix legacy-app directory path

Priority 3 (Monthly):
  1. Review overall project health
  2. Update documentation
  3. Clean up build artifacts

Next Steps:
───────────

I recommend starting with:

  1. Fix api-server tests:
     "Help me fix the failing tests in api-server"

  2. Update security dependencies:
     "Update dependencies with security fixes in api-server and mobile-app"

  3. Fix mobile-app tests:
     "Help me fix the mobile-app test failures"

Would you like me to help with any of these now?

────────────────────────────────────

Report saved to: ~/.config/project-manager/sync-report-20251127-0915.txt
```

### User's Response

```
You: Help me fix the api-server tests first
```

```
Claude: I'll help you fix the failing tests in api-server. Let me switch to that project and diagnose the failures.

[Uses project-switcher skill to navigate to api-server]

==> Switching to api-server...
✅ Switched to: ~/projects/api-server

[Uses build-fixer skill to analyze test failures]

Running tests to capture failures...

Found 3 failing tests related to GraphQL features added over the weekend.

The tests are failing because they expect the old REST API response format, but the code now uses GraphQL.

Would you like me to help update these tests to work with the new GraphQL API?
```

## Key Takeaways

### What the Skill Did

1. **Gathered all projects** - Listed 6 configured projects
2. **Checked accessibility** - Found 1 inaccessible project
3. **Scanned current state** - Analyzed git status for each project
4. **Presented overview** - Clear table with status of each project
5. **Categorized actions** - Identified what each project needs
6. **Offered strategies** - Multiple sync approaches (safe/aggressive/full)
7. **Handled uncommitted changes** - Committed work in data-pipeline
8. **Executed sync** - Pulled 68 commits across 2 projects
9. **Checked dependencies** - Found 25 outdated packages
10. **Ran health checks** - Built and tested all projects
11. **Generated report** - Comprehensive summary with priorities
12. **Provided next steps** - Clear action items

### Benefits

- **Complete visibility**: See all projects at once
- **Time efficient**: Sync everything in minutes, not hours
- **Prioritized actions**: Know what needs attention first
- **No lost work**: Safely handled uncommitted changes
- **Caught issues early**: Found failing tests immediately
- **Security aware**: Identified security updates needed
- **Actionable**: Clear next steps with priorities

### Time Saved

**Without skill:**
- Manually check each project: 6 × 3 min = 18 minutes
- Pull updates one by one: 6 × 2 min = 12 minutes
- Check dependencies manually: 6 × 5 min = 30 minutes
- Run builds/tests individually: 6 × 5 min = 30 minutes
- **Total: ~90 minutes**

**With skill:**
- Full sync + health + dependencies: ~15 minutes
- **Time saved: 75 minutes (83%)**

### What Was Found

**Issues discovered:**
- 8 failing tests across 2 projects
- 2 security vulnerabilities in dependencies
- 1 project with directory path issue
- 68 commits that needed to be pulled

**Without Monday sync**, these issues might not have been discovered until they caused problems later in the week.

## Related Skills

- **project-switcher**: Used to navigate to api-server for test fixes
- **build-fixer**: Used to diagnose and fix failing tests
- **dependency-manager**: Will use to update packages with security fixes
- **project-health-check**: Could run on individual projects for deeper analysis

## Weekly Workflow Integration

This skill fits perfectly into a weekly workflow:

**Monday:**
- Run multi-project-sync (this example)
- Fix critical issues (failing tests)
- Update security dependencies

**During Week:**
- Work on features (use project-workflow)
- Switch between projects (use project-switcher)
- Fix builds as needed (use build-fixer)

**Friday:**
- Create releases (use release-helper)
- Clean up artifacts (use project-cleaner)
- Commit all work

**Result:** Organized, efficient week with all projects in good health.
