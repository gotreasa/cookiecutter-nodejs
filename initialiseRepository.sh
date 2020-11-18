#!/bin/bash
if ! git --version; then
    echo "Git needs to be installed"
    exit 1
else
    echo "All good with Git"
fi
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion
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

git clone git@github.com:gotreasa/templateRepository.git $repositoryName
cd $repository

nvm install --lts
nodeVersion=`nvm version` 
echo $nodeVersion > .nvmrc
sed -i 's/"node": ".*"/"node": "'${nodeVersion}'"/g' package.json


rm -rf .git
git init
git remote add git remote add origin git@github.com:gotreasa/${repository}.git