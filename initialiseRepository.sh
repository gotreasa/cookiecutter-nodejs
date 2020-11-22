#!/bin/bash
set +x
# Check Git is installed
if ! git --version; then
    if [[ $(uname) == "Darwin" ]]; then
        brew install git
    else
        echo "ERROR: Git needs to be installed"
        exit 1
    fi
else
    echo "INFO: All good with Git"
fi

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

while [ -z "$repositoryName" ]; do
    echo -e "\n\nWhat is the name of the repository you need?"
    read repositoryName
done

while [ -z "$gitUser" ]; do
    echo "What is the name of your Git Hub ID?"
    read gitUser
    if [[ $(curl -L -s -o /dev/null -w "%{http_code}" http://github.com/$gitUser) != 200 ]]; then
        echo "ERROR: hat ID was not found at http://github.com/$gitUser"
        unset gitUser
    else
        echo "INFO: Your ID was found at http://github.com/$gitUser"
    fi
done

# Clone the template repository to a new repository name
echo "INFO: Creating the repository"
git clone git@github.com:gotreasa/templateRepository.git $repositoryName
cd $repositoryName

# Setup NVM and Node version
echo "INFO: Installing node"
nvm install --lts
nodeVersion=`nvm version` 
echo $nodeVersion > .nvmrc
sed -i '' 's/"node": ".*"/"node": "'${nodeVersion}'"/g' package.json
sed -i '' 's/gotreasa/'${gitUser}'/g' package.json
sed -i '' 's/templateRepository/'${repositoryName}'/g' package.json
sed -i '' "s/node-version: [14.15.1]/node-version: [${nodeVersion}/g" .github/workflows/node.js.yml
# Install and update NPM packages
echo "INFO: Setting up the npm packages"
npm i
npx npm-check-updates -u
npm i
echo "INFO: Initialising the repository"
npm init

echo "INFO: Updating sonar properties file"
sed -i '' 's/gotreasa/'${gitUser}'/g' sonar-project.properties
sed -i '' 's/templateRepository/'${repositoryName}'/g' sonar-project.properties

# Setup git
echo "INFO: Initialise Git"
rm -rf .git
git init
git remote add origin https://github.com/$gitUser/${repositoryName}
git checkout -b main
git add .
echo "INFO: Setup Husky"
npx husky init
echo "INFO: Commit code to Git"
git commit -m "feat: setup of the repository" --no-verify
echo "INFO: Repository setup for ${repositoryName} is now complete"
