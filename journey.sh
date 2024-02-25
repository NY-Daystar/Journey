#!/bin/bash

# ------------------------------------------------------------------
# [Title] : Journey
# [Description] : Docker registry builder (build and pus)
# [Version] : v1.0.0
# [Author] : Lucas Noga
# [Shell] : Bash v5.2.15
# [Usage] : ./journey.sh
#           ./journey.sh --debug
#           ./journey.sh --debug --config
# ------------------------------------------------------------------

PROJECT_NAME=Journey
PROJECT_VERSION=1.0.0

# Options params setup with command parameters
typeset -A CONFIG=(
    [debug]=false            # Debug mode to show more log
    [debug_color]=light_blue # Color to show log in debug mode
    [quiet]=false            # Quiet mode when we build and push image
    [registry]=""
    [default_registry]="castimaging"
)

function main() {
    read_params $@
    log_debug "Launch Project $(log_color "${PROJECT_NAME} : v${PROJECT_VERSION}" "magenta")"

    while [ -z ${CONFIG[registry]} ]; do
        CONFIG+=([registry]=$(ask_registry))

        if [ -z ${CONFIG[registry]} ]; then
            log no registry set please retry
        fi
    done

    ## program execution
    run $@
}

###
# Run script
###
function run {
    args=("$@")
    log_debug "Registry value: ${CONFIG[registry]}"

    ## TODO pour distinguer le type
    # Faire cette appel https://hub.docker.com/_/${CONFIG[registry]}/tags
    # si on trouve alors type librairy sinon type classique

    images=$(get_images)
    echo "${images}"

    echo "Les derniers tags des images Docker (hors 'latest') du dépôt ${CONFIG[registry]} :"

    for image in $images; do
        echo "Tags pour l'image ${CONFIG[registry]}:${image} :"
        first_tag=$(get_image_tags "${image}")
        echo "Premier tag pour l'image ${CONFIG[registry]}:${image} : ${first_tag}"
    done

    exit 0
}

###
# Fetch with curl request images list in registry
# $1 : [string] registry name on docker hub
# returns: [list] images list
###
get_images() {
    # TODO deux url possibles en fonction du type d'image
    # si librairy url="https://hub.docker.com/v2/repositories/library/${CONFIG[registry]}/tags?page_size=25&ordering=last_updated"
    # sinon url="https://hub.docker.com/v2/repositories/${CONFIG[registry]}?page_size=25&ordering=last_updated"
    url="https://hub.docker.com/v2/repositories/${CONFIG[registry]}?page_size=25&ordering=last_updated"
    log $url
    curl -sS $url |
        grep -Po '"name":.*?[^\\]",' |
        awk -F'"' '$2 != "latest" {print $4}'
}

###
# Get tags on docker image
# $1 : [string] docker image name
# returns: [list] tags of the image
###
function get_image_tags() {
    # TODO deux url possibles en fonction du type d'image
    image="$1"
    echo "Tags pour l'image ${CONFIG[registry]}:${image} :"
    curl -sS "https://registry.hub.docker.com/v2/repositories/${CONFIG[registry]}/${image}/tags/?page_size=10" |
        grep -Po '"name":.*?[^\\]",' |
        awk -F'"' '{print $4}'
    echo "--------------"
}

###
# Ask for the user which registry he wants to read
# no parameters
# returns: [string] registry name
###
function ask_registry() {
    read -p "What registry do you want to read images (Ex: ${CONFIG[default_registry]}) : " registry
    echo $registry
}

################################################################### Params Scripts ###################################################################

###
# Setup params passed with the script
# -d | --debug : Setup debug mode
###
function read_params {
    params=("$@") # Convert params into an array

    # Step through all params passed to the script
    for param in "${params[@]}"; do
        log_debug "Option '$param' founded"
        case $param in
        "--help")
            help
            exit 0
            ;;
        "--version" | "-v")
            log Journey ${PROJECT_VERSION}
            exit 0
            ;;
        "-d" | "--debug")
            active_debug_mode
            ;;
        *) ;;
        esac
    done

    log_debug "Dump: $(declare -p CONFIG)"
}

################################################################################
# Help                                                                     #
################################################################################
help() {
    log "Usage journey [-d | --debug] [-v | --version] [--help] [<args>] [OPTIONS...]..."
    log "Version $PROJECT_VERSION"
    log "Get docker images and tags from dockerhub regisry"
    log
    log "Syntax: journey"
    log "Options:"
    log "\t -d, --debug \t\t Show verbose logs"
}

###
# Active the debug mode changing options params
###
function active_debug_mode {
    CONFIG+=([debug]=true)
    log_debug "Debug Mode Activated"
}

################################################################### Utils functions ###################################################################

###
# Return parent folder name in lowercase
###
function get_parent_folder {
    folder=$(basename $(pwd))
    folder_lower=$(echo $folder | tr '[:upper:]' '[:lower:]')
    echo $folder_lower
}

###
# Return datetime of now (ex: 2022-01-10 23:20:35)
###
function get_datetime {
    log $(date '+%Y-%m-%d %H:%M:%S')
}

###
# Ask yes/no question for user and return boolean
# $1 : question to prompt for the user
###
function ask_yes_no {
    message=$1
    read -r -p "$message [y/N] : " ask
    if [ "$ask" == 'y' ] || [ "$ask" == 'Y' ]; then
        echo true
    else
        echo false
    fi
}

################################################################### Logging functions ###################################################################

###
# Simple log function to support color
###
function log {
    echo -e $@
}

typeset -A COLORS=(
    [default]='\033[0;39m'
    [black]='\033[0;30m'
    [red]='\033[0;31m'
    [green]='\033[0;32m'
    [yellow]='\033[0;33m'
    [blue]='\033[0;34m'
    [magenta]='\033[0;35m'
    [cyan]='\033[0;36m'
    [light_gray]='\033[0;37m'
    [light_grey]='\033[0;37m'
    [dark_gray]='\033[0;90m'
    [dark_grey]='\033[0;90m'
    [light_red]='\033[0;91m'
    [light_green]='\033[0;92m'
    [light_yellow]='\033[0;93m'
    [light_blue]='\033[0;94m'
    [light_magenta]='\033[0;95m'
    [light_cyan]='\033[0;96m'
    [nc]='\033[0m' # No Color
)

###
# Log the message in specific color
###
function log_color {
    message=$1
    color=$2
    log ${COLORS[$color]}$message${COLORS[nc]}
}

###
# Log the message if debug mode is activated
###
function log_debug {
    message=$@
    date=$(get_datetime)
    if [ "${CONFIG[debug]}" = true ]; then log_color "[$date] $message" ${CONFIG[debug_color]}; fi
}

main $@
