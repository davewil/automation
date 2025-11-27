#compdef projects open

# Zsh completion for project manager

_get_projects() {
    local config_file="${OPEN_PROJECT_CONFIG:-$HOME/.config/project-manager/projects.json}"
    if [ -f "$config_file" ] && command -v jq &> /dev/null; then
        jq -r 'keys[]' "$config_file" 2>/dev/null
    fi
}

_projects() {
    local -a projects
    projects=(${(f)"$(_get_projects)"})

    _arguments \
        '1: :->command' \
        '2: :->project'

    case $state in
        command)
            local -a commands
            commands=(
                '--help:Show help message'
                '--edit:Edit projects configuration'
                '--clone:Clone a project from GitHub'
                '--add:Add current directory as a project'
                '-h:Show help message'
                '-e:Edit projects configuration'
                '-c:Clone a project from GitHub'
                '-a:Add current directory as a project'
            )
            _describe 'command' commands
            ;;
        project)
            if [[ ${words[2]} == "--clone" || ${words[2]} == "-c" ]]; then
                _describe 'project' projects
            fi
            ;;
    esac
}

_open() {
    local -a projects
    projects=(${(f)"$(_get_projects)"})

    local -a options
    options=(
        '--help:Show help message'
        '--list:List all projects'
        '-h:Show help message'
        '-l:List all projects'
    )

    _arguments \
        '1: :->target'

    case $state in
        target)
            _describe 'project' projects
            _describe 'option' options
            ;;
    esac
}

_project_command() {
    local -a projects
    projects=(${(f)"$(_get_projects)"})

    _describe 'project' projects
}

_gotoproject() {
    local -a projects
    projects=(${(f)"$(_get_projects)"})

    _describe 'project' projects
}

compdef _projects projects
compdef _open open
compdef _project_command build
compdef _project_command test
compdef _project_command run
compdef _project_command watch
compdef _project_command push
compdef _project_command outdated
compdef _gotoproject gotoproject
