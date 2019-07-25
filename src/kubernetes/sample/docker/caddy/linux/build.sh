IMAGE_NAME=caddy-test
IMAGE_VERSION=1.0.1

docker build --platform linux -t $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION-linux .
docker login $ACR_HOSTNAME
# use azurerm_client_id & azurerm_client_secret to login
docker push $ACR_HOSTNAME/$IMAGE_NAME
