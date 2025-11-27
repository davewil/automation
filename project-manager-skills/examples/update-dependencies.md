# Example: Updating Project Dependencies

This example demonstrates using the **dependency-manager** skill to safely update dependencies with breaking change detection.

## Scenario

You're maintaining the `grocery-planner` project and want to update dependencies. It's been a few weeks since the last update, and you want to ensure you're on the latest versions with security fixes.

## Walkthrough

### Starting the Interaction

```
You: Check and update dependencies for grocery-planner

Claude: I'll help you update dependencies for grocery-planner. Let me start by
checking what's outdated...
```

At this point, Claude invokes the **dependency-manager** skill and begins the workflow.

### Step 1: Analyze Current Dependencies

```
Claude: Checking for outdated dependencies...

[Executing: outdated grocery-planner]

Found 12 outdated packages. Let me analyze them by risk level...
```

### Step 2: Categorize by Risk

```
Claude:
===========================================
Dependency Update Plan: grocery-planner
===========================================

Total Outdated: 12
  Low Risk (Patch):    5 packages
  Medium Risk (Minor): 4 packages
  High Risk (Major):   2 packages
  Critical Risk:       1 package

RECOMMENDED UPDATE ORDER
------------------------

Phase 1 - Safe Updates (Patch versions):
  ✓ express: 4.18.2 → 4.18.3 (security fix)
  ✓ lodash: 4.17.20 → 4.17.21 (security fix)
  ✓ cors: 2.8.5 → 2.8.6 (bug fixes)
  ✓ dotenv: 16.0.3 → 16.4.1 (bug fixes)
  ✓ helmet: 7.0.0 → 7.1.0 (security improvements)

  Risk: LOW
  Time: 5-10 minutes
  Action: Update all, run tests

Phase 2 - Feature Updates (Minor versions):
  ⚠ react: 18.2.0 → 18.3.0 (new features, React Compiler support)
  ⚠ vite: 4.5.0 → 4.6.0 (performance improvements)
  ⚠ typescript: 5.2.2 → 5.3.3 (new language features)
  ⚠ @tanstack/react-query: 5.0.0 → 5.8.0 (new hooks)

  Risk: MEDIUM
  Time: 30-60 minutes
  Action: Update individually, check changelog, test each

Phase 3 - Breaking Changes (Major versions):
  ⚠️ eslint: 8.54.0 → 9.0.0 (BREAKING: new config format)
  ⚠️ prisma: 5.6.0 → 6.0.0 (BREAKING: schema changes)

  Risk: HIGH
  Time: 2-4 hours
  Action: Review migration guide, update code, extensive testing

Skipped (Too Risky for Now):
  🚫 node: v18 → v20 (recommend dedicated migration)
     Recommendation: Schedule separate session for Node upgrade
```

### Step 3: Fetch Breaking Changes

```
Claude: Let me fetch changelog information for the major updates...

[Searches for ESLint 9.0 and Prisma 6.0 changelogs]

eslint (8.54.0 → 9.0.0):
--------------------------
Breaking Changes:
  • New flat config format (eslint.config.js instead of .eslintrc)
  • Removed deprecated rules
  • Changed default parser options
  • No longer supports Node.js < 18

Migration Steps:
  1. Create new eslint.config.js
  2. Migrate rules from .eslintrc.json
  3. Update package.json scripts
  4. Test linting on codebase

Estimated Effort: 1-2 hours
Migration Guide: https://eslint.org/docs/latest/use/migrate-to-9.0.0

prisma (5.6.0 → 6.0.0):
-----------------------
Breaking Changes:
  • TypedSQL feature now enabled by default
  • Changed transaction API
  • Updated relation filter behavior
  • Some preview features graduated to GA

Migration Steps:
  1. Update schema syntax
  2. Regenerate Prisma Client
  3. Update transaction code
  4. Test database queries

Estimated Effort: 2-3 hours
Migration Guide: https://github.com/prisma/prisma/releases/tag/6.0.0
```

### Step 4: Choose Update Strategy

```
Claude: How would you like to proceed?

1. Conservative (Recommended for Production):
   - Update only patch versions now (5 packages)
   - Schedule minor/major updates separately
   - Minimize risk of breakage
   - Time: 10 minutes

2. Balanced (Good for Active Development):
   - Update patch and minor versions (9 packages)
   - Review major updates individually later
   - Moderate risk, good improvements
   - Time: 45-60 minutes

3. Aggressive (Only if Time Permits):
   - Update everything including major versions (11 packages)
   - Requires significant testing time
   - Maximum improvements, highest risk
   - Time: 4-5 hours

4. Custom:
   - Let me choose which packages to update

Which strategy do you prefer? (1/2/3/4):
```

```
You: 2 (balanced approach)
```

### Step 5: Execute Patch Updates

```
Claude: Great! I'll start with the balanced approach - updating patch and minor versions.

===========================================
Phase 1: Patch Updates (5 packages)
===========================================

Creating backup branch...
[Executing: git checkout -b deps/patch-updates]
✅ Branch created

Updating dependencies...
[Executing: bun update express lodash cors dotenv helmet]

  + express@4.18.3 (was 4.18.2)
  + lodash@4.17.21 (was 4.17.20)
  + cors@2.8.6 (was 2.8.5)
  + dotenv@16.4.1 (was 16.0.3)
  + helmet@7.1.0 (was 7.0.0)

✅ Dependencies updated

Building with updated dependencies...
[Executing: build grocery-planner]
✅ Build successful (12.3s)

Running tests...
[Executing: test grocery-planner]
✅ All 47 tests passing

Phase 1 Complete! ✅

Updated packages:
  • express: 4.18.2 → 4.18.3 ✓
  • lodash: 4.17.20 → 4.17.21 ✓
  • cors: 2.8.5 → 2.8.6 ✓
  • dotenv: 16.0.3 → 16.4.1 ✓
  • helmet: 7.0.0 → 7.1.0 ✓

Build: ✅ Successful
Tests: ✅ All passing

Ready to proceed to Phase 2 (minor updates)? (Y/n):
```

```
You: y
```

### Step 6: Execute Minor Updates

```
Claude:
===========================================
Phase 2: Minor Updates (4 packages)
===========================================

I'll update these one at a time to catch any issues early.

Update 1/4: react (18.2.0 → 18.3.0)
-----------------------------------

[Executing: bun update react react-dom]

  + react@18.3.0 (was 18.2.0)
  + react-dom@18.3.0 (was 18.2.0)

Building...
✅ Build successful

Running tests...
✅ All tests passing

What's new in React 18.3:
  • React Compiler support (opt-in)
  • Better DevTools integration
  • Performance improvements

Update 2/4: vite (4.5.0 → 4.6.0)
--------------------------------

[Executing: bun update vite]

  + vite@4.6.0 (was 4.5.0)

Building...
✅ Build successful (10% faster!)

What's new in Vite 4.6:
  • Faster cold starts
  • Better HMR performance
  • CSS optimization improvements

Update 3/4: typescript (5.2.2 → 5.3.3)
--------------------------------------

[Executing: bun update typescript]

  + typescript@5.3.3 (was 5.2.2)

Rebuilding with new TypeScript version...
⚠️  Found 2 new type errors!

Error 1: lib/utils.ts:45
  Type 'unknown' is not assignable to type 'string'

This is due to stricter type checking in TypeScript 5.3.

Fix:
  Old: const result = getValue();
  New: const result = getValue() as string;

Or better (with type guard):
  const result = getValue();
  if (typeof result === 'string') {
    // use result
  }

Would you like me to show you all occurrences? (Y/n):
```

```
You: y
```

```
Claude: Found 2 type errors, both easily fixable:

1. lib/utils.ts:45 - getValue() return type
2. lib/api.ts:89 - JSON.parse() result type

These are due to TypeScript 5.3's improved type inference.

Recommended fixes:

lib/utils.ts:
  export function parseConfig(json: string): Config {
    const data = JSON.parse(json) as unknown;  // Add type assertion
    return data as Config;  // Existing code
  }

lib/api.ts:
  const response = await fetch(url);
  const data = await response.json() as ApiResponse;  // Add type assertion

Would you like me to create a patch with these fixes? (Y/n):
```

```
You: y
```

```
Claude: Applying TypeScript fixes...

[Updates both files with proper type assertions]

✅ Fixed lib/utils.ts
✅ Fixed lib/api.ts

Rebuilding...
✅ Build successful

Running tests...
✅ All 47 tests passing

TypeScript update complete!

Update 4/4: @tanstack/react-query (5.0.0 → 5.8.0)
--------------------------------------------------

[Executing: bun update @tanstack/react-query]

  + @tanstack/react-query@5.8.0 (was 5.0.0)

Building...
✅ Build successful

Running tests...
✅ All tests passing

What's new:
  • New useQueries hook improvements
  • Better DevTools
  • Experimental features added

===========================================
Phase 2 Complete! ✅
===========================================

All minor updates applied successfully:
  • react: 18.2.0 → 18.3.0 ✓
  • vite: 4.5.0 → 4.6.0 ✓
  • typescript: 5.2.2 → 5.3.3 ✓ (with fixes)
  • @tanstack/react-query: 5.0.0 → 5.8.0 ✓

Build: ✅ Successful
Tests: ✅ All 47 passing
Build time: 10% faster than before

Total updates applied: 9 packages
```

### Step 7: Create Commit

```
Claude: All updates successful! Let me create a proper commit message.

chore(deps): update dependencies to latest versions

Patch updates (security & bug fixes):
- express: 4.18.2 → 4.18.3 (security fix)
- lodash: 4.17.20 → 4.17.21 (security fix)
- cors: 2.8.5 → 2.8.6
- dotenv: 16.0.3 → 16.4.1
- helmet: 7.0.0 → 7.1.0

Minor updates (new features):
- react: 18.2.0 → 18.3.0 (React Compiler support)
- vite: 4.5.0 → 4.6.0 (performance improvements)
- typescript: 5.2.2 → 5.3.3 (stricter type checking)
  * Fixed type assertions in utils.ts and api.ts
- @tanstack/react-query: 5.0.0 → 5.8.0

All tests passing ✓
Build performance improved by ~10%

[Executing: git add . && git commit -m "..."]
✅ Changes committed
```

### Step 8: Summary and Next Steps

```
Claude:
===========================================
Dependency Update Complete! ✅
===========================================

Updates Applied:
  Patch versions:  5 packages (security fixes)
  Minor versions:  4 packages (new features)
  Total updated:   9 packages

Build Status:    ✅ Successful (10% faster)
Test Status:     ✅ All passing (47/47)
Time Taken:      42 minutes

Changes Committed:
  Branch: deps/patch-updates
  Commit: chore(deps): update dependencies

Skipped Updates:
  • eslint (8.54.0 → 9.0.0)
    Reason: Breaking changes - requires config migration
    Effort: 1-2 hours

  • prisma (5.6.0 → 6.0.0)
    Reason: Breaking changes - requires schema updates
    Effort: 2-3 hours

  • node (v18 → v20)
    Reason: Major runtime update - needs dedicated session

Recommendations:
  ✓ Ready to merge to main
  ✓ Schedule ESLint 9 migration (1-2 hours)
  ✓ Schedule Prisma 6 migration (2-3 hours)
  ✓ Plan Node 20 upgrade (requires testing)
  ✓ Set reminder to check dependencies in 1 month

Next Steps:
  1. Push branch: git push -u origin deps/patch-updates
  2. Create PR for code review
  3. Merge after approval
  4. Monitor for any issues
  5. Schedule major version updates

Great work keeping dependencies up to date! 🎉
```

## Key Takeaways

### What the Skill Did

1. **Analyzed dependencies** - Ran outdated check
2. **Categorized by risk** - Separated patch/minor/major updates
3. **Fetched changelogs** - Researched breaking changes for major versions
4. **Provided options** - Let user choose update strategy
5. **Executed incrementally** - Updated in phases with testing
6. **Fixed issues** - Addressed TypeScript errors from stricter checking
7. **Committed properly** - Created detailed commit message
8. **Gave recommendations** - Advised on skipped updates

### Benefits

- **Safe updates**: Incremental approach caught issues early
- **Time efficient**: Completed safe updates quickly, deferred risky ones
- **Well-informed**: Understood what was changing and why
- **Tested thoroughly**: Build and tests after each phase
- **Properly documented**: Clear commit message for future reference
- **Risk-aware**: Major breaking changes scheduled separately

### What Was Updated

**Patch versions (safe):**
- Security fixes in express and lodash
- Bug fixes in cors, dotenv, helmet

**Minor versions (tested):**
- React 18.3 with new features
- Vite 4.6 with performance improvements
- TypeScript 5.3 with stricter checking (required fixes)
- React Query 5.8 with new hooks

**Deferred (breaking changes):**
- ESLint 9 (config format change)
- Prisma 6 (schema changes)
- Node 20 (major runtime update)

## Related Skills

- **build-fixer**: If build fails after updates
- **project-workflow**: To commit and create PR
- **project-health-check**: To verify overall project health after updates
