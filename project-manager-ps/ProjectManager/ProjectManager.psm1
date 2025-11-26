# ProjectManager PowerShell Module
# A comprehensive tool for managing, building, testing, and deploying projects

$script:ConfigPath = Join-Path $env:USERPROFILE ".config\project-manager\projects.json"
$script:TypesPath = Join-Path $PSScriptRoot "project-types.json"

# Ensure config directory exists
function Initialize-ProjectManagerConfig {
    $configDir = Split-Path $script:ConfigPath -Parent
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    # Copy default config if it doesn't exist
    if (-not (Test-Path $script:ConfigPath)) {
        $defaultConfig = Join-Path $PSScriptRoot "projects.json"
        if (Test-Path $defaultConfig) {
            Copy-Item $defaultConfig $script:ConfigPath
        }
    }
}

# Helper function to read JSON config
function Get-ProjectConfig {
    param([string]$ProjectName)

    if (-not (Test-Path $script:ConfigPath)) {
        Write-Error "Configuration file not found at $script:ConfigPath"
        return $null
    }

    $config = Get-Content $script:ConfigPath -Raw | ConvertFrom-Json

    if ($ProjectName) {
        return $config.$ProjectName
    }

    return $config
}

# Helper function to get project type commands
function Get-ProjectTypeCommand {
    param(
        [string]$ProjectType,
        [string]$CommandType
    )

    if (-not (Test-Path $script:TypesPath)) {
        Write-Error "Project types file not found at $script:TypesPath"
        return $null
    }

    $types = Get-Content $script:TypesPath -Raw | ConvertFrom-Json

    if ($types.$ProjectType.$CommandType) {
        return $types.$ProjectType.$CommandType
    }

    return $null
}

# Helper function to detect project type
function Get-DetectedProjectType {
    if (Test-Path "mix.exs") {
        return "elixir"
    }
    elseif ((Get-ChildItem "*.csproj" -ErrorAction SilentlyContinue) -or
            (Get-ChildItem "*.fsproj" -ErrorAction SilentlyContinue) -or
            (Get-ChildItem "*.sln" -ErrorAction SilentlyContinue)) {
        return "dotnet"
    }
    elseif (Test-Path "package.json") {
        return "node"
    }
    elseif (Test-Path "go.mod") {
        return "go"
    }
    elseif ((Test-Path "requirements.txt") -or (Test-Path "setup.py") -or (Test-Path "pyproject.toml")) {
        return "python"
    }
    elseif (Test-Path "Cargo.toml") {
        return "rust"
    }

    return $null
}

# Function to list all projects
function Get-ProjectList {
    [CmdletBinding()]
    param()

    $config = Get-ProjectConfig
    if (-not $config) { return }

    Write-Host "Available projects:"
    $config.PSObject.Properties | ForEach-Object {
        $name = $_.Name
        $desc = $_.Value.description
        Write-Host "  $name - $desc"
    }
}

# Function to add current directory as a project
function Add-Project {
    [CmdletBinding()]
    param()

    # Check if we're in a git repository
    if (-not (Test-Path ".git")) {
        Write-Error "Not in a git repository. Please run this command from the root of a git repository."
        return
    }

    $currentDir = Get-Location
    $projectName = Split-Path $currentDir -Leaf

    # Get git remote URL
    $remoteUrl = git remote get-url origin 2>$null
    if (-not $remoteUrl) {
        Write-Error "No git remote 'origin' found. Please add a remote with: git remote add origin <url>"
        return
    }

    # Check if project already exists
    $config = Get-ProjectConfig
    if ($config.$projectName) {
        Write-Error "Project '$projectName' already exists in configuration"
        Write-Host "`nCurrent configuration:"
        $config.$projectName | ConvertTo-Json -Depth 10
        return
    }

    # Detect project type
    $projectType = Get-DetectedProjectType

    if ($projectType) {
        Write-Host "Detected project type: $projectType"
    }
    else {
        Write-Host "Warning: Could not automatically detect project type"
        Write-Host "You can manually set it later by editing the configuration"
        Write-Host ""
        Write-Host "Supported types: elixir, dotnet, node, go, python, rust"
    }

    # Get default editor
    $editor = if ($env:EDITOR) { $env:EDITOR } else { "nvim" }

    # Prompt for description
    Write-Host ""
    $description = Read-Host "Enter project description (optional)"

    # Build new project entry
    $newEntry = @{
        github = $remoteUrl
        local_path = $currentDir.Path
        editor = $editor
        auto_pull = $true
        description = $description
    }

    if ($projectType) {
        $newEntry.project_type = $projectType
    }

    # Add to config
    $config | Add-Member -MemberType NoteProperty -Name $projectName -Value ([PSCustomObject]$newEntry)

    # Save config
    $config | ConvertTo-Json -Depth 10 | Set-Content $script:ConfigPath

    Write-Host ""
    Write-Host "✓ Successfully added project '$projectName' to configuration" -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuration:"
    $config.$projectName | ConvertTo-Json -Depth 10
    Write-Host ""
    Write-Host "You can now use: Open-Project $projectName"
}

# Function to clone a project
function New-ProjectClone {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProjectName
    )

    $project = Get-ProjectConfig -ProjectName $ProjectName
    if (-not $project) {
        Write-Error "Project '$ProjectName' not found in configuration"
        Get-ProjectList
        return
    }

    $localPath = $project.local_path
    $githubUrl = $project.github

    if (Test-Path $localPath) {
        Write-Error "Project already exists at $localPath"
        return
    }

    Write-Host "Cloning $ProjectName from $githubUrl..."
    $parentDir = Split-Path $localPath -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # Try gh CLI first, then fall back to git
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        # Extract repo path from SSH URL
        $repoPath = $githubUrl -replace 'git@github\.com:', '' -replace '\.git$', ''
        gh repo clone $repoPath $localPath
    }
    else {
        git clone $githubUrl $localPath
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Successfully cloned $ProjectName to $localPath" -ForegroundColor Green
        Write-Host "You can now open it with: Open-Project $ProjectName"
    }
}

# Function to open a project
function Open-Project {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName
    )

    $project = Get-ProjectConfig -ProjectName $ProjectName
    if (-not $project) {
        Write-Error "Project '$ProjectName' not found in configuration"
        Get-ProjectList
        return
    }

    $localPath = $project.local_path
    $editor = $project.editor
    $autoPull = $project.auto_pull

    if (-not (Test-Path $localPath)) {
        Write-Error "Project directory not found at $localPath"
        Write-Host "Please clone the repository first using: New-ProjectClone $ProjectName"
        return
    }

    Write-Host "Opening project: $ProjectName"
    Set-Location $localPath
    Write-Host "Changed to: $(Get-Location)"

    # Pull latest changes if auto_pull is enabled
    if ($autoPull -and (Test-Path ".git")) {
        Write-Host ""
        Write-Host "==> Step 1/4: Pulling latest changes..." -ForegroundColor Cyan
        git pull
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to pull latest changes"
        }
    }

    # Get project type for workflow steps
    if ($project.project_type) {
        # Step 2: Check dependencies
        Write-Host ""
        Write-Host "==> Step 2/4: Checking for dependency updates..." -ForegroundColor Cyan

        switch ($project.project_type) {
            'elixir' { if (Test-Path "mix.exs") { mix hex.outdated } }
            'dotnet' { if (Get-Command dotnet -ErrorAction SilentlyContinue) { dotnet list package --outdated } }
            'node' { if (Test-Path "package.json") { bun outdated } }
            'go' {
                if (Test-Path "go.mod") {
                    $outdated = go list -u -m all 2>$null | Select-String '\['
                    if ($outdated) { $outdated } else { Write-Host "All dependencies up to date" }
                }
            }
            'python' { if (Test-Path "requirements.txt") { pip list --outdated } }
            'rust' {
                if (Test-Path "Cargo.toml") {
                    if (Get-Command cargo-outdated -ErrorAction SilentlyContinue) {
                        cargo outdated
                    } else {
                        Write-Host "Note: Install cargo-outdated for this feature (cargo install cargo-outdated)"
                    }
                }
            }
        }

        # Step 3: Build
        Write-Host ""
        Write-Host "==> Step 3/4: Running build..." -ForegroundColor Cyan
        $buildCmd = Get-ProjectTypeCommand -ProjectType $project.project_type -CommandType 'build'
        if ($buildCmd) {
            Invoke-Expression $buildCmd
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Build failed"
            }
        }
        else {
            Write-Host "No build command configured, skipping..."
        }

        # Step 4: Test
        Write-Host ""
        Write-Host "==> Step 4/4: Running tests..." -ForegroundColor Cyan
        $testCmd = Get-ProjectTypeCommand -ProjectType $project.project_type -CommandType 'test'
        if ($testCmd) {
            Invoke-Expression $testCmd
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Tests failed"
            }
        }
        else {
            Write-Host "No test command configured, skipping..."
        }

        Write-Host ""
        Write-Host "✓ Project ready!" -ForegroundColor Green
    }

    # Open with specified editor
    Write-Host ""
    if ($editor) {
        Write-Host "Opening with $editor..."
        & $editor .
    }
}

# Function to navigate to project directory
function Set-ProjectLocation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName
    )

    $project = Get-ProjectConfig -ProjectName $ProjectName
    if (-not $project) {
        Write-Error "Project '$ProjectName' not found in configuration"
        Get-ProjectList
        return
    }

    $localPath = $project.local_path

    if (-not (Test-Path $localPath)) {
        Write-Error "Project directory not found at $localPath"
        Write-Host "Clone the project first with: New-ProjectClone $ProjectName"
        return
    }

    Set-Location $localPath
    Write-Host "Switched to: $(Get-Location)" -ForegroundColor Green
}

# Function to edit project configuration
function Edit-ProjectConfig {
    [CmdletBinding()]
    param()

    $editor = if ($env:EDITOR) { $env:EDITOR } else { "notepad" }
    & $editor $script:ConfigPath
}

# Function to run a project command
function Invoke-ProjectCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,

        [Parameter(Mandatory=$true)]
        [ValidateSet('build', 'test', 'run', 'watch')]
        [string]$CommandType
    )

    $project = Get-ProjectConfig -ProjectName $ProjectName
    if (-not $project) {
        Write-Error "Project '$ProjectName' not found in configuration"
        return
    }

    $localPath = $project.local_path

    if (-not (Test-Path $localPath)) {
        Write-Error "Project directory not found at $localPath"
        Write-Host "Clone the project first with: New-ProjectClone $ProjectName"
        return
    }

    # Check for custom command first
    $command = $project.commands.$CommandType

    # Fall back to project type command
    if (-not $command -and $project.project_type) {
        $command = Get-ProjectTypeCommand -ProjectType $project.project_type -CommandType $CommandType
    }

    if (-not $command) {
        Write-Error "No $CommandType command defined for project '$ProjectName'"
        if ($project.project_type) {
            Write-Host "Project type: $($project.project_type)"
        }
        else {
            Write-Host "No project_type set. Add 'project_type' field to your project configuration."
        }
        return
    }

    Write-Host "Running $CommandType for $ProjectName..."
    Write-Host "Command: $command"
    Write-Host "Directory: $localPath"
    Write-Host ""

    Push-Location $localPath
    try {
        Invoke-Expression $command
    }
    finally {
        Pop-Location
    }
}

# Wrapper functions for specific commands
function Invoke-ProjectBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName
    )
    Invoke-ProjectCommand -ProjectName $ProjectName -CommandType 'build'
}

function Invoke-ProjectTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName
    )
    Invoke-ProjectCommand -ProjectName $ProjectName -CommandType 'test'
}

function Invoke-ProjectRun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName
    )
    Invoke-ProjectCommand -ProjectName $ProjectName -CommandType 'run'
}

function Invoke-ProjectWatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName
    )
    Invoke-ProjectCommand -ProjectName $ProjectName -CommandType 'watch'
}

# Function to check for outdated dependencies
function Test-ProjectOutdated {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName
    )

    $project = Get-ProjectConfig -ProjectName $ProjectName
    if (-not $project) {
        Write-Error "Project '$ProjectName' not found in configuration"
        return
    }

    $localPath = $project.local_path

    if (-not (Test-Path $localPath)) {
        Write-Error "Project directory not found at $localPath"
        return
    }

    if (-not $project.project_type) {
        Write-Error "No project type configured for '$ProjectName'"
        Write-Host "Add 'project_type' field to your project configuration."
        return
    }

    Write-Host "Checking for outdated dependencies in $ProjectName..."
    Write-Host ""

    Push-Location $localPath
    try {
        switch ($project.project_type) {
            'elixir' {
                if (Test-Path "mix.exs") {
                    mix hex.outdated
                } else {
                    Write-Host "No mix.exs file found"
                }
            }
            'dotnet' {
                if (Get-Command dotnet -ErrorAction SilentlyContinue) {
                    dotnet list package --outdated
                } else {
                    Write-Host "dotnet command not found"
                }
            }
            'node' {
                if (Test-Path "package.json") {
                    bun outdated
                } else {
                    Write-Host "No package.json file found"
                }
            }
            'go' {
                if (Test-Path "go.mod") {
                    go list -u -m all 2>$null | Select-String '\['
                    if (-not $?) {
                        Write-Host "All dependencies up to date"
                    }
                } else {
                    Write-Host "No go.mod file found"
                }
            }
            'python' {
                if (Test-Path "requirements.txt") {
                    pip list --outdated
                } else {
                    Write-Host "No requirements.txt file found"
                }
            }
            'rust' {
                if (Test-Path "Cargo.toml") {
                    if (Get-Command cargo-outdated -ErrorAction SilentlyContinue) {
                        cargo outdated
                    } else {
                        Write-Host "cargo-outdated not installed"
                        Write-Host "Install with: cargo install cargo-outdated"
                    }
                } else {
                    Write-Host "No Cargo.toml file found"
                }
            }
            default {
                Write-Error "Unknown project type: $($project.project_type)"
            }
        }
    }
    finally {
        Pop-Location
    }
}

# Function to push changes (pull, build, test, commit, push)
function Publish-ProjectChanges {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProjectName,

        [Parameter(Mandatory=$true, Position=1)]
        [string]$CommitMessage,

        [Parameter()]
        [switch]$AutoUpdate
    )

    $project = Get-ProjectConfig -ProjectName $ProjectName
    if (-not $project) {
        Write-Error "Project '$ProjectName' not found in configuration"
        return
    }

    $localPath = $project.local_path

    if (-not (Test-Path $localPath)) {
        Write-Error "Project directory not found at $localPath"
        return
    }

    Push-Location $localPath
    try {
        # Check if it's a git repository
        if (-not (Test-Path ".git")) {
            Write-Error "Not a git repository"
            return
        }

        Write-Host "==> Step 1/6: Pulling latest changes..." -ForegroundColor Cyan
        git pull
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to pull changes. Please resolve conflicts manually."
            return
        }

        Write-Host ""
        Write-Host "==> Step 2/6: Checking for dependency updates..." -ForegroundColor Cyan

        if ($project.project_type) {
            # Run outdated check based on project type
            switch ($project.project_type) {
                'elixir' { if (Test-Path "mix.exs") { mix hex.outdated } }
                'dotnet' { if (Get-Command dotnet -ErrorAction SilentlyContinue) { dotnet list package --outdated } }
                'node' { if (Test-Path "package.json") { bun outdated } }
                'go' {
                    if (Test-Path "go.mod") {
                        $outdated = go list -u -m all 2>$null | Select-String '\['
                        if ($outdated) { $outdated } else { Write-Host "All dependencies up to date" }
                    }
                }
                'python' { if (Test-Path "requirements.txt") { pip list --outdated } }
                'rust' {
                    if (Test-Path "Cargo.toml") {
                        if (Get-Command cargo-outdated -ErrorAction SilentlyContinue) {
                            cargo outdated
                        } else {
                            Write-Host "Note: Install cargo-outdated for this feature (cargo install cargo-outdated)"
                        }
                    }
                }
            }

            Write-Host ""

            # Check if auto-update or prompt
            $shouldUpdate = $false
            if ($AutoUpdate) {
                $shouldUpdate = $true
                Write-Host "Auto-updating dependencies..."
            }
            else {
                $response = Read-Host "Would you like to update dependencies? (y/N)"
                $shouldUpdate = $response -eq 'y' -or $response -eq 'Y'
            }

            if ($shouldUpdate) {
                $depsCmd = Get-ProjectTypeCommand -ProjectType $project.project_type -CommandType 'deps'
                if ($depsCmd) {
                    Write-Host "Updating dependencies..."
                    Invoke-Expression $depsCmd
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "Dependency update failed"
                    }
                }
                else {
                    Write-Host "No deps command configured for this project type"
                }
            }
            else {
                Write-Host "Skipping dependency updates..."
            }
        }
        else {
            Write-Host "No project type configured, skipping dependency check..."
        }

        Write-Host ""
        Write-Host "==> Step 3/6: Running build..." -ForegroundColor Cyan
        $buildCmd = Get-ProjectTypeCommand -ProjectType $project.project_type -CommandType 'build'
        if ($buildCmd) {
            Invoke-Expression $buildCmd
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Build failed"
                return
            }
        }
        else {
            Write-Host "No build command configured, skipping..."
        }

        Write-Host ""
        Write-Host "==> Step 4/6: Running tests..." -ForegroundColor Cyan
        $testCmd = Get-ProjectTypeCommand -ProjectType $project.project_type -CommandType 'test'
        if ($testCmd) {
            Invoke-Expression $testCmd
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Tests failed"
                return
            }
        }
        else {
            Write-Host "No test command configured, skipping..."
        }

        Write-Host ""
        Write-Host "==> Step 5/6: Committing changes..." -ForegroundColor Cyan
        git add .

        # Check if there are changes to commit
        $status = git diff --staged --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "No changes to commit"
        }
        else {
            git commit -m $CommitMessage
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Commit failed"
                return
            }
        }

        Write-Host ""
        Write-Host "==> Step 6/6: Pushing to remote..." -ForegroundColor Cyan
        git push
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to push changes"
            return
        }

        Write-Host ""
        Write-Host "✓ Successfully pushed $ProjectName!" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

# Set up aliases
Set-Alias -Name projects -Value Get-ProjectList
Set-Alias -Name goto -Value Set-ProjectLocation
Set-Alias -Name build -Value Invoke-ProjectBuild
Set-Alias -Name test -Value Invoke-ProjectTest
Set-Alias -Name run -Value Invoke-ProjectRun
Set-Alias -Name watch -Value Invoke-ProjectWatch
Set-Alias -Name outdated -Value Test-ProjectOutdated
Set-Alias -Name push -Value Publish-ProjectChanges

# Initialize config on module load
Initialize-ProjectManagerConfig

# Export module members
Export-ModuleMember -Function * -Alias *
