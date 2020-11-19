#!/bin/bash
# Check Git is installed
if ! git --version; then
    echo "Git needs to be installed"
    exit 1
else
    echo "All good with Git"
fi

# Setup the NVM path
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion
# Check if NVM is installed
if ! nvm version; then 
    echo "NVM needs to be installed"
    exit 1
else
    echo "All good with NVM"
fi

while [ -z "$repositoryName" ]; do
    echo "What is the name of the repository you need?"
    read repositoryName
done

while [ -z "$gitUser" ]; do
    echo "What is the name of your Git Hub ID?"
    read gitUser
    if [[ $(curl -L -s -o /dev/null -w "%{http_code}" http://github.com/$gitUser) != 200 ]]; then
        echo "That ID was not found at http://github.com/$gitUser"
        unset gitUser
    else
        echo "Your ID was found at http://github.com/$gitUser"
    fi
done

# Clone the template repository to a new repository name
git clone git@github.com:gotreasa/templateRepository.git $repositoryName
cd $repositoryName

# Setup NVM and Node version
nvm install --lts
nodeVersion=`nvm version` 
echo $nodeVersion > .nvmrc
sed -i '' 's/"node": ".*"/"node": "'${nodeVersion}'"/g' package.json
sed -i '' 's/gotreasa/'${gitUser}'/g' package.json
sed -i '' 's/templateRepository/'${repositoryName}'/g' package.json
# Install and update NPM packages
npm i
npx npm-check-updates -u
npm i

# Setup git
rm -rf .git
git init
git remote add origin https://github.com:$gitUser/${repositoryName}
git checkout -b main
git add .
git commit -m "feat: setup of the repository"
git push origin main
