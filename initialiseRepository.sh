#!/bin/bash

function loadConfigFromFile() {
    if [ -f .templateRepositoryConfig ]; then
        . .templateRepositoryConfig
        echo "INFO: Loaded existing configuration"
    else
        echo "INFO: No configuration found, using interactive mode"
    fi
}

function installPackage() {
    set +e
    if ! $1 --version; then
        if [[ $(uname) == "Darwin" ]]; then
            echo "INFO: Installing $1"
            if ! brew install $1; then
                echo "ERROR: There was an problem installing $1"
                exit 1
            else
                echo "INFO: $1 installed successfully"
            fi
        else
            echo "ERROR: $1 needs to be installed"
            exit 1
        fi
    else
        echo "INFO: All good with $1"
    fi
    set -e
}

function installNvm() {
    set +e
    # Setup the NVM path
    export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion
    # Check if NVM is installed
    if ! nvm version; then 
        echo "ERROR: NVM needs to be installed"
        exit 1
    else
        echo "INFO: All good with NVM"
    fi
    set -e
}

function getRepositoryName() {
    while [ -z "$repositoryName" ]; do
        echo -e "\n\nWhat is the name of the repository you need?"
        read repositoryName
    done
}

function getGitUserName() {
    while [ -z "$GIT_USER" ]; do
        echo "What is the name of your Git Hub ID?"
        read GIT_USER
        if [[ $(curl -L -s -o /dev/null -w "%{http_code}" http://github.com/$GIT_USER) != 200 ]]; then
            echo "ERROR: That ID was not found at http://github.com/$GIT_USER"
            unset GIT_USER
        else
            echo "INFO: Your ID was found at http://github.com/$GIT_USER"
        fi
    done
}

function cloneTemplateRepository() {
    echo "INFO: Creating the repository"
    gh repo create $repositoryName --public --confirm --template="gotreasa/templateRepository"
    cd $repositoryName
    while [[ "$(git branch -a | grep remotes/origin/main)" != *"remotes/origin/main" ]]; do
        git fetch origin
    done
    git checkout main
}

function installLatestNodeAndNpmPackages() {
    # Setup NVM and Node version
    echo "INFO: Installing node"
    nvm install --lts
    nodeVersion=`nvm version` 
    echo $nodeVersion > .nvmrc
    sed -i '' 's/"node": ".*"/"node": "'${nodeVersion}'"/g' package.json
    # Install and update NPM packages
    echo "INFO: Setting up the npm packages"
    npm i
    npx npm-check-updates -u
    npm i
}

function updateRepositoryFiles() {
    sed -i '' 's/gotreasa/'${GIT_USER}'/g' package.json
    sed -i '' 's/templateRepository/'${repositoryName}'/g' package.json
    sed -i '' 's/node-version: \[14.15.1\]/node-version: \['${nodeVersion}'\]/g' .github/workflows/node.js.yml
}

function setupSonar() {
    echo "INFO: Updating sonar properties file"
    sed -i '' 's/gotreasa/'${GIT_USER}'/g' sonar-project.properties
    sed -i '' 's/templateRepository/'${repositoryName}'/g' sonar-project.properties

    while [ -z "$SONAR_SECRET" ]; do
        echo -e "\n\nWhat is the sonar API key?"
        read -s SONAR_SECRET
    done
    gh secret set SONAR_TOKEN -b ${SONAR_SECRET}

    curl --include \
        --request POST \
        --header "Content-Type: application/x-www-form-urlencoded" \
        -u ${SONAR_SECRET}: \
        -d "project=${GIT_USER}_${repositoryName}&organization=${GIT_USER}&name=${repositoryName}" \
    'https://sonarcloud.io/api/projects/create'
}

function setupSnyk() {
    while [ -z "$SNYK_SECRET" ]; do
        echo -e "\n\nWhat is the synk API key?"
        read -s SNYK_SECRET
    done
    gh secret set SNYK_TOKEN -b ${SNYK_SECRET}
}

function saveConfigToFile() {
    echo "INFO: Saving the configuration to file"
    cat > ../.templateRepositoryConfig << EOF
GIT_USER=${GIT_USER}
SONAR_SECRET=${SONAR_SECRET}
SNYK_SECRET=${SNYK_SECRET}
EOF
}

function commitCodeToGit() {
    echo "INFO: Commit code to Git"
    git add .
    git commit -m "feat: setup of the repository"
    git push origin main
}

function printSuccessMessage() {
    echo "INFO: Repository setup for ${repositoryName} is now complete"
}

loadConfigFromFile
installPackage "git"
installPackage "gh"
installPackage "curl"
installNvm
getRepositoryName
getGitUserName
cloneTemplateRepository
installLatestNodeAndNpmPackages
updateRepositoryFiles
setupSonar
setupSnyk
saveConfigToFile
commitCodeToGit
printSuccessMessage
