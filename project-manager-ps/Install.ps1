# Install script for ProjectManager PowerShell module

param(
    [switch]$CurrentUser,
    [switch]$AllUsers
)

$ErrorActionPreference = 'Stop'

Write-Host "ProjectManager Installation" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

# Determine installation scope
if ($AllUsers) {
    $scope = 'AllUsers'
    $modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules"
}
else {
    $scope = 'CurrentUser'
    $modulePath = "$HOME\Documents\WindowsPowerShell\Modules"
}

Write-Host "Installing for: $scope"
Write-Host "Module path: $modulePath"
Write-Host ""

# Create module directory if it doesn't exist
$targetPath = Join-Path $modulePath "ProjectManager"
if (-not (Test-Path $targetPath)) {
    Write-Host "Creating module directory..."
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
}

# Copy module files
Write-Host "Installing module files..."
$sourcePath = Join-Path $PSScriptRoot "ProjectManager"
Copy-Item -Path "$sourcePath\*" -Destination $targetPath -Recurse -Force

# Create config directory
$configDir = Join-Path $env:USERPROFILE ".config\project-manager"
if (-not (Test-Path $configDir)) {
    Write-Host "Creating config directory at $configDir..."
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Copy default config if it doesn't exist
$configFile = Join-Path $configDir "projects.json"
if (-not (Test-Path $configFile)) {
    Write-Host "Installing default configuration..."
    Copy-Item -Path "$sourcePath\projects.json" -Destination $configFile
    Write-Host "Please edit $configFile to add your projects"
}
else {
    Write-Host "Configuration already exists at $configFile (not overwriting)"
}

# Copy project types file
Write-Host "Installing project types..."
Copy-Item -Path "$sourcePath\project-types.json" -Destination $configDir -Force

# Check if module is imported in profile
$profilePath = $PROFILE.CurrentUserAllHosts
$importStatement = "Import-Module ProjectManager"

if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
    if ($profileContent -notmatch [regex]::Escape($importStatement)) {
        Write-Host ""
        Write-Host "Adding module import to PowerShell profile..."
        Add-Content -Path $profilePath -Value "`n# Project Manager Module"
        Add-Content -Path $profilePath -Value $importStatement
    }
    else {
        Write-Host ""
        Write-Host "Module import already exists in profile"
    }
}
else {
    Write-Host ""
    Write-Host "Creating PowerShell profile and adding module import..."
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    "# Project Manager Module" | Set-Content $profilePath
    Add-Content -Path $profilePath -Value $importStatement
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit your projects: $configFile"
Write-Host "  2. Reload your PowerShell session or run: Import-Module ProjectManager"
Write-Host "  3. Try it out: Get-ProjectList"
Write-Host ""
Write-Host "Usage:"
Write-Host "  Open-Project <name>      - Open a project"
Write-Host "  Get-ProjectList          - List all projects (alias: projects)"
Write-Host "  New-ProjectClone <name>  - Clone a project from GitHub"
Write-Host "  Add-Project              - Add current directory as a project"
Write-Host "  Set-ProjectLocation <name> - Navigate to project (alias: goto)"
Write-Host "  Edit-ProjectConfig       - Edit projects configuration"
Write-Host ""
Write-Host "  Invoke-ProjectBuild <name>   - Build a project (alias: build)"
Write-Host "  Invoke-ProjectTest <name>    - Test a project (alias: test)"
Write-Host "  Invoke-ProjectRun <name>     - Run a project (alias: run)"
Write-Host "  Invoke-ProjectWatch <name>   - Watch a project (alias: watch)"
Write-Host "  Test-ProjectOutdated <name>  - Check outdated deps (alias: outdated)"
Write-Host "  Publish-ProjectChanges <name> \"message\" - Push changes (alias: push)"
Write-Host ""
