# Project Cleaner - Clean Up Artifacts and Optimize

## Description

Clean up build artifacts, temporary files, caches, and optimize project storage. This skill helps reclaim disk space, fix corrupted caches, and keep projects lean. Perfect for when builds are slow, disk space is low, or you need a fresh start.

## Prerequisites

- Project must be registered in Project Manager
- Project directory must exist locally
- User wants to clean artifacts or free disk space

## Instructions

When this skill is invoked, help the user clean and optimize their project:

### 1. Analyze Current Disk Usage

Start by understanding what's taking up space:

```bash
cd <project_path>

echo "==> Analyzing disk usage..."

# Total project size
total_size=$(du -sh . 2>/dev/null | awk '{print $1}')

echo "Project: $project_name"
echo "Total size: $total_size"
echo ""

# Break down by common directories
echo "Disk Usage Breakdown:"
echo "─────────────────────"

# Find large directories
for dir in node_modules deps _build dist build target .next out coverage .cache; do
    if [ -d "$dir" ]; then
        size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        echo "  $dir: $size"
    fi
done

echo ""

# Find cache directories
echo "Cache Directories:"
for dir in .cache .turbo .parcel-cache .vite; do
    if [ -d "$dir" ]; then
        size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        echo "  $dir: $size"
    fi
done

# Find large files
echo ""
echo "Largest Files (top 10):"
find . -type f -not -path '*/\.git/*' -exec du -h {} + 2>/dev/null | \
    sort -rh | head -10 | awk '{printf "  %s\t%s\n", $1, $2}'
```

### 2. Present Cleaning Options

Show what can be cleaned:

```
===========================================
Cleanable Items Found
===========================================

Build Artifacts (~${build_size}):
  • _build/ (Elixir compiled files)
  • dist/ (Build output)
  • *.beam files (compiled bytecode)
  Reclaim: ${build_size}

Dependencies (~${deps_size}):
  • node_modules/ (npm packages)
  • deps/ (Elixir dependencies)
  • .mix/ (Mix cache)
  Reclaim: ${deps_size}
  Note: Will need reinstall

Caches (~${cache_size}):
  • .cache/ (Build cache)
  • .turbo/ (Turbo cache)
  • .parcel-cache/ (Parcel cache)
  Reclaim: ${cache_size}

Temporary Files (~${temp_size}):
  • *.log files
  • *.tmp files
  • __pycache__/
  Reclaim: ${temp_size}

Test Coverage (~${coverage_size}):
  • coverage/ directory
  • htmlcov/ (Python coverage)
  Reclaim: ${coverage_size}

Total Reclaimable: ${total_reclaimable}

─────────────────────────────────────

Cleaning Strategies:

1. Quick Clean (Safe) - ${quick_clean_size}
   • Remove build artifacts only
   • Keep dependencies and caches
   • Fast rebuild after

2. Standard Clean - ${standard_clean_size}
   • Remove build artifacts and caches
   • Keep dependencies
   • Moderate rebuild time

3. Deep Clean - ${deep_clean_size}
   • Remove everything (build, deps, caches)
   • Requires full reinstall
   • Maximum space reclaimed

4. Custom Clean
   • Choose exactly what to remove

5. Analyze Only
   • Just show me details, don't clean

Which strategy? (1-5):
```

### 3. Execute Quick Clean

Safe cleaning of build artifacts:

```bash
echo ""
echo "===========================================
Quick Clean (Build Artifacts)
==========================================="
echo ""

space_before=$(df -h . | awk 'NR==2 {print $3}')

removed_items=""

# Clean based on project type
case "$project_type" in
    elixir)
        if [ -d "_build" ]; then
            size=$(du -sh _build 2>/dev/null | awk '{print $1}')
            rm -rf _build
            echo "✅ Removed _build/ ($size)"
            removed_items="$removed_items\n  • _build/ ($size)"
        fi

        if [ -d ".elixir_ls" ]; then
            rm -rf .elixir_ls
            echo "✅ Removed .elixir_ls/"
            removed_items="$removed_items\n  • .elixir_ls/"
        fi

        # Clean compiled beam files
        find . -name "*.beam" -type f -delete 2>/dev/null
        echo "✅ Removed *.beam files"
        ;;

    node)
        if [ -d "dist" ]; then
            size=$(du -sh dist 2>/dev/null | awk '{print $1}')
            rm -rf dist
            echo "✅ Removed dist/ ($size)"
            removed_items="$removed_items\n  • dist/ ($size)"
        fi

        if [ -d "build" ]; then
            size=$(du -sh build 2>/dev/null | awk '{print $1}')
            rm -rf build
            echo "✅ Removed build/ ($size)"
            removed_items="$removed_items\n  • build/ ($size)"
        fi

        if [ -d ".next" ]; then
            size=$(du -sh .next 2>/dev/null | awk '{print $1}')
            rm -rf .next
            echo "✅ Removed .next/ ($size)"
            removed_items="$removed_items\n  • .next/ ($size)"
        fi
        ;;

    rust)
        if [ -d "target/debug" ]; then
            size=$(du -sh target/debug 2>/dev/null | awk '{print $1}')
            rm -rf target/debug
            echo "✅ Removed target/debug/ ($size)"
            removed_items="$removed_items\n  • target/debug/ ($size)"
        fi

        if [ -d "target/release" ]; then
            size=$(du -sh target/release 2>/dev/null | awk '{print $1}')
            rm -rf target/release
            echo "✅ Removed target/release/ ($size)"
            removed_items="$removed_items\n  • target/release/ ($size)"
        fi
        ;;

    dotnet)
        if [ -d "bin" ]; then
            size=$(du -sh bin 2>/dev/null | awk '{print $1}')
            rm -rf bin
            echo "✅ Removed bin/ ($size)"
            removed_items="$removed_items\n  • bin/ ($size)"
        fi

        if [ -d "obj" ]; then
            size=$(du -sh obj 2>/dev/null | awk '{print $1}')
            rm -rf obj
            echo "✅ Removed obj/ ($size)"
            removed_items="$removed_items\n  • obj/ ($size)"
        fi
        ;;

    python)
        # Remove __pycache__ directories
        find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null
        echo "✅ Removed __pycache__ directories"

        # Remove .pyc files
        find . -name "*.pyc" -delete 2>/dev/null
        echo "✅ Removed *.pyc files"
        ;;

    go)
        go clean -cache -testcache -modcache 2>/dev/null
        echo "✅ Cleaned Go caches"
        ;;
esac

space_after=$(df -h . | awk 'NR==2 {print $3}')

echo ""
echo "✅ Quick clean complete!"
echo ""
echo "Removed:$removed_items"
```

### 4. Execute Standard Clean

Remove build artifacts and caches:

```bash
echo ""
echo "===========================================
Standard Clean (Artifacts + Caches)
==========================================="
echo ""

# All quick clean items
# ... (same as above)

# Plus caches
echo ""
echo "==> Cleaning caches..."

for cache_dir in .cache .turbo .parcel-cache .vite .webpack .esbuild; do
    if [ -d "$cache_dir" ]; then
        size=$(du -sh "$cache_dir" 2>/dev/null | awk '{print $1}')
        rm -rf "$cache_dir"
        echo "✅ Removed $cache_dir/ ($size)"
    fi
done

# Coverage reports
if [ -d "coverage" ]; then
    size=$(du -sh coverage 2>/dev/null | awk '{print $1}')
    rm -rf coverage
    echo "✅ Removed coverage/ ($size)"
fi

# Log files
find . -name "*.log" -type f -delete 2>/dev/null
echo "✅ Removed *.log files"

# Temporary files
find . -name "*.tmp" -type f -delete 2>/dev/null
find . -name ".DS_Store" -type f -delete 2>/dev/null
echo "✅ Removed temporary files"

echo ""
echo "✅ Standard clean complete!"
```

### 5. Execute Deep Clean

Remove everything including dependencies:

```bash
echo ""
echo "⚠️  Deep Clean Warning"
echo "This will remove:"
echo "  • Build artifacts"
echo "  • Caches"
echo "  • Dependencies (node_modules, deps, etc.)"
echo ""
echo "You will need to reinstall dependencies after:"
case "$project_type" in
    node) echo "  bun install" ;;
    elixir) echo "  mix deps.get" ;;
    rust) echo "  cargo fetch" ;;
    python) echo "  pip install -r requirements.txt" ;;
esac
echo ""
read -p "Continue with deep clean? Type 'YES' to confirm: " confirm

if [ "$confirm" != "YES" ]; then
    echo "Deep clean cancelled"
    exit 0
fi

echo ""
echo "===========================================
Deep Clean (Everything)
==========================================="
echo ""

# All standard clean items
# ... (same as above)

# Plus dependencies
echo ""
echo "==> Removing dependencies..."

case "$project_type" in
    node)
        if [ -d "node_modules" ]; then
            size=$(du -sh node_modules 2>/dev/null | awk '{print $1}')
            echo "Removing node_modules/ ($size)..."
            rm -rf node_modules
            echo "✅ Removed node_modules/"
        fi
        ;;

    elixir)
        if [ -d "deps" ]; then
            size=$(du -sh deps 2>/dev/null | awk '{print $1}')
            rm -rf deps
            echo "✅ Removed deps/ ($size)"
        fi

        if [ -d ".mix" ]; then
            rm -rf .mix
            echo "✅ Removed .mix/"
        fi
        ;;

    rust)
        if [ -d "target" ]; then
            size=$(du -sh target 2>/dev/null | awk '{print $1}')
            rm -rf target
            echo "✅ Removed target/ ($size)"
        fi
        ;;

    python)
        if [ -d "venv" ] || [ -d ".venv" ]; then
            rm -rf venv .venv
            echo "✅ Removed virtual environment"
        fi
        ;;
esac

echo ""
echo "✅ Deep clean complete!"
echo ""
echo "⚠️  Remember to reinstall dependencies before building:"
case "$project_type" in
    node) echo "  bun install" ;;
    elixir) echo "  mix deps.get" ;;
    rust) echo "  cargo build" ;;
    python) echo "  pip install -r requirements.txt" ;;
esac
```

### 6. Clean Git Repository

Optimize git storage:

```bash
echo ""
read -p "Also clean Git repository? (removes unreachable objects) (y/N): " clean_git

if [ "$clean_git" = "y" ]; then
    echo ""
    echo "==> Cleaning Git repository..."

    # Get size before
    git_size_before=$(du -sh .git 2>/dev/null | awk '{print $1}')

    # Clean up unreachable objects
    git gc --aggressive --prune=now

    # Get size after
    git_size_after=$(du -sh .git 2>/dev/null | awk '{print $1}')

    echo "✅ Git repository optimized"
    echo "   Before: $git_size_before"
    echo "   After: $git_size_after"
fi
```

### 7. Find and Remove Large Files

Help identify space hogs:

```bash
echo ""
echo "==> Searching for unusually large files..."

large_files=$(find . -type f -size +10M -not -path '*/\.git/*' \
    -not -path '*/node_modules/*' -not -path '*/deps/*' 2>/dev/null)

if [ -n "$large_files" ]; then
    echo ""
    echo "Large files found (>10MB):"
    echo ""

    echo "$large_files" | while read file; do
        size=$(du -h "$file" | awk '{print $1}')
        echo "  $size  $file"
    done

    echo ""
    read -p "Review these files? Some may be unnecessary (y/N): " review

    if [ "$review" = "y" ]; then
        echo ""
        echo "Common unnecessary large files:"
        echo "  • Old database dumps (*.sql, *.dump)"
        echo "  • Large log files (*.log)"
        echo "  • Compiled binaries (check if needed)"
        echo "  • Downloaded datasets (can re-download)"
        echo ""

        echo "$large_files" | while read file; do
            echo ""
            echo "File: $file"
            size=$(du -h "$file" | awk '{print $1}')
            echo "Size: $size"

            read -p "Delete this file? (y/N): " delete_file
            if [ "$delete_file" = "y" ]; then
                rm "$file"
                echo "✅ Deleted"
            else
                echo "⏭️  Kept"
            fi
        done
    fi
fi
```

### 8. Clean Docker Resources (if applicable)

Clean Docker images and containers:

```bash
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then
    echo ""
    read -p "Clean Docker resources for this project? (y/N): " clean_docker

    if [ "$clean_docker" = "y" ]; then
        echo ""
        echo "==> Cleaning Docker resources..."

        # Stop containers
        if docker-compose ps -q 2>/dev/null | grep -q .; then
            docker-compose down
            echo "✅ Stopped containers"
        fi

        # Remove volumes
        read -p "Remove Docker volumes? (data will be lost) (y/N): " remove_volumes
        if [ "$remove_volumes" = "y" ]; then
            docker-compose down -v
            echo "✅ Removed volumes"
        fi

        # Show images for this project
        project_images=$(docker images | grep "$project_name")
        if [ -n "$project_images" ]; then
            echo ""
            echo "Docker images for this project:"
            echo "$project_images"
            echo ""
            read -p "Remove these images? (y/N): " remove_images
            if [ "$remove_images" = "y" ]; then
                docker images | grep "$project_name" | awk '{print $3}' | xargs docker rmi -f
                echo "✅ Removed Docker images"
            fi
        fi
    fi
fi
```

### 9. Verify Project Still Works

After cleaning, verify the project:

```bash
echo ""
read -p "Verify project still works? (recommended) (Y/n): " verify

if [ "$verify" != "n" ]; then
    echo ""
    echo "==> Verifying project..."

    # Reinstall dependencies if deep clean
    if [ "$clean_type" = "deep" ]; then
        echo "==> Reinstalling dependencies..."
        case "$project_type" in
            node) bun install ;;
            elixir) mix deps.get ;;
            rust) cargo fetch ;;
            python) pip install -r requirements.txt ;;
        esac

        if [ $? -eq 0 ]; then
            echo "✅ Dependencies reinstalled"
        else
            echo "❌ Dependency installation failed"
            exit 1
        fi
    fi

    # Build
    echo ""
    echo "==> Building..."
    if build "$project_name"; then
        echo "✅ Build successful"
    else
        echo "❌ Build failed"
        echo "Project may need attention after cleaning"
        exit 1
    fi

    # Test
    echo ""
    echo "==> Running tests..."
    if test "$project_name"; then
        echo "✅ Tests passing"
    else
        echo "⚠️  Some tests failing"
    fi
fi
```

### 10. Provide Summary

Give detailed summary of cleaning:

```
===========================================
Cleaning Complete! ✅
===========================================

Cleaning Type: ${clean_type_name}
Project: $project_name

Space Reclaimed:
────────────────

Before: ${space_before}
After:  ${space_after}
Freed:  ${space_freed} (${percent_freed}%)

Items Removed:
──────────────

Build Artifacts:
  ${build_items_removed}

Caches:
  ${cache_items_removed}

${if deep_clean}
Dependencies:
  ${dep_items_removed}
${endif}

${if git_cleaned}
Git Repository:
  Optimized .git/ (saved ${git_space_freed})
${endif}

Verification:
─────────────

${if verified}
  ✅ Build: Passing
  ✅ Tests: Passing
  ✅ Project: Working correctly
${else}
  ⏭️  Verification skipped
${endif}

Project Status:
───────────────

Current size: ${final_size}
Largest remaining items:
  ${largest_items}

Recommendations:
────────────────

${if should_add_gitignore}
  • Add build artifacts to .gitignore
${endif}
${if should_clean_git}
  • Run git gc periodically to optimize repository
${endif}
${if large_files_found}
  • Consider removing large files: ${large_file_list}
${endif}

Next Steps:
───────────

${if deep_clean}
  • Dependencies reinstalled ✅
  • Ready to continue development
${else}
  • Project ready to use immediately
${endif}

────────────────────────────────────

Your project is now cleaner and leaner! 🧹
```

## Context

Use this skill when:
- Disk space is low
- Build is mysteriously slow
- Corrupted cache suspected
- Starting fresh after issues
- Preparing for archive/backup
- Monthly maintenance
- Before long-term storage

## Example Usage

**Scenario 1: Low disk space**

```
User: "I'm running out of disk space, clean up my projects"

Claude: I'll help you free up disk space.

Analyzing grocery-planner...

Current size: 2.3 GB

Breakdown:
  node_modules: 1.5 GB (65%)
  dist: 234 MB (10%)
  .next: 189 MB (8%)
  .cache: 156 MB (7%)
  source code: 234 MB (10%)

Reclaimable: 2.1 GB (91% of project)

Recommendations:
  • Quick Clean: 423 MB (build artifacts)
  • Standard Clean: 768 MB (+ caches)
  • Deep Clean: 2.1 GB (+ dependencies)

Since you're low on space, I recommend Deep Clean.

Proceed with deep clean? (Y/n): y

[Cleans project]

✅ Freed 2.1 GB from grocery-planner

Want me to check other projects too?
```

**Scenario 2: Corrupted cache**

```
User: "Build is failing with weird errors, maybe cache issue"

Claude: Corrupted cache can cause mysterious build failures. Let me clean it.

Running Standard Clean on api-server...
  • Removes build artifacts
  • Removes all caches
  • Keeps dependencies

[Cleans caches]

✅ Removed:
  • _build/ (234 MB)
  • .cache/ (89 MB)
  • *.beam files

Now rebuilding from scratch...

[Builds project]

✅ Build successful!

The corrupted cache was the issue. Project is working again.
```

## Error Handling

Handle these scenarios:

### 1. Permission Denied

```
❌ Permission denied removing node_modules/

Some files are owned by different user or are read-only.

Fix:
  sudo chown -R $USER:$USER node_modules
  chmod -R u+w node_modules

Then try cleaning again.

Attempt fix? (Y/n):
```

### 2. Files In Use

```
⚠️  Some files are in use and cannot be removed

Files locked:
  • dist/app.js (process PID: 12345)

This usually means:
  • Development server is running
  • Editor has files open
  • Background process accessing files

Stop processes and retry? (Y/n):
```

### 3. Git Clean Would Remove Untracked

```
⚠️  Git clean would remove untracked files

Found untracked files:
  • src/new_feature.js
  • config/local_settings.json

These might be important work in progress!

Options:
  1. Skip git clean (keep untracked files)
  2. Commit files first, then clean
  3. Review each file
  4. Remove all (dangerous!)

What would you like? (1-4):
```

## Success Criteria

The skill is successful when:
- ✓ Disk space is reclaimed
- ✓ No important files are deleted
- ✓ Project still builds after cleaning
- ✓ Tests still pass
- ✓ User understands what was removed
- ✓ Recommendations provided for future

## Tips

- **Safe by default**: Start with quick clean
- **Verify after**: Always test build after deep clean
- **Back up first**: If unsure, back up important files
- **Regular cleaning**: Clean monthly to prevent buildup
- **Add to .gitignore**: Ensure build artifacts aren't committed
- **Docker pruning**: Clean Docker resources periodically
- **Git optimization**: Run git gc on large repos
- **Know your tools**: Each language has cleanup commands

## Advanced Features

### Automated Cleanup Schedule

Set up automatic cleaning:

```bash
# Add to crontab for weekly cleanup
0 2 * * 0 /path/to/project-cleaner --auto --type=standard --all-projects
```

### Disk Space Monitoring

Track space over time:

```bash
# Save disk usage history
echo "$(date),$(du -sh . | awk '{print $1}')" >> ~/.project-disk-usage.csv

# Show trend
echo "Disk usage trend for $project_name:"
grep "$project_name" ~/.project-disk-usage.csv | tail -10
```

### Cleanup Report

Generate detailed report:

```markdown
# Cleanup Report - ${project_name}

**Date:** $(date)
**Type:** ${clean_type}

## Summary

- **Space Before:** ${space_before}
- **Space After:** ${space_after}
- **Freed:** ${space_freed} (${percent}%)

## Items Removed

### Build Artifacts
${build_list}

### Caches
${cache_list}

### Large Files
${large_files_list}

## Verification

- Build: ${build_status}
- Tests: ${test_status}

## Recommendations

${recommendations_list}

---
*Generated by project-cleaner skill*
```

### Multi-Project Batch Clean

Clean all projects at once:

```bash
for project in $(projects); do
    echo "Cleaning $project..."
    # Run standard clean
    # Track space freed
    # Aggregate results
done

echo "Total space freed across all projects: $total_freed"
```
