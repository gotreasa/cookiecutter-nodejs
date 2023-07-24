#!/bin/bash

function start() {
    echo "🏁    Starting the pre-checks 🧾 for {{cookiecutter.project_name}}"
}

function installPackage() {
    TYPE=$2
    PACKAGE=$1
    set +e
    if ! [ -x "$(command -v $PACKAGE)" ]; then
        if [[ $(uname) == "Darwin" ]]; then
            echo -e "\n\nℹ️    Installing $PACKAGE"
            if ! brew install $TYPE $PACKAGE; then
                echo -e "\n⛔️    There was an problem installing $PACKAGE"
                exit 1
            else
                echo -e "\n✅    $PACKAGE installed successfully\n"
            fi
        else
            echo -e "\n⛔️    $PACKAGE needs to be installed"
            exit 1
        fi
    else
        echo -e "\n✅    All good with $PACKAGE\n"
    fi
    set -e
}

function verifyDockerIsRunning() {
    echo -e "\n\nℹ️    Checking Docker is running"
    if ! docker info &>/dev/null; then
        echo -e "\n✅    Docker was not running, Starting...\n"
        open --background -a Docker
    else
        echo -e "\n✅    Docker is running\n"
    fi 
}

function installNvm() {
    set +e
    # Setup the NVM path
    source $(brew --prefix nvm)/nvm.sh
    # Check if NVM is installed
    if [ -z "$(command -v nvm)" ]; then 
        echo -e "\n⛔️    NVM needs to be installed"
        exit 1
    else
        echo -e "\n✅    All good with NVM\n"
    fi
    set -e
}

function complete() {
    echo "🚀    Completed the pre-checks 🧾 for {{cookiecutter.project_name}}"
}

start
installPackage "git"
installPackage "gh"
installPackage "curl"
installPackage "ruby"
installPackage "chef/chef/inspec"
installPackage "docker" "--cask"
verifyDockerIsRunning
installNvm
complete