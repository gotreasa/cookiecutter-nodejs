#!/bin/bash

function start() {
    echo "🏁    Starting the configuration of {{cookiecutter.project_name}}"
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

verifyDockerIsRunning() {
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
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    # Check if NVM is installed
    if [ -z "$(command -v nvm)" ]; then 
        echo -e "\n⛔️    NVM needs to be installed"
        exit 1
    else
        echo -e "\n✅    All good with NVM\n"
    fi
    set -e
}

function setupRepository() {
    echo -e "\n\nℹ️    Setting up the remote repository"
    gh repo create {{cookiecutter.github_url}}/{{cookiecutter.github_org}}/{{cookiecutter.project_slug}} --public
    git init
    git remote add origin git@{{cookiecutter.github_url}}:{{cookiecutter.github_org}}/{{cookiecutter.project_slug}}.git
    echo -e "👌    Completed setting up the remote repository"
}

function writeTokensToEnvFile() {
    echo -e "\n\nℹ️    Saving the token to the environment file"
    cat > .env << EOF
IBMCLOUD_APIKEY={{cookiecutter.ibm_cloud_api_key}}
PACT_BROKER_TOKEN={{cookiecutter.pact_broker_token}}
SONAR_TOKEN={{cookiecutter.sonar_token}}
SNYK_TOKEN={{cookiecutter.snyk_token}}
EOF
}

function installLatestNodeAndNpmPackages() {
    nvm use
    # Setup NVM and Node version
    # echo -e "\n\nℹ️    Installing NodeJS"
    # nvm install --lts
    # nodeVersion=`nvm version` 
    # echo $nodeVersion > .nvmrc
    # sed -i '' 's/"node": ".*"/"node": "'${nodeVersion}'"/g' package.json
    # # Install and update NPM packages
    # echo "ℹ️    Setting up the npm packages"
    # npm ci
    # npx npm-check-updates --upgrade
    npm i
}

function setupSonar() { # TDOD Fix this for the organisation
    projectName={{cookiecutter.github_org}}_{{cookiecutter.project_slug}}
    projectOrganisation={{cookiecutter.sonar_org}}
    projectKey={{cookiecutter.github_org}}_{{cookiecutter.project_slug}}
    echo -e "\n\nℹ️    Updating sonar properties file"


    curl --include \
        --request POST \
        --header "Content-Type: application/x-www-form-urlencoded" \
        -u {{cookiecutter.sonar_token}}: \
        -d "project=${projectKey}&organization=${projectOrganisation}&name=${projectName}" \
    'https://sonarcloud.io/api/projects/create'

    curl --location --include \
        --request POST \
        --header "Content-Type: application/x-www-form-urlencoded" \
        -u {{cookiecutter.sonar_token}}: \
        -d "key=sonar.leak.period&value=previous_version&component=${projectKey}" \
        'https://sonarcloud.io/api/settings/set'

    curl --location --include \
        --request POST \
        --header "Content-Type: application/x-www-form-urlencoded" \
        -u {{cookiecutter.sonar_token}}: \
        -d "key=sonar.leak.period.type&value=previous_version&component=${projectKey}" \
        'https://sonarcloud.io/api/settings/set'
}


function snycTravis() {
    echo -e "\n\nℹ️    Syncing Travis"
    travis sync
}

function enableTravis() {
    echo -e "\n\nℹ️    Enabling Travis"
    yes | travis enable
    travis env set SNYK_TOKEN {{cookiecutter.snyk_token}} --private
    travis env set SONAR_TOKEN {{cookiecutter.sonar_token}} --private
    travis env set PACT_BROKER_TOKEN {{cookiecutter.pact_broker_token}} --private
    travis env set IBMCLOUD_APIKEY {{cookiecutter.ibm_cloud_api_key}} --private
}

function updateSecrets() {
    echo -e "\n\nℹ️    Updating the secrets baseline to prevent new secrets being added"
    npm run detect-secrets:update-baseline
    git add .secrets.baseline
}


function commitCodeToGit() {
    echo -e "\n\nℹ️    Commit code to Git"
    git add .
    git commit -m "feat: setup of the repository"
    git push origin main
}

function printSuccessMessage() {
    echo -e "\n\n🏃🏁    Repository setup for ${repositoryName} is now complete. 🚀"
}

function launchVSCode() {
    echo -e "\n\n👩‍💻    Attempting to start up Visual Studio code"
    if ! [ -x "$(command -v code)" ]; then
        if [[ $(uname) == "Darwin" ]]; then
            export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
        fi
    fi
    code .
}

function enableSonarQualityGate() {
    echo -e "\n\nℹ️    Enabling the Sonar quality gate"
    echo "sonar.qualitygate.wait=true" >> sonar-project.properties
    git add sonar-project.properties
    git commit -m "chore: enabling the sonar quality gate"
    git push origin main --no-verify
    echo  "✅    Sonar quality gate check enabled!"
}

start
installPackage "git"
installPackage "gh"
installPackage "curl"
installPackage "docker" "--cask"
verifyDockerIsRunning
setupRepository
installNvm
snycTravis
installLatestNodeAndNpmPackages
setupSonar
enableTravis
updateSecrets
writeTokensToEnvFile
commitCodeToGit
printSuccessMessage
launchVSCode
enableSonarQualityGate
