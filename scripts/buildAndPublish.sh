#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )
. $SCRIPT_DIR/hosting.conf

echo "🛠 Building docker image"
docker-compose build --parallel
echo "✅ Completed building the image"


checkIbmcloudCli


echo "🔐 Logging into IBMCloud"
ibmcloud login -a $IBMCLOUD_URL --apikey $IBMCLOUD_APIKEY --no-region
echo "🎯 Targetting the correct region and resource group"
ibmcloud target -r $IBMCLOUD_REGION -g $IBMCLOUD_RESOURCE_GROUP
echo "🔐 Logging into the container registry"
ibmcloud cr login

echo "🔖 Tagging the App docker image"
docker tag $APP_IMAGE:latest $IMAGE_REPOSITORY_URL/$IMAGE_NAMESPACE/$APP_IMAGE:latest

echo "⏫ Pushing the App docker image"
docker push $IMAGE_REPOSITORY_URL/$IMAGE_NAMESPACE/$APP_IMAGE:latest
echo "🏁 Finished publishing the docker images"
