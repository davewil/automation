#!/bin/bash

# Bash completion for project manager

_projects_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Options for projects command
    local opts="--help --edit --clone --add -h -e -c -a"

    # Get project names from config
    local config_file="${OPEN_PROJECT_CONFIG:-$HOME/.config/project-manager/projects.json}"
    local projects=""

    if [ -f "$config_file" ] && command -v jq &> /dev/null; then
        projects=$(jq -r 'keys[]' "$config_file" 2>/dev/null)
    fi

    case "${prev}" in
        --clone|-c)
            # Autocomplete project names after --clone
            COMPREPLY=( $(compgen -W "${projects}" -- ${cur}) )
            return 0
            ;;
        projects)
            # First argument: show options
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
        *)
            ;;
    esac

    # If no matches yet, show nothing
    COMPREPLY=()
}

_open_completion() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Get project names from config
    local config_file="${OPEN_PROJECT_CONFIG:-$HOME/.config/project-manager/projects.json}"
    local projects=""

    if [ -f "$config_file" ] && command -v jq &> /dev/null; then
        projects=$(jq -r 'keys[]' "$config_file" 2>/dev/null)
    fi

    case "${prev}" in
        open)
            # Autocomplete project names for open command
            COMPREPLY=( $(compgen -W "${projects} --help --list -h -l" -- ${cur}) )
            return 0
            ;;
        *)
            ;;
    esac

    COMPREPLY=()
}

_project_command_completion() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Get project names from config
    local config_file="${OPEN_PROJECT_CONFIG:-$HOME/.config/project-manager/projects.json}"
    local projects=""

    if [ -f "$config_file" ] && command -v jq &> /dev/null; then
        projects=$(jq -r 'keys[]' "$config_file" 2>/dev/null)
    fi

    case "${prev}" in
        build|test|run|watch)
            # Autocomplete project names
            COMPREPLY=( $(compgen -W "${projects}" -- ${cur}) )
            return 0
            ;;
        push)
            # For push, first arg is project name
            if [ ${#COMP_WORDS[@]} -eq 2 ]; then
                COMPREPLY=( $(compgen -W "${projects}" -- ${cur}) )
            fi
            return 0
            ;;
        *)
            ;;
    esac

    COMPREPLY=()
}

_goto_completion() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Get project names from config
    local config_file="${OPEN_PROJECT_CONFIG:-$HOME/.config/project-manager/projects.json}"
    local projects=""

    if [ -f "$config_file" ] && command -v jq &> /dev/null; then
        projects=$(jq -r 'keys[]' "$config_file" 2>/dev/null)
    fi

    case "${prev}" in
        goto)
            # Autocomplete project names for goto command
            COMPREPLY=( $(compgen -W "${projects}" -- ${cur}) )
            return 0
            ;;
        *)
            ;;
    esac

    COMPREPLY=()
}

# Register completions
complete -F _projects_completion projects
complete -F _open_completion open
complete -F _project_command_completion build
complete -F _project_command_completion test
complete -F _project_command_completion run
complete -F _project_command_completion watch
complete -F _project_command_completion push
complete -F _project_command_completion outdated
complete -F _goto_completion goto
