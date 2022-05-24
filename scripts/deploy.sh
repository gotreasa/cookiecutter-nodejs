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

echo "👌 Select the app project"
ibmcloud ce project select --name $PROJECT_NAME
echo "💿 Update the app"
ibmcloud ce app update --name $APP_NAME --image $IMAGE_REPOSITORY_URL/$IMAGE_NAMESPACE/$APP_IMAGE --registry-secret $IMAGE_NAMESPACE
echo "🖨 Details of the app URL"
ibmcloud ce app get --name $APP_NAME --output url
