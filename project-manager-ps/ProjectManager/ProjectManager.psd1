@{
    RootModule = 'ProjectManager.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'Project Manager'
    CompanyName = 'Unknown'
    Copyright = '(c) 2025. All rights reserved.'
    Description = 'A comprehensive PowerShell module for managing, building, testing, and deploying projects across different languages and frameworks.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Open-Project',
        'Get-ProjectList',
        'Add-Project',
        'New-ProjectClone',
        'Edit-ProjectConfig',
        'Set-ProjectLocation',
        'Invoke-ProjectBuild',
        'Invoke-ProjectTest',
        'Invoke-ProjectRun',
        'Invoke-ProjectWatch',
        'Test-ProjectOutdated',
        'Publish-ProjectChanges'
    )

    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @(
        'projects',
        'goto',
        'build',
        'test',
        'run',
        'watch',
        'outdated',
        'push'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('ProjectManagement', 'DevOps', 'Build', 'Git')
            ProjectUri = 'https://github.com/davewil/automation'
        }
    }
}
