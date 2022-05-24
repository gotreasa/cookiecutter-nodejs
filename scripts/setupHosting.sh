#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. $SCRIPT_DIR/hosting.conf

checkIbmcloudCli

echo "🔐 Logging into IBMCloud"
ibmcloud login -a $IBMCLOUD_URL --apikey $IBMCLOUD_APIKEY --no-region
echo "🎯 Targetting the correct region and resource group"
ibmcloud target -r $IBMCLOUD_REGION -g $IBMCLOUD_RESOURCE_GROUP
echo "🔐 Logging into the container registry"
ibmcloud cr login
echo "🧱 Setting up the container registry namespace"
ibmcloud cr namespace-add $IMAGE_NAMESPACE
ibmcloud cr retention-policy-set --images 1 $IMAGE_NAMESPACE

echo "🧱 Creating and selecting the Code Engine project"
ibmcloud ce project create --name $PROJECT_NAME
ibmcloud ce project select --name $PROJECT_NAME
ibmcloud ce registry create --name $IMAGE_NAMESPACE --server $IMAGE_REPOSITORY_URL -username iamapikey --password $IBMCLOUD_APIKEY

$SCRIPT_DIR/buildAndPublish.sh

ibmcloud ce app create --name $APP_NAME --image $IMAGE_REPOSITORY_URL/$IMAGE_NAMESPACE/$APP_IMAGE --min-scale 1 --max-scale 1 --port 9080 --registry-secret $IMAGE_NAMESPACE
travis env set IBMCLOUD_APIKEY $IBMCLOUD_APIKEY --private
travis env set REGISTRY_SECRET $IMAGE_NAMESPACE --private
travis env set APP_HOST $(ibmcloud ce app get --name $APP_NAME --output url) --public
